#!/bin/bash

if [ $# -lt 16 ]
then
	echo ""
	echo "Usage: DTI_DiffusionToStructural.sh  -t1 <t1_nifti>  -t1brain <t1brain_nifti>  -brainmask <mask_nifti>  -dti  <dti_nifti>  -bval  <file>  -bvec <file>  -oreg <outdir>   -o <folder>  [-t1restore <nifti>  -bias <nifti>  -fs <folder>  -subj <name>]"
	echo ""
	echo "NIFTI IMAGE WHITHOUT EXTENSION"
	echo "  -t1                       : t1 file (nifti image)"
	echo "  -t1brain                  : t1 brain file (nifti image)"
	echo "  -brainmask                : t1 brain mask (nifti image)"
	echo "  -dti                      : dti file (nifti image)"
	echo "  -bval                     : bval file"
	echo "  -bvec                     : bvec file"
	echo "  -oreg                     : output folder for registration files "
	echo "  -o                        : output folder name "
	echo " "
	echo "Options :"
	echo "  -t1restore                : t1 file after bias field correction (default : NONE)"
	echo "  -bias                     : bias field image (default : NONE)"
	echo "  -fs                       : Freesurfer folder (Default : NONE)"
	echo "  -subj                     : Subject's Freesurfer folder (Default : NONE)"
	echo ""
	echo "Usage: DTI_DiffusionToStructural.sh  -t1 <t1_nifti>  -t1brain <t1brain_nifti>  -brainmask <mask_nifti>  -dti  <dti_nifti>  -bval  <file>  -bvec <file>  -oreg <outdir>  [-t1restore <nifti>  -bias <nifti>  -fs <folder>  -subj <name>]"
	exit 1
fi


#### Inputs ####
index=1
echo "------------------------"

T1wRestoreImage="NONE"
BiasField="NONE"
dof="6"
FSDIR="NONE"
SUBJ="NONE"
QAImage="QA"

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: DTI_DiffusionToStructural.sh  -t1 <t1_nifti>  -t1brain <t1brain_nifti>  -brainmask <mask_nifti>  -dti  <dti_nifti>  -bval  <file>  -bvec <file>  -oreg <outdir>   -o <folder>  [-t1restore <nifti>  -bias <nifti>  -fs <folder>  -subj <name>]"
		echo ""
		echo "NIFTI IMAGE WHITHOUT EXTENSION"
		echo "  -t1                       : t1 file (nifti image)"
		echo "  -t1brain                  : t1 brain file (nifti image)"
		echo "  -brainmask                : t1 brain mask (nifti image)"
		echo "  -dti                      : dti file (nifti image)"
		echo "  -bval                     : bval file"
		echo "  -bvec                     : bvec file"
		echo "  -oreg                     : output folder for registration files "
		echo "  -o                        : output folder name "
		echo " "
		echo "Options :"
		echo "  -t1restore                : t1 file after bias field correction (default : NONE)"
		echo "  -bias                     : bias field image (default : NONE)"
		echo "  -fs                       : Freesurfer folder (Default : NONE)"
		echo "  -subj                     : Subject's Freesurfer folder (Default : NONE)"
		echo ""
		echo "Usage: DTI_DiffusionToStructural.sh  -t1 <t1_nifti>  -t1brain <t1brain_nifti>  -brainmask <mask_nifti>  -dti  <dti_nifti>  -bval  <file>  -bvec <file>  -oreg <outdir>  [-t1restore <nifti>  -bias <nifti>  -fs <folder>  -subj <name>]"
		exit 1
		;;
	-t1)
		T1wImage=`expr $index + 1`
		eval T1wImage=\${$T1wImage}
		echo "  |-------> T1 file : $T1wImage"
		index=$[$index+1]
		;;
	-t1brain)
		T1wBrainImage=`expr $index + 1`
		eval T1wBrainImage=\${$T1wBrainImage}
		echo "  |-------> T1 brain file : $T1wBrainImage"
		index=$[$index+1]
		;;
	-brainmask)
		InputBrainMask=`expr $index + 1`
		eval InputBrainMask=\${$InputBrainMask}
		echo "  |-------> T1 brain mask file : $InputBrainMask"
		index=$[$index+1]
		;;
	-t1restore)
		T1wRestoreImage=`expr $index + 1`
		eval T1wRestoreImage=\${$T1wRestoreImage}
		echo "  |-------> T1 restore file : $T1wRestoreImage"
		index=$[$index+1]
		;;
	-dti)
		DTI=`expr $index + 1`
		eval DTI=\${$DTI}
		echo "  |-------> DTI file : $DTI"
		index=$[$index+1]
		;;
	-bval)
		BVAL=`expr $index + 1`
		eval BVAL=\${$BVAL}
		echo "  |-------> bval file : ${BVAL}"
		index=$[$index+1]
		;;
	-bvec)
		BVEC=`expr $index + 1`
		eval BVEC=\${$BVEC}
		echo "  |-------> bvec file : ${BVEC}"
		index=$[$index+1]
		;;
	-oreg)
		OUTDIR=`expr $index + 1`
		eval OUTDIR=\${$OUTDIR}
		echo "  |-------> output folder for registration : ${OUTDIR}"
		index=$[$index+1]
		;;
	-o)
		OUTNAME=`expr $index + 1`
		eval OUTNAME=\${$OUTNAME}
		echo "  |-------> output folder name : ${OUTNAME}"
		index=$[$index+1]
		;;
	-bias)
		BiasField=`expr $index + 1`
		eval BiasField=\${$BiasField}
		echo "  |-------> bias field : ${BiasField}"
		index=$[$index+1]
		;;
	-fs)
		FSDIR=`expr $index + 1`
		eval FSDIR=\${$FSDIR}
		echo "  |-------> FS folder : ${FSDIR}"
		index=$[$index+1]
		;;
	-subj)
		SUBJ=`expr $index + 1`
		eval SUBJ=\${$SUBJ}
		echo "  |-------> subject's FS folder : ${SUBJ}"
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


# Paths for scripts etc (uses variables defined in SetUpHCPPipeline.sh)
GlobalScripts=${HCPPIPEDIR_Global}

DIR=`dirname ${DTI}`

# T1 output folder
echo "Create T1 folder"
T1wOutputDirectory=${DIR}/${OUTNAME}
echo $T1wOutputDirectory
if [ ! -d ${T1wOutputDirectory} ]; then mkdir ${T1wOutputDirectory}; fi 

# T1 restore
if [ $T1wRestoreImage = "NONE" ] ; then T1wRestoreImage=${T1wImage}; fi

# T1 names
T1wBrainImageFile=`basename $T1wBrainImage`
T1wRestoreImageFile=`basename $T1wRestoreImage`

regimg="nodif"

# test if B0 image
if [ ! -f ${DIR}/${regimg}.nii.gz ]; then $FSLDIR/bin/fslroi ${DTI} ${DIR}/${regimg} 0 1; fi

# Check if output folder
echo "check if output folder"
if [ ! -d ${OUTDIR} ]; then mkdir ${OUTDIR}; fi 

QAImage=${OUTDIR}/${QAImage}

echo "imcp "$T1wBrainImage" "$OUTDIR"/"$T1wBrainImageFile""
${FSLDIR}/bin/imcp "$T1wBrainImage" "$OUTDIR"/"$T1wBrainImageFile"

# B0 FLIRT BBR to T1w
echo "b0 FLIRT BBR to T1w"
echo "epi_reg_dof --dof=${dof} --epi="$DIR"/"$regimg" --t1="$T1wImage" --t1brain="$OUTDIR"/"$T1wBrainImageFile" --out="$OUTDIR"/"$regimg"2T1w_initII"
${GlobalScripts}/epi_reg_dof --dof=${dof} --epi="$DIR"/"$regimg" --t1="$T1wImage" --t1brain="$OUTDIR"/"$T1wBrainImageFile" --out="$OUTDIR"/"$regimg"2T1w_initII

# Apply transformation to B0
echo "Apply transformation to B0"
echo "applywarp --rel --interp=spline -i "$DIR"/"$regimg" -r "$T1wImage" --premat="$OUTDIR"/"$regimg"2T1w_initII_init.mat -o "$OUTDIR"/"$regimg"2T1w_init.nii.gz"
${FSLDIR}/bin/applywarp --rel --interp=spline -i "$DIR"/"$regimg" -r "$T1wImage" --premat="$OUTDIR"/"$regimg"2T1w_initII_init.mat -o "$OUTDIR"/"$regimg"2T1w_init.nii.gz
echo "applywarp --rel --interp=spline -i "$DIR"/"$regimg" -r "$T1wImage" --premat="$OUTDIR"/"$regimg"2T1w_initII.mat -o "$OUTDIR"/"$regimg"2T1w_initII.nii.gz"
${FSLDIR}/bin/applywarp --rel --interp=spline -i "$DIR"/"$regimg" -r "$T1wImage" --premat="$OUTDIR"/"$regimg"2T1w_initII.mat -o "$OUTDIR"/"$regimg"2T1w_initII.nii.gz

if [ $BiasField = "NONE" ] ; then
	echo "do not bias field correction"
else
	echo "do bias field correction"
	echo "fslmaths "$OUTDIR"/"$regimg"2T1w_initII.nii.gz -div "$BiasField" "$OUTDIR"/"$regimg"2T1w_initII.nii.gz"
	${FSLDIR}/bin/fslmaths "$OUTDIR"/"$regimg"2T1w_initII.nii.gz -div "$BiasField" "$OUTDIR"/"$regimg"2T1w_initII.nii.gz
fi


# Do B0 bbregister to T1w
if [ $FSDIR = "NONE" ] ; then 

	echo "do not BBregister"
	mv "$OUTDIR"/"$regimg"2T1w_initII.mat "$OUTDIR"/diff2str.mat
	
	echo "inverse final transformation"
	echo "convert_xfm -omat "$OUTDIR"/str2diff.mat -inverse "$OUTDIR"/diff2str.mat"
	${FSLDIR}/bin/convert_xfm -omat "$OUTDIR"/str2diff.mat -inverse "$OUTDIR"/diff2str.mat

	${FSLDIR}/bin/imcp "$OUTDIR"/"$regimg"2T1w_initII "$OUTDIR"/"$regimg"2T1w

else

	echo "do BBregister to T1w"
	SUBJECTS_DIR="$FSDIR"
	export SUBJECTS_DIR

	if [ ! -f "$FSDIR"/"$SUBJ"/mri/transforms/eye.dat ]; then

		echo "$SUBJ" > "$FSDIR"/"$SUBJ"/mri/transforms/eye.dat
		echo "1" >> "$FSDIR"/"$SUBJ"/mri/transforms/eye.dat
		echo "1" >> "$FSDIR"/"$SUBJ"/mri/transforms/eye.dat
		echo "1" >> "$FSDIR"/"$SUBJ"/mri/transforms/eye.dat
		echo "1 0 0 0" >> "$FSDIR"/"$SUBJ"/mri/transforms/eye.dat
		echo "0 1 0 0" >> "$FSDIR"/"$SUBJ"/mri/transforms/eye.dat
		echo "0 0 1 0" >> "$FSDIR"/"$SUBJ"/mri/transforms/eye.dat
		echo "0 0 0 1" >> "$FSDIR"/"$SUBJ"/mri/transforms/eye.dat
		echo "round" >> "$FSDIR"/"$SUBJ"/mri/transforms/eye.dat

	fi

	if [ ! -f "$FSDIR"/"$SUBJ"/surf/lh.white.deformed ]; then SURF="white"; else SURF="white.deformed"; fi
	echo "bbregister --s "$SUBJ" --mov "$OUTDIR"/"$regimg"2T1w_initII.nii.gz --surf ${SURF} --init-reg "$FSDIR"/"$SUBJ"/mri/transforms/eye.dat --bold --reg "$OUTDIR"/EPItoT1w.dat --o "$OUTDIR"/"$regimg"2T1w.nii.gz"
	${FREESURFER_HOME}/bin/bbregister --s "$SUBJ" --mov "$OUTDIR"/"$regimg"2T1w_initII.nii.gz --surf ${SURF} --init-reg "$FSDIR"/"$SUBJ"/mri/transforms/eye.dat --bold --reg "$OUTDIR"/EPItoT1w.dat --o "$OUTDIR"/"$regimg"2T1w.nii.gz

	echo "tkregister2 --noedit --reg "$OUTDIR"/EPItoT1w.dat --mov "$OUTDIR"/"$regimg"2T1w_initII.nii.gz --targ "$T1wImage".nii.gz --fslregout "$OUTDIR"/diff2str_fs.mat"
	${FREESURFER_HOME}/bin/tkregister2 --noedit --reg "$OUTDIR"/EPItoT1w.dat --mov "$OUTDIR"/"$regimg"2T1w_initII.nii.gz --targ "$T1wImage".nii.gz --fslregout "$OUTDIR"/diff2str_fs.mat

	echo "final transformation"
	echo "convert_xfm -omat "$OUTDIR"/diff2str.mat -concat "$OUTDIR"/diff2str_fs.mat "$OUTDIR"/"$regimg"2T1w_initII.mat"
	${FSLDIR}/bin/convert_xfm -omat "$OUTDIR"/diff2str.mat -concat "$OUTDIR"/diff2str_fs.mat "$OUTDIR"/"$regimg"2T1w_initII.mat
	
	echo "inverse final transformation"
	echo "convert_xfm -omat "$OUTDIR"/str2diff.mat -inverse "$OUTDIR"/diff2str.mat"
	${FSLDIR}/bin/convert_xfm -omat "$OUTDIR"/str2diff.mat -inverse "$OUTDIR"/diff2str.mat

	echo "B0 to T1 image"
	echo "applywarp --rel --interp=spline -i "$DIR"/"$regimg" -r "$T1wImage".nii.gz --premat="$OUTDIR"/diff2str.mat -o "$OUTDIR"/"$regimg"2T1w"
	${FSLDIR}/bin/applywarp --rel --interp=spline -i "$DIR"/"$regimg" -r "$T1wImage".nii.gz --premat="$OUTDIR"/diff2str.mat -o "$OUTDIR"/"$regimg"2T1w

fi


if [ $BiasField = "NONE" ] ; then echo "do not bias field correction"; else
	echo "do bias field correction"
	echo "fslmaths "$OUTDIR"/"$regimg"2T1w -div "$BiasField" "$OUTDIR"/"$regimg"2T1w"
	${FSLDIR}/bin/fslmaths "$OUTDIR"/"$regimg"2T1w -div "$BiasField" "$OUTDIR"/"$regimg"2T1w
fi

# Are the next two scripts needed?
echo "fslmaths $T1wRestoreImage -mul ${OUTDIR}/${regimg}2T1w -sqrt ${QAImage}_${regimg}"
${FSLDIR}/bin/fslmaths $T1wRestoreImage -mul ${OUTDIR}/${regimg}2T1w -sqrt ${QAImage}_${regimg}

# Generate 2mm structural space for resampling the diffusion data into
echo "Generate 2mm structural space for resampling the diffusion data into"
DiffRes=`${FSLDIR}/bin/fslval ${DTI} pixdim1`
DiffRes=`printf "%0.2f" ${DiffRes}`
echo "flirt -interp spline -in "$T1wRestoreImage" -ref "$T1wRestoreImage" -applyisoxfm ${DiffRes} -out "$T1wOutputDirectory"/"$T1wRestoreImageFile"_${DiffRes}"
${FSLDIR}/bin/flirt -interp spline -in "$T1wRestoreImage" -ref "$T1wRestoreImage" -applyisoxfm ${DiffRes} -out "$T1wOutputDirectory"/"$T1wRestoreImageFile"_${DiffRes}
echo "applywarp --rel --interp=spline -i "$T1wRestoreImage" -r "$T1wOutputDirectory"/"$T1wRestoreImageFile"_${DiffRes} -o "$T1wOutputDirectory"/"$T1wRestoreImageFile"_${DiffRes}"
${FSLDIR}/bin/applywarp --rel --interp=spline -i "$T1wRestoreImage" -r "$T1wOutputDirectory"/"$T1wRestoreImageFile"_${DiffRes} -o "$T1wOutputDirectory"/"$T1wRestoreImageFile"_${DiffRes}

# Generate 2mm mask in structural space
echo "Generate 2mm mask in structural space"
echo "flirt -interp nearestneighbour -in "$InputBrainMask" -ref "$InputBrainMask" -applyisoxfm ${DiffRes} -out "$T1wOutputDirectory"/nodif_brain_mask"
${FSLDIR}/bin/flirt -interp nearestneighbour -in "$InputBrainMask" -ref "$InputBrainMask" -applyisoxfm ${DiffRes} -out "$T1wOutputDirectory"/nodif_brain_mask
${FSLDIR}/bin/fslmaths "$T1wOutputDirectory"/nodif_brain_mask -kernel 3D -dilM "$T1wOutputDirectory"/nodif_brain_mask

# mask dilatation
echo "mask dilatation"
DilationsNum=6 # Dilated mask for masking the final data and grad_dev
${FSLDIR}/bin/imcp "$T1wOutputDirectory"/nodif_brain_mask "$T1wOutputDirectory"/nodif_brain_mask_temp
for (( j=0; j<${DilationsNum}; j++ ))
do
    ${FSLDIR}/bin/fslmaths "$T1wOutputDirectory"/nodif_brain_mask_temp -kernel 3D -dilM "$T1wOutputDirectory"/nodif_brain_mask_temp
done

# Rotate bvecs from diffusion to structural space
echo "Rotate bvecs from diffusion to structural space"
echo "Rotate_bvecs.sh ${BVEC} "$OUTDIR"/diff2str.mat "$T1wOutputDirectory"/bvecs"
${GlobalScripts}/Rotate_bvecs.sh ${BVEC} "$OUTDIR"/diff2str.mat "$T1wOutputDirectory"/bvecs
cp ${BVAL} "$T1wOutputDirectory"/bvals

# Register diffusion data to T1w space. 
echo "Register diffusion data to T1w space"
echo "flirt -in ${DTI} -ref "$T1wOutputDirectory"/"$T1wRestoreImageFile"_${DiffRes} -applyxfm -init "$OUTDIR"/diff2str.mat -interp spline -out "$T1wOutputDirectory"/data"
${FSLDIR}/bin/flirt -in ${DTI} -ref "$T1wOutputDirectory"/"$T1wRestoreImageFile"_${DiffRes} -applyxfm -init "$OUTDIR"/diff2str.mat -interp spline -out "$T1wOutputDirectory"/data

${FSLDIR}/bin/fslmaths "$T1wOutputDirectory"/data -mas "$T1wOutputDirectory"/nodif_brain_mask_temp "$T1wOutputDirectory"/data  #Mask-out data outside the brain 
${FSLDIR}/bin/fslmaths "$T1wOutputDirectory"/data -thr 0 "$T1wOutputDirectory"/data      #Remove negative intensity values (caused by spline interpolation) from final data
${FSLDIR}/bin/imrm "$T1wOutputDirectory"/nodif_brain_mask_temp

${FSLDIR}/bin/fslmaths "$T1wOutputDirectory"/data -Tmean "$T1wOutputDirectory"/temp
${FSLDIR}/bin/immv "$T1wOutputDirectory"/nodif_brain_mask.nii.gz "$T1wOutputDirectory"/nodif_brain_mask_old.nii.gz
${FSLDIR}/bin/fslmaths "$T1wOutputDirectory"/nodif_brain_mask_old.nii.gz -mas "$T1wOutputDirectory"/temp "$T1wOutputDirectory"/nodif_brain_mask
${FSLDIR}/bin/imrm "$T1wOutputDirectory"/temp

echo " END: DTI_DiffusionToStructural"

