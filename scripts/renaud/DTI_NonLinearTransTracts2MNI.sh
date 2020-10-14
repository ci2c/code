#!/bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: DTI_NonLinearTransTracts2MNI.sh  -fs  <SubjDir>  -subj  <SubjName>  [-dtifolder <name>  -fib fibre_filename  -out <out_folder>  -log <log_dir>]"
	echo ""
	echo "  -fs SubjDir                  : Path to FS output directory (equivalent to SUBJECTS_DIR)"
	echo "  -subj SubjName               : Subject ID"
	echo " "
	echo "Options :"
	echo "  -dtifolder dti_folder        : Path to the dti folder."
	echo "                                  Default : dti"
	echo "  -fib     fibre_filename      : Name of the fiber file found in SubjDir/SubjName/dti_folder"
	echo "                                  Default : whole_brain_6_1500000.tck or"
	echo "                                            whole_brain_6_1500000 if the fiber file was split"
	echo "  -out     output_folder       : Name of the output folder stored in SubjDir/SubjName/dti_folder"
	echo "                                  Default : MNIspace"
	echo "  -log     log_dir             : Path to the SGE log directory"
	echo "                                  Default : SubjDir/SubjName/dti_folder/MNIspace/temp_rand"
	echo " "
	echo "Important : Pior to this script, the script PrepareSurfaceConnectome.sh must have been called"
	echo "            If you send the job on the queue system, do NOT use fs_q ! Use surf_q instead."
	echo ""
	echo "Usage: DTI_NonLinearTransTracts2MNI.sh  -fs  <SubjDir>  -subj  <SubjName>  [-dtifolder <name>  -fib fibre_filename  -out <out_folder>  -log <log_dir>]"
	exit 1
fi

#### Inputs ####
index=1
echo "------------------------"

# Set default parameters
dti_folder="dti"
fib_name="whole_brain_6_1500000"
outdir="MNIspace"
RES=1
log_dir="default"
#

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: DTI_NonLinearTransTracts2MNI.sh  -fs  <SubjDir>  -subj  <SubjName>  [-dtifolder <name>  -fib fibre_filename  -out <out_folder>  -log <log_dir>]"
		echo ""
		echo "  -fs SubjDir                  : Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -subj SubjName               : Subject ID"
		echo " "
		echo "Options :"
		echo "  -dtifolder dti_folder        : Path to the dti folder."
		echo "                                  Default : dti"
		echo "  -fib     fibre_filename      : Name of the fiber file found in SubjDir/SubjName/dti_folder"
		echo "                                  Default : whole_brain_6_1500000.tck or"
		echo "                                            whole_brain_6_1500000 if the fiber file was split"
		echo "  -out     output_folder       : Name of the output folder stored in SubjDir/SubjName/dti_folder"
		echo "                                  Default : MNIspace"
		echo "  -log     log_dir             : Path to the SGE log directory"
		echo "                                  Default : SubjDir/SubjName/dti_folder/MNIspace/temp_rand"
		echo " "
		echo "Important : Pior to this script, the script PrepareSurfaceConnectome.sh must have been called"
		echo "            If you send the job on the queue system, do NOT use fs_q ! Use surf_q instead."
		echo ""
		echo "Usage: DTI_NonLinearTransTracts2MNI.sh  -fs  <SubjDir>  -subj  <SubjName>  [-dtifolder <name>  -fib fibre_filename  -out <out_folder>  -log <log_dir>]"
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
		outdir=`expr $index + 1`
		eval outdir=\${$outdir}
		echo "  |-------> Optional out folder : ${outdir}"
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

fibers=${DTI}/${fib_name}
if [ ! -e ${fibers} -a ! -e ${fibers}_part000001.tck ]
then
	echo "Can not find files ${fibers} and ${fibers}_part000001.tck"
	exit 1
fi

OUTPUT=${DTI}/${outdir}
if [ ! -e ${OUTPUT} ]
then
	echo "Create ${OUTPUT} directory"
	mkdir ${OUTPUT}
fi

if [ ! -e ${log_dir} ]
then
	echo "Can not find ${log_dir} directory"
	log_dir=`mktemp -d -p "$OUTPUT"`
	echo "New log dir: ${log_dir}" 
fi

out_name=${fib_name%.tck}".mat"


#--------------------------------------------------------------------------
#                                Preprocess
#--------------------------------------------------------------------------

# dti reference
dti_vol=${OUTPUT}/rwm_mask_dti.nii
if [ ! -e ${dti_vol} ]
then
	cp ${DTI}/rwm_mask_dti.nii.gz ${OUTPUT}/
	gunzip -f ${OUTPUT}/rwm_mask_dti.nii.gz
fi

# native T1 in diffusion space
t1_natif=${OUTPUT}/rt1_dti_ras.nii
if [ ! -f ${t1_natif} ]
then
	cp ${DTI}/t1_dti_ras.nii.gz ${OUTPUT}/
	gunzip -f ${OUTPUT}/t1_dti_ras.nii.gz
matlab -nodisplay <<EOF

% Load Matlab Path
cd ${HOME}
p = pathdef;
addpath(p);
spm_get_defaults;
spm_jobman('initcfg');
matlabbatch = {};
matlabbatch{1}.spm.spatial.coreg.write.ref = {'${dti_vol}'};
matlabbatch{1}.spm.spatial.coreg.write.source = {'${OUTPUT}/t1_dti_ras.nii,1'};
matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 0;
matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.coreg.write.roptions.mask = 0;
matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'r';
spm_jobman('run',matlabbatch);

EOF
fi

# Transformation: T1 in diffusion space into MNI space
transf=${OUTPUT}/y_t1_dti_ras.nii
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

matlabbatch{1}.spm.spatial.normalise.est.subj.vol          = {'${OUTPUT}/t1_dti_ras.nii,1'};
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

# T1 in diffusion space into MNI space
t1_mni=${OUTPUT}/wt1_dti_ras.nii
if [ ! -e ${t1_mni} ]
then

matlab -nodisplay <<EOF

% Load Matlab Path
cd ${HOME}
p = pathdef;
addpath(p);
spm_get_defaults;
spm_jobman('initcfg');
matlabbatch = {};
matlabbatch{1}.spm.spatial.normalise.write.subj.def        = {'${transf}'};
matlabbatch{1}.spm.spatial.normalise.write.subj.resample   = {'${OUTPUT}/t1_dti_ras.nii,1'};
matlabbatch{1}.spm.spatial.normalise.write.woptions.bb     = [-78 -112 -70; 78 76 85];
matlabbatch{1}.spm.spatial.normalise.write.woptions.vox    = ${RES}*ones(1,3);
matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 0;
matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'w';
spm_jobman('run',matlabbatch);

EOF
fi


# Test if the fiber file was split
if [ -e ${fibers}_part000001.tck ]
then
	# Fiber file was split : launch jobs on the cluster
	i=1
	JOB_ID=""
	for Split in `ls ${fibers}_part*.tck`
	do
		split_name=`basename ${Split}`
		out_split_name=`printf "%.6d" "$i"`
		out_split_name=${out_name%.mat}_part${out_split_name}.mat
		echo ${out_split_name}
		echo ${Split}
		echo ${OUTPUT}
		if [ ! -e ${OUTPUT}/${out_split_name} ]
		then
			echo "qbatch -N split_${i} -oe ${log_dir} -q two_job_q DTI_NonLinearTransTracts2MNI.sh -fs ${fs} -subj ${subj} -dtifolder ${dti_folder} -fib ${split_name} -out ${outdir} -log ${log_dir}"
			TEMP=`qbatch -N split_${i} -oe ${log_dir} -q two_job_q DTI_NonLinearTransTracts2MNI.sh -fs ${fs} -subj ${subj} -dtifolder ${dti_folder} -fib ${split_name} -out ${outdir} -log ${log_dir}`
			TEMP=`echo ${TEMP} | awk '{print $3}'`
			if [ -z "${JOB_ID}" ]
			then
				JOB_ID="-j ${TEMP}"
			else
				JOB_ID="${JOB_ID},${TEMP}"
			fi
			sleep 3
		else
			echo "${out_split_name} found"
		fi
		i=$[$i+1]
	done
	
	echo "DTI_PostProcessTracts2MNI.sh -i ${OUTPUT} -mat_name ${out_name%.mat}"
	#qbatch ${JOB_ID} -N postproc_split -oe ${log_dir} -q M64_q /home/renaud/SVN/scripts/renaud/DTI_PostProcessTracts2MNI.sh -i ${OUTPUT} -mat_name ${out_name%.mat}
	
else
	# No corresponding split found, launch job locally

matlab -nodisplay <<EOF

'${dti_vol}'
'${transf}'
'${fibers}'
'${t1_natif}'
'${t1_mni}'
'${OUTPUT}/${out_name}'

opt = struct('interp',0,'voxinit',${RES}*ones(1,3),'bbinit',[-78 -112 -70; 78 76 85],'thresh',0);
opt

[fibmni,posc_new,posc_orig,mbeg,mend] = DTI_NonLinearTransTracts2MNI('${dti_vol}','${transf}','${fibers}','${t1_natif}','${t1_mni}',opt);
save('${OUTPUT}/${out_name}','fibmni','posc_new','posc_orig','mbeg','mend','-v7.3');

EOF

# gzip -f ${ref_vol} ${dti_vol}

fi
