# PostgreSQL [\<back>](zabbix.md)
Table of contents
- [Install packages](#install-packages-on-both-nodes-as-root)
- [Configure Master](#configure-master-on-master-node-as-root)
- [Initialize Zabbix prerequisites](#initialize-zabbix-prerequisites-on-master-node-as-root)
- [Connfigure Slave](#configure-salve-on-slave-node-as-root)
- [Check replication](#check-replication-on-master-node-as-root)
- [Perform manual switchover](#perform-manual-switch)
- [Configure the cluster](#configure-cluster)
- [Managing your cluster](#managing-your-cluster)
## Install packages (on both nodes as root)
1) Install PostgreSQL and Timescaledb repos
```commandline
dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm
dnf install -y https://repo.zabbix.com/zabbix/5.0/rhel/8/x86_64/zabbix-release-5.0-1.el8.noarch.rpm
tee /etc/yum.repos.d/timescaledb.repo <<EOF
[Timescale_TimescaleDB]
name=timescale_timescaledb
baseurl=https://packagecloud.io/timescale/timescaledb/el/8/\$basearch
repo_gpgcheck=1
gpgcheck=0
enabled=1
gpgkey=https://packagecloud.io/timescale/timescaledb/gpgkey
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300
EOF
```
2) Disable the built-in PostgreSQL module
```commandline
dnf -qy module disable postgresql
```
3) Install packages and enable automatic startup
```commandline
dnf install -y postgresql12-server timescaledb-postgresql-12 zabbix-agent
systemctl enable zabbix-agent
```
4) Configure postgres PATH for everybody
```commandline
echo "PGDATA=/var/lib/pgsql/12/data
export PATH=\$PATH:/usr/pgsql-12/bin" > /etc/profile.d/postgres.sh
```
5) Create firewall rule
```commandline
firewall-cmd --add-service=postgresql --permanent
firewall-cmd --reload
```
## Configure Master (on master node as root)
1) Initialize the database and enable automatic start
```commandline
/usr/pgsql-12/bin/postgresql-12-setup initdb 
systemctl start postgresql-12
```
2) Configure postgresql.auto.conf
```commandline
sudo -i -u postgres psql -c "ALTER SYSTEM SET listen_addresses TO '*';"
sudo -i -u postgres psql -c "ALTER SYSTEM SET primary_conninfo TO 'application_name=VM-CENTOS8-zabbix-postgresql-1';"
```
3) Create replicator user
```commandline
sudo -i -u postgres createuser --replication -P -e replicator
```
4) Configure pg_hba.conf
```commandline
cp /var/lib/pgsql/12/data/pg_hba.conf /var/lib/pgsql/12/data/pg_hba.conf.bkp
chown postgres: /var/lib/pgsql/12/data/pg_hba.conf.bkp
echo "host replication replicator 172.16.0.135/24 md5" >> /var/lib/pgsql/12/data/pg_hba.conf
echo "host replication replicator 172.16.0.134/24 md5" >> /var/lib/pgsql/12/data/pg_hba.conf
```
5) Restart PostgreSQL
```commandline
systemctl restart postgresql-12
```
## Initialize Zabbix prerequisites (on master node as root)
1) Configure pg_hba.conf
```commandline
sed -i -e "s/ident/md5/g" /var/lib/pgsql/12/data/pg_hba.conf
echo "host zabbix zabbix 172.16.0.130/32 md5" >> /var/lib/pgsql/12/data/pg_hba.conf
echo "host zabbix zabbix 172.16.0.131/32 md5" >> /var/lib/pgsql/12/data/pg_hba.conf
echo "host zabbix zabbix 172.16.0.132/32 md5" >> /var/lib/pgsql/12/data/pg_hba.conf
echo "host zabbix zabbix 172.16.0.133/32 md5" >> /var/lib/pgsql/12/data/pg_hba.conf
```
2) Configure PostgreSQL for Zabbix
```commandline
sudo -i -u postgres psql -c "ALTER SYSTEM SET shared_buffers TO '965640kB';"
sudo -i -u postgres psql -c "ALTER SYSTEM SET effective_cache_size TO '2829MB';"
sudo -i -u postgres psql -c "ALTER SYSTEM SET maintenance_work_mem TO '482820kB';"
sudo -i -u postgres psql -c "ALTER SYSTEM SET work_mem TO '4828kB';"
sudo -i -u postgres psql -c "ALTER SYSTEM SET max_worker_processes TO '13';"
sudo -i -u postgres psql -c "ALTER SYSTEM SET max_parallel_workers_per_gather TO '1';"
sudo -i -u postgres psql -c "ALTER SYSTEM SET max_parallel_workers TO '2';"
sudo -i -u postgres psql -c "ALTER SYSTEM SET wal_buffers TO '16MB';"
sudo -i -u postgres psql -c "ALTER SYSTEM SET min_wal_size TO '512MB';"
sudo -i -u postgres psql -c "ALTER SYSTEM SET max_wal_size TO '1GB';"
sudo -i -u postgres psql -c "ALTER SYSTEM SET default_statistics_target TO '500';"
sudo -i -u postgres psql -c "ALTER SYSTEM SET random_page_cost TO '1.1';"
sudo -i -u postgres psql -c "ALTER SYSTEM SET checkpoint_completion_target TO '0.9';"
sudo -i -u postgres psql -c "ALTER SYSTEM SET max_connections TO '100';"
sudo -i -u postgres psql -c "ALTER SYSTEM SET max_locks_per_transaction TO '64';"
sudo -i -u postgres psql -c "ALTER SYSTEM SET autovacuum_max_workers TO '10';"
sudo -i -u postgres psql -c "ALTER SYSTEM SET autovacuum_naptime TO '10';"
sudo -i -u postgres psql -c "ALTER SYSTEM SET effective_io_concurrency TO '200';"
sudo -i -u postgres psql -c "ALTER SYSTEM SET max_parallel_maintenance_workers TO '1';"
sudo -i -u postgres psql -c "ALTER SYSTEM SET shared_preload_libraries TO 'timescaledb';"
```
3) Restart PostgreSQL
```commandline
systemctl restart postgresql-12
```
4) Create Zabbix user and database (on master node as root)
```commandline
sudo -i -u postgres psql -c "CREATE USER zabbix WITH PASSWORD 'zabbixPassw0rd';" 
sudo -i -u postgres psql -c "CREATE DATABASE zabbix WITH ENCODING='UTF-8';"
sudo -i -u postgres psql -c "GRANT ALL ON DATABASE zabbix TO zabbix;"
sudo -i -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE zabbix TO postgres;"
sudo -i -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'postgresPassw0rd';"
sudo -i -u postgres psql -c "CREATE USER zbx_monitor WITH PASSWORD '<PASSWORD>' INHERIT;"
sudo -i -u postgres psql -c "GRANT pg_monitor TO zbx_monitor;"
sudo -i -u postgres psql zabbix -c "CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;"
sudo -i -u postgres psql -c "ALTER SYSTEM SET timescaledb.max_background_workers TO '8';"
systemctl reload postgresql-12.service
```
## Configure Salve (on slave node as root)
1) Bootstrap standby database
```commandline
rm -rf /var/lib/pgsql/12/data/*
sudo -i -u postgres pg_basebackup -h 172.16.0.134 -D /var/lib/pgsql/12/data -U replicator -P -v -R -X stream -C -S pgstandby
sed -i -r -e "s/^(primary_conninfo = )'(.*)'$/\1'\2 application_name=VM-CENTOS8-zabbix-postgresql-2'/" /var/lib/pgsql/12/data/postgresql.auto.conf
systemctl start postgresql-12
```
2) Check replication
```commandline
sudo -i -u postgres psql -c "\x" -c "SELECT * FROM pg_stat_wal_receiver;"
```
## Check replication (on master node as root)
1) Check replication
```commandline
sudo -i -u postgres psql -c "\x" -c "SELECT * FROM pg_stat_replication;"
```
2) Configure postgresql.auto.conf
```commandline
echo "primary_conninfo = 'user=replicator password=replicatorPassw0rd host=172.16.0.135 port=5432 sslmode=prefer sslcompression=0 gssencmode=prefer krbsrvname=postgres target_session_attrs=any application_name=VM-CENTOS8-zabbix-postgresql-1'" >> /var/lib/pgsql/12/data/postgresql.auto.conf
echo "primary_slot_name = 'pgstandby'" >> /var/lib/pgsql/12/data/postgresql.auto.conf 
systemctl restart postgresql-12.service
```
## Perform manual switch
1) Stop postgres on master
```commandline
sudo -i -u postgres pg_ctl stop -m fast
```
2) Promote postgres on slave
```commandline
sudo -i -u postgres psql -x -c "select pg_last_wal_receive_lsn(), pg_last_wal_replay_lsn(), pg_last_xact_replay_timestamp();"
sudo -i -u postgres pg_ctl promote
```
3) Start postgres on old master as new standby 
```commandline
sudo -i -u postgres touch /var/lib/pgsql/12/data/standby.signal
sudo -i -u postgres pg_ctl start
```
## Configure Cluster
1) Install packages 
```commandline
dnf -y install --enablerepo=HighAvailability pacemaker corosync pcs resource-agents-paf
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
pcs host auth -u hacluster VM-CENTOS8-zabbix-postgresql-1 VM-CENTOS8-zabbix-postgresql-2
pcs cluster setup PostgreSQLServerHA VM-CENTOS8-zabbix-postgresql-1 VM-CENTOS8-zabbix-postgresql-2
pcs cluster disable --all 
pcs cluster start --all 
pcs resource defaults migration-threshold=5
pcs resource defaults resource-stickiness=10
pcs property set stonith-enabled=false
pcs property set no-quorum-policy=ignore
pcs cluster status 
pcs status corosync 
```
6) Create resources
```commandline
pcs resource create pgsqld ocf:heartbeat:pgsqlms  \
bindir=/usr/pgsql-12/bin                          \
pgdata=/var/lib/pgsql/12/data                     \
op start timeout=60s                              \
op stop timeout=60s                               \
op promote timeout=30s                            \
op demote timeout=120s                            \
op monitor interval=15s timeout=10s role="Master" \
op monitor interval=16s timeout=10s role="Slave"  \
op notify timeout=60s                             \
promotable notify=true
pcs resource create pgsql-pri-ip ocf:heartbeat:IPaddr2 ip=172.16.0.138 cidr_netmask=24 op monitor interval=10s
pcs constraint colocation add pgsql-pri-ip with master pgsqld-clone INFINITY
pcs constraint order promote pgsqld-clone then start pgsql-pri-ip symmetrical=false kind=Mandatory
pcs constraint order demote pgsqld-clone then stop pgsql-pri-ip symmetrical=false kind=Mandatory
```
## Managing your cluster
1) Perform Switchover
```commandline
pcs resource move --master pgsqld-clone VM-CENTOS8-zabbix-postgresql-1
pcs resource clear pgsqld-clone
```
2) Recover after Failover of VM-CENTOS8-zabbix-postgresql-1

!!! Do not restart postgres on your old Master !!!

Connect on the failed server
```commandline
sudo -i -u postgres touch $PGDATA/standby.signal
sudo -i -u postgres pg_ctl start
pcs resource clear pgsqld-clone (on the other node)
pcs cluster start
```
Verify on postgres log ($PGDATA/log/)
