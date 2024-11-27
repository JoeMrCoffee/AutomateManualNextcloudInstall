#!/bin/bash
#this script must be run as root (sudo)
#Install the latest version of Nextcloud with Maria DB and Redis on Debian / Ubuntu systems
#to install Redis, memcached please also run the postInstallNextcloud.sh with configModify.py in the same directory.
#This script and the accompanying postInstallNextcloud.sh were tested with Debian 12 Buster
#Note that the versions of MariaDB and PHP may need to be upgraded / downgraded in the script depending on the version of Nextcloud being installed.
#NOTE: if using Ubuntu LTS please exit the script and change the PHP version to 8.1 on line 6 and the sed calls as the php.ini path could change.
echo "This script will help install the necessary packages and files for a minimal Nextcloud install on Debian 12 systems. Includes Apache, Redis, MariaDB, and the latest Nextcloud version. NOTE: if using Ubuntu LTS please exit the script and change the PHP version to 8.1 on line 6 of the script."
sudo apt update
sudo apt install -y apache2
sudo apt install -y memcached
sudo apt install -y php8.2 
sudo apt install -y libapache2-mod-php php-mysql php-curl 
sudo apt install -y php-apcu php-bcmath php-dom php-gd php-gmp 
sudo apt install -y php-memcached 
sudo apt install -y php-redis
sudo apt install -y php-ldap
sudo apt install -y php-zip php-mbstring
sudo apt install -y php-imagick php-intl php-bz2
sudo apt install -y libmagickcore-6.q16-6-extra
sudo apt install -y ffmpeg
sudo apt install -y nfs-common
sudo apt install -y unzip
sudo sed -i 's/memory_limit = 128M/memory_limit = 512M/' /etc/php/8.2/apache2/php.ini
sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 512M/' /etc/php/8.2/apache2/php.ini
sudo sed -i 's/post_max_size = 8M/post_max_size = 512M/' /etc/php/8.2/apache2/php.ini
sudo sed -i 's/output_buffering = 4096/output_buffering = off/' /etc/php/8.2/apache2/php.ini
sudo sed -i 's/;opcache.interned_strings_buffer=8/opcache.interned_strings_buffer=32/' /etc/php/8.2/apache2/php.ini
sudo sed -i 's/expose_php = on/expose_php = off/' /etc/php/8.2/apache2/php.ini
echo "apc.enable_cli = 1" | sudo tee --append /etc/php/8.2/apache2/php.ini
echo "apc.enable_cli = 1" | sudo tee --append /etc/php/8.2/mods-available/apcu.ini


sudo apt install -y mariadb-server
sudo mysql_secure_installation
sudo systemctl restart mariadb
echo "Create a user for nextcloud; the user is NCadmin, default password is my5QLnextcloud, and database is ncDB."
sudo mariadb -e "CREATE USER 'NCadmin'@'localhost' IDENTIFIED BY 'my5QLnextcloud';"
sudo mariadb -e "CREATE DATABASE IF NOT EXISTS ncDB CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
sudo mariadb -e "GRANT ALL PRIVILEGES ON ncDB.* TO 'NCadmin'@'localhost';"
sudo mariadb -e "FLUSH PRIVILEGES;"
echo "DB criteria entered."

sudo systemctl restart mariadb

wget https://download.nextcloud.com/server/releases/latest.zip
unzip latest.zip
sudo systemctl stop apache2
sudo mv /var/www/html/index.html /var/www/html/debian.html
sudo cp -t /var/www/html -R nextcloud/* nextcloud/.htaccess nextcloud/.user.ini
sudo mkdir /var/www/html/custom_apps
sudo chown -R www-data:www-data /var/www/html/
sudo systemctl start apache2

echo "Please navigate in a browser from a device on the same network to the IP address or domain name of the system, normally number 2 in the below output."
ip a
echo "Fill in the admin user information, and connect the database to MySQL type with localhost and the password set for user nextcloud.
Once complete please also run the post install script - postInstallNextcloud - to properly configure Redis and memcache for better performance.
Reminder: Important account info:
- Your DB user is NCadmin
- Your DB password: my5QLnextcloud
- You DB for Nextcloud: ncDB"
