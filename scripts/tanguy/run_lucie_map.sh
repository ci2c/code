#! /bin/bash

if [ $# -lt 2 ]
then
		echo ""
		echo "Usage: run_lucie_map.sh -SD <Subj_Dir> -subj <Subj_ID>"
		echo ""
		echo " -SD				: Subj Dir"
		echo ""
		echo ""
		echo " -subj				: Subj ID"
		echo ""
		echo "Usage: run_lucie_map.sh -SD <Subj_Dir> -subj <Subj_ID>"
		echo ""
		echo "Author: Tanguy Hamel - CHRU Lille - 2013"
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
			echo "Usage: run_lucie_map.sh -SD <Subj_Dir> -subj <Subj_ID>"
			echo ""
			echo " -SD				: Subj Dir"
			echo ""
			echo ""
			echo " -subj				: Subj ID"
			echo ""
			echo "Usage: run_lucie_map.sh -SD <Subj_Dir> -subj <Subj_ID>"
			echo ""
			echo "Author: Tanguy Hamel - CHRU Lille - 2013"
			echo ""
			exit 1
			;;
	-SD)
		
		SD=`expr $index + 1`
		eval SD=\${$SD}
		echo "Subject Directory  : $SD"
		;;
	
	-subj)
		
		SUBJ=`expr $index + 1`
		eval SUBJ=\${$SUBJ}
		echo "Subject ID  : $SUBJ"
		;;

	esac
	index=$[$index+1]
done

echo ""
echo ""
echo ""
echo ""
echo "run extract_roi.sh"
echo ""
echo "Author: Tanguy Hamel - CHRU Lille - 2014"
echo ""
echo ""
echo ""


### Paramètres 

# entrées
echo "manualtransfo=$SD/$SUBJ/recallage/tag.xfm"
manualtransfo=$SD/$SUBJ/recallage/tag.xfm

echo "prefix=m"
prefix="m"

echo "roidir=$SD/$SUBJ/FS/ROI_analyse/mROI"
roidir="$SD/$SUBJ/FS/ROI_analyse/mROI"

echo "T1_ref=$SD/$SUBJ/FS/T1_ref.mnc"
T1_ref="$SD/$SUBJ/FS/T1_ref.mnc"

echo "T1_fs=$SD/$SUBJ/FS/T1_fs.mnc"
T1_fs="$SD/$SUBJ/FS/T1_fs.mnc"

echo "T2file=$SD/$SUBJ/recallage/T2.mnc"
T2file="$SD/$SUBJ/recallage/T2.mnc"

echo "T2mapfile=$SD/$SUBJ/recallage/T2map.mnc"
T2mapfile="$SD/$SUBJ/recallage/T2map.mnc"


echo ""

# sorties

echo "files_outdir=${T1_fs%%`basename $T1_fs`*}/recal"
files_outdir=${T1_fs%%`basename $T1_fs`*}/recal

echo "transfodir=$files_outdir"
transfodir=$files_outdir

echo "stats_outdir=$SD/$SUBJ/Stats"
stats_outdir="$SD/$SUBJ/Stats"

echo "prefix_recal=r"
prefix_recal="r"

echo ""
echo ""

### Initialisation

cp -Rf $roidir ${roidir}_back
rm -f $roidir/T1.mgz

if [ ! -f $manualtransfo ]
then
	echo ""
	echo "cette étape a besoin du fichier de transformation manuelle"
	echo ""
	echo "nom du fichier requis : $manualtransfo "
	echo ""
	exit 1
fi


if [ ! -d $roidir ]
then
	echo ""
	echo "cette étape doit être précédée de l'extraction des ROI FreeSurfer"
	echo ""
	echo $roidir
	exit 1
elif [ `ls ${roidir}/${prefix}*nii | wc -l` -eq 0 ]
then
	echo "fichiers mrois.nii non trouvés"
	echo ""
	echo "utilisation des fichiers roi.nii"
	echo ""
	for file in `ls $roidir`
	do
		filename=$(basename $file)
		echo "mv $roidir/$filename ${roidir}/m${filename}"
		mv $roidir/$filename ${roidir}/m${filename}
	done
fi


if [ -f $T1_fs ]
then
	if [ "${T1_fs#*.}" != "mnc" ]
	then
		echo "création du fichier ${T1_fs%%.*}.mnc"
		echo "mri_convert $T1_fs ${T1_fs%%.*}.mnc"
		mri_convert $T1_fs ${T1_fs%%.*}.mnc
		T1_fs=${T1_fs%%.*}.mnc
		echo "	$T1_fs"
	else
		echo ""
		echo "FreeSurfer MINC T1 : $T1_fs"
		echo ""
	fi
elif [ -f ${T1_fs%%`basename $T1_fs`*}/T1.mgz ]
then
	echo "création du fichier ${T1_fs%%.*}.mnc"
	echo "mri_convert ${T1_fs%%`basename $T1_fs`*}/T1.mgz ${T1_fs%%.*}.mnc"
	mri_convert ${T1_fs%%`basename $T1_fs`*}/T1.mgz ${T1_fs%%.*}.mnc
	T1_fs=${T1_fs%%.*}.mnc
	echo "	$T1_fs"
else
	echo ""
	echo "impossible de trouver le fichier T1 FreeSurfer $T1_fs ou son équivalent T1.mgz"
	echo ""
	exit 1
fi




if [ -f $T1_ref ]
then
	if [ "${T1_ref#*.}" != "mnc" ]
	then
		echo "création du fichier ${T1_ref%%.*}.mnc"
		echo "mri_convert $T1_ref ${T1_ref%%.*}.mnc"
		mri_convert $T1_ref ${T1_ref%%.*}.mnc
		T1_ref=${T1_ref%%.*}.mnc
		echo $T1_ref
	else
		echo ""
		echo "Reference MINC T1 : $T1_ref"
		echo ""
	fi
elif [ -f ${T1_ref%%`basename $T1_ref`*}/T1.mnc ]
then
	echo "création du fichier ${T1_ref%%.*}.mnc"
	echo "cp -f ${T1_ref%%`basename $T1_ref`*}/T1.mnc ${T1_ref%%.*}.mnc"
	cp -f ${T1_ref%%`basename $T1_ref`*}/T1.mnc ${T1_ref%%.*}.mnc
	T1_ref=${T1_ref%%.*}.mnc
	echo $T1_ref
else
	echo ""
	echo "impossible de trouver le fichier T1 référence $T1_ref ou son équivalent T1.mnc"
	echo ""
	exit 1
fi


if [ ! -f $T2file ]
then
	echo "fichier T2 non trouvé"
	echo ""
	echo $T2file
	exit 1
fi

if [ ! -f $T2mapfile ]
then
	echo "fichier T2 map non trouvé"
	echo ""
	echo $T2file
	exit 1
fi


if [ ! -d $transfodir ]
then
	echo "mkdir $transfodir"
	mkdir $transfodir
fi

if [ ! -d $files_outdir ]
then
	echo "mkdir $files_outdir"
	mkdir $files_outdir
fi



mkdir $SD/$SUBJ/FS/temp_recal
mri_convert $SD/$SUBJ/FS/T1_fs.mnc $SD/$SUBJ/FS/temp_recal/T1_fs.nii
mri_convert $SD/$SUBJ/FS/T1_ref.mnc $SD/$SUBJ/FS/temp_recal/T1_ref.nii

if [ ! -d $stats_outdir ]
then
	echo ""
	echo "création du dossier sortie"
	echo ""
	echo "mkdir $stats_outdir"
	mkdir $stats_outdir
fi



### recalage des T2 et T2 map

echo ""
echo ""
echo "recalage des T2 et T2 map"
echo ""
echo ""

echo "mritoself -transform $manualtransfo $T2file $T1_ref $transfodir/T2toT1_ref.xfm"
mritoself -transform $manualtransfo $T2file $T1_ref $transfodir/T2toT1_ref.xfm

echo "mincresample -like $T1file -transformation $autotransfo $T2file ${files_outdir}/T2toT1.mnc -clobber"
mincresample -like $T1_ref -transformation $transfodir/T2toT1_ref.xfm $T2file ${files_outdir}/T2toT1_ref.mnc -clobber

echo "mincresample -like $T1file -transformation $autotransfo $T2mapfile ${files_outdir}/T2maptoT1.mnc -clobber"
mincresample -like $T1_ref -transformation $transfodir/T2toT1_ref.xfm $T2mapfile ${files_outdir}/T2maptoT1_ref.mnc -clobber







#########
#########
# SI BESOIN D UN SECOND RECALLAGE DU T2MAP SUR LE T1 NATIF
#
#########
#########

#echo "2nd recallage"
#echo "mritoself $T2file $T1_ref $transfodir/T2toT1_ref_2.xfm"
#mritoself ${files_outdir}/T2toT1_ref.mnc $T1_ref $transfodir/T2toT1_ref_2.xfm
#echo "mincresample -like T1.mnc -transformation T2toT1auto.xfm T2maptoT1.mnc T2maptoT1_auto.mnc"
#mincresample -like $T1_ref -transformation $transfodir/T2toT1_ref_2.xfm ${files_outdir}/T2maptoT1_ref.mnc ${files_outdir}/T2maptoT1_ref_2.mnc
#mv ${files_outdir}/T2maptoT1_ref.mnc ${files_outdir}/T2maptoT1_ref_first_step.mnc
#mv ${files_outdir}/T2maptoT1_ref_2.mnc ${files_outdir}/T2maptoT1_ref.mnc

#########
#########
# FIN 
#########
#########


### Stats

/usr/local/matlab11/bin/matlab -nodisplay <<EOF
% Load Matlab Path
%cd /home/lucie/
%p = pathdef;
%addpath(p);

cd /home/lucie/memoire/code/new
p=lucie_matlab_path;
addpath(p)

list=dir(['$roidir' '/' '$prefix' '*.nii']);
size(list)
for i = 1 : size(list,1)
    roilist{i}=list(i).name;
    list(i).name
end




T_CoregT1FsToT1Map('${SD}/${SUBJ}/FS/temp_recal',roilist,'$roidir');

T_ResliceROI('${SD}/${SUBJ}/FS/temp_recal',roilist,'$roidir');

roilist

roilist_recal=arrayfun(@(i) ['r' roilist{i}],1:length(roilist),'UniformOutput',0);

stats=T_ComputeStatsOnT2Map('$SD/$SUBJ/FS/recal/T2maptoT1_ref.mnc','$roidir',roilist_recal);

T_write_results_stats_lucie('$stats_outdir','$SUBJ',stats)

save(fullfile('$stats_outdir','results_fs.mat'),'stats');

EOF












