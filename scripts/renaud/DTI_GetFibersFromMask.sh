#!/bin/bash

if [ $# -lt 6 ]
then
	echo ""
	echo "Usage: DTI_GetFibersFromMask.sh  -fs  <SubjDir>  -subj  <SubjName>  -mask <mask_path>  [-dtifolder <name>  -fib fibre_filename  -out <out_folder>  -log <log_dir>]"
	echo ""
	echo "  -fs SubjDir                  : Path to FS output directory (equivalent to SUBJECTS_DIR)"
	echo "  -subj SubjName               : Subject ID"
	echo "  -mask SubjName               : mask path (.nii)"
	echo " "
	echo "Options :"
	echo "  -dtifolder dti_folder        : Path to the dti folder."
	echo "                                  Default : dti"
	echo "  -fib     fibre_filename      : Name of the fiber file found in SubjDir/SubjName/dti_folder"
	echo "                                  Default : whole_brain_6_1500000.tck or"
	echo "                                            whole_brain_6_1500000 if the fiber file was split"
	echo "  -out     output_folder       : Name of the output structure stored in SubjDir/SubjName/dti_folder"
	echo "                                  Default : MaskFibers.mat"
	echo "  -log     log_dir             : Path to the SGE log directory"
	echo "                                  Default : SubjDir/SubjName/dti_folder/temp_rand"
	echo " "
	echo "Important : Pior to this script, the script PrepareSurfaceConnectome.sh must have been called"
	echo "            If you send the job on the queue system, do NOT use fs_q ! Use surf_q instead."
	echo ""
	echo "Usage: DTI_GetFibersFromMask.sh  -fs  <SubjDir>  -subj  <SubjName>  -mask <mask_path>  [-dtifolder <name>  -fib fibre_filename  -out <out_folder>  -log <log_dir>]"
	exit 1
fi

#### Inputs ####
index=1
echo "------------------------"

# Set default parameters
dti_folder="dti"
fib_name="whole_brain_6_1500000"
outname="MaskFibers.mat"
RES=1
log_dir="default"
#

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: DTI_GetFibersFromMask.sh  -fs  <SubjDir>  -subj  <SubjName>  -mask <mask_path>  [-dtifolder <name>  -fib fibre_filename  -out <out_folder>  -log <log_dir>]"
		echo ""
		echo "  -fs SubjDir                  : Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -subj SubjName               : Subject ID"
		echo "  -mask SubjName               : mask path (.nii)"
		echo " "
		echo "Options :"
		echo "  -dtifolder dti_folder        : Path to the dti folder."
		echo "                                  Default : dti"
		echo "  -fib     fibre_filename      : Name of the fiber file found in SubjDir/SubjName/dti_folder"
		echo "                                  Default : whole_brain_6_1500000.tck or"
		echo "                                            whole_brain_6_1500000 if the fiber file was split"
		echo "  -out     output_folder       : Name of the output structure stored in SubjDir/SubjName/dti_folder"
		echo "                                  Default : MaskFibers.mat"
		echo "  -log     log_dir             : Path to the SGE log directory"
		echo "                                  Default : SubjDir/SubjName/dti_folder/temp_rand"
		echo " "
		echo "Important : Pior to this script, the script PrepareSurfaceConnectome.sh must have been called"
		echo "            If you send the job on the queue system, do NOT use fs_q ! Use surf_q instead."
		echo ""
		echo "Usage: DTI_GetFibersFromMask.sh  -fs  <SubjDir>  -subj  <SubjName>  -mask <mask_path>  [-dtifolder <name>  -fib fibre_filename  -out <out_folder>  -log <log_dir>]"
		exit 1
		;;
	-fs)
		fs=`expr $index + 1`
		eval fs=\${$fs}
		echo "  |-------> SubjDir : $fs"
		index=$[$index+1]
		;;
	-subj)
		subj=`expr $index + 1`
		eval subj=\${$subj}
		echo "  |-------> Subject Name : ${subj}"
		index=$[$index+1]
		;;
	-mask)
		mask=`expr $index + 1`
		eval mask=\${$mask}
		echo "  |-------> Mask file : ${mask}"
		index=$[$index+1]
		;;
	-dtifolder)
		dti_folder=`expr $index + 1`
		eval dti_folder=\${$dti_folder}
		echo "  |-------> Optional dti folder : ${dti_folder}"
		index=$[$index+1]
		;;
	-fib)
		fib_name=`expr $index + 1`
		eval fib_name=\${$fib_name}
		echo "  |-------> Optional fib_name : ${fib_name}"
		index=$[$index+1]
		;;
	-out)
		outname=`expr $index + 1`
		eval outname=\${$outname}
		echo "  |-------> Optional out name : ${outname}"
		index=$[$index+1]
		;;
	-log)
		log_dir=`expr $index + 1`
		eval log_dir=\${$log_dir}
		echo "  |-------> Optional log_dir : ${log_dir}"
		index=$[$index+1]
		;;
	-*)
		TEMP=`expr $index`
		eval TEMP=\${$TEMP}
		echo "${TEMP} : unknown argument"
		echo ""
		echo "Enter $0 -help for help"
		exit 1
		;;
	esac
	index=$[$index+1]
done
#################

# Check inputs
DIR=${fs}/${subj}
if [ ! -e ${DIR} ]
then
	echo "Can not find ${DIR} directory"
	exit 1
fi

DTI=${DIR}/${dti_folder}
if [ ! -e ${DTI} ]
then
	echo "Can not find ${DTI} directory"
	exit 1
fi

if [ ! -e ${mask} ]
then
	echo "Can not find ${mask} file"
	exit 1
fi

fibers=${DTI}/${fib_name}
if [ ! -e ${fibers} -a ! -e ${fibers}_part000001.tck ]
then
	echo "Can not find files ${fibers} and ${fibers}_part000001.tck"
	exit 1
fi

OUTPUT=${DTI}/${outname}
if [ -e ${OUTPUT} ]
then
	rm -f ${OUTPUT}
fi

#if [ ! -e ${log_dir} ]
#then
#	echo "Can not find ${log_dir} directory"
#	log_dir=`mktemp -d -p "$OUTPUT"`
#	echo "New log dir: ${log_dir}" 
#fi


# Transformation: T1 in diffusion space into MNI space
transf=${DTI}/y_t1_dti_ras.nii
if [ ! -e ${transf} ]
then

matlab -nodisplay <<EOF

% Load Matlab Path
cd ${HOME}
p = pathdef;
addpath(p);
spm_get_defaults;
spm_jobman('initcfg');
matlabbatch = {};

[p,n,e]=fileparts(which('spm.m'));

matlabbatch{1}.spm.spatial.normalise.est.subj.vol          = {'${DTI}/t1_dti_ras.nii,1'};
matlabbatch{1}.spm.spatial.normalise.est.eoptions.biasreg  = 0.0001;
matlabbatch{1}.spm.spatial.normalise.est.eoptions.biasfwhm = 60;
matlabbatch{1}.spm.spatial.normalise.est.eoptions.tpm      = {fullfile(p,'tpm/TPM.nii')};
matlabbatch{1}.spm.spatial.normalise.est.eoptions.affreg   = 'mni';
matlabbatch{1}.spm.spatial.normalise.est.eoptions.reg      = [0 0.001 0.5 0.05 0.2];
matlabbatch{1}.spm.spatial.normalise.est.eoptions.fwhm     = 0;
matlabbatch{1}.spm.spatial.normalise.est.eoptions.samp     = 3;
spm_jobman('run',matlabbatch);

EOF
fi


