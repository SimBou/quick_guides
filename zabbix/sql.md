# Examples

```jql
SELECT g.groupid,g.name FROM hstgrp g WHERE g.groupid=6
SELECT i.itemid,i.hostid,i.value_type FROM items i WHERE i.flags IN (0,4) AND i.hostid=10607 AND ((UPPER(i.name) LIKE '%CPU READY%' ESCAPE '!')) AND i.status=0
SELECT * FROM history_uint h WHERE h.itemid='36963' AND h.clock>1601376636 ORDER BY h.clock DESC LIMIT 3
SELECT i.itemid,i.hostid,i.value_type FROM items i WHERE i.flags IN (0,4) AND i.hostid=10587 AND ((UPPER(i.name) LIKE '%HYPERVISOR NAME%' ESCAPE '!')) AND i.status=0
```
```jql
SELECT $__time(time_column), value1 FROM metric_table WHERE $__timeFilter(time_column)
```
```jql
SELECT
  hu.clock,
  hu.value,
  h.name
FROM history_uint hu
  inner join items i on hu.itemid=i.itemid
  inner join hosts h on i.hostid=h.hostid
  inner join hosts_groups hg on h.hostid=hg.hostid
WHERE
  i.name = 'CPU ready' AND hg.groupid=6 AND hu.clock>1601482993
ORDER BY 1
```
```commandline
psql -h VM-CENTOS8-zabbix-postgres -U zabbix-server zabbixServer
```
Get HOSTS
```jql
SELECT h.hostid,h.name FROM hosts h WHERE h.flags IN (0,4) AND h.status IN (0,1) 
```

Get TEMPLATES
```jql
SELECT h.hostid,h.templateid,h.name FROM hosts h WHERE h.status=3 
```

Get INTERFACES
```jql
select * from interface 
```
```jql
SELECT
  ho.hostid,
  ho.name,
  itf.ip,
  itf.port
FROM hosts ho
  inner join interface itf on itf.hostid=ho.hostid
WHERE ho.flags IN (0,4) AND ho.status IN (0,1) AND ho.snmp_available=1
```
```jql
SELECT
  distinct on (ho.hostid) ho.hostid,
  ho.name,
  itf.ip,
  itf.port,
  hi.value
FROM hosts ho
  inner join interface itf on itf.hostid=ho.hostid
  inner join items it on it.hostid=ho.hostid
  inner join history_str hi on hi.itemid=it.itemid
WHERE ho.flags IN (0,4) AND ho.status IN (0,1) AND ho.snmp_available=1 AND it.key_='system.descr[sysDescr.0]' order by ho.hostid desc
```

Get table space odered by size
```jql
SELECT N.nspname || '.' || C.relname AS "relation",
CASE WHEN reltype = 0
THEN pg_size_pretty(pg_total_relation_size(C.oid)) || ' (index)'
ELSE pg_size_pretty(pg_total_relation_size(C.oid)) || ' (' || pg_size_pretty(pg_relation_size(C.oid)) || ' data)'
END AS "size (data)",
COALESCE(T.tablespace, I.tablespace, '') AS "tablespace"
FROM pg_class C
LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
LEFT JOIN pg_tables T ON (T.tablename = C.relname)
LEFT JOIN pg_indexes I ON (I.indexname = C.relname)
LEFT JOIN pg_tablespace TS ON TS.spcname = T.tablespace
LEFT JOIN pg_tablespace XS ON XS.spcname = I.tablespace
WHERE nspname NOT IN ('pg_catalog','pg_toast','information_schema')
ORDER BY pg_total_relation_size(C.oid) DESC;
```
