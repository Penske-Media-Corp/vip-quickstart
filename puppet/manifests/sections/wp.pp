$plugins = [
  'debug-bar',
  'debug-bar-console',
  'debug-bar-cron',
  'debug-bar-extender',
  'debug-bar-slow-actions',
  'debug-bar-query-count-alert',
  'debug-bar-remote-requests',
  'log-deprecated-notices',
  'log-viewer',
  'monster-widget',
  'user-switching',
  'wordpress-importer',

  # WordPress.com
  'keyring',
  'mrss',
  'polldaddy',
  'rewrite-rules-inspector',
]

$github_plugins = {
    'vip-scanner' => 'https://github.com/Automattic/vip-scanner',

    # WordPress.com
    'jetpack'        => 'https://github.com/Automattic/jetpack',
    'media-explorer' => 'https://github.com/Automattic/media-explorer',
    'writing-helper' => 'https://github.com/automattic/writing-helper',
}

# Install WordPress
exec { 'wp install /srv/www/wp':
  command => "/usr/bin/wp core multisite-install --url='${quickstart_domain}' --title='${quickstart_domain}' --admin_email='wordpress@${quickstart_domain}' --admin_name='wordpress' --admin_password='wordpress'",
  cwd     => '/srv/www/wp',
  unless  => "test -z ${quickstart_domain}",
  user    => 'vagrant',
  require => [
    Vcsrepo['/srv/www/wp'],
    Class['wp::cli'],
    Line['path:/srv/www/wp'],
  ]
}

# Install GitHub Plugins
$github_plugin_keys = keys( $github_plugins )
gitplugin { $github_plugin_keys:
    git_urls => $github_plugins
}

# Install plugins
wp::plugin { $plugins:
  location    => '/srv/www/wp',
  networkwide => true,
  require     => [
    Exec['wp install /srv/www/wp'],
    File['/srv/www/wp-content/plugins'],
    Gitplugin[ $github_plugin_keys ],
  ]
}

# Update all the plugins
wp::command { 'plugin update --all':
  command  => 'plugin update --all',
  location => '/srv/www/wp',
  require  => Exec['wp install /srv/www/wp'],
}

# Install WP-CLI
class { 'wp::cli': ensure  => installed }

# Make sure the themes directory exists
file { '/srv/www/wp-content/themes': ensure => 'directory' }

# Make sure the plugins directory exists
file { '/srv/www/wp-content/plugins': ensure => 'directory' }

# VCS Checkout
vcsrepo { '/srv/www/wp':
  ensure   => latest,
  source   => 'http://core.svn.wordpress.org/trunk/',
  provider => svn,
}

# cron job to run every hour
cron { '/srv/www/wp':
  command => '/usr/bin/svn up /srv/www/wp > /dev/null 2>&1',
  minute  => '0',
  hour    => '*',
  user    => 'vagrant',
}

vcsrepo { '/srv/www/wp-content/themes/vip/plugins':
  ensure   => latest,
  source   => 'https://vip-svn.wordpress.com/plugins/',
  provider => svn,
}

# cron job to run every hour
cron { '/srv/www/wp-content/themes/vip/plugins':
  command => '/usr/bin/svn up /srv/www/wp-content/themes/vip/plugins > /dev/null 2>&1',
  minute  => '0',
  hour    => '*',
  user    => 'vagrant',
}

vcsrepo { '/srv/www/wp-content/themes/pub/twentyfourteen':
  ensure   => latest,
  source   => 'https://wpcom-themes.svn.automattic.com/twentyfourteen',
  provider => svn,
}

vcsrepo { '/srv/www/wp-tests':
  ensure   => latest,
  source   => 'http://develop.svn.wordpress.org/trunk/',
  provider => svn,
}

# Create a local config
file { 'local-config.php':
  ensure => present,
  path   => '/srv/www/local-config.php',
  notify => Exec['generate salts']
}

# Add default path to local WP-CLI config
line { 'path:/srv/www/wp':
  line => 'path:/srv/www/wp',
  file => '/srv/www/wp-cli.yml',
}

# Add default domain to local WP-CLI config
if ( $quickstart_domain ) {
  line { "url:${quickstart_domain}":
    line => "url:${quickstart_domain}",
    file => '/srv/www/wp-cli.yml',
  }
}

exec { 'generate salts':
  command     => 'printf "<?php\n" > /srv/www/local-config.php; curl https://api.wordpress.org/secret-key/1.1/salt/ >> /srv/www/local-config.php',
  refreshonly => true
}
