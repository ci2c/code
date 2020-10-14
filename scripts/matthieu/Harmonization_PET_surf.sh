#!/bin/bash

if [ $# -lt 8 ]
then
	echo ""
	echo "Usage:  Harmonization_PET_surf.sh  -idPet <inputdir_pet> -sd <SUBJECTS_DIR> -subjMri <SUBJECT_ID_MRI> -recon <Reconstruction> [ -v <FSVersion> -sx <resample_x> -sy <resample_y> -sz <resample_z> -DoInit -DoReg -DoPVC -DoIN -DoSBA -oldSeg ]"
	echo ""
	echo "	-idPet		: Input raw Pet data directory "
	echo "  -sd		: FreeSurfer subjects directory "
	echo "  -subjMri       	: FreeSurfer subject name "
	echo "  -v              : Version of FreeSurfer used"
	echo "  -sx             : Size of x PET resample (default :1 mm)"
	echo "  -sy             : Size of y PET resample (default :1 mm)"
	echo "  -sz             : Size of z PET resample (default :1 mm)"
	echo "  -DoInit         : Do Initialization step "
	echo "  -DoReg          : Do rigid-body registration of PET on orig.mgz with bbregister "
	echo "  -DoPVC          : Compute partial volume correction with Muller-Gartner/Rousset based method "
	echo "  -DoIN           : Apply intensity normalization "
	echo "  -DoSBA          : Do surface-based analysis "
	echo "  -oldSeg         : Do SPM8 New Segment (else SPM12 Segment) "
	echo "  -recon          : Name of the PET reconstruction "
	echo ""
	echo "Usage:  Harmonization_PET_surf.sh  -idPet <inputdir_pet> -sd <SUBJECTS_DIR> -subjMri <SUBJECT_ID_MRI> -recon <Reconstruction> [ -v <FSVersion> -sx <resample_x> -sy <resample_y> -sz <resample_z> -DoInit -DoReg -DoPVC -DoIN -DoSBA -oldSeg ]"
	echo ""
	echo "Author: Matthieu Vanhoutte - CHRU Lille - August 2017"
	echo ""
	exit 1
fi

index=1
FS_VERSION=5.3
DoInit=0
DoReg=0
oldSeg=0
DoPVC=0
DoIN=0
DoSBA=0
size_x=1
size_y=1
size_z=1

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage:  Harmonization_PET_surf.sh  -idPet <inputdir_pet> -sd <SUBJECTS_DIR> -subjMri <SUBJECT_ID_MRI> -recon <Reconstruction> [ -v <FSVersion> -sx <resample_x> -sy <resample_y> -sz <resample_z> -DoInit -DoReg -DoPVC -DoIN -DoSBA -oldSeg ]"
		echo ""
		echo "	-idPet		: Input raw Pet data directory "
		echo "  -sd		: FreeSurfer subjects directory "
		echo "  -subjMri       	: FreeSurfer subject name "
		echo "  -v              : Version of FreeSurfer used"
		echo "  -sx             : Size of x PET resample (default :1 mm)"
		echo "  -sy             : Size of y PET resample (default :1 mm)"
		echo "  -sz             : Size of z PET resample (default :1 mm)"
		echo "  -DoInit         : Do Initialization step "
		echo "  -DoReg          : Do rigid-body registration of PET on orig.mgz with bbregister "
		echo "  -DoPVC          : Compute partial volume correction with Muller-Gartner/Rousset based method "
		echo "  -DoIN           : Apply intensity normalization "
		echo "  -DoSBA          : Do surface-based analysis "
		echo "  -oldSeg         : Do SPM8 New Segment (else SPM12 Segment) "
		echo "  -recon          : Name of the PET reconstruction "
		echo ""
		echo "Usage:  Harmonization_PET_surf.sh  -idPet <inputdir_pet> -sd <SUBJECTS_DIR> -subjMri <SUBJECT_ID_MRI> -recon <Reconstruction> [ -v <FSVersion> -sx <resample_x> -sy <resample_y> -sz <resample_z> -DoInit -DoReg -DoPVC -DoIN -DoSBA -oldSeg ]"
		echo ""
		echo "Author: Matthieu Vanhoutte - CHRU Lille - August 2017"
		echo ""
		exit 1
		;;
	-idPet)
		index=$[$index+1]
		eval INPUT_PET_DIR=\${$index}
		echo "input Pet data directory: ${INPUT_PET_DIR}"
		;;	
	-sd)
		index=$[$index+1]
		eval SUBJECTS_DIR=\${$index}
		echo "FreeSurfer subjects directory : ${SUBJECTS_DIR}"
		;;
	-subjMri)
		index=$[$index+1]
		eval SUBJECT_ID=\${$index}
		echo "FreeSurfer subject name : ${SUBJECT_ID}"
		;;
	-v)
		index=$[$index+1]
		eval FS_VERSION=\${$index}
		echo "Version of FS used : ${FS_VERSION}"
		;;
	-sx)
		index=$[$index+1]
		eval size_x=\${$index}
		echo "Size of x PET resample : ${size_x}"
		;;
	-sy)
		index=$[$index+1]
		eval size_y=\${$index}
		echo "Size of y PET resample : ${size_y}"
		;;
	-sz)
		index=$[$index+1]
		eval size_z=\${$index}
		echo "Size of z PET resample : ${size_z}"
		;;
	-DoInit)
		DoInit=1
		echo "Do Initialization step"
		;;
	-DoReg)
		DoReg=1
		echo "Do rigid-body registration of PET on orig.mgz with bbregister"
		;;
	-DoPVC)
		DoPVC=1
		echo "Compute partial volume correction with Muller-Gartner based method"
		;;
	-DoIN)
		DoIN=1
		echo "Apply intensity normalization"
		;;
	-DoSBA)
		DoSBA=1
		echo "Do surface-based analysis"
		;;
	-oldSeg)
		oldSeg=1
		echo "Do SPM8 new Segment"
		;;
	-recon)
		index=$[$index+1]
		eval RECON=\${$index}
		echo "Name of the PET reconstruction : ${RECON}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo ""
		echo ""
		echo ""
		echo "Usage:  Harmonization_PET_surf.sh  -idPet <inputdir_pet> -sd <SUBJECTS_DIR> -subjMri <SUBJECT_ID_MRI> -recon <Reconstruction> [ -v <FSVersion> -sx <resample_x> -sy <resample_y> -sz <resample_z> -DoInit -DoReg -DoPVC -DoIN -DoSBA -oldSeg ]"
		echo ""
		echo "	-idPet		: Input raw Pet data directory "
		echo "  -sd		: FreeSurfer subjects directory "
		echo "  -subjMri       	: FreeSurfer subject name "
		echo "  -v              : Version of FreeSurfer used"
		echo "  -sx             : Size of x PET resample (default :1 mm)"
		echo "  -sy             : Size of y PET resample (default :1 mm)"
		echo "  -sz             : Size of z PET resample (default :1 mm)"
		echo "  -DoInit         : Do Initialization step "
		echo "  -DoReg          : Do rigid-body registration of PET on orig.mgz with bbregister "
		echo "  -DoPVC          : Compute partial volume correction with Muller-Gartner/Rousset based method "
		echo "  -DoIN           : Apply intensity normalization "
		echo "  -DoSBA          : Do surface-based analysis "
		echo "  -oldSeg         : Do SPM8 New Segment (else SPM12 Segment) "
		echo "  -recon          : Name of the PET reconstruction "
		echo ""
		echo "Usage:  Harmonization_PET_surf.sh  -idPet <inputdir_pet> -sd <SUBJECTS_DIR> -subjMri <SUBJECT_ID_MRI> -recon <Reconstruction> [ -v <FSVersion> -sx <resample_x> -sy <resample_y> -sz <resample_z> -DoInit -DoReg -DoPVC -DoIN -DoSBA -oldSeg ]"
		echo ""
		echo "Author: Matthieu Vanhoutte - CHRU Lille - August 2017"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${INPUT_PET_DIR} ]
then
	 echo "-idPet argument mandatory"
	 exit 1
fi
if [ -z ${SUBJECTS_DIR} ]
then
	 echo "-sd argument mandatory"
	 exit 1
fi
if [ -z ${SUBJECT_ID} ]
then
	 echo "-subjMri argument mandatory"
	 exit 1
fi
if [ -z ${RECON} ]
then
	 echo "-recon argument mandatory"
	 exit 1
fi

## Set up FSL (if not already done so in the running environment) ##
FSLDIR=${Soft_dir}/fsl50
. ${FSLDIR}/etc/fslconf/fsl.sh

## Set up FreeSurfer (if not already done so in the running environment) ##
if [ "${FS_VERSION}" == "5.3" ]
then
	export FREESURFER_HOME=${Soft_dir}/freesurfer5.3/
	export FSFAST_HOME=${Soft_dir}/freesurfer5.3/fsfast
	export MNI_DIR=${Soft_dir}/freesurfer5.3/mni
	. ${FREESURFER_HOME}/SetUpFreeSurfer.sh
elif [ "${FS_VERSION}" == "6b" ]
then
	export FREESURFER_HOME=${Soft_dir}/freesurfer6_b/
	export FSFAST_HOME=${Soft_dir}/freesurfer6_b/fsfast
	export MNI_DIR=${Soft_dir}/freesurfer6_b/mni
	. ${FREESURFER_HOME}/SetUpFreeSurfer.sh
fi

DIR=${SUBJECTS_DIR}/${SUBJECT_ID}

if [ ${oldSeg} -eq 1 ]
then
	pvedir=pvelab_Seg8_l0
elif [ ${oldSeg} -eq 0 ]
then
	pvedir=pvelab_Seg12_l0
fi

#  ========================================================================================================================================
#                                                        INITIALIZATION
# ========================================================================================================================================

if [ $DoInit -eq 1 ]
then
	if [ -d ${DIR}/pet_std/${RECON} ]
	then
	    rm -rf ${DIR}/pet_std/${RECON}/*
	else
	    mkdir -p ${DIR}/pet_std/${RECON}
	fi
	
	# Extract SUBJECT_ID_PET from SUBJECT_ID and get TP number
	SUBJECT_ID_PET=${SUBJECT_ID:0:6}
	echo "ID SUBJ: ${SUBJECT_ID_PET}"
	if [ “${SUBJECT_ID_PET}” == “207047” ] || [ “${SUBJECT_ID_PET}” == “207050” ]
	then
		if [ “${SUBJECT_ID:0:7}” == “${SUBJECT_ID_PET}b” ]
		then
			SUBJECT_ID_PET="${SUBJECT_ID_PET}bis"
			TP=${SUBJECT_ID:10:2}
		else
			TP=${SUBJECT_ID:7:2}
		fi
	else
		TP=${SUBJECT_ID:7:2}
	fi
	echo "TP : $TP"
	
	# Copy from Siemens PET data
	if [ -f ${INPUT_PET_DIR}/${SUBJECT_ID_PET}/${TP}_*/DICOMS-${RECON}/*TOF_000_000_ctm_v.nii.gz ]
	then
		echo "mri_convert ${INPUT_PET_DIR}/${SUBJECT_ID_PET}/${TP}_*/DICOMS-${RECON}/*TOF_000_000_ctm_v.nii.gz ${DIR}/pet_std/${RECON}/PET.lps.nii.gz"
		mri_convert ${INPUT_PET_DIR}/${SUBJECT_ID_PET}/${TP}_*/DICOMS-${RECON}/*TOF_000_000_ctm_v.nii.gz ${DIR}/pet_std/${RECON}/PET.lps.nii.gz
	else
		echo "${INPUT_PET_DIR}/${SUBJECT_ID_PET}/${TP}_*/DICOMS-${RECON}/*TOF_000_000_ctm_v.nii.gz doesn't exist"
		exit 1
	fi
	
	# Check LPS orientation of raw PET data
	Orientation=$(mri_info ${DIR}/pet_std/${RECON}/PET.lps.nii.gz | grep "Orientation" | awk '{print $3}')	
	if [ "${Orientation}" != "LPS" ]
	then
		echo "PET not in native LPS orientation"
		exit 1
	fi
	
	# Reorient native Siemens PET data to better fit TPM (SPM8/SPM12)
	if [ -f ${DIR}/pet/PET.lps.nii.gz ]
	then
		cp ${DIR}/pet/PET.lps.nii.gz ${DIR}/pet_std/${RECON}/PET.lps.orig.nii.gz
		gunzip ${DIR}/pet_std/${RECON}/PET.lps.orig.nii.gz ${DIR}/pet_std/${RECON}/PET.lps.nii.gz
		
		matlab -nodisplay <<EOF
		%% Load Matlab Path: Matlab 14 and SPM12 needed
		cd ${HOME}
		p = pathdef14_SPM12;
		addpath(p);
		
		%% Compute translation to apply
		V = spm_vol('${DIR}/pet_std/${RECON}/PET.lps.nii');
		W = spm_vol('${DIR}/pet_std/${RECON}/PET.lps.orig.nii');
		
		transl = W.mat(1:3,4)-V.mat(1:3,4);
		
		%% Init of spm_jobman
		spm('defaults', 'PET');
		spm_jobman('initcfg');
		matlabbatch={};
			
		%% Reorient PET image near TPM
		matlabbatch{end+1}.spm.util.reorient.srcfiles = {
								  '${DIR}/pet_std/${RECON}/PET.lps.nii,1'
								};
		matlabbatch{end}.spm.util.reorient.transform.transM = [1 0 0 transl(1)
								      0 1 0 transl(2)
								      0 0 1 transl(3)
								      0 0 0 1];
		matlabbatch{end}.spm.util.reorient.prefix = '';
			
		spm_jobman('run',matlabbatch);
EOF
		gzip ${DIR}/pet_std/${RECON}/PET.lps.orig.nii ${DIR}/pet_std/${RECON}/PET.lps.nii
	else
		echo "${DIR}/pet/PET.lps.nii.gz doesn't exist"
		exit 1
	fi
fi

# ========================================================================================================================================
#                                     Upsampled PET to 1x1x1mm and copy rigid transformation matrix PET/MRI
# ========================================================================================================================================

if [ $DoReg -eq 1 ] && [ ! -f ${DIR}/pet_std/${RECON}/Pet2T1.BS7.register.dof6.dat ]
then
	# Reslice PET to 1x1x1mm resolution with trilinear interpolation
	mri_convert ${DIR}/pet_std/${RECON}/PET.lps.nii.gz ${DIR}/pet_std/${RECON}/PET.lps.lin.nii.gz -vs ${size_x} ${size_y} ${size_z} -rt interpolate
		
	# Crop FOV to 256
	mri_convert --cropsize 256 256 256 ${DIR}/pet_std/${RECON}/PET.lps.lin.nii.gz ${DIR}/pet_std/${RECON}/PET.lps.lin.nii.gz
		
	# Reslice PET to 1x1x1mm resolution with B-spline 7th (SPM) (!! Shift de -0.155 selon z entre ${DIR}/pet_std/${RECON}/PET.lps.nii.gz et ${DIR}/pet_std/${RECON}/PET.lps.lin.nii.gz !!)
	gunzip ${DIR}/pet_std/${RECON}/PET.lps.nii.gz ${DIR}/pet_std/${RECON}/PET.lps.lin.nii.gz
	matlab -nodisplay <<EOF
		
		%% Load Matlab Path: Matlab 14 and SPM8 version
		cd ${HOME}
		p = pathdef14_SPM8;
		addpath(p);

		%% Init of spm_jobman
		spm('defaults', 'PET');
		spm_jobman('initcfg');
		matlabbatch={};
			
		%% Step 1. Reslice PET.lps.nii with B-spline 7th interpolation
		matlabbatch{end+1}.spm.spatial.realign.write.data = {
								    '${DIR}/pet_std/${RECON}/PET.lps.lin.nii,1'
								    '${DIR}/pet_std/${RECON}/PET.lps.nii,1'
								};
		matlabbatch{end}.spm.spatial.realign.write.roptions.which = [1 0];
		matlabbatch{end}.spm.spatial.realign.write.roptions.interp = 7;
		matlabbatch{end}.spm.spatial.realign.write.roptions.wrap = [0 0 0];
		matlabbatch{end}.spm.spatial.realign.write.roptions.mask = 0;
		matlabbatch{end}.spm.spatial.realign.write.roptions.prefix = 'BS7_';

		spm_jobman('run',matlabbatch);
			
		%% Step 2. Remove NaN and negative values in BS7_PET.lps.nii
		V = spm_vol('${DIR}/pet_std/${RECON}/BS7_PET.lps.nii');
		[Y, XYZ] = spm_read_vols(V);
		Y(~isfinite(Y(:))) = 0;
		Y(Y(:) < 0) = 0;
		spm_write_vol(V, Y);
EOF
		gzip ${DIR}/pet_std/${RECON}/PET.lps.nii ${DIR}/pet_std/${RECON}/PET.lps.lin.nii ${DIR}/pet_std/${RECON}/BS7_PET.lps.nii
	
	# Copy rigid transformation of OSEM_TOF_i3_s21_g1_5 onto T1
	cp ${DIR}/pet/Pet2T1.BS7.register.dof6.dat ${DIR}/pet_std/${RECON}
fi

# ========================================================================================================================================
#                                         Apply intensity normalization (without PVC)
# ========================================================================================================================================
 
if [ $DoIN -eq 1 ] && [ ! -f ${DIR}/pet_std/${RECON}/PET.lps.BS7.gn.nii.gz ]
then
	# Global normalization based on SPM
	gunzip ${DIR}/pet_std/${RECON}/BS7_PET.lps.nii.gz
	matlab -nodisplay <<EOF
		% Load Matlab Path: Matlab 14 and SPM12 needed
		cd ${HOME}
		p = pathdef14_SPM12;
		addpath(p);
			
		% Compute global mean
		V = spm_data_hdr_read('${DIR}/pet_std/${RECON}/BS7_PET.lps.nii');
		Gmean = spm_global(V);
		PET = spm_data_read(V);
			
		% Value of Grand Mean scaling (50 per default for O2)
		GM = 6.5;
			
		% Scaling: compute global scaling factors gSF required to implement proportional scaling global normalisation (PropSca) 
		gSF = GM/Gmean;
			
		% Apply gSF to memory-mapped scalefactors to implement scaling
		% V.pinfo(1:2,:) = V.pinfo(1:2,:)*gSF;
		
		% Compute & save global normalized PET image
		% PET_gnorm = PET.*V.pinfo(1,1) + V.pinfo(2,1);
		PET_gnorm = PET.*gSF;
		V.fname = '${DIR}/pet_std/${RECON}/PET.lps.BS7.gn.nii';
		spm_write_vol(V,PET_gnorm);	
EOF
		gzip ${DIR}/pet_std/${RECON}/BS7_PET.lps.nii ${DIR}/pet_std/${RECON}/PET.lps.BS7.gn.nii
fi

# ========================================================================================================================================
#                                   Compute partial volume correction with Muller-Gartner/Rousset based method
# ========================================================================================================================================

if [ $DoPVC -eq 1 ] && [ ! -f ${DIR}/pet_std/${RECON}/${pvedir}/PET.BS7.lps.MGCS.nii.gz ]
then
	if [ -d ${DIR}/pet_std/${RECON}/${pvedir} ]
	then
	    rm -rf ${DIR}/pet_std/${RECON}/${pvedir}/*
	else
	    mkdir ${DIR}/pet_std/${RECON}/${pvedir}
	fi

	# Copy rbrainmask.npet.nii.gz + rt1.BS7.lps.img/hdr + rt1.BS7.lps_GMROI.img/hdr
	cp ${DIR}/pet/rbrainmask.npet.nii.gz ${DIR}/pet_std/${RECON}/
	cp ${DIR}/pet/${pvedir}/rt1.BS7.lps.img ${DIR}/pet_std/${RECON}/${pvedir}
	cp ${DIR}/pet/${pvedir}/rt1.BS7.lps.hdr ${DIR}/pet_std/${RECON}/${pvedir}
	cp ${DIR}/pet/${pvedir}/rt1.BS7.lps_GMROI.img ${DIR}/pet_std/${RECON}/${pvedir}
	cp ${DIR}/pet/${pvedir}/rt1.BS7.lps_GMROI.hdr ${DIR}/pet_std/${RECON}/${pvedir}
	
	gunzip ${DIR}/pet_std/${RECON}/BS7_PET.lps.nii.gz

	# Convert to analyze format
	matlab -nodisplay <<EOF
	
	%% Load Matlab Path: Matlab 14 and SPM8 version
	cd ${HOME}
	p = pathdef14_SPM8;
	addpath(p);

	%% Step 1. Convert nifti format to analyze %%
	
	V = spm_vol('${DIR}/pet_std/${RECON}/BS7_PET.lps.nii');
	[Y, XYZ] = spm_read_vols(V);
	V.fname = '${DIR}/pet_std/${RECON}/${pvedir}/PET.BS7.lps.img';
	spm_write_vol(V, Y);
EOF

	matlab -nodisplay <<EOF
		
	%% Load Matlab Path: Matlab 14 and SPM8 version for pvelab2012
	cd ${HOME}
	p = pathdef14_SPM8;
	addpath(p);
	
	%% Step 2. Launch pve correction %%
	
	rt1_path = '${DIR}/pet_std/${RECON}/${pvedir}/rt1.BS7.lps.img';
	pet_path = '${DIR}/pet_std/${RECON}/${pvedir}/PET.BS7.lps.img';
	Vt1   = spm_vol(rt1_path);

	% Load configuration file for pve correction
	configfile = '${HOME}/SVN/matlab/matthieu/pve/config_pvec';
	
	mni = round(Vt1.dim(3) / 3);
	gmROI_path = '${DIR}/pet_std/${RECON}/${pvedir}/rt1.BS7.lps_GMROI.img';
	cmdline = ['/home/global/matlab_toolbox/pvelab2012/IBB_wrapper/pve/pve64 -cse 2 -w -s -cs ', num2str(mni), ' ', gmROI_path, ' ', pet_path, ' ', configfile];
	fid = fopen('${DIR}/pet/${pvedir}/cmdline.txt', 'w');
	fprintf(fid, '%s', cmdline);
	fclose(fid);
	disp('Performing PVC. Please wait...');
	[status, result] = unix(cmdline);

	%% Step 3. Remove NaN and negative values in rt1.BS7.lps_MGRousset.img & rt1.BS7.lps_MGCS.img %%
	
	V = spm_vol('${DIR}/pet_std/${RECON}/${pvedir}/rt1.BS7.lps_MGRousset.img');
	[Y, XYZ] = spm_read_vols(V);
	Y(~isfinite(Y(:))) = 0;
	Y(Y(:) < 0) = 0;
	spm_write_vol(V, Y);
	
	V = spm_vol('${DIR}/pet_std/${RECON}/${pvedir}/rt1.BS7.lps_MGCS.img');
	[Y, XYZ] = spm_read_vols(V);
	Y(~isfinite(Y(:))) = 0;
	Y(Y(:) < 0) = 0;
	spm_write_vol(V, Y);
	
	%% Step 4. Modify transformation matrix of corrected output misaligned : overwrite with PET.BS7.lps.img %%
	
	Vref = spm_vol(pet_path);
	
	Vsrc = spm_vol('${DIR}/pet_std/${RECON}/${pvedir}/rt1.BS7.lps_MGRousset.img');
	Y = spm_read_vols(Vsrc);
	Vsrc.mat = Vref.mat;
	spm_write_vol(Vsrc, Y);
	
	Vsrc = spm_vol('${DIR}/pet_std/${RECON}/${pvedir}/rt1.BS7.lps_MGCS.img');
	Y = spm_read_vols(Vsrc);
	Vsrc.mat = Vref.mat;
	spm_write_vol(Vsrc, Y);	
EOF

	gzip ${DIR}/pet_std/${RECON}/BS7_PET.lps.nii
	mri_convert ${DIR}/pet_std/${RECON}/${pvedir}/rt1.BS7.lps_MGRousset.img ${DIR}/pet_std/${RECON}/${pvedir}/PET.BS7.lps.MGRousset.nii.gz
	mri_convert ${DIR}/pet_std/${RECON}/${pvedir}/rt1.BS7.lps_MGCS.img ${DIR}/pet_std/${RECON}/${pvedir}/PET.BS7.lps.MGCS.nii.gz
fi

# ========================================================================================================================================
#                                         Apply intensity normalization (with PVC)
# ========================================================================================================================================

for type_pvc in MGRousset MGCS
do
	if [ $DoIN -eq 1 ] && [ ! -f ${DIR}/pet_std/${RECON}/${pvedir}/PET.BS7.lps.${type_pvc}.gn.nii.gz ]
	then
		# Global normalization based on SPM
		gunzip ${DIR}/pet_std/${RECON}/${pvedir}/PET.BS7.lps.${type_pvc}.nii.gz
		matlab -nodisplay <<EOF
			% Load Matlab Path: Matlab 14 and SPM12 needed
			cd ${HOME}
			p = pathdef14_SPM12;
			addpath(p);
			
			% Compute global mean
			V = spm_data_hdr_read('${DIR}/pet_std/${RECON}/${pvedir}/PET.BS7.lps.${type_pvc}.nii');
			Gmean = spm_global(V);
			PET = spm_data_read(V);
			
			% Value of Grand Mean scaling (50 per default for O2)
			GM = 6.5;
			
			% Scaling: compute global scaling factors gSF required to implement proportional scaling global normalisation (PropSca) 
			gSF = GM/Gmean;
			
			% Apply gSF to memory-mapped scalefactors to implement scaling
			% V.pinfo(1:2,:) = V.pinfo(1:2,:)*gSF;
			
			% Compute & save global normalized PET image
			% PET_gnorm = PET.*V.pinfo(1,1) + V.pinfo(2,1);
			PET_gnorm = PET.*gSF;
			V.fname = '${DIR}/pet_std/${RECON}/${pvedir}/PET.BS7.lps.${type_pvc}.gn.nii';
			spm_write_vol(V,PET_gnorm);	
EOF
		gzip ${DIR}/pet_std/${RECON}/${pvedir}/PET.BS7.lps.${type_pvc}.nii ${DIR}/pet_std/${RECON}/${pvedir}/PET.BS7.lps.${type_pvc}.gn.nii
	fi
done

# ========================================================================================================================================
#                                  Resample PET data onto native and common surfaces
# ========================================================================================================================================


if [ $DoSBA -eq 1 ] && [ ! -f ${DIR}/pet_std/${RECON}/${pvedir}/surf/rh.PET.BS7.lps.MGCS.gn.fsaverage.sm15.mgh ]
then
	if [ -d ${DIR}/pet_std/${RECON}/surf ]
	then
	    rm -rf ${DIR}/pet_std/${RECON}/surf/*
	else
	    mkdir ${DIR}/pet_std/${RECON}/surf
	fi
	
	if [ -d ${DIR}/pet_std/${RECON}/${pvedir}/surf ]
	then
	    rm -rf ${DIR}/pet_std/${RECON}/${pvedir}/surf/*
	else
	    mkdir ${DIR}/pet_std/${RECON}/${pvedir}/surf
	fi
	
	## Copy PET brainmask
	cp ${DIR}/pet/BS7_PET.lps.brain_mask.dil1.nii.gz ${DIR}/pet_std/${RECON}

	## Resample brain mask onto native surface
	mri_vol2surf --mov ${DIR}/pet_std/${RECON}/BS7_PET.lps.brain_mask.dil1.nii.gz --reg ${DIR}/pet_std/${RECON}/Pet2T1.BS7.register.dof6.dat --trgsubject ${SUBJECT_ID} --interp nearest --projfrac 0.5 --hemi lh --o ${DIR}/pet_std/${RECON}/surf/lh.PET.lps.BS7.brain_mask.nii --noreshape --cortex --surfreg sphere.reg
	mri_vol2surf --mov ${DIR}/pet_std/${RECON}/BS7_PET.lps.brain_mask.dil1.nii.gz --reg ${DIR}/pet_std/${RECON}/Pet2T1.BS7.register.dof6.dat --trgsubject ${SUBJECT_ID} --interp nearest --projfrac 0.5 --hemi rh --o ${DIR}/pet_std/${RECON}/surf/rh.PET.lps.BS7.brain_mask.nii --noreshape --cortex --surfreg sphere.reg
	
	## Resample brain mask onto fs_average surface
	mri_vol2surf --mov ${DIR}/pet_std/${RECON}/BS7_PET.lps.brain_mask.dil1.nii.gz --reg ${DIR}/pet_std/${RECON}/Pet2T1.BS7.register.dof6.dat --trgsubject fsaverage --interp nearest --projfrac 0.5 --hemi lh --o ${DIR}/pet_std/${RECON}/surf/lh.PET.lps.BS7.brain_mask.fsaverage.nii --noreshape --cortex --surfreg sphere.reg
	mri_vol2surf --mov ${DIR}/pet_std/${RECON}/BS7_PET.lps.brain_mask.dil1.nii.gz --reg ${DIR}/pet_std/${RECON}/Pet2T1.BS7.register.dof6.dat --trgsubject fsaverage --interp nearest --projfrac 0.5 --hemi rh --o ${DIR}/pet_std/${RECON}/surf/rh.PET.lps.BS7.brain_mask.fsaverage.nii --noreshape --cortex --surfreg sphere.reg
	
	for type_norm in gn
	do	
		## Resample onto native surface
		
		# lh
		mri_vol2surf --mov ${DIR}/pet_std/${RECON}/PET.lps.BS7.${type_norm}.nii.gz --reg ${DIR}/pet_std/${RECON}/Pet2T1.BS7.register.dof6.dat --trgsubject ${SUBJECT_ID} --interp trilin --projfrac 0.5 --hemi lh --o ${DIR}/pet_std/${RECON}/surf/lh.PET.lps.BS7.${type_norm}.mgh --noreshape --cortex --surfreg sphere.reg

		# rh
		mri_vol2surf --mov ${DIR}/pet_std/${RECON}/PET.lps.BS7.${type_norm}.nii.gz --reg ${DIR}/pet_std/${RECON}/Pet2T1.BS7.register.dof6.dat --trgsubject ${SUBJECT_ID} --interp trilin --projfrac 0.5 --hemi rh --o ${DIR}/pet_std/${RECON}/surf/rh.PET.lps.BS7.${type_norm}.mgh --noreshape --cortex --surfreg sphere.reg
		
		# smooth
		for fwhmsurf in 0 3 6 10 12 15
		do
			mris_fwhm --s ${SUBJECT_ID} --hemi lh --smooth-only --i ${DIR}/pet_std/${RECON}/surf/lh.PET.lps.BS7.${type_norm}.mgh --fwhm ${fwhmsurf} --o ${DIR}/pet_std/${RECON}/surf/lh.PET.lps.BS7.${type_norm}.sm${fwhmsurf}.mgh --mask ${DIR}/pet_std/${RECON}/surf/lh.PET.lps.BS7.brain_mask.nii
			mris_fwhm --s ${SUBJECT_ID} --hemi rh --smooth-only --i ${DIR}/pet_std/${RECON}/surf/rh.PET.lps.BS7.${type_norm}.mgh --fwhm ${fwhmsurf} --o ${DIR}/pet_std/${RECON}/surf/rh.PET.lps.BS7.${type_norm}.sm${fwhmsurf}.mgh --mask ${DIR}/pet_std/${RECON}/surf/rh.PET.lps.BS7.brain_mask.nii
		done	

		## Resample onto fsaverage
		
		# lh
		mri_vol2surf --mov ${DIR}/pet_std/${RECON}/PET.lps.BS7.${type_norm}.nii.gz --reg ${DIR}/pet_std/${RECON}/Pet2T1.BS7.register.dof6.dat --trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi lh --o ${DIR}/pet_std/${RECON}/surf/lh.PET.lps.BS7.${type_norm}.fsaverage.mgh --noreshape --cortex --surfreg sphere.reg

		# rh
		mri_vol2surf --mov ${DIR}/pet_std/${RECON}/PET.lps.BS7.${type_norm}.nii.gz --reg ${DIR}/pet_std/${RECON}/Pet2T1.BS7.register.dof6.dat --trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi rh --o ${DIR}/pet_std/${RECON}/surf/rh.PET.lps.BS7.${type_norm}.fsaverage.mgh --noreshape --cortex --surfreg sphere.reg

		# smooth
		for fwhmsurf in 0 3 6 10 12 15
# 		for fwhmsurf in 3
		do
			mris_fwhm --s fsaverage --hemi lh --smooth-only --i ${DIR}/pet_std/${RECON}/surf/lh.PET.lps.BS7.${type_norm}.fsaverage.mgh --fwhm ${fwhmsurf} --o ${DIR}/pet_std/${RECON}/surf/lh.PET.lps.BS7.${type_norm}.fsaverage.sm${fwhmsurf}.mgh --mask ${DIR}/pet_std/${RECON}/surf/lh.PET.lps.BS7.brain_mask.fsaverage.nii
			mris_fwhm --s fsaverage --hemi rh --smooth-only --i ${DIR}/pet_std/${RECON}/surf/rh.PET.lps.BS7.${type_norm}.fsaverage.mgh --fwhm ${fwhmsurf} --o ${DIR}/pet_std/${RECON}/surf/rh.PET.lps.BS7.${type_norm}.fsaverage.sm${fwhmsurf}.mgh --mask ${DIR}/pet_std/${RECON}/surf/rh.PET.lps.BS7.brain_mask.fsaverage.nii
		done	
		
		for type_pvc in MGRousset MGCS
		do
			## Resample onto native surface
			
			# lh
			mri_vol2surf --mov ${DIR}/pet_std/${RECON}/${pvedir}/PET.BS7.lps.${type_pvc}.${type_norm}.nii.gz --reg ${DIR}/pet_std/${RECON}/Pet2T1.BS7.register.dof6.dat --trgsubject ${SUBJECT_ID} --interp trilin --projfrac 0.5 --hemi lh --o ${DIR}/pet_std/${RECON}/${pvedir}/surf/lh.PET.BS7.lps.${type_pvc}.${type_norm}.mgh --noreshape --cortex --surfreg sphere.reg

			# rh
			mri_vol2surf --mov ${DIR}/pet_std/${RECON}/${pvedir}/PET.BS7.lps.${type_pvc}.${type_norm}.nii.gz --reg ${DIR}/pet_std/${RECON}/Pet2T1.BS7.register.dof6.dat --trgsubject ${SUBJECT_ID} --interp trilin --projfrac 0.5 --hemi rh --o ${DIR}/pet_std/${RECON}/${pvedir}/surf/rh.PET.BS7.lps.${type_pvc}.${type_norm}.mgh --noreshape --cortex --surfreg sphere.reg
			
			# smooth
			for fwhmsurf in 0 3 6 10 12 15
			do
				mris_fwhm --s ${SUBJECT_ID} --hemi lh --smooth-only --i ${DIR}/pet_std/${RECON}/${pvedir}/surf/lh.PET.BS7.lps.${type_pvc}.${type_norm}.mgh --fwhm ${fwhmsurf} --o ${DIR}/pet_std/${RECON}/${pvedir}/surf/lh.PET.BS7.lps.${type_pvc}.${type_norm}.sm${fwhmsurf}.mgh --mask ${DIR}/pet_std/${RECON}/surf/lh.PET.lps.BS7.brain_mask.nii
				mris_fwhm --s ${SUBJECT_ID} --hemi rh --smooth-only --i ${DIR}/pet_std/${RECON}/${pvedir}/surf/rh.PET.BS7.lps.${type_pvc}.${type_norm}.mgh --fwhm ${fwhmsurf} --o ${DIR}/pet_std/${RECON}/${pvedir}/surf/rh.PET.BS7.lps.${type_pvc}.${type_norm}.sm${fwhmsurf}.mgh --mask ${DIR}/pet_std/${RECON}/surf/rh.PET.lps.BS7.brain_mask.nii
			done	

			## Resample onto fsaverage

			# lh
			mri_vol2surf --mov ${DIR}/pet_std/${RECON}/${pvedir}/PET.BS7.lps.${type_pvc}.${type_norm}.nii.gz --reg ${DIR}/pet_std/${RECON}/Pet2T1.BS7.register.dof6.dat --trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi lh --o ${DIR}/pet_std/${RECON}/${pvedir}/surf/lh.PET.BS7.lps.${type_pvc}.${type_norm}.fsaverage.mgh --noreshape --cortex --surfreg sphere.reg

			# rh
			mri_vol2surf --mov ${DIR}/pet_std/${RECON}/${pvedir}/PET.BS7.lps.${type_pvc}.${type_norm}.nii.gz --reg ${DIR}/pet_std/${RECON}/Pet2T1.BS7.register.dof6.dat --trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi rh --o ${DIR}/pet_std/${RECON}/${pvedir}/surf/rh.PET.BS7.lps.${type_pvc}.${type_norm}.fsaverage.mgh --noreshape --cortex --surfreg sphere.reg

			# smooth
			for fwhmsurf in 0 3 6 10 12 15
# 			for fwhmsurf in 3
			do
				mris_fwhm --s fsaverage --hemi lh --smooth-only --i ${DIR}/pet_std/${RECON}/${pvedir}/surf/lh.PET.BS7.lps.${type_pvc}.${type_norm}.fsaverage.mgh --fwhm ${fwhmsurf} --o ${DIR}/pet_std/${RECON}/${pvedir}/surf/lh.PET.BS7.lps.${type_pvc}.${type_norm}.fsaverage.sm${fwhmsurf}.mgh --mask ${DIR}/pet_std/${RECON}/surf/lh.PET.lps.BS7.brain_mask.fsaverage.nii
				mris_fwhm --s fsaverage --hemi rh --smooth-only --i ${DIR}/pet_std/${RECON}/${pvedir}/surf/rh.PET.BS7.lps.${type_pvc}.${type_norm}.fsaverage.mgh --fwhm ${fwhmsurf} --o ${DIR}/pet_std/${RECON}/${pvedir}/surf/rh.PET.BS7.lps.${type_pvc}.${type_norm}.fsaverage.sm${fwhmsurf}.mgh --mask ${DIR}/pet_std/${RECON}/surf/rh.PET.lps.BS7.brain_mask.fsaverage.nii
			done
		done
	done
fi