## Automating a Manual Nextcloud Install
This repository contains a few scripts and an Ansible playbook for getting 95% of the way there for a manual Nextcloud installation.
This repo is not an official or affiliated method for installating Nextcloud manually, just a way of automating the process to make the bulk of it get deployed more quickly. 

### Various ways to install
Nextcloud can be installed on a host of different systems - ARM, x86, big servers, tiny PCs, etc. Since it is a LAMP (Linux Apache MySQL PHP) or a LEMP (swap NGINX for Apache), the software can be run on pretty much any Linux distro one wishes. Here I provide scripts for some of the big ones - Debian 12, Ubuntu 22.04, and Alma Linux 9.4 (Alma Linux is more similar to a RHEL / CentOS environment). 

#### Debian and Ubuntu Scripts
Under the Debian and Ubuntu Script section there are 3 files - an install file, a configModify.py file, and a postinstall file. The first package install script that installs everything needed for Nextcloud - the web server, database (Maria DB), and the Nextcloud software. The script will trigger a mysql_secure_installation where the user/admin will need to set a root password and set some security defaults on the Maria DB server. The root users isn't used for the Nextcloud to database connection - the script will create that user and spit out the credentials to the user/admin once it finishes. The user/admin then needs to go into the web page of Nextcloud (http://<server ip address>) to then create an admin user and connect the database server using the offered credentials from the script at localhost. Once connected, choose whether to isntall the recommended apps. After logging in, the user needs to run the postinstall script with the configModify.py file in the same directory. The postinstall.sh will adjust some of the settings in the config.php file to install and attach Redis and setup Memcached. The postinstall and configModify.py will also try to adjust some security issues that Nextcloud scans for with the Apache web server defaults - like getting rid of indexing for example. 

###### What it does not do
The scripts don't handle every issue that Nextcloud scans for, mostly because some of those are user choices, such as attaching an email server for notifications, and the ./well-known etc. Those are issues that can depend on where Nextcloud is isntalled and the web server configuration of the virtual hosts.

VERY IMPORTANT: This is just a local Nextcloud and does NOT have SSL certificates. Those can be set up with Let's Encrypt and Certbot so long as the server has a valid domain name (or sub-domain) that can reach the server host. Certbot will need the Apache config to include a virtual host with the server name = to the domain of the server. Once that is set in the apache.conf file or sites-enabled directory, just running certbot --apache should work to auto-provision the SSL cert.

#### Alma / RHEL / CentOS / Fedora
These scripts do exactly the same as the above Debain and Ubuntu Scripts, and operate the same, just using DNF instead of APT essentially. By default, the Red Hat Linux variant has SELinux enabled, so the script tries to adjust for that, and also adds the additional PHP repository 'remirepo' so that a newer PHP 8.2 can be used - needed for the latest Nextcloud version. The remirepo PHP meta package also doesn't - in my experience - pull down as many other common PHP packages, so some more are added in the script vs the Debian versions.

Please note that the versioning of PHP for all of the distros might differ as the default PHP is continually being bumped up with each new release. Alma 9.4 - based from RHEL/CentOS 9.4 - has some pretty old packages so soemthing to just keep in mind if using a different distro version. Same is true for the Debian and Ubuntu (actually the reason those are different is the default PHP version between Debian 12 and Ubuntu). 

#### Ansible Playbook
The Ansible Playbook is more of an experiment. Ansible can be really useful if there are a lot of different hosts, which is why the install breaks out the web server, database and Redis groups. For this reason as well, I include some notes for getting NFS installed on Debian 12 and then the Ansible script will mount the NFS share as the web server root directory. In production, I could see the Ansible Playbook being using if there are a few web servers, a single database and shared Redis host. For larger deployments - say >1500 users of Nextcloud - it may make more sense to have something like clustered Redis and Database. For organizations with those aspirations, suggest the Nextcloud Enterprise version https://nextcloud.com/enterprise/.

To run the Ansible Playbook, an Ansible host is required, and the various servers (hosts) need to be added in the host under the Ansible main directory (by default /etc/ansible with Fedora). The Ansible host needs the SSH keys set in its known_hosts - the easiest way to set this up is to first SSH into each host once just to get the key pair. Afterwards the play book can be run with the below command:

ansible-playbook NCplaybook.yaml --user=joe --ask-become-pass

Assuming the connection succeeds, the playbook will install all the packages needed per role - database, Redis, web server - and if there is any error it will get returned and stop the play. Assuming the user is created with sudo rights on each host, it should provision everything. 

The Anisble playbook does NOT download the Nextcloud software. That needs to be done manually, as well as adjust the config.php file to connect the Redis server. I think that is reasonable, however, because with the NFS mount it is only a one-time job, and afterwards if the playbook is ever re-run - i.e. to add a new web server or replace a failed system - one wouldn't want to re-download the software. Ansible is pretty neat in that it can be used to run and re-run the updates, and will just check that the changes are in place - if so it leaves the systems alone. This feature makes it ideal for multiple system deployments just to ensure each host is properly configured.

Comments welcome, hope this is helpful.

#### Addtiional reference
Nextcloud documentation is pretty helpful, the scripts are just perhaps slightly more up-to-date in terms of the versioning of some of the packages.

https://docs.nextcloud.com/server/latest/admin_manual/installation/example_ubuntu.html

https://docs.nextcloud.com/server/latest/admin_manual/installation/example_centos.html

