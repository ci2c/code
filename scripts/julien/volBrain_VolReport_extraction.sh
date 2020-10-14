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
echo "Usage:  volBrain_VolReport_extraction.sh  -i <input pdf file>"
echo "                                         [-q] quiet mode : no std output"
echo "                                         [-s] subject name"
echo "                                         [-csv] csv output file"
echo "                                         [-validity] Only test if the pdf file is a valid volBrain Report"
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
-i)
index=$[$index+1]
eval input=\${$index}
;;
-csv)
index=$[$index+1]
eval csv_file=\${$index}
;;
-q)
eval quiet="y"
;;
-s)
index=$[$index+1]
eval subject=\${$index}
;;
-validity)
eval only_test_report_validity="y"
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
	echo "Input required"
	use_func
	exit 1
fi
if [ ! -f ${input} ]
then
	echo "Input does not exist"
	use_func
	exit 1
fi
if [ -z ${csv_file} ]
then
  csv_file="5sd4hs35r7jetk42d.csv"
else

    if [ ! -f ${csv_file} ]
    then
      touch ${csv_file}
    fi

fi

if [ -z ${subject} ]
then
  subject=""
else
  subject="${subject},"
fi




pdf_file=$(basename ${input})
pdf_dir=$(dirname ${input})
file_wo_ext=${pdf_file%.*}
txt_file="${file_wo_ext}.txt"
output=${pdf_dir}/${txt_file}


pdftotext ${input}

is_a_valid_VB_Report=$(cat ${output} | grep "volBrain Volumetry Report" | wc -l)

if [  ! ${is_a_valid_VB_Report} -eq 1 ]
then

  echo -e "\e[31m${pdf_file} is not a valid volBrain Volumetry Report\e[0m"
  rm ${output}
  exit 1
else
  if [ "${only_test_report_validity}" == "y"  ]
  then
    echo "${pdf_file} is a valid volBrain Volumetry Report"
    rm ${output}
    exit 1
  fi

fi

volBrain_version=$(cat ${output} | grep "volBrain Volumetry Report. version 1.0 release 04-03-2015" | wc -l)
IC=$(cat ${output}  | sed -n 12p | sed 's/ /_/g' | sed -e "s/\(.*\)_.*/\1/" )
RH=$(cat ${output}  | sed -n 253p | sed 's/ /_/g' | sed -e "s/\(.*\)_.*/\1/" )
LH=$(cat ${output}  | sed -n 255p | sed 's/ /_/g' | sed -e "s/\(.*\)_.*/\1/" )


if [ -z ${quiet} ]
then
echo -e "\e[31m
=================== Extract VolBrain data from Report ========================\e[0m"

echo -e "\e[32mVolBrain Report          :\e[0m ${input}"
echo -e "\e[32mDirectory Report         :\e[0m ${pdf_dir}"
echo -e "\e[32mOutput                   :\e[0m ${output}"


echo -e "\e[31m===========================================================\e[0m"

echo -e "\e[32mIntracranial Cavity :\e[0m ${IC}"
echo -e "\e[32mRight Hippocampus   :\e[0m ${RH}"
echo -e "\e[32mLeft Hippocampus    :\e[0m ${LH}"
echo -e "\e[31m===========================================================\e[0m"
fi

if [ ! ${volBrain_version} -eq 1 ]
then

echo -e "\e[31mWARNING - WARNING - WARNING - WARNING - WARNING - WARNING - WARNING
This script is working with volBrain Volumetry Report. version 1.0 release 04-03-2015
Use it with an other version at your own risk\e[0m"

fi



if [ -f ${csv_file} ]
then
  echo "${subject}${IC},${RH},${LH}" >> "${csv_file}"
fi

rm ${output}