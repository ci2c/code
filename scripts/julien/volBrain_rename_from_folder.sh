#!/bin/bash

#######################################
#
#   Require pdftotext
#   
#######################################
export LC_CTYPE=C
export LANG=C

function use_func(){

echo ""

echo " J.DUMONT 07/18"
echo ""

}

index=1

while [ $index -le $# ]
do
eval arg=\${$index}
case "$arg" in
-h|-help)
use_func
exit 1
;;
-s_folder)
index=$[$index+1]
eval search_in=\${$index}
;;
-pdf)
index=$[$index+1]
eval input=\${$index}
;;
-*)
eval infile=\${$index}
echo "
${infile} : unknown option
"

exit 1
;;
esac
index=$[$index+1]
done


if [ -z ${input} ]
then
	echo "pdf file required"
	use_func
	exit 1
fi
if [ ! -f ${input} ]
then
	echo "pdf file does not exist"
	use_func
	exit 1
fi


pdf_file=$(basename ${input})
file_wo_ext=${pdf_file%.*}
pdf_directory=$(dirname ${input})
# nom theorique du nifti
nifti_file=$(echo ${pdf_file} | sed -e "s/\(.*\)_job.*/\1/")
native_file="native_${file_wo_ext}"
# recherche du nifti
this_nifti=$(find ${search_in} -iname "${nifti_file}")

#echo "${pdf_file} --> ${nifti_file} -> ${this_nifti}"
subject=$(basename $(dirname ${this_nifti}))
output="$(dirname ${this_nifti})/"


echo "--------------------------------------"
echo "input   : ${input}"
echo "pdf     : ${pdf_file}"
echo "nifti   : ${this_nifti}"
echo "native  : ${native_file}"
echo "subject : ${subject}"
echo "output  : ${output}"

echo "mv -v ${input} ${output}/${subject}_${pdf_file}"
echo "mv -v ${pdf_directory}/${native_file} ${output}/${subject}_${native_file}"
if [ -e ${output} ]
then

  #echo "mv -v ${input} ${output}/${subject}_${pdf_file}"
  mv -v ${input} ${output}/${subject}_${pdf_file}
  
  if [ -f  ${pdf_directory}/${native_file} ]
  then
  #echo "mv -v ${pdf_directory}/${native_file} ${output}/${subject}_${native_file}"
  mv -v ${pdf_directory}/${native_file} ${output}/${subject}_${native_file}
  fi
  
fi



