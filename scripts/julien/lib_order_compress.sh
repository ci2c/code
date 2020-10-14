#!/bin/bash

export LC_CTYPE=C
export LANG=C

if [ $# -lt 3 ]
then
echo "Usage:  lib_order_compress.sh  -i <input folder> -o <output folder> -t <folder structure type>"
echo "  -i                         : input folder"
echo "  -o                         : output folder"
echo "  -t                         : type"
echo ""
echo "Author: Dumont Julien - CHRU Lille - Sept , 2014"
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
echo "Usage:  lib_order_compress  -i <input folder> -o <output folder> -t <folder structure type>"
echo "  -i                         : input folder"
echo "  -o                         : output folder"
echo "	-t                         : type"
echo ""
echo "Author: Dumont Julien - CHRU Lille - Sept , 2014"
echo ""
exit 1
;;
-i)
index=$[$index+1]
eval input=\${$index}
echo "input folder : ${input}"
;;
-o)
index=$[$index+1]
eval output=\${$index}
echo "output folder : ${output}"
;;
-t)
index=$[$index+1]
eval type=\${$index}
echo "folder type: ${type}"
;;
-*)
eval infile=\${$index}
echo "${infile} : unknown option"
echo ""
echo "Usage:  lib_order_compress  -i <input folder> -o <output folder> -t <folder structure type>"
echo "  -i                         : input folder"
echo "  -o                         : output folder"
echo "	-t                         : type"
echo ""
echo "Author: Dumont Julien - CHRU Lille - Sept , 2014"
echo ""
exit 1
;;
esac
index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${input} ]
then
echo "-i argument mandatory"
exit 1
fi

if [ -z ${output} ]
then
echo "-o argument mandatory"
exit 1
fi

cd ${input}

for annee in $(ls -d *)
do

dcm_order_archive_recherche.sh -i ${input}/$annee/ -o ${output} -t folder

done

cd ${output}

for station in $(ls -d *)
do


	dcm_compress_archive.sh ${output}/${station}/

done


