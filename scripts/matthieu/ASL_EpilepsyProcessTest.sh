#! /bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage:  ASL_EpilepsyProcess.sh  -sd <path> -subj <patientname> "
	echo ""
	echo "  -sd         : Path to FS5.0 SUBJECTS_DIR "
	echo "  -subj       : Subject name "
	echo ""
	echo "Usage:  ASL_EpilepsyProcess.sh  -sd <path> -subj <patientname> "
	echo ""
	echo "Author: Matthieu Vanhoutte - CHRU Lille - March,21 2014"
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
	echo "Usage:  ASL_EpilepsyProcess.sh  -sd <path> -subj <patientname> "
	echo ""
	echo "  -sd         : Path to FS5.0 SUBJECTS_DIR "
	echo "  -subj       : Subject name "
	echo ""
	echo "Usage:  ASL_EpilepsyProcess.sh  -sd <path> -subj <patientname> "
	echo ""
	echo "Author: Matthieu Vanhoutte - CHRU Lille - March,21 2014"
	echo ""
	exit 1
		;;
	-sd)
		index=$[$index+1]
		eval FS_DIR=\${$index}
		echo "data : ${FS_DIR}"
		;;
	-subj)
		index=$[$index+1]
		eval subject=\${$index}
		echo "subject name : ${subject}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo ""
		echo "Usage:  ASL_EpilepsyProcess.sh  -sd <path> -subj <patientname> "
		echo ""
		echo "  -sd         : Path to FS5.0 SUBJECTS_DIR "
		echo "  -subj       : Subject name "
		echo ""
		echo "Usage:  ASL_EpilepsyProcess.sh  -sd <path> -subj <patientname> "
		echo ""
		echo "Author: Matthieu Vanhoutte - CHRU Lille - March,21 2014"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${FS_DIR} ]
then
	 echo "-sd argument mandatory"
	 exit 1
fi
if [ -z ${subject} ]
then
	 echo "-subj argument mandatory"
	 exit 1
fi

INPUT_DIR=/home/pierre/NAS/pierre/Epilepsy/DICOMS/Patients_fmri_dti

################################
## Step 1. Prepare ASL data in ${FS_DIR}/${subject}/asl directory
################################

# if [ ! -d ${FS_DIR}/${subject}/asl ]
# then
# 	mkdir -p ${FS_DIR}/${subject}/asl/{RawEpi,Structural}
# else
# 	rm -rf ${FS_DIR}/${subject}/asl/*
# 	mkdir ${FS_DIR}/${subject}/asl/{RawEpi,Structural}
# fi
# 
# echo "mri_convert ${FS_DIR}/${subject}/mri/T1.mgz ${FS_DIR}/${subject}/asl/Structural/brain.nii.gz --out_orientation RAS"
# mri_convert ${FS_DIR}/${subject}/mri/T1.mgz ${FS_DIR}/${subject}/asl/Structural/brain.nii.gz --out_orientation RAS
# 
# AslNii=$(ls ${INPUT_DIR}/${subject}/mri_convert/*PCASLSENSE*.nii.gz)
# AslCorr=$(ls ${INPUT_DIR}/${subject}/mri_convert/*PCASLCORRECTIONSENSE*.nii.gz)
# 
# cp ${AslNii} ${FS_DIR}/${subject}/asl/asl.nii.gz
# cp ${AslCorr} ${FS_DIR}/${subject}/asl/asl_back.nii.gz

################################
## Step 2. Correct distortions
################################

for_asl=${FS_DIR}/${subject}/asl/asl.nii.gz
rev_asl=${FS_DIR}/${subject}/asl/asl_back.nii.gz
distcor_asl=${FS_DIR}/${subject}/asl/asl_distcor.nii.gz
DCDIR=${FS_DIR}/${subject}/asl/DC

# if [ -e ${rev_asl} ]
# then
# 	# Estimate distortion corrections
# 	if [ ! -e ${FS_DIR}/${subject}/asl/DC/aslC0_norm_unwarp.nii.gz ]
# 	then
# 		if [ ! -d ${FS_DIR}/${subject}/asl/DC ]
# 		then
# 			mkdir ${FS_DIR}/${subject}/asl/DC
# 		else
# 			rm -rf ${FS_DIR}/${subject}/asl/DC/*
# 		fi
# 		echo "fslroi ${for_asl} ${DCDIR}/aslC0 0 1"
# 		fslroi ${for_asl} ${DCDIR}/aslC0 0 1
# 		echo "fslroi ${rev_asl} ${DCDIR}/aslC0_back 0 1"
# 		fslroi ${rev_asl} ${DCDIR}/aslC0_back 0 1
# 		
# 		gunzip -f ${DCDIR}/*gz
# 
# 		# Shift the reverse DWI by 1 voxel AP
# 		# Only for Philips images, for *unknown* reason
# 		# Then LR-flip the image for CMTK
# 		matlab -nodisplay <<EOF
# 		cd ${DCDIR}
# 		V = spm_vol('aslC0_back.nii');
# 		Y = spm_read_vols(V);
# 		
# 		Y = circshift(Y, [0 -1 0]);
# 		V.fname = 'saslC0_back.nii';
# 		spm_write_vol(V,Y);
# 		
# 		Y = flipdim(Y, 1);
# 		V.fname = 'raslC0_back.nii';
# 		spm_write_vol(V,Y);
# EOF
# 
# 		# Normalize the signal
# 		S=`fslstats ${DCDIR}/aslC0.nii -m`
# 		fslmaths ${DCDIR}/aslC0.nii -div $S -mul 1000 ${DCDIR}/aslC0_norm -odt double
# 		
# 		S=`fslstats ${DCDIR}/raslC0_back.nii -m`
# 		fslmaths ${DCDIR}/raslC0_back.nii -div $S -mul 1000 ${DCDIR}/raslC0_back_norm -odt double
# 		
# 		# Launch CMTK
# 		echo "cmtk epiunwarp --smooth-sigma-max 30 --smooth-sigma-diff 0.1 --smoothness-constraint-weight 5000000 --folding-constraint-weight 100000 --iterations 50000 -x --write-jacobian-fwd ${DCDIR}/jacobian_fwd.nii ${DCDIR}/b0_norm.nii.gz ${DCDIR}/rb0_back_norm.nii.gz ${DCDIR}/b0_norm_unwarp.nii ${DCDIR}/rb0_back_norm_unwarp.nii ${DCDIR}/dfield.nrrd"
# 		cmtk epiunwarp --smooth-sigma-max 30 --smooth-sigma-diff 0.1 --smoothness-constraint-weight 5000000 --folding-constraint-weight 100000 --iterations 50000 -x --write-jacobian-fwd ${DCDIR}/jacobian_fwd.nii ${DCDIR}/aslC0_norm.nii.gz ${DCDIR}/raslC0_back_norm.nii.gz ${DCDIR}/aslC0_norm_unwarp.nii ${DCDIR}/raslC0_back_norm_unwarp.nii ${DCDIR}/dfield.nrrd
# 		
# 		gzip -f ${DCDIR}/*.nii
# 	fi
# 	
# 	# Apply distortion corrections to the whole ASL
# 	if [ ! -e ${FS_DIR}/${subject}/asl/asl_distcor.nii.gz ]
# 	then
# 		echo "fslsplit ${for_asl} ${DCDIR}/voltmp -t"
# 		fslsplit ${for_asl} ${DCDIR}/voltmp -t
# 		
# 		for I in `ls ${DCDIR} | grep voltmp`
# 		do
# 			echo "cmtk reformatx --floating ${DCDIR}/${I} --linear -o ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/b0_norm.nii.gz ${DCDIR}/dfield.nrrd"
# 			cmtk reformatx --floating ${DCDIR}/${I} --linear -o ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/aslC0_norm.nii.gz ${DCDIR}/dfield.nrrd
# 			
# 			echo "cmtk imagemath --in ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/jacobian_fwd.nii.gz --mul --out ${DCDIR}/${I%.nii.gz}_ucorr_jac.nii.gz"
# 			cmtk imagemath --in ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/jacobian_fwd.nii.gz --mul --out ${DCDIR}/${I%.nii.gz}_ucorr_jac.nii.gz
# 			
# 			rm -f ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz
# 		done
# 		
# 		echo "fslmerge -t ${FS_DIR}/${subject}/asl/asl_distcor.nii.gz ${DCDIR}/*ucorr_jac.nii.gz"
# 		fslmerge -t ${FS_DIR}/${subject}/asl/asl_distcor.nii.gz ${DCDIR}/*ucorr_jac.nii.gz
# 		
# 		rm -f ${DCDIR}/*ucorr_jac.nii.gz ${DCDIR}/voltmp*
# 		gzip -f ${DCDIR}/*.nii	
# 	fi
# else
# 	# Rename asl.nii.gz to asl_distcor.nii.gz
# 	echo "mv ${for_asl} ${distcor_asl}"
# 	mv ${for_asl} ${distcor_asl}
# fi

################################
## Step 3. PreProcess asl nifti files
################################

if [ -n "${distcor_asl}" ]
then
	if [ ! -f ${FS_DIR}/${subject}/asl/RawEpi/epi_0000.nii ]
	then
		fslsplit ${distcor_asl} ${FS_DIR}/${subject}/asl/RawEpi/epi_ -t
		gunzip ${FS_DIR}/${subject}/asl/RawEpi/epi_*.gz
	fi


	if [ ! -f ${FS_DIR}/${subject}/asl/RawEpi/repi_0000.nii ]
	then
		gunzip ${FS_DIR}/${subject}/asl/Structural/brain.nii.gz
		matlab -nodisplay <<EOF

		prefix{1}  = '';
		prefix{2}  = 'r';
		prefix{3}  = 'mean';
		data_path = '${FS_DIR}/${subject}/asl'

		%% Initialise SPM defaults
		%--------------------------------------------------------------------------
		spm('defaults', 'FMRI');

		spm_jobman('initcfg');
		jobs={};

		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% SPATIAL PREPROCESSING
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		%% Select functional and structural scans
		%--------------------------------------------------------------------------
		f = spm_select('FPList', fullfile(data_path,'RawEpi'), '^epi_.*\.nii$');
		a = spm_select('FPList', fullfile(data_path,'Structural'), '^brain.*\.nii$');

		%% REALIGN
		%--------------------------------------------------------------------------
		jobs{end+1}.spm.spatial.realign.estwrite.data = { editfilenames(f,'prefix',prefix{1}) };
		jobs{end}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
		jobs{end}.spm.spatial.realign.estwrite.eoptions.sep     = 4;
		jobs{end}.spm.spatial.realign.estwrite.eoptions.fwhm    = 5;
		jobs{end}.spm.spatial.realign.estwrite.eoptions.rtm     = 1;
		jobs{end}.spm.spatial.realign.estwrite.eoptions.interp  = 2;
		jobs{end}.spm.spatial.realign.estwrite.eoptions.wrap    = [0 0 0];
		jobs{end}.spm.spatial.realign.estwrite.eoptions.weight  = '';
		jobs{end}.spm.spatial.realign.estwrite.roptions.which   = [2 1];
		jobs{end}.spm.spatial.realign.estwrite.roptions.interp  = 4;
		jobs{end}.spm.spatial.realign.estwrite.roptions.wrap    = [0 0 0];
		jobs{end}.spm.spatial.realign.estwrite.roptions.mask    = 1;
		jobs{end}.spm.spatial.realign.estwrite.roptions.prefix  = 'r';

		%% COREGISTRATION
		%--------------------------------------------------------------------------

		disp('no resampling');
		jobs{end+1}.spm.spatial.coreg.estimate.ref    = cellstr(a);
		jobs{end}.spm.spatial.coreg.estimate.source = editfilenames(f(1,:),'prefix',prefix{3});
		jobs{end}.spm.spatial.coreg.estimate.other  = editfilenames(f,'prefix',prefix{2});
		jobs{end}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
		jobs{end}.spm.spatial.coreg.estimate.eoptions.sep      = [4 2];
		jobs{end}.spm.spatial.coreg.estimate.eoptions.tol      = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
		jobs{end}.spm.spatial.coreg.estimate.eoptions.fwhm     = [7 7];
		    

		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%% RUN
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		save(fullfile(data_path,'batch_preprocessing.mat'),'jobs');
		spm_jobman('run',jobs);
EOF
	gunzip ${FS_DIR}/${subject}/asl/RawEpi/repi_*.gz 
	fi
fi

################################
## Step 4. Merge and calcul mean of each type of ASL files, then do the substraction
################################

echo "fslmerge -t ${FS_DIR}/${subject}/asl/control ${FS_DIR}/${subject}/asl/RawEpi/repi_00{00..58..2}*.nii"
fslmerge -t ${FS_DIR}/${subject}/asl/control ${FS_DIR}/${subject}/asl/RawEpi/repi_00{00..58..2}*.nii

echo "fslmerge -t ${FS_DIR}/${subject}/asl/tag ${FS_DIR}/${subject}/asl/RawEpi/repi_00{01..59..2}*.nii"
fslmerge -t ${FS_DIR}/${subject}/asl/tag ${FS_DIR}/${subject}/asl/RawEpi/repi_00{01..59..2}*.nii

echo "fslmaths ${FS_DIR}/${subject}/asl/control -Tmean ${FS_DIR}/${subject}/asl/control_mean"
fslmaths ${FS_DIR}/${subject}/asl/control -Tmean ${FS_DIR}/${subject}/asl/control_mean

# Remove NaNs
echo "fslmaths ${FS_DIR}/${subject}/asl/control_mean -nan ${FS_DIR}/${subject}/asl/control_mean"
fslmaths ${FS_DIR}/${subject}/asl/control_mean -nan ${FS_DIR}/${subject}/asl/control_mean
# gunzip ${FS_DIR}/${subject}/asl/control_mean.nii.gz

echo "fslmaths ${FS_DIR}/${subject}/asl/tag -Tmean  ${FS_DIR}/${subject}/asl/tag_mean"
fslmaths ${FS_DIR}/${subject}/asl/tag -Tmean  ${FS_DIR}/${subject}/asl/tag_mean

# Remove NaNs
echo "fslmaths ${FS_DIR}/${subject}/asl/tag_mean -nan ${FS_DIR}/${subject}/asl/tag_mean"
fslmaths ${FS_DIR}/${subject}/asl/tag_mean -nan ${FS_DIR}/${subject}/asl/tag_mean
# gunzip ${FS_DIR}/${subject}/asl/tag_mean.nii.gz

echo "fslmaths ${FS_DIR}/${subject}/asl/control_mean -sub ${FS_DIR}/${subject}/asl/tag_mean ${FS_DIR}/${subject}/asl/asl_map"
fslmaths ${FS_DIR}/${subject}/asl/control_mean -sub ${FS_DIR}/${subject}/asl/tag_mean ${FS_DIR}/${subject}/asl/asl_map

gunzip ${FS_DIR}/${subject}/asl/*.gz 

echo "mri_binarize --i ${FS_DIR}/${subject}/asl/control_mean.nii --min 150 --o ${FS_DIR}/${subject}/asl/brain_mask.nii"
mri_binarize --i ${FS_DIR}/${subject}/asl/control_mean.nii --min 150 --o ${FS_DIR}/${subject}/asl/brain_mask.nii

echo "mri_morphology ${FS_DIR}/${subject}/asl/brain_mask.nii dilate 1 ${FS_DIR}/${subject}/asl/brain_mask_dil.nii" 
mri_morphology ${FS_DIR}/${subject}/asl/brain_mask.nii dilate 1 ${FS_DIR}/${subject}/asl/brain_mask_dil.nii

################################
## Step 5. Calcul CBF map
################################

if [ ! -f ${FS_DIR}/${subject}/asl/CBF.nii ]
then
	matlab -nodisplay <<EOF
	
	disp('calcul carto CBF');
	V1=spm_vol('${FS_DIR}/${subject}/asl/control_mean.nii');
	V2=spm_vol('${FS_DIR}/${subject}/asl/asl_map.nii');
	V3=spm_vol('${FS_DIR}/${subject}/asl/brain_mask_dil.nii');

	data1=spm_read_vols(V1);
	data2=spm_read_vols(V2);
	data3=spm_read_vols(V3);

	data2(~isfinite(data2(:))) = 0;
	data3(~isfinite(data3(:))) = 0;
	%CBFtemp=6000.*data2.*exp(1.525./1.68)./(2.*0.85.*0.76.*1.68.*data1);
	CBFtemp=6000/2*0.76*0.85*0.83*1.68.*data2./data1*exp((1.525+0.03646)/1.68)*exp(14/50).*data3;

	V1.fname='${FS_DIR}/${subject}/asl/CBF.nii';
	spm_write_vol(V1,CBFtemp);
EOF

# Remove NaNs
echo "fslmaths ${FS_DIR}/${subject}/asl/CBF -nan ${FS_DIR}/${subject}/asl/CBF"
fslmaths ${FS_DIR}/${subject}/asl/CBF -nan ${FS_DIR}/${subject}/asl/CBF
rm -f ${FS_DIR}/${subject}/asl/CBF.nii
gunzip ${FS_DIR}/${subject}/asl/CBF.nii.gz

fi

################################
## Step 6. Reslice CBF map
################################

if [ ! -f ${FS_DIR}/${subject}/asl/rCBF.nii ]
then
	matlab -nodisplay <<EOF
	
	disp('reslice CBF.nii');
	prefix{1}  = '';
	data_path = '${FS_DIR}/${subject}/asl'

	%% Initialise SPM defaults
	%--------------------------------------------------------------------------
	spm('defaults', 'FMRI');

	spm_jobman('initcfg');
	matlabbatch={};

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% SPATIAL PREPROCESSING
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	%% Select functional and structural scans
	%--------------------------------------------------------------------------
	a = spm_select('FPList', fullfile(data_path,'Structural'), '^brain.*\.nii$');
	f = spm_select('FPList', data_path, '^CBF.*\.nii$');

	%% Reslice Coregistration on T1 map
	%-----------------------------------------------------------------------
	matlabbatch{end+1}.spm.spatial.coreg.write.ref = editfilenames(a,'prefix',prefix{1});
	matlabbatch{end}.spm.spatial.coreg.write.source = editfilenames(f,'prefix',prefix{1}) ;
	matlabbatch{end}.spm.spatial.coreg.write.roptions.interp = 1;
	matlabbatch{end}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
	matlabbatch{end}.spm.spatial.coreg.write.roptions.mask = 0;
	matlabbatch{end}.spm.spatial.coreg.write.roptions.prefix = 'r';

	save(fullfile(data_path,'batch_reslice.mat'),'matlabbatch');
	spm_jobman('run',matlabbatch);
EOF
	# Remove NaNs
	echo "fslmaths ${FS_DIR}/${subject}/asl/rCBF -nan ${FS_DIR}/${subject}/asl/rCBF"
	fslmaths ${FS_DIR}/${subject}/asl/rCBF -nan ${FS_DIR}/${subject}/asl/rCBF
	rm -f ${FS_DIR}/${subject}/asl/rCBF.nii
	gzip ${FS_DIR}/${subject}/asl/*.nii
fi
	
# if [ -z "${AslCorr}" ]
# then
# 	if [ ! -f ${FS_DIR}/${subject}/asl/RawEpi/epi_corr_0000.nii ]
# 	then
# 		fslsplit ${AslNii} ${FS_DIR}/${subject}/asl/RawEpi/epi_corr_ -t
# 	fi
# fi
# 
# 
# # # ASL map
# # /usr/local/matlab11/bin/matlab -nodisplay <<EOF
# # % Load Matlab Path
# # %p = pathdef;
# # %addpath(p);
# # 
# # process_asl(fullfile('${FS_DIR}','${subject}'));
# #  
# # EOF
# # 
# # # Map on surface
# # Project_ASL.sh -sd ${FS_DIR} -subj ${subject} -fwhm 20
# 
