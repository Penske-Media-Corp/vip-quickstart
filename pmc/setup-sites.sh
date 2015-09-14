#!/bin/bash

##################################
########  FUNCTIONS  #############
##################################

function is_program_installed {
	# set to 1 initially
	local return_=1

	# set to 0 if not found
	type $1 >/dev/null 2>&1 || { local return_=0; }

	# return value
	return $return_
}

function echo_fail {
	# start red colour output
	printf "\n\e[31m"

	# echo out first argument
	printf " ✘   ${1}  "

	# reset colours back to normal
	printf "\e[0m\n"
}

function echo_pass {
	# start green colour output
	printf "\n\e[32m"

	# echo out first argument
	printf " ✔   ${1}  "
	
	# reset colours back to normal
	printf "\e[0m\n"
}

DOMAIN='vip.local'
export HTTP_USER_AGENT="WP_CLI"
export HTTP_HOST="${DOMAIN}"

cd `dirname "$0"`
sudo usermod -a -G www-data vagrant

#####################
# Required packages #
#####################

# mcrypt
if [[ -z "`dpkg -s php5-mcrypt | grep "Status: install ok installed"`" ]]; then
	apt-get -y install php5-mcrypt mcrypt
	ln -s /etc/php5/mods-available/mcrypt.ini /etc/php5/cli/conf.d/20-mcrypt.ini
	ln -s /etc/php5/mods-available/mcrypt.ini /etc/php5/fpm/conf.d/20-mcrypt.ini
	service php5-fpm restart
fi;

# PHPUnit
# added this because VIP Quickstart tries to install PHPUnit from PEAR
# which doesn't work reliably & because PHP PEAR is now defunct & shouldn't
# be relied upon.

is_program_installed phpunit

if [ $? -eq 0 ]; then
	echo_fail 'Big surprise, PHPUnit was not installed'

	echo 'Downloading PHPUnit.....'

	wget https://phar.phpunit.de/phpunit.phar -O phpunit.phar

	echo 'Moving PHPUnit to local scope.....'

	mv phpunit.phar /usr/local/bin/phpunit
	chmod +x /usr/local/bin/phpunit

	echo_pass 'PHPUnit installed'
fi

# composer

is_program_installed composer

if [ $? -eq 0 ]; then
	echo 'Downloading Composer.....'
	curl -sS https://getcomposer.org/installer | php
	php composer.phar install

	echo 'Moving Composer to local scope.....'
	mv composer.phar /usr/local/bin/composer
	chmod +x /usr/local/bin/composer

	echo_pass 'Composer installed'
fi;

# nodejs

is_program_installed node

if [ $? -eq 0 ]; then
	echo 'Installing NodeJS.....'

	sudo apt-get update
	sudo apt-get install -y nodejs

	echo_pass 'NodeJS installed'
fi

# mobify client
if [ -z "`mobify`" ]; then
	sudo npm -g install mobify-client
	echo_pass 'Mobify client installed'
fi

# compass
if [ -z "`which compass`" ]; then
	sudo apt-get install rubygems -y
	sudo apt-get install ruby -y
	sudo gem install sass compass compass-rgbapng compass-photoshop-drop-shadow sassy-strings compass-import-once
	echo_pass 'Compass installed'
fi

######################
# WordPress Projects #
######################

# workaround pmc_analytics required this theme to be at this location.
if [ ! -e /srv/www/wp-content/themes/twentyfourteen ]; then
	ln -s /srv/www/wp-content/themes/pub/twentyfourteen/ /srv/www/wp-content/themes/twentyfourteen
fi

# eventbrite-venue theme required for pmc-conference
if [ ! -e /srv/www/wp-content/themes/eventbrite-venue ]; then
	svn co https://wpcom-themes.svn.automattic.com/eventbrite-venue/ /srv/www/wp-content/themes/eventbrite-venue
fi

if [ ! -f ~/.ssh/bitbucket.org_id_rsa ]; then
	bash /srv/pmc/bitbucket-gen-key.sh
	sudo chmod 600 ~/.ssh/bitbucket.org_id_rsa
fi

sed -e '$a\' -e "define('SUBDOMAIN_INSTALL', true );" -e "/define\s*(\s*'SUBDOMAIN_INSTALL'/d" -i /srv/www/local-config.php
sed -e '$a\' -e "define('AUTOMATIC_UPDATER_DISABLED', false );" -e "/define\s*(\s*'AUTOMATIC_UPDATER_DISABLED'/d" -i /srv/www/local-config.php
sed -e '$a\' -e "define('WP_CACHE_KEY_SALT', \$_SERVER['HTTP_HOST'] );" -e "/define\s*(\s*'WP_CACHE_KEY_SALT'/d" -i /srv/www/local-config.php

if [ "0" == "`/usr/bin/wp --path=/srv/www/wp network meta get 1 subdomain_install`" ]; then
	/usr/bin/wp --path=/srv/www/wp network meta update 1 subdomain_install 1
fi

sudo /usr/bin/wp --allow-root --path=/srv/www/wp --url=${DOMAIN} pmc-site set-domain ${DOMAIN}

if [ ! -d "/srv/www/wp-content/themes/vip/pmc-plugins" ]
then
	printf "\nDownloading pmc-plugins...\n"
	if [ ! -f /home/vagrant/.ssh/bitbucket.org_id_rsa ]
	then
		printf "\nSkipping this step, SSH key has not been created.\n"
	else
		git clone git@bitbucket.org:penskemediacorp/pmc-plugins.git /srv/www/wp-content/themes/vip/pmc-plugins
	fi
fi

while IFS=$',\n\r' read site_slug site_name site_theme
do
	[[ $site_slug = \#* ]] && continue

	if [ "" != "$1" ]; then
		[[ "$1" != "${site_slug}" ]] && continue
	fi

	repo=${site_theme}
	echo "Setting up site: ${site_slug}"

	if [ ! -d "/srv/www/wp-content/themes/vip/${site_theme}" ]
	then
		printf "\nDownloading $repo theme...\n"
		if [ ! -f /home/vagrant/.ssh/bitbucket.org_id_rsa.pub ]
		then
			printf "\nSkipping this step, SSH key has not been created.\n"
		else
			git clone git@bitbucket.org:penskemediacorp/${repo}.git /srv/www/wp-content/themes/vip/${site_theme}
		fi
	fi

	STATUS=`/usr/bin/wp --path=/srv/www/wp site list --fields=domain --format=csv | grep "${site_slug}.${DOMAIN}"`
	if [ "" == "${STATUS}" ]; then
		/usr/bin/wp --path=/srv/www/wp site create --slug=${site_slug} --title=${site_name}
	fi

	STATUS=`/usr/bin/wp --path=/srv/www/wp --url=${site_slug}.${DOMAIN} theme status vip/${site_theme} | grep 'Status: Inactive'`
	if [ "" != "${STATUS}" ]; then
		/usr/bin/wp --path=/srv/www/wp theme enable vip/${site_theme} --network
		/usr/bin/wp --path=/srv/www/wp --url=${site_slug}.${DOMAIN} theme activate vip/${site_theme}
	fi

done < ./sites

##########################
# PMC Specific scripts  #
##########################

[ -d pmc-setup-sites ] || mkdir pmc-setup-sites

cd /srv/pmc/pmc-setup-sites/

sudo git init

sudo git add .

sudo git remote rm origin

sudo git remote add origin https://github.com/Penske-Media-Corp/pmc-setup-sites.git

sudo git pull origin master

FILE="pmc-setup-sites.sh"
if [ -f $FILE ];
then
    bash $FILE
else
    echo "File $FILE does not exists"
fi

echo_pass "Site setup finished."
