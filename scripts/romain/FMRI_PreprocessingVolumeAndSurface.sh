#! /bin/bash

if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: FMRI_PreprocessingVolumeAndSurface.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -o <path>  [-fwhmsurf <value>  -fwhmvol <value>  -acquis <name>  -rmframe <value>  -doGMS  -tr <value> -toMNI  -doCompCor  -doFilt  -doAAL  -doCraddock  -doStriatum  -doSPMNorm  -doANTSNorm  -doAnalysis  -doSeg  -oldNorm  -v <FSVersion> ]"
	echo ""
	echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
	echo "  -subj                        : Subject I "
	echo "  -epi                         : fmri file "
	echo "  -o                           : output path "
	echo "  -fwhmsurf                    : smoothing value (volume) before projection "
	echo "  -fwhmvol                     : smoothing value (volume) "
	echo "  -acquis                      : 'ascending', 'interleaved' or 0 (no STC) "
	echo "  -rmframe                     : frame for removal "
	echo "  -doGMS                       : Do grand-mean scaling "
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
	echo "  -doAnalysis                  : Do a first level analysis"
	echo "  -v                           : Version of FS used"
	echo ""
	echo "Usage: FMRI_PreprocessingVolumeAndSurface.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -o <path>  [-fwhmsurf <value>  -fwhmvol <value>  -acquis <name>  -rmframe <value>  -doGMS  -tr <value> -tomni  -doCompCor  -doFilt  -doAAL  -doCraddock  -doStriatum  -doSPMNorm  -doANTSNorm  -doAnalysis -doSeg  -oldNorm  -v <FSVersion> ]"
	echo ""
	exit 1
fi

HOME=/home/romain
index=1
fwhmsurf=6
fwhmvol=6
acquis=interleaved
remframe=3
TRtmp=0
DoGMS=0
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
DoAnalysis=0
DoSeg=0
oldNorm=0
FS_VERSION=5.0

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: FMRI_PreprocessingVolumeAndSurface.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -o <path>  [-fwhmsurf <value>  -fwhmvol <value>  -acquis <name>  -rmframe <value>  -doGMS  -tr <value> -toMNI  -doCompCor  -doFilt  -doAAL  -doCraddock  -doStriatum  -doSPMNorm  -doANTSNorm  -doAnalysis  -doSeg  -oldNorm  -v <FSVersion> ]"
		echo ""
		echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subj                        : Subject I "
		echo "  -epi                         : fmri file "
		echo "  -o                           : output path "
		echo "  -fwhmsurf                    : smoothing value (volume) before projection "
		echo "  -fwhmvol                     : smoothing value (volume) "
		echo "  -acquis                      : 'ascending', 'interleaved' or 0 (no STC) "
		echo "  -rmframe                     : frame for removal "
		echo "  -doGMS                       : Do grand-mean scaling "
		echo "  -tr                          : TR value "
		echo "  -toMNI                       : Do MNI normalization "
		echo "  -doCompCor                   : Do CompCor correction "
		echo "  -doFilt                      : Do bandpass filtering (hp and lp values) "
		echo "  -doAAL                       : Create AAL parcellation "
		echo "  -doCraddock                  : Create Craddock parcellation "
		echo "  -doStriatum                  : Create striatum parcellation "
		echo "  -doSPMNorm                   : Non-linear registration of T1 in MNI space (SPM function 'normalize') "
		echo "  -doANTSNorm                  : Non-linear registration of T1 in MNI space (ANTS function) "
		echo "  -doAnalysis                  : Do a first level analysis"
		echo "  -doSeg                       : SPM segmentation (grey matter - white matter - csf) "
		echo "  -oldNorm                     : Do SPM8 Normalization (else SPM12) "
		echo "  -v                           : Version of FS used"
		echo ""
		echo "Usage: FMRI_PreprocessingVolumeAndSurface.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -o <path>  [-fwhmsurf <value>  -fwhmvol <value>  -acquis <name>  -rmframe <value>  -doGMS  -tr <value> -tomni  -doCompCor  -doFilt  -doAAL  -doCraddock  -doStriatum  -doSPMNorm  -doANTSNorm  -doAnalysis  -doSeg  -oldNorm  -v <FSVersion> ]"
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
	-doGMS)
		DoGMS=1
		echo "Do grand-mean scaling"
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
	-doAnalysis)
		DoAnalysis=1
		echo "First level analysis"
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
		echo "Usage: FMRI_PreprocessingVolumeAndSurface.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -o <path>  [-fwhmsurf <value>  -fwhmvol <value>  -acquis <name>  -rmframe <value>  -doGMS  -tr <value> -toMNI  -doCompCor  -doFilt  -doAAL  -doCraddock  -doStriatum  -doSPMNorm  -doANTSNorm  -doAnalysis -doSeg  -oldNorm  -v <FSVersion> ]"
		echo ""
		echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subj                        : Subject I "
		echo "  -epi                         : fmri file "
		echo "  -o                           : output path "
		echo "  -fwhmsurf                    : smoothing value (volume) before projection "
		echo "  -fwhmvol                     : smoothing value (volume) "
		echo "  -acquis                      : 'ascending', 'interleaved' or 0 (no STC) "
		echo "  -rmframe                     : frame for removal "
		echo "  -doGMS                       : Do grand-mean scaling "
		echo "  -tr                          : TR value "
		echo "  -toMNI                       : Do MNI normalization "
		echo "  -doCompCor                   : Do CompCor correction "
		echo "  -doFilt                      : Do bandpass filtering (hp and lp values) "
		echo "  -doAAL                       : Create AAL parcellation "
		echo "  -doCraddock                  : Create Craddock parcellation "
		echo "  -doStriatum                  : Create striatum parcellation "
		echo "  -doSPMNorm                   : Non-linear registration of T1 in MNI space (SPM function 'normalize') "
		echo "  -doANTSNorm                  : Non-linear registration of T1 in MNI space (ANTS function) "
		echo "  -doAnalysis                  : do a first level analysis"
		echo "  -doSeg                       : SPM segmentation (grey matter - white matter - csf) "
		echo "  -oldNorm                     : Do SPM8 Normalization (else SPM12) "
		echo "  -v                           : Version of FS used"
		echo ""
		echo "Usage: FMRI_PreprocessingVolumeAndSurface.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -o <path>  [-fwhmsurf <value>  -fwhmvol <value>  -acquis <name>  -rmframe <value>  -doGMS  -tr <value> -tomni  -doCompCor  -doFilt  -doAAL  -doCraddock  -doStriatum  -doSPMNorm  -doANTSNorm  -doAnalysis  -doSeg  -oldNorm  -v <FSVersion> ]"
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
	sudo ln -s ${FREESURFER_HOME}/subjects/fsaverage5 ${SUBJECTS_DIR}/
elif [ "${FS_VERSION}" == "5.3" ]
then
	export FREESURFER_HOME=${Soft_dir}/freesurfer5.3/
	. ${FREESURFER_HOME}/SetUpFreeSurfer.sh
	sudo ln -s ${FREESURFER_HOME}/subjects/fsaverage5 ${SUBJECTS_DIR}/
fi


DoTemplate=1
DoMask=1
DoReg=1
DoMC=1
ToSurf=1

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

if [ ! -d ${DIR}/${outdir} ]
then
	mkdir ${DIR}/${outdir}
fi
if [ ! -d ${DIR}/${outdir}/run01 ]
then
	mkdir ${DIR}/${outdir}/run01
fi

cp ${epi} ${DIR}/${outdir}/
mri_convert ${DIR}/mri/T1.mgz ${DIR}/${outdir}/T1_las.nii --out_orientation LAS

filename=$(basename "$epi")
extension="${filename##*.}"
if [ "${extension}" == "gz" ]
then
	gunzip -f ${DIR}/${outdir}/${filename}
	filename="${filename%.*}"
fi
epi=${DIR}/${outdir}/${filename}

# Remove N first frames
mkdir ${DIR}/${outdir}/run01/tmp
echo "fslsplit ${epi} ${DIR}/${outdir}/run01/tmp/epi_ -t"
fslsplit ${epi} ${DIR}/${outdir}/run01/tmp/epi_ -t
for ((ind = 0; ind < ${remframe}; ind += 1))
do
	filename=`ls -1 ${DIR}/${outdir}/run01/tmp/ | sed -ne "1p"`
	rm -f ${DIR}/${outdir}/run01/tmp/${filename}
done

echo "fslmerge -t ${DIR}/${outdir}/run01/epi.nii ${DIR}/${outdir}/run01/tmp/epi_*"
fslmerge -t ${DIR}/${outdir}/run01/epi.nii ${DIR}/${outdir}/run01/tmp/epi_*

echo "gunzip -f ${DIR}/${outdir}/run01/*.gz"
gunzip -f ${DIR}/${outdir}/run01/*.gz
echo "rm -rf ${DIR}/${outdir}/run01/tmp"
rm -rf ${DIR}/${outdir}/run01/tmp


# ========================================================================================================================================
#                                                        RUNNING ...
# ========================================================================================================================================

if [ $DoTemplate -eq 1 ] && [ ! -f ${DIR}/${outdir}/run01/template.nii ]
then

	# Make EPI template file
	echo "mri_convert ${DIR}/${outdir}/run01/epi.nii ${DIR}/${outdir}/template.nii --frame 0"
	mri_convert ${DIR}/${outdir}/run01/epi.nii ${DIR}/${outdir}/template.nii --frame 0
	echo "mri_convert ${DIR}/${outdir}/run01/epi.nii ${DIR}/${outdir}/run01/template.nii --mid-frame"
	mri_convert ${DIR}/${outdir}/run01/epi.nii ${DIR}/${outdir}/run01/template.nii --mid-frame
	#cp ${DIR}/${outdir}/template.nii ${DIR}/${outdir}/run01/template.nii

fi


# ========================================================================================================================================
#            COMMON PREPROCESSING (motion correction - slice-timing correction - coregistration T1-EPI - spatial normalization)
# ========================================================================================================================================

if [ $DoMC -eq 1 ] && [ ! -f ${DIR}/${outdir}/run01/repi.nii ]
then

	mc-afni2 --i ${DIR}/${outdir}/run01/epi.nii --t ${DIR}/${outdir}/run01/template.nii --o ${DIR}/${outdir}/run01/repi.nii --mcdat ${DIR}/${outdir}/run01/repi.mcdat

	# Making external regressor from mc params
	mcdat2mcextreg --i ${DIR}/${outdir}/run01/repi.mcdat --o ${DIR}/${outdir}/run01/mcprextreg

fi
epipre=${DIR}/${outdir}/run01/repi.nii


if [ $DoSTC -eq 1 ] && [ ! -f ${DIR}/${outdir}/run01/arepi.nii ]
then

/usr/local/matlab/bin/matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);

	if strcmp('${acquis}','ascending')
		sliceorder = 1:1:${nslices};
	elseif strcmp('${acquis}','interleaved')
		sliceorder = [];
		space      = round(sqrt(${nslices}));
		for k=1:space
			tmp        = k:space:${nslices};
			sliceorder = [sliceorder tmp];
		end
	elseif strcmp('${acquis}','descending')
		sliceorder = [${nslices}:-2:1 ${nslices}-1:-2:1];
	else
		sliceorder = 1:1:${nslices};
	end

	[tempa,tempb,tempc]=fileparts('${epipre}'); 
	epifiles{1}=cellstr(spm_select('ExtFPList',tempa,['^',tempb,tempc],1:1e4));

	spm_get_defaults;
	spm_jobman('initcfg');
	matlabbatch = {};
	matlabbatch{end+1}.spm.temporal.st.scans    = epifiles;
        matlabbatch{end}.spm.temporal.st.tr         = ${TR};
        matlabbatch{end}.spm.temporal.st.nslices    = ${nslices};
        matlabbatch{end}.spm.temporal.st.ta         = ${TR}*(1-1/${nslices});
        matlabbatch{end}.spm.temporal.st.refslice   = floor(${nslices}/2);
        matlabbatch{end}.spm.temporal.st.so         = sliceorder;
        spm_jobman('run',matlabbatch);

EOF

	if [ $DoGMS -eq 1 ]
	then
		echo "Grand-mean scaling ${DIR}/${outdir}/run01/arepi.nii"
		fslmaths ${DIR}/${outdir}/run01/arepi.nii -ing 10000 ${DIR}/${outdir}/run01/arepi_gms.nii.gz -odt float
		gunzip -f ${DIR}/${outdir}/run01/arepi_gms.nii.gz
		rm -f ${DIR}/${outdir}/run01/arepi.nii
		mv ${DIR}/${outdir}/run01/arepi_gms.nii ${DIR}/${outdir}/run01/arepi.nii
	fi
	
else

	cp ${epipre} ${DIR}/${outdir}/run01/arepi.nii
	
	if [ $DoGMS -eq 1 ]
	then
		echo "Grand-mean scaling ${DIR}/${outdir}/run01/arepi.nii"
		fslmaths ${DIR}/${outdir}/run01/arepi.nii -ing 10000 ${DIR}/${outdir}/run01/arepi_gms.nii.gz -odt float
		gunzip -f ${DIR}/${outdir}/run01/arepi_gms.nii.gz
		rm -f ${DIR}/${outdir}/run01/arepi.nii
		mv ${DIR}/${outdir}/run01/arepi_gms.nii ${DIR}/${outdir}/run01/arepi.nii
	fi
	
fi

epipre=${DIR}/${outdir}/run01/arepi.nii

if [ $DoReg -eq 1 ] && [ ! -f ${DIR}/${outdir}/run01/arepi_sm${fwhmvol}_al.nii.gz ]
then

	fslmaths ${epipre} -Tmean ${DIR}/${outdir}/run01/mean_arepi.nii
	gunzip -f ${DIR}/${outdir}/run01/mean_arepi.nii.gz

	bbregister --s ${SUBJ} --init-fsl --6 --bold --mov ${DIR}/${outdir}/run01/mean_arepi.nii --reg ${DIR}/${outdir}/run01/register.dof6.dat --init-reg-out ${DIR}/${outdir}/run01/init.register.dof6.dat --o ${DIR}/${outdir}/run01/mean_arepi_al.nii
	tkregister2 --noedit --reg ${DIR}/${outdir}/run01/register.dof6.dat --mov ${DIR}/${outdir}/run01/mean_arepi.nii --targ ${DIR}/${outdir}/T1_las.nii --fslregout ${DIR}/${outdir}/fMRI2str.mat
	
	# to check results, run: tkregister2 --mov ${DIR}/${outdir}/run01/mean_arepi.nii --reg ${DIR}/${outdir}/run01/register.dof6.dat --surf
	mri_vol2vol --mov ${DIR}/${outdir}/run01/mean_arepi.nii --targ ${DIR}/mri/aparc.a2009s+aseg.mgz --o ${DIR}/${outdir}/run01/rparc.nii --inv --reg ${DIR}/${outdir}/run01/register.dof6.dat --nearest --no-save-reg
	mri_vol2vol --mov ${DIR}/${outdir}/run01/mean_arepi.nii --targ ${DIR}/mri/aparc.a2009s+aseg.mgz --o ${DIR}/${outdir}/run01/rparc_anat.nii --inv --reg ${DIR}/${outdir}/run01/register.dof6.dat --nearest --no-resample --no-save-reg
	mri_vol2vol --mov ${DIR}/${outdir}/run01/mean_arepi.nii --targ ${DIR}/mri/orig.mgz --o ${DIR}/${outdir}/run01/rorig.nii --inv --reg ${DIR}/${outdir}/run01/register.dof6.dat --no-save-reg
	mri_vol2vol --mov ${DIR}/${outdir}/run01/mean_arepi.nii --targ ${DIR}/mri/orig.mgz --o ${DIR}/${outdir}/run01/rorig_anat.nii --inv --reg ${DIR}/${outdir}/run01/register.dof6.dat --no-resample --no-save-reg
	mri_extract_label ${DIR}/${outdir}/run01/rparc.nii 41 2 ${DIR}/${outdir}/run01/rwm.nii
	mri_extract_label ${DIR}/${outdir}/run01/rparc.nii 24 ${DIR}/${outdir}/run01/rcsf.nii
	mri_extract_label ${DIR}/${outdir}/run01/rparc.nii 43 4 ${DIR}/${outdir}/run01/rvent.nii
	
	mri_vol2vol --mov ${DIR}/${outdir}/run01/mean_arepi.nii --targ ${DIR}/mri/orig.mgz --o ${DIR}/${outdir}/run01/mean_arepi_al.nii --reg ${DIR}/${outdir}/run01/register.dof6.dat --no-resample --no-save-reg
	
	# smoothing
	mri_vol2vol --mov ${DIR}/${outdir}/run01/arepi.nii --targ ${DIR}/mri/orig.mgz --o ${DIR}/${outdir}/run01/arepi_al.nii --reg ${DIR}/${outdir}/run01/register.dof6.dat --no-resample --no-save-reg
	echo "Smoothing ${DIR}/${outdir}/run01/arepi_al.nii"
	fslmaths ${DIR}/${outdir}/run01/arepi_al.nii -kernel gauss ${Sigma} -fmean ${DIR}/${outdir}/run01/arepi_sm${fwhmvol}_al.nii.gz

fi


if [ $DoMask -eq 1 ] && [ ! -f ${DIR}/${outdir}/masks/brain.nii ]
then

	# Make brain mask (template frame 0)
	mkdir ${DIR}/${outdir}/temp_mask
	mkdir ${DIR}/${outdir}/masks
	mri_convert ${DIR}/${outdir}/run01/mean_arepi.nii ${DIR}/${outdir}/temp_mask/in.nii
	# ---------- Using FSL's BET to Extract Brain------------------ #
	bet ${DIR}/${outdir}/temp_mask/in.nii ${DIR}/${outdir}/temp_mask/brain -m -f 0.1
	gunzip -f ${DIR}/${outdir}/temp_mask/brain_mask.nii.gz
	mri_binarize --i ${DIR}/${outdir}/temp_mask/brain_mask.nii --min .01 --o ${DIR}/${outdir}/temp_mask/brain_mask.nii
	# Diliating 1
	mri_binarize --i ${DIR}/${outdir}/temp_mask/brain_mask.nii --min 0.5 --dilate 1 --o ${DIR}/${outdir}/temp_mask/brain_mask.nii
	mri_convert ${DIR}/${outdir}/temp_mask/brain_mask.nii ${DIR}/${outdir}/masks/brain.nii
	rm -rf ${DIR}/${outdir}/temp_mask

	mri_binarize --i ${DIR}/${outdir}/masks/brain.nii --min 0.5 --zero-edges --erode 3 --o ${DIR}/${outdir}/masks/brain.e3.nii
	meanval --i ${DIR}/${outdir}/run01/epi.nii --m ${DIR}/${outdir}/masks/brain.e3.nii --o ${DIR}/${outdir}/run01/global.meanval.dat --avgwf ${DIR}/${outdir}/run01/global.waveform.dat

fi


if [ $DoANTSNorm -eq 1 ] && [ ! -f ${DIR}/${outdir}/run01/arepi_sm${fwhmvol}_al_MNI152_2mm.nii.gz ]
then

    if [ ! -f ${DIR}/${outdir}/norm_las.nii.gz ]
    then
	mri_convert ${DIR}/mri/norm.mgz ${DIR}/${outdir}/norm_las.nii.gz --out_orientation LAS
    fi
	
    TEMPLATE=${FSLDIR}/data/standard/MNI152_T1_1mm_brain.nii.gz
    TEMPLATE2=${FSLDIR}/data/standard/MNI152_T1_2mm.nii.gz
    if [ ! -f ${DIR}/${outdir}/norm_mni152.nii.gz ]
    then
	ANTS 3 -m MI[${TEMPLATE},${DIR}/${outdir}/norm_las.nii.gz,1,32] -o ${DIR}/${outdir}/norm_mni152_rigid -i 0 --rigid-affine true
	WarpImageMultiTransform 3 ${DIR}/${outdir}/norm_las.nii.gz ${DIR}/${outdir}/norm_mni152_rigid.nii.gz ${DIR}/${outdir}/norm_mni152_rigidAffine.txt -R ${TEMPLATE}
	ANTS 3 -m CC[${TEMPLATE},${DIR}/${outdir}/norm_mni152_rigid.nii.gz,1,4] -i 100x100x100x20 -o ${DIR}/${outdir}/norm_mni152 -t SyN[0.25] -r Gauss[3,0]
	WarpImageMultiTransform 3 ${DIR}/${outdir}/norm_las.nii.gz ${DIR}/${outdir}/norm_mni152.nii.gz ${DIR}/${outdir}/norm_mni152Warp.nii.gz ${DIR}/${outdir}/norm_mni152Affine.txt ${DIR}/${outdir}/norm_mni152_rigidAffine.txt -R ${TEMPLATE} --use-BSpline
    fi
    
    FMRI_ApplyAntsWarp.sh -epi ${DIR}/${outdir}/run01/arepi_al.nii -temp ${TEMPLATE2} -pref ${DIR}/${outdir}/norm_mni152 -o MNI152_2mm
    FMRI_ApplyAntsWarp.sh -epi ${DIR}/${outdir}/run01/mean_arepi_al.nii -temp ${TEMPLATE2} -pref ${DIR}/${outdir}/norm_mni152 -o MNI152_2mm
    
    echo "Smoothing ${DIR}/${outdir}/run01/arepi_al_MNI152_2mm.nii.gz"
    fslmaths ${DIR}/${outdir}/run01/arepi_al_MNI152_2mm.nii.gz -kernel gauss ${Sigma} -fmean ${DIR}/${outdir}/run01/arepi_sm${fwhmvol}_al_MNI152_2mm.nii.gz

fi


if [ $DoSPMNorm -eq 1 ] && [ ! -f ${DIR}/${outdir}/run01/warepi_sm${fwhmvol}_al.nii.gz ]
then	

/usr/local/matlab/bin/matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);

	spm_get_defaults;
	spm_jobman('initcfg');
	matlabbatch = {};

	if ${oldNorm}==0
	  matlabbatch{end+1}.spm.spatial.normalise.est.subj.vol        = cellstr('${DIR}/${outdir}/T1_las.nii');
	  matlabbatch{end}.spm.spatial.normalise.est.eoptions.biasreg  = 0.0001;
	  matlabbatch{end}.spm.spatial.normalise.est.eoptions.biasfwhm = 60;
	  matlabbatch{end}.spm.spatial.normalise.est.eoptions.tpm      = {'/home/global/matlab_toolbox/spm12b/tpm/TPM.nii'};
	  matlabbatch{end}.spm.spatial.normalise.est.eoptions.affreg   = 'mni';
	  matlabbatch{end}.spm.spatial.normalise.est.eoptions.reg      = [0 0.001 0.5 0.05 0.2];
	  matlabbatch{end}.spm.spatial.normalise.est.eoptions.fwhm     = 0;
	  matlabbatch{end}.spm.spatial.normalise.est.eoptions.samp     = 3;
	else
	  matlabbatch{end+1}.spm.tools.oldnorm.est.subj.source     = cellstr('${DIR}/${outdir}/run01/mean_arepi_al.nii');
	  matlabbatch{end}.spm.tools.oldnorm.est.subj.wtsrc        = '';
	  matlabbatch{end}.spm.tools.oldnorm.est.eoptions.template = {'/home/global/matlab_toolbox/spm12b/toolbox/OldNorm/EPI.nii,1'};
	  matlabbatch{end}.spm.tools.oldnorm.est.eoptions.weight   = '';
	  matlabbatch{end}.spm.tools.oldnorm.est.eoptions.smosrc   = 8;
	  matlabbatch{end}.spm.tools.oldnorm.est.eoptions.smoref   = 0;
	  matlabbatch{end}.spm.tools.oldnorm.est.eoptions.regtype  = 'mni';
	  matlabbatch{end}.spm.tools.oldnorm.est.eoptions.cutoff   = 25;
	  matlabbatch{end}.spm.tools.oldnorm.est.eoptions.nits     = 16;
	  matlabbatch{end}.spm.tools.oldnorm.est.eoptions.reg      = 1;
	  
	  matlabbatch{end+1}.spm.tools.oldnorm.est.subj.source     = cellstr('${DIR}/${outdir}/run01/mean_arepi.nii');
	  matlabbatch{end}.spm.tools.oldnorm.est.subj.wtsrc        = '';
	  matlabbatch{end}.spm.tools.oldnorm.est.eoptions.template = {'/home/global/matlab_toolbox/spm12b/toolbox/OldNorm/EPI.nii,1'};
	  matlabbatch{end}.spm.tools.oldnorm.est.eoptions.weight   = '';
	  matlabbatch{end}.spm.tools.oldnorm.est.eoptions.smosrc   = 8;
	  matlabbatch{end}.spm.tools.oldnorm.est.eoptions.smoref   = 0;
	  matlabbatch{end}.spm.tools.oldnorm.est.eoptions.regtype  = 'mni';
	  matlabbatch{end}.spm.tools.oldnorm.est.eoptions.cutoff   = 25;
	  matlabbatch{end}.spm.tools.oldnorm.est.eoptions.nits     = 16;
	  matlabbatch{end}.spm.tools.oldnorm.est.eoptions.reg      = 1;
	end

	spm_jobman('run',matlabbatch);

	[tempa,tempb,tempc] = fileparts('${DIR}/${outdir}/run01/arepi_al.nii');

	clear matlabbatch 
	matlabbatch = {};
	if ${oldNorm}==0
	  matlabbatch{end+1}.spm.spatial.normalise.write.subj.def      = cellstr('${DIR}/${outdir}/y_T1_las.nii');
	  matlabbatch{end}.spm.spatial.normalise.write.subj.resample   = cellstr(spm_select('ExtFPList',tempa,['^',tempb,tempc],1:1e4));
	  matlabbatch{end}.spm.spatial.normalise.write.woptions.bb     = [-78 -112 -70; 78 76 85];
	  matlabbatch{end}.spm.spatial.normalise.write.woptions.vox    = [2 2 2];
	  matlabbatch{end}.spm.spatial.normalise.write.woptions.interp = 4;
	else
	  matlabbatch{end+1}.spm.tools.oldnorm.write.subj.matname    = cellstr('${DIR}/${outdir}/run01/mean_arepi_al_sn.mat');
	  matlabbatch{end}.spm.tools.oldnorm.write.subj.resample     = cellstr(spm_select('ExtFPList',tempa,['^',tempb,tempc],1:1e4));
	  matlabbatch{end}.spm.tools.oldnorm.write.roptions.preserve = 0;
	  matlabbatch{end}.spm.tools.oldnorm.write.roptions.bb       = [-78 -112 -70; 78 76 85];
	  matlabbatch{end}.spm.tools.oldnorm.write.roptions.vox      = [2 2 2];
	  matlabbatch{end}.spm.tools.oldnorm.write.roptions.interp   = 4;
	  matlabbatch{end}.spm.tools.oldnorm.write.roptions.wrap     = [0 0 0];
	  matlabbatch{end}.spm.tools.oldnorm.write.roptions.prefix   = 'w';
	end
	spm_jobman('run',matlabbatch);
	
	clear matlabbatch 
	matlabbatch = {};
	if ${oldNorm}==0
	  matlabbatch{end+1}.spm.spatial.normalise.write.subj.def      = cellstr('${DIR}/${outdir}/y_T1_las.nii');
	  matlabbatch{end}.spm.spatial.normalise.write.subj.resample   = cellstr('${DIR}/${outdir}/run01/mean_arepi_al.nii');
	  matlabbatch{end}.spm.spatial.normalise.write.woptions.bb     = [-78 -112 -70; 78 76 85];
	  matlabbatch{end}.spm.spatial.normalise.write.woptions.vox    = [2 2 2];
	  matlabbatch{end}.spm.spatial.normalise.write.woptions.interp = 4;
	else
	  matlabbatch{end+1}.spm.tools.oldnorm.write.subj.matname    = cellstr('${DIR}/${outdir}/run01/mean_arepi_al_sn.mat');
	  matlabbatch{end}.spm.tools.oldnorm.write.subj.resample     = cellstr('${DIR}/${outdir}/run01/mean_arepi_al.nii');
	  matlabbatch{end}.spm.tools.oldnorm.write.roptions.preserve = 0;
	  matlabbatch{end}.spm.tools.oldnorm.write.roptions.bb       = [-78 -112 -70; 78 76 85];
	  matlabbatch{end}.spm.tools.oldnorm.write.roptions.vox      = [2 2 2];
	  matlabbatch{end}.spm.tools.oldnorm.write.roptions.interp   = 4;
	  matlabbatch{end}.spm.tools.oldnorm.write.roptions.wrap     = [0 0 0];
	  matlabbatch{end}.spm.tools.oldnorm.write.roptions.prefix   = 'w';
	  
	  matlabbatch{end+1}.spm.tools.oldnorm.write.subj.matname    = cellstr('${DIR}/${outdir}/run01/mean_arepi_al_sn.mat');
	  matlabbatch{end}.spm.tools.oldnorm.write.subj.resample     = cellstr('${DIR}/${outdir}/T1_las.nii');
	  matlabbatch{end}.spm.tools.oldnorm.write.roptions.preserve = 0;
	  matlabbatch{end}.spm.tools.oldnorm.write.roptions.bb       = [-78 -112 -70; 78 76 85];
	  matlabbatch{end}.spm.tools.oldnorm.write.roptions.vox      = [2 2 2];
	  matlabbatch{end}.spm.tools.oldnorm.write.roptions.interp   = 4;
	  matlabbatch{end}.spm.tools.oldnorm.write.roptions.wrap     = [0 0 0];
	  matlabbatch{end}.spm.tools.oldnorm.write.roptions.prefix   = 'we';
	end
	spm_jobman('run',matlabbatch);

EOF
 
	# Create EPI mask 
	fslmaths ${DIR}/${outdir}/run01/wmean_arepi_al.nii -nan ${DIR}/${outdir}/run01/wmean_arepi_al.nii
	rm -f ${DIR}/${outdir}/run01/wmean_arepi_al.nii
	gunzip -f ${DIR}/${outdir}/run01/wmean_arepi_al.nii.gz
	bet ${DIR}/${outdir}/run01/wmean_arepi_al.nii ${DIR}/${outdir}/run01/wepi -m -n -f 0.4
	gunzip -f ${DIR}/${outdir}/run01/wepi_mask.nii.gz
	
	echo "Smoothing ${DIR}/${outdir}/run01/warepi_al.nii"
	fslmaths ${DIR}/${outdir}/run01/warepi_al.nii -kernel gauss ${Sigma} -fmean ${DIR}/${outdir}/run01/warepi_sm${fwhmvol}_al.nii.gz

fi

# Create EPI mask
fslmaths ${DIR}/${outdir}/run01/mean_arepi_al.nii -nan ${DIR}/${outdir}/run01/mean_arepi_al.nii
rm -f ${DIR}/${outdir}/run01/mean_arepi_al.nii
gunzip -f ${DIR}/${outdir}/run01/mean_arepi_al.nii.gz
bet ${DIR}/${outdir}/run01/mean_arepi_al.nii ${DIR}/${outdir}/run01/epi -m -n -f 0.4
gunzip -f ${DIR}/${outdir}/run01/epi_mask.nii.gz


if [ $DoSeg -eq 1 ] && [ ! -f ${DIR}/${outdir}/c1T1_las_MNI152_2mm.nii.gz ]
then

/usr/local/matlab/bin/matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);

	spm_get_defaults;
	spm_jobman('initcfg');
	matlabbatch = {};

	matlabbatch{end+1}.spm.spatial.preproc.channel.vols = {'${DIR}/${outdir}/T1_las.nii'};
	matlabbatch{end}.spm.spatial.preproc.channel.biasreg = 0.001;
	matlabbatch{end}.spm.spatial.preproc.channel.biasfwhm = 60;
	matlabbatch{end}.spm.spatial.preproc.channel.write = [0 0];
	matlabbatch{end}.spm.spatial.preproc.tissue(1).tpm = {'/home/global/matlab_toolbox/spm12b/tpm/TPM.nii,1'};
	matlabbatch{end}.spm.spatial.preproc.tissue(1).ngaus = 1;
	matlabbatch{end}.spm.spatial.preproc.tissue(1).native = [1 0];
	matlabbatch{end}.spm.spatial.preproc.tissue(1).warped = [0 0];
	matlabbatch{end}.spm.spatial.preproc.tissue(2).tpm = {'/home/global/matlab_toolbox/spm12b/tpm/TPM.nii,2'};
	matlabbatch{end}.spm.spatial.preproc.tissue(2).ngaus = 1;
	matlabbatch{end}.spm.spatial.preproc.tissue(2).native = [1 0];
	matlabbatch{end}.spm.spatial.preproc.tissue(2).warped = [0 0];
	matlabbatch{end}.spm.spatial.preproc.tissue(3).tpm = {'/home/global/matlab_toolbox/spm12b/tpm/TPM.nii,3'};
	matlabbatch{end}.spm.spatial.preproc.tissue(3).ngaus = 2;
	matlabbatch{end}.spm.spatial.preproc.tissue(3).native = [1 0];
	matlabbatch{end}.spm.spatial.preproc.tissue(3).warped = [0 0];
	matlabbatch{end}.spm.spatial.preproc.tissue(4).tpm = {'/home/global/matlab_toolbox/spm12b/tpm/TPM.nii,4'};
	matlabbatch{end}.spm.spatial.preproc.tissue(4).ngaus = 3;
	matlabbatch{end}.spm.spatial.preproc.tissue(4).native = [0 0];
	matlabbatch{end}.spm.spatial.preproc.tissue(4).warped = [0 0];
	matlabbatch{end}.spm.spatial.preproc.tissue(5).tpm = {'/home/global/matlab_toolbox/spm12b/tpm/TPM.nii,5'};
	matlabbatch{end}.spm.spatial.preproc.tissue(5).ngaus = 4;
	matlabbatch{end}.spm.spatial.preproc.tissue(5).native = [0 0];
	matlabbatch{end}.spm.spatial.preproc.tissue(5).warped = [0 0];
	matlabbatch{end}.spm.spatial.preproc.tissue(6).tpm = {'/home/global/matlab_toolbox/spm12b/tpm/TPM.nii,6'};
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

	spm_jobman('run',matlabbatch);

EOF

	if [ $DoSPMNorm -eq 1 ]
	then

/usr/local/matlab/bin/matlab -nodisplay <<EOF

		% Load Matlab Path
		cd ${HOME}
		p = pathdef;
		addpath(p);

		filestmp{1}='${DIR}/${outdir}/c1T1_las.nii';
		filestmp{2}='${DIR}/${outdir}/c2T1_las.nii';
		filestmp{3}='${DIR}/${outdir}/c3T1_las.nii';
		filestmp{4}='${DIR}/${outdir}/T1_las.nii';

		spm_get_defaults;
		spm_jobman('initcfg');
		matlabbatch = {};
		
		if ${oldNorm}==0
		  matlabbatch{end+1}.spm.spatial.normalise.write.subj.def      = cellstr('${DIR}/${outdir}/y_T1_las.nii');
		  matlabbatch{end}.spm.spatial.normalise.write.subj.resample   = filestmp;
		  matlabbatch{end}.spm.spatial.normalise.write.woptions.bb     = [-78 -112 -70; 78 76 85];
		  matlabbatch{end}.spm.spatial.normalise.write.woptions.vox    = [2 2 2];
		  matlabbatch{end}.spm.spatial.normalise.write.woptions.interp = 4;
		else
		  matlabbatch{end+1}.spm.tools.oldnorm.est.subj.source     = cellstr('${DIR}/${outdir}/T1_las.nii');
		  matlabbatch{end}.spm.tools.oldnorm.est.subj.wtsrc        = '';
		  matlabbatch{end}.spm.tools.oldnorm.est.eoptions.template = {'/home/global/matlab_toolbox/spm12b/toolbox/OldNorm/T1_las.nii,1'};
		  matlabbatch{end}.spm.tools.oldnorm.est.eoptions.weight   = '';
		  matlabbatch{end}.spm.tools.oldnorm.est.eoptions.smosrc   = 8;
		  matlabbatch{end}.spm.tools.oldnorm.est.eoptions.smoref   = 0;
		  matlabbatch{end}.spm.tools.oldnorm.est.eoptions.regtype  = 'mni';
		  matlabbatch{end}.spm.tools.oldnorm.est.eoptions.cutoff   = 25;
		  matlabbatch{end}.spm.tools.oldnorm.est.eoptions.nits     = 16;
		  matlabbatch{end}.spm.tools.oldnorm.est.eoptions.reg      = 1;
		  matlabbatch{end+1}.spm.tools.oldnorm.write.subj.matname    = cellstr('${DIR}/${outdir}/T1_las_sn.mat');
		  matlabbatch{end}.spm.tools.oldnorm.write.subj.resample     = filestmp;
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.preserve = 0;
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.bb       = [-78 -112 -70; 78 76 85];
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.vox      = [2 2 2];
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.interp   = 4;
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.wrap     = [0 0 0];
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.prefix   = 'w';
		end
		
		spm_jobman('run',matlabbatch);
EOF
	fi
	
	if [ $DoANTSNorm -eq 1 ]
	then
		
	    TEMPLATE2=${FSLDIR}/data/standard/MNI152_T1_2mm.nii.gz

	    WarpImageMultiTransform 3 ${DIR}/${outdir}/c1T1_las.nii ${DIR}/${outdir}/c1T1_las_MNI152_2mm.nii.gz ${DIR}/${outdir}/norm_mni152Warp.nii.gz ${DIR}/${outdir}/norm_mni152Affine.txt ${DIR}/${outdir}/norm_mni152_rigidAffine.txt -R ${TEMPLATE2} --use-BSpline
	    WarpImageMultiTransform 3 ${DIR}/${outdir}/c2T1_las.nii ${DIR}/${outdir}/c2T1_las_MNI152_2mm.nii.gz ${DIR}/${outdir}/norm_mni152Warp.nii.gz ${DIR}/${outdir}/norm_mni152Affine.txt ${DIR}/${outdir}/norm_mni152_rigidAffine.txt -R ${TEMPLATE2} --use-BSpline
	    WarpImageMultiTransform 3 ${DIR}/${outdir}/c3T1_las.nii ${DIR}/${outdir}/c3T1_las_MNI152_2mm.nii.gz ${DIR}/${outdir}/norm_mni152Warp.nii.gz ${DIR}/${outdir}/norm_mni152Affine.txt ${DIR}/${outdir}/norm_mni152_rigidAffine.txt -R ${TEMPLATE2} --use-BSpline

	fi
	
fi


if [ $ToSurf -eq 1 ] && [ ! -f ${DIR}/${outdir}/run01/arepi.sm${fwhmsurf}.fsaverage5.rh.nii ]
then

	# native
 
	# lh
	mri_vol2surf --mov ${DIR}/${outdir}/masks/brain.nii --reg ${DIR}/${outdir}/run01/register.dof6.dat --trgsubject ${SUBJ} --interp nearest --projfrac 0.5 --hemi lh --o ${DIR}/${outdir}/masks/brain.lh.nii --noreshape --cortex --surfreg sphere.reg
	mri_binarize --i ${DIR}/${outdir}/masks/brain.lh.nii --min .00001 --o ${DIR}/${outdir}/masks/brain.lh.nii
	mri_vol2surf --mov ${epipre} --reg ${DIR}/${outdir}/run01/register.dof6.dat --trgsubject ${SUBJ} --interp trilin --projfrac 0.5 --hemi lh --o ${DIR}/${outdir}/run01/arepi.lh.nii --noreshape --cortex --surfreg sphere.reg
	mris_fwhm --s ${SUBJ} --hemi lh --smooth-only --i ${DIR}/${outdir}/run01/arepi.lh.nii --fwhm ${fwhmsurf} --o ${DIR}/${outdir}/run01/arepi.sm${fwhmsurf}.lh.nii --mask ${DIR}/${outdir}/masks/brain.lh.nii

	# rh
	mri_vol2surf --mov ${DIR}/${outdir}/masks/brain.nii --reg ${DIR}/${outdir}/run01/register.dof6.dat --trgsubject ${SUBJ} --interp nearest --projfrac 0.5 --hemi rh --o ${DIR}/${outdir}/masks/brain.rh.nii --noreshape --cortex --surfreg sphere.reg
	mri_binarize --i ${DIR}/${outdir}/masks/brain.rh.nii --min .00001 --o ${DIR}/${outdir}/masks/brain.rh.nii
	mri_vol2surf --mov ${epipre} --reg ${DIR}/${outdir}/run01/register.dof6.dat --trgsubject ${SUBJ} --interp trilin --projfrac 0.5 --hemi rh --o ${DIR}/${outdir}/run01/arepi.rh.nii --noreshape --cortex --surfreg sphere.reg
	mris_fwhm --s ${SUBJ} --hemi rh --smooth-only --i ${DIR}/${outdir}/run01/arepi.rh.nii --fwhm ${fwhmsurf} --o ${DIR}/${outdir}/run01/arepi.sm${fwhmsurf}.rh.nii --mask ${DIR}/${outdir}/masks/brain.rh.nii

	# fsaverage

	# lh
	mri_vol2surf --mov ${DIR}/${outdir}/masks/brain.nii --reg ${DIR}/${outdir}/run01/register.dof6.dat --trgsubject fsaverage --interp nearest --projfrac 0.5 --hemi lh --o ${DIR}/${outdir}/masks/brain.fsaverage.lh.nii --noreshape --cortex --surfreg sphere.reg
	mri_binarize --i ${DIR}/${outdir}/masks/brain.fsaverage.lh.nii --min .00001 --o ${DIR}/${outdir}/masks/brain.fsaverage.lh.nii
	mri_vol2surf --mov ${epipre} --reg ${DIR}/${outdir}/run01/register.dof6.dat --trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi lh --o ${DIR}/${outdir}/run01/arepi.fsaverage.lh.nii --noreshape --cortex --surfreg sphere.reg
	mris_fwhm --s fsaverage --hemi lh --smooth-only --i ${DIR}/${outdir}/run01/arepi.fsaverage.lh.nii --fwhm ${fwhmsurf} --o ${DIR}/${outdir}/run01/arepi.sm${fwhmsurf}.fsaverage.lh.nii --mask ${DIR}/${outdir}/masks/brain.fsaverage.lh.nii

	# rh
	mri_vol2surf --mov ${DIR}/${outdir}/masks/brain.nii --reg ${DIR}/${outdir}/run01/register.dof6.dat --trgsubject fsaverage --interp nearest --projfrac 0.5 --hemi rh --o ${DIR}/${outdir}/masks/brain.fsaverage.rh.nii --noreshape --cortex --surfreg sphere.reg
	mri_binarize --i ${DIR}/${outdir}/masks/brain.fsaverage.rh.nii --min .00001 --o ${DIR}/${outdir}/masks/brain.fsaverage.rh.nii
	mri_vol2surf --mov ${epipre} --reg ${DIR}/${outdir}/run01/register.dof6.dat --trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi rh --o ${DIR}/${outdir}/run01/arepi.fsaverage.rh.nii --noreshape --cortex --surfreg sphere.reg
	mris_fwhm --s fsaverage --hemi rh --smooth-only --i ${DIR}/${outdir}/run01/arepi.fsaverage.rh.nii --fwhm ${fwhmsurf} --o ${DIR}/${outdir}/run01/arepi.sm${fwhmsurf}.fsaverage.rh.nii --mask ${DIR}/${outdir}/masks/brain.fsaverage.rh.nii

	# fsaverage5

	# lh
	mri_vol2surf --mov ${DIR}/${outdir}/masks/brain.nii --reg ${DIR}/${outdir}/run01/register.dof6.dat --trgsubject fsaverage5 --interp nearest --projfrac 0.5 --hemi lh --o ${DIR}/${outdir}/masks/brain.fsaverage5.lh.nii --noreshape --cortex --surfreg sphere.reg
	mri_binarize --i ${DIR}/${outdir}/masks/brain.fsaverage5.lh.nii --min .00001 --o ${DIR}/${outdir}/masks/brain.fsaverage5.lh.nii
	mri_vol2surf --mov ${epipre} --reg ${DIR}/${outdir}/run01/register.dof6.dat --trgsubject fsaverage5 --interp trilin --projfrac 0.5 --hemi lh --o ${DIR}/${outdir}/run01/arepi.fsaverage5.lh.nii --noreshape --cortex --surfreg sphere.reg
	mris_fwhm --s fsaverage5 --hemi lh --smooth-only --i ${DIR}/${outdir}/run01/arepi.fsaverage5.lh.nii --fwhm ${fwhmsurf} --o ${DIR}/${outdir}/run01/arepi.sm${fwhmsurf}.fsaverage5.lh.nii --mask ${DIR}/${outdir}/masks/brain.fsaverage5.lh.nii

	# rh
	mri_vol2surf --mov ${DIR}/${outdir}/masks/brain.nii --reg ${DIR}/${outdir}/run01/register.dof6.dat --trgsubject fsaverage5 --interp nearest --projfrac 0.5 --hemi rh --o ${DIR}/${outdir}/masks/brain.fsaverage5.rh.nii --noreshape --cortex --surfreg sphere.reg
	mri_binarize --i ${DIR}/${outdir}/masks/brain.fsaverage5.rh.nii --min .00001 --o ${DIR}/${outdir}/masks/brain.fsaverage5.rh.nii
	mri_vol2surf --mov ${epipre} --reg ${DIR}/${outdir}/run01/register.dof6.dat --trgsubject fsaverage5 --interp trilin --projfrac 0.5 --hemi rh --o ${DIR}/${outdir}/run01/arepi.fsaverage5.rh.nii --noreshape --cortex --surfreg sphere.reg
	mris_fwhm --s fsaverage5 --hemi rh --smooth-only --i ${DIR}/${outdir}/run01/arepi.fsaverage5.rh.nii --fwhm ${fwhmsurf} --o ${DIR}/${outdir}/run01/arepi.sm${fwhmsurf}.fsaverage5.rh.nii --mask ${DIR}/${outdir}/masks/brain.fsaverage5.rh.nii

fi


if [ $ToMNI305 -eq 1 ] && [ ! -f ${DIR}/${outdir}/run01/vent.mni305.2mm.nii.gz ]
then

	mri_vol2vol --mov ${DIR}/${outdir}/masks/brain.nii --reg ${DIR}/${outdir}/run01/register.dof6.dat --tal --talres 2 --talxfm talairach.xfm --nearest --no-save-reg --o ${DIR}/${outdir}/masks/brain.mni305.2mm.nii
	mri_vol2vol --mov ${epipre} --reg ${DIR}/${outdir}/run01/register.dof6.dat --tal --talres 2 --talxfm talairach.xfm --interp trilin --no-save-reg --o ${DIR}/${outdir}/run01/arepi.mni305.2mm.nii
	echo "Smoothing ${DIR}/${outdir}/run01/arepi.mni305.2mm.nii"
	fslmaths ${DIR}/${outdir}/run01/arepi.mni305.2mm.nii -kernel gauss ${Sigma} -fmean ${DIR}/${outdir}/run01/arepi_sm${fwhmvol}.mni305.2mm.nii.gz
	
	mri_vol2vol --s ${SUBJ} --mov ${DIR}/mri/orig.mgz --tal --talres 1 --nearest --talxfm talairach.xfm --o ${DIR}/${outdir}/run01/orig.mni305.1mm.nii --no-save-reg
	mri_vol2vol --s ${SUBJ} --mov ${DIR}/mri/orig.mgz --tal --talres 2 --nearest --talxfm talairach.xfm --o ${DIR}/${outdir}/run01/orig.mni305.2mm.nii --no-save-reg
	mri_vol2vol --s ${SUBJ} --mov ${DIR}/mri/ribbon.mgz --tal --talres 1 --nearest --talxfm talairach.xfm --o ${DIR}/${outdir}/run01/ribbon.mni305.1mm.nii --no-save-reg

	# parcellation
	mri_vol2vol --s ${SUBJ} --mov ${DIR}/mri/aparc.a2009s+aseg.mgz --tal --talres 1 --nearest --talxfm talairach.xfm --o ${DIR}/${outdir}/run01/aparc.mni305.1mm.nii.gz --no-save-reg
	mri_vol2vol --s ${SUBJ} --mov ${DIR}/mri/aparc.a2009s+aseg.mgz --tal --talres 2 --nearest --talxfm talairach.xfm --o ${DIR}/${outdir}/run01/aparc.mni305.2mm.nii.gz --no-save-reg
	mri_extract_label ${DIR}/${outdir}/run01/aparc.mni305.2mm.nii.gz 41 2 ${DIR}/${outdir}/run01/wm.mni305.2mm.nii.gz
	mri_extract_label ${DIR}/${outdir}/run01/aparc.mni305.2mm.nii.gz 24 ${DIR}/${outdir}/run01/csf.mni305.2mm.nii.gz
	mri_extract_label ${DIR}/${outdir}/run01/aparc.mni305.2mm.nii.gz 43 4 ${DIR}/${outdir}/run01/vent.mni305.2mm.nii.gz
fi


# ========================================================================================================================================
#      Regress slow time drift, global signal, motion parameters as well as "scrubbing" of time frames with excessive motion
# ========================================================================================================================================

# -------------------------------------------------------------------------------------------
# STEP 1: Without scrubbing

if [ $DoCompCor -eq 1 ] && [ ! -f ${DIR}/${outdir}/run01/carepi_sm${fwhmvol}_al_MNI152_2mm.nii.gz ]
then
	
/usr/local/matlab/bin/matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);

        files_in  = '${DIR}/${outdir}/run01/arepi.nii';
	[p,n,e]   = fileparts(files_in);
	outfolder = '${DIR}/${outdir}';

        files_out.dc_high       = fullfile(outfolder,'run01',[n '_dc_high.mat']); 
        files_out.dc_low        = fullfile(outfolder,'run01',[n '_dc_low.mat']);
        files_out.filtered_data = 'gb_niak_omitted';
        files_out.var_high      = 'gb_niak_omitted';
        files_out.var_low       = 'gb_niak_omitted';
        files_out.beta_high     = 'gb_niak_omitted';
        files_out.beta_low      = 'gb_niak_omitted';

        opt = struct('folder_out',[outfolder '/run01/'],'flag_test',0,'flag_mean',1,'flag_verbose',1,'tr',${TR},'hp',0.01,'lp',Inf);
        niak_brick_time_filter(files_in,files_out,opt);
        clear files_in files_out opt;

        files_in.fmri         = '${DIR}/${outdir}/run01/arepi.nii';
        files_in.dc_low       = fullfile(outfolder,'run01',[n '_dc_low.mat']);
        files_in.dc_high      = fullfile(outfolder,'run01',[n '_dc_high.mat']); 
        files_in.custom_param = 'gb_niak_omitted';
        files_in.motion_param = fullfile(outfolder,'run01','mcprextreg');
        files_in.mask_brain   = fullfile(outfolder,'masks','brain.nii');
        files_in.mask_vent    = fullfile(outfolder,'run01','rvent.nii');
        files_in.mask_wm      = fullfile(outfolder,'run01','rwm.nii');

        files_out.scrubbing       = 'gb_niak_omitted';
        files_out.compcor_mask    = fullfile(outfolder,'run01',['compcor_mask_' n '.mat']);
        files_out.confounds       = fullfile(outfolder,'run01',['confounds_gs_' n '_cor' '.mat']);
        files_out.filtered_data   = fullfile(outfolder,'run01',['c' n e]);
        files_out.qc_compcor      = fullfile(outfolder,'run01',[n '_qc_compcor' e]);
        files_out.qc_slow_drift   = fullfile(outfolder,'run01',[n '_qc_slow_drift' e]);
        files_out.qc_high         = 'gb_niak_omitted';
        files_out.qc_wm           = fullfile(outfolder,'run01',[n '_qc_wm' e]);
        files_out.qc_vent         = fullfile(outfolder,'run01',[n '_qc_vent' e]);
        files_out.qc_motion       = fullfile(outfolder,'run01',[n '_qc_motion' e]);
        files_out.qc_custom_param = 'gb_niak_omitted';
        files_out.qc_gse          = fullfile(outfolder,'run01',[n '_qc_gse' e]);
                     
	opt = struct('flag_compcor',0,'compcor',struct(),'nb_vol_min',40,'flag_scrubbing',1,'thre_fd',0.8,'flag_slow',1,...
                         'flag_high',0,'folder_out',[outfolder '/run01/'],'flag_verbose',1,'flag_motion_params',1,'flag_wm',1,...
                         'flag_vent',1,'flag_gsc',0,'flag_pca_motion',1,'flag_test',0,'pct_var_explained',0.95);

        FMRI_RegressConfoundsByNiak(files_in,files_out,opt);

        clear files_in files_out opt;

EOF

	episc=${DIR}/${outdir}/run01/carepi.nii
	mri_vol2vol --mov ${DIR}/${outdir}/run01/carepi.nii --targ ${DIR}/mri/orig.mgz --o ${DIR}/${outdir}/run01/carepi_al.nii --reg ${DIR}/${outdir}/run01/register.dof6.dat --no-resample --no-save-reg
	
	# smoothing
	echo "Smoothing ${episc}"
	fslmaths ${episc} -kernel gauss ${Sigma} -fmean ${DIR}/${outdir}/run01/carepi_sm${fwhmvol}.nii.gz
	mri_vol2vol --mov ${DIR}/${outdir}/run01/carepi.nii --targ ${DIR}/mri/orig.mgz --o ${DIR}/${outdir}/run01/carepi_al.nii --reg ${DIR}/${outdir}/run01/register.dof6.dat --no-resample --no-save-reg
	echo "Smoothing ${DIR}/${outdir}/run01/carepi_al.nii"
	fslmaths ${DIR}/${outdir}/run01/carepi_al.nii -kernel gauss ${Sigma} -fmean ${DIR}/${outdir}/run01/carepi_sm${fwhmvol}_al.nii.gz

	# native surface
 
	# lh
	mri_vol2surf --mov ${episc} --reg ${DIR}/${outdir}/run01/register.dof6.dat --trgsubject ${SUBJ} --interp trilin --projfrac 0.5 --hemi lh --o ${DIR}/${outdir}/run01/carepi.lh.nii --noreshape --cortex --surfreg sphere.reg
	mris_fwhm --s ${SUBJ} --hemi lh --smooth-only --i ${DIR}/${outdir}/run01/carepi.lh.nii --fwhm ${fwhmsurf} --o ${DIR}/${outdir}/run01/carepi.sm${fwhmsurf}.lh.nii --mask ${DIR}/${outdir}/masks/brain.lh.nii

	# rh
	mri_vol2surf --mov ${episc} --reg ${DIR}/${outdir}/run01/register.dof6.dat --trgsubject ${SUBJ} --interp trilin --projfrac 0.5 --hemi rh --o ${DIR}/${outdir}/run01/carepi.rh.nii --noreshape --cortex --surfreg sphere.reg
	mris_fwhm --s ${SUBJ} --hemi rh --smooth-only --i ${DIR}/${outdir}/run01/carepi.rh.nii --fwhm ${fwhmsurf} --o ${DIR}/${outdir}/run01/carepi.sm${fwhmsurf}.rh.nii --mask ${DIR}/${outdir}/masks/brain.rh.nii

	# fsaverage surface

	# lh
	mri_vol2surf --mov ${episc} --reg ${DIR}/${outdir}/run01/register.dof6.dat --trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi lh --o ${DIR}/${outdir}/run01/carepi.fsaverage.lh.nii --noreshape --cortex --surfreg sphere.reg
	mris_fwhm --s fsaverage --hemi lh --smooth-only --i ${DIR}/${outdir}/run01/carepi.fsaverage.lh.nii --fwhm ${fwhmsurf} --o ${DIR}/${outdir}/run01/carepi.sm${fwhmsurf}.fsaverage.lh.nii --mask ${DIR}/${outdir}/masks/brain.fsaverage.lh.nii

	# rh
	mri_vol2surf --mov ${episc} --reg ${DIR}/${outdir}/run01/register.dof6.dat --trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi rh --o ${DIR}/${outdir}/run01/carepi.fsaverage.rh.nii --noreshape --cortex --surfreg sphere.reg
	mris_fwhm --s fsaverage --hemi rh --smooth-only --i ${DIR}/${outdir}/run01/carepi.fsaverage.rh.nii --fwhm ${fwhmsurf} --o ${DIR}/${outdir}/run01/carepi.sm${fwhmsurf}.fsaverage.rh.nii --mask ${DIR}/${outdir}/masks/brain.fsaverage.rh.nii

	# fsaverage5 surface

	# lh
	mri_vol2surf --mov ${episc} --reg ${DIR}/${outdir}/run01/register.dof6.dat --trgsubject fsaverage5 --interp trilin --projfrac 0.5 --hemi lh --o ${DIR}/${outdir}/run01/carepi.fsaverage5.lh.nii --noreshape --cortex --surfreg sphere.reg
	mris_fwhm --s fsaverage5 --hemi lh --smooth-only --i ${DIR}/${outdir}/run01/carepi.fsaverage5.lh.nii --fwhm ${fwhmsurf} --o ${DIR}/${outdir}/run01/carepi.sm${fwhmsurf}.fsaverage5.lh.nii --mask ${DIR}/${outdir}/masks/brain.fsaverage5.lh.nii

	# rh
	mri_vol2surf --mov ${episc} --reg ${DIR}/${outdir}/run01/register.dof6.dat --trgsubject fsaverage5 --interp trilin --projfrac 0.5 --hemi rh --o ${DIR}/${outdir}/run01/carepi.fsaverage5.rh.nii --noreshape --cortex --surfreg sphere.reg
	mris_fwhm --s fsaverage5 --hemi rh --smooth-only --i ${DIR}/${outdir}/run01/carepi.fsaverage5.rh.nii --fwhm ${fwhmsurf} --o ${DIR}/${outdir}/run01/carepi.sm${fwhmsurf}.fsaverage5.rh.nii --mask ${DIR}/${outdir}/masks/brain.fsaverage5.rh.nii

	if [ $ToMNI305 -eq 1 ]
	then
	  # MNI305 2mm
	  mri_vol2vol --mov ${episc} --reg ${DIR}/${outdir}/run01/register.dof6.dat --tal --talres 2 --talxfm talairach.xfm --interp trilin --no-save-reg --o ${DIR}/${outdir}/run01/carepi.mni305.2mm.nii
	  
	  # smoothing
	  # smoothing
	  echo "Smoothing ${episc}"
	  fslmaths ${DIR}/${outdir}/run01/carepi.mni305.2mm.nii -kernel gauss ${Sigma} -fmean ${DIR}/${outdir}/run01/carepi_sm${fwhmvol}.mni305.2mm.nii.gz

	fi

	# MNI Normalization
	if [ $DoSPMNorm -eq 1 ]
	then
		
/usr/local/matlab/bin/matlab -nodisplay <<EOF

		% Load Matlab Path
		cd ${HOME}
		p = pathdef;
		addpath(p);

		spm_get_defaults;
		spm_jobman('initcfg');

		[tempa,tempb,tempc] = fileparts('${DIR}/${outdir}/run01/carepi_al.nii');

		clear matlabbatch 
		matlabbatch = {};
		if ${oldNorm}==0
		  matlabbatch{end+1}.spm.spatial.normalise.write.subj.def      = cellstr('${DIR}/${outdir}/y_T1_las.nii');
		  matlabbatch{end}.spm.spatial.normalise.write.subj.resample   = cellstr(spm_select('ExtFPList',tempa,['^',tempb,tempc],1:1e4));
		  matlabbatch{end}.spm.spatial.normalise.write.woptions.bb     = [-78 -112 -70; 78 76 85];
		  matlabbatch{end}.spm.spatial.normalise.write.woptions.vox    = [2 2 2];
		  matlabbatch{end}.spm.spatial.normalise.write.woptions.interp = 4;
		else
		  matlabbatch{end+1}.spm.tools.oldnorm.write.subj.matname    = cellstr('${DIR}/${outdir}/run01/mean_arepi_al_sn.mat');
		  matlabbatch{end}.spm.tools.oldnorm.write.subj.resample     = cellstr(spm_select('ExtFPList',tempa,['^',tempb,tempc],1:1e4));
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.preserve = 0;
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.bb       = [-78 -112 -70; 78 76 85];
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.vox      = [2 2 2];
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.interp   = 4;
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.wrap     = [0 0 0];
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.prefix   = 'w';
		end
		spm_jobman('run',matlabbatch);

EOF

		# smoothing
		echo "Smoothing ${DIR}/${outdir}/run01/wcarepi_al.nii"
		fslmaths ${DIR}/${outdir}/run01/wcarepi_al.nii -kernel gauss ${Sigma} -fmean ${DIR}/${outdir}/run01/wcarepi_sm${fwhmvol}_al.nii.gz

	fi
	
	if [ $DoANTSNorm -eq 1 ]
	then

	    TEMPLATE2=${FSLDIR}/data/standard/MNI152_T1_2mm.nii.gz

	    FMRI_ApplyAntsWarp.sh -epi ${DIR}/${outdir}/run01/carepi_al.nii -temp ${TEMPLATE2} -pref ${DIR}/${outdir}/norm_mni152 -o MNI152_2mm
	    
	    # smoothing
	    echo "Smoothing ${DIR}/${outdir}/run01/carepi_al_MNI152_2mm.nii.gz"
	    fslmaths ${DIR}/${outdir}/run01/carepi_al_MNI152_2mm.nii.gz -kernel gauss ${Sigma} -fmean ${DIR}/${outdir}/run01/carepi_sm${fwhmvol}_al_MNI152_2mm.nii.gz

	fi

fi

# -------------------------------------------------------------------------------------------
#  STEP 2: With scrubbing

if [ $DoCompCor -eq 1 ] && [ ! -f ${DIR}/${outdir}/run01/carepi_sc_sm${fwhmvol}_al_MNI152_2mm.nii.gz ]
then

	cp ${DIR}/${outdir}/run01/arepi.nii ${DIR}/${outdir}/run01/arepi_sc.nii
	
/usr/local/matlab/bin/matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);

        files_in  = '${DIR}/${outdir}/run01/arepi_sc.nii';
	[p,n,e]   = fileparts(files_in);
	outfolder = '${DIR}/${outdir}';

        files_out.dc_high       = fullfile(outfolder,'run01',[n '_dc_high.mat']); 
        files_out.dc_low        = fullfile(outfolder,'run01',[n '_dc_low.mat']);
        files_out.filtered_data = 'gb_niak_omitted';
        files_out.var_high      = 'gb_niak_omitted';
        files_out.var_low       = 'gb_niak_omitted';
        files_out.beta_high     = 'gb_niak_omitted';
        files_out.beta_low      = 'gb_niak_omitted';

        opt = struct('folder_out',[outfolder '/run01/'],'flag_test',0,'flag_mean',1,'flag_verbose',1,'tr',${TR},'hp',0.01,'lp',Inf);
        niak_brick_time_filter(files_in,files_out,opt);
        clear files_in files_out opt;

        files_in.fmri         = '${DIR}/${outdir}/run01/arepi_sc.nii';
        files_in.dc_low       = fullfile(outfolder,'run01',[n '_dc_low.mat']);
        files_in.dc_high      = fullfile(outfolder,'run01',[n '_dc_high.mat']); 
        files_in.custom_param = 'gb_niak_omitted';
        files_in.motion_param = fullfile(outfolder,'run01','mcprextreg');
        files_in.mask_brain   = fullfile(outfolder,'masks','brain.nii');
        files_in.mask_vent    = fullfile(outfolder,'run01','rvent.nii');
        files_in.mask_wm      = fullfile(outfolder,'run01','rwm.nii');

        files_out.scrubbing       = 'gb_niak_omitted';
        files_out.compcor_mask    = fullfile(outfolder,'run01',['compcor_mask_' n '.mat']);
        files_out.confounds       = fullfile(outfolder,'run01',['confounds_gs_' n '_cor' '.mat']);
        files_out.filtered_data   = fullfile(outfolder,'run01',['c' n e]);
        files_out.qc_compcor      = fullfile(outfolder,'run01',[n '_qc_compcor' e]);
        files_out.qc_slow_drift   = fullfile(outfolder,'run01',[n '_qc_slow_drift' e]);
        files_out.qc_high         = 'gb_niak_omitted';
        files_out.qc_wm           = fullfile(outfolder,'run01',[n '_qc_wm' e]);
        files_out.qc_vent         = fullfile(outfolder,'run01',[n '_qc_vent' e]);
        files_out.qc_motion       = fullfile(outfolder,'run01',[n '_qc_motion' e]);
        files_out.qc_custom_param = 'gb_niak_omitted';
        files_out.qc_gse          = fullfile(outfolder,'run01',[n '_qc_gse' e]);
                     
	opt = struct('flag_compcor',0,'compcor',struct(),'nb_vol_min',40,'flag_scrubbing',1,'thre_fd',0.8,'flag_slow',1,...
                         'flag_high',0,'folder_out',[outfolder '/run01/'],'flag_verbose',1,'flag_motion_params',1,'flag_wm',1,...
                         'flag_vent',1,'flag_gsc',0,'flag_pca_motion',1,'flag_test',0,'pct_var_explained',0.95);

        FMRI_RegressConfoundsByNiak(files_in,files_out,opt);

        clear files_in files_out opt;

EOF

	episc=${DIR}/${outdir}/run01/carepi_sc.nii
	mri_vol2vol --mov ${DIR}/${outdir}/run01/carepi_sc.nii --targ ${DIR}/mri/orig.mgz --o ${DIR}/${outdir}/run01/carepi_sc_al.nii --reg ${DIR}/${outdir}/run01/register.dof6.dat --no-resample --no-save-reg
	
	# smoothing
	echo "Smoothing ${episc}"
	fslmaths ${episc} -kernel gauss ${Sigma} -fmean ${DIR}/${outdir}/run01/carepi_sc_sm${fwhmvol}.nii.gz
	mri_vol2vol --mov ${DIR}/${outdir}/run01/carepi_sc.nii --targ ${DIR}/mri/orig.mgz --o ${DIR}/${outdir}/run01/carepi_sc_al.nii --reg ${DIR}/${outdir}/run01/register.dof6.dat --no-resample --no-save-reg
	echo "Smoothing ${DIR}/${outdir}/run01/carepi_sc_al.nii"
	fslmaths ${DIR}/${outdir}/run01/carepi_sc_al.nii -kernel gauss ${Sigma} -fmean ${DIR}/${outdir}/run01/carepi_sc_sm${fwhmvol}_al.nii.gz

	# native surface
 
	# lh
	mri_vol2surf --mov ${episc} --reg ${DIR}/${outdir}/run01/register.dof6.dat --trgsubject ${SUBJ} --interp trilin --projfrac 0.5 --hemi lh --o ${DIR}/${outdir}/run01/carepi_sc.lh.nii --noreshape --cortex --surfreg sphere.reg
	mris_fwhm --s ${SUBJ} --hemi lh --smooth-only --i ${DIR}/${outdir}/run01/carepi_sc.lh.nii --fwhm ${fwhmsurf} --o ${DIR}/${outdir}/run01/carepi_sc.sm${fwhmsurf}.lh.nii --mask ${DIR}/${outdir}/masks/brain.lh.nii

	# rh
	mri_vol2surf --mov ${episc} --reg ${DIR}/${outdir}/run01/register.dof6.dat --trgsubject ${SUBJ} --interp trilin --projfrac 0.5 --hemi rh --o ${DIR}/${outdir}/run01/carepi_sc.rh.nii --noreshape --cortex --surfreg sphere.reg
	mris_fwhm --s ${SUBJ} --hemi rh --smooth-only --i ${DIR}/${outdir}/run01/carepi_sc.rh.nii --fwhm ${fwhmsurf} --o ${DIR}/${outdir}/run01/carepi_sc.sm${fwhmsurf}.rh.nii --mask ${DIR}/${outdir}/masks/brain.rh.nii

	# fsaverage surface

	# lh
	mri_vol2surf --mov ${episc} --reg ${DIR}/${outdir}/run01/register.dof6.dat --trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi lh --o ${DIR}/${outdir}/run01/carepi_sc.fsaverage.lh.nii --noreshape --cortex --surfreg sphere.reg
	mris_fwhm --s fsaverage --hemi lh --smooth-only --i ${DIR}/${outdir}/run01/carepi_sc.fsaverage.lh.nii --fwhm ${fwhmsurf} --o ${DIR}/${outdir}/run01/carepi_sc.sm${fwhmsurf}.fsaverage.lh.nii --mask ${DIR}/${outdir}/masks/brain.fsaverage.lh.nii

	# rh
	mri_vol2surf --mov ${episc} --reg ${DIR}/${outdir}/run01/register.dof6.dat --trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi rh --o ${DIR}/${outdir}/run01/carepi_sc.fsaverage.rh.nii --noreshape --cortex --surfreg sphere.reg
	mris_fwhm --s fsaverage --hemi rh --smooth-only --i ${DIR}/${outdir}/run01/carepi_sc.fsaverage.rh.nii --fwhm ${fwhmsurf} --o ${DIR}/${outdir}/run01/carepi_sc.sm${fwhmsurf}.fsaverage.rh.nii --mask ${DIR}/${outdir}/masks/brain.fsaverage.rh.nii

	# fsaverage5 surface

	# lh
	mri_vol2surf --mov ${episc} --reg ${DIR}/${outdir}/run01/register.dof6.dat --trgsubject fsaverage5 --interp trilin --projfrac 0.5 --hemi lh --o ${DIR}/${outdir}/run01/carepi_sc.fsaverage5.lh.nii --noreshape --cortex --surfreg sphere.reg
	mris_fwhm --s fsaverage5 --hemi lh --smooth-only --i ${DIR}/${outdir}/run01/carepi_sc.fsaverage5.lh.nii --fwhm ${fwhmsurf} --o ${DIR}/${outdir}/run01/carepi_sc.sm${fwhmsurf}.fsaverage5.lh.nii --mask ${DIR}/${outdir}/masks/brain.fsaverage5.lh.nii

	# rh
	mri_vol2surf --mov ${episc} --reg ${DIR}/${outdir}/run01/register.dof6.dat --trgsubject fsaverage5 --interp trilin --projfrac 0.5 --hemi rh --o ${DIR}/${outdir}/run01/carepi_sc.fsaverage5.rh.nii --noreshape --cortex --surfreg sphere.reg
	mris_fwhm --s fsaverage5 --hemi rh --smooth-only --i ${DIR}/${outdir}/run01/carepi_sc.fsaverage5.rh.nii --fwhm ${fwhmsurf} --o ${DIR}/${outdir}/run01/carepi_sc.sm${fwhmsurf}.fsaverage5.rh.nii --mask ${DIR}/${outdir}/masks/brain.fsaverage5.rh.nii

	if [ $ToMNI305 -eq 1 ]
	then
	  # MNI305 2mm
	  mri_vol2vol --mov ${episc} --reg ${DIR}/${outdir}/run01/register.dof6.dat --tal --talres 2 --talxfm talairach.xfm --interp trilin --no-save-reg --o ${DIR}/${outdir}/run01/carepi_sc.mni305.2mm.nii
	  
	  # smoothing
	  # smoothing
	  echo "Smoothing ${episc}"
	  fslmaths ${DIR}/${outdir}/run01/carepi_sc.mni305.2mm.nii -kernel gauss ${Sigma} -fmean ${DIR}/${outdir}/run01/carepi_sc_sm${fwhmvol}.mni305.2mm.nii.gz

	fi

	# MNI Normalization
	if [ $DoSPMNorm -eq 1 ]
	then
		
/usr/local/matlab/bin/matlab -nodisplay <<EOF

		% Load Matlab Path
		cd ${HOME}
		p = pathdef;
		addpath(p);

		spm_get_defaults;
		spm_jobman('initcfg');

		[tempa,tempb,tempc] = fileparts('${DIR}/${outdir}/run01/carepi_sc_al.nii');

		clear matlabbatch 
		matlabbatch = {};
		if ${oldNorm}==0
		  matlabbatch{end+1}.spm.spatial.normalise.write.subj.def      = cellstr('${DIR}/${outdir}/y_T1_las.nii');
		  matlabbatch{end}.spm.spatial.normalise.write.subj.resample   = cellstr(spm_select('ExtFPList',tempa,['^',tempb,tempc],1:1e4));
		  matlabbatch{end}.spm.spatial.normalise.write.woptions.bb     = [-78 -112 -70; 78 76 85];
		  matlabbatch{end}.spm.spatial.normalise.write.woptions.vox    = [2 2 2];
		  matlabbatch{end}.spm.spatial.normalise.write.woptions.interp = 4;
		else
		  matlabbatch{end+1}.spm.tools.oldnorm.write.subj.matname    = cellstr('${DIR}/${outdir}/run01/mean_arepi_al_sn.mat');
		  matlabbatch{end}.spm.tools.oldnorm.write.subj.resample     = cellstr(spm_select('ExtFPList',tempa,['^',tempb,tempc],1:1e4));
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.preserve = 0;
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.bb       = [-78 -112 -70; 78 76 85];
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.vox      = [2 2 2];
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.interp   = 4;
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.wrap     = [0 0 0];
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.prefix   = 'w';
		end
		spm_jobman('run',matlabbatch);

EOF

		# smoothing
		echo "Smoothing ${DIR}/${outdir}/run01/wcarepi_sc_al.nii"
		fslmaths ${DIR}/${outdir}/run01/wcarepi_sc_al.nii -kernel gauss ${Sigma} -fmean ${DIR}/${outdir}/run01/wcarepi_sc_sm${fwhmvol}_al.nii.gz

	fi
	
	if [ $DoANTSNorm -eq 1 ]
	then

	    TEMPLATE2=${FSLDIR}/data/standard/MNI152_T1_2mm.nii.gz

	    FMRI_ApplyAntsWarp.sh -epi ${DIR}/${outdir}/run01/carepi_sc_al.nii -temp ${TEMPLATE2} -pref ${DIR}/${outdir}/norm_mni152 -o MNI152_2mm
	    
	    # smoothing
	    echo "Smoothing ${DIR}/${outdir}/run01/carepi_sc_al_MNI152_2mm.nii.gz"
	    fslmaths ${DIR}/${outdir}/run01/carepi_sc_al_MNI152_2mm.nii.gz -kernel gauss ${Sigma} -fmean ${DIR}/${outdir}/run01/carepi_sc_sm${fwhmvol}_al_MNI152_2mm.nii.gz

	fi

fi



# ========================================================================================================================================
#                                                        Bandpass Filtering
# ========================================================================================================================================

# -------------------------------------------------------------------------------------------
#  STEP 1: Without scrubbing

if [ $DoFiltering -eq 1 ] && [ ! -f ${DIR}/${outdir}/run01/fcarepi_sm${fwhmvol}_al_MNI152_2mm.nii.gz ]
then

/usr/local/matlab/bin/matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);

	files_in = '${DIR}/${outdir}/run01/carepi.nii';
	[p,n,e]  = fileparts(files_in);
	outdir   = '${DIR}/${outdir}/run01';

        files_out.dc_high       = 'gb_niak_omitted'; 
        files_out.dc_low        = 'gb_niak_omitted';
        files_out.filtered_data = fullfile(outdir,['f' n e]);
        files_out.var_high      = 'gb_niak_omitted';
        files_out.var_low       = 'gb_niak_omitted';
        files_out.beta_high     = 'gb_niak_omitted';
        files_out.beta_low      = 'gb_niak_omitted';

        opt = struct('folder_out',[outdir '/'],'flag_test',0,'flag_mean',1,'flag_verbose',1,'tr',${TR},'hp',${highpass},'lp',${lowpass});
        niak_brick_time_filter(files_in,files_out,opt);
        clear files_in files_out opt;

EOF

	episc=${DIR}/${outdir}/run01/fcarepi.nii

	echo "Smoothing ${episc}"
	fslmaths ${episc} -kernel gauss ${Sigma} -fmean ${DIR}/${outdir}/run01/fcarepi_sm${fwhmvol}.nii.gz
	mri_vol2vol --mov ${DIR}/${outdir}/run01/fcarepi.nii --targ ${DIR}/mri/orig.mgz --o ${DIR}/${outdir}/run01/fcarepi_al.nii --reg ${DIR}/${outdir}/run01/register.dof6.dat --no-resample --no-save-reg
	echo "Smoothing ${DIR}/${outdir}/run01/fcarepi_al.nii"
	fslmaths ${DIR}/${outdir}/run01/fcarepi_al.nii -kernel gauss ${Sigma} -fmean ${DIR}/${outdir}/run01/fcarepi_sm${fwhmvol}_al.nii.gz
	
	# native surface
 
	# lh
	mri_vol2surf --mov ${episc} --reg ${DIR}/${outdir}/run01/register.dof6.dat --trgsubject ${SUBJ} --interp trilin --projfrac 0.5 --hemi lh --o ${DIR}/${outdir}/run01/fcarepi.lh.nii --noreshape --cortex --surfreg sphere.reg
	mris_fwhm --s ${SUBJ} --hemi lh --smooth-only --i ${DIR}/${outdir}/run01/fcarepi.lh.nii --fwhm ${fwhmsurf} --o ${DIR}/${outdir}/run01/fcarepi.sm${fwhmsurf}.lh.nii --mask ${DIR}/${outdir}/masks/brain.lh.nii

	# rh
	mri_vol2surf --mov ${episc} --reg ${DIR}/${outdir}/run01/register.dof6.dat --trgsubject ${SUBJ} --interp trilin --projfrac 0.5 --hemi rh --o ${DIR}/${outdir}/run01/fcarepi.rh.nii --noreshape --cortex --surfreg sphere.reg
	mris_fwhm --s ${SUBJ} --hemi rh --smooth-only --i ${DIR}/${outdir}/run01/fcarepi.rh.nii --fwhm ${fwhmsurf} --o ${DIR}/${outdir}/run01/fcarepi.sm${fwhmsurf}.rh.nii --mask ${DIR}/${outdir}/masks/brain.rh.nii

	# fsaverage surface

	# lh
	mri_vol2surf --mov ${episc} --reg ${DIR}/${outdir}/run01/register.dof6.dat --trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi lh --o ${DIR}/${outdir}/run01/fcarepi.fsaverage.lh.nii --noreshape --cortex --surfreg sphere.reg
	mris_fwhm --s fsaverage --hemi lh --smooth-only --i ${DIR}/${outdir}/run01/fcarepi.fsaverage.lh.nii --fwhm ${fwhmsurf} --o ${DIR}/${outdir}/run01/fcarepi.sm${fwhmsurf}.fsaverage.lh.nii --mask ${DIR}/${outdir}/masks/brain.fsaverage.lh.nii

	# rh
	mri_vol2surf --mov ${episc} --reg ${DIR}/${outdir}/run01/register.dof6.dat --trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi rh --o ${DIR}/${outdir}/run01/fcarepi.fsaverage.rh.nii --noreshape --cortex --surfreg sphere.reg
	mris_fwhm --s fsaverage --hemi rh --smooth-only --i ${DIR}/${outdir}/run01/fcarepi.fsaverage.rh.nii --fwhm ${fwhmsurf} --o ${DIR}/${outdir}/run01/fcarepi.sm${fwhmsurf}.fsaverage.rh.nii --mask ${DIR}/${outdir}/masks/brain.fsaverage.rh.nii

	# fsaverage 5 surface
	
	# lh
	mri_vol2surf --mov ${episc} --reg ${DIR}/${outdir}/run01/register.dof6.dat --trgsubject fsaverage5 --interp trilin --projfrac 0.5 --hemi lh --o ${DIR}/${outdir}/run01/fcarepi.fsaverage5.lh.nii --noreshape --cortex --surfreg sphere.reg
	mris_fwhm --s fsaverage5 --hemi lh --smooth-only --i ${DIR}/${outdir}/run01/fcarepi.fsaverage5.lh.nii --fwhm ${fwhmsurf} --o ${DIR}/${outdir}/run01/fcarepi.sm${fwhmsurf}.fsaverage5.lh.nii --mask ${DIR}/${outdir}/masks/brain.fsaverage5.lh.nii

	# rh
	mri_vol2surf --mov ${episc} --reg ${DIR}/${outdir}/run01/register.dof6.dat --trgsubject fsaverage5 --interp trilin --projfrac 0.5 --hemi rh --o ${DIR}/${outdir}/run01/fcarepi.fsaverage5.rh.nii --noreshape --cortex --surfreg sphere.reg
	mris_fwhm --s fsaverage5 --hemi rh --smooth-only --i ${DIR}/${outdir}/run01/fcarepi.fsaverage5.rh.nii --fwhm ${fwhmsurf} --o ${DIR}/${outdir}/run01/fcarepi.sm${fwhmsurf}.fsaverage5.rh.nii --mask ${DIR}/${outdir}/masks/brain.fsaverage5.rh.nii

	if [ $ToMNI305 -eq 1 ]
	then
	  # MNI305 2mm
	  mri_vol2vol --mov ${episc} --reg ${DIR}/${outdir}/run01/register.dof6.dat --tal --talres 2 --talxfm talairach.xfm --interp trilin --no-save-reg --o ${DIR}/${outdir}/run01/fcarepi.mni305.2mm.nii	
	  
	  # smoothing
	  echo "Smoothing ${episc}"
	  fslmaths ${DIR}/${outdir}/run01/fcarepi.mni305.2mm.nii -kernel gauss ${Sigma} -fmean ${DIR}/${outdir}/run01/fcarepi_sm${fwhmvol}.mni305.2mm.nii.gz
	  
	fi
	
	# MNI Normalization
	if [ $DoSPMNorm -eq 1 ]
	then

/usr/local/matlab/bin/matlab -nodisplay <<EOF

		% Load Matlab Path
		cd ${HOME}
		p = pathdef;
		addpath(p);
		
		spm_get_defaults;
		spm_jobman('initcfg');

		[tempa,tempb,tempc] = fileparts('${DIR}/${outdir}/run01/fcarepi_al.nii');

		clear matlabbatch 
		matlabbatch = {};
		if ${oldNorm}==0
		  matlabbatch{end+1}.spm.spatial.normalise.write.subj.def      = cellstr('${DIR}/${outdir}/y_T1_las.nii');
		  matlabbatch{end}.spm.spatial.normalise.write.subj.resample   = cellstr(spm_select('ExtFPList',tempa,['^',tempb,tempc],1:1e4));
		  matlabbatch{end}.spm.spatial.normalise.write.woptions.bb     = [-78 -112 -70; 78 76 85];
		  matlabbatch{end}.spm.spatial.normalise.write.woptions.vox    = [2 2 2];
		  matlabbatch{end}.spm.spatial.normalise.write.woptions.interp = 4;
		else
		  matlabbatch{end+1}.spm.tools.oldnorm.write.subj.matname    = cellstr('${DIR}/${outdir}/run01/mean_arepi_al_sn.mat');
		  matlabbatch{end}.spm.tools.oldnorm.write.subj.resample     = cellstr(spm_select('ExtFPList',tempa,['^',tempb,tempc],1:1e4));
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.preserve = 0;
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.bb       = [-78 -112 -70; 78 76 85];
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.vox      = [2 2 2];
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.interp   = 4;
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.wrap     = [0 0 0];
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.prefix   = 'w';
		end
		spm_jobman('run',matlabbatch);

EOF
		# smoothing
		echo "Smoothing ${DIR}/${outdir}/run01/wfcarepi_al.nii"
		fslmaths ${DIR}/${outdir}/run01/wfcarepi_al.nii -kernel gauss ${Sigma} -fmean ${DIR}/${outdir}/run01/wfcarepi_sm${fwhmvol}_al.nii.gz
	fi
	
	if [ $DoANTSNorm -eq 1 ]
	then

	    TEMPLATE2=${FSLDIR}/data/standard/MNI152_T1_2mm.nii.gz

	    FMRI_ApplyAntsWarp.sh -epi ${DIR}/${outdir}/run01/fcarepi_al.nii -temp ${TEMPLATE2} -pref ${DIR}/${outdir}/norm_mni152 -o MNI152_2mm
  
	    # smoothing
	    echo "Smoothing ${DIR}/${outdir}/run01/fcarepi_al_MNI152_2mm.nii.gz"
	    fslmaths ${DIR}/${outdir}/run01/fcarepi_al_MNI152_2mm.nii.gz -kernel gauss ${Sigma} -fmean ${DIR}/${outdir}/run01/fcarepi_sm${fwhmvol}_al_MNI152_2mm.nii.gz
	fi

fi


# -------------------------------------------------------------------------------------------
#  STEP 2: With scrubbing

if [ $DoFiltering -eq 1 ] && [ ! -f ${DIR}/${outdir}/run01/fcarepi_sc_sm${fwhmvol}_al_MNI152_2mm.nii.gz ]
then

/usr/local/matlab/bin/matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);

	files_in = '${DIR}/${outdir}/run01/carepi_sc.nii';
	[p,n,e]  = fileparts(files_in);
	outdir   = '${DIR}/${outdir}/run01';

        files_out.dc_high       = 'gb_niak_omitted'; 
        files_out.dc_low        = 'gb_niak_omitted';
        files_out.filtered_data = fullfile(outdir,['f' n e]);
        files_out.var_high      = 'gb_niak_omitted';
        files_out.var_low       = 'gb_niak_omitted';
        files_out.beta_high     = 'gb_niak_omitted';
        files_out.beta_low      = 'gb_niak_omitted';

        opt = struct('folder_out',[outdir '/'],'flag_test',0,'flag_mean',1,'flag_verbose',1,'tr',${TR},'hp',${highpass},'lp',${lowpass});
        niak_brick_time_filter(files_in,files_out,opt);
        clear files_in files_out opt;

EOF

	episc=${DIR}/${outdir}/run01/fcarepi_sc.nii

	echo "Smoothing ${episc}"
	fslmaths ${episc} -kernel gauss ${Sigma} -fmean ${DIR}/${outdir}/run01/fcarepi_sc_sm${fwhmvol}.nii.gz
	mri_vol2vol --mov ${DIR}/${outdir}/run01/fcarepi_sc.nii --targ ${DIR}/mri/orig.mgz --o ${DIR}/${outdir}/run01/fcarepi_sc_al.nii --reg ${DIR}/${outdir}/run01/register.dof6.dat --no-resample --no-save-reg
	echo "Smoothing ${DIR}/${outdir}/run01/fcarepi_sc_al.nii"
	fslmaths ${DIR}/${outdir}/run01/fcarepi_sc_al.nii -kernel gauss ${Sigma} -fmean ${DIR}/${outdir}/run01/fcarepi_sc_sm${fwhmvol}_al.nii.gz
	
	# native surface
 
	# lh
	mri_vol2surf --mov ${episc} --reg ${DIR}/${outdir}/run01/register.dof6.dat --trgsubject ${SUBJ} --interp trilin --projfrac 0.5 --hemi lh --o ${DIR}/${outdir}/run01/fcarepi_sc.lh.nii --noreshape --cortex --surfreg sphere.reg
	mris_fwhm --s ${SUBJ} --hemi lh --smooth-only --i ${DIR}/${outdir}/run01/fcarepi_sc.lh.nii --fwhm ${fwhmsurf} --o ${DIR}/${outdir}/run01/fcarepi_sc.sm${fwhmsurf}.lh.nii --mask ${DIR}/${outdir}/masks/brain.lh.nii

	# rh
	mri_vol2surf --mov ${episc} --reg ${DIR}/${outdir}/run01/register.dof6.dat --trgsubject ${SUBJ} --interp trilin --projfrac 0.5 --hemi rh --o ${DIR}/${outdir}/run01/fcarepi_sc.rh.nii --noreshape --cortex --surfreg sphere.reg
	mris_fwhm --s ${SUBJ} --hemi rh --smooth-only --i ${DIR}/${outdir}/run01/fcarepi_sc.rh.nii --fwhm ${fwhmsurf} --o ${DIR}/${outdir}/run01/fcarepi_sc.sm${fwhmsurf}.rh.nii --mask ${DIR}/${outdir}/masks/brain.rh.nii

	# fsaverage surface

	# lh
	mri_vol2surf --mov ${episc} --reg ${DIR}/${outdir}/run01/register.dof6.dat --trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi lh --o ${DIR}/${outdir}/run01/fcarepi_sc.fsaverage.lh.nii --noreshape --cortex --surfreg sphere.reg
	mris_fwhm --s fsaverage --hemi lh --smooth-only --i ${DIR}/${outdir}/run01/fcarepi_sc.fsaverage.lh.nii --fwhm ${fwhmsurf} --o ${DIR}/${outdir}/run01/fcarepi_sc.sm${fwhmsurf}.fsaverage.lh.nii --mask ${DIR}/${outdir}/masks/brain.fsaverage.lh.nii

	# rh
	mri_vol2surf --mov ${episc} --reg ${DIR}/${outdir}/run01/register.dof6.dat --trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi rh --o ${DIR}/${outdir}/run01/fcarepi_sc.fsaverage.rh.nii --noreshape --cortex --surfreg sphere.reg
	mris_fwhm --s fsaverage --hemi rh --smooth-only --i ${DIR}/${outdir}/run01/fcarepi_sc.fsaverage.rh.nii --fwhm ${fwhmsurf} --o ${DIR}/${outdir}/run01/fcarepi_sc.sm${fwhmsurf}.fsaverage.rh.nii --mask ${DIR}/${outdir}/masks/brain.fsaverage.rh.nii

	# fsaverage 5 surface
	
	# lh
	mri_vol2surf --mov ${episc} --reg ${DIR}/${outdir}/run01/register.dof6.dat --trgsubject fsaverage5 --interp trilin --projfrac 0.5 --hemi lh --o ${DIR}/${outdir}/run01/fcarepi_sc.fsaverage5.lh.nii --noreshape --cortex --surfreg sphere.reg
	mris_fwhm --s fsaverage5 --hemi lh --smooth-only --i ${DIR}/${outdir}/run01/fcarepi_sc.fsaverage5.lh.nii --fwhm ${fwhmsurf} --o ${DIR}/${outdir}/run01/fcarepi_sc.sm${fwhmsurf}.fsaverage5.lh.nii --mask ${DIR}/${outdir}/masks/brain.fsaverage5.lh.nii

	# rh
	mri_vol2surf --mov ${episc} --reg ${DIR}/${outdir}/run01/register.dof6.dat --trgsubject fsaverage5 --interp trilin --projfrac 0.5 --hemi rh --o ${DIR}/${outdir}/run01/fcarepi_sc.fsaverage5.rh.nii --noreshape --cortex --surfreg sphere.reg
	mris_fwhm --s fsaverage5 --hemi rh --smooth-only --i ${DIR}/${outdir}/run01/fcarepi_sc.fsaverage5.rh.nii --fwhm ${fwhmsurf} --o ${DIR}/${outdir}/run01/fcarepi_sc.sm${fwhmsurf}.fsaverage5.rh.nii --mask ${DIR}/${outdir}/masks/brain.fsaverage5.rh.nii

	if [ $ToMNI305 -eq 1 ]
	then
	  # MNI305 2mm
	  mri_vol2vol --mov ${episc} --reg ${DIR}/${outdir}/run01/register.dof6.dat --tal --talres 2 --talxfm talairach.xfm --interp trilin --no-save-reg --o ${DIR}/${outdir}/run01/fcarepi_sc.mni305.2mm.nii	
	  
	  # smoothing
	  echo "Smoothing ${episc}"
	  fslmaths ${DIR}/${outdir}/run01/fcarepi_sc.mni305.2mm.nii -kernel gauss ${Sigma} -fmean ${DIR}/${outdir}/run01/fcarepi_sc_sm${fwhmvol}.mni305.2mm.nii.gz
	  
	fi
	
	# MNI Normalization
	if [ $DoSPMNorm -eq 1 ]
	then

/usr/local/matlab/bin/matlab -nodisplay <<EOF

		% Load Matlab Path
		cd ${HOME}
		p = pathdef;
		addpath(p);
		
		spm_get_defaults;
		spm_jobman('initcfg');

		[tempa,tempb,tempc] = fileparts('${DIR}/${outdir}/run01/fcarepi_sc_al.nii');

		clear matlabbatch 
		matlabbatch = {};
		if ${oldNorm}==0
		  matlabbatch{end+1}.spm.spatial.normalise.write.subj.def      = cellstr('${DIR}/${outdir}/y_T1_las.nii');
		  matlabbatch{end}.spm.spatial.normalise.write.subj.resample   = cellstr(spm_select('ExtFPList',tempa,['^',tempb,tempc],1:1e4));
		  matlabbatch{end}.spm.spatial.normalise.write.woptions.bb     = [-78 -112 -70; 78 76 85];
		  matlabbatch{end}.spm.spatial.normalise.write.woptions.vox    = [2 2 2];
		  matlabbatch{end}.spm.spatial.normalise.write.woptions.interp = 4;
		else
		  matlabbatch{end+1}.spm.tools.oldnorm.write.subj.matname    = cellstr('${DIR}/${outdir}/run01/mean_arepi_al_sn.mat');
		  matlabbatch{end}.spm.tools.oldnorm.write.subj.resample     = cellstr(spm_select('ExtFPList',tempa,['^',tempb,tempc],1:1e4));
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.preserve = 0;
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.bb       = [-78 -112 -70; 78 76 85];
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.vox      = [2 2 2];
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.interp   = 4;
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.wrap     = [0 0 0];
		  matlabbatch{end}.spm.tools.oldnorm.write.roptions.prefix   = 'w';
		end
		spm_jobman('run',matlabbatch);

EOF
		# smoothing
		echo "Smoothing ${DIR}/${outdir}/run01/wfcarepi_sc_al.nii"
		fslmaths ${DIR}/${outdir}/run01/wfcarepi_sc_al.nii -kernel gauss ${Sigma} -fmean ${DIR}/${outdir}/run01/wfcarepi_sc_sm${fwhmvol}_al.nii.gz
	fi
	
	if [ $DoANTSNorm -eq 1 ]
	then

	    TEMPLATE2=${FSLDIR}/data/standard/MNI152_T1_2mm.nii.gz

	    FMRI_ApplyAntsWarp.sh -epi ${DIR}/${outdir}/run01/fcarepi_sc_al.nii -temp ${TEMPLATE2} -pref ${DIR}/${outdir}/norm_mni152 -o MNI152_2mm
  
	    # smoothing
	    echo "Smoothing ${DIR}/${outdir}/run01/fcarepi_sc_al_MNI152_2mm.nii.gz"
	    fslmaths ${DIR}/${outdir}/run01/fcarepi_sc_al_MNI152_2mm.nii.gz -kernel gauss ${Sigma} -fmean ${DIR}/${outdir}/run01/fcarepi_sc_sm${fwhmvol}_al_MNI152_2mm.nii.gz
	fi

fi



# ========================================================================================================================================
#                                                        AAL Parcellation
# ========================================================================================================================================

if [ $DoAAL -eq 1 ]
then

/usr/local/matlab/bin/matlab -nodisplay <<EOF

	% Load Matlab Path
	p = pathdef;
	addpath(p);
		
	pathOI  = fileparts(which('ned_hier_clustering.m'));
	pathCh2 = [pathOI filesep '..' filesep 'aal'];

	if(isunix)
	    unix(['cp ', pathCh2 filesep 'struct.* ', '${DIR}/${outdir}/']);
	    unix(['cp ', pathCh2 filesep 'aal.* ', '${DIR}/${outdir}/']);
	elseif(ispc)
	    copyfile([pathCh2,filesep,'struct.*'],'${DIR}/${outdir}/')
	    copyfile([pathCh2,filesep,'aal.*'],'${DIR}/${outdir}/')
	end
	
	hdr_epi = spm_vol('${DIR}/${outdir}/run01/wmean_arepi_al.nii');
	hdr_ch2 = spm_vol('${DIR}/${outdir}/struct.img');
	PP      = strvcat(hdr_epi.fname,hdr_ch2.fname);
	flag_reslice.interp = 1;
	flag_reslice.wrap   = [0 0 0];
	flag_reslice.mask   = 0;
	flag_reslice.mean   = 0;
	flag_reslice.which  = 1;
	warning('off')
	spm_reslice(PP,flag_reslice);
	clear hdr_ch2;
	
	hdr_aal = spm_vol('${DIR}/${outdir}/aal.img');
	PP      = strvcat(hdr_epi.fname,hdr_aal.fname);
	flag_reslice.interp = 0;
	flag_reslice.wrap   = [0 0 0];
	flag_reslice.mask   = 0;
	flag_reslice.mean   = 0;
	flag_reslice.which  = 1;
	warning('off')
	spm_reslice(PP,flag_reslice);
	clear hdr_aal hdr_epi;
	
	spm_get_defaults;
	spm_jobman('initcfg');
	
	clear matlabbatch 
	matlabbatch = {};
	if ${oldNorm}==0
	    matlabbatch{end+1}.spm.util.defs.comp{1}.inv.comp{1}.def   = {'${DIR}/${outdir}/y_T1_las.nii'};
	    matlabbatch{end}.spm.util.defs.comp{1}.inv.space           = {'${DIR}/${outdir}/run01/mean_arepi_al.nii'};
	    matlabbatch{end}.spm.util.defs.out{1}.pull.fnames          = {'${DIR}/${outdir}/raal.img'};
	    matlabbatch{end}.spm.util.defs.out{1}.pull.savedir.savesrc = 1;
	    matlabbatch{end}.spm.util.defs.out{1}.pull.interp          = 0;
	    matlabbatch{end}.spm.util.defs.out{1}.pull.mask            = 1;
	    matlabbatch{end}.spm.util.defs.out{1}.pull.fwhm            = [0 0 0];
	else
	    matlabbatch{end+1}.spm.util.defs.comp{1}.inv.comp{1}.sn2def.matname = cellstr('${DIR}/${outdir}/run01/mean_arepi_al_sn.mat');
	    matlabbatch{end}.spm.util.defs.comp{1}.inv.comp{1}.sn2def.vox       = [2 2 2];
	    matlabbatch{end}.spm.util.defs.comp{1}.inv.comp{1}.sn2def.bb        = [-78 -112 -70; 78 76 85];
	    matlabbatch{end}.spm.util.defs.comp{1}.inv.space                    = {'${DIR}/${outdir}/run01/mean_arepi_al.nii'};
	    matlabbatch{end}.spm.util.defs.out{1}.pull.fnames                   = {'${DIR}/${outdir}/raal.img'};
	    matlabbatch{end}.spm.util.defs.out{1}.pull.savedir.savesrc          = 1;
	    matlabbatch{end}.spm.util.defs.out{1}.pull.interp                   = 0;
	    matlabbatch{end}.spm.util.defs.out{1}.pull.mask                     = 1;
	    matlabbatch{end}.spm.util.defs.out{1}.pull.fwhm                     = [0 0 0];
	end
	spm_jobman('run',matlabbatch);
	
EOF

fi


# ========================================================================================================================================
#                                                       Craddock Parcellation
# ========================================================================================================================================

if [ $DoCraddock -eq 1 ]
then

	cp /home/global/atlases/craddock/*.nii.gz ${DIR}/${outdir}/
	gunzip -f ${DIR}/${outdir}/*.gz
	
/usr/local/matlab/bin/matlab -nodisplay <<EOF

	% Load Matlab Path
	p = pathdef;
	addpath(p);
	
	hdr_epi = spm_vol('${DIR}/${outdir}/run01/wmean_arepi_al.nii');
	hdr_ch2 = spm_vol('${DIR}/${outdir}/random_all.nii');
	PP      = strvcat(hdr_epi.fname,hdr_ch2.fname);
	flag_reslice.interp = 0;
	flag_reslice.wrap   = [0 0 0];
	flag_reslice.mask   = 0;
	flag_reslice.mean   = 0;
	flag_reslice.which  = 1;
	warning('off')
	spm_reslice(PP,flag_reslice);
	clear hdr_ch2;
	
	hdr_ch2 = spm_vol('${DIR}/${outdir}/scorr05_2level_all.nii');
	PP      = strvcat(hdr_epi.fname,hdr_ch2.fname);
	flag_reslice.interp = 0;
	flag_reslice.wrap   = [0 0 0];
	flag_reslice.mask   = 0;
	flag_reslice.mean   = 0;
	flag_reslice.which  = 1;
	warning('off')
	spm_reslice(PP,flag_reslice);
	clear hdr_ch2;
	
	hdr_ch2 = spm_vol('${DIR}/${outdir}/scorr05_mean_all.nii');
	PP      = strvcat(hdr_epi.fname,hdr_ch2.fname);
	flag_reslice.interp = 0;
	flag_reslice.wrap   = [0 0 0];
	flag_reslice.mask   = 0;
	flag_reslice.mean   = 0;
	flag_reslice.which  = 1;
	warning('off')
	spm_reslice(PP,flag_reslice);
	clear hdr_ch2;
	
	hdr_ch2 = spm_vol('${DIR}/${outdir}/tcorr05_2level_all.nii');
	PP      = strvcat(hdr_epi.fname,hdr_ch2.fname);
	flag_reslice.interp = 0;
	flag_reslice.wrap   = [0 0 0];
	flag_reslice.mask   = 0;
	flag_reslice.mean   = 0;
	flag_reslice.which  = 1;
	warning('off')
	spm_reslice(PP,flag_reslice);
	clear hdr_ch2;
	
	hdr_ch2 = spm_vol('${DIR}/${outdir}/tcorr05_mean_all.nii');
	PP      = strvcat(hdr_epi.fname,hdr_ch2.fname);
	flag_reslice.interp = 0;
	flag_reslice.wrap   = [0 0 0];
	flag_reslice.mask   = 0;
	flag_reslice.mean   = 0;
	flag_reslice.which  = 1;
	warning('off')
	spm_reslice(PP,flag_reslice);
	clear hdr_ch2 hdr_epi;
	
	
	spm_get_defaults;
	spm_jobman('initcfg');
	
	clear matlabbatch 
	matlabbatch = {};
	maps{1} = '${DIR}/${outdir}/rrandom_all.nii';
	maps{2} = '${DIR}/${outdir}/rscorr05_2level_all.nii';
	maps{3} = '${DIR}/${outdir}/rscorr05_mean_all.nii';
	maps{4} = '${DIR}/${outdir}/rtcorr05_2level_all.nii';
	maps{5} = '${DIR}/${outdir}/rtcorr05_mean_all.nii';
	if ${oldNorm}==0
	    matlabbatch{end+1}.spm.util.defs.comp{1}.inv.comp{1}.def   = {'${DIR}/${outdir}/y_T1_las.nii'};
	    matlabbatch{end}.spm.util.defs.comp{1}.inv.space           = {'${DIR}/${outdir}/run01/mean_arepi_al.nii'};
	    matlabbatch{end}.spm.util.defs.out{1}.pull.fnames          = maps;
	    matlabbatch{end}.spm.util.defs.out{1}.pull.savedir.savesrc = 1;
	    matlabbatch{end}.spm.util.defs.out{1}.pull.interp          = 0;
	    matlabbatch{end}.spm.util.defs.out{1}.pull.mask            = 1;
	    matlabbatch{end}.spm.util.defs.out{1}.pull.fwhm            = [0 0 0];
	else
	    matlabbatch{end+1}.spm.util.defs.comp{1}.inv.comp{1}.sn2def.matname = cellstr('${DIR}/${outdir}/run01/mean_arepi_al_sn.mat');
	    matlabbatch{end}.spm.util.defs.comp{1}.inv.comp{1}.sn2def.vox       = [2 2 2];
	    matlabbatch{end}.spm.util.defs.comp{1}.inv.comp{1}.sn2def.bb        = [-78 -112 -70; 78 76 85];
	    matlabbatch{end}.spm.util.defs.comp{1}.inv.space                    = {'${DIR}/${outdir}/run01/mean_arepi_al.nii'};
	    matlabbatch{end}.spm.util.defs.out{1}.pull.fnames                   = maps;
	    matlabbatch{end}.spm.util.defs.out{1}.pull.savedir.savesrc          = 1;
	    matlabbatch{end}.spm.util.defs.out{1}.pull.interp                   = 0;
	    matlabbatch{end}.spm.util.defs.out{1}.pull.mask                     = 1;
	    matlabbatch{end}.spm.util.defs.out{1}.pull.fwhm                     = [0 0 0];
	end
	spm_jobman('run',matlabbatch);
	
EOF

fi




# ========================================================================================================================================
#                                                      Striatum Parcellation
# ========================================================================================================================================

if [ $DoStriatum -eq 1 ]
then
	
	cd ${DIR}/${outdir}/run01

	cp /home/notorious/NAS/renaud/atlas/striatum_parcellation/Choi_JNeurophysiol12_MNI152/striatum_fsl_mni152_1mm.nii.gz ${DIR}/${outdir}/run01/
	cp /home/notorious/NAS/renaud/atlas/striatum_parcellation/Choi_JNeurophysiol12_MNI152/Choi2012_7Networks_MNI152_FreeSurferConformed1mm_TightMask.nii ${DIR}/${outdir}/run01/parc_striatum.nii

	mri_extract_label ${DIR}/${outdir}/run01/aparc.mni305.1mm.nii 51 12 50 11 26 58 ${DIR}/${outdir}/run01/striatum.mni305.1mm.nii
	mri_binarize --i ${DIR}/${outdir}/run01/striatum.mni305.1mm.nii --min 0.5 --binval 1 --o ${DIR}/${outdir}/run01/striatum.mni305.1mm.nii
	fslmaths ${DIR}/${outdir}/run01/orig.mni305.1mm.nii -mul ${DIR}/${outdir}/run01/striatum.mni305.1mm.nii ${DIR}/${outdir}/run01/striatum.mni305.1mm.nii

	ANTS 3 -m CC[striatum.mni305.1mm.nii.gz,striatum_fsl_mni152_1mm.nii.gz,1,4] -t Syn[0.25] -r Gauss[3,0] -o striatum_parc_al -i 50x40x30 --number-of-affine-iterations 1000x1000x500

	WarpImageMultiTransform 3 parc_striatum.nii striatum_parc_al.nii.gz striatum_parc_alWarp.nii.gz striatum_parc_alAffine.txt -R striatum.mni305.1mm.nii.gz --use-NN

	mri_vol2vol --mov ${DIR}/${outdir}/run01/fcarepi.nii --reg ${DIR}/${outdir}/run01/register.dof6.dat --tal --talres 1 --talxfm talairach.xfm --interp trilin --no-save-reg --o ${DIR}/${outdir}/run01/fcarepi.mni305.1mm.nii
	mri_vol2vol --mov ${DIR}/${outdir}/run01/fcarepi_sc.nii --reg ${DIR}/${outdir}/run01/register.dof6.dat --tal --talres 1 --talxfm talairach.xfm --interp trilin --no-save-reg --o ${DIR}/${outdir}/run01/fcarepi_sc.mni305.1mm.nii

	gunzip -f ${DIR}/${outdir}/run01/striatum_parc_al.nii.gz

	mri_extract_label .${DIR}/mri/aparc.a2009s+aseg.mgz 51 12 50 11 26 58 ${DIR}/${outdir}/run01/striatum.orig.nii
	mri_binarize --i ${DIR}/${outdir}/run01/striatum.orig.nii --min 0.5 --binval 1 --o ${DIR}/${outdir}/run01/striatum.orig.bin.nii
	mri_convert ${DIR}/mri/orig.mgz ${DIR}/${outdir}/run01/orig.ni
	fslmaths ${DIR}/${outdir}/run01/orig.nii -mul ${DIR}/${outdir}/run01/striatum.orig.bin.nii ${DIR}/${outdir}/run01/striatum.orig.grey.nii
	ANTS 3 -m CC[striatum.orig.grey.nii.gz,striatum_fsl_mni152_1mm.nii.gz,1,4] -t Syn[0.25] -r Gauss[3,0] -o striatum_mni152_alorig -i 50x40x30 --number-of-affine-iterations 1000x1000x500
	WarpImageMultiTransform 3 /home/notorious/NAS/renaud/atlas/striatum_parcellation/Choi_JNeurophysiol12_MNI152/Choi2012_7Networks_MNI152_FreeSurferConformed1mm_TightMask.nii striatum_mni152_alorig.nii.gz striatum_mni152_alorigWarp.nii.gz striatum_mni152_alorigAffine.txt -R orig.nii --use-NN
	mri_vol2vol --mov ${DIR}/${outdir}/run01/template.nii --targ ${DIR}/${outdir}/run01/striatum_mni152_alorig.nii.gz --o ${DIR}/${outdir}/run01/striatum_mni152_altemplate.nii --inv --reg ${DIR}/${outdir}/run01/register.dof6.dat --nearest --no-save-reg

fi


#
#Do Analysis
#
if [ $DoAnalysis -eq 1 ]
then
echo "\n\ndo the analysis ;-)\n\n" 
echo 
#	mkdir ${DIR}/${outdir}/
#	cp ${DIR}/${outdir}/run01/mean_arepi_al.nii.gz ${DIR}/${outdir}/mean_arepi_al.nii.gz
#	gunzip -f ${DIR}/${outdir}/*.gz
#	cp ${DIR}/${outdir}/run01/mean_arepi_al.nii ${DIR}/${outdir}/mean_arepi_al.nii

	cd ${DIR}/${outdir}
	gunzip ${DIR}/${outdir}/run01/arepi_sm6_al.nii.gz
	fslsplit ${DIR}/${outdir}/run01/arepi_sm6_al.nii
	gunzip ${DIR}/${outdir}/vol0*.nii.gz
	mv ${DIR}/${outdir}/run01/mcprextreg ${DIR}/${outdir}/run01/mcprextreg.txt
	
	/usr/local/matlab/bin/matlab -nodisplay <<EOF
%	cmd=sprintf('gunzip %s','${DIR}/${outdir}/run01/arepi_sm6_al.nii.gz');
%	unix(cmd)cd cdcd
	
	p = pathdef;
	addpath(p);
	spm_get_defaults;
	spm('Defaults','fMRI');
	spm_jobman('initcfg');
	
	clear matlabbatch
	matlabbatch={}; 
	PATIENT_NAME=strrep('${SUBJ}','_enc','')

	if (findstr('${epi}','mot'))
		run_mot=1;
	else
		run_mot=0;
	end
	
	[tempa,tempb,tempc] = fileparts('${DIR}/${outdir}/vol0000.nii');
	
	matlabbatch{1}.spm.stats.fmri_spec.dir = {'${DIR}/${outdir}'};
	matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
	matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2;
	matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
	matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
	matlabbatch{1}.spm.stats.fmri_spec.sess.scans = cellstr(spm_select('ExtFPList','${DIR}/${outdir}',['^vol']));
	matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).name = 'bonnes reponses';

	if (run_mot)
		goodValues = importdata(strrep('/NAS/dumbo/protocoles/IRMf_memoire/data/vanpoucke/log/words_TruePositive_vanpoucke.txt','vanpoucke',PATIENT_NAME));
	else
		goodValues = importdata(strrep('/NAS/dumbo/protocoles/IRMf_memoire/data/vanpoucke/log/faces_TruePositive_vanpoucke.txt','vanpoucke',PATIENT_NAME));
	end
	
	matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).onset = goodValues - (${remframe} * ${TR});
	matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).duration = 4;
	matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).tmod = 0;
	matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
	matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).orth = 1;
	matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).name = 'mauvaises conditions';
	if (run_mot)
		badValues = importdata(strrep('/NAS/dumbo/protocoles/IRMf_memoire/data/vanpoucke/log/words_FalseNegative_vanpoucke.txt','vanpoucke',PATIENT_NAME));
	else
		badValues = importdata(strrep('/NAS/dumbo/protocoles/IRMf_memoire/data/vanpoucke/log/faces_FalseNegative_vanpoucke.txt','vanpoucke',PATIENT_NAME));
	end
	matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).onset = badValues - (${remframe} * ${TR});
	matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).duration = 4;
	matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).tmod = 0;
	matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
	matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).orth = 1;
	matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {''};
	matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
	matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {'${DIR}/${outdir}/run01/mcprextreg.txt'};
	%matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {strrep('/NAS/dumbo/protocoles/IRMf_memoire/FS5.3/vanpoucke_enc/fmri/mot/rp_epi_0000.txt','vanpoucke',PATIENT_NAME)};
	matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;
	matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
	matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
	matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
	matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
	matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
	matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
	matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
	matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
	matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
	matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
	matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
	matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'bonnes reponses > baseline';
	matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1 0];
	matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
	matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'mauvaises reponses > baseline';
	matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [0 1];
	matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
	matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'bonnes reponses > mauvaises reponses';
	matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [1 -1];
	matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
	matlabbatch{3}.spm.stats.con.delete = 0;
	matlabbatch{4}.spm.stats.results.spmmat(1) = cfg_dep('Contrast Manager: SPM.mat File', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
	matlabbatch{4}.spm.stats.results.conspec.titlestr = '';
	matlabbatch{4}.spm.stats.results.conspec.contrasts = Inf;
	matlabbatch{4}.spm.stats.results.conspec.threshdesc = 'FWE';
	matlabbatch{4}.spm.stats.results.conspec.thresh = 0.05;
	matlabbatch{4}.spm.stats.results.conspec.extent = 5;
	matlabbatch{4}.spm.stats.results.conspec.mask.contrast.contrasts = 1;
	matlabbatch{4}.spm.stats.results.conspec.mask.contrast.thresh = 0.05;
	matlabbatch{4}.spm.stats.results.conspec.mask.contrast.mtype = 0;
	matlabbatch{4}.spm.stats.results.units = 1;
	matlabbatch{4}.spm.stats.results.print = 'pdf';
	matlabbatch{4}.spm.stats.results.write.none = 1;
	spm_jobman('run',matlabbatch);
EOF
rm -rf ${DIR}/${outdir}/vol0*.nii
fi
