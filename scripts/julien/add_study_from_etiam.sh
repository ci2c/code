#!/bin/bash

if [ $# -lt 1 ]
then
echo "Usage:  add_study_from_etiam.sh  -d <date>"
echo "  -d                     : date (yyyymmdd)"
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
echo "Usage:  add_study_from_etiam.sh  -d <date>"
echo "  -d                     : date (yyyymmdd)"
echo ""
exit 1
;;
-d)
index=$[$index+1]
eval my_date=\${$index}
;;
-*)
eval infile=\${$index}
echo "${infile} : unknown option"
echo ""
echo "Usage:  add_study_from_etiam.sh  -d <date>"
echo "  -d                     : date (yyyymmdd)"
echo ""
exit 1
;;
esac
index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${my_date} ]
then
echo "-d argument mandatory"
exit 1
fi


is_good_format=$(echo ${my_date} | egrep -e "^[0-9]{4}[0-1][0-9][0-3][0-9]$" | wc -l)
if [ ${is_good_format} -eq 1 ]
then

	ssh gaia "sudo /var/www/html/imvdb/pipeline/bash/add_etiam_study3.sh ${my_date}"
else
	echo "Invalid date"
	
fi






