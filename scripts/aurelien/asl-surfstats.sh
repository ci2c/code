#!/bin/bash

if [ $# -lt 1 ]
then
	echo ""
		echo "Usage: process_asl.sh  -dir DICOM_FILES"
		echo ""
		echo "  -dir DICOM_FILES                   : Path to DICOMS dir"
		echo ""
		echo "Usage: scripttoto.sh  -dir DICOM_FILES"
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
		echo "Usage: scripttoto.sh  -dir DICOM_FILES"
		echo ""
		echo "  -dir DICOM_FILES                   : Path to DICOMS dir"
		echo ""
		echo "Usage: scripttoto.sh  -dir REC_FILES"
		echo ""
		exit 1
		;;
	-dir)
		Dicom=`expr $index + 1`
		eval Dicom=\${$Dicom}
		echo "DICOM_DIR : ${Dicom}"
		;;
	esac
	index=$[$index+1]
done

dcm2nii -o ${Dicom} ${Dicom}
mkdir -p $Dicom/split
echo
echo
for vol in `ls ${Dicom}/*gz`
do
echo
echo "correction du volume $vol"
echo
echo
index=`echo $vol |sed -n "/[aAsSlL]/s/.*\([0-9]\)\.nii.*/\1/p"`
eddy_correct $vol ${Dicom}/raw_ASL_recal_${index}.nii.gz 0
fslmaths ${Dicom}/raw_ASL_recal_${index}.nii.gz -s 2 ${Dicom}/vol_blur_${index}.nii.gz
fslsplit $Dicom/vol_blur_${index}.nii.gz $Dicom/split/split-${index}- -t
done
fslmerge -t ${Dicom}/vol_merge.nii.gz $Dicom/vol_blur_1.nii.gz $Dicom/vol_blur_2.nii.gz
gunzip ${Dicom}/split/*gz
rm -fr ${Dicom}/raw_ASL_recal*
rm -fr $Dicom/vol_blur_*
matlab -nodisplay <<EOF >> ${Dicom}/surfstats.log
filenames = SurfStatListDir( '${Dicom}/split/' );
[ Y, vol ] = SurfStatReadVol(filenames);
[ mindata, volmin ] = SurfStatAvVol( filenames, @min, 0 );
[ Y, vol ] = SurfStatReadVol( filenames, mindata>=500 );
dyn=[1:30]';
%Cont=[control,marquage]';
Marq=flipdim(Cont,1);
Dyn=[dyn;dyn];
label=var2fac([repmat(1,1,30) repmat(2,1,30)],{'control';'marquage'});
label_type=term(label);
Dynamique=term(Dyn);
M=1+label_type+Dynamique;
slm = SurfStatLinMod( Y, M);
slm = SurfStatT( slm, label_type.control-label_type.marquage );
SurfStatWriteVol( '${Dicom}/Tvol.nii', slm.t, vol );
EOF
echo "c'est fini, taper entrée pour quitter"
read q
