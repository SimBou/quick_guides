# Zabbix Server [\<back>](zabbix.md)
Table of contents
- [Install packages](#install-packages-on-both-nodes-as-root)
- [Configure security](#configure-security-on-both-nodes-as-root)
- [Configure Zabbix](#configure-zabbix-on-both-nodes-as-root)
- [Configure Cluster](#configure-cluster)
## Install packages (on both nodes as root)
1) Install Zabbix repos

RHEL/CentOS
```commandline
dnf install -y https://repo.zabbix.com/zabbix/5.0/rhel/8/x86_64/zabbix-release-5.0-1.el8.noarch.rpm
dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm
```
Debian/Ubuntu
```commandline

```
2) Disable the built-in PostgreSQL module
```commandline
dnf -qy module disable postgresql
```
3) Install Zabbix Server
```commandline
dnf -y install zabbix-server-pgsql zabbix-agent 
```
4) Install optionnal packages
```commandline
dnf -y install zabbix-sender zabbix-get net-snmp-utils 
```
## Configure security (on both nodes as root) 
1) Configure firewall
```commandline
firewall-cmd --add-port={10051/tcp,10050/tcp} --permanent 
firewall-cmd --reload
```
2) Configure SELinux
```commandline
setsebool -P zabbix_can_network on
install_semodule.bsx
```
## Configure Zabbix (on both nodes as root)
1) Initialize Zabbix database
```commandline
zcat /usr/share/doc/zabbix-server-pgsql/create.sql.gz | sudo -u zabbix psql -h 172.16.0.138 zabbix
zcat /usr/share/doc/zabbix-server-pgsql/timescaledb.sql.gz | sudo -u zabbix psql -h 172.16.0.138 zabbix
```
2) Configure Zabbix
```commandline
sed -i -r -e "s/^# (DBHost=)$/\1172.16.0.138/" /etc/zabbix/zabbix_server.conf
sed -i -r -e "s/^# (DBPassword=)$/\1zabbixPassw0rd/" /etc/zabbix/zabbix_server.conf
sed -i -r -e "s/^# (SourceIP=)$/\1172.16.0.136/" /etc/zabbix/zabbix_server.conf
```
3) Disable and stop services
```commandline
systemctl disable zabbix-server
systemctl stop zabbix-server
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
pcs host auth -u hacluster VM-CENTOS8-zabbix-core-1 VM-CENTOS8-zabbix-core-2 VM-CENTOS8-zabbix-core-3
pcs cluster setup ZabbixServerHA VM-CENTOS8-zabbix-core-1 VM-CENTOS8-zabbix-core-2 VM-CENTOS8-zabbix-core-3
pcs cluster start --all 
pcs cluster enable --all 
pcs property set symmetric-cluster=true
pcs property set stonith-enabled=false
crm_verify -L -V
pcs cluster status 
pcs status corosync 
```
6) Create resources
```commandline
pcs resource create zabbixServerVip ocf:heartbeat:IPaddr2 cidr_netmask=24 ip=172.16.0.136 op monitor interval=20s
pcs resource create zabbixService systemd:zabbix-server op monitor interval=10s
```
7) Add resources to a group called zabbixServer 
```commandline
pcs resource group add zabbixServer zabbixServerVip zabbixService
pcs constraint location zabbixServer avoids VM-CENTOS8-zabbix-core-3=INFINITY
```
