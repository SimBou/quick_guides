#!/bin/bash

# psql config
DBHOST="VM-CENTOS8-zabbix-postgres"
DBNAME="zabbixServer"
DBUSER="zabbix-server"
PASSWORD=""

# you need to set ~/.pgpass
# hostname:port:database:username:password

# some tools
SQLDUMP="`which pg_dump`"
SQL="`which psql`"
TAR="`which tar`"
DATEBIN="`which date`"
MKDIRBIN="`which mkdir`"

# target path
MAINDIR="/home/sbouchex/backupconf"
DUMPDIR="`${DATEBIN} +%Y%m%d%H%M`"
BACKUPDIR="${MAINDIR}/${DUMPDIR}"
DUMPFILE="`${DATEBIN} +%Y%m%d%H%M`.tgz"
${MKDIRBIN} -p ${BACKUPDIR}

DATATABLES="^acknowledges|^alerts|^auditlog|^event|^history|^trends"

PSQL="${SQL} -h ${DBHOST} -U ${DBUSER} ${DBNAME}"

export PGPASSWORD=${PASSWORD}
dataTables=$(${PSQL} -A -c "\d" | grep table | awk -F'|' '{print $2}' | egrep "${DATATABLES}")
configTables=$(${PSQL} -A -c "\d" | grep table | awk -F'|' '{print $2}' | egrep -v "${DATATABLES}")


# Configuration Tables
for table in ${configTables} ; do
        dumpfile="${BACKUPDIR}/${table}.csv"
        echo "Backuping table ${table}"
        #${SQL} -h ${DBHOST} -U ${DBUSER} ${DBNAME} -A -F"|" -c "select * from ${table}" > ${tmpfile}
        #awk '/\r$/ {sub(/\r$/, ""); printf "%s", $0; next} {print}' ${tmpfile} > ${dumpfile}
        ${PSQL} -c "copy ${table} to stdout delimiter ';' csv header;" > ${dumpfile}
done

# Data Tables
for table in ${dataTables} ; do
        dumpfile="${BACKUPDIR}/${table}.csv"
        echo "Backuping schema table ${table}"
        #${SQL} -h ${DBHOST} -U ${DBUSER} ${DBNAME} -A -F";" -c "select * from ${table} limit 1" > ${tmpfile}
        #awk '/\r$/ {sub(/\r$/, ""); printf "%s", $0; next} {print}' ${tmpfile} > ${dumpfile}
        ${PSQL} -c "copy (select * from ${table} limit 1) to stdout delimiter ';' csv header;" > ${dumpfile}
done

cd ${MAINDIR}
${TAR} czf ${DUMPFILE} ${DUMPDIR}
[ $? -eq 0 ] && rm -rf ${DUMPDIR}

echo
echo "Backup Completed - ${MAINDIR}/${DUMPFILE}"
