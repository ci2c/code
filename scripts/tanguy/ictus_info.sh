sd=/NAS/dumbo/protocoles/ictus/data/2014_05_19_ETUDE_ICTUS/patients_ictus_5/sujets
file=$sd/info.txt
for subj in `ls $sd`
do
subj=`basename $subj`

dde=$(cat $sd/$subj/info_subj.txt | grep AcquisitionDate | awk '{print $3}')
ddn=$(cat $sd/$subj/info_subj.txt | grep PatientBirthDate | awk '{print $3}')

n=`ls $sd/$subj/dcmnii/o* | wc -l`
if [ $n -gt 0 ]
then
anat='T1'
cp -f $sd/$subj/dcmnii/o* $sd/$subj
else
anat=' '
fi

if [ ! -f $sd/$subj/*.bval ]
then
	dti_file=`ls $sd/$subj/dcmnii/*.bval`
	dti_file=`basename $dti_file`
	dti_file=${dti_file%%.*}
	cp -f $sd/$subj/dcmnii/${dti_file}* $sd/$subj/
fi

dti=$(sed 's/ /\n/g' $sd/$subj/*.bval | sort | uniq -c)
B=$( echo $dti | awk '{print $NF}')
dir=$( echo $dti | awk '{print $((NF-1))}')

echo "$subj -  - $ddn - $anat - $dir - $B - $dde"
echo "$subj -  - $ddn - $anat - $dir - $B - $dde" >> $file

done

