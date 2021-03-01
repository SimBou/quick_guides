# Zabbix Frontend (Apache or Nginx) [\<back>](zabbix.md)
Table of contents
- [Install packages](#install-packages-on-both-nodes-as-root)
- [Configure security](#configure-security-on-both-nodes-as-root)
- [Configure Zabbix](#configure-zabbix-on-both-nodes-as-root)
- [Configure Cluster](#configure-cluster)
## Install packages (on both nodes as root)
1) Install Zabbix repos
```commandline
dnf install -y https://repo.zabbix.com/zabbix/5.0/rhel/8/x86_64/zabbix-release-5.0-1.el8.noarch.rpm
```
2.1) Install Zabbix Frontend with Apache
```commandline
dnf -y install zabbix-web-pgsql zabbix-apache-conf zabbix-agent
```
2.2) Install Zabbix Frontend with Nginx
```commandline
dnf -y install zabbix-web-pgsql zabbix-nginx-conf zabbix-agent
```
## Configure security (on both nodes as root) 
1) Configure firewall
```commandline
firewall-cmd --permanent --add-service=http
firewall-cmd --reload
```        
2) Configure SELinux
```commandline
setsebool -P httpd_can_connect_zabbix on
setsebool -P httpd_can_network_connect_db on
```        
## Configure Zabbix (on both nodes as root)
1.1) Configure PHP and Zabbix
```commandline
echo "php_value[date.timezone] = Europe/Paris" >> /etc/php-fpm.d/zabbix.conf
tee /etc/zabbix/web/zabbix.conf.php <<EOF
<?php
// Zabbix GUI configuration file
global $DB;

$DB['TYPE']     = 'POSTGRESQL';
$DB['SERVER']   = '172.16.0.138';
$DB['PORT']     = '5432';
$DB['DATABASE'] = 'zabbix';
$DB['USER']     = 'zabbix';
$DB['PASSWORD'] = 'zabbixPassw0rd';

// Schema name. Used for IBM DB2 and PostgreSQL.
$DB['SCHEMA'] = '';

$ZBX_SERVER      = '172.16.0.136';
$ZBX_SERVER_PORT = '10051';
$ZBX_SERVER_NAME = '172.16.0.136';

$IMAGE_FORMAT_DEFAULT = IMAGE_FORMAT_PNG;
?>
EOF
chown apache: /etc/zabbix/web/zabbix.conf.php
```
1.2) Configure Nginx
```commandline
sed -i -r -e "s/^#.*(listen.*)/        \1/" /etc/nginx/conf.d/zabbix.conf
sed -i -r -e "s/^#.*(server_name).*/        \1     172.16.0.132;/" /etc/nginx/conf.d/zabbix.conf
```
2) Disable and stop services
```commandline
systemctl disable httpd php-fpm 
systemctl stop httpd php-fpm
```        
## Configure Cluster
1) Install packages
```commandline
dnf -y install --enablerepo=HighAvailability pacemaker corosync pcs
```        
2) Enable and start service
```commandline
systemctl enable --now pcsd
```        
3) Configure HA password
```commandline
passwd hacluster
```        
4) Configure firewall
```commandline
firewall-cmd --permanent --add-service=high-availability
firewall-cmd --reload
```        
5) Configure cluster on 1st node
```commandline
pcs host auth -u hacluster VM-CENTOS8-zabbix-web-1 VM-CENTOS8-zabbix-web-2
pcs cluster setup ZabbixWebHA VM-CENTOS8-zabbix-web-1 VM-CENTOS8-zabbix-web-2
pcs property set stonith-enabled=false
pcs property set no-quorum-policy=ignore
pcs cluster start --all 
pcs cluster enable --all 
pcs cluster status 
pcs status corosync 
```        
6) Create resources
```commandline
pcs resource create zabbixWebVip ocf:heartbeat:IPaddr2 cidr_netmask=24 ip=172.16.0.137 op monitor interval=20s
pcs resource create zabbixServiceHttp systemd:httpd op monitor interval=10s
pcs resource create zabbixServicePhpFpm systemd:php-fpm op monitor interval=10s
pcs resource create zabbixWebUI ocf:heartbeat:apache configfile=/etc/httpd/conf/httpd.conf statusurl="http://localhost:8080/server−status" op monitor interval=30s
```        
7) Add resources to a group called zabbixFrontend 
```commandline
pcs resource group add zabbixFrontend zabbixWebVip zabbixServiceHttp zabbixWebUI zabbixServicePhpFpm 
```        
