#! /bin/bash

if [ $# -lt 2 ]
then
	echo "Usage : MyTranspose.sh input.bvec input_transpose.bvec"
	exit 1
fi


cols=`head -1 <$1 | wc -w`
count=1
while [ $count -le $cols ]; do
        if [ $count = 1 ]; then
                tr -s ' ' ' ' <$1 | cut -f$count -d' ' | tr '\012' ' ' >$2
        else
                tr -s ' ' ' ' < $1 | cut -f$count -d' ' | tr '\012' ' ' >>$2
        fi
        echo "" >>$2
        count=`expr $count + 1`
done

