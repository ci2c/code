#!/bin/bash

if [ $# -lt 1 ]
then
	echo ""
	echo "Usage:  sup_eadir.sh  <SD>"
	echo ""
	echo "supprime les répertoires @eaDir dans l'arborescence suivant le dossier SD"
	echo ""
	echo "Author: Tanguy Hamel - CHRU Lille - 2014"
	echo ""
	exit 1
fi

SD=$1
find $SD -name "@eaDir" -type d -exec rm -rf {} \;