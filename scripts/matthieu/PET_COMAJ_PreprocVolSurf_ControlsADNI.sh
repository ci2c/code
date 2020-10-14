#!/bin/bash

if [ $# -lt 10 ]
then
	echo ""
	echo "Usage:  PET_COMAJ_PreprocVolSurf_ControlsADNI.sh  -idPet <inputdir_pet> -sd <SUBJECTS_DIR> -subjPet <SUBJECT_ID_PET> -subjMri <SUBJECT_ID_MRI> -typeSubj <control/patient> [ -v <FSVersion> -sx <resample_x> -sy <resample_y> -sz <resample_z> -DoInit -DoReg -ApplyReg -DoPVC -DoMeanRoi -DoIN -DoMask -DoSBA -DoSPMNorm -DoANTSNorm -oldNorm -oldSeg ]"
	echo ""
	echo "	-idPet		: Input raw Pet data directory "
	echo "  -sd		: FreeSurfer subjects directory "
	echo "  -subjPet       	: Raw Pet subject name "
	echo "  -subjMri       	: FreeSurfer subject name "
	echo "  -typeSubj       : Type of subject --> control or patient "
	echo "  -v              : Version of FreeSurfer used"
	echo "  -sx             : Size of x PET resample (default :1 mm)"
	echo "  -sy             : Size of y PET resample (default :1 mm)"
	echo "  -sz             : Size of z PET resample (default :1 mm)"
	echo "  -DoInit         : Do Initialization step "
	echo "  -DoReg          : Do rigid-body registration of PET on orig.mgz with bbregister "
	echo "  -ApplyReg       : Register volumic parcellations into PET space  "
	echo "  -DoPVC          : Compute partial volume correction with Muller-Gartner/Rousset based method "
	echo "  -DoMeanRoi      : Compute mean values in PET ROIs "
	echo "  -DoIN           : Apply intensity normalization "
	echo "  -DoMask         : Compute PET brain mask "
	echo "  -DoSBA          : Do surface-based analysis "
	echo "  -DoSPMNorm	: Do SPM12 normalization to MNI152 space"
	echo "  -DoANTSNorm	: Do ANTs normalization to MNI152 1mm space"
	echo "  -oldNorm        : Do SPM8 Normalization (else SPM12) "
	echo "  -oldSeg         : Do SPM8 New Segment (else SPM12 Segment) "
	echo ""
	echo "Usage:  PET_COMAJ_PreprocVolSurf_ControlsADNI.sh  -idPet <inputdir_pet> -sd <SUBJECTS_DIR> -subjPet <SUBJECT_ID_PET> -subjMri <SUBJECT_ID_MRI> -typeSubj <control/patient> [ -v <FSVersion> -sx <resample_x> -sy <resample_y> -sz <resample_z> -DoInit -DoReg -ApplyReg -DoPVC -DoMeanRoi -DoIN -DoMask -DoSBA -DoSPMNorm -DoANTSNorm -oldNorm -oldSeg ]"
	echo ""
	echo "Author: Matthieu Vanhoutte - CHRU Lille - March 2016"
	echo ""
	exit 1
fi

index=1
FS_VERSION=5.3
TypeSubj="control"
DoInit=0
DoReg=0
ApplyReg=0
oldSeg=0
DoPVC=0
DoMeanRoi=0
DoIN=0
DoMask=0
DoSBA=0
DoSPMNorm=0
oldNorm=0
DoANTSNorm=0
size_x=1
size_y=1
size_z=1

# INPUT_PET_DIR=/NAS/tupac/matthieu/Nifti_TEP
# SUBJECT_ID_PET=Hallaert_Beatrice_20100527
# SUBJECT_ID=Hallaert_Beatrice_M0_2010-12-15
# SUBJECTS_DIR=/NAS/tupac/matthieu/FS5.3

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage:  PET_COMAJ_PreprocVolSurf_ControlsADNI.sh  -idPet <inputdir_pet> -sd <SUBJECTS_DIR> -subjPet <SUBJECT_ID_PET> -subjMri <SUBJECT_ID_MRI> -typeSubj <control/patient> [ -v <FSVersion> -sx <resample_x> -sy <resample_y> -sz <resample_z> -DoInit -DoReg -ApplyReg -DoPVC -DoMeanRoi -DoIN -DoMask -DoSBA -DoSPMNorm -DoANTSNorm -oldNorm -oldSeg ]"
		echo ""
		echo "	-idPet		: Input raw Pet data directory "
		echo "  -sd		: FreeSurfer subjects directory "
		echo "  -subjPet       	: Raw Pet subject name "
		echo "  -subjMri       	: FreeSurfer subject name "
		echo "  -typeSubj       : Type of subject --> control or patient "
		echo "  -v              : Version of FreeSurfer used"
		echo "  -sx             : Size of x PET resample (default :1 mm)"
		echo "  -sy             : Size of y PET resample (default :1 mm)"
		echo "  -sz             : Size of z PET resample (default :1 mm)"
		echo "  -DoInit         : Do Initialization step "
		echo "  -DoReg          : Do rigid-body registration of PET on orig.mgz with bbregister "
		echo "  -ApplyReg       : Register volumic parcellations into PET space  "
		echo "  -DoPVC          : Compute partial volume correction with Muller-Gartner/Rousset based method "
		echo "  -DoMeanRoi      : Compute mean values in PET ROIs "
		echo "  -DoIN           : Apply intensity normalization "
		echo "  -DoMask         : Compute PET brain mask "
		echo "  -DoSBA          : Do surface-based analysis "
		echo "  -DoSPMNorm	: Do SPM12 normalization to MNI152 space"
		echo "  -DoANTSNorm	: Do ANTs normalization to MNI152 1mm space"
		echo "  -oldNorm        : Do SPM8 Normalization (else SPM12) "
		echo "  -oldSeg         : Do SPM8 New Segment (else SPM12 Segment) "
		echo ""
		echo "Usage:  PET_COMAJ_PreprocVolSurf_ControlsADNI.sh  -idPet <inputdir_pet> -sd <SUBJECTS_DIR> -subjPet <SUBJECT_ID_PET> -subjMri <SUBJECT_ID_MRI> -typeSubj <control/patient> [ -v <FSVersion> -sx <resample_x> -sy <resample_y> -sz <resample_z> -DoInit -DoReg -ApplyReg -DoPVC -DoMeanRoi -DoIN -DoMask -DoSBA -DoSPMNorm -DoANTSNorm -oldNorm -oldSeg ]"
		echo ""
		echo "Author: Matthieu Vanhoutte - CHRU Lille - March 2016"
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
	-subjPet)
		index=$[$index+1]
		eval SUBJECT_ID_PET=\${$index}
		echo "Pet subject name : ${SUBJECT_ID_PET}"
		;;
	-subjMri)
		index=$[$index+1]
		eval SUBJECT_ID=\${$index}
		echo "FreeSurfer subject name : ${SUBJECT_ID}"
		;;
	-typeSubj)
		index=$[$index+1]
		eval TypeSubj=\${$index}
		echo "Type of subject --> control or patient : ${TypeSubj}"
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
	-ApplyReg)
		ApplyReg=1
		echo "Register volumic parcellations into PET space"
		;;
	-DoPVC)
		DoPVC=1
		echo "Compute partial volume correction with Muller-Gartner based method"
		;;
	-DoMeanRoi)
		DoMeanRoi=1
		echo "Compute mean values in PET ROIs"
		;;
	-DoIN)
		DoIN=1
		echo "Apply intensity normalization"
		;;
	-DoMask)
		DoMask=1
		echo "Compute PET brain mask"
		;;
	-DoSBA)
		DoSBA=1
		echo "Do surface-based analysis"
		;;
	-DoSPMNorm)
		DoSPMNorm=1
		echo "Do SPM12 spatial normalization"
		;;
	-DoANTSNorm)
		DoANTSNorm=1
		echo "Do ANTs spatial normalization"
		;;
	-oldNorm)
		oldNorm=1
		echo "Do SPM12 old Normalization"
		;;
	-oldSeg)
		oldSeg=1
		echo "Do SPM8 new Segment"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo ""
		echo "Usage:  PET_COMAJ_PreprocVolSurf_ControlsADNI.sh  -idPet <inputdir_pet> -sd <SUBJECTS_DIR> -subjPet <SUBJECT_ID_PET> -subjMri <SUBJECT_ID_MRI> -typeSubj <control/patient> [ -v <FSVersion> -sx <resample_x> -sy <resample_y> -sz <resample_z> -DoInit -DoReg -ApplyReg -DoPVC -DoMeanRoi -DoIN -DoMask -DoSBA -DoSPMNorm -DoANTSNorm -oldNorm -oldSeg ]"
		echo ""
		echo "	-idPet		: Input raw Pet data directory "
		echo "  -sd		: FreeSurfer subjects directory "
		echo "  -subjPet       	: Raw Pet subject name "
		echo "  -subjMri       	: FreeSurfer subject name "
		echo "  -typeSubj       : Type of subject --> control or patient "
		echo "  -v              : Version of FreeSurfer used"
		echo "  -sx             : Size of x PET resample (default :1 mm)"
		echo "  -sy             : Size of y PET resample (default :1 mm)"
		echo "  -sz             : Size of z PET resample (default :1 mm)"
		echo "  -DoInit         : Do Initialization step "
		echo "  -DoReg          : Do rigid-body registration of PET on orig.mgz with bbregister "
		echo "  -ApplyReg       : Register volumic parcellations into PET space  "
		echo "  -DoPVC          : Compute partial volume correction with Muller-Gartner/Rousset based method "
		echo "  -DoMeanRoi      : Compute mean values in PET ROIs "
		echo "  -DoIN           : Apply intensity normalization "
		echo "  -DoMask         : Compute PET brain mask "
		echo "  -DoSBA          : Do surface-based analysis "
		echo "  -DoSPMNorm	: Do SPM12 normalization to MNI152 space"
		echo "  -DoANTSNorm	: Do ANTs normalization to MNI152 1mm space"
		echo "  -oldNorm        : Do SPM8 Normalization (else SPM12) "
		echo "  -oldSeg         : Do SPM8 New Segment (else SPM12 Segment) "
		echo ""
		echo "Usage:  PET_COMAJ_PreprocVolSurf_ControlsADNI.sh  -idPet <inputdir_pet> -sd <SUBJECTS_DIR> -subjPet <SUBJECT_ID_PET> -subjMri <SUBJECT_ID_MRI> -typeSubj <control/patient> [ -v <FSVersion> -sx <resample_x> -sy <resample_y> -sz <resample_z> -DoInit -DoReg -ApplyReg -DoPVC -DoMeanRoi -DoIN -DoMask -DoSBA -DoSPMNorm -DoANTSNorm -oldNorm -oldSeg ]"
		echo ""
		echo "Author: Matthieu Vanhoutte - CHRU Lille - March 2016"
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
if [ -z ${SUBJECT_ID_PET} ]
then
	 echo "-subjPet argument mandatory"
	 exit 1
fi
if [ -z ${SUBJECT_ID} ]
then
	 echo "-subjMri argument mandatory"
	 exit 1
fi
if [ -z ${TypeSubj} ]
then
	 echo "-typeSubj argument mandatory"
	 exit 1
fi

## Set up FSL (if not already done so in the running environment) ##
FSLDIR=${Soft_dir}/fsl50
. ${FSLDIR}/etc/fslconf/fsl.sh
PATH=${FSLDIR}/bin:${PATH}
export FSLDIR

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

export PATH

DIR=${SUBJECTS_DIR}/${SUBJECT_ID}

if [ ${oldSeg} -eq 1 ]
then
	pvedir=pvelab_Seg8_l0
elif [ ${oldSeg} -eq 0 ]
then
	pvedir=pvelab_Seg12_l0
fi

# ========================================================================================================================================
#                                                        INITIALIZATION
# ========================================================================================================================================

if [ $DoInit -eq 1 ]
then
	if [ -d ${DIR}/pet.adni ]
	then
	    rm -rf ${DIR}/pet.adni/*
	else
	    mkdir ${DIR}/pet.adni
	fi
	
	if [ "${TypeSubj}"  == "control" ]
	then
		echo "mri_convert ${INPUT_PET_DIR}/${SUBJECT_ID_PET}/*Coreg__Avg__Standardized_Image_and_Voxel_Size.nii ${DIR}/pet.adni/PET.lps.nii.gz"
		mri_convert ${INPUT_PET_DIR}/${SUBJECT_ID_PET}/*Coreg__Avg__Standardized_Image_and_Voxel_Size.nii ${DIR}/pet.adni/PET.lps.nii.gz
		
		echo "mri_convert ${INPUT_PET_DIR}/${SUBJECT_ID_PET}/*Coreg__Avg__Std_Img_and_Vox_Siz__Uniform_Resolution.nii ${DIR}/pet.adni/PET.lps.sm8.nii.gz"
		mri_convert ${INPUT_PET_DIR}/${SUBJECT_ID_PET}/*Coreg__Avg__Std_Img_and_Vox_Siz__Uniform_Resolution.nii ${DIR}/pet.adni/PET.lps.sm8.nii.gz
	elif [ "${TypeSubj}"  == "patient" ]
	then	
		echo "mri_convert ${INPUT_PET_DIR}/${SUBJECT_ID_PET}/*CERVEAU_3D_SALENGRO_CERVEAU_GRANULEUX_3D_AC.nii.gz ${DIR}/pet.adni/PET.lps.nii.gz"
		mri_convert ${INPUT_PET_DIR}/${SUBJECT_ID_PET}/*_CERVEAU_3D_SALENGRO_CERVEAU_GRANULEUX_3D_AC.nii.gz ${DIR}/pet.adni/PET.lps.nii.gz
	fi
	
	Orientation=$(mri_info ${DIR}/pet.adni/PET.lps.nii.gz | grep "Orientation" | awk '{print $3}')
	
	if [ "${Orientation}" != "LPS" ]
	then
		echo "PET not in native LPS orientation"
		exit 1
	fi
	
# 	echo "mri_convert ${DIR}/mri/T1.mgz ${DIR}/pet.adni/T1_RAS.nii.gz --out_orientation RAS"
# 	mri_convert ${DIR}/mri/T1.mgz ${DIR}/pet.adni/T1_RAS.nii.gz --out_orientation RAS

	mri_convert ${DIR}/mri/T1.mgz ${DIR}/pet.adni/T1.lia.nii.gz
fi

# ========================================================================================================================================
#                                           Register upsampled PET (1x1x1mm) on MRI
# ========================================================================================================================================

if [ $DoReg -eq 1 ] && [ ! -f ${DIR}/pet.adni/Pet2T1.BS7.register.dof6.dat ]
then
	# Reslice PET to 1x1x1mm resolution with trilinear interpolation
	mri_convert ${DIR}/pet.adni/PET.lps.nii.gz ${DIR}/pet.adni/PET.lps.lin.nii.gz -vs ${size_x} ${size_y} ${size_z} -rt interpolate
	
	# Crop FOV to 256
	mri_convert --cropsize 256 256 256 ${DIR}/pet.adni/PET.lps.lin.nii.gz ${DIR}/pet.adni/PET.lps.lin.nii.gz

	if [ "${TypeSubj}"  == "control" ]
	then
		# Reslice PET to 1x1x1mm resolution with B-spline 7th (SPM) (!! Shift de -0.155 selon z entre ${DIR}/pet.adni/PET.lps.nii.gz et ${DIR}/pet.adni/PET.lps.lin.nii.gz !!)
		gunzip ${DIR}/pet.adni/PET.lps.nii.gz ${DIR}/pet.adni/PET.lps.sm8.nii.gz ${DIR}/pet.adni/PET.lps.lin.nii.gz
		matlab -nodisplay <<EOF
		
			%% Load Matlab Path: Matlab 14 and SPM8 version
			cd ${HOME}
			p = pathdef;
			addpath(p);

			%% Init of spm_jobman
			spm('defaults', 'PET');
			spm_jobman('initcfg');
			matlabbatch={};
			
			%% Step 1. Reslice PET.lps.nii and PET.lps.sm8.nii with B-spline 7th interpolation
			matlabbatch{end+1}.spm.spatial.realign.write.data = {
									    '${DIR}/pet.adni/PET.lps.lin.nii,1'
									    '${DIR}/pet.adni/PET.lps.nii,1'
									    '${DIR}/pet.adni/PET.lps.sm8.nii,1'
									};
			matlabbatch{end}.spm.spatial.realign.write.roptions.which = [1 0];
			matlabbatch{end}.spm.spatial.realign.write.roptions.interp = 7;
			matlabbatch{end}.spm.spatial.realign.write.roptions.wrap = [0 0 0];
			matlabbatch{end}.spm.spatial.realign.write.roptions.mask = 0;
			matlabbatch{end}.spm.spatial.realign.write.roptions.prefix = 'BS7_';

			spm_jobman('run',matlabbatch);
			
			%% Step 2. Remove NaN and negative values in BS7_PET.lps.nii and BS7_PET.lps.sm8.nii
			V = spm_vol('${DIR}/pet.adni/BS7_PET.lps.nii');
			[Y, XYZ] = spm_read_vols(V);
			Y(~isfinite(Y(:))) = 0;
			Y(Y(:) < 0) = 0;
			spm_write_vol(V, Y);

			V = spm_vol('${DIR}/pet.adni/BS7_PET.lps.sm8.nii');
			[Y, XYZ] = spm_read_vols(V);
			Y(~isfinite(Y(:))) = 0;
			Y(Y(:) < 0) = 0;
			spm_write_vol(V, Y);
EOF
		gzip ${DIR}/pet.adni/PET.lps.nii ${DIR}/pet.adni/PET.lps.sm8.nii ${DIR}/pet.adni/PET.lps.lin.nii ${DIR}/pet.adni/BS7_PET.lps.nii ${DIR}/pet.adni/BS7_PET.lps.sm8.nii
		
	elif [ "${TypeSubj}"  == "patient" ]
	then
		# Reslice PET to 1x1x1mm resolution with B-spline 7th (SPM) (!! Shift de -0.155 selon z entre ${DIR}/pet.adni/PET.lps.nii.gz et ${DIR}/pet.adni/PET.lps.lin.nii.gz !!)
		gunzip ${DIR}/pet.adni/PET.lps.nii.gz ${DIR}/pet.adni/PET.lps.lin.nii.gz
		matlab -nodisplay <<EOF
		
			%% Load Matlab Path: Matlab 14 and SPM8 version
			cd ${HOME}
			p = pathdef;
			addpath(p);

			%% Init of spm_jobman
			spm('defaults', 'PET');
			spm_jobman('initcfg');
			matlabbatch={};
			
			%% Step 1. Reslice PET.lps.nii with B-spline 7th interpolation
			matlabbatch{end+1}.spm.spatial.realign.write.data = {
									    '${DIR}/pet.adni/PET.lps.lin.nii,1'
									    '${DIR}/pet.adni/PET.lps.nii,1'
									};
			matlabbatch{end}.spm.spatial.realign.write.roptions.which = [1 0];
			matlabbatch{end}.spm.spatial.realign.write.roptions.interp = 7;
			matlabbatch{end}.spm.spatial.realign.write.roptions.wrap = [0 0 0];
			matlabbatch{end}.spm.spatial.realign.write.roptions.mask = 0;
			matlabbatch{end}.spm.spatial.realign.write.roptions.prefix = 'BS7_';

			spm_jobman('run',matlabbatch);
			
			%% Step 2. Remove NaN and negative values in BS7_PET.lps.nii
			V = spm_vol('${DIR}/pet.adni/BS7_PET.lps.nii');
			[Y, XYZ] = spm_read_vols(V);
			Y(~isfinite(Y(:))) = 0;
			Y(Y(:) < 0) = 0;
			spm_write_vol(V, Y);
EOF
		gzip ${DIR}/pet.adni/PET.lps.nii ${DIR}/pet.adni/PET.lps.lin.nii ${DIR}/pet.adni/BS7_PET.lps.nii
	fi
	
	if [ "${TypeSubj}" == "control" ]
	then 	
		bbregister  --s ${SUBJECT_ID} --init-spm --t2 --mov ${DIR}/pet.adni/BS7_PET.lps.nii.gz --reg ${DIR}/pet.adni/Pet2T1.BS7.register.dof6.dat --lta ${DIR}/pet.adni/Pet2T1.BS7.register.dof6.lta \
		--init-reg-out ${DIR}/pet.adni/Pet2T1.BS7.init.register.dof6.dat --o ${DIR}/pet.adni/rPET.lia.BS7.nii.gz > ${DIR}/pet.adni/bbregister_BS7_log.txt
	elif [ "${TypeSubj}" == "patient" ]
	then 
		bbregister  --s ${SUBJECT_ID} --init-fsl --t2 --mov ${DIR}/pet.adni/BS7_PET.lps.nii.gz --reg ${DIR}/pet.adni/Pet2T1.BS7.register.dof6.dat --lta ${DIR}/pet.adni/Pet2T1.BS7.register.dof6.lta \
		--init-reg-out ${DIR}/pet.adni/Pet2T1.BS7.init.register.dof6.dat --o ${DIR}/pet.adni/rPET.lia.BS7.nii.gz > ${DIR}/pet.adni/bbregister_BS7_log.txt
	fi
	
	# FSL-compatible registration matrix
	tkregister2 --noedit --reg ${DIR}/pet.adni/Pet2T1.BS7.register.dof6.dat --mov ${DIR}/pet.adni/BS7_PET.lps.nii.gz --targ ${DIR}/pet.adni/T1.lia.nii.gz --fslregout ${DIR}/pet.adni/Pet2T1.BS7.mat
fi

# ========================================================================================================================================
#                                   Register volumic parcellations into PET upsampled space
# ========================================================================================================================================

if [ $ApplyReg -eq 1 ] && [ ! -f ${DIR}/pet.adni/rGMcerebellum.BS7.mask.nii.gz ] && [ ! -f ${DIR}/pet.adni/rpons.BS7.mask.nii.gz ]
then
	# Extract labels of cerebellar gray matter and pons and compute masks
	mri_extract_label ${DIR}/mri/aparc.a2009s+aseg.mgz 8 47 ${DIR}/pet.adni/GMcerebellum.nii.gz
	mri_extract_label ${DIR}/mri/brainstemSsLabels.v10.1mm.mgz 174 ${DIR}/pet.adni/pons.nii.gz

	mri_binarize --i ${DIR}/pet.adni/GMcerebellum.nii.gz --min 0.1 --o ${DIR}/pet.adni/GMcerebellum.mask.nii.gz
	mri_binarize --i ${DIR}/pet.adni/pons.nii.gz --min 0.1 --o ${DIR}/pet.adni/pons.mask.nii.gz
	
	# Register GMcerebellum_mask into PET space
	mri_vol2vol --mov ${DIR}/pet.adni/BS7_PET.lps.nii.gz --targ ${DIR}/pet.adni/GMcerebellum.mask.nii.gz --o ${DIR}/pet.adni/rGMcerebellum.BS7.mask.nii.gz --inv --reg ${DIR}/pet.adni/Pet2T1.BS7.register.dof6.dat --no-save-reg --nearest
# 	mri_convert -rl ${DIR}/pet.adni/PET.cubic.lps.nii.gz -rt nearest -odt int ${DIR}/pet.adni/GMcerebellum_mask_npet.nii.gz ${DIR}/pet.adni/rGMcerebellum_mask_npet.nii.gz

	# Register pons_mask into PET space
	mri_vol2vol --mov ${DIR}/pet.adni/BS7_PET.lps.nii.gz --targ ${DIR}/pet.adni/pons.mask.nii.gz --o ${DIR}/pet.adni/rpons.BS7.mask.nii.gz --inv --reg ${DIR}/pet.adni/Pet2T1.BS7.register.dof6.dat --no-save-reg --nearest
# 	mri_convert -rl ${DIR}/pet.adni/PET.cubic.lps.nii.gz -rt nearest -odt int ${DIR}/pet.adni/pons_mask_npet.nii.gz ${DIR}/pet.adni/rpons_mask_npet.nii.gz

fi

# ========================================================================================================================================
#                    Smooth upsampled PET data of patients to obtain a uniform resolution of 8 mm FWHM
# ========================================================================================================================================

if [ "${TypeSubj}"  == "patient" ] && [ ! -f ${DIR}/pet.adni/BS7_PET.lps.sm8.nii.gz ]
then
	gunzip ${DIR}/pet.adni/BS7_PET.lps.nii.gz
	matlab -nodisplay <<EOF
	
		%% Load Matlab Path: Matlab 14 and SPM8 version
		cd ${HOME}
		p = pathdef;
		addpath(p);

		%% Init of spm_jobman
		spm('defaults', 'PET');
		spm_jobman('initcfg');
		matlabbatch={};
			
		%% Step 1. Smooth PET data to obtain uniform resolution of 8 mm FWHM
		matlabbatch{end+1}.spm.spatial.smooth.data = {'${DIR}/pet.adni/BS7_PET.lps.nii,1'};
		matlabbatch{end}.spm.spatial.smooth.fwhm = [6 6.2 3];
		matlabbatch{end}.spm.spatial.smooth.dtype = 0;
		matlabbatch{end}.spm.spatial.smooth.im = 0;
		matlabbatch{end}.spm.spatial.smooth.prefix = 'sm8_';

		spm_jobman('run',matlabbatch);
EOF
	mv ${DIR}/pet.adni/sm8_BS7_PET.lps.nii ${DIR}/pet.adni/BS7_PET.lps.sm8.nii
	gzip ${DIR}/pet.adni/BS7_PET.lps.nii ${DIR}/pet.adni/BS7_PET.lps.sm8.nii
fi

# ========================================================================================================================================
#                                           Compute mean values in upsampled PET ROIs (without PVC)
# ========================================================================================================================================

if [ $DoMeanRoi -eq 1 ] && [ ! -f ${DIR}/pet.adni/mean.pons.pet.BS7.sm8.dat ]
then
	mri_segstats --seg ${DIR}/pet.adni/rGMcerebellum.BS7.mask.nii.gz --id 1 --i ${DIR}/pet.adni/BS7_PET.lps.sm8.nii.gz --sum ${DIR}/pet.adni/mean.cerebellar.pet.BS7.sm8.dat
	mri_segstats --seg ${DIR}/pet.adni/rpons.BS7.mask.nii.gz --id 1 --i ${DIR}/pet.adni/BS7_PET.lps.sm8.nii.gz --sum ${DIR}/pet.adni/mean.pons.pet.BS7.sm8.dat
	mean_cerebellar_pet_BS7=$(fslstats ${DIR}/pet.adni/BS7_PET.lps.sm8.nii.gz -k ${DIR}/pet.adni/rGMcerebellum.BS7.mask.nii.gz -m)
	mean_pons_pet_BS7=$(fslstats ${DIR}/pet.adni/BS7_PET.lps.sm8.nii.gz -k ${DIR}/pet.adni/rpons.BS7.mask.nii.gz -m)
fi

# ============================================================================================zscs============================================
#                                         Apply intensity normalization (without PVC)
# ========================================================================================================================================

if [ $DoIN -eq 1 ] && [ ! -f ${DIR}/pet.adni/PET.lps.BS7.sm8.gn.nii.gz ]
then
	# Based on anatomical reference ROI
	fslmaths ${DIR}/pet.adni/BS7_PET.lps.sm8.nii.gz -div ${mean_pons_pet_BS7} ${DIR}/pet.adni/PET.lps.BS7.sm8.npons.nii.gz
	fslmaths ${DIR}/pet.adni/BS7_PET.lps.sm8.nii.gz -div ${mean_cerebellar_pet_BS7} ${DIR}/pet.adni/PET.lps.BS7.sm8.ncereb.nii.gz

	# Global normalization based on SPM
	gunzip ${DIR}/pet.adni/BS7_PET.lps.sm8.nii.gz
	matlab -nodisplay <<EOF
		% Load Matlab Path: Matlab 14 and SPM12 needed
		cd ${HOME}
		p = pathdef14_SPM12;
		addpath(p);
		
		% Compute global mean
		V = spm_data_hdr_read('${DIR}/pet.adni/BS7_PET.lps.sm8.nii');
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
		V.fname = '${DIR}/pet.adni/PET.lps.BS7.sm8.gn.nii';
		spm_write_vol(V,PET_gnorm);	
EOF
	gzip ${DIR}/pet.adni/BS7_PET.lps.sm8.nii ${DIR}/pet.adni/PET.lps.BS7.sm8.gn.nii
fi

# ========================================================================================================================================
#                                   Compute partial volume correction with Muller-Gartner/Rousset based method
# ========================================================================================================================================

if [ $DoPVC -eq 1 ] && [ ! -f ${DIR}/pet.adni/${pvedir}/PET.BS7.lps.sm8.MGCS.nii.gz ]
then
# 	rm -rf ${DIR}/pet.adni/gtmpvc.output
# 	
# 	# Create an anatomical segmentation for the geometric transfer matrix (GTM) 
# 	gtmseg --s ${SUBJECT_ID}
# 	
# 	# Run muller-gartner based partial volume correction (Intensity normalization is done per default on pons)
# 	mri_gtmpvc --i ${DIR}/pet.adni/PET_RAS.nii.gz --psf 6 --auto-mask 8 0.01 --seg ${DIR}/mri/gtmseg.mgz --reg ${DIR}/pet.adni/Pet2T1.register.dof6.lta --default-seg-merge --mgx 0.01 --o ${DIR}/pet.adni/gtmpvc.output
# 	
# 	# Run RBV based partial volume correction (Intensity normalization is done per default on pons)
# 	mri_gtmpvc --i ${DIR}/pet.adni/PET_RAS.nii.gz --psf 6 --auto-mask 8 0.01 --seg ${DIR}/mri/gtmseg.mgz --reg ${DIR}/pet.adni/Pet2T1.register.dof6.lta --default-seg-merge --rbv --o ${DIR}/pet.adni/gtmpvc.output
# # fi

	if [ -d ${DIR}/pet.adni/${pvedir} ]
	then
	    rm -rf ${DIR}/pet.adni/${pvedir}/*
	else
	    mkdir ${DIR}/pet.adni/${pvedir}
	fi

# 	# Register T1_LIA into upsampled PET space without resample
# 	mri_vol2vol --mov ${DIR}/pet.adni/BS7_PET.lps.nii.gz --targ ${DIR}/pet.adni/T1.lia.nii.gz --o ${DIR}/pet.adni/T1.npet.nii.gz --inv --reg ${DIR}/pet.adni/Pet2T1.BS7.register.dof6.dat --no-save-reg --no-resample

# 	# Register brainmask.mgz into upsampled PET space without nearest interpolation
# 	mri_binarize --i ${DIR}/mri/brainmask.mgz --min 0.001 --o ${DIR}/pet.adni/brainmask.nii.gz
# 	mri_vol2vol --mov ${DIR}/pet.adni/BS7_PET.lps.nii.gz --targ ${DIR}/pet.adni/brainmask.nii.gz --o ${DIR}/pet.adni/rbrainmask.npet.nii.gz --inv --reg ${DIR}/pet.adni/Pet2T1.BS7.register.dof6.dat --no-save-reg --nearest

	gunzip ${DIR}/pet.adni/BS7_PET.lps.sm8.nii.gz ${DIR}/pet.adni/T1.npet.nii.gz ${DIR}/pet.adni/rbrainmask.npet.nii.gz

	# Reslice T1 in upsampled PET space and apply pve correction
# 	matlab -nodisplay <<EOF
# 	
# 	%% Load Matlab Path: Matlab 14 and SPM8 version for pvelab2012
# 	cd ${HOME}
# 	p = pathdef;
# 	addpath(p);
# 
# 	%% Init of spm_jobman
# 	spm('defaults', 'PET');
# 	spm_jobman('initcfg');
# 	matlabbatch={};
# 	
# 	%% Step 1. Reslice T1.lia.npet.nii with B-spline 7th interpolation %%
# 	matlabbatch{end+1}.spm.spatial.realign.write.data = {
# 							    '${DIR}/pet.adni/BS7_PET.lps.sm8.nii,1'
# 							    '${DIR}/pet.adni/T1.npet.nii,1'
# 							};
# 	matlabbatch{end}.spm.spatial.realign.write.roptions.which = [1 0];
# 	matlabbatch{end}.spm.spatial.realign.write.roptions.interp = 7;
# 	matlabbatch{end}.spm.spatial.realign.write.roptions.wrap = [0 0 0];
# 	matlabbatch{end}.spm.spatial.realign.write.roptions.mask = 0;
# 	matlabbatch{end}.spm.spatial.realign.write.roptions.prefix = 'BS7_';
# 
# 	spm_jobman('run',matlabbatch);
# 	
# 	%% Step 2. Remove NaN and negative values in BS7_T1.npet.nii %%
# 	
# 	V = spm_vol('${DIR}/pet.adni/BS7_T1.npet.nii');
# 	[Y, XYZ] = spm_read_vols(V);
# 	Y(~isfinite(Y(:))) = 0;
# 	Y(Y(:) < 0) = 0;
# 	spm_write_vol(V, Y);
# EOF
	gunzip ${DIR}/pet.adni/BS7_T1.npet.nii.gz
	matlab -nodisplay <<EOF
	
	%% Load Matlab Path: Matlab 14 and SPM8 version
	cd ${HOME}
	p = pathdef;
	addpath(p);
		
	%% Step 3. Convert nifti format to analyze %%

	V = spm_vol('${DIR}/pet.adni/BS7_T1.npet.nii');
	[Y, XYZ] = spm_read_vols(V);
	V.fname = '${DIR}/pet.adni/${pvedir}/rt1.BS7.lps.img';
	spm_write_vol(V, Y);

	V = spm_vol('${DIR}/pet.adni/BS7_PET.lps.sm8.nii');
	[Y, XYZ] = spm_read_vols(V);
	V.fname = '${DIR}/pet.adni/${pvedir}/PET.BS7.lps.sm8.img';
	spm_write_vol(V, Y);

EOF

	# Apply old Segmentation (SPM8) or new Segmentation (SPM12 + imported files for DARTEL)
	if [ ${oldSeg} -eq 1 ]
	then
		matlab -nodisplay <<EOF
		
		%% Load Matlab Path: Matlab 14 and SPM8 version for old Segmentation
		cd ${HOME}
		p = pathdef;
		addpath(p);

		rt1_path = '${DIR}/pet.adni/${pvedir}/rt1.BS7.lps.img';
		
		%% Step 4. Segment rt1.BS7.lps.img using SPM8 new segment function %%

		% Init of spm_jobman
		close all
		spm('defaults', 'PET');
		spm_jobman('initcfg');
		matlabbatch={};
			
		if strcmp('${TypeSubj}','control')
		  matlabbatch{end+1}.spm.tools.preproc8.channel.vols = {[rt1_path ',1']};
		  matlabbatch{end}.spm.tools.preproc8.channel.biasreg = 0.0001;
		  matlabbatch{end}.spm.tools.preproc8.channel.biasfwhm = 60;
		  matlabbatch{end}.spm.tools.preproc8.channel.write = [0 1];
		  matlabbatch{end}.spm.tools.preproc8.tissue(1).tpm = {'/NAS/tupac/matthieu/Template/SPM8/rTPM.nii,1'};
		  matlabbatch{end}.spm.tools.preproc8.tissue(1).ngaus = 2;
		  matlabbatch{end}.spm.tools.preproc8.tissue(1).native = [1 0];
		  matlabbatch{end}.spm.tools.preproc8.tissue(1).warped = [0 0];
		  matlabbatch{end}.spm.tools.preproc8.tissue(2).tpm = {'/NAS/tupac/matthieu/Template/SPM8/rTPM.nii,2'};
		  matlabbatch{end}.spm.tools.preproc8.tissue(2).ngaus = 2;
		  matlabbatch{end}.spm.tools.preproc8.tissue(2).native = [1 0];
		  matlabbatch{end}.spm.tools.preproc8.tissue(2).warped = [0 0];
		  matlabbatch{end}.spm.tools.preproc8.tissue(3).tpm = {'/NAS/tupac/matthieu/Template/SPM8/rTPM.nii,3'};
		  matlabbatch{end}.spm.tools.preproc8.tissue(3).ngaus = 2;
		  matlabbatch{end}.spm.tools.preproc8.tissue(3).native = [1 0];
		  matlabbatch{end}.spm.tools.preproc8.tissue(3).warped = [0 0];
		  matlabbatch{end}.spm.tools.preproc8.tissue(4).tpm = {'/NAS/tupac/matthieu/Template/SPM8/rTPM.nii,4'};
		  matlabbatch{end}.spm.tools.preproc8.tissue(4).ngaus = 3;
		  matlabbatch{end}.spm.tools.preproc8.tissue(4).native = [1 0];
		  matlabbatch{end}.spm.tools.preproc8.tissue(4).warped = [0 0];
		  matlabbatch{end}.spm.tools.preproc8.tissue(5).tpm = {'/NAS/tupac/matthieu/Template/SPM8/rTPM.nii,5'};
		  matlabbatch{end}.spm.tools.preproc8.tissue(5).ngaus = 4;
		  matlabbatch{end}.spm.tools.preproc8.tissue(5).native = [1 0];
		  matlabbatch{end}.spm.tools.preproc8.tissue(5).warped = [0 0];
		  matlabbatch{end}.spm.tools.preproc8.tissue(6).tpm = {'/NAS/tupac/matthieu/Template/SPM8/rTPM.nii,6'};
		  matlabbatch{end}.spm.tools.preproc8.tissue(6).ngaus = 2;
		  matlabbatch{end}.spm.tools.preproc8.tissue(6).native = [0 0];
		  matlabbatch{end}.spm.tools.preproc8.tissue(6).warped = [0 0];
		  matlabbatch{end}.spm.tools.preproc8.warp.mrf = 0;
		  matlabbatch{end}.spm.tools.preproc8.warp.reg = 4;
		  matlabbatch{end}.spm.tools.preproc8.warp.affreg = 'mni';
		  matlabbatch{end}.spm.tools.preproc8.warp.samp = 3;
		  matlabbatch{end}.spm.tools.preproc8.warp.write = [0 0];
		
		elseif strcmp('${TypeSubj}','patient')
		  matlabbatch{end+1}.spm.tools.preproc8.channel.vols = {[rt1_path ',1']};
		  matlabbatch{end}.spm.tools.preproc8.channel.biasreg = 0.0001;
		  matlabbatch{end}.spm.tools.preproc8.channel.biasfwhm = 60;
		  matlabbatch{end}.spm.tools.preproc8.channel.write = [0 1];
		  matlabbatch{end}.spm.tools.preproc8.tissue(1).tpm = {'/home/global/matlab_toolbox/spm8/toolbox/Seg/TPM.nii,1'};
		  matlabbatch{end}.spm.tools.preproc8.tissue(1).ngaus = 2;
		  matlabbatch{end}.spm.tools.preproc8.tissue(1).native = [1 0];
		  matlabbatch{end}.spm.tools.preproc8.tissue(1).warped = [0 0];
		  matlabbatch{end}.spm.tools.preproc8.tissue(2).tpm = {'/home/global/matlab_toolbox/spm8/toolbox/Seg/TPM.nii,2'};
		  matlabbatch{end}.spm.tools.preproc8.tissue(2).ngaus = 2;
		  matlabbatch{end}.spm.tools.preproc8.tissue(2).native = [1 0];
		  matlabbatch{end}.spm.tools.preproc8.tissue(2).warped = [0 0];
		  matlabbatch{end}.spm.tools.preproc8.tissue(3).tpm = {'/home/global/matlab_toolbox/spm8/toolbox/Seg/TPM.nii,3'};
		  matlabbatch{end}.spm.tools.preproc8.tissue(3).ngaus = 2;
		  matlabbatch{end}.spm.tools.preproc8.tissue(3).native = [1 0];
		  matlabbatch{end}.spm.tools.preproc8.tissue(3).warped = [0 0];
		  matlabbatch{end}.spm.tools.preproc8.tissue(4).tpm = {'/home/global/matlab_toolbox/spm8/toolbox/Seg/TPM.nii,4'};
		  matlabbatch{end}.spm.tools.preproc8.tissue(4).ngaus = 3;
		  matlabbatch{end}.spm.tools.preproc8.tissue(4).native = [1 0];
		  matlabbatch{end}.spm.tools.preproc8.tissue(4).warped = [0 0];
		  matlabbatch{end}.spm.tools.preproc8.tissue(5).tpm = {'/home/global/matlab_toolbox/spm8/toolbox/Seg/TPM.nii,5'};
		  matlabbatch{end}.spm.tools.preproc8.tissue(5).ngaus = 4;
		  matlabbatch{end}.spm.tools.preproc8.tissue(5).native = [1 0];
		  matlabbatch{end}.spm.tools.preproc8.tissue(5).warped = [0 0];
		  matlabbatch{end}.spm.tools.preproc8.tissue(6).tpm = {'/home/global/matlab_toolbox/spm8/toolbox/Seg/TPM.nii,6'};
		  matlabbatch{end}.spm.tools.preproc8.tissue(6).ngaus = 2;
		  matlabbatch{end}.spm.tools.preproc8.tissue(6).native = [0 0];
		  matlabbatch{end}.spm.tools.preproc8.tissue(6).warped = [0 0];
		  matlabbatch{end}.spm.tools.preproc8.warp.mrf = 0;
		  matlabbatch{end}.spm.tools.preproc8.warp.reg = 4;
		  matlabbatch{end}.spm.tools.preproc8.warp.affreg = 'mni';
		  matlabbatch{end}.spm.tools.preproc8.warp.samp = 3;
		  matlabbatch{end}.spm.tools.preproc8.warp.write = [0 0];		  
		end
			
		spm_jobman('run',matlabbatch);
EOF

	elif [ ${oldSeg} -eq 0 ]
	then
		matlab -nodisplay <<EOF
		%% Load Matlab Path: Matlab 14 and SPM12 needed
		cd ${HOME}
		p = pathdef14_SPM12;
		addpath(p);
		
		rt1_path = '${DIR}/pet.adni/${pvedir}/rt1.BS7.lps.img';
		
		%% Step 4. Segment rt1.BS7.lps.img using SPM12 segment function + imported DARTEL %%
		
		% Init of spm_jobman
		close all
		spm('defaults', 'PET');
		spm_jobman('initcfg');
		matlabbatch={};
		
		if strcmp('${TypeSubj}','control')
		  matlabbatch{end+1}.spm.spatial.preproc.channel.vols = {[rt1_path ',1']};
		  matlabbatch{end}.spm.spatial.preproc.channel.biasreg = 0.001;
		  matlabbatch{end}.spm.spatial.preproc.channel.biasfwhm = 60;
		  matlabbatch{end}.spm.spatial.preproc.channel.write = [0 1];
		  matlabbatch{end}.spm.spatial.preproc.tissue(1).tpm = {'/NAS/tupac/matthieu/Template/SPM12/rTPM.nii,1'};
		  matlabbatch{end}.spm.spatial.preproc.tissue(1).ngaus = 1;
		  matlabbatch{end}.spm.spatial.preproc.tissue(1).native = [1 1];
		  matlabbatch{end}.spm.spatial.preproc.tissue(1).warped = [0 0];
		  matlabbatch{end}.spm.spatial.preproc.tissue(2).tpm = {'/NAS/tupac/matthieu/Template/SPM12/rTPM.nii,2'};
		  matlabbatch{end}.spm.spatial.preproc.tissue(2).ngaus = 1;
		  matlabbatch{end}.spm.spatial.preproc.tissue(2).native = [1 1];
		  matlabbatch{end}.spm.spatial.preproc.tissue(2).warped = [0 0];
		  matlabbatch{end}.spm.spatial.preproc.tissue(3).tpm = {'/NAS/tupac/matthieu/Template/SPM12/rTPM.nii,3'};
		  matlabbatch{end}.spm.spatial.preproc.tissue(3).ngaus = 2;
		  matlabbatch{end}.spm.spatial.preproc.tissue(3).native = [1 0];
		  matlabbatch{end}.spm.spatial.preproc.tissue(3).warped = [0 0];
		  matlabbatch{end}.spm.spatial.preproc.tissue(4).tpm = {'/NAS/tupac/matthieu/Template/SPM12/rTPM.nii,4'};
		  matlabbatch{end}.spm.spatial.preproc.tissue(4).ngaus = 3;
		  matlabbatch{end}.spm.spatial.preproc.tissue(4).native = [1 0];
		  matlabbatch{end}.spm.spatial.preproc.tissue(4).warped = [0 0];
		  matlabbatch{end}.spm.spatial.preproc.tissue(5).tpm = {'/NAS/tupac/matthieu/Template/SPM12/rTPM.nii,5'};
		  matlabbatch{end}.spm.spatial.preproc.tissue(5).ngaus = 4;
		  matlabbatch{end}.spm.spatial.preproc.tissue(5).native = [1 0];
		  matlabbatch{end}.spm.spatial.preproc.tissue(5).warped = [0 0];
		  matlabbatch{end}.spm.spatial.preproc.tissue(6).tpm = {'/NAS/tupac/matthieu/Template/SPM12/rTPM.nii,6'};
		  matlabbatch{end}.spm.spatial.preproc.tissue(6).ngaus = 2;
		  matlabbatch{end}.spm.spatial.preproc.tissue(6).native = [0 0];
		  matlabbatch{end}.spm.spatial.preproc.tissue(6).warped = [0 0];
		  matlabbatch{end}.spm.spatial.preproc.warp.mrf = 1;
		  matlabbatch{end}.spm.spatial.preproc.warp.cleanup = 1;
		  matlabbatch{end}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
		  matlabbatch{end}.spm.spatial.preproc.warp.affreg = 'mni';
		  matlabbatch{end}.spm.spatial.preproc.warp.fwhm = 0;
		  matlabbatch{end}.spm.spatial.preproc.warp.samp = 3;
		  matlabbatch{end}.spm.spatial.preproc.warp.write = [0 0];
		  
		elseif strcmp('${TypeSubj}','patient')
		  matlabbatch{end+1}.spm.spatial.preproc.channel.vols = {[rt1_path ',1']};
		  matlabbatch{end}.spm.spatial.preproc.channel.biasreg = 0.001;
		  matlabbatch{end}.spm.spatial.preproc.channel.biasfwhm = 60;
		  matlabbatch{end}.spm.spatial.preproc.channel.write = [0 1];
		  matlabbatch{end}.spm.spatial.preproc.tissue(1).tpm = {'/home/global/matlab_toolbox/spm12/tpm/TPM.nii,1'};
		  matlabbatch{end}.spm.spatial.preproc.tissue(1).ngaus = 1;
		  matlabbatch{end}.spm.spatial.preproc.tissue(1).native = [1 1];
		  matlabbatch{end}.spm.spatial.preproc.tissue(1).warped = [0 0];
		  matlabbatch{end}.spm.spatial.preproc.tissue(2).tpm = {'/home/global/matlab_toolbox/spm12/tpm/TPM.nii,2'};
		  matlabbatch{end}.spm.spatial.preproc.tissue(2).ngaus = 1;
		  matlabbatch{end}.spm.spatial.preproc.tissue(2).native = [1 1];
		  matlabbatch{end}.spm.spatial.preproc.tissue(2).warped = [0 0];
		  matlabbatch{end}.spm.spatial.preproc.tissue(3).tpm = {'/home/global/matlab_toolbox/spm12/tpm/TPM.nii,3'};
		  matlabbatch{end}.spm.spatial.preproc.tissue(3).ngaus = 2;
		  matlabbatch{end}.spm.spatial.preproc.tissue(3).native = [1 0];
		  matlabbatch{end}.spm.spatial.preproc.tissue(3).warped = [0 0];
		  matlabbatch{end}.spm.spatial.preproc.tissue(4).tpm = {'/home/global/matlab_toolbox/spm12/tpm/TPM.nii,4'};
		  matlabbatch{end}.spm.spatial.preproc.tissue(4).ngaus = 3;
		  matlabbatch{end}.spm.spatial.preproc.tissue(4).native = [1 0];
		  matlabbatch{end}.spm.spatial.preproc.tissue(4).warped = [0 0];
		  matlabbatch{end}.spm.spatial.preproc.tissue(5).tpm = {'/home/global/matlab_toolbox/spm12/tpm/TPM.nii,5'};
		  matlabbatch{end}.spm.spatial.preproc.tissue(5).ngaus = 4;
		  matlabbatch{end}.spm.spatial.preproc.tissue(5).native = [1 0];
		  matlabbatch{end}.spm.spatial.preproc.tissue(5).warped = [0 0];
		  matlabbatch{end}.spm.spatial.preproc.tissue(6).tpm = {'/home/global/matlab_toolbox/spm12/tpm/TPM.nii,6'};
		  matlabbatch{end}.spm.spatial.preproc.tissue(6).ngaus = 2;
		  matlabbatch{end}.spm.spatial.preproc.tissue(6).native = [0 0];
		  matlabbatch{end}.spm.spatial.preproc.tissue(6).warped = [0 0];
		  matlabbatch{end}.spm.spatial.preproc.warp.mrf = 1;
		  matlabbatch{end}.spm.spatial.preproc.warp.cleanup = 1;
		  matlabbatch{end}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
		  matlabbatch{end}.spm.spatial.preproc.warp.affreg = 'mni';
		  matlabbatch{end}.spm.spatial.preproc.warp.fwhm = 0;
		  matlabbatch{end}.spm.spatial.preproc.warp.samp = 3;
		  matlabbatch{end}.spm.spatial.preproc.warp.write = [0 0];
		end
		
		spm_jobman('run',matlabbatch);
EOF
	fi

	matlab -nodisplay <<EOF
		
	%% Load Matlab Path: Matlab 14 and SPM8 version for pvelab2012
	cd ${HOME}
	p = pathdef;
	addpath(p);
	
	rt1_path = '${DIR}/pet.adni/${pvedir}/rt1.BS7.lps.img';
	pet_path = '${DIR}/pet.adni/${pvedir}/PET.BS7.lps.sm8.img';
	
	%% Step 5. Rescale prob maps to [0 255], rename them to rt1.BS7.lps_segN.img and create rt1.BS7.lps_GMROI.img %%
	
	Vt1   = spm_vol(rt1_path);
	Vseg1 = spm_vol('${DIR}/pet.adni/${pvedir}/c1rt1.BS7.lps.nii');
	Vseg2 = spm_vol('${DIR}/pet.adni/${pvedir}/c2rt1.BS7.lps.nii');
	Vseg3 = spm_vol('${DIR}/pet.adni/${pvedir}/c3rt1.BS7.lps.nii');
	delete('${DIR}/pet.adni/${pvedir}/c4rt1.BS7.lps.nii');
	delete('${DIR}/pet.adni/${pvedir}/c5rt1.BS7.lps.nii');

	[Y1, XYZ] = spm_read_vols(Vseg1);
	[Y2, XYZ] = spm_read_vols(Vseg2);
	[Y3, XYZ] = spm_read_vols(Vseg3);
		
	Vseg1.fname = '${DIR}/pet.adni/${pvedir}/rt1.BS7.lps_seg1.img';
	spm_write_vol(Vseg1, Y1);
	Vseg2.fname = '${DIR}/pet.adni/${pvedir}/rt1.BS7.lps_seg2.img';
	spm_write_vol(Vseg2, Y2);
	Vseg3.fname = '${DIR}/pet.adni/${pvedir}/rt1.BS7.lps_seg3.img';
	spm_write_vol(Vseg3, Y3);

	[seg1,hseg]=ReadAnalyzeImg('${DIR}/pet.adni/${pvedir}/rt1.BS7.lps_seg1.img');
	seg1=double(seg1);
	[seg2,hseg]=ReadAnalyzeImg('${DIR}/pet.adni/${pvedir}/rt1.BS7.lps_seg2.img');
	seg2=double(seg2);
	[seg3,hseg]=ReadAnalyzeImg('${DIR}/pet.adni/${pvedir}/rt1.BS7.lps_seg3.img');
	seg3=double(seg3);
	
	seg4=255-(seg1+seg2+seg3);
	[dummy,index]=max([seg1 seg2 seg3 seg4]');
	gmroi=zeros(size(seg1));
	gmroi(index==1)=51;
	gmroi(index==2)=2;
	gmroi(index==3)=3;
		
	GMROI = reshape(gmroi,Vt1.dim(1),Vt1.dim(2),Vt1.dim(3));
	Vt1.fname = '${DIR}/pet.adni/${pvedir}/rt1.BS7.lps_GMROI.img';
	Vt1.dt = [2 0];
	spm_write_vol(Vt1, GMROI);

	%% Step 6. Remove misclassified GM and WM located in dura mater from rt1.BS7.lps_GMROI.img %%
	
	V = spm_vol('${DIR}/pet.adni/${pvedir}/rt1.BS7.lps_GMROI.img');
	[GMROI, XYZ] = spm_read_vols(V);
	
	W = spm_vol('${DIR}/pet.adni/rbrainmask.npet.nii');
	[brainmask, XYZ] = spm_read_vols(W);
	
	GMROI(((GMROI==51)&(brainmask==0))|((GMROI==2)&(brainmask==0)))=0;
	V.dt = [2 0];
	spm_write_vol(V, GMROI);	
	
	%% Step 7. Launch pve correction %%

	% Load configuration file for pve correction
	configfile = '${HOME}/SVN/matlab/matthieu/pve/config_pvec_ADNI';
	
	mni = round(Vt1.dim(3) / 3);
	gmROI_path = '${DIR}/pet.adni/${pvedir}/rt1.BS7.lps_GMROI.img';
	cmdline = ['/home/global/matlab_toolbox/pvelab2012/IBB_wrapper/pve/pve64 -w -s -cs ', num2str(mni), ' ', gmROI_path, ' ', pet_path, ' ', configfile];
	fid = fopen('${DIR}/pet.adni/${pvedir}/cmdline.txt', 'w');
	fprintf(fid, '%s', cmdline);
	fclose(fid);
	disp('Performing PVC. Please wait...');
	[status, result] = unix(cmdline);

	%% Step 8. Remove NaN and negative values in rt1.BS7.lps_MGRousset.img & rt1.BS7.lps_MGCS.img %%
	
	V = spm_vol('${DIR}/pet.adni/${pvedir}/rt1.BS7.lps_MGRousset.img');
	[Y, XYZ] = spm_read_vols(V);
	Y(~isfinite(Y(:))) = 0;
	Y(Y(:) < 0) = 0;
	spm_write_vol(V, Y);
	
	V = spm_vol('${DIR}/pet.adni/${pvedir}/rt1.BS7.lps_MGCS.img');
	[Y, XYZ] = spm_read_vols(V);
	Y(~isfinite(Y(:))) = 0;
	Y(Y(:) < 0) = 0;
	spm_write_vol(V, Y);
	
	%% Step 9. Modify transformation matrix of corrected output misaligned : overwrite with PET.BS7.lps.sm8.img %%
	
	Vref = spm_vol(pet_path);
		
	Vsrc = spm_vol('${DIR}/pet.adni/${pvedir}/rt1.BS7.lps_MGRousset.img');
	Y = spm_read_vols(Vsrc);
	Vsrc.mat = Vref.mat;
	spm_write_vol(Vsrc, Y);
	
	Vsrc = spm_vol('${DIR}/pet.adni/${pvedir}/rt1.BS7.lps_MGCS.img');
	Y = spm_read_vols(Vsrc);
	Vsrc.mat = Vref.mat;
	spm_write_vol(Vsrc, Y);	
EOF
	gzip ${DIR}/pet.adni/BS7_PET.lps.sm8.nii ${DIR}/pet.adni/T1.npet.nii ${DIR}/pet.adni/rbrainmask.npet.nii ${DIR}/pet.adni/BS7_T1.npet.nii
	mri_convert ${DIR}/pet.adni/${pvedir}/rt1.BS7.lps_MGRousset.img ${DIR}/pet.adni/${pvedir}/PET.BS7.lps.sm8.MGRousset.nii.gz
	mri_convert ${DIR}/pet.adni/${pvedir}/rt1.BS7.lps_MGCS.img ${DIR}/pet.adni/${pvedir}/PET.BS7.lps.sm8.MGCS.nii.gz
fi

# # pve64 -F -s "/NAS/tupac/matthieu/PVE_lab/pve_proj_1/r_volume_GMROI.img" "/NAS/tupac/matthieu/PVE_lab/pve_proj_1/PET_RAS.img" "/NAS/tupac/matthieu/PVE_lab/pve_proj_1/config"
# # "/home/global/matlab_toolbox/pvelab2012/IBB_wrapper/pve/pve64" -cse 2 -r "/NAS/tupac/matthieu/PVE_lab/pve_proj_1/sn.mat" -w -s -cs num2str(mni) "/NAS/tupac/matthieu/PVE_lab/pve_proj_1/r_volume_GMROI.img" "/NAS/tupac/matthieu/PVE_lab/pve_proj_1/PET_RAS.img" "/NAS/tupac/matthieu/PVE_lab/pve_proj_1/config"

# ========================================================================================================================================
#                                               Compute mean values in PET ROIs (with PVC)
# ========================================================================================================================================

for type_pvc in MGRousset MGCS
do
	if [ $DoMeanRoi -eq 1 ] && [ ! -f ${DIR}/pet.adni/${pvedir}/mean.pons.pet.BS7.sm8.${type_pvc}.dat ]
	then
		mri_segstats --seg ${DIR}/pet.adni/rGMcerebellum.BS7.mask.nii.gz --id 1 --i ${DIR}/pet.adni/${pvedir}/PET.BS7.lps.sm8.${type_pvc}.nii.gz --sum ${DIR}/pet.adni/${pvedir}/mean.cerebellar.pet.BS7.sm8.${type_pvc}.dat
		mri_segstats --seg ${DIR}/pet.adni/rpons.BS7.mask.nii.gz --id 1 --i ${DIR}/pet.adni/${pvedir}/PET.BS7.lps.sm8.${type_pvc}.nii.gz --sum ${DIR}/pet.adni/${pvedir}/mean.pons.pet.BS7.sm8.${type_pvc}.dat
		mean_cerebellar_pet_sm8_pvc[${type_pvc}]=$(fslstats ${DIR}/pet.adni/${pvedir}/PET.BS7.lps.sm8.${type_pvc}.nii.gz -k ${DIR}/pet.adni/rGMcerebellum.BS7.mask.nii.gz -m)
		mean_pons_pet_sm8_pvc[${type_pvc}]=$(fslstats ${DIR}/pet.adni/${pvedir}/PET.BS7.lps.sm8.${type_pvc}.nii.gz -k ${DIR}/pet.adni/rpons.BS7.mask.nii.gz -m)
	fi
done	

# ========================================================================================================================================
#                                         Apply intensity normalization (with PVC)
# ========================================================================================================================================

for type_pvc in MGRousset MGCS
do
	if [ $DoIN -eq 1 ] && [ ! -f ${DIR}/pet.adni/${pvedir}/PET.BS7.lps.sm8.${type_pvc}.gn.nii.gz ]
	then
		# Based on anatomical reference ROI
		fslmaths ${DIR}/pet.adni/${pvedir}/PET.BS7.lps.sm8.${type_pvc}.nii.gz -div ${mean_pons_pet_sm8_pvc[${type_pvc}]} ${DIR}/pet.adni/${pvedir}/PET.BS7.lps.sm8.${type_pvc}.npons.nii.gz
		fslmaths ${DIR}/pet.adni/${pvedir}/PET.BS7.lps.sm8.${type_pvc}.nii.gz -div ${mean_cerebellar_pet_sm8_pvc[${type_pvc}]} ${DIR}/pet.adni/${pvedir}/PET.BS7.lps.sm8.${type_pvc}.ncereb.nii.gz

		# Global normalization based on SPM
		gunzip ${DIR}/pet.adni/${pvedir}/PET.BS7.lps.sm8.${type_pvc}.nii.gz
		matlab -nodisplay <<EOF
			% Load Matlab Path: Matlab 14 and SPM12 needed
			cd ${HOME}
			p = pathdef14_SPM12;
			addpath(p);
			
			% Compute global mean
			V = spm_data_hdr_read('${DIR}/pet.adni/${pvedir}/PET.BS7.lps.sm8.${type_pvc}.nii');
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
			V.fname = '${DIR}/pet.adni/${pvedir}/PET.BS7.lps.sm8.${type_pvc}.gn.nii';
			spm_write_vol(V,PET_gnorm);	
EOF
		gzip ${DIR}/pet.adni/${pvedir}/PET.BS7.lps.sm8.${type_pvc}.nii ${DIR}/pet.adni/${pvedir}/PET.BS7.lps.sm8.${type_pvc}.gn.nii
	fi
done

# ========================================================================================================================================
#                                  Compute PET brain mask : avoid to project non-existing PET signal
# ========================================================================================================================================

if [ $DoMask -eq 1 ] && [ ! -f ${DIR}/pet.adni/BS7_PET.lps.brain_mask.dil1.nii.gz ]
then
# 	# Extract brain mask from T1_FS then apply it to PET space
# 	bet ${DIR}/pet.adni/T1_FS.nii.gz ${DIR}/pet.adni/T1_brain -R -f 0.3 -m
# 	mri_morphology ${DIR}/pet.adni/T1_brain_mask.nii.gz dilate 1 ${DIR}/pet.adni/T1_brain_mask_dil1.nii.gz
# 	mri_vol2vol --mov ${DIR}/pet.adni/PET_RAS.nii.gz --targ ${DIR}/pet.adni/T1_brain_mask_dil1.nii.gz --o ${DIR}/pet.adni/rbrain_mask.nii.gz --inv --reg ${DIR}/pet.adni/Pet2T1.register.dof6.dat --nearest --no-save-reg

	# Extract brain mask from PET_RAS
	bet ${DIR}/pet.adni/BS7_PET.lps.nii.gz ${DIR}/pet.adni/BS7_PET.lps.brain -R -f 0.6 -m
	mri_morphology ${DIR}/pet.adni/BS7_PET.lps.brain_mask.nii.gz dilate 1 ${DIR}/pet.adni/BS7_PET.lps.brain_mask.dil1.nii.gz
fi

# ========================================================================================================================================
#                                  Resample PET data onto native and common surfaces
# ========================================================================================================================================


if [ $DoSBA -eq 1 ] && [ ! -f ${DIR}/pet.adni/${pvedir}/surf/rh.PET.BS7.lps.sm8.MGCS.gn.fsaverage.sm10.mgh ]
then
# 	if [ -d ${DIR}/pet.adni/surf ]
# 	then
# 	    rm -rf ${DIR}/pet.adni/surf/*
# 	else
# 	    mkdir ${DIR}/pet.adni/surf
# 	fi
	
	if [ -d ${DIR}/pet.adni/${pvedir}/surf ]
	then
	    rm -rf ${DIR}/pet.adni/${pvedir}/surf/*
	else
	    mkdir ${DIR}/pet.adni/${pvedir}/surf
	fi

# 	## Resample brain mask onto native surface
# 	mri_vol2surf --mov ${DIR}/pet.adni/BS7_PET.lps.brain_mask.dil1.nii.gz --reg ${DIR}/pet.adni/Pet2T1.BS7.register.dof6.dat --trgsubject ${SUBJECT_ID} --interp nearest --projfrac 0.5 --hemi lh --o ${DIR}/pet.adni/surf/lh.PET.lps.BS7.brain_mask.nii --noreshape --cortex --surfreg sphere.reg
# 	mri_vol2surf --mov ${DIR}/pet.adni/BS7_PET.lps.brain_mask.dil1.nii.gz --reg ${DIR}/pet.adni/Pet2T1.BS7.register.dof6.dat --trgsubject ${SUBJECT_ID} --interp nearest --projfrac 0.5 --hemi rh --o ${DIR}/pet.adni/surf/rh.PET.lps.BS7.brain_mask.nii --noreshape --cortex --surfreg sphere.reg
# 
# 	## Resample brain mask onto fs_average surface
# 	mri_vol2surf --mov ${DIR}/pet.adni/BS7_PET.lps.brain_mask.dil1.nii.gz --reg ${DIR}/pet.adni/Pet2T1.BS7.register.dof6.dat --trgsubject fsaverage --interp nearest --projfrac 0.5 --hemi lh --o ${DIR}/pet.adni/surf/lh.PET.lps.BS7.brain_mask.fsaverage.nii --noreshape --cortex --surfreg sphere.reg
# 	mri_vol2surf --mov ${DIR}/pet.adni/BS7_PET.lps.brain_mask.dil1.nii.gz --reg ${DIR}/pet.adni/Pet2T1.BS7.register.dof6.dat --trgsubject fsaverage --interp nearest --projfrac 0.5 --hemi rh --o ${DIR}/pet.adni/surf/rh.PET.lps.BS7.brain_mask.fsaverage.nii --noreshape --cortex --surfreg sphere.reg
	
	for type_norm in npons ncereb gn
	do	
# 		## Resample onto native surface
# 		
# 		# lh
# 		mri_vol2surf --mov ${DIR}/pet.adni/PET.lps.BS7.sm8.${type_norm}.nii.gz --reg ${DIR}/pet.adni/Pet2T1.BS7.register.dof6.dat --trgsubject ${SUBJECT_ID} --interp trilin --projfrac 0.5 --hemi lh --o ${DIR}/pet.adni/surf/lh.PET.lps.BS7.sm8.${type_norm}.mgh --noreshape --cortex --surfreg sphere.reg
# 
# 		# rh
# 		mri_vol2surf --mov ${DIR}/pet.adni/PET.lps.BS7.sm8.${type_norm}.nii.gz --reg ${DIR}/pet.adni/Pet2T1.BS7.register.dof6.dat --trgsubject ${SUBJECT_ID} --interp trilin --projfrac 0.5 --hemi rh --o ${DIR}/pet.adni/surf/rh.PET.lps.BS7.sm8.${type_norm}.mgh --noreshape --cortex --surfreg sphere.reg
# 		
# 		# smooth
# 		for fwhmsurf in 0 1 2 4 5 6 8 10
# 		do
# 	# 		mri_surf2surf --hemi lh --s ${SUBJECT_ID} --fwhm ${fwhmsurf} --label-trg ${DIR}/pet.adni/surf/lh.PET_brain_mask.label --sval ${DIR}/pet.adni/surf/lh.PET_${type_norm}.mgh --tval ${DIR}/pet.adni/surf/lh.PET_${type_norm}.sm${fwhmsurf}.mgh
# 			mris_fwhm --s ${SUBJECT_ID} --hemi lh --smooth-only --i ${DIR}/pet.adni/surf/lh.PET.lps.BS7.sm8.${type_norm}.mgh --fwhm ${fwhmsurf} --o ${DIR}/pet.adni/surf/lh.PET.lps.BS7.sm8.${type_norm}.sm${fwhmsurf}.mgh --mask ${DIR}/pet.adni/surf/lh.PET.lps.BS7.brain_mask.nii
# 			mris_fwhm --s ${SUBJECT_ID} --hemi rh --smooth-only --i ${DIR}/pet.adni/surf/rh.PET.lps.BS7.sm8.${type_norm}.mgh --fwhm ${fwhmsurf} --o ${DIR}/pet.adni/surf/rh.PET.lps.BS7.sm8.${type_norm}.sm${fwhmsurf}.mgh --mask ${DIR}/pet.adni/surf/rh.PET.lps.BS7.brain_mask.nii
# 		done	
# 
# 		## Resample onto fsaverage
# 
# 		# lh
# 		mri_vol2surf --mov ${DIR}/pet.adni/PET.lps.BS7.sm8.${type_norm}.nii.gz --reg ${DIR}/pet.adni/Pet2T1.BS7.register.dof6.dat --trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi lh --o ${DIR}/pet.adni/surf/lh.PET.lps.BS7.sm8.${type_norm}.fsaverage.mgh --noreshape --cortex --surfreg sphere.reg
# 
# 		# rh
# 		mri_vol2surf --mov ${DIR}/pet.adni/PET.lps.BS7.sm8.${type_norm}.nii.gz --reg ${DIR}/pet.adni/Pet2T1.BS7.register.dof6.dat --trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi rh --o ${DIR}/pet.adni/surf/rh.PET.lps.BS7.sm8.${type_norm}.fsaverage.mgh --noreshape --cortex --surfreg sphere.reg
# 
# 		# smooth
# 		for fwhmsurf in 0 1 2 4 5 6 8 10
# 		do
# 			mris_fwhm --s fsaverage --hemi lh --smooth-only --i ${DIR}/pet.adni/surf/lh.PET.lps.BS7.sm8.${type_norm}.fsaverage.mgh --fwhm ${fwhmsurf} --o ${DIR}/pet.adni/surf/lh.PET.lps.BS7.sm8.${type_norm}.fsaverage.sm${fwhmsurf}.mgh --mask ${DIR}/pet.adni/surf/lh.PET.lps.BS7.brain_mask.fsaverage.nii
# 			mris_fwhm --s fsaverage --hemi rh --smooth-only --i ${DIR}/pet.adni/surf/rh.PET.lps.BS7.sm8.${type_norm}.fsaverage.mgh --fwhm ${fwhmsurf} --o ${DIR}/pet.adni/surf/rh.PET.lps.BS7.sm8.${type_norm}.fsaverage.sm${fwhmsurf}.mgh --mask ${DIR}/pet.adni/surf/rh.PET.lps.BS7.brain_mask.fsaverage.nii
# 		done	
		
		for type_pvc in MGRousset MGCS
		do
			## Resample onto native surface
			
			# lh
			mri_vol2surf --mov ${DIR}/pet.adni/${pvedir}/PET.BS7.lps.sm8.${type_pvc}.${type_norm}.nii.gz --reg ${DIR}/pet.adni/Pet2T1.BS7.register.dof6.dat --trgsubject ${SUBJECT_ID} --interp trilin --projfrac 0.5 --hemi lh --o ${DIR}/pet.adni/${pvedir}/surf/lh.PET.BS7.lps.sm8.${type_pvc}.${type_norm}.mgh --noreshape --cortex --surfreg sphere.reg

			# rh
			mri_vol2surf --mov ${DIR}/pet.adni/${pvedir}/PET.BS7.lps.sm8.${type_pvc}.${type_norm}.nii.gz --reg ${DIR}/pet.adni/Pet2T1.BS7.register.dof6.dat --trgsubject ${SUBJECT_ID} --interp trilin --projfrac 0.5 --hemi rh --o ${DIR}/pet.adni/${pvedir}/surf/rh.PET.BS7.lps.sm8.${type_pvc}.${type_norm}.mgh --noreshape --cortex --surfreg sphere.reg
			
			# smooth
			for fwhmsurf in 0 1 2 4 5 6 8 10 12
			do
				mris_fwhm --s ${SUBJECT_ID} --hemi lh --smooth-only --i ${DIR}/pet.adni/${pvedir}/surf/lh.PET.BS7.lps.sm8.${type_pvc}.${type_norm}.mgh --fwhm ${fwhmsurf} --o ${DIR}/pet.adni/${pvedir}/surf/lh.PET.BS7.lps.sm8.${type_pvc}.${type_norm}.sm${fwhmsurf}.mgh --mask ${DIR}/pet.adni/surf/lh.PET.lps.BS7.brain_mask.nii
				mris_fwhm --s ${SUBJECT_ID} --hemi rh --smooth-only --i ${DIR}/pet.adni/${pvedir}/surf/rh.PET.BS7.lps.sm8.${type_pvc}.${type_norm}.mgh --fwhm ${fwhmsurf} --o ${DIR}/pet.adni/${pvedir}/surf/rh.PET.BS7.lps.sm8.${type_pvc}.${type_norm}.sm${fwhmsurf}.mgh --mask ${DIR}/pet.adni/surf/rh.PET.lps.BS7.brain_mask.nii
			done	

			## Resample onto fsaverage

			# lh
			mri_vol2surf --mov ${DIR}/pet.adni/${pvedir}/PET.BS7.lps.sm8.${type_pvc}.${type_norm}.nii.gz --reg ${DIR}/pet.adni/Pet2T1.BS7.register.dof6.dat --trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi lh --o ${DIR}/pet.adni/${pvedir}/surf/lh.PET.BS7.lps.sm8.${type_pvc}.${type_norm}.fsaverage.mgh --noreshape --cortex --surfreg sphere.reg

			# rh
			mri_vol2surf --mov ${DIR}/pet.adni/${pvedir}/PET.BS7.lps.sm8.${type_pvc}.${type_norm}.nii.gz --reg ${DIR}/pet.adni/Pet2T1.BS7.register.dof6.dat --trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi rh --o ${DIR}/pet.adni/${pvedir}/surf/rh.PET.BS7.lps.sm8.${type_pvc}.${type_norm}.fsaverage.mgh --noreshape --cortex --surfreg sphere.reg

			# smooth
			for fwhmsurf in 0 1 2 4 5 6 8 10 12
			do
				mris_fwhm --s fsaverage --hemi lh --smooth-only --i ${DIR}/pet.adni/${pvedir}/surf/lh.PET.BS7.lps.sm8.${type_pvc}.${type_norm}.fsaverage.mgh --fwhm ${fwhmsurf} --o ${DIR}/pet.adni/${pvedir}/surf/lh.PET.BS7.lps.sm8.${type_pvc}.${type_norm}.fsaverage.sm${fwhmsurf}.mgh --mask ${DIR}/pet.adni/surf/lh.PET.lps.BS7.brain_mask.fsaverage.nii
				mris_fwhm --s fsaverage --hemi rh --smooth-only --i ${DIR}/pet.adni/${pvedir}/surf/rh.PET.BS7.lps.sm8.${type_pvc}.${type_norm}.fsaverage.mgh --fwhm ${fwhmsurf} --o ${DIR}/pet.adni/${pvedir}/surf/rh.PET.BS7.lps.sm8.${type_pvc}.${type_norm}.fsaverage.sm${fwhmsurf}.mgh --mask ${DIR}/pet.adni/surf/rh.PET.lps.BS7.brain_mask.fsaverage.nii
			done
		done
	done
fi

# ========================================================================================================================================
#                                  Non-linear registration of PET data onto MNI space
# ========================================================================================================================================

if [ $DoSPMNorm -eq 1 ] && [ ! -f ${DIR}/pet.adni/${pvedir}/wPET.lps.BS7.sm8.MGCS.gn.sm12.nii.gz ]
then
	if [ ! -d ${DIR}/pet.adni/SPMNorm ]
	then
		mkdir ${DIR}/pet.adni/SPMNorm
	fi

	if [ "${TypeSubj}" == "control" ]
	then 		
		gunzip ${DIR}/pet.adni/T1.npet.nii.gz ${DIR}/pet.adni/BS7_PET.lps.sm8.nii.gz
		rm -f ${DIR}/pet.adni/rT1.npet.nii* ${DIR}/pet.adni/rBS7_PET.lps.sm8.nii* ${DIR}/pet.adni/rPET.lps.BS7.sm8.gn.nii* ${DIR}/pet.adni/rPET.lps.BS7.sm8.ncereb.nii* ${DIR}/pet.adni/rPET.lps.BS7.sm8.npons.nii*		
		if [ ${oldNorm} -eq 0 ]
		then		
			rm -f ${DIR}/pet.adni/wrT1.npet.nii* ${DIR}/pet.adni/y_rT1.npet.nii*
			for type_norm in npons ncereb gn
			do
				gunzip ${DIR}/pet.adni/PET.lps.BS7.sm8.${type_norm}.nii.gz
				rm -f ${DIR}/pet.adni/wrPET.lps.BS7.sm8.${type_norm}.nii* ${DIR}/pet.adni/SPMNorm/wrPET.lps.BS7.sm8.${type_norm}.sm*.nii*
		# 		for type_pvc in MGRousset MGCS
		# 		do
		# 			gunzip ${DIR}/pet.adni/${pvedir}/PET.BS7.lps.sm8.${type_pvc}.${type_norm}.nii.gz
		# 			rm -f ${DIR}/pet.adni/${pvedir}/wrPET.BS7.lps.sm8.${type_pvc}.${type_norm}.nii*
		# 		done
			done
		elif [ ${oldNorm} -eq 1 ]
		then					
			rm -f ${DIR}/pet.adni/wprT1.npet.nii* ${DIR}/pet.adni/rBS7_PET.lps.sm8_sn.mat	
			for type_norm in npons ncereb gn
			do					
				gunzip ${DIR}/pet.adni/PET.lps.BS7.sm8.${type_norm}.nii.gz
				rm -f ${DIR}/pet.adni/wprPET.lps.BS7.sm8.${type_norm}.nii*  ${DIR}/pet.adni/SPMNorm/wprPET.lps.BS7.sm8.${type_norm}.sm*.nii*
		# 		for type_pvc in MGRousset MGCS
		# 		do
		# 			gunzip ${DIR}/pet.adni/${pvedir}/PET.BS7.lps.sm8.${type_pvc}.${type_norm}.nii.gz
		# 			rm -f ${DIR}/pet.adni/${pvedir}/wprPET.BS7.lps.sm8.${type_pvc}.${type_norm}.nii*
		# 		done			
			done
		fi
		
		matlab -nodisplay <<EOF
		%% Load Matlab Path: Matlab 14 and SPM12 needed
		cd ${HOME}
		p = pathdef14_SPM12;
		addpath(p);

		%% Init of spm_jobman
		spm('defaults', 'PET');
		spm_jobman('initcfg');
		matlabbatch={};
		
		%% Step 1. Reorient T1 and PET images near MNI_T1_1mm template
		matlabbatch{end+1}.spm.util.reorient.srcfiles = {
								  '${DIR}/pet.adni/T1.npet.nii,1'
								  '${DIR}/pet.adni/BS7_PET.lps.sm8.nii,1'
								  '${DIR}/pet.adni/PET.lps.BS7.sm8.gn.nii,1'
								  '${DIR}/pet.adni/PET.lps.BS7.sm8.ncereb.nii,1'
								  '${DIR}/pet.adni/PET.lps.BS7.sm8.npons.nii,1'
								};
		matlabbatch{end}.spm.util.reorient.transform.transM = [1 0 0 115
								      0 1 0 100
								      0 0 1 -50
								      0 0 0 1];
		matlabbatch{end}.spm.util.reorient.prefix = 'r';
		
		spm_jobman('run',matlabbatch);

		%% Step 2. Normalize estimate
		clear matlabbatch
		matlabbatch={};
		
		if ${oldNorm}==0
			matlabbatch{end+1}.spm.spatial.normalise.est.subj.vol = {'${DIR}/pet.adni/rT1.npet.nii,1'};
			matlabbatch{end}.spm.spatial.normalise.est.eoptions.biasreg = 0.0001;
			matlabbatch{end}.spm.spatial.normalise.est.eoptions.biasfwhm = 60;
			matlabbatch{end}.spm.spatial.normalise.est.eoptions.tpm = {'/home/global/matlab_toolbox/spm12/tpm/TPM.nii'};
			matlabbatch{end}.spm.spatial.normalise.est.eoptions.affreg = 'mni';
			matlabbatch{end}.spm.spatial.normalise.est.eoptions.reg = [0 0.001 0.5 0.05 0.2];
			matlabbatch{end}.spm.spatial.normalise.est.eoptions.fwhm = 0;
			matlabbatch{end}.spm.spatial.normalise.est.eoptions.samp = 3;
		elseif ${oldNorm}==1
			matlabbatch{end+1}.spm.tools.oldnorm.est.subj.source     = cellstr('${DIR}/pet.adni/rBS7_PET.lps.sm8.nii');
			matlabbatch{end}.spm.tools.oldnorm.est.subj.wtsrc        = '';
			matlabbatch{end}.spm.tools.oldnorm.est.eoptions.template = {'/home/global/matlab_toolbox/spm12/toolbox/OldNorm/TEMPLATE_FDGPET_100.nii,1'};
			matlabbatch{end}.spm.tools.oldnorm.est.eoptions.weight   = '';
			matlabbatch{end}.spm.tools.oldnorm.est.eoptions.smosrc   = 8;
			matlabbatch{end}.spm.tools.oldnorm.est.eoptions.smoref   = 0;
			matlabbatch{end}.spm.tools.oldnorm.est.eoptions.regtype  = 'mni';
			matlabbatch{end}.spm.tools.oldnorm.est.eoptions.cutoff   = 25;
			matlabbatch{end}.spm.tools.oldnorm.est.eoptions.nits     = 16;
			matlabbatch{end}.spm.tools.oldnorm.est.eoptions.reg      = 1;
		end
		
		spm_jobman('run',matlabbatch);
		
		%% Step 3. Normalize write
		clear matlabbatch 
		matlabbatch = {};
		
		if ${oldNorm}==0
			matlabbatch{end+1}.spm.spatial.normalise.write.subj.def = {'${DIR}/pet.adni/y_rT1.npet.nii'};
			matlabbatch{end}.spm.spatial.normalise.write.subj.resample = {
										    '${DIR}/pet.adni/rPET.lps.BS7.sm8.gn.nii,1'
										    '${DIR}/pet.adni/rPET.lps.BS7.sm8.ncereb.nii,1'
										    '${DIR}/pet.adni/rPET.lps.BS7.sm8.npons.nii,1'
										    '${DIR}/pet.adni/rT1.npet.nii,1'
										    };
			matlabbatch{end}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
										  78 76 85];
			matlabbatch{end}.spm.spatial.normalise.write.woptions.vox = [2 2 2];
			matlabbatch{end}.spm.spatial.normalise.write.woptions.interp = 4;
			matlabbatch{end}.spm.spatial.normalise.write.woptions.prefix = 'w';
		elseif ${oldNorm}==1
			matlabbatch{end+1}.spm.tools.oldnorm.write.subj.matname    = cellstr('${DIR}/pet.adni/rBS7_PET.lps.sm8_sn.mat');
			matlabbatch{end}.spm.tools.oldnorm.write.subj.resample     = {
										    '${DIR}/pet.adni/rPET.lps.BS7.sm8.gn.nii,1'
										    '${DIR}/pet.adni/rPET.lps.BS7.sm8.ncereb.nii,1'
										    '${DIR}/pet.adni/rPET.lps.BS7.sm8.npons.nii,1'
										    '${DIR}/pet.adni/rT1.npet.nii'
										    };
			matlabbatch{end}.spm.tools.oldnorm.write.roptions.preserve = 0;
			matlabbatch{end}.spm.tools.oldnorm.write.roptions.bb       = [-78 -112 -70; 78 76 85];
			matlabbatch{end}.spm.tools.oldnorm.write.roptions.vox      = [2 2 2];
			matlabbatch{end}.spm.tools.oldnorm.write.roptions.interp   = 4;
			matlabbatch{end}.spm.tools.oldnorm.write.roptions.wrap     = [0 0 0];
			matlabbatch{end}.spm.tools.oldnorm.write.roptions.prefix   = 'wp';
		end

		spm_jobman('run',matlabbatch);

		%% Step 4. Remove NaN and negative values in normalized PET images %%
		
		if ${oldNorm}==0
			V = spm_vol('${DIR}/pet.adni/wrPET.lps.BS7.sm8.gn.nii');
			[Y, XYZ] = spm_read_vols(V);
			Y(~isfinite(Y(:))) = 0;
			Y(Y(:) < 0) = 0;
			spm_write_vol(V, Y);
			
			V = spm_vol('${DIR}/pet.adni/wrPET.lps.BS7.sm8.ncereb.nii');
			[Y, XYZ] = spm_read_vols(V);
			Y(~isfinite(Y(:))) = 0;
			Y(Y(:) < 0) = 0;
			spm_write_vol(V, Y);
			
			V = spm_vol('${DIR}/pet.adni/wrPET.lps.BS7.sm8.npons.nii');
			[Y, XYZ] = spm_read_vols(V);
			Y(~isfinite(Y(:))) = 0;
			Y(Y(:) < 0) = 0;
			spm_write_vol(V, Y);
		elseif ${oldNorm}==1
			V = spm_vol('${DIR}/pet.adni/wprPET.lps.BS7.sm8.gn.nii');
			[Y, XYZ] = spm_read_vols(V);
			Y(~isfinite(Y(:))) = 0;
			Y(Y(:) < 0) = 0;
			spm_write_vol(V, Y);
			
			V = spm_vol('${DIR}/pet.adni/wprPET.lps.BS7.sm8.ncereb.nii');
			[Y, XYZ] = spm_read_vols(V);
			Y(~isfinite(Y(:))) = 0;
			Y(Y(:) < 0) = 0;
			spm_write_vol(V, Y);
			
			V = spm_vol('${DIR}/pet.adni/wprPET.lps.BS7.sm8.npons.nii');
			[Y, XYZ] = spm_read_vols(V);
			Y(~isfinite(Y(:))) = 0;
			Y(Y(:) < 0) = 0;
			spm_write_vol(V, Y);
		end
EOF

		gzip ${DIR}/pet.adni/*.nii
	# 	${DIR}/pet.adni/${pvedir}/*.nii
		
		# Smooth PET data normalized to MNI152 space
		for type_norm in npons ncereb gn
		do
			for fwhmvol in 0 2 4 5 6 8 10 12
			do
				Sigma=`echo "$fwhmvol / ( 2 * ( sqrt ( 2 * l ( 2 ) ) ) )" | bc -l`
				if [ ${oldNorm} -eq 0 ]
				then
					fslmaths ${DIR}/pet.adni/wrPET.lps.BS7.sm8.${type_norm}.nii.gz -mas ${SUBJECTS_DIR}/MNI152_T1_1mm/firstSeg/MNI152_T1_2mm_subCort_mask.nii -kernel gauss ${Sigma} -fmean ${DIR}/pet.adni/SPMNorm/wrPET.lps.BS7.sm8.${type_norm}.sm${fwhmvol}.nii.gz
					gunzip ${DIR}/pet.adni/SPMNorm/wrPET.lps.BS7.sm8.${type_norm}.sm${fwhmvol}.nii.gz
	# 				for type_pvc in MGRousset MGCS
	# 				do
	# 					fslmaths ${DIR}/pet.adni/${pvedir}/wrPET.BS7.lps.sm8.${type_pvc}.${type_norm}.nii.gz -mas ${SUBJECTS_DIR}/MNI152_T1_1mm/firstSeg/MNI152_T1_2mm_subCort_mask.nii -kernel gauss ${Sigma} -fmean ${DIR}/pet.adni/SPMNorm/wrPET.BS7.lps.sm8.${type_pvc}.${type_norm}.sm${fwhmvol}.nii.gz
	# 					gunzip ${DIR}/pet.adni/SPMNorm/wrPET.BS7.lps.sm8.${type_pvc}.${type_norm}.sm${fwhmvol}.nii.gz
	# 				done
				elif [ ${oldNorm} -eq 1 ]
				then	
					fslmaths ${DIR}/pet.adni/wprPET.lps.BS7.sm8.${type_norm}.nii.gz -mas ${SUBJECTS_DIR}/MNI152_T1_1mm/firstSeg/MNI152_T1_2mm_PET_subCort_mask.nii -kernel gauss ${Sigma} -fmean ${DIR}/pet.adni/SPMNorm/wprPET.lps.BS7.sm8.${type_norm}.sm${fwhmvol}.nii.gz
					gunzip ${DIR}/pet.adni/SPMNorm/wprPET.lps.BS7.sm8.${type_norm}.sm${fwhmvol}.nii.gz
	# 				for type_pvc in MGRousset MGCS
	# 				do
	# 					fslmaths ${DIR}/pet.adni/${pvedir}/wprPET.BS7.lps.${type_pvc}.${type_norm}.nii.gz -mas ${SUBJECTS_DIR}/MNI152_T1_1mm/firstSeg/MNI152_T1_2mm_PET_subCort_mask.nii -kernel gauss ${Sigma} -fmean ${DIR}/pet.adni/SPMNorm/wprPET.BS7.lps.${type_pvc}.${type_norm}.sm${fwhmvol}.nii.gz
	# 					gunzip ${DIR}/pet.adni/SPMNorm/wprPET.BS7.lps.${type_pvc}.${type_norm}.sm${fwhmvol}.nii.gz
	# 				done
				fi
			done
		done	
	elif [ "${TypeSubj}" == "patient" ]
	then 
		gunzip ${DIR}/pet.adni/T1.npet.nii.gz ${DIR}/pet.adni/BS7_PET.lps.sm8.nii.gz
		if [ ${oldNorm} -eq 0 ]
		then		
			rm -f ${DIR}/pet.adni/wT1.npet.nii* ${DIR}/pet.adni/y_T1.npet.nii*
			for type_norm in npons ncereb gn
			do
				gunzip ${DIR}/pet.adni/PET.lps.BS7.sm8.${type_norm}.nii.gz
				rm -f ${DIR}/pet.adni/wPET.lps.BS7.sm8.${type_norm}.nii* ${DIR}/pet.adni/SPMNorm/wPET.lps.BS7.sm8.${type_norm}.sm*.nii*
		# 		for type_pvc in MGRousset MGCS
		# 		do
		# 			gunzip ${DIR}/pet.adni/${pvedir}/PET.BS7.lps.sm8.${type_pvc}.${type_norm}.nii.gz
		# 			rm -f ${DIR}/pet.adni/${pvedir}/wPET.BS7.lps.sm8.${type_pvc}.${type_norm}.nii*
		# 		done
			done
		elif [ ${oldNorm} -eq 1 ]
		then					
			rm -f ${DIR}/pet.adni/wpT1.npet.nii* ${DIR}/pet.adni/BS7_PET.lps.sm8_sn.mat	
			for type_norm in npons ncereb gn
			do					
				gunzip ${DIR}/pet.adni/PET.lps.BS7.sm8.${type_norm}.nii.gz
				rm -f ${DIR}/pet.adni/wpPET.lps.BS7.sm8.${type_norm}.nii*  ${DIR}/pet.adni/SPMNorm/wpPET.lps.BS7.sm8.${type_norm}.sm*.nii*
		# 		for type_pvc in MGRousset MGCS
		# 		do
		# 			gunzip ${DIR}/pet.adni/${pvedir}/PET.BS7.lps.sm8.${type_pvc}.${type_norm}.nii.gz
		# 			rm -f ${DIR}/pet.adni/${pvedir}/wpPET.BS7.lps.sm8.${type_pvc}.${type_norm}.nii*
		# 		done			
			done
		fi
		
		matlab -nodisplay <<EOF
		%% Load Matlab Path: Matlab 14 and SPM12 needed
		cd ${HOME}
		p = pathdef14_SPM12;
		addpath(p);

		%% Init of spm_jobman
		spm('defaults', 'PET');
		spm_jobman('initcfg');
		matlabbatch={};
		
		%% Step 1. Normalize estimate
		if ${oldNorm}==0
			matlabbatch{end+1}.spm.spatial.normalise.est.subj.vol = {'${DIR}/pet.adni/T1.npet.nii,1'};
			matlabbatch{end}.spm.spatial.normalise.est.eoptions.biasreg = 0.0001;
			matlabbatch{end}.spm.spatial.normalise.est.eoptions.biasfwhm = 60;
			matlabbatch{end}.spm.spatial.normalise.est.eoptions.tpm = {'/home/global/matlab_toolbox/spm12/tpm/TPM.nii'};
			matlabbatch{end}.spm.spatial.normalise.est.eoptions.affreg = 'mni';
			matlabbatch{end}.spm.spatial.normalise.est.eoptions.reg = [0 0.001 0.5 0.05 0.2];
			matlabbatch{end}.spm.spatial.normalise.est.eoptions.fwhm = 0;
			matlabbatch{end}.spm.spatial.normalise.est.eoptions.samp = 3;
		elseif ${oldNorm}==1
			matlabbatch{end+1}.spm.tools.oldnorm.est.subj.source     = cellstr('${DIR}/pet.adni/BS7_PET.lps.sm8.nii');
			matlabbatch{end}.spm.tools.oldnorm.est.subj.wtsrc        = '';
			matlabbatch{end}.spm.tools.oldnorm.est.eoptions.template = {'/home/global/matlab_toolbox/spm12/toolbox/OldNorm/TEMPLATE_FDGPET_100.nii,1'};
			matlabbatch{end}.spm.tools.oldnorm.est.eoptions.weight   = '';
			matlabbatch{end}.spm.tools.oldnorm.est.eoptions.smosrc   = 8;
			matlabbatch{end}.spm.tools.oldnorm.est.eoptions.smoref   = 0;
			matlabbatch{end}.spm.tools.oldnorm.est.eoptions.regtype  = 'mni';
			matlabbatch{end}.spm.tools.oldnorm.est.eoptions.cutoff   = 25;
			matlabbatch{end}.spm.tools.oldnorm.est.eoptions.nits     = 16;
			matlabbatch{end}.spm.tools.oldnorm.est.eoptions.reg      = 1;
		end
		
		spm_jobman('run',matlabbatch);
		
		%% Step 2. Normalize write
		clear matlabbatch 
		matlabbatch = {};
		
		if ${oldNorm}==0
			matlabbatch{end+1}.spm.spatial.normalise.write.subj.def = {'${DIR}/pet.adni/y_T1.npet.nii'};
			matlabbatch{end}.spm.spatial.normalise.write.subj.resample = {
										    '${DIR}/pet.adni/PET.lps.BS7.sm8.gn.nii,1'
										    '${DIR}/pet.adni/PET.lps.BS7.sm8.ncereb.nii,1'
										    '${DIR}/pet.adni/PET.lps.BS7.sm8.npons.nii,1'
										    '${DIR}/pet.adni/T1.npet.nii,1'
										    };
			matlabbatch{end}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
										  78 76 85];
			matlabbatch{end}.spm.spatial.normalise.write.woptions.vox = [2 2 2];
			matlabbatch{end}.spm.spatial.normalise.write.woptions.interp = 4;
			matlabbatch{end}.spm.spatial.normalise.write.woptions.prefix = 'w';
		elseif ${oldNorm}==1
			matlabbatch{end+1}.spm.tools.oldnorm.write.subj.matname    = cellstr('${DIR}/pet.adni/BS7_PET.lps.sm8_sn.mat');
			matlabbatch{end}.spm.tools.oldnorm.write.subj.resample     = {
										    '${DIR}/pet.adni/PET.lps.BS7.sm8.gn.nii,1'
										    '${DIR}/pet.adni/PET.lps.BS7.sm8.ncereb.nii,1'
										    '${DIR}/pet.adni/PET.lps.BS7.sm8.npons.nii,1'
										    '${DIR}/pet.adni/T1.npet.nii'
										    };
			matlabbatch{end}.spm.tools.oldnorm.write.roptions.preserve = 0;
			matlabbatch{end}.spm.tools.oldnorm.write.roptions.bb       = [-78 -112 -70; 78 76 85];
			matlabbatch{end}.spm.tools.oldnorm.write.roptions.vox      = [2 2 2];
			matlabbatch{end}.spm.tools.oldnorm.write.roptions.interp   = 4;
			matlabbatch{end}.spm.tools.oldnorm.write.roptions.wrap     = [0 0 0];
			matlabbatch{end}.spm.tools.oldnorm.write.roptions.prefix   = 'wp';
		end

		spm_jobman('run',matlabbatch);

		%% Step 3. Remove NaN and negative values in normalized PET images %%
		
		if ${oldNorm}==0
			V = spm_vol('${DIR}/pet.adni/wPET.lps.BS7.sm8.gn.nii');
			[Y, XYZ] = spm_read_vols(V);
			Y(~isfinite(Y(:))) = 0;
			Y(Y(:) < 0) = 0;
			spm_write_vol(V, Y);
			
			V = spm_vol('${DIR}/pet.adni/wPET.lps.BS7.sm8.ncereb.nii');
			[Y, XYZ] = spm_read_vols(V);
			Y(~isfinite(Y(:))) = 0;
			Y(Y(:) < 0) = 0;
			spm_write_vol(V, Y);
			
			V = spm_vol('${DIR}/pet.adni/wPET.lps.BS7.sm8.npons.nii');
			[Y, XYZ] = spm_read_vols(V);
			Y(~isfinite(Y(:))) = 0;
			Y(Y(:) < 0) = 0;
			spm_write_vol(V, Y);
		elseif ${oldNorm}==1
			V = spm_vol('${DIR}/pet.adni/wpPET.lps.BS7.sm8.gn.nii');
			[Y, XYZ] = spm_read_vols(V);
			Y(~isfinite(Y(:))) = 0;
			Y(Y(:) < 0) = 0;
			spm_write_vol(V, Y);
			
			V = spm_vol('${DIR}/pet.adni/wpPET.lps.BS7.sm8.ncereb.nii');
			[Y, XYZ] = spm_read_vols(V);
			Y(~isfinite(Y(:))) = 0;
			Y(Y(:) < 0) = 0;
			spm_write_vol(V, Y);
			
			V = spm_vol('${DIR}/pet.adni/wpPET.lps.BS7.sm8.npons.nii');
			[Y, XYZ] = spm_read_vols(V);
			Y(~isfinite(Y(:))) = 0;
			Y(Y(:) < 0) = 0;
			spm_write_vol(V, Y);
		end
EOF

		gzip ${DIR}/pet.adni/*.nii
	# 	${DIR}/pet.adni/${pvedir}/*.nii
		
		# Smooth PET data normalized to MNI152 space
		for type_norm in npons ncereb gn
		do
			for fwhmvol in 0 2 4 5 6 8 10 12
			do
				Sigma=`echo "$fwhmvol / ( 2 * ( sqrt ( 2 * l ( 2 ) ) ) )" | bc -l`
				if [ ${oldNorm} -eq 0 ]
				then
					fslmaths ${DIR}/pet.adni/wPET.lps.BS7.sm8.${type_norm}.nii.gz -mas ${SUBJECTS_DIR}/MNI152_T1_1mm/firstSeg/MNI152_T1_2mm_subCort_mask.nii -kernel gauss ${Sigma} -fmean ${DIR}/pet.adni/SPMNorm/wPET.lps.BS7.sm8.${type_norm}.sm${fwhmvol}.nii.gz
					gunzip ${DIR}/pet.adni/SPMNorm/wPET.lps.BS7.sm8.${type_norm}.sm${fwhmvol}.nii.gz
	# 				for type_pvc in MGRousset MGCS
	# 				do
	# 					fslmaths ${DIR}/pet.adni/${pvedir}/wPET.BS7.lps.sm8.${type_pvc}.${type_norm}.nii.gz -mas ${SUBJECTS_DIR}/MNI152_T1_1mm/firstSeg/MNI152_T1_2mm_subCort_mask.nii -kernel gauss ${Sigma} -fmean ${DIR}/pet.adni/SPMNorm/wPET.BS7.lps.sm8.${type_pvc}.${type_norm}.sm${fwhmvol}.nii.gz
	# 					gunzip ${DIR}/pet.adni/SPMNorm/wPET.BS7.lps.sm8.${type_pvc}.${type_norm}.sm${fwhmvol}.nii.gz
	# 				done
				elif [ ${oldNorm} -eq 1 ]
				then	
					fslmaths ${DIR}/pet.adni/wpPET.lps.BS7.sm8.${type_norm}.nii.gz -mas ${SUBJECTS_DIR}/MNI152_T1_1mm/firstSeg/MNI152_T1_2mm_PET_subCort_mask.nii -kernel gauss ${Sigma} -fmean ${DIR}/pet.adni/SPMNorm/wpPET.lps.BS7.sm8.${type_norm}.sm${fwhmvol}.nii.gz
					gunzip ${DIR}/pet.adni/SPMNorm/wpPET.lps.BS7.sm8.${type_norm}.sm${fwhmvol}.nii.gz
	# 				for type_pvc in MGRousset MGCS
	# 				do
	# 					fslmaths ${DIR}/pet.adni/${pvedir}/wpPET.BS7.lps.sm8.${type_pvc}.${type_norm}.nii.gz -mas ${SUBJECTS_DIR}/MNI152_T1_1mm/firstSeg/MNI152_T1_2mm_PET_subCort_mask.nii -kernel gauss ${Sigma} -fmean ${DIR}/pet.adni/SPMNorm/wpPET.BS7.lps.sm8.${type_pvc}.${type_norm}.sm${fwhmvol}.nii.gz
	# 					gunzip ${DIR}/pet.adni/SPMNorm/wpPET.BS7.lps.sm8.${type_pvc}.${type_norm}.sm${fwhmvol}.nii.gz
	# 				done
				fi
			done
		done
	fi
fi

if [ $DoANTSNorm -eq 1 ] && [ ! -f ${DIR}/pet.adni/${pvedir}/ANTs/wrPET.BS7.lia.sm8.MGRousset.gn.sm14.nii.gz ]
then
# 	if [ -d ${DIR}/pet.adni/vol ]
# 	then
# 	    rm -rf ${DIR}/pet.adni/vol/*
# 	else
# 	    mkdir ${DIR}/pet.adni/vol
# 	fi	

	if [ -d ${DIR}/pet.adni/${pvedir}/vol ]
	then
	    rm -rf ${DIR}/pet.adni/${pvedir}/vol/*
	else
	    mkdir ${DIR}/pet.adni/${pvedir}/vol
	fi

	# Register intensity normalized PET data (with or without PVC) into T1 space
# 	for type_norm in npons ncereb gn
	for type_norm in ncereb gn
	do
# 		mri_vol2vol --mov ${DIR}/pet.adni/PET.lps.BS7.sm8.${type_norm}.nii.gz --targ ${DIR}/pet.adni/T1.lia.nii.gz --o ${DIR}/pet.adni/vol/rPET.lia.BS7.sm8.${type_norm}.nii.gz --reg ${DIR}/pet.adni/Pet2T1.BS7.register.dof6.dat --no-save-reg --trilin
# 		gunzip ${DIR}/pet.adni/vol/rPET.lia.BS7.sm8.${type_norm}.nii.gz
		
# 		for type_pvc in MGRousset MGCS
		for type_pvc in MGRousset
		do
			mri_vol2vol --mov ${DIR}/pet.adni/${pvedir}/PET.BS7.lps.sm8.${type_pvc}.${type_norm}.nii.gz --targ ${DIR}/pet.adni/T1.lia.nii.gz --o ${DIR}/pet.adni/${pvedir}/vol/rPET.BS7.lia.sm8.${type_pvc}.${type_norm}.nii.gz --reg ${DIR}/pet.adni/Pet2T1.BS7.register.dof6.dat --no-save-reg --trilin
			gunzip ${DIR}/pet.adni/${pvedir}/vol/rPET.BS7.lia.sm8.${type_pvc}.${type_norm}.nii.gz
		done
	done

# 	if [ -d ${DIR}/pet.adni/ANTs ]
# 	then
# 	    rm -rf ${DIR}/pet.adni/ANTs/*
# 	else
# 	    mkdir ${DIR}/pet.adni/ANTs
# 	fi

	if [ -d ${DIR}/pet.adni/${pvedir}/ANTs ]
	then
	    rm -rf ${DIR}/pet.adni/${pvedir}/ANTs/*
	else
	    mkdir ${DIR}/pet.adni/${pvedir}/ANTs
	fi

# 	if [ ! -f ${DIR}/pet.adni/ANTs/norm_las.nii.gz ]
# 	then
# 	    mri_convert ${DIR}/mri/norm.mgz ${DIR}/pet.adni/ANTs/norm_las.nii.gz --out_orientation LAS
# 	fi
	
	# Normalize PET data, registered to T1 space, into MNI152 space
	TEMPLATE=${FSLDIR}/data/standard/MNI152_T1_1mm_brain.nii.gz
# 	if [ ! -f ${DIR}/pet.adni/ANTs/norm_mni152.nii.gz ]
# 	then
# 	    ANTS 3 -m MI[${TEMPLATE},${DIR}/pet.adni/ANTs/norm_las.nii.gz,1,32] -o ${DIR}/pet.adni/ANTs/norm_mni152_rigid -i 0 --rigid-affine true
# 	    WarpImageMultiTransform 3 ${DIR}/pet.adni/ANTs/norm_las.nii.gz ${DIR}/pet.adni/ANTs/norm_mni152_rigid.nii.gz ${DIR}/pet.adni/ANTs/norm_mni152_rigidAffine.txt -R ${TEMPLATE}
# 	    ANTS 3 -m CC[${TEMPLATE},${DIR}/pet.adni/ANTs/norm_mni152_rigid.nii.gz,1,4] -i 100x100x100x20 -o ${DIR}/pet.adni/ANTs/norm_mni152 -t SyN[0.25] -r Gauss[3,0]
# 	    WarpImageMultiTransform 3 ${DIR}/pet.adni/ANTs/norm_las.nii.gz ${DIR}/pet.adni/ANTs/norm_mni152.nii.gz ${DIR}/pet.adni/ANTs/norm_mni152Warp.nii.gz ${DIR}/pet.adni/ANTs/norm_mni152Affine.txt ${DIR}/pet.adni/ANTs/norm_mni152_rigidAffine.txt -R ${TEMPLATE} --use-BSpline
# 	fi

	# Smooth PET data normalized to MNI152 space
	for type_norm in ncereb gn
# 	for type_norm in npons ncereb gn
	do
# 		WarpImageMultiTransform 3 ${DIR}/pet.adni/vol/rPET.lia.BS7.sm8.${type_norm}.nii.gz ${DIR}/pet.adni/ANTs/wrPET.lia.BS7.sm8.${type_norm}.nii.gz ${DIR}/pet.adni/ANTs/norm_mni152Warp.nii.gz ${DIR}/pet.adni/ANTs/norm_mni152Affine.txt ${DIR}/pet.adni/ANTs/norm_mni152_rigidAffine.txt -R ${TEMPLATE} --use-BSpline	
		for fwhmvol in 6 8 10 12 14
# 		for fwhmvol in 12 15
		do
			Sigma=`echo "$fwhmvol / ( 2 * ( sqrt ( 2 * l ( 2 ) ) ) )" | bc -l`
# 			rm -f ${DIR}/pet.adni/ANTs/wrPET.lia.BS7.sm8.${type_norm}.sm${fwhmvol}.nii*
# 			fslmaths ${DIR}/pet.adni/ANTs/wrPET.lia.BS7.sm8.${type_norm}.nii.gz -mas ${SUBJECTS_DIR}/MNI152_T1_1mm/firstSeg/MNI152_T1_1mm_subCort_mask.nii -kernel gauss ${Sigma} -fmean ${DIR}/pet.adni/ANTs/wrPET.lia.BS7.sm8.${type_norm}.sm${fwhmvol}.nii.gz
# 			gunzip ${DIR}/pet.adni/ANTs/wrPET.lia.BS7.sm8.${type_norm}.sm${fwhmvol}.nii.gz
# 			for type_pvc in MGRousset MGCS
			for type_pvc in MGRousset
			do
				WarpImageMultiTransform 3 ${DIR}/pet.adni/${pvedir}/vol/rPET.BS7.lia.sm8.${type_pvc}.${type_norm}.nii.gz ${DIR}/pet.adni/${pvedir}/ANTs/wrPET.BS7.lia.sm8.${type_pvc}.${type_norm}.nii.gz ${DIR}/pet.adni/ANTs/norm_mni152Warp.nii.gz ${DIR}/pet.adni/ANTs/norm_mni152Affine.txt ${DIR}/pet.adni/ANTs/norm_mni152_rigidAffine.txt -R ${TEMPLATE} --use-BSpline
				rm -f ${DIR}/pet.adni/${pvedir}/ANTs/wrPET.BS7.lia.sm8.${type_pvc}.${type_norm}.sm${fwhmvol}.nii*
				fslmaths ${DIR}/pet.adni/${pvedir}/ANTs/wrPET.BS7.lia.sm8.${type_pvc}.${type_norm}.nii.gz -mas ${SUBJECTS_DIR}/MNI152_T1_1mm/firstSeg/Subcortical_mask.nii.gz -kernel gauss ${Sigma} -fmean ${DIR}/pet.adni/${pvedir}/ANTs/wrPET.BS7.lia.sm8.${type_pvc}.${type_norm}.sm${fwhmvol}.nii.gz
				gunzip ${DIR}/pet.adni/${pvedir}/ANTs/wrPET.BS7.lia.sm8.${type_pvc}.${type_norm}.sm${fwhmvol}.nii.gz
			done
		done
	done	
fi