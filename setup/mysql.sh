#! /usr/bin/env bash

DB_ROOT_PWD=$1
DB_NAME=$2
DB_USER=$3
DB_USER_PWD=$4


echo -e "\n--- Install MySQL with admin PWD: $DB_ROOT_PWD ---\n"
echo "mysql-server mysql-server/root_password password $DB_ROOT_PWD" | sudo debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $DB_ROOT_PWD" | sudo debconf-set-selections

sudo apt-get -yqq install mysql-server

echo -e "\n--- Setting up our MySQL user $DB_USER for $DB_NAME ---\n"
mysql -uroot -p$DB_ROOT_PWD -e "CREATE DATABASE $DB_NAME"
mysql -uroot -p$DB_ROOT_PWD -e "grant all privileges on $DB_NAME.* to '$DB_USER'@'localhost' identified by '$DB_USER_PWD'"
