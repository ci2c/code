#!/bin/bash
# 
echo "
*----------------------* 
* Starting LDAP Backup *
*----------------------*

"

THEDATE=`date +%Y-%m-%d_%H-%M`

cd /NAS/dumbo/BACKUP3T/backup_ldap/

slapcat -v -l ldap_backup_$THEDATE.ldif
echo "
Compressing ... "
tar -cvf ldap_backup_$THEDATE.ldif.tar ldap_backup_$THEDATE.ldif
pbzip2 -f ldap_backup_$THEDATE.ldif.tar
rm ldap_backup_$THEDATE.ldif


echo "Removing older ldap backup : keeping 15 days ...
"

find /NAS/dumbo/BACKUP3T/backup_ldap/ldap_backup_* -mtime +15 -exec rm {} \;

echo "Backup finished"

