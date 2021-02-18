#!/usr/bin/bash

source variables.bash

[ "$(whoami)" != "root" ] && echo "You must be root" && exit 1

echo "Install PG repos"
dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-${EL_VERSION}-x86_64/pgdg-redhat-repo-latest.noarch.rpm

echo "Install TimescaleDB repo"
cp timescaledb.repo /etc/yum.repos.d/

echo "Disable the built-in PostgreSQL module"
dnf -qy module disable postgresql

echo "Install PostgreSQL"
dnf install -y postgresql${PG_VERSION}-server timescaledb-postgresql-12

echo "Bootstrap standby database"
systemctl stop postgresql-${PG_VERSION}
rm -rf ${PGDATA}/*
sudo -i -u postgres pg_basebackup -h ${PG_MASTER_IP} -D ${PGDATA} -U replicator -P -v  -R -X stream -C -S pgstandby1
systemctl start postgresql-12

echo "Check replication"
sudo -i -u postgres psql -c "\x" -c "SELECT * FROM pg_stat_wal_receiver;"

