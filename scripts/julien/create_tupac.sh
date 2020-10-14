#!/bin/bash

echo '
*******************************************************************************
* Mount tupac				                                      *
******************************************************************************* 
'
sudo mkdir -p /NAS/tupac
sudo chgrp ingenieur /NAS/tupac
sudo chmod 775 /NAS/tupac
sudo echo "10.11.204.243:/data /NAS/tupac nfs rw,auto,sync" >> /etc/fstab
sudo mount -a


echo '
Done
'
