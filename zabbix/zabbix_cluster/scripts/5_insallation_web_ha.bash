#!/usr/bin/bash

source variables.bash

[ "$(whoami)" != "root" ] && echo "You must be root" && exit 1

echo "Install PG repos"
dnf -y install --enablerepo=HighAvailability pacemaker corosync pcs

echo "Enable and start services"
systemctl enable pacemaker corosync pcsd
systemctl start pcsd

echo "Configure HA password"
passwd hacluster

echo "Configure firewall"
firewall-cmd --permanent --add-service=high-availability
firewall-cmd --reload

echo "Configure cluster on 1 node"
pcs host auth -u hacluster VM-CENTOS8-zabbix-web-1 VM-CENTOS8-zabbix-web-2
pcs cluster setup ZabbixWebHA VM-CENTOS8-zabbix-web-1 VM-CENTOS8-zabbix-web-2
pcs cluster start --all 
pcs cluster enable --all 
pcs cluster status 
pcs property set stonith-enabled=false
pcs property set no-quorum-policy=ignore
pcs status corosync 

pcs resource create zabbixWebVip ocf:heartbeat:IPaddr2 cidr_netmask=24 ip=172.16.0.137 op monitor interval=20s --group ha_group
pcs resource create zabbixServiceHttp systemd:httpd op monitor interval=10s --group ha_group 
pcs resource create zabbixWebUI ocf:heartbeat:apache configfile=/etc/httpd/conf/httpd.conf statusurl="http://localhost:8080/server−status" op monitor interval=30s --group ha_group

echo "Install Zabbix Frontend"
dnf install -y https://repo.zabbix.com/zabbix/5.0/rhel/${EL_VERSION}/x86_64/zabbix-release-5.0-1.el8.noarch.rpm
dnf -y install zabbix-web-pgsql zabbix-apache-conf 
firewall-cmd --permanent --add-service=http
firewall-cmd --reload
setsebool -P httpd_can_connect_zabbix on
setsebool -P httpd_can_network_connect_db on

echo "php_value[date.timezone] = Europe/Paris" >> /etc/php-fpm.d/zabbix.conf
cat zabbix.conf.php | sed -e "s/POSTGRES_VIP/${POSTGRES_VIP}/" -e "s/ZABBIX_DB/${ZABBIX_DB}/" -e "s/ZABBIX_PG_USER/${ZABBIX_PG_USER}/" -e "s/ZABBIX_PG_PWD/${ZABBIX_PG_PWD}/" -e "s/ZABBIX_VIP/${ZABBIX_VIP}/" > /etc/zabbix/web/zabbix.conf.php
chown apache: /etc/zabbix/web/zabbix.conf.php

systemctl restart httpd php-fpm
systemctl enable httpd php-fpm
