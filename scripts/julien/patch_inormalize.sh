#!/bin/bash

echo '
*******************************************************************************
* Patching inormalize on Ubuntu 12.10                                         *
******************************************************************************* 
'
sudo cp /home/notorious/NAS/julien/lib/libnetcdf.so.6 /usr/lib/
sudo cp /home/notorious/NAS/julien/lib/libhdf5.so.6.0.3 /usr/lib/
sudo ln -s /usr/lib/libnetcdf.so.6 /usr/lib/libnetcdf.so.4
sudo ln -s /usr/lib/libhdf5.so.6.0.3 /usr/lib/libhdf5.so.6
sudo ln -s /usr/local/matlab11/bin/glnxa64/libhdf5_hl.so.6.0.5 /usr/lib/libhdf5_hl.so.6
echo '
Done
'