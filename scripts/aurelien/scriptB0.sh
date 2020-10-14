#!/bin/bash

if [ $# -lt 1 ]
then
	echo ""
		echo "Usage: scripttoto.sh  -dir DICOM_FILES"
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

#for IM in `ls ${Dicom}/IM*`
#do
#  Is_BO=`dcmdump ${IM} | grep "B0 map"`
#  if [ -n "${Is_BO}" ]
#  then
#    dcmdump ${IM} | grep 2005,100e > ${Dicom}/Stuff.txt
#   Nb_line=`cat ${Dicom}/Stuff.txt | wc -l`
#    Stuff=`sed -n "${Nb_line}{p;q}" ${Dicom}/Stuff.txt`
#    Factor=`echo ${Stuff} | awk  '{print $3}'`
#    echo Factor=${Factor}
#    rm -f ${Dicom}/Stuff.txt
#  fi
#done


#echo "dcm2nii ${Dicom}/IM*"
#dcm2nii ${Dicom}/IM*

#rm -f ${Dicom}/*.bvec
#rm -f ${Dicom}/*.bval

Image=`ls ${Dicom}/*B0map*2.nii.gz`
Image=`basename ${Image}`
Magn=`ls ${Dicom}/*B0map*1.nii.gz`
Magn=`basename ${Magn}`
Image_ref=`ls ${Dicom}/*DTI*.nii.gz`
Image_ref=`echo ${Image_ref} | awk  '{print $1}'`
Image_ref=`basename ${Image_ref}`

# echo "fslmaths ${Dicom}/${Image} -div 10.0737 ${Dicom}/${Image%.nii.gz}_carto.nii.gz"
# fslmaths ${Dicom}/${Image} -div 10.0737 ${Dicom}/${Image%.nii.gz}_carto.nii.gz
# echo "fslcreatehd 256 256 60 1 1 1 2 1 0 0 0 4  ${Dicom}/Temp_carto.nii.gz"
# fslcreatehd 256 256 60 1 1 1 2 1 0 0 0 4  ${Dicom}/Temp_carto.nii.gz
# echo "flirt -in ${Dicom}/${Image%.nii.gz}_carto.nii.gz -applyxfm -init /usr/share/fsl/etc/flirtsch/ident.mat -out ${Dicom}/B0_map -paddingsize 0.0 -interp trilinear -ref ${Dicom}/Temp_carto.nii.gz"
# flirt -in ${Dicom}/${Image%.nii.gz}_carto.nii.gz -applyxfm -init /usr/share/fsl/etc/flirtsch/ident.mat -out ${Dicom}/B0_map -paddingsize 0.0 -interp trilinear -ref ${Dicom}/Temp_carto.nii.gz
## Matlab
#Im_ref.vol = Imre ./ ${Factor};
echo "--------------------------------------------------"
echo "Interpolate volume"
/usr/local/matlab/bin/matlab -nodisplay <<EOF
Im = load_nifti('${Dicom}/${Image}');
Magnitude = load_nifti('${Dicom}/${Magn}');
Im_ref = load_nifti('${Dicom}/${Image_ref}');
nx = size(Im_ref.vol, 1);
ny = size(Im_ref.vol, 2);
Imre=imresize(Im.vol, [nx ny], 'nearest');
Magre = imresize(Magnitude.vol, [nx ny], 'nearest');
Im_ref.vol=Imre;
save_nifti(Im_ref, '${Dicom}/phi_map.nii');
Im_ref.vol=Magre;
save_nifti(Im_ref, '${Dicom}/magnitude.nii');
EOF
echo

gzip -f ${Dicom}/phi_map.nii
gzip -f ${Dicom}/magnitude.nii

echo
echo
echo "Normalisation de la carte de phase de 0 à 2*pi"
echo
fslhd ${Dicom}/phi_map.nii.gz |grep scl_slope > ${Dicom}/slope.txt
Factor=`cat ${Dicom}/slope.txt | awk '{print $2}'`
echo Factor=${Factor}
rm -fr ${Dicom}/slope.txt

fslmaths ${Dicom}/phi_map.nii.gz -div ${Factor} ${Dicom}/phi_map_re.nii.gz -odt double
fslstats ${Dicom}/phi_map_re.nii.gz -R > ${Dicom}/stats.txt
Vmin=`cat ${Dicom}/stats.txt |awk '{print $1}'`
Vmax=`cat ${Dicom}/stats.txt |awk '{print $2}'`
echo Vmin=$Vmin et Vmax=$Vmax
rm -f ${Dicom}/stats.txt

fslmaths ${Dicom}/phi_map_re.nii.gz -div 203 -add 1 -mul 3.1416 ${Dicom}/phi_temp.nii.gz -odt double
#echo "fslmaths ${Dicom}/phi_temp_1.nii.gz -div `echo "${Vmax} - ${Vmin}" | bc -l` ${Dicom}/phi_temp_2.nii.gz"
#V_diff=`echo "${Vmax} - ${Vmin}" | bc -l`
#echo "V_diff = ${V_diff}"
#fslmaths ${Dicom}/phi_temp_1.nii.gz -div ${V_diff} ${Dicom}/phi_temp_2.nii.gz -odt double
#fslmaths ${Dicom}/phi_temp_2.nii.gz -mul 6.2832 ${Dicom}/phi_temp.nii.gz -odt double
echo
echo
echo "déroulement de la phase : cette opération peut prendre plusieurs minutes"
echo
echo
echo "prelude -p ${Dicom}/phi_temp.nii.gz -a ${Dicom}/magnitude.nii.gz -o ${Dicom}/unwrapphi.nii.gz"
time prelude -p ${Dicom}/phi_temp.nii.gz -a ${Dicom}/magnitude.nii.gz -o ${Dicom}/unwrapphi.nii.gz

min=`fslstats ${Dicom}/unwrapphi.nii.gz -M`
if [ `echo "${min} < 0" | bc -l` ]
then
fslmaths ${Dicom}/unwrapphi.nii.gz -add 3.1416 ${Dicom}/unwrapphi_temp.nii.gz
else 
fslmaths ${Dicom}/unwrapphi.nii.gz -sub 3.1416 ${Dicom}/unwrapphi_temp.nii.gz
fi
fslmaths ${Dicom}/unwrapphi_temp.nii.gz -div 0.015456 ${Dicom}/unwrapB0.nii.gz -odt double

rm -fr ${Dicom}/phi_temp*.nii.gz

echo "Calcul et correction des distorsions"

echo "cd ${Dicom}" 
cd ${Dicom} 
#for dti in `ls ${Dicom}/*DTI*`
for dti in `ls *DTI*`
do  
   echo "fslsplit ${dti}"
   fslsplit ${dti}
   i=0
   for Temp_dti in `ls vol*`
   do
      if [ ${i} -lt 10 ]
      then
 	i="0${i}"
      fi
      echo "fugue -i ${Temp_dti} --dwell=0.0026 --loadfmap=unwrapB0.nii.gz -u Unwarp_${i}"
      fugue -i ${Temp_dti} --dwell=0.0026 --loadfmap=unwrapB0.nii.gz -u Unwarp_${i}
      i=`echo "${i}+1 " | bc -l`
   done
   echo "fslmerge -t ${dti%.nii.gz}_unwarp Unwarp_*"
   fslmerge -t ${dti%.nii.gz}_unwarp Unwarp_*
   rm -f vol* Unwarp_*
 done
cd ..
