#!/bin/bash
#
# curl -kLO https://raw.github.com/kcoombes-oakforduk-com/oakford-public/main/zabbix-proxy-upgrade-v1.0.sh
# chmod +x zabbix-proxy-upgrade-v1.0.sh
# ./zabbix-proxy-upgrade-v1.0.sh
#

# Check if /etc/os-release exists
if [ ! -f /etc/os-release ]; then
    echo "Cannot determine OS. Exiting."
    exit 1
fi

# Source the OS release info
. /etc/os-release

# Check if the OS is Red Hat-based and version 9
if [[ "$ID_LIKE" != *"rhel"* ]]; then
    echo "This script requires a Red Hat-based OS. Exiting."
    exit 1
fi

if [[ "$VERSION_ID" != 9* ]]; then
    echo "This script requires Red Hat version 9.x. Exiting."
    exit 1
fi

echo "Red Hat-based OS version 9 detected. Continuing..."

systemctl stop zabbix-proxy
systemctl stop zabbix-agent

mkdir /opt/zabbix-backup/
cp /etc/zabbix/zabbix_proxy.conf /opt/zabbix-backup/
cp /etc/zabbix/zabbix_agentd.conf /opt/zabbix-backup/

rpm -Uvh https://repo.zabbix.com/zabbix/7.0/rhel/9/x86_64/zabbix-release-latest.el9.noarch.rpm
dnf clean all
yes | dnf install -y zabbix-proxy-sqlite3 zabbix-selinux-policy zabbix-agent

systemctl start zabbix-proxy
systemctl start zabbix-agent
