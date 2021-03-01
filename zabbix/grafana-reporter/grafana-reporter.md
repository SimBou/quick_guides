# GRAFANA REPORTER
## Table of Contents
  - [Zabbix 5.0 HA with PostgreSQL 12 Streaming replication](zabbix/zabbix_cluster/zabbix.md)
  - [SQL](zabbix/sql.md)
## Installation
### Prerequisites Centos
```commandline
dnf install golang
dnf install libX11-xcb
dnf install libXcomposite
dnf install libXdamage
dnf install libXtst
dnf install libXss
dnf install libXScrnSaver
dnf install libasound
dnf install alsa-lib
dnf install atk
dnf install at-spi2-atk
```
### Prerequisites Ubuntu
```commandline
apt install golang
apt install texlive-latex-base
apt install libnss3
apt install libxss1
apt install libatk1.0-0
apt install libatk-bridge2.0-0
apt install libpangocairo-1.0-0
apt install libgtk-3-0
```
### Plugin Grafana Image Renderer
```commandline
grafana-cli plugins install grafana-image-renderer
```
### Grafana reporter
```commandline
go get github.com/IzakMarais/reporter/...
go install -v github.com/IzakMarais/reporter/cmd/grafana-reporter
```
## Startup API service configuration
Copy startup script, configuration file and systemd unit file into /var/lib/grafana/grafana-reporter
```commandline
grafana-reporter.conf
rafana-reporter.service
launch-grafana-reporter
```


## References
https://grafana.com/grafana/plugins/grafana-image-renderer/installation
https://github.com/IzakMarais/reporter