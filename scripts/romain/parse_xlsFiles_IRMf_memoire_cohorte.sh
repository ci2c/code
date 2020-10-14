#!/bin/bash

FILE_PATH=$1

if [ -s ${FILE_PATH}/IRMf_cohorte.txt ]
then	
	while read SUBJECT_ID  
	do
	IOpath="/NAS/dumbo/protocoles/IRMf_memoire/data/${SUBJECT_ID}/log/"
	#path="$(dirname $file)"
	#onlyfile="$(basename find IOpath -iname "*Retrieval*.xls")"
	echo "find ${IOpath} -iname "*Retrieval*.xls" | xargs basename"
	retrievalFile=`find ${IOpath} -iname "*Retrieval*.xls*" | xargs basename`
	encodingFile=`find ${IOpath} -iname "*Encoding*.xls*" | xargs basename`
	echo '[gaf baf gaw baw]= parse_xls_log_files_4IRMf('${IOpath}','${encodingFile}','${retrievalFile}','${SUBJECT_ID}');'
	matlab -nodisplay <<EOF
	cd /home/romain/SVN/matlab/romain;
	[gaf baf gaw baw]=parse_xls_log_files_4IRMf('${IOpath}','${encodingFile}','${retrievalFile}','${SUBJECT_ID}');
EOF
	done < ${FILE_PATH}/IRMf_cohorte.txt
fi
