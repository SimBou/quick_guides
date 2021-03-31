# SNMP
## Table of Contents
  - [SnmpWalk](#snmpwalk)
  - [SnmpGet](#snmpget)
  - [SnmpTranslate](#snmptranslate)
  - [SnmpTable](#snmptable)
  - [References](#reference)
## snmpwalk
snmpwalk query via SNMPv1
```commandline
snmpwalk -v1 -c [Community string] [IP address of the host] [OID of the system information MIB]</p>
```
snmpwalk query via SNMPv2
```commandline
snmpwalk -v2c -c -c [Community string] [IP address of host] [OID of system information MIB]
```
snmpwalk query via SNMPv3 (authentication, but no encryption)
```commandline
snmpwalk -v3 -l authNoPriv -u [User name] -a MD5 -A [User password] [IP address of host] [OID of system information MIB]
```
snmpwalk query via SNMPv3 (authentication and encryption)
```commandline
snmpwalk -v3 -l authPriv -u [User name] -a MD5 -A [User password] -x DES -X [DES password] [IP address of host] [OID of system information MIB]
```
snmpwalk query via SNMPv3 (no authentication, no encryption)
```commandline
snmpwalk -v3 -l noAuthNoPriv -u [User name] [IP address of the host] [OID of the system information MIB]
```
examples
```commandline
snmpwalk -v 2c -c public -On 192.168.1.30
snmpwalk -v 2c -c public 192.168.1.30
snmpwalk -v 2c -c public 192.168.1.30 1.3.6.1.2.1.2.2.1.10
snmpwalk -v 2c -c public -Ov 192.168.1.30 1.3.6.1.2.1.2.2.1.1
snmpwalk -v 2c -c public -OevQ 192.168.1.30 ipForwarding.0
snmpwalk -v3 -l authPriv -u snmp-poller -a SHA -A "PASSWORD1" -x AES -X "PASSWORD1" 10.10.60.50
```
## snmpget
snmpget query via SNMPv1
```commandline
snmpget -v1 -c [Community string] [IP address of the host] [OID for update check]
```
snmpget query via SNMPv2
```commandline
snmpget -v2c -c [Community string] [IP address of the host] [OID for update check]
```
snmpget query via SNMPv3 (authentication, but no encryption)
```commandline
snmpget -v3 -l authNoPriv -u [user name] -a MD5 -A [MD5 hash of user password] [IP address of host] [OID for update check]
```
snmpget query via SNMPv3 (authentication and encryption)
```commandline
snmpget -v3 -l authPriv -u [user name] -a MD5 -A [user password] -x DES -X [DES password] [IP address of host] [OID for update check]
```
snmpget query via SNMPv3 (no authentication, no encryption)
```commandline
snmpget -v3 -l noAuthNoPriv -u [User name] [IP address of the host] [OID for update check]
```
examples
```commandline
snmpget -v2c -c public 10.0.249.1 .1.3.6.1.2.1.10.7.2.1.3.193
snmpget -v3  -l authPriv -u snmp-poller -a SHA -A "PASSWORD1"  -x AES -X "PASSWORD1" 10.10.60.50 sysName.0
snmpget -v3  -l authPriv -u snmp-poller -a SHA -A "PASSWORD1"  -x AES -X "PASSWORD1" 10.10.60.50 sysName.0 system.sysUpTime.0
```
## snmptranslate
```commandline
snmptranslate -On FORTINET-FORTIGATE-MIB::fgWcWtpProfileRadionStationCapacity.1.
```
## snmptable
```commandline
snmptable -v 2c -c public localhost 1.3.6.1.2.1.6.13
snmptable -v 2c -c public -Ci localhost 1.3.6.1.2.1.6.13
snmptable -v 2c -c public -Cb localhost 1.3.6.1.2.1.6.13
```
## Reference

https://blog.cedrictemple.net/239-faire-des-requetes-snmp-en-ligne-de-commande-sous-linux
