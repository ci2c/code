#!/bin/bash

if [ $# -lt 1 ]
then
	echo ""
		echo "Usage: process_DTI_multi_B.sh  -dir DICOM_FILES"
		echo ""
		echo "  -dir DICOM_FILES                   : Path to DICOMS dir"
		echo ""
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
		echo "Usage: scripttoto.sh  -dir DICOM_FILES"
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

i=0
for DTI in `ls ${Dicom}/*DTI*.nii.gz`
do
dti=`basename ${DTI}`
filename=`echo ${dti} | sed s/.nii.gz//`
bvec=${filename}.bvec
bval=${filename}.bval

#echo "Interpolate volume"
#/usr/local/matlab/bin/matlab -nodisplay <<EOF
#Im = load_nifti('${Dicom}/${dti}');
#Imre = imresize(Im.vol, [256 256], 'nearest');
#Im.vol = Imre;
#save_nifti(Im, '${Dicom}/${filename}_interp.nii');
#EOF

#gzip -f ${Dicom}/${filename}_interp.nii
   
echo
   echo "eddy current correction"
   echo
   echo "correction de ${filename}.nii.gz"
   echo
   eddy_correct ${Dicom}/${filename}.nii.gz ${Dicom}/dti_${i}_correct.nii.gz 0
   i=`echo "${i}+1 " | bc -l`
done

for n in `ls ${Dicom}/dti*_correct.nii.gz`
do
fslroi ${n} ${n}_b0.nii.gz 0 128 0 128 0 60 0 1
Nvols=`fslnvols ${n}`
fslroi ${n} ${n}_dir.nii.gz 0 128 0 128 0 60 1 `echo "$Nvols - 1" | bc -l`
echo ...
done


fslmerge -t ${Dicom}/DTI_merge.nii.gz ${Dicom}/*b0.nii.gz ${Dicom}/*dir.nii.gz
#eddy_correct ${Dicom}/DTI_merge.nii.gz ${Dicom}/DTI_merge_corrected.nii.gz 0

for files in `ls ${Dicom}/*.bvec`
do
cols=`head -1 < ${files} | wc -w`
count=1
while [ $count -le $cols ]; do
        if [ $count = 1 ]; then
                tr -s ' ' ' ' <${files} | cut -f$count -d' ' | tr '\012' ' ' >${files}_transpose.txt
        else
                tr -s ' ' ' ' <${files} | cut -f$count -d' ' | tr '\012' ' ' >>${files}_transpose.txt
        fi
        echo "" >>${files}_transpose.txt
        count=`expr $count + 1`
done
done

echo > ${Dicom}/bvec.txt
for bfile in `ls ${Dicom}/*transpose.txt`
do
sed -i 1d ${bfile}
cat ${bfile} >> ${Dicom}/bvec.txt
done

COUNTER=1
while [ $COUNTER -le `ls -1 ${Dicom}/*.bvec | wc -l` ]; do
sed -i '1a\0 0 0' ${Dicom}/bvec.txt
let COUNTER=COUNTER+1
done
sed -i 1d ${Dicom}/bvec.txt
echo

dti_recon "${Dicom}/DTI_merge.nii.gz" "${Dicom}" -gm "${Dicom}/bvec.txt" -b 1000 -b0 auto -sn 1 -ot nii


