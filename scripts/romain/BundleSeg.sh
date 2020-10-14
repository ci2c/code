#!/bin/bash

SEG=$1 #raparc.a2009s+aseg.nii
TRACTO=$2 #whole_brain_6_1500000_part000001.tck
QRY_PATH="/home/global/anaconda2/tract_querier/queries/freesurfer_queries.qry"
#QRY_PATH_cc="/NAS/dumbo/protocoles/strokconnect/scripts/cc_parietal.qry"

if [ ${#*} -ne 2 ]
then
	echo ""
	echo "Please provide a brain parcellation (nii.gz first arg) "
	echo "	and a tractography (.tck second arg)"
	echo "	output files are store in the tractography's folder"
	echo "	example of use : "
	echo "	BundleSeg.sh ../FS53/p_AR28_na/mri/wmparc.nii.gz ../FS53/p_AR28_na/dti/whole_brain_6_1500000_part000001.tck"
	echo ""
	exit
fi 

/home/global/anaconda2/bin/python /home/romain/SVN/scripts/romain/tck2trk.py -f $1 $2

TRACTO_TRK=`echo ${TRACTO::-4}.trk`	
NAME=`basename ${TRACTO} ".tck"`
DEST="`dirname ${TRACTO}`/${NAME}" 
/home/global/anaconda2/bin/tract_querier -a ${SEG} -t ${TRACTO_TRK} -q ${QRY_PATH} -o ${DEST}
#/home/global/anaconda2/bin/tract_querier -a ${SEG} -t ${TRACTO_TRK} -q ${QRY_PATH_cc} -o ${DEST}

TRACTO_TO_BE_CONVERT="`dirname $TRACTO`/${NAME}*trk" 
/home/global/anaconda2/bin/python /home/romain/SVN/scripts/romain/trk2tck.py `ls ${TRACTO_TO_BE_CONVERT}`

#rm ${TRACTO_TRK} 
rm ${TRACTO_TO_BE_CONVERT}
