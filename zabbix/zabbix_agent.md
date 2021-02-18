# Zabbix Agent [\<back>](README.md)
Table of contents
- [Install packages](#install-packages-on-both-nodes-as-root)
- [Configure security](#configure-security-on-both-nodes-as-root)
- [Configure Zabbix](#configure-zabbix-on-both-nodes-as-root)
- [Configure Cluster](#configure-cluster)
## Install packages
1) Install Zabbix repos
```commandline
dnf install -y https://repo.zabbix.com/zabbix/5.0/rhel/8/x86_64/zabbix-release-5.0-1.el8.noarch.rpm
```
2) Install Zabbix Agent
```commandline
dnf -y install zabbix-agent 
```
## Configure security
1) Configure firewall
```commandline
firewall-cmd --add-port={10051/tcp,10050/tcp} --permanent 
firewall-cmd --reload
```
2) Configure SELinux
```commandline
setsebool -P zabbix_can_network on
install_semodule_agent.bsx
```
## Configure Zabbix
1) Configure Zabbix
```commandline
ip a (get principal server IP)
sed -i -r -e "s/^# (SourceIP=)$/\1<principal_server_ip>/"
sed -i -r -e "s/^(Server=)$/\1172.16.0.136/"
sed -i -r -e "s/^(ServerActive=)$/\1172.16.0.136/"
sed -i -r -e "s/^(Hostname=)$/\1<agent_server_name>/"
echo "PGDATA=/var/lib/pgsql/12/data
PATH=\$PATH:/usr/pgsql-12/bin" > /etc/sysconfig/zabbix-agent
```
3) Enable and start service
```commandline
systemctl enable zabbix-agent
systemctl start zabbix-agent
```
