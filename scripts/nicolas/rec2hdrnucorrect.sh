#! /bin/bash

if [ $# -lt 1 ]
then
    echo ""
    echo "Usage: rec2hdrnucorrect <path2folder>"
    echo "create for each rec image in <path2folder> a <image_name>_nu.hdr"
    echo ""
    exit 1
fi

pathdir=$1

echo "mkdir ~/tempforT1process"
mkdir ~/tempforT1process
echo "cd $pathdir"
cd $pathdir

for Imrec in `ls *.rec`
do
  echo "cp $Imrec ~/tempforT1process"
  cp $Imrec ~/tempforT1process
done

for Impar in `ls *.par`
do
  echo "cp $Impar ~/tempforT1process"
  cp $Impar ~/tempforT1process
done

echo "cd ~/tempforT1process"
cd ~/tempforT1process

for Image in `ls *.rec`
do
	Image=${Image%.rec}
	if [ -e ${Image}_output ]
	then
		echo "${Image} deja fait"
	else
		echo "mkdir ./${Image}_output"
		mkdir ./${Image}_output
		echo "dcm2nii -o ${Image}_output ${Image}.rec"
		dcm2nii -o ${Image}_output ${Image}.rec
		echo "cd ./${Image}_output"
		cd ./${Image}_output
		echo "rm -f o* co*"
		rm -f o* co*
		NII=`ls *nii.gz`
		echo "Image Nii : $NII"
		mv ${NII} ${Image}.nii.gz
		echo "gunzip ${Image}.nii.gz"
		gunzip ${Image}.nii.gz
		echo "nii2mnc ${Image}.nii ${Image}_temp.mnc"
		nii2mnc ${Image}.nii ${Image}_temp.mnc
		echo "nu_correct ${Image}_temp.mnc ${Image}_temp_nu.mnc -distance 25"
		nu_correct ${Image}_temp.mnc ${Image}_temp_nu.mnc -distance 25
		echo "mnc2nii ${Image}_temp_nu.mnc temp.nii"
		mnc2nii ${Image}_temp_nu.mnc temp.nii
		echo "fslswapdim temp.nii -z x y  ${Image}_nu.nii"
		fslswapdim temp.nii -z x y  ${Image}_nu.nii
		echo "fslchfiletype ANALYZE ${Image}_nu.nii.gz"
		fslchfiletype ANALYZE ${Image}_nu.nii.gz
		echo "mv ${Image}_nu.hdr $pathdir"
		mv ${Image}_nu.hdr $pathdir
		echo "mv ${Image}_nu.img $pathdir"
		mv ${Image}_nu.img $pathdir
		cd ..
	fi
done
cd ..
rm -r ~/tempforT1process
