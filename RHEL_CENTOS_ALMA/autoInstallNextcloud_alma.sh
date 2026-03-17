#!/bin/bash
#this script must be run as root (sudo)
#Install the latest version of Nextcloud with Maria DB and Redis on RHEL-sytle systems
#to install Redis, memcached please also run the postInstallNextcloud.sh with configModify.py in the same directory.
#Note that the versions of MariaDB and PHP may need to be upgraded / downgraded in the script depending on the version of Nextcloud being installed.
#NOTE: This version is for RHEL derivatives.
# Updated for Alma Linux 10

sudo dnf -y update
sudo dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm
#sudo dnf install dnf-utils https://rpms.remirepo.net/enterprise/remi-release-9.rpm -y
#sudo dnf module install -y php:remi-8.3
sudo dnf -y update

sudo dnf install -y httpd
sudo dnf install -y memcached
sudo dnf install -y php
sudo dnf install -y php-fpm
sudo dnf install -y php-cli
sudo dnf install -y php-mysqlnd
sudo dnf install -y php-pgsql
sudo dnf install -y php-opcache
sudo dnf install -y php-curl
sudo dnf install -y php-pecl-apcu 
sudo dnf install -y php-bcmath 
sudo dnf install -y php-dom 
sudo dnf install -y php-gd 
sudo dnf install -y php-gmp
sudo dnf install -y php-pecl-memcached
sudo dnf install -y php-pecl-redis
sudo dnf install -y php-ldap
sudo dnf install -y php-smbclient
sudo dnf install -y php-process 
sudo dnf install -y php-sodium
sudo dnf install -y php-zip
sudo dnf install -y php-mbstring
sudo dnf install -y php-pecl-imagick
sudo dnf install -y php-intl
sudo dnf install -y php-bz2
sudo dnf install -y ffmpeg
sudo dnf install -y nfs-utils
sudo dnf install -y samba-client
sudo dnf install -y unzip
sudo dnf install -y wget
sudo dnf install -y valkey
sudo sed -i 's/memory_limit = 128M/memory_limit = 2048M/' /etc/php.ini
sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 2048M/' /etc/php.ini
sudo sed -i 's/post_max_size = 8M/post_max_size = 2048M/' /etc/php.ini
sudo sed -i 's/output_buffering = 4096/output_buffering = off/' /etc/php.ini
sudo sed -i 's/;opcache.interned_strings_buffer=8/opcache.interned_strings_buffer=32/' /etc/php.d/10-opcache.ini
sudo echo "apc.enable_cli=1" | sudo tee -a /etc/php.ini
sudo sed -i 's/;apc.enable_cli/apc.enable_cli=1 ;/' /etc/php.d/40-apcu.ini
sudo sed -i 's/expose_php = on/expose_php = off/' /etc/php.ini


#Adjust SElinux permissions
sudo semanage fcontext -a -t httpd_sys_rw_content_t '/var/www/html(/.*)?'
sudo semanage fcontext -a -t httpd_sys_rw_content_t '/var/www/html/data(/.*)?'
sudo semanage fcontext -a -t httpd_sys_rw_content_t '/var/www/html/config(/.*)?'
sudo semanage fcontext -a -t httpd_sys_rw_content_t '/var/www/html/apps(/.*)?'
sudo semanage fcontext -a -t httpd_sys_rw_content_t '/var/www/html/.htaccess'
sudo semanage fcontext -a -t httpd_sys_rw_content_t '/var/www/html/.user.ini'

sudo restorecon -R '/var/www/html/'

sudo setsebool -P httpd_can_network_connect on
sudo setsebool httpd_use_nfs on

#restart the services to ensure they take effect
sudo systemctl enable httpd
sudo service httpd restart
sudo service php-fpm restart

#allow firewall settings
sudo firewall-cmd --zone=public --add-service=http --permanent
sudo firewall-cmd --zone=public --add-service=https --permanent
sudo firewall-cmd --reload

sudo dnf install -y mariadb-server
sudo systemctl enable mariadb
sudo systemctl start mariadb
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
sudo systemctl stop httpd
sudo cp -t /var/www/html -R nextcloud/* nextcloud/.htaccess nextcloud/.user.ini
sudo mkdir /var/www/html/custom_apps
sudo chown -R apache:apache /var/www/html/
sudo systemctl start httpd

echo "Please navigate in a browser from a device on the same network to the IP address or domain name of the system, normally number 2 in the below output."
ip a
echo "Fill in the admin user information, and connect the database to MySQL type with localhost and the password set for user nextcloud.
Once complete please also run the post install script - postInstallNextcloud - to properly configure Redis and memcache for better performance.
Reminder: Important account info:
- Your DB user is NCadmin
- Your DB password: my5QLnextcloud
- You DB for Nextcloud: ncDB
If there are any issues please refer to the CentOS 8 install in the Nextcloud documentation:
https://docs.nextcloud.com/server/latest/admin_manual/installation/example_centos.html"
