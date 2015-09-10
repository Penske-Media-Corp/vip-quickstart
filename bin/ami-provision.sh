#!/bin/bash

# Update apt
sudo apt-get update --yes --quiet

# Install requirements
sudo apt-get install git --yes --quiet
sudo apt-get install puppet --yes --quiet

# Download Quickstart
sudo git clone https://github.com/Automattic/vip-quickstart.git /srv

# Install Quickstart
sudo /srv/bin/vip-init --server --domain=vip.dev

mkdir -p /srv/pmc

sudo git clone https://github.com/Penske-Media-Corp/pmc.git /srv/pmc

# Delete all authorized_key files
sudo find / -name "authorized_keys" -print -exec rm {} \;
