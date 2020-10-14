sd=/home/tanguy/dumbo/protocoles/ictus/TBSS/
path_info=$sd/info.txt
for pop in PATIENTS TEMOINS
do
	for fold in `ls $sd/$pop`
	do
		fold=`basename $fold`

		dti=$(sed 's/ /\n/g' $sd/$pop/$fold/*.bval | sort | uniq -c)

		B=$( echo $dti | awk '{print $NF}')
		dir=$( echo $dti | awk '{print $((NF-1))}')

		echo "$pop - $fold - ${dir}b${B}"

		echo "$pop - $fold - ${dir}b${B}" >> $path_info

	done
done    