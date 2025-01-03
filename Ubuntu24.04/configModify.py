#First adjust the config.php settings 
configModifications="""'htaccess.RewriteBase' => '/',
  'memcache.local' => '\\OC\\Memcache\\APCu',
  'maintenance_window_start' => 1,
  'memcache.distributed' => '\\OC\\Memcache\\Redis',
  'memcache.locking' => '\\OC\\Memcache\\Redis',
  'redis' =>
  array (
    'host' => '127.0.0.1',
    'port' => 6379,
  ),"""

newOutput = ""

print(configModifications)

try:
	configFile = open("config.php", "r")
	for line in configFile:
		if "'instanceid'" in line:
			newOutput = newOutput+configModifications+line
		else:
			newOutput += line
	configFile.close()
except:
	print("Error opening that file")

print(newOutput)

newConfig = open("newConfig.php", "w")
try:
	newConfig.write(newOutput)
	newConfig.close()
except:
	print("Error writing to that file.")
	
#then adjust the sites file
sitemodify = """
	<Directory /var/www/html>
		Require all granted
		AllowOverride All
		Options FollowSymLinks MultiViews
		<IfModule mod_headers.c>
			Header always set Strict-Transport-Security "max-age=15552000; includeSubDomains"
		</IfModule>  
		<IfModule mod_dav.c>
			Dav off
		</IfModule>
	</Directory>
     """

newOutput2 = ""

print(sitemodify)

try:
	siteFile = open("000-default.conf", "r")
	for l in siteFile:
		if "DocumentRoot /var/www/html" in l:
			newOutput2 = newOutput2+l+sitemodify
		else:
			newOutput2 += l
	siteFile.close()
except:
	print("Error opening that file")

print(newOutput2)

newConfig2 = open("001-default.conf", "w")
try:
	newConfig2.write(newOutput2)
	newConfig2.close()
except:
	print("Error writing to that file.")
