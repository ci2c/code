#!/bin/bash

qdir=$1

for script in `ls -1 ${qdir}/*`
do
echo "submitting job $script"
qsub -S /bin/bash -j y -q fs_q -o ${qdir} $script
done
