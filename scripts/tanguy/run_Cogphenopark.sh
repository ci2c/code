#!/bin/bash

if [ $# -lt 2 ]
then
	echo ""
	echo "Usage:  run_Cogphenopark.sh  -sd <subject dir>"
	echo ""
	echo "  -sd				:subject dir : directory containing rec&par files "
	echo ""
	echo "Usage:  run_Cogphenopark.sh  -sd <subject dir>"
	echo ""
	echo "Author: Tanguy Hamel - CHRU Lille - 2014"
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
		echo ""
		echo "Usage:  run_Cogphenopark.sh  -sd <subject dir>"
		echo ""
		echo "  -sd				:subject dir : directory containing rec&par files "
		echo ""
		echo "Usage:  run_Cogphenopark.sh  -sd <subject dir>"
		echo ""
		echo "Author: Tanguy Hamel - CHRU Lille - 2014"
		echo ""
		exit 1
		;;
	-sd)
		index=$[$index+1]
		eval SD=\${$index}
		echo "Subject Directory : ${SD}"
		;;

	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo ""
		echo "Usage:  run_Cogphenopark.sh  -sd <subject dir>"
		echo ""
		echo "  -sd				:subject dir : directory containing rec&par files "
		echo ""
		echo "Usage:  run_Cogphenopark.sh  -sd <subject dir>"
		echo ""
		echo "Author: Tanguy Hamel - CHRU Lille - 2014"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${SD} ]
then
	 echo "-sd argument mandatory"
	 exit 1
fi

if [ ! -d ${SD} ]
then
	echo "SD not found"
	exit 1
fi


echo '
*******************************************************************************
* 0- Init      	                                              *
******************************************************************************* 
'

echo "datapath=/NAS/dumbo/protocoles/CogPhenoPark/data"
datapath=/NAS/dumbo/protocoles/CogPhenoPark/data

echo "vbmpath=/NAS/dumbo/protocoles/CogPhenoPark/VBM"
vbmpath=/NAS/dumbo/protocoles/CogPhenoPark/VBM

echo "FS_path=/NAS/dumbo/protocoles/CogPhenoPark/FS5.1/"
FS_path=/NAS/dumbo/protocoles/CogPhenoPark/FS5.1/

echo "Logdir=/home/tanguy/Logdir"
Logdir=/home/tanguy/Logdir

echo "subj=basename $SD"
echo "subj=`basename $SD`"
subj=`basename $SD`

echo "subjname=${subj%%^*}"
subjname=${subj%%^*}

echo "DIR=dirname $SD"
echo "DIR=`dirname $SD`"
DIR=`dirname $SD`

echo '
*******************************************************************************
* 1- Converting files      	                                              *
******************************************************************************* 
'

nrec=`ls $SD/*rec | wc -l`
if [ $nrec -gt 0 ]
then
	echo "converting REC&PAR files"
	echo "mkdir $SD/RECPAR"
	mkdir $SD/RECPAR
	mv $SD/*par $SD/RECPAR
	mv $SD/*rec $SD/RECPAR
	rm -f $SD/*
	
	echo "dcm2nii -o $SD/RECPAR -f fsl $SD/RECPAR/*"
	dcm2nii -o $SD/RECPAR -f fsl $SD/RECPAR/*
	
	echo "gunzip $SD/RECPAR/*gz"
	gunzip $SD/RECPAR/*gz

	mv $SD/RECPAR/*nii $SD
else
	nnii=`ls $SD/*nii | wc -l`
	if [ $nnii -gt 0 ]
	then
		echo "nii files are already presents"
	else
		echo "no file found"
		exit 1
	fi
fi


echo '
*******************************************************************************
* 2-  Finding T1 file      	                                              *
******************************************************************************* 
'

nanat=`ls $SD/*3dt1*.nii | wc -l`
natatup=`ls $SD/*3DT1*.nii | wc -l`

if [ $nanat -eq 1 ]
then
	echo "anat=`ls $SD/*3dt1*.nii`"
	anat=`ls $SD/*3dt1*.nii`
	echo "anat=`basename $anat`"
	anat=`basename $anat`
elif [ $nanatup -eq 1 ]
then 
	echo "`ls $SD/*3DT1*.nii`"
	anat=`ls $SD/*3DT1*.nii`
	echo "anat=`basename $anat`"
	anat=`basename $anat`
else
	echo "no 3d T1 file found"
	ls $SD
	echo "paste T1 name"
	read anat
fi



echo '
*******************************************************************************
* 3-  Moving data      	                	                              *
******************************************************************************* 
'

if [ ! -d $datapath/$subjname ]
then
	echo "cp -Rf $SD $datapath/$subjname"
	cp -Rf $SD $datapath/$subjname
else
	echo "$subjname fold is already presents into $datapath"
fi




echo '
*******************************************************************************
* 3-  Runing FreeSurfer      	                                              *
******************************************************************************* 
'

echo "qbatch -N FS_Cog_$subjname -q fs_q -oe $Logdir Cogphenopark_FS5.3.sh -subj $subjname"
qbatch -N FS_Cog_$subjname -q fs_q -oe $Logdir Cogphenopark_FS5.3.sh -subj $subjname 





echo '
*******************************************************************************
* 4-  copy T1 for VBM      	                                              *
******************************************************************************* 
'

echo "cp -f $datapath/$subjname/$anat $vbmpath/raw_T1/T1_${subjname}.nii"
cp -f $datapath/$subjname/$anat $vbmpath/raw_T1/T1_${subjname}.nii


echo '
*******************************************************************************
* 5-  run VBM      	                                          	      *
******************************************************************************* 
'

mkdir -p $vbmpath/VBM/tmp_$subjname

echo "cp -f $vbmpath/raw_T1/T1_${subjname}.nii $vbmpath/VBM/tmp_$subjname"
cp -f $vbmpath/raw_T1/T1_${subjname}.nii $vbmpath/VBM/tmp_$subjname

echo "VBM_8.sh -i $vbmpath/VBM/tmp_$subjname"
VBM_8.sh -i $vbmpath/VBM/tmp_$subjname

if [ -f $vbmpath/VBM/raw_volumes.txt ]
then
	cat $vbmpath/VBM/tmp_$subjname/raw_volumes.txt >> $vbmpath/VBM/raw_volumes.txt
else
	mv $vbmpath/VBM/tmp_$subjname/raw_volumes.txt $vbmpath/VBM/raw_volumes.txt
fi

if [ -f $vbmpath/VBM/subj_list.txt ]
then
	cat $vbmpath/VBM/tmp_$subjname/subj_list.txt >> $vbmpath/VBM/subj_list.txt
else
	mv $vbmpath/VBM/tmp_$subjname/subj_list.txt $vbmpath/VBM/subj_list.txt
fi

mv $vbmpath/VBM/tmp_$subjname/*nii $vbmpath/VBM/
mv $vbmpath/VBM/tmp_$subjname/T1_${subjname}_seg8.mat $vbmpath/VBM/

rm -Rf $vbmpath/VBM/tmp_$subjname

