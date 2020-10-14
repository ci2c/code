#!/bin/bash
	
if [ $# -lt 1 ]
then
	echo ""
	echo "Usage: par2bval.sh Convert Phillips par file to bvec & bval"
	echo ""
	echo "  par_file              : input par file"
	echo ""
	echo "Usage: par2bval.sh Convert Phillips par file to bvec & bval"
	echo ""
	exit 1
fi

PAR_FILE=$1

BASE_NAME=`basename ${PAR_FILE}`
DIR_NAME=`dirname ${PAR_FILE}`
DIR_NAME=`cd ${DIR_NAME} | pwd`

PAR_FILE=${DIR_NAME}/${BASE_NAME}

/usr/local/matlab11/bin/matlab -nodisplay -nosplash -nojvm<<EOF
par2bval('${PAR_FILE}');
EOF



