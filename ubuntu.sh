#!/bin/sh

#######################################
# Bash script to install all necessary softwares in ubuntu
# Written by Karthikeyans Network Manager DCKAP

## This is for ubuntu 22.04
#sed -i "/#\$nrconf{restart} = 'i';/s/.*/\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf

# Update packages and Upgrade system
sudo apt-get update

## Install Apache
add-apt-repository ppa:ondrej/apache2 -y && apt-get install apache2 -y
# Enabling Mod Rewrite, required for Magento permalinks and .htaccess files
sudo a2enmod rewrite
sudo a2enmod headers
sudo a2enmod ssl
sudo a2ensite default-ssl.conf
sed -i 's/export APACHE_RUN_USER=www-data/export APACHE_RUN_USER=dckap/g' /etc/apache2/envvars
sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf
sudo systemctl restart apache2
sudo chown -R dckap:www-data /var/www/html

## Install Php8.1
apt-get install software-properties-common -y && add-apt-repository ppa:ondrej/php -y && apt-get update
sudo apt-get install -y php8.1 libapache2-mod-php8.1 php8.1 php8.1-common php8.1-gd php8.1-mysql php8.1-mcrypt php8.1-curl php8.1-intl php8.1-xsl php8.1-mbstring php8.1-zip php8.1-bcmath php8.1-iconv php8.1-gd php8.1-soap php8.1-redis

### Change php.ini Configuration
sed -i 's/memory_limit = 128M/memory_limit = 1024M/g' /etc/php/8.1/apache2/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 3000/g' /etc/php/8.1/apache2/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 20M/g' /etc/php/8.1/apache2/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 20M/g' /etc/php/8.1/apache2/php.ini
sed -i 's/;max_input_vars = 1000/max_input_vars = 10000/g' /etc/php/8.1/apache2/php.ini
sudo systemctl restart apache2

## Install Composer2
sudo apt-get install curl -y
cd /tmp && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && chmod +x /usr/local/bin/composer

## Install MariaDB Server and Set Password
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
sudo add-apt-repository "deb [arch=amd64,arm64,ppc64el] http://mariadb.mirror.liquidtelecom.com/repo/10.4/ubuntu $(lsb_release -cs) main" -y
sudo apt-get install mariadb-server -y
sudo systemctl restart mariadb
mysql -u root -e "CREATE USER 'dckap'@'localhost' IDENTIFIED BY 'Dckap2023Ecommerce';";
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'dckap'@'localhost' WITH GRANT OPTION;"
mysql -u root -e "FLUSH PRIVILEGES"

#### Disable Mariadb binary logging
echo "
[mysqld]
skip-log-bin
" >> /etc/mysql/conf.d/disable_binary_log.cnf
sudo systemctl restart mariadb

## Install phpMyAdmin
cd /tmp
apt-get install wget zip unzip -y
wget https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.zip
unzip phpMyAdmin-5.2.1-all-languages && mv phpMyAdmin-5.2.1-all-languages /usr/share/phpmyadmin
echo "
Alias /phpmyadmin /usr/share/phpmyadmin
Alias /phpMyAdmin /usr/share/phpmyadmin

<Directory /usr/share/phpmyadmin/>
   AddDefaultCharset UTF-8
   <IfModule mod_authz_core.c>
      <RequireAny>
      Require all granted
     </RequireAny>
   </IfModule>
</Directory>

<Directory /usr/share/phpmyadmin/setup/>
   <IfModule mod_authz_core.c>
     <RequireAny>
       Require all granted
     </RequireAny>
   </IfModule>
</Directory>
" >> /etc/apache2/sites-available/phpmyadmin.conf
a2ensite phpmyadmin.conf
sudo a2enmod ssl
sudo a2ensite default-ssl.conf
sudo systemctl restart apache2

#####Install NodeJS
curl -sL https://deb.nodesource.com/setup_16.x | sudo bash -
apt-get update
sudo apt-get install gcc g++ make -y
sudo apt -y install nodejs

###Install Google Chrome
cd /tmp
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
sudo apt-get install -f -y
rm -rf google-chrome-stable_current_amd64.deb

####Install Zoom Client in Ubuntu
cd /tmp
wget https://zoom.us/client/5.14.10.3738/zoom_amd64.deb
sudo dpkg -i zoom_amd64.deb
sudo apt-get install -f -y
rm -rf zoom_amd64.deb

###Install Slack Application
cd /tmp
wget https://dckapdocker.s3.amazonaws.com/slack-desktop-4.32.127-amd64.deb
sudo dpkg -i slack-desktop-4.32.127-amd64.deb
sudo apt-get install -f -y

## Install Elasticsearch
sudo apt install openjdk-11-jdk -y
sudo apt-get install apt-transport-https -y
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo sh -c 'echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" > /etc/apt/sources.list.d/elastic-7.x.list'
sudo apt-get update
sudo apt-get install elasticsearch -y
sed -i 's/## -Xms4g/-Xms2g/g' /etc/elasticsearch/jvm.options
sed -i 's/## -Xmx4g/-Xmx2g/g' /etc/elasticsearch/jvm.options
sudo systemctl daemon-reload
sudo systemctl restart elasticsearch
sudo systemctl enable elasticsearch

#####Install Redis-server
sudo add-apt-repository ppa:redislabs/redis -y
apt-get update
sudo apt-get install redis -y
sudo systemctl restart redis-server
sudo systemctl enable redis-server

#####Install Redis-server
sudo add-apt-repository ppa:git-core/ppa -y
sudo apt-get update
sudo apt-get install git -y

#### Install Pruitnal vpn
sudo tee /etc/apt/sources.list.d/pritunl.list << EOF
deb https://repo.pritunl.com/stable/apt focal main
EOF

sudo apt --assume-yes install gnupg
gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 7568D9BB55FF9E5287D586017AE645C0CF8E292A
gpg --armor --export 7568D9BB55FF9E5287D586017AE645C0CF8E292A | sudo tee /etc/apt/trusted.gpg.d/pritunl.asc
sudo apt update
sudo apt install pritunl-client-electron -y

#####INstall Netextender
cd /tmp
wget https://dckapdocker.s3.amazonaws.com/netextender.zip
unzip netextender.zip
cd netextender && chmod +x install && ./install 

####Install Sublime
cd /tmp
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
apt-get update
sudo apt-get install sublime-text -y

