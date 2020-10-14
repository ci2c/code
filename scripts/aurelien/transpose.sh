#!/bin/bash

for files in `ls *.bvec`
do
cols=`head -1 <${files} | wc -w`
count=1
while [ $count -le $cols ]; do
        if [ $count = 1 ]; then
                tr -s ' ' ' ' <${files} | cut -f$count -d' ' | tr '\012' ' ' >${files}_transpose.txt
        else
                tr -s ' ' ' ' < ${files} | cut -f$count -d' ' | tr '\012' ' ' >>${files}_transpose.txt
        fi
        echo "" >>${files}_transpose.txt
        count=`expr $count + 1`
done
done

echo > bvec.txt
for file in `ls *_transpose.txt`
do
cat ${file} >> bvec.txt
done
