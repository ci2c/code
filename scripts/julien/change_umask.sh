echo "
Change UMASK in /etc/lognin.defs ...
"
ssh julien@$1 "sudo sed -i -e 's/UMASK\t\t022/UMASK\t\t002/g' /etc/login.defs"
