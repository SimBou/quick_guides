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

echo "Initialize the database and enable automatic start"
/usr/pgsql-${PG_VERSION}/bin/postgresql-${PG_VERSION}-setup initdb
systemctl enable postgresql-${PG_VERSION}
systemctl start postgresql-${PG_VERSION}

echo "Configure postgres PATH for everybody"
echo "export PGDATA=/var/lib/pgsql/${PG_VERSION}/data
export PATH=\$PATH:/usr/pgsql-${PG_VERSION}/bin" > /etc/profile.d/postgres.sh

echo "Configure postgresql.conf"
cp ${PGDATA}/postgresql.conf ${PGDATA}/postgresql.conf.bkp
sudo -i -u postgres psql -c "ALTER SYSTEM SET listen_addresses TO '*';"

echo "Create replicator user : ${REPLICATOR_USER}"
echo "Password : ${REPLICATOR_PDW}"
sudo -i -u postgres createuser --replication -P -e  : ${REPLICATOR_USER}

echo "Configure pg_hba"
cp ${PGDATA}/pg_hba.conf ${PGDATA}/pg_hba.conf.bkp
chown postgres: ${PGDATA}/pg_hba.conf.bkp
sed -i -e "s/ident/md5/g" ${PGDATA}/pg_hba.conf
echo "host replication replicator ${PG_STANDBY_IP}/24 md5" >> ${PGDATA}/pg_hba.conf

echo "Restart PostgreSQL"
systemctl restart postgresql-${PG_VERSION}

echo "Create firewall rule"
firewall-cmd --add-service=postgresql --permanent
firewall-cmd --reload
