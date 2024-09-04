#!/bin/bash
#This is the post install script to complete the setup of Redis and memcache 
echo "Nextcloud base install, post install script."
sudo systemctl stop httpd
sudo cp /var/www/html/config/config.php /var/www/html/config/config.php.bak
sudo cp /var/www/html/config/config.php ./
sudo cp /etc/httpd/conf/httpd.conf ./
#sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf.bak
#sudo cp /etc/apache2/sites-available/000-default.conf ./
#Run python to update the configs - if split out across different machines, be sure to update the Redis target in the conif.php modification in the python variable.
sudo python3 ./configModify-Alma.py
sudo cp newConfig.php /var/www/html/config/config.php
sudo cp -u ./httpd.conf /etc/httpd/conf/httpd.conf


#Install Redis cache and enable caching
sudo dnf install -y redis
sudo systemctl enable redis
sudo systemctl start redis
sudo systemctl enable memcached
sudo systemctl start memcached
redischk=$(redis-cli ping)
if [[ $redischk == "PONG" ]]; then
	echo "PING PONG Success! Redis Online";
else 
	echo "Redis check failed, could be a timing issue. Please check manually: redis-cli ping";
fi
sudo systemctl start httpd
sudo -u apache php /var/www/html/occ db:add-missing-indices
echo "************ Setup complete. Please re-login and enjoy Nextcloud! 
If you have any questions please reach out to your Nextcloud contact(s) or reach us at https://nextcloud.com/contact/"
