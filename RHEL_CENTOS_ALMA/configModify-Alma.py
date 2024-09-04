#First adjust the config.php settings 
configModifications="""'htaccess.RewriteBase' => '/',
  'memcache.local' => '\\OC\\Memcache\\APCu',
  'apps_paths' =>
  array (
    0 =>
    array (
      'path' => '/var/www/html/apps',
      'url' => '/apps',
      'writable' => false,
    ),
    1 =>
    array (
      'path' => '/var/www/html/custom_apps',
      'url' => '/custom_apps',
      'writable' => true,
    ),
  ),
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

#Update the site settings for .htaccess	
check = 0
	
newOutput2 = ""


try:
	siteFile = open("httpd.conf", "r")
	for l in siteFile:
		if '''<Directory "/var/www/html">''' in l:
			check = 1
			newOutput2 += l
		elif check == 1 and "AllowOverride None" in l:
			newOutput2 += "AllowOverride All"
			check = 0
		else:
			newOutput2 += l
	siteFile.close()
except:
	print("Error opening that file")

print(newOutput2)

newConfig2 = open("httpd.conf", "w")
try:
	newConfig2.write(newOutput2)
	newConfig2.close()
except:
	print("Error writing to that file.")
