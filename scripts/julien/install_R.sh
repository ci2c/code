#!/bin/bash

echo '
*****************************
* Install R on ubuntu 14.04 *
***************************** 
'

if [ $EUID -ne 0 ]
then
 	echo "You need to be a sudo user
"
  exit 1
else


echo "CRAN repository ..."
check_repository1=$(cat /etc/apt/sources.list | grep "deb http://cran.univ-lyon1.fr/bin/linux/ubuntu trusty/" | wc -l)
check_repository2=$(cat /etc/apt/sources.list | grep "deb-src http://cran.univ-lyon1.fr/bin/linux/ubuntu trusty/" | wc -l)

if [ ${check_repository1} -eq 1 ]
then
	echo "	- First repository already exist"
else

	echo "# R software" >> /etc/apt/sources.list	
	echo "deb http://cran.univ-lyon1.fr/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list
	echo "	- First repository added"

fi

if [ ${check_repository2} -eq 1 ]
then
	echo "	- Second repository already exist"
else

	echo "# R software" >> /etc/apt/sources.list	
	echo "deb-src http://cran.univ-lyon1.fr/bin/linux/ubuntu trusty/" >> /etc/apt/sources.list
	echo "	- Second repository added"

fi

echo "CRAN public key ... "
key_installed=$(sudo apt-key list | grep "pub   2048R/E084DAB9 2010-10-19 \[expires: 2020-10-16\]" | wc -l)
if [ ${key_installed} -eq 1 ]
then
	echo "	- public key already installed"
else
	
	sudo apt-key add /home/global/R/r_key.txt

fi

echo "Updating repository list"

sudo apt-get update

echo "
Updating R"

	sudo apt-get install -y --only-upgrade r-base* r-cran* r-doc*








fi

