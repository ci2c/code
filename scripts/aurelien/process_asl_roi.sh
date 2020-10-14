#!/bin/bash

if [ $# -lt 1 ]
then
	echo ""
		echo "Usage: process_asl.sh  -dir DATA_DIR"
		echo ""
		echo "  -dir DATA_DIR                   : Path to Data dir"
		echo ""
		echo "Usage: scripttoto.sh  -dir DATA_DIR"
		echo ""
		exit 1
fi


index=1

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: scripttoto.sh  -dir DATA_DIR"
		echo ""
		echo "  -dir DATA_DIR                   : Path to dir"
		echo ""
		echo "Usage: scripttoto.sh  -dir DATA_DIR"
		echo ""
		exit 1
		;;
	-dir)
		Dicom=`expr $index + 1`
		eval Dicom=\${$Dicom}
		echo "DATA_DIR : ${Dicom}"
		;;
	esac
	index=$[$index+1]
done

echo
echo "==================================="
echo "on va extraire des ROIs au pif"
echo "==================================="
indice=1

echo "resultats de l'analyse pour ${Dicom}"> ${Dicom}/results.txt
echo "Date de l'analyse : `date +%F`" >> ${Dicom}/results.txt
echo >> ${Dicom}/results.txt
while [ ${indice} -le 98 ]
do
echo "roi ${indice}"
mincsample -mask_val ${indice} -mask /home/aurelien/ASL/Etude_TI/aal.mnc /home/aurelien/ASL/Etude_TI/aal.mnc -sample ${Dicom}/mask.mnc -clobber
cat /home/aurelien/ASL/Etude_TI/freesurfer/FreeSurferColorLUT.txt |sed -n /^${indice}\ /p >> ${Dicom}/results.txt
#echo "resultat de la roi ${indice}" >> ${Dicom}/results.txt
mincstats -mean -stddev ${Dicom}/asl_to_t1.mnc -mask ${Dicom}/mask.mnc -mask_binvalue 1 >> ${Dicom}/results.txt
echo >> ${Dicom}/results.txt
indice=$[$indice+1]
done
cat /home/aurelien/SVN/scripts/aurelien/troll_face
echo "Fuck yeah, c'est termine !!! Allez champion, va vite voir les resultats dans ${Dicom}"

read q
