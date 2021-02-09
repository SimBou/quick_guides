# SNMP
## Table of Contents
  - [Commands examples](#commands_examples)
  - [Get](#reference)
  - [Translate](#reference)
## Commands examples
### snmpwalk
```commandline
snmpwalk -v 2c -c public -On 192.168.1.30
snmpwalk -v 2c -c public 192.168.1.30
snmpwalk -v 2c -c public 192.168.1.30 1.3.6.1.2.1.2.2.1.10
snmpwalk -v 2c -c public -Ov 192.168.1.30 1.3.6.1.2.1.2.2.1.1
snmpwalk -v 2c -c public -OevQ 192.168.1.30 ipForwarding.0
```
### snmpget
```commandline
snmpget -v2c -c public 10.0.249.1 .1.3.6.1.2.1.10.7.2.1.3.193
```
### snmptranslate
```commandline
snmptranslate -On FORTINET-FORTIGATE-MIB::fgWcWtpProfileRadionStationCapacity.1.
```
### snmptable
```commandline
snmptable -v 2c -c public localhost 1.3.6.1.2.1.6.13
snmptable -v 2c -c public -Ci localhost 1.3.6.1.2.1.6.13
snmptable -v 2c -c public -Cb localhost 1.3.6.1.2.1.6.13
```
## Reference

https://blog.cedrictemple.net/239-faire-des-requetes-snmp-en-ligne-de-commande-sous-linux