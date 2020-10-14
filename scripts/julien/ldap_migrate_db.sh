#!/bin/bash

echo '
*******************************************************************************
* LDAP Migare Data Base                                                       *
******************************************************************************* 
Configure Users -> ou=people,dc=imv3t,dc=lan'
sudo sed -i -e "s/#nss_base_passwd/nss_base_passwd/g" /etc/ldap.conf
sudo sed -i -e "s/ou=People,dc=padl,dc=com/ou=people,dc=imv3t,dc=lan/g" /etc/ldap.conf
sudo sed -i -e "s/#nss_base_shadow/nss_base_shadow/g" /etc/ldap.conf
sudo sed -i -e "s/#nss_base_group/nss_base_group/g" /etc/ldap.conf
sudo sed -i -e "s/ou=Group,dc=padl,dc=com/ou=groups,dc=imv3t,dc=lan/g" /etc/ldap.conf
echo 'Configure Groups -> ou=groups,dc=imv3t,dc=lan
Done
'
