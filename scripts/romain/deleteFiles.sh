#!/bin/bash
subjList=$1

for SUBJ in `cat ${subjList}`
do
        echo "find $2 -iname ${SUBJ} | xargs rm"
        `find $2 -iname ${SUBJ}* | xargs rm`
done
