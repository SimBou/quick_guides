#!/bin/bash

# This script create csv files with all configuration of Zabbix
# Autor : Simon Bouchex-Bellomie

DATATABLES="^acknowledges|^alerts|^auditlog|^event|^history|^trends"

usage() {
  echo "Export Zabbix configuration to CSVs files"
  echo "Usage : $(basename $0) [--help] -h <dbhost> -d <dbname> -u <dbuser> [-p <password>] [-o <output directory>]"
  echo "  -h     : Database host"
  echo "  -d     : Database name"
  echo "  -u     : Database user"
  echo "  -p     : Database password (if not set, interactively prompt)"
  echo "  -o     : Output archive directory (default: current folder"
  exit 0
}

get_params() {
  if ! options=$(getopt -o h:d:u:o:p: -l help -- "$@") ; then
    usage
    exit 1
  fi
  set -- ${options}
  while [ $# -gt 0 ] ; do
    case ${1} in
      --help) usage ;;
      -h) dbhost=$(echo ${2}|tr -d "'") ; shift ;;
      -d) dbname=$(echo ${2}|tr -d "'") ; shift ;;
      -u) dbuser=$(echo ${2}|tr -d "'") ; shift ;;
      -p) dbpassword=$(echo ${2}|tr -d "'") ; shift ;;
      -o) outputDir=$(echo ${2}|tr -d "'") ; shift ;;
      (--) shift ;;
      (-*) printf "$0: error - unrecognized option ${1}\n" ; usage ;;
      (*) break ;;
    esac
    shift
  done
  if [[ -z ${dbhost} || -z ${dbname} || -z ${dbuser} ]] ; then
    printf "$0: error - missing options\n" ; usage
  fi
}

read_secret()
{
    stty -echo
    trap 'stty echo' EXIT
    read "$@"
    stty echo
    trap - EXIT
    echo
}

# Get SQL client binary
SQL=$(which psql)
[ -z ${SQL} ] && SQL=$(which sql)
[ -z ${SQL} ] && echo "Error, no SQL client found" && exit 1

# Get options
get_params $*

if [ -z ${dbpassword} ] ; then
  echo -e "$dbuser password: \c"
  read_secret dbpassword
fi

[ -z ${outputDir} ] && MAINDIR=$(pwd)

sqlQuery="${SQL} -h ${dbhost} -U ${dbuser} ${dbname}"

# target path
DUMPDIR=$(date +%Y%m%d%H%M)
DUMPFILE="$(date +%Y%m%d%H%M).tgz"
BACKUPDIR="${MAINDIR}/${DUMPDIR}"
mkdir -p ${BACKUPDIR}

export PGPASSWORD=${dbpassword}

# Get Tables from DB
dataTables=$(${sqlQuery} -A -c "\d" | grep table | awk -F'|' '{print $2}' | egrep "${DATATABLES}")
configTables=$(${sqlQuery} -A -c "\d" | grep table | awk -F'|' '{print $2}' | egrep -v "${DATATABLES}")

# Export configuration tables
for table in ${configTables} ; do
        dumpfile="${BACKUPDIR}/${table}.csv"
        echo "Backuping table ${table}"
        ${sqlQuery} -c "copy ${table} to stdout delimiter ';' csv header;" > ${dumpfile}
done

# Export data tables schema
for table in ${dataTables} ; do
        dumpfile="${BACKUPDIR}/${table}.csv"
        echo "Backuping schema table ${table}"
        ${sqlQuery} -c "copy (select * from ${table} limit 1) to stdout delimiter ';' csv header;" > ${dumpfile}
done

cd ${MAINDIR}
tar czf ${DUMPFILE} ${DUMPDIR}
[ $? -eq 0 ] && rm -rf ${DUMPDIR}

echo
echo "Backup Completed - ${MAINDIR}/${DUMPFILE}"
