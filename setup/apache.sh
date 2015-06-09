#! /usr/bin/env bash
 
# Variables
APPENV=local
DBHOST=localhost
DBNAME=dbname
DBUSER=dbuser
DBPASSWD=test123
PHPMYADMINPORT=81

echo -e "\n--- Mkay, installing now... ---\n"
cd ~
sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' .bashrc
 
echo -e "\n--- Updating packages list ---\n"
sudo apt-get -qq update
export DEBIAN_FRONTEND=noninteractive
 
echo -e "\n--- Install base packages ---\n"
sudo apt-get -yqq install curl git
 
echo -e "\n--- Install MySQL specific packages and settings ---\n"
echo "mysql-server mysql-server/root_password password $DBPASSWD" | sudo debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $DBPASSWD" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $DBPASSWD" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password $DBPASSWD" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $DBPASSWD" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none" | sudo debconf-set-selections
sudo apt-get -yqq install mysql-server phpmyadmin
 
echo -e "\n--- Setting up our MySQL user and db ---\n"
mysql -uroot -p$DBPASSWD -e "CREATE DATABASE $DBNAME"
mysql -uroot -p$DBPASSWD -e "grant all privileges on $DBNAME.* to '$DBUSER'@'localhost' identified by '$DBPASSWD'"
 
echo -e "\n--- Installing PHP-specific packages ---\n"
sudo apt-get -yqq install php5 apache2 libapache2-mod-php5 php5-curl php5-gd php5-mcrypt php5-mysql php-apc
 
echo -e "\n--- Enabling mod-rewrite ---\n"
sudo a2enmod rewrite
 
echo -e "\n--- Allowing Apache override to all ---\n"
sudo sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf
 
echo -e "\n--- Setting document root to public directory ---\n"
#rm -rf /var/www
#ln -fs /vagrant/public /var/www
 
echo -e "\n--- We definitly need to see the PHP errors, turning them on ---\n"
sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/apache2/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/apache2/php.ini
 
echo -e "\n--- Turn off disabled pcntl functions so we can use Boris ---\n"
sudo sed -i "s/disable_functions = .*//" /etc/php5/cli/php.ini

echo -e "\n--- Configure Apache to use phpmyadmin ---\n"
sudo sed -i -e '$a\' -e 'Listen '"${PHPMYADMINPORT}"'' -e '/Listen '"${PHPMYADMINPORT}"'/d' /etc/apache2/ports.conf
# TODO: Nicer solution anyone?
sudo bash -c "cat > /etc/apache2/conf-available/phpmyadmin.conf" << "EOF"
<VirtualHost *:%PLACEHOLDER%>
    ServerAdmin webmaster@localhost
    DocumentRoot /usr/share/phpmyadmin
    DirectoryIndex index.php
    ErrorLog ${APACHE_LOG_DIR}/phpmyadmin-error.log
    CustomLog ${APACHE_LOG_DIR}/phpmyadmin-access.log combined
</VirtualHost>
EOF
sudo sed -i 's/%PLACEHOLDER%/'"${PHPMYADMINPORT}"'/g' /etc/apache2/conf-available/phpmyadmin.conf
sudo a2enconf phpmyadmin

# TODO: Environment variables in Virtualhost?
# SetEnv APP_ENV $APPENV
# SetEnv DB_HOST $DBHOST
# SetEnv DB_NAME $DBNAME
# SetEnv DB_USER $DBUSER
# SetEnv DB_PASS $DBPASSWD 
echo -e "\n--- Add environment variables to Apache ---\n"
sudo bash -c "cat > /etc/apache2/sites-enabled/000-default.conf" <<EOF
<VirtualHost *:80>
    DocumentRoot /var/www
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined    
</VirtualHost>
EOF
 
echo -e "\n--- Restarting Apache ---\n"
sudo service apache2 restart
 
#echo -e "\n--- Installing Composer for PHP package management ---\n"
#curl --silent https://getcomposer.org/installer
#mv composer.phar /usr/local/bin/composer
 
#echo -e "\n--- Installing NodeJS and NPM ---\n"
#apt-get -y install nodejs > /dev/null 2>&1
#curl --silent https://npmjs.org/install.sh | sh > /dev/null 2>&1
 
#echo -e "\n--- Installing javascript components ---\n"
#npm install -g gulp bower > /dev/null 2>&1
 
#echo -e "\n--- Updating project components and pulling latest versions ---\n"
#cd /vagrant
#sudo -u vagrant -H sh -c "composer install" > /dev/null 2>&1
#cd /vagrant/client
#sudo -u vagrant -H sh -c "npm install" > /dev/null 2>&1
#sudo -u vagrant -H sh -c "bower install -s" > /dev/null 2>&1
#sudo -u vagrant -H sh -c "gulp" > /dev/null 2>&1
 
#echo -e "\n--- Creating a symlink for future phpunit use ---\n"
#ln -fs /vagrant/vendor/bin/phpunit /usr/local/bin/phpunit
 
#echo -e "\n--- Add environment variables locally for artisan ---\n"
cat >> /home/vagrant/.bashrc <<EOF

# Set envvars
export APP_ENV=$APPENV
export DB_HOST=$DBHOST
export DB_NAME=$DBNAME
export DB_USER=$DBUSER
export DB_PASS=$DBPASSWD
EOF
