#! /bin/bash
# curl -kLO https://raw.github.com/kcoombes-oakforduk-com/oakford-public/main/zabbix-proxy-v1.0.sh

read -p "Enter key: " key
echo $key
read -p "Confirm this is correct. Continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

echo "Downloading and installing Oakford CA Cert"
wget https://oakfordhelp.co.uk/oakford-ca.crt
yes | cp oakford-ca.crt /etc/pki/ca-trust/source/anchors/
update-ca-trust

echo "Downloading and installing Zabbix Proxy, v6.4, rhel9, sqlite3"
rpm -Uvh https://repo.zabbix.com/zabbix/6.4/rhel/9/x86_64/zabbix-release-latest-6.4.el9.noarch.rpm
dnf clean all
yes | dnf install -y zabbix-proxy-sqlite3 zabbix-selinux-policy
setsebool -P httpd_can_connect_zabbix on

echo "Updating conf file"
sed -i -e "s/^\(Server=*\).*/\1185.73.67.34/" -e "s/^\(DBName=*\).*/\1\/tmp\/zabbix_proxy/" /etc/zabbix/zabbix_proxy.conf

if grep "^TLSPSKIdentity" -i /etc/zabbix/zabbix_proxy.conf
then 
   sed -i "s/^\(TLSPSKIdentity=*\).*/\1custom/" /etc/zabbix/zabbix_proxy.conf;
else
   echo "TLSPSKIdentity=custom" >> /etc/zabbix/zabbix_proxy.conf;
fi

if grep "^TLSPSKFile" -i /etc/zabbix/zabbix_proxy.conf
then 
   sed -i "s/^\(TLSPSKFile=*\).*/\1\/etc\/zabbix\/key/" /etc/zabbix/zabbix_proxy.conf;
else
   echo "TLSPSKFile=/etc/zabbix/key" >> /etc/zabbix/zabbix_proxy.conf;
fi

echo "Creating key file"
echo $key > /etc/zabbix/key

echo "enable and start the zabbix-proxy service"
systemctl restart zabbix-proxy
systemctl enable zabbix-proxy

