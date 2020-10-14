#! /bin/bash

if [ $# -lt 6 ]
then
	echo ""
	echo "Usage: BIDS_ImportSubjToDB.sh  -i <folder>  -o <folder>  -subj <name>   [-acq <name>]"
	echo ""
	echo "  -i              : dicom directory "
	echo "  -o              : output directory "
	echo "  -subj           : subject's name "
	echo "  Options "
	echo "  -acq            : acquisition order (Default: interleaved) "
	echo ""
	echo "Usage: BIDS_ImportSubjToDB.sh  -i <folder>  -o <folder>  -subj <name>  [-acq <name>]"
	echo ""
	exit 1
fi

user=`whoami`

HOME=/home/${user}
index=1
acorder="interleaved"


while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: BIDS_ImportSubjToDB.sh  -i <folder>  -o <folder>  -subj <name>   [-acq <name>]"
		echo ""
		echo "  -i              : dicom directory "
		echo "  -o              : output directory "
		echo "  -subj           : subject's name "
		echo "  Options "
		echo "  -acq            : acquisition order (Default: interleaved) "
		echo ""
		echo "Usage: BIDS_ImportSubjToDB.sh  -i <folder>  -o <folder>  -subj <name>  [-acq <name>]"
		echo ""
		exit 1
		;;
	-i)
		index=$[$index+1]
		eval DICOMDIR=\${$index}
		echo "DICOMDIR : $DICOMDIR"
		;;
	-o)
		index=$[$index+1]
		eval BIDSDIR=\${$index}
		echo "BIDSDIR : $BIDSDIR"
		;;
	-subj)
		index=$[$index+1]
		eval SUBJ=\${$index}
		echo "SUBJ : $SUBJ"
		;;
	-acq)
		index=$[$index+1]
		eval acorder=\${$index}
		echo "acorder : $acorder"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: BIDS_ImportSubjToDB.sh  -i <folder>  -o <folder>  -subj <name>   [-acq <name>]"
		echo ""
		echo "  -i              : dicom directory "
		echo "  -o              : output directory "
		echo "  -subj           : subject's name "
		echo "  Options "
		echo "  -acq            : acquisition order (Default: interleaved) "
		echo ""
		echo "Usage: BIDS_ImportSubjToDB.sh  -i <folder>  -o <folder>  -subj <name>  [-acq <name>]"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

echo " "
echo "START: BIDS_ImportSubjToDB.sh"
echo " START: `date`"
echo ""


echo ""
echo "################################################################################################"
echo "##                                          CHECK "
echo "################################################################################################"
echo ""

if [ ! -d ${DICOMDIR}/${SUBJ} ]; then
	echo "no dicom folder"
	exit 1
fi
if [ ! -d ${BIDSDIR} ]; then
	echo "no bids folder"
	exit 1
fi

SCRIPTNAME=`ls -1 ${BIDSDIR}/code | grep "heuristic" | grep ".py$"`


echo ""
echo "################################################################################################"
echo "##                                         HEUDICONV "
echo "################################################################################################"
echo ""

echo "docker run --rm -v ${DICOMDIR}/:/data -v ${BIDSDIR}/:/output nipy/heudiconv:latest -d /data/{subject}/*/*.dcm -o /output -f /output/code/${SCRIPTNAME} -s ${SUBJ} -c dcm2niix -b --overwrite"
docker run --rm -v ${DICOMDIR}/:/data -v ${BIDSDIR}/:/output nipy/heudiconv:latest -d /data/{subject}/*/*.dcm -o /output -f /output/code/${SCRIPTNAME} -s ${SUBJ} -c dcm2niix -b --overwrite



echo ""
echo "################################################################################################"
echo "##                                     CHANGE PERMISSION "
echo "################################################################################################"
echo ""

echo "sudo chown renaud:500 ${BIDSDIR}/sub-${SUBJ} -R"
sudo chown renaud:500 ${BIDSDIR}/sub-${SUBJ} -R
echo "chmod 775 ${BIDSDIR}/sub-${SUBJ} -R"
chmod 775 ${BIDSDIR}/sub-${SUBJ} -R



echo ""
echo "################################################################################################"
echo "##                                     CORRECT IMPORT "
echo "################################################################################################"
echo ""

echo "FMRI_CorrectHeudiconvImport.sh -i ${BIDSDIR}/sub-${SUBJ} -d ${DICOMDIR}/${SUBJ} -acq ${acorder}"
FMRI_CorrectHeudiconvImport.sh -i ${BIDSDIR}/sub-${SUBJ} -d ${DICOMDIR}/${SUBJ} -acq ${acorder}



echo ""
echo "################################################################################################"
echo "##                                    CHECK BIDS IMPORTATION "
echo "################################################################################################"
echo ""

echo "docker run -ti --rm -v ${BIDSDIR}/:/data:ro bids/validator /data"
docker run -ti --rm -v ${BIDSDIR}/:/data:ro bids/validator /data


echo " "
echo "END: BIDS_ImportSubjToDB.sh"
echo " END: `date`"
echo ""

