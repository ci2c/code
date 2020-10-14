#! /bin/bash

# Set up FreeSurfer (if not already done so in the running environment)
export FREESURFER_HOME=${Soft_dir}/freesurfer5.3/
. ${FREESURFER_HOME}/SetUpFreeSurfer.sh

# Set up FSL (if not already done so in the running environment)
FSLDIR=${Soft_dir}/fsl50
. ${FSLDIR}/etc/fslconf/fsl.sh

if [[ ! -s ${ANTSPATH}/antsRegistration ]]
then
  echo "Cannot find antsRegistration.  Please \(re\)define \$ANTSPATH in your environment."
fi
if [[ ! -s ${ANTSPATH}/antsApplyTransforms ]]
then
  echo "Cannot find antsApplyTransforms.  Please \(re\)define \$ANTSPATH in your environment."
fi
if [[ ! -s ${ANTSPATH}/antsIntermodalityIntrasubject.sh ]]
then 
  echo "Cannot find antsIntermodalityIntrasubject.sh script.  Please \(re\)define \$ANTSPATH in your environemnt."
fi

if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: fMRI_PreprocessingRats.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -o <path>  [-fwhmsurf <value>  -fwhmvol <value>  -acquis <name>  -rmframe <value>  -tr <value> -toMNI  -doCompCor  -doFilt  -doAAL  -doCraddock  -doStriatum  -doSPMNorm  -doANTSNorm  -doSeg  -oldNorm  -v <FSVersion> ]"
	echo ""
	echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
	echo "  -subj                        : Subject I "
	echo "  -epi                         : fmri file "
	echo "  -o                           : output path "
	echo "  -fwhmsurf                    : smoothing value (volume) before projection "
	echo "  -fwhmvol                     : smoothing value (volume) "
	echo "  -acquis                      : 'ascending', 'interleaved' or 0 (no STC) "
	echo "  -rmframe                     : frame for removal "
	echo "  -tr                          : TR value "
	echo "  -toMNI                       : Do MNI normalization "
	echo "  -doCompCor                   : Do CompCor correction "
	echo "  -doFilt                      : Do bandpass filtering (hp and lp values) "
	echo "  -doAAL                       : Create AAL parcellation "
	echo "  -doCraddock                  : Create Craddock parcellation "
	echo "  -doStriatum                  : Create striatum parcellation "
	echo "  -doSPMNorm                   : Non-linear registration of T1 in MNI space (SPM function 'normalize') "
	echo "  -doANTSNorm                  : Non-linear registration of T1 in MNI space (ANTS function) "
	echo "  -doSeg                       : SPM segmentation (grey matter - white matter - csf) "
	echo "  -oldNorm                     : Do SPM8 Normalization (else SPM12) "
	echo "  -v                           : Version of FS used"
	echo ""
	echo "Usage: fMRI_PreprocessingRats.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -o <path>  [-fwhmsurf <value>  -fwhmvol <value>  -acquis <name>  -rmframe <value>  -tr <value> -tomni  -doCompCor  -doFilt  -doAAL  -doCraddock  -doStriatum  -doSPMNorm  -doANTSNorm  -doSeg  -oldNorm  -v <FSVersion> ]"
	echo ""
	exit 1
fi

HOME=/home/renaud
index=1
fwhmsurf=6
fwhmvol=6
acquis=interleaved
remframe=3
TRtmp=0
ToMNI305=0
DoCompCor=0
DoFiltering=0
highpass=-1
lowpass=-1
DoAAL=0
DoCraddock=0
DoStriatum=0
DoSPMNorm=0
DoANTSNorm=0
DoSeg=0
oldNorm=0
FS_VERSION=5.0

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: FMRI_PreprocessingVolumeAndSurface.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -o <path>  [-fwhmsurf <value>  -fwhmvol <value>  -acquis <name>  -rmframe <value>  -tr <value> -toMNI  -doCompCor  -doFilt  -doAAL  -doCraddock  -doStriatum  -doSPMNorm  -doANTSNorm  -doSeg  -oldNorm  -v <FSVersion> ]"
		echo ""
		echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subj                        : Subject I "
		echo "  -epi                         : fmri file "
		echo "  -o                           : output path "
		echo "  -fwhmsurf                    : smoothing value (volume) before projection "
		echo "  -fwhmvol                     : smoothing value (volume) "
		echo "  -acquis                      : 'ascending', 'interleaved' or 0 (no STC) "
		echo "  -rmframe                     : frame for removal "
		echo "  -tr                          : TR value "
		echo "  -toMNI                       : Do MNI normalization "
		echo "  -doCompCor                   : Do CompCor correction "
		echo "  -doFilt                      : Do bandpass filtering (hp and lp values) "
		echo "  -doAAL                       : Create AAL parcellation "
		echo "  -doCraddock                  : Create Craddock parcellation "
		echo "  -doStriatum                  : Create striatum parcellation "
		echo "  -doSPMNorm                   : Non-linear registration of T1 in MNI space (SPM function 'normalize') "
		echo "  -doANTSNorm                  : Non-linear registration of T1 in MNI space (ANTS function) "
		echo "  -doSeg                       : SPM segmentation (grey matter - white matter - csf) "
		echo "  -oldNorm                     : Do SPM8 Normalization (else SPM12) "
		echo "  -v                           : Version of FS used"
		echo ""
		echo "Usage: FMRI_PreprocessingVolumeAndSurface.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -o <path>  [-fwhmsurf <value>  -fwhmvol <value>  -acquis <name>  -rmframe <value>  -tr <value> -tomni  -doCompCor  -doFilt  -doAAL  -doCraddock  -doStriatum  -doSPMNorm  -doANTSNorm  -doSeg  -oldNorm  -v <FSVersion> ]"
		echo ""
		exit 1
		;;
	-sd)
		index=$[$index+1]
		eval SUBJECTS_DIR=\${$index}
		echo "SUBJECTS DIR : $SUBJECTS_DIR"
		;;
	-subj)
		index=$[$index+1]
		eval SUBJ=\${$index}
		echo "Subject's name : $SUBJ"
		;;
	-epi)
		index=$[$index+1]
		eval epi=\${$index}
		echo "fMRI file : $epi"
		;;
	-fwhmsurf)
		index=$[$index+1]
		eval fwhmsurf=\${$index}
		echo "fwhm surface : ${fwhmsurf}"
		;;
	-tomni)
		ToMNI305=1
		echo "Do MNI normalization"
		;;
	-o)
		index=$[$index+1]
		eval outdir=\${$index}
		echo "output path : $outdir"
		;;
	-fwhmvol)
		index=$[$index+1]
		eval fwhmvol=\${$index}
		echo "fwhm volume : ${fwhmvol}"
		;;
	-acquis)
		index=$[$index+1]
		eval acquis=\${$index}
		echo "acquisition : ${acquis}"
		;;
	-tr)
		index=$[$index+1]
		eval TRtmp=\${$index}
		echo "TR value : ${TRtmp}"
		;;
	-rmframe)
		index=$[$index+1]
		eval remframe=\${$index}
		echo "frame for removal : ${remframe}"
		;;
	-toMNI)
		ToMNI305=1
		echo "Do MNI normalization"
		;;
	-doCompCor)
		DoCompCor=1
		echo "Do CompCorr correction"
		;;
	-doFilt)
		tmp=`expr $index + 1`
		eval highpass=\${$tmp}
		index=$[$index+1]
		tmp=`expr $index + 1`
		eval lowpass=\${$tmp}
		index=$[$index+1]
		echo "  |-------> Bandpass filtering : $highpass $lowpass"
		DoFiltering=1
		;;
	-doStriatum)
		DoStriatum=1
		echo "Create striatum parcellation"
		;;
	-doAAL)
		DoAAL=1
		echo "Create AAL parcellation"
		;;
	-doCraddock)
		DoCraddock=1
		echo "Create Craddock parcellation"
		;;
	-doSPMNorm)
		DoSPMNorm=1
		echo "Non-linear registration of T1 in MNI space (SPM function 'normalize')"
		;;
	-doANTSNorm)
		DoANTSNorm=1
		echo "Non-linear registration of T1 in MNI space (ANTS function)"
		;;
	-doSeg)
		DoSeg=1
		echo "SPM segmentation"
		;;
	-oldNorm)
		oldNorm=1
		echo "Do SPM8 Normalization"
		;;
	-v)
		index=$[$index+1]
		eval FS_VERSION=\${$index}
		echo "Version of FS used : ${FS_VERSION}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: FMRI_PreprocessingVolumeAndSurface.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -o <path>  [-fwhmsurf <value>  -fwhmvol <value>  -acquis <name>  -rmframe <value>  -tr <value> -toMNI  -doCompCor  -doFilt  -doAAL  -doCraddock  -doStriatum  -doSPMNorm  -doANTSNorm  -doSeg  -oldNorm  -v <FSVersion> ]"
		echo ""
		echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subj                        : Subject I "
		echo "  -epi                         : fmri file "
		echo "  -o                           : output path "
		echo "  -fwhmsurf                    : smoothing value (volume) before projection "
		echo "  -fwhmvol                     : smoothing value (volume) "
		echo "  -acquis                      : 'ascending', 'interleaved' or 0 (no STC) "
		echo "  -rmframe                     : frame for removal "
		echo "  -tr                          : TR value "
		echo "  -toMNI                       : Do MNI normalization "
		echo "  -doCompCor                   : Do CompCor correction "
		echo "  -doFilt                      : Do bandpass filtering (hp and lp values) "
		echo "  -doAAL                       : Create AAL parcellation "
		echo "  -doCraddock                  : Create Craddock parcellation "
		echo "  -doStriatum                  : Create striatum parcellation "
		echo "  -doSPMNorm                   : Non-linear registration of T1 in MNI space (SPM function 'normalize') "
		echo "  -doANTSNorm                  : Non-linear registration of T1 in MNI space (ANTS function) "
		echo "  -doSeg                       : SPM segmentation (grey matter - white matter - csf) "
		echo "  -oldNorm                     : Do SPM8 Normalization (else SPM12) "
		echo "  -v                           : Version of FS used"
		echo ""
		echo "Usage: FMRI_PreprocessingVolumeAndSurface.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -o <path>  [-fwhmsurf <value>  -fwhmvol <value>  -acquis <name>  -rmframe <value>  -tr <value> -tomni  -doCompCor  -doFilt  -doAAL  -doCraddock  -doStriatum  -doSPMNorm  -doANTSNorm  -doSeg  -oldNorm  -v <FSVersion> ]"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${SUBJECTS_DIR} ]
then
	 echo "-sd argument mandatory"
	 exit 1
fi

if [ -z ${SUBJ} ]
then
	 echo "-subj argument mandatory"
	 exit 1
fi

if [ -z ${epi} ]
then
	 echo "-epi argument mandatory"
	 exit 1
fi

if [ -z ${outdir} ]
then
	 echo "-o argument mandatory"
	 exit 1
fi

# Choice of FS version
if [ "${FS_VERSION}" == "5.1" ]
then
	export FREESURFER_HOME=${Soft_dir}/freesurfer5.1/
	. ${FREESURFER_HOME}/SetUpFreeSurfer.sh
# 	sudo ln -s ${FREESURFER_HOME}/subjects/fsaverage5 ${SUBJECTS_DIR}/
elif [ "${FS_VERSION}" == "5.3" ]
then
	export FREESURFER_HOME=${Soft_dir}/freesurfer5.3/
	. ${FREESURFER_HOME}/SetUpFreeSurfer.sh
# 	sudo ln -s ${FREESURFER_HOME}/subjects/fsaverage5 ${SUBJECTS_DIR}/
fi


DoTemplate=1
DoMask=1
DoReg=1
DoMC=1
ToSurf=1

Anatomical_T2=`basename ${epi}`
Anatomical_T2=${Anatomical_T2}/20141030_132512TurboRARET2worksOKs131073a001.nii.gz

if [ ${acquis} -eq 0 ]
then
	DoSTC=0
else
	DoSTC=1
fi
echo "Do STC : ${DoSTC}"

#=========================================
#            Initialization...
#=========================================

# TR value
if [ ${TRtmp} -eq 0 ]
then
	TR=$(mri_info ${epi} | grep TR | awk '{print $2}')
	TR=$(echo "$TR/1000" | bc -l)
else
	TR=${TRtmp}
fi

# Number of slices
nslices=$(mri_info ${epi} | grep dimensions | awk '{print $6}')

Sigma=`echo "$fwhmvol / ( 2 * ( sqrt ( 2 * l ( 2 ) ) ) )" | bc -l`

echo $TR
echo $nslices
echo $Sigma

DIR=${SUBJECTS_DIR}/${SUBJ}

# if [ ! -d ${DIR} ]
# then
# 	mkdir -p ${DIR}
# else
# 	rm -rf ${DIR}/*
# fi
# 
# if [ ! -d ${DIR}/${outdir} ]
# then
# 	mkdir ${DIR}/${outdir}
# else
# 	rm -rf ${DIR}/${outdir}/*
# fi
# if [ ! -d ${DIR}/${outdir}/run01 ]
# then
# 	mkdir ${DIR}/${outdir}/run01
# else
# 	rm -rf ${DIR}/${outdir}/run01/*
# fi
# 
# cp ${epi} ${DIR}/${outdir}/
# 
# filename=$(basename "$epi")
# extension="${filename##*.}"
# if [ "${extension}" == "gz" ]
# then
# 	gunzip ${DIR}/${outdir}/${filename}
# 	filename="${filename%.*}"
# fi
# epi=${DIR}/${outdir}/${filename}
# 
# # Remove N first frames
# mkdir ${DIR}/${outdir}/run01/tmp
# echo "fslsplit ${epi} ${DIR}/${outdir}/run01/tmp/epi_ -t"
# fslsplit ${epi} ${DIR}/${outdir}/run01/tmp/epi_ -t
# for ((ind = 0; ind < ${remframe}; ind += 1))
# do
# 	filename=`ls -1 ${DIR}/${outdir}/run01/tmp/ | sed -ne "1p"`
# 	rm -f ${DIR}/${outdir}/run01/tmp/${filename}
# done
# 
# echo "fslmerge -t ${DIR}/${outdir}/run01/epi.nii ${DIR}/${outdir}/run01/tmp/epi_*"
# fslmerge -t ${DIR}/${outdir}/run01/epi.nii ${DIR}/${outdir}/run01/tmp/epi_*
# 
# echo "gunzip ${DIR}/${outdir}/run01/*.gz"
# gunzip ${DIR}/${outdir}/run01/*.gz
# echo "rm -rf ${DIR}/${outdir}/run01/tmp"
# rm -rf ${DIR}/${outdir}/run01/tmp
# 
# 
# # ========================================================================================================================================
# #                                                        RUNNING...
# # ========================================================================================================================================
# 
# if [ $DoTemplate -eq 1 ] 
# then
# 
# 	# Make EPI template file
# 	echo "mri_convert ${DIR}/${outdir}/run01/epi.nii ${DIR}/${outdir}/template.nii --frame 0"
# 	mri_convert ${DIR}/${outdir}/run01/epi.nii ${DIR}/${outdir}/template.nii --frame 0
# 	echo "mri_convert ${DIR}/${outdir}/run01/epi.nii ${DIR}/${outdir}/run01/template.nii --mid-frame"
# 	mri_convert ${DIR}/${outdir}/run01/epi.nii ${DIR}/${outdir}/run01/template.nii --mid-frame
# 	#cp ${DIR}/${outdir}/template.nii ${DIR}/${outdir}/run01/template.nii
# 
# fi
# 
# 
# # ========================================================================================================================================
# #            COMMON PREPROCESSING (motion correction - slice-timing correction - smoothing)
# # ========================================================================================================================================
# 
# if [ $DoMC -eq 1 ]
# then
# 
# 	mc-afni2 --i ${DIR}/${outdir}/run01/epi.nii --t ${DIR}/${outdir}/run01/template.nii --o ${DIR}/${outdir}/run01/repi.nii --mcdat ${DIR}/${outdir}/run01/repi.mcdat
# 
# 	# Making external regressor from mc params
# 	mcdat2mcextreg --i ${DIR}/${outdir}/run01/repi.mcdat --o ${DIR}/${outdir}/run01/mcprextreg
# 
# fi
# epipre=${DIR}/${outdir}/run01/repi.nii
# 
# 
# if [ $DoSTC -eq 1 ]
# then
# 
# /usr/local/matlab11/bin/matlab -nodisplay <<EOF
# 
# 	% Load Matlab Path
# 	cd ${HOME}
# 	p = pathdef;
# 	addpath(p);
# 
# 	if strcmp('${acquis}','ascending')
# 		sliceorder = 1:1:${nslices};
# 	elseif strcmp('${acquis}','interleaved')
# 		sliceorder = [];
# 		space      = round(sqrt(${nslices}));
# 		for k=1:space
# 			tmp        = k:space:${nslices};
# 			sliceorder = [sliceorder tmp];
# 		end
# 	elseif strcmp('${acquis}','descending')
# 		sliceorder = [${nslices}:-2:1 ${nslices}-1:-2:1];
# 	else
# 		sliceorder = 1:1:${nslices};
# 	end
# 
# 	[tempa,tempb,tempc]=fileparts('${epipre}'); 
# 	epifiles{1}=cellstr(spm_select('ExtFPList',tempa,['^',tempb,tempc],1:1e4));
# 
# 	spm_get_defaults;
# 	spm_jobman('initcfg');
# 	matlabbatch = {};
# 	matlabbatch{end+1}.spm.temporal.st.scans    = epifiles;
#         matlabbatch{end}.spm.temporal.st.tr         = ${TR};
#         matlabbatch{end}.spm.temporal.st.nslices    = ${nslices};
#         matlabbatch{end}.spm.temporal.st.ta         = ${TR}*(1-1/${nslices});
#         matlabbatch{end}.spm.temporal.st.refslice   = floor(${nslices}/2);
#         matlabbatch{end}.spm.temporal.st.so         = sliceorder;
#         spm_jobman('run',matlabbatch);
# 
# EOF
# 
# else
# 	cp ${epipre} ${DIR}/${outdir}/run01/arepi.nii
# fi
# 
# # smoothing
# fslmaths ${DIR}/${outdir}/run01/arepi.nii -kernel gauss ${Sigma} -fmean ${DIR}/${outdir}/run01/arepi_s${fwhmvol}.nii.gz
# 
# # ========================================================================================================================================
# #            EPI : N4 Bias Field correction (resample before) - extraction brain mask - manual correction of brain mask
# # ========================================================================================================================================
# 
# # Compute arepi mean
# fslmaths ${DIR}/${outdir}/run01/arepi.nii -Tmean ${DIR}/${outdir}/run01/arepi_mean.nii.gz
# 
# # Resample arepi_mean to isotropic voxels (0.3 mm, cubic interpolation)
# mri_convert -vs 0.3 0.3 0.3 -rt cubic ${DIR}/${outdir}/run01/arepi_mean.nii.gz ${DIR}/${outdir}/run01/arepi_mean_iso.nii.gz
# 
# # Perform N4 Bias Field correction
# N4BiasFieldCorrection -d 3 -i ${DIR}/${outdir}/run01/arepi_mean_iso.nii.gz -o ${DIR}/${outdir}/run01/N4_arepi_mean_iso.nii.gz -b [200] -s 3 -c [50x50x30x20,1e-6]
# 
# # Extract EPI brain mask
# RATS_MM ${DIR}/${outdir}/run01/N4_arepi_mean_iso.nii.gz ${DIR}/${outdir}/run01/epi_mask.nii.gz -t 2650 -v 1750
# 
# RATS_LOGISMOS ${DIR}/${outdir}/run01/N4_arepi_mean_iso.nii.gz ${DIR}/${outdir}/run01/epi_mask.nii.gz ${DIR}/${outdir}/run01/rat_epi_logismos.vtp
# 
# # Use 3D Slicer (save epi_final_mask.nii.gz) and correct manually epi_final_mask.nii.gz if needed
# 
# # Binarize epi_final_mask.nii.gz
# mri_binarize --i ${DIR}/${outdir}/run01/epi_final_mask.nii.gz --min 1 --o ${DIR}/${outdir}/run01/epi_final_maskb.nii.gz
# 
# # Resample epi_final_maskb.nii.gz to original arepi_mean resolution
# mri_convert -rl ${DIR}/${outdir}/run01/arepi_mean.nii.gz -rt nearest ${DIR}/${outdir}/run01/epi_final_maskb.nii.gz ${DIR}/${outdir}/run01/epi_final_maskbr.nii.gz
# 
# # Manual EPI brain mask correction if needed
# 
# # ========================================================================================================================================
# #           T2 : N4 Bias Field correction (resample+padding before) - extraction brain mask - coregistration T2-EPI
# # ========================================================================================================================================
# 
# # # Resample N4_T2.nii.gz to isotropic voxels
# # ${ANTSPATH}/ResampleImageBySpacing 3 ${DIR}/${outdir}/run01/N4_T2.nii.gz ${DIR}/${outdir}/run01/N4_T2_isotropic.nii.gz 0.2 0.2 0.2 0
# 
# # 
# # # N4BiasFieldCorrection on anatomical T2 image
# # N4BiasFieldCorrection -d 3 -i ${Anatomical_T2} -o ${DIR}/${outdir}/run01/N4_T2.nii.gz -b [200] -s 3 -c [50x50x30x20,1e-6]
# # 
# # # # Quick SyN registration of arepi mean onto anatomical T2
# # # antsRegistrationSyNQuick.sh -d 3 -f ${OUTPUT_DIR}/${subject}/Structural/T2.nii.gz -m ${OUTPUT_DIR}/${subject}/N4_control_mean.nii.gz -o ${OUTPUT_DIR}/${subject}/T2toAsl
# # 
# # # Registration of N4_arepi_mean_iso_brain.nii.gz onto anatomical N4_T2_iso_pad_brain.nii.gz
# # antsIntermodalityIntrasubject.sh -d 3 -i ${DIR}/${outdir}/run01/N4_arepi_mean_iso_brain.nii.gz -r ${DIR}/${outdir}/run01/N4_T2_iso_pad_brain.nii.gz -x ${DIR}/${outdir}/run01/N4_T2_iso_pad_maskb.nii.gz -t 2 -o ${DIR}/${outdir}/run01/EpitoT2/Epi
# 
# # ========================================================================================================================================
# #           Compute ICA
# # ========================================================================================================================================
# 
# gunzip ${DIR}/${outdir}/run01/arepi_s${fwhmvol}.nii.gz ${DIR}/${outdir}/run01/epi_final_maskbr.nii.gz
# mkdir ${DIR}/${outdir}/run01/ICA/
# 
# # Compute ICA
# FMRI_ICAOnVolume.sh -epi ${DIR}/${outdir}/run01/arepi_s${fwhmvol}.nii -o ${DIR}/${outdir}/run01/ICA/ -ncomp 40 -mask ${DIR}/${outdir}/run01/epi_final_maskbr.nii -tr ${TR}

# ========================================================================================================================================
#           Register ICA maps on N4_T2_iso_pad_brain.nii.gz
# ========================================================================================================================================

ICA=$(ls ${DIR}/${outdir}/run01/ICA/ica_map_*.nii)
i=1

for map in ${ICA}
do
	antsApplyTransforms -d 3 -i ${map} -o ${DIR}/${outdir}/run01/ICA/ica_map_${i}_toT2.nii.gz -r ${DIR}/${outdir}/run01/N4_T2_iso_pad.nii.gz -t ${DIR}/${outdir}/run01/EpitoT2/Epi1Warp.nii.gz -t ${DIR}/${outdir}/run01/EpitoT2/Epi0GenericAffine.mat -n Linear
	i=$[$i+1]
done

fslmerge -t ${DIR}/${outdir}/run01/ICA/ica_map_4D_toT2.nii.gz ${DIR}/${outdir}/run01/ICA/ica_map_*_toT2.nii.gz