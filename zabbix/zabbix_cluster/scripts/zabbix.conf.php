<?php
// Zabbix GUI configuration file
global $DB;

$DB['TYPE']     = 'POSTGRESQL';
$DB['SERVER']   = 'POSTGRES_VIP';
$DB['PORT']     = '5432';
$DB['DATABASE'] = 'ZABBIX_DB';
$DB['USER']     = 'ZABBIX_PG_USER';
$DB['PASSWORD'] = 'ZABBIX_PG_PWD';

// Schema name. Used for IBM DB2 and PostgreSQL.
$DB['SCHEMA'] = '';

$ZBX_SERVER      = 'ZABBIX_VIP';
$ZBX_SERVER_PORT = '10051';
$ZBX_SERVER_NAME = 'ZABBIX_VIP';

$IMAGE_FORMAT_DEFAULT = IMAGE_FORMAT_PNG;

?>
