#! /usr/bin/env bash
 
# Variables
PHPMYADMIN_PORT=$1
DB_HOST=$2
DB_PORT="3306"
APP_NAME=$3
APP_USER_AND_DB=$4
APP_DB_PWD=$5
APP_ADMIN=$6
APP_ADMIN_PWD=$7
APP_ADMIN_MAIL=$8


echo -e "\n--- Enabling mod-rewrite ---\n"
sudo a2enmod rewrite
 
echo -e "\n--- Allowing Apache override to all ---\n"
sudo sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf
 
#echo -e "\n--- Setting document root to public directory ---\n"
#rm -rf /var/www
#ln -fs /vagrant/public /var/www
 
echo -e "\n--- We definitly need to see the PHP errors, turning them on ---\n"
sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/apache2/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/apache2/php.ini
 
echo -e "\n--- Turn off disabled pcntl functions so we can use Boris ---\n"
sudo sed -i "s/disable_functions = .*//" /etc/php5/cli/php.ini

echo -e "\n--- Configure Apache to use phpmyadmin ---\n"
sudo sed -i -e '$a\' -e 'Listen '"${PHPMYADMIN_PORT}"'' -e '/Listen '"${PHPMYADMIN_PORT}"'/d' /etc/apache2/ports.conf
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
sudo sed -i 's/%PLACEHOLDER%/'"${PHPMYADMIN_PORT}"'/g' /etc/apache2/conf-available/phpmyadmin.conf
sudo a2enconf phpmyadmin

echo -e "\n--- For Python web applications ---\n"
sudo apt-get install -yqq python-setuptools libapache2-mod-wsgi-py3 virtualenv
sudo a2dismod mpm_event
sudo a2enmod wsgi

sudo mkdir -p /var/django
sudo mkdir -p /var/www/static
sudo chown -R vagrant:root /var/django
sudo chown -R vagrant:root /var/www/static
cd /var/django
virtualenv -p python3 ./env
source env/bin/activate
pip3.4 search -v django &> /dev/null
pip3.4 install django
pip3.4 search -v pymysql &> /dev/null
pip3.4 install pymysql
django-admin.py startproject $APP_NAME .
deactivate

echo -e "\n--- Creating DB APP Info ---\n"
cat > db <<EOF
'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': '%DBNAME%',
        'USER': '%DBUSER%',
        'PASSWORD': '%DBPASSWD%',
        'HOST': '%DBHOST%',
        'PORT': '%DBPORT%',
    }
}

EOF
sed -i 's/%DBNAME%/'"${APP_USER_AND_DB}"'/g' db
sed -i 's/%DBUSER%/'"${APP_USER_AND_DB}"'/g' db
sed -i 's/%DBPASSWD%/'"${APP_DB_PWD}"'/g' db
sed -i 's/%DBHOST%/'"${DB_HOST}"'/g' db
sed -i 's/%DBPORT%/'"${DB_PORT}"'/g' db

ed -s ./$APP_NAME/settings.py <<EOF
/DATABASES = {/+,/# Internationalization/-d
/DATABASES = {/ r db
w
q
EOF

rm db

sed -i '/STATIC_ROOT/d' ./$APP_NAME/settings.py
echo "STATIC_ROOT = '/var/www/static'" >> ./$APP_NAME/settings.py

cat > ./$APP_NAME/__init__.py <<EOF
import pymysql
pymysql.install_as_MySQLdb()
EOF

source env/bin/activate
echo "from django.contrib.auth.models import User; User.objects.create_superuser('${APP_ADMIN}', '${APP_ADMIN_MAIL}', '${APP_ADMIN_PWD}')" | python3 manage.py shell
python3 manage.py migrate &> /dev/null
python3 manage.py collectstatic --noinput &> /dev/null
deactivate

echo -e "\n--- Add environment variables to Apache ---\n"
sudo bash -c "cat > /etc/apache2/sites-enabled/000-default.conf" <<EOF
<VirtualHost *:80>
WSGIDaemonProcess %PLACEHOLDER% python-path=/var/django/::/var/django/env/lib/python3.4/site-packages
WSGIProcessGroup %PLACEHOLDER%
WSGIScriptAlias / /var/django/%PLACEHOLDER%/wsgi.py

Alias /html /var/www/html/
Alias /static/ /var/www/static/

    <Directory /var/www/html>
       Options Indexes FollowSymLinks
       AllowOverride All
       Require all granted
    </Directory>
    <Directory /var/django/%PLACEHOLDER%>
       <Files wsgi.py>
           Order deny,allow
           Allow from all
           Require all granted
       </Files>
    </Directory>

    DocumentRoot /var/www
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF
sudo sed -i 's/%PLACEHOLDER%/'"${APP_NAME}"'/g' /etc/apache2/sites-enabled/000-default.conf
 
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
#cat >> /home/vagrant/.bashrc <<EOF

# Set envvars
#export APP_ENV=$APPENV
#export DB_HOST=$DBHOST
#export DB_NAME=$DBNAME
#export DB_USER=$DBUSER
#export DB_PASS=$DBPASSWD
#EOF
