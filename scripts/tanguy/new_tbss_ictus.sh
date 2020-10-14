  #!/bin/bash


if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: new_tbss_ictus.sh -tbss <tbss_dir> -cont <cont_list> -contdir <contdir> -pat <pat_list> -patdir <patdir> -im <image> "
	echo ""
	echo ""
	echo "Usage: new_tbss_ictus.sh -tbss <tbss_dir> -cont <cont_list> -contdir <contdir> -pat <pat_list> -patdir <patdir> -im <image> "
	echo ""
	exit 1
fi



index=1

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: new_tbss_ictus.sh -tbss <tbss_dir> -cont <cont_list> -contdir <contdir> -pat <pat_list> -patdir <patdir> -im <image> "
		echo ""
		echo ""
		echo "Usage: new_tbss_ictus.sh -tbss <tbss_dir> -cont <cont_list> -contdir <contdir> -pat <pat_list> -patdir <patdir> -im <image> "
		echo ""
		exit 1
		;;
	-tbss)
		index=$[$index+1]
		eval outdir=\${$index}
		echo "outdir : $outdir"
		;;

	
	-cont)
		index=$[$index+1]
		eval contlist=\${$index}
		echo "cont list : $contlist"
		;;
	
	-contdir)
		index=$[$index+1]
		eval contdir=\${$index}
		echo "contdir : $contdir"
		;;
	
	-pat)
		index=$[$index+1]
		eval patlist=\${$index}
		echo "pat list : $patlist"
		;;

	-patdir)
		index=$[$index+1]
		eval patdir=\${$index}
		echo "patdir : $patdir"
		;;

	-im)
		index=$[$index+1]
		eval im=\${$index}
		echo "image : $im"
		;;		

	esac
	index=$[$index+1]
done

list_dir=/NAS/dumbo/tanguy/ictus/TBSS/Doc/ictus_subj_lists
nbper=5000

if [ $im = FA ]
	then
	exam=/home/tanguy/dumbo/tanguy/ictus/TBSS/TBSS/$outdir
	echo "outdir : $outdir"
	tbss_dir=$exam
else
	exam=/home/tanguy/dumbo/tanguy/ictus/TBSS/TBSS/$outdir/$im
	echo "outdir : $outdir"
	tbss_dir=/home/tanguy/dumbo/tanguy/ictus/TBSS/TBSS/$outdir/
fi

if [ ! -d $exam ]
	then
	echo "mkdir $exam"
	mkdir "$exam"
fi

echo ""
echo ""
echo "copy for cont"
echo ""

if [ $contlist = cont.txt ]
	then
	data_dir=TEMOINS
else
	data_dir=PATIENTS
fi

echo "sd=/home/tanguy/dumbo/tanguy/ictus/TBSS/Data/$data_dir/"
sd=/home/tanguy/dumbo/tanguy/ictus/TBSS/Data/$data_dir/


for subj in `cat $list_dir/$contlist`
do
	echo "cp -f $sd/$subj/DTI_${contdir}dir/dti/data_corr_${im}.nii.gz $exam/cont_${subj}.nii.gz"
	cp -f $sd/$subj/DTI_${contdir}dir/dti/data_corr_${im}.nii.gz $exam/cont_${subj}.nii.gz
done



echo ""
echo ""
echo "copy for pat"
echo ""

data_dir=PATIENTS

echo "sd=/home/tanguy/dumbo/tanguy/ictus/TBSS/Data/$data_dir/"
sd=/home/tanguy/dumbo/tanguy/ictus/TBSS/Data/$data_dir/

for subj in `cat $list_dir/$patlist`
do
	echo "cp -f $sd/$subj/DTI_${patdir}dir/dti/data_corr_${im}.nii.gz $exam/pat_${subj}.nii.gz"
	cp -f $sd/$subj/DTI_${patdir}dir/dti/data_corr_${im}.nii.gz $exam/pat_${subj}.nii.gz
done

echo ""
echo ""
echo "run tbss_non_fa"
echo ""

cd $tbss_dir

echo "tbss_non_FA $im"
tbss_non_FA $im


cd $tbss_dir/stats 

randomise -i all_${im}_skeletonised -o tbss_${im} -m mean_FA_skeleton_mask -d design.mat -t design.con -n $nbper --T2 -V