sd=/home/tanguy/dumbo/protocoles/CogPhenoPark/FS5.3_tmp

subj=$1
echo $subj
subj=`basename $subj`

n=`ls $sd/$subj/orig/*res* | wc -l `

echo $n


if [ $n -eq 1 ]
	then


	rm -Rf $sd/$subj/spm
	mkdir $sd/$subj/spm
	rs=`ls $sd/$subj/orig/*res*nii`
	rs=`basename $rs`
	echo "RS file : $rs"
	fslsplit $sd/$subj/orig/$rs $sd/$subj/spm/epi -t
	dir=$sd/$subj
	gunzip $sd/$subj/spm/*

	## Calculate TR and N
	TR=$(mri_info $dir/orig/$rs | grep TR | awk '{print $2}')
	TR=$(echo "$TR/1000" | bc -l)
	N=$(mri_info $dir/orig/$rs | grep dimensions | awk '{print $6}')


matlab -nodisplay <<EOF

Cog_ART_RS('${dir}',${TR},${N})

EOF

fi