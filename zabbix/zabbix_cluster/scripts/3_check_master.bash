#!/usr/bin/bash

source variables.bash

[ "$(whoami)" != "root" ] && echo "You must be root" && exit 1

echo "Check replication"
sudo -i -u postgres psql -c "\x" -c "SELECT * FROM pg_stat_replication;"

echo "Enable synchronous repication"
sudo -i -u postgres psql -c "ALTER SYSTEM SET synchronous_standby_names TO  '*';"
systemctl reload postgresql-12.service

echo "Check synchronous replication"
sudo -i -u postgres psql -c "\x" -c "SELECT * FROM pg_stat_replication;"
