#!/bin/bash

echo '
*******************************************************************************
* Install Matlab 2011 in /usr/local/matlab11    	                      *
******************************************************************************* 
Use 59327-00840-06743-08309-05690
'
mkdir -p /media/cd
mount -o loop /home/global/matlab11/matl11bu.iso /media/cd/
bash /media/cd/install
