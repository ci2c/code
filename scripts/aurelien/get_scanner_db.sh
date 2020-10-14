#!/bin/bash

perl /home/aurelien/SVN/scripts/aurelien/pati_linux/pat_list.pl -s achieva3t |sed s/\&/\ /g
echo
echo "entrer un numéro de patient (chiffre de la deuxième colonne)"
read patient
perl /home/aurelien/SVN/scripts/aurelien/pati_linux/scan_list.pl -s achieva3t -p $patient |sed s/\&/\ /g
echo
echo "entrer un numero de serie (chiffre de la deuxième colonne)"
read series
perl /home/aurelien/SVN/scripts/aurelien/pati_linux/parameter_list.pl -s achieva3t -n $series -f all > header.txt
