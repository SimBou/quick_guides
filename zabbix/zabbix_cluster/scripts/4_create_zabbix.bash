#!/usr/bin/bash

source variables.bash

[ "$(whoami)" != "root" ] && echo "You must be root" && exit 1

echo "Create Zabbix user and database"
sudo -i -u postgres psql -c "CREATE USER ${ZABBIX_PG_USER} WITH PASSWORD '${ZABBIX_PG_PWD}';" 
sudo -i -u postgres psql -c "CREATE DATABASE ${ZABBIX_DB} WITH ENCODING='UTF-8';"
sudo -i -u postgres psql -c "GRANT ALL ON DATABASE ${ZABBIX_DB} TO ${ZABBIX_PG_USER};"
sudo -i -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE ${ZABBIX_DB} TO postgres;"
sudo -i -u postgres psql -c "ALTER USER postgres WITH PASSWORD '${POSTGRES_PG_PWD}';"

echo "Configure pg_hba"
sed -i -e "s/ident/md5/g" ${PGDATA}/pg_hba.conf
echo "host ${ZABBIX_DB} ${ZABBIX_PG_USER} ${ZABBIX_SERVER1_IP}/32 md5" >> ${PGDATA}/pg_hba.conf
echo "host ${ZABBIX_DB} ${ZABBIX_PG_USER} ${ZABBIX_SERVER2_IP}/32 md5" >> ${PGDATA}/pg_hba.conf
echo "host ${ZABBIX_DB} ${ZABBIX_PG_USER} ${ZABBIX_WEB1_IP}/32 md5" >> ${PGDATA}/pg_hba.conf
echo "host ${ZABBIX_DB} ${ZABBIX_PG_USER} ${ZABBIX_WEB2_IP}/32 md5" >> ${PGDATA}/pg_hba.conf

echo "Configure PG for zabbix"
cat pg_tunning | while read variable value ; do
  sudo -i -u postgres psql -c "ALTER SYSTEM SET ${variable} TO '${value}';"
done

echo "Restart PostgreSQL"
systemctl restart postgresql-${PG_VERSION}

echo "Configure TimescaleDB"
sudo -i -u postgres psql zabbix -c "CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;"


