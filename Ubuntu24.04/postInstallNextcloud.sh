#!/bin/bash
#This is the post install script to complete the setup of Redis and memcache 
echo "Nextcloud base install, post install script."
sudo systemctl stop apache2
sudo cp /var/www/html/config/config.php /var/www/html/config/config.php.bak
sudo cp /var/www/html/config/config.php ./
sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf.bak
sudo cp /etc/apache2/sites-available/000-default.conf ./
#Run python to update the configs - if split out across different machines, be sure to update the Redis target in the conif.php modification in the python variable.
sudo python3 ./configModify.py
sudo cp newConfig.php /var/www/html/config/config.php
sudo cp ./001-default.conf /etc/apache2/sites-available/000-default.conf

#add Apache mods
sudo a2enmod rewrite
sudo a2enmod headers
sudo a2enmod env
sudo a2enmod dir
sudo a2enmod mime

#Install Redis cache and enable caching
sudo apt install -y redis
sudo systemctl enable memcached
sudo systemctl start memcached
redischk=$(redis-cli ping)
if [[ $redischk == "PONG" ]]; then
	echo "PING PONG Success! Redis Online";
else 
	echo "Redis check failed, could be a timing issue. Please check manually: redis-cli ping";
fi
sudo sed -i 's%session.save_handler = files%session.save_handler = redis%' /etc/php/8.3/apache2/php.ini
sudo sed -i 's%;session.save_path = "/var/lib/php/sessions"%session.save_path = "tcp://localhost:6379"%' /etc/php/8.3/apache2/php.ini

sudo systemctl start apache2
echo "************ Setup complete. Please re-login and enjoy Nextcloud! 
If you have any questions please reach out to your Nextcloud contact(s) or reach us at https://nextcloud.com/contact/"
