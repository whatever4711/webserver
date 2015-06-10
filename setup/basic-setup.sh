#! /usr/bin/env bash

cd ~
sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' .bashrc
 
echo -e "\n--- Updating packages list ---\n"
sudo apt-get -qq update
export DEBIAN_FRONTEND=noninteractive
 
echo -e "\n--- Install base packages ---\n"
sudo apt-get -yqq install curl git ed

echo -e "\n--- Installing Apache packages ---\n"
sudo apt-get -yqq install apache2

echo -e "\n--- Installing PHP-specific packages ---\n"
sudo apt-get -yqq install php5 libapache2-mod-php5 php5-curl php5-gd php5-mcrypt php5-mysql php-apc

echo -e "\n--- Installing Python 3 ---\n"
sudo apt-get -yqq install python3 python3-pip


