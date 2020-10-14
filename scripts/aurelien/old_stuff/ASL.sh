#!/bin/bash

PS3="Choisir (1-2):"
echo "Choisir quel traitement vous voulez lancer..."
select name in "Analyse Freesurfer et ASL surface features" "need Help ?"
do
	 break
done
echo "Vous avez choisi $name"
echo
ladate=`date +%T`

case "$name" in
"Analyse Freesurfer et ASL surface features")
echo
echo "####### Script en développement #######" 
echo
echo "==================================================================="
echo "Donner le chemin de l'étude, ex : /home/aurelien/ASL/etude_a_la_con"
echo "==================================================================="
read study
echo $study
echo "=============================================================================================="
echo "Donner le nom du dossier sujet (qui doit se trouver dans le dossier de l'étude), ex : temoin01"
echo "=============================================================================================="
read subject
echo $subject

DIR="${study}/${subject}"
SUBJECTS_DIR=${SD}

if [ ! -d ${DIR}/asl ]
then
	mkdir ${DIR}/asl
fi

if [ ! -d ${DIR}/rawdata ]
then
	mkdir ${DIR}/rawdata
fi

/home/aurelien/SVN/scripts/aurelien/free_asl.sh ${study} ${subject} 2>/tmp/stderr$ladate
;;
"need Help ?")
/home/aurelien/SVN/scripts/aurelien/help_asl.sh	
;;
esac
