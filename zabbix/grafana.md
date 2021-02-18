# Grafana [\<back>](README.md)
Table of contents
- [Install packages](#install-packages-on-both-nodes-as-root)
- [Configure security](#configure-security-on-both-nodes-as-root)
- [Configure Zabbix](#configure-zabbix-on-both-nodes-as-root)
- [Configure Cluster](#configure-cluster)
## Install packages (on both nodes as root)
1) Install Grafana repos
```commandline
tee /etc/yum.repos.d/grafana.repo <<EOF
[grafana]
baseurl = https://packages.grafana.com/oss/rpm
enabled = 1
gpgcheck = 1
gpgkey = https://packages.grafana.com/gpg.key
name = Grafana OSS Repository
sslcacert = /etc/pki/tls/certs/ca-bundle.crt
sslverify = 1
EOF
```
2) Install Grafana
```commandline
dnf -y install grafana
```
3) Configure firewall
```commandline
firewall-cmd --permanent --add-port=3000/tcp
firewall-cmd --reload
```        
4) Install Zabbix pluggin
```commandline
grafana-cli plugins install alexanderzobnin-zabbix-app
sed -i -r -e "s/;(allow_loading_unsigned_plugins =)/\1 alexanderzobnin-zabbix-datasource/" /etc/grafana/grafana.ini
```
5) Create Grafana user and database (on Postgresql Master node as root) 
```commandline
sudo -i -u postgres psql -c "CREATE USER grafana WITH PASSWORD 'grafanaPassw0rd';" 
sudo -i -u postgres psql -c "CREATE DATABASE grafana WITH ENCODING='UTF-8';"
sudo -i -u postgres psql -c "GRANT ALL ON DATABASE grafana TO grafana;"
```
6) Grant grafana user to connect on database (on PostgreSQL Master and Slave)
```commandline
echo "host grafana grafana 172.16.0.132/32 md5" >> /var/lib/pgsql/12/data/pg_hba.conf
echo "host grafana grafana 172.16.0.133/32 md5" >> /var/lib/pgsql/12/data/pg_hba.conf
sudo -i -u postgres pg_ctl reload
```
7) Configure Grafana database (on both nodes)
```commandline
sed -i -r -e "s/(^\[database\]$)/\1\ntype = postgres\nhost = 172.16.0.138:5432\nname = grafana\nuser = grafana\npassword = grafanaPassw0rd/" /etc/grafana/grafana.ini
```
8) Start grafana on one node and try to connect
```commandline
systemctl start grafana-server
```
9) Disable and stop services
```commandline
systemctl disable grafana-server 
systemctl stop grafana-server
```        
## Configure cluster
(If not already done, see Zabbix Front cluster configuration)
1) Create resource
```commandline
pcs resource create zabbixServiceGrafana systemd:grafana-server op monitor interval=10s
```        
2) Add resources to a group called zabbixFrontend 
```commandline
pcs resource group add zabbixFrontend zabbixServiceGrafana 
```        
