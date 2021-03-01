#!/bin/bash

# psql config
DBHOST="VM-CENTOS8-zabbix-postgres"
DBNAME="zabbixServer"
DBUSER="zabbix-server"

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

# configuration tables
CONFTABLES=( actions application_discovery application_prototype application_template \
applications autoreg_host conditions config config_autoreg_tls corr_condition \
corr_condition_group corr_condition_tag corr_condition_tagpair corr_condition_tagvalue \
corr_operation correlation dashboard dashboard_user dashboard_usrgrp dbversion dchecks \
dhosts drules dservices escalations expressions functions globalmacro globalvars \
graph_discovery graph_theme graphs graphs_items group_discovery group_prototype \
host_discovery host_inventory host_tag hostmacro hosts hosts_groups hosts_templates \
housekeeper hstgrp httpstep httpstep_field httpstepitem httptest httptest_field \
httptestitem icon_map icon_mapping ids images interface interface_discovery \
interface_snmp item_application_prototype item_condition item_discovery item_preproc \
item_rtdata items items_applications lld_macro_path lld_override lld_override_condition \
lld_override_opdiscover lld_override_operation lld_override_ophistory \
lld_override_opinventory lld_override_opperiod lld_override_opseverity \
lld_override_opstatus lld_override_optag lld_override_optemplate lld_override_optrends \
maintenance_tag maintenances maintenances_groups maintenances_hosts maintenances_windows \
mappings media media_type media_type_message media_type_param module opcommand \
opcommand_grp opcommand_hst opconditions operations opgroup opinventory opmessage \
opmessage_grp opmessage_usr optemplate problem problem_tag profiles proxy_autoreg_host \
proxy_dhistory proxy_history regexps rights screen_user screen_usrgrp screens \
screens_items scripts service_alarms services services_links services_times sessions \
slides slideshow_user slideshow_usrgrp slideshows sysmap_element_trigger \
sysmap_element_url sysmap_shape sysmap_url sysmap_user sysmap_usrgrp sysmaps \
sysmaps_elements sysmaps_link_triggers sysmaps_links tag_filter task task_acknowledge \
task_check_now task_close_problem task_data task_remote_command task_remote_command_result \
task_result timeperiods trigger_depends trigger_discovery trigger_tag triggers users \
users_groups usrgrp valuemaps widget widget_field )

# tables with large data
DATATABLES=( acknowledges alerts auditlog auditlog_details event_recovery \
event_suppress event_tag events history history_log history_str history_text \
history_uint item_rtdata task_data trends trends_uint )

# CONFTABLES
for table in ${CONFTABLES[*]}; do
        dumpfile="${BACKUPDIR}/${table}.txt"
        tmpfile="${BACKUPDIR}/tmp_file"
        echo "Backuping table ${table}"
        ${SQL} -h ${DBHOST} -U ${DBUSER} ${DBNAME} -A -F"|" -c "select * from ${table}" > ${tmpfile}
        awk '/\r$/ {sub(/\r$/, ""); printf "%s", $0; next} {print}' ${tmpfile} > ${dumpfile}
        rm -f ${tmpfile}
done

# DATATABLES
for table in ${DATATABLES[*]}; do
        dumpfile="${BACKUPDIR}/${table}.txt"
        tmpfile="${BACKUPDIR}/tmp_file"
        echo "Backuping schema table ${table}"
        ${SQL} -h ${DBHOST} -U ${DBUSER} ${DBNAME} -A -F"|" -c "select * from ${table} limit 1" > ${tmpfile}
        awk '/\r$/ {sub(/\r$/, ""); printf "%s", $0; next} {print}' ${tmpfile} > ${dumpfile}
        rm -f ${tmpfile}
done

cd ${MAINDIR}
${TAR} czf ${DUMPFILE} ${DUMPDIR}
[ $? -eq 0 ] && rm -rf ${DUMPDIR}

echo
echo "Backup Completed - ${MAINDIR}/${DUMPFILE}"
