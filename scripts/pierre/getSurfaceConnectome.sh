#!/bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: getSurfaceConnectome.sh  -fs  <SubjDir>  -subj  <SubjName>  [-surf_lh surface_lh_path  -surf_rh surface_rh_path  -fib fibre_filename  -out outfile_name  -log log_dir]"
	echo ""
	echo "  -fs SubjDir                  : Path to FS output directory (equivalent to SUBJECTS_DIR)"
	echo "  -subj SubjName               : Subject ID"
	echo " "
	echo "Options :"
	echo "  -surf_lh surface_lh_path     : Path to the left surface to use for the connectome."
	echo "                                  Default : SubjDir/SubjName/surf/lh.white"
	echo "  -surf_rh surface_rh_path     : Path to the right surface to use for the connectome."
	echo "                                  Default : SubjDir/SubjName/surf/rh.white"
	echo "  -fib     fibre_filename      : Name of the fiber file found in SubjDir/SubjName/dti"
	echo "                                  Default : whole_brain_6_1500000.tck or"
	echo "                                            whole_brain_6_1500000 if the fiber file was split"
	echo "  -out     outfile_name        : Name of the output matlab file stored in SubjDir/SubjName/dti"
	echo "                                  Default : Connectome.mat"
	echo "  -log     log_dir             : Path to the SGE log directory"
	echo "                                  Default : /NAS/dumbo/romain/log/"
	echo " "
	echo "Important : Pior to this script, the script PrepareSurfaceConnectome.sh must have been called"
	echo "            If you send the job on the queue system, do NOT use fs_q ! Use surf_q instead."
	echo "            -surf_lh and -surf_rh MUST BE used together. No connectome can be built using only lh or rh surface"
	echo ""
	echo "Usage: getSurfaceConnectome.sh  -fs  <SubjDir>  -subj  <SubjName>  [-surf_lh surface_lh_path  -surf_rh surface_rh_path  -fib fibre_filename  -out outfile_name  -log logdir]"
	exit 1
fi


#### Inputs ####
index=1
echo "------------------------"

# Set default parameters
fib_name="whole_brain_6_1500000"
out_name="Connectome.mat"
surf_lh_flag=0
surf_rh_flag=0
log_dir=/NAS/dumbo/romain/log/
#

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: getSurfaceConnectome.sh  -fs  <SubjDir>  -subj  <SubjName>  [-surf_lh surface_lh_path  -surf_rh surface_rh_path  -fib fibre_filename  -out outfile_name  -log log_dir]"
		echo ""
		echo "  -fs SubjDir                  : Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -subj SubjName               : Subject ID"
		echo " "
		echo "Options :"
		echo "  -surf_lh surface_lh_path     : Path to the left surface to use for the connectome."
		echo "                                  Default : SubjDir/SubjName/surf/lh.white"
		echo "  -surf_rh surface_rh_path     : Path to the right surface to use for the connectome."
		echo "                                  Default : SubjDir/SubjName/surf/rh.white"
		echo "  -fib     fibre_filename      : Name of the fiber file found in SubjDir/SubjName/dti"
		echo "                                  Default : whole_brain_6_1500000.tck or"
		echo "                                            whole_brain_6_1500000 if the fiber file was split"
		echo "  -out     outfile_name        : Name of the output matlab file stored in SubjDir/SubjName/dti"
		echo "                                  Default : Connectome.mat"
		echo "  -log     log_dir             : Path to the SGE log directory"
		echo "                                  Default : /NAS/dumbo/romain/log/"
		echo " "
		echo "Important : Pior to this script, the script PrepareSurfaceConnectome.sh must have been called"
		echo "            If you send the job on the queue system, do NOT use fs_q ! Use surf_q instead."
		echo "            -surf_lh and -surf_rh MUST BE used together. No connectome can be built using only lh or rh surface"
		echo ""
		echo "Usage: getSurfaceConnectome.sh  -fs  <SubjDir>  -subj  <SubjName>  [-surf_lh surface_lh_path  -surf_rh surface_rh_path  -fib fibre_filename  -out outfile_name  -log logdir]"
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
	-surf_lh)
		surf_lh=`expr $index + 1`
		eval surf_lh=\${$surf_lh}
		echo "  |-------> Optional surf_lh : ${surf_lh}"
		surf_lh_flag=1
		index=$[$index+1]
		;;
	-surf_rh)
		surf_rh=`expr $index + 1`
		eval surf_rh=\${$surf_rh}
		echo "  |-------> Optional surf_rh : ${surf_rh}"
		surf_rh_flag=1
		index=$[$index+1]
		;;
	-fib)
		fib_name=`expr $index + 1`
		eval fib_name=\${$fib_name}
		echo "  |-------> Optional fib_name : ${fib_name}"
		index=$[$index+1]
		;;
	-out)
		out_name=`expr $index + 1`
		eval out_name=\${$out_name}
		echo "  |-------> Optional out_name : ${out_name}"
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

DTI=${DIR}/dti
if [ ! -e ${DTI} ]
then
	echo "Can not find ${DTI} directory"
	exit 1
fi

for_dti=${DTI}/dti.nii.gz
if [ ! -e ${for_dti} ]
then
	echo "Can not find file ${for_dti}"
	exit 1
fi

bval=${DTI}/dti.bval
if [ ! -e ${bval} ]
then
	echo "Can not find file ${bval}"
	exit 1
fi

bvec=${DTI}/dti.bvec
if [ ! -e ${bvec} ]
then
	echo "Can not find file ${bvec}"
	exit 1
fi

if [ ${surf_lh_flag} -eq 0 ]
then
	if [ ! -e ${DIR}/surf/lh.white.ras ]
	then
		echo "Can not find ${DIR}/surf/lh.white.ras"
		exit 1
	fi
	surf_lh=${DIR}/surf/lh.white.ras
fi

if [ ${surf_rh_flag} -eq 0 ]
then
	if [ ! -e ${DIR}/surf/rh.white.ras ]
	then
		echo "Can not find ${DIR}/surf/rh.white.ras"
		exit 1
	fi
	surf_rh=${DIR}/surf/rh.white.ras
fi

fibers=${DTI}/${fib_name}
if [ ! -e ${fibers} -a ! -e ${fibers}_part000001.tck ]
then
	echo "Can not find files ${fibers} and ${fibers}_part000001.tck"
	exit 1
fi

ref_vol=${DTI}/t1_native_ras.nii
if [ ! -e ${ref_vol}.gz -a ! -e ${ref_vol} ]
then
	echo "Can not find files ${ref_vol}.gz and ${ref_vol}"
	exit 1
fi
if [ -e ${ref_vol}.gz ]
then
	gunzip -f ${ref_vol}.gz
fi

dti_vol=${DTI}/t1_dti_ras.nii
if [ ! -e ${dti_vol}.gz -a ! -e ${dti_vol} ]
then
	echo "Can not find files ${dti_vol}.gz and ${dti_vol}"
	exit 1
fi
if [ -e ${dti_vol}.gz ]
then
	gunzip -f ${dti_vol}.gz
fi

if [ ! -e ${log_dir} ]
then
	echo "Can not find ${log_dir} directory"
	exit 1
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
		if [ ! -e ${DTI}/${out_split_name} ]
		then
			echo "qbatch -N Split_${i} -oe ${log_dir} -q  three_job_q getSurfaceConnectome.sh -fs ${fs} -subj ${subj} -fib ${split_name} -out ${out_split_name} -surf_lh ${surf_lh} -surf_rh ${surf_rh}"
			TEMP=`qbatch -N Split_q_${i} -oe ${log_dir} -q three_job_q getSurfaceConnectome.sh -fs ${fs} -subj ${subj} -fib ${split_name} -out ${out_split_name} -surf_lh ${surf_lh} -surf_rh ${surf_rh}`
			TEMP=`echo ${TEMP} | awk '{print $3}'`
			if [ -z "${JOB_ID}" ]
			then
				JOB_ID="-j ${TEMP}"
			else
				JOB_ID="${JOB_ID},${TEMP}"
			fi
			sleep 0.5
		else
			echo "${out_split_name} found"
		fi
		i=$[$i+1]
	done
	
	echo "PostProcessSurfaceConnectome.sh -fs ${fs} -subj ${subj} -mat_name ${out_name%.mat}"
	qbatch ${JOB_ID} -N pps_${subj} -oe ${log_dir} -q fs_q PostProcessSurfaceConnectome.sh -fs ${fs} -subj ${subj} -mat_name ${out_name%.mat}
	
else
	# No corresponding split found, launch job locally
matlab -nodisplay <<EOF
Connectome = getFastTriangleConnectMat('${surf_lh}', '${surf_rh}', '${fibers}', '${ref_vol}', '${dti_vol}');
save ${DTI}/${out_name} Connectome -v7.3
EOF

# gzip -f ${ref_vol} ${dti_vol}

fi
