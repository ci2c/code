#!/bin/bash

# Tanguy Hamel @ CHRU Lille, 2014
# run ictus preprocessing & connectome


if [ $# -lt 12 ]
then
	echo ""
	echo "Usage: ictus_prep.sh  -sd <subj dir>  -subj <subj> -anat <t1 file>  -dti <dti file>  -bvec <bvec file>  -bval <bval file> [-no-fs -no-conn -N <Nfiber>]"
	echo ""
	echo "  -sd <subj dir>                     : Path to subject dir"
	echo "  -subj <subj_ID>                    : Subjects ID"
	echo "  -anat <t1 file>                    : path to t1 file"
	echo "  -dti <dti file>                    : path to dti file"
	echo "  -bvec <bvec file>                  : path to bvec file"
	echo "  -bval <bval file>                  : path to bval file"
	echo "Options :"
	echo "  -no-fs                             : Does not apply recon-all. "
	echo "                                          (default : Does apply recon-all)"
	echo "  -no-conn                           : Does not apply connectome. "
	echo "                                          (default : Does apply connectome)"
	echo "  -N Nfiber                          : Number of fibers (default : 1500000)"
	echo "Usage: ictus_prep.sh  -sd <FS_dir>  -subj <subj> -anat <t1 file>  -dti <dti file>  -bvec <bvec file>  -bval <bval file> [-no-fs -no-conn -N <Nfiber>]"
	echo ""
	exit 1
fi


#### Inputs ####
index=1
echo "------------------------"

# Set default parameters
do_fs=1
do_conn=1
Nfiber=1500000
#


while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
	echo ""
		echo "Usage: ictus_prep.sh  -sd <subj dir>  -subj <subj> -anat <t1 file>  -dti <dti file>  -bvec <bvec file>  -bval <bval file> [-no-fs -no-conn -N <Nfiber>]"
		echo ""
		echo "  -sd <subj dir>                     : Path to subject dir"
		echo "  -subj <subj_ID>                    : Subjects ID"
		echo "  -anat <t1 file>                    : path to t1 file"
		echo "  -dti <dti file>                    : path to dti file"
		echo "  -bvec <bvec file>                  : path to bvec file"
		echo "  -bval <bval file>                  : path to bval file"
		echo "Options :"
		echo "  -no-fs                             : Does not apply recon-all. "
		echo "                                          (default : Does apply recon-all)"
		echo "  -no-conn                           : Does not apply connectome. "
		echo "                                          (default : Does apply connectome)"
		echo "  -N Nfiber                          : Number of fibers (default : 1500000)"
		echo "Usage: ictus_prep.sh  -sd <FS_dir>  -subj <subj> -anat <t1 file>  -dti <dti file>  -bvec <bvec file>  -bval <bval file> [-no-fs -no-conn -N <Nfiber>]"
		echo ""
		exit 1
		;;
	-sd)
		index=$[$index+1]
		eval sd=\${$index}
		echo "subject dir  : $sd"
		;;
	-subj)
		index=$[$index+1]
		eval subj=\${$index}
		echo "subj : $subj"
		;;
	-anat)
		index=$[$index+1]
		eval anat=\${$index}
		echo "path to T1 file  : $anat"
		;;
	-dti)
		index=$[$index+1]
		eval dti=\${$index}
		echo "path to dti file  : $dti"
		;;
	-bvec)
		index=$[$index+1]
		eval bvec=\${$index}
		echo "path to bvec file  : $bvec"
		;;
	-bval)
		index=$[$index+1]
		eval bval=\${$index}
		echo "path to bval file  : $bval"
		;;
	-no-fs)
		do_fs=0
		echo "|-------> Disabled recon-all"
		;;
	-no-conn)
		do_conn=0
		echo "|-------> Disabled connectome"
		;;
	-N)
		Nfiber=`expr $index + 1`
		eval Nfiber=\${$Nfiber}
		echo "  |-------> Optional N : ${Nfiber}"
		index=$[$index+1]
		;;				
	esac
	index=$[$index+1]
done

## lance FS

if [ ${do_fs} -eq 1 ]
then
	echo "############"
	echo "## run FS ##"
	echo "############"

	echo "recon-all -all -sd $sd/$subj -subjid $subj -i $anat -nuintensitycor-3T"
	recon-all -all -sd $sd -subjid $subj -i $anat -nuintensitycor-3T
fi

echo "" >> $sd/$subj/LOG_pipeline.txt
echo "RUN ICTUS PREPROCESSING" >> $sd/$subj/LOG_pipeline.txt
echo "" >> $sd/$subj/LOG_pipeline.txt

echo "subject dir  : $sd" >> $sd/$subj/LOG_pipeline.txt
echo "subj : $subj" >> $sd/$subj/LOG_pipeline.txt
echo "path to T1 file  : $anat" >> $sd/$subj/LOG_pipeline.txt

touch $sd/$subj/LOG_pipeline.txt

echo "############" >> $sd/$subj/LOG_pipeline.txt
echo "## run FS ##" >> $sd/$subj/LOG_pipeline.txt
echo "############" >> $sd/$subj/LOG_pipeline.txt

sleep 5 

echo "#######################"
echo "## DTI Preprocessing ##"
echo "#### FA extraction ####"
echo "#######################"

mkdir $sd/$subj/orig
cp $dti $bvec $bval $sd/$subj/orig/

echo "" >> $sd/$subj/LOG_pipeline.txt
echo "" >> $sd/$subj/LOG_pipeline.txt
echo "#######################" >> $sd/$subj/LOG_pipeline.txt
echo "## DTI Preprocessing ##" >> $sd/$subj/LOG_pipeline.txt
echo "#### FA extraction ####" >> $sd/$subj/LOG_pipeline.txt
echo "#######################" >> $sd/$subj/LOG_pipeline.txt



echo "DTI_FA_ictus_64.sh  -sd $sd  -subj $subj"
echo "DTI_FA_ictus_64.sh  -sd $sd  -subj $subj"  >> $sd/$subj/LOG_pipeline.txt
DTI_FA_ictus_64.sh  -sd $sd  -subj $subj


if [ ${do_conn} -eq 1 ]
then

	echo "######################"
	echo "### Run Connectome ###"
	echo "######################"

	echo "" >> $sd/$subj/LOG_pipeline.txt
	echo "" >> $sd/$subj/LOG_pipeline.txt
	echo "######################" >> $sd/$subj/LOG_pipeline.txt
	echo "### Run Connectome ###" >> $sd/$subj/LOG_pipeline.txt
	echo "######################" >> $sd/$subj/LOG_pipeline.txt

	echo "labels=/NAS/dumbo/protocoles/ictus/Connectome/aparc2009LOI_ictus.txt" >> $sd/$subj/LOG_pipeline.txt
	labels=/NAS/dumbo/protocoles/ictus/Connectome/aparc2009LOI_ictus.txt

	mkdir $sd/$subj/dti_connectome

	echo "cp -f $sd/$subj/dti/data_corr.nii.gz $sd/$subj/dti_connectome"
	echo "cp -f $sd/$subj/dti/data_corr.nii.gz $sd/$subj/dti_connectome" >> $sd/$subj/LOG_pipeline.txt
	cp -f $sd/$subj/dti/data_corr.nii.gz $sd/$subj/dti_connectome

	echo "gunzip $sd/$subj/dti_connectome/data_corr.nii.gz"
	echo "gunzip $sd/$subj/dti_connectome/data_corr.nii.gz" >> $sd/$subj/LOG_pipeline.txt
	gunzip $sd/$subj/dti_connectome/data_corr.nii.gz

	echo "CMatrixVolume_mrtrix.sh -fs $sd -subj $subj -parcname aparc.a2009s+aseg.mgz -labels $labels -dti $sd/$subj/dti_connectome/data_corr.nii -bvecs $sd/$subj/dti/data.bvec -bvals $sd/$subj/dti/data.bval -outdir $sd/$subj/dti_connectome -N ${Nfiber}"
	echo "CMatrixVolume_mrtrix.sh -fs $sd -subj $subj -parcname aparc.a2009s+aseg.mgz -labels $labels -dti $sd/$subj/dti_connectome/data_corr.nii -bvecs $sd/$subj/dti/data.bvec -bvals $sd/$subj/dti/data.bval -outdir $sd/$subj/dti_connectome -N ${Nfiber}" >> $sd/$subj/LOG_pipeline.txt
	CMatrixVolume_mrtrix.sh -fs $sd -subj $subj -parcname aparc.a2009s+aseg.mgz -labels $labels -dti $sd/$subj/dti_connectome/data_corr.nii -bvecs $sd/$subj/dti/data.bvec -bvals $sd/$subj/dti/data.bval -outdir $sd/$subj/dti_connectome -N ${Nfiber}

	# Connectome - MD
	echo ""
	echo "MAP MD on connectome"
	echo ""

	echo "" >> $sd/$subj/LOG_pipeline.txt
	echo "MAP MD on connectome" >> $sd/$subj/LOG_pipeline.txt
	echo "" >> $sd/$subj/LOG_pipeline.txt

	echo "map_MD.sh $sd $subj 8 ${Nfiber}" >> $sd/$subj/LOG_pipeline.txt
	echo "map_MD.sh $sd $subj 8 ${Nfiber}"
	map_MD.sh $sd $subj 8 ${Nfiber}

	# Connectome - density
	echo ""
	echo "MAP density on connectome"
	echo ""

matlab -nodisplay <<EOF

	load(fullfile('$sd','$subj','dti_connectome',['Connectome_' '$subj' '.mat']));
	Connectome = computeMdensity(fullfile('$sd','$subj','dti_connectome','labels.nii'), [1 1 1], Connectome);
	Connectome.Mdensity = Connectome.Mdensity+Connectome.Mdensity';
	Connectome.Mdensity = full(Connectome.Mdensity);
	save(fullfile('$sd','$subj','dti_connectome',['Connectome_' '$subj' '.mat']),'Connectome','-v7.3');

EOF

fi
