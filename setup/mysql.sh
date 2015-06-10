#! /usr/bin/env bash

DB_ROOT_PWD=$1
DB_NAME=$2
DB_USER=$3
DB_USER_PWD=$4
APP_USER_AND_DB=$5
APP_DB_PWD=$6


echo -e "\n--- Install MySQL with admin PWD: $DB_ROOT_PWD ---\n"
echo "mysql-server mysql-server/root_password password $DB_ROOT_PWD" | sudo debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $DB_ROOT_PWD" | sudo debconf-set-selections

sudo apt-get -yqq install mysql-server

echo -e "\n--- Setting up our MySQL user $DB_USER for $DB_NAME ---\n"
mysql -uroot -p$DB_ROOT_PWD -e "CREATE DATABASE $DB_NAME"
mysql -uroot -p$DB_ROOT_PWD -e "grant all privileges on $DB_NAME.* to '$DB_USER'@'localhost' identified by '$DB_USER_PWD'"

echo -e "\n--- Setting up MySQL for $APP_USER_AND_DB ---\n"
mysql -uroot -p$DB_ROOT_PWD -e "CREATE DATABASE $APP_USER_AND_DB"
mysql -uroot -p$DB_ROOT_PWD -e "grant all privileges on $APP_USER_AND_DB.* to '$APP_USER_AND_DB'@'localhost' identified by '$APP_DB_PWD'"

