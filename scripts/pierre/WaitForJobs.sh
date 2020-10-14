#!/bin/bash

if [ $# -lt 1 ]
then
	echo "WaitForJobs.sh  <pattern>"
	echo ""
	echo "  pattern      : text pattern in jobs name"
	echo " "
	echo "WaitForJobs.sh  <pattern>"
	exit 1
fi

JOBS=`qstat | grep $1 | wc -l`

while [ ${JOBS} -ge 1 ]
do
	sleep 5
	JOBS=`qstat | grep $1 | wc -l`
done
