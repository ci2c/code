#!/bin/bash

PS3="Choisir (1-6):"
echo "Choisir quel traitement vous voulez lancer..."
select name in "analyse standard" "correction mouvements ASL" "correction et recalage non lineaire" "traitement des rois" "analyse freesurfer puis ASL surface features" "need Help ?"
do
	 break
done
echo "Vous avez choisi $name"
echo
ladate=`date +%T`

case "$name" in
"analyse standard")
echo "======================================="
echo "Donner le chemin complet de vos données"
echo "======================================="
read chemin
file=`basename $chemin`
echo $file
/home/aurelien/SVN/scripts/aurelien/asl_watershed.sh -dir $chemin 2>/tmp/stderr$ladate
;;
"correction mouvements ASL")
echo "======================================="
echo "Donner le chemin complet de vos données"
echo "======================================="
read chemin
file=`basename $chemin`
echo $file
/home/aurelien/SVN/scripts/aurelien/process_asl.sh -dir $chemin 2>/tmp/stderr$ladate
;;
"correction et recalage non lineaire")
echo "======================================="
echo "Donner le chemin complet de vos données"
echo "======================================="
read chemin
file=`basename $chemin`
echo $file
/home/aurelien/SVN/scripts/aurelien/asl_nlrecalsoft.sh -dir $chemin 2>/tmp/stderr$ladate
;;
"traitement des rois")
echo "======================================="
echo "Donner le chemin complet de vos données"
echo "======================================="
read chemin
file=`basename $chemin`
echo $file
/home/aurelien/SVN/scripts/aurelien/process_asl_roi.sh -dir $chemin 2>/tmp/stderr$ladate
;;
"analyse freesurfer avec ASL surface features")
echo
echo "####### Script en développement #######" 
echo
echo "======================================="
echo "Donner le chemin complet de vos données"
echo "======================================="
read chemin
file=`basename $chemin`
echo $file
/home/aurelien/SVN/scripts/aurelien/free_asl.sh -dir $chemin 2>/tmp/stderr$ladate
;;
"need Help ?")
/home/aurelien/SVN/scripts/aurelien/help.sh	
;;
esac
