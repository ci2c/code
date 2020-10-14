#! /bin/bash

if [ $# -lt 6 ]
then
	echo ""
	echo "Usage:  ASL_EpilepsyProcess.sh  -id <inputdir> -sd <path> -subj <patientname>"
	echo ""
	echo "	-id		: Input directory containing raw data "
	echo "  -sd		: Path to FS5.0 SUBJECTS_DIR "
	echo "  -subj       	: Subject name "
	echo ""
	echo "Usage:  ASL_EpilepsyProcess.sh  -id <inputdir> -sd <path> -subj <patientname>"
	echo ""
	echo "Author: Matthieu Vanhoutte - CHRU Lille - May 2014"
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
		echo "Usage:  ASL_EpilepsyProcess.sh  -id <inputdir> -sd <path> -subj <patientname>"
		echo ""
		echo "	-id		: Input directory containing raw data "
		echo "  -sd		: Path to FS5.0 SUBJECTS_DIR "
		echo "  -subj       	: Subject name "
		echo ""
		echo "Usage:  ASL_EpilepsyProcess.sh  -id <inputdir> -sd <path> -subj <patientname>"
		echo ""
		echo "Author: Matthieu Vanhoutte - CHRU Lille - May 2014"
		echo ""
		exit 1
		;;
	-id)
		index=$[$index+1]
		eval INPUT_DIR=\${$index}
		echo "input data : ${INPUT_DIR}"
		;;	
	-sd)
		index=$[$index+1]
		eval FS_DIR=\${$index}
		echo "FS data : ${FS_DIR}"
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
		echo "Usage:  ASL_EpilepsyProcess.sh  -id <inputdir> -sd <path> -subj <patientname>"
		echo ""
		echo "	-id		: Input directory containing raw data "
		echo "  -sd		: Path to FS5.0 SUBJECTS_DIR "
		echo "  -subj       	: Subject name "
		echo ""
		echo "Usage:  ASL_EpilepsyProcess.sh  -id <inputdir> -sd <path> -subj <patientname>"
		echo ""
		echo "Author: Matthieu Vanhoutte - CHRU Lille - May 2014"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${INPUT_DIR} ]
then
	 echo "-id argument mandatory"
	 exit 1
fi
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

################################
## Step 1. Extract input data and prepare ASL data in ${FS_DIR}/${subject}/asl directory
################################

# gzip ${INPUT_DIR}/${subject}/*.nii

# # init_fs5.1
# export FREESURFER_HOME=/home/global/freesurfer5.1/
# . ${FREESURFER_HOME}/SetUpFreeSurfer.sh
# 
# if [ ! -d ${INPUT_DIR}/${subject}/asl ]
# then
# 	mkdir -p ${INPUT_DIR}/${subject}/asl/{Nifti,RawEpi,Structural}
# else
# 	rm -f ${INPUT_DIR}/${subject}/asl/*
# 	mkdir -p ${INPUT_DIR}/${subject}/asl/{Nifti,RawEpi,Structural}
# fi

# # mv -t ${INPUT_DIR}/${subject}/Nifti ${INPUT_DIR}/${subject}/*.nii.gz

# if [ -d ${INPUT_DIR}/${subject}/DICOM ]
# then
# 	dcm2nii -o ${INPUT_DIR}/${subject}/Nifti ${INPUT_DIR}/${subject}/DICOM/*
# elif [ -d ${INPUT_DIR}/${subject}/recpar ]
# then
# 	dcm2nii -o ${INPUT_DIR}/${subject}/Nifti ${INPUT_DIR}/${subject}/recpar/*
# elif [ -d ${INPUT_DIR}/${subject}/asl_old ]
# then
# 	dcm2nii -o ${INPUT_DIR}/${subject}/asl/Nifti ${INPUT_DIR}/${subject}/asl_old/*.par
# fi

if [ ! -d ${FS_DIR}/${subject}/asl ]
then
	mkdir -p ${FS_DIR}/${subject}/asl/{RawEpi,Structural}
else
	rm -rf ${FS_DIR}/${subject}/asl/*
	mkdir ${FS_DIR}/${subject}/asl/{RawEpi,Structural}
fi

echo "mri_convert ${FS_DIR}/${subject}/mri/T1.mgz ${FS_DIR}/${subject}/asl/Structural/brain.nii.gz --out_orientation LAS"
mri_convert ${FS_DIR}/${subject}/mri/T1.mgz ${FS_DIR}/${subject}/asl/Structural/brain.nii.gz --out_orientation LAS

BitRecPar=0

AslSplit1=$(ls ${INPUT_DIR}/${subject}/Nifti/*PCASLSENSE*x1.nii.gz)
AslSplit2=$(ls ${INPUT_DIR}/${subject}/Nifti/*PCASLSENSE*x2.nii.gz)
AslCorrSplit1=$(ls ${INPUT_DIR}/${subject}/Nifti/*PCASLCORRECTION*x1.nii.gz)
AslCorrSplit2=$(ls ${INPUT_DIR}/${subject}/Nifti/*PCASLCORRECTION*x2.nii.gz)

if [ -n "${AslSplit1}" ] && [ -n "${AslSplit2}" ]
then
	BitRecPar=1
	
	echo "fslmerge -t ${FS_DIR}/${subject}/asl/asl.nii.gz ${AslSplit1} ${AslSplit2}"
	fslmerge -t ${FS_DIR}/${subject}/asl/asl.nii.gz ${AslSplit1} ${AslSplit2}
	
	echo "fslmerge -t ${FS_DIR}/${subject}/asl/asl_back.nii.gz ${AslCorrSplit1} ${AslCorrSplit2}"
	fslmerge -t ${FS_DIR}/${subject}/asl/asl_back.nii.gz ${AslCorrSplit1} ${AslCorrSplit2}
else
	Asl=$(ls ${INPUT_DIR}/${subject}/Nifti/*PCASLSENSE*.nii.gz)
	AslCorr=$(ls ${INPUT_DIR}/${subject}/Nifti/*PCASLCORRECTIONSENSE*.nii.gz)
	if [ -n "${Asl}" ]
	then
		echo "cp ${Asl} ${FS_DIR}/${subject}/asl/asl.nii.gz"
		cp ${Asl} ${FS_DIR}/${subject}/asl/asl.nii.gz
		
		echo "cp ${AslCorr} ${FS_DIR}/${subject}/asl/asl_back.nii.gz"
		cp ${AslCorr} ${FS_DIR}/${subject}/asl/asl_back.nii.gz
	else
		echo "Le fichier ASL n'existe pas"
		exit 1
	fi
fi	

################################
## Step 2. Correct distortions
################################

for_asl=${FS_DIR}/${subject}/asl/asl.nii.gz
rev_asl=${FS_DIR}/${subject}/asl/asl_back.nii.gz
distcor_asl=${FS_DIR}/${subject}/asl/asl_distcor.nii.gz
DCDIR=${FS_DIR}/${subject}/asl/DC

if [ -e ${rev_asl} ]
then
	# Estimate distortion corrections
	if [ ! -e ${FS_DIR}/${subject}/asl/DC/aslC0_norm_unwarp.nii.gz ]
	then
		if [ ! -d ${FS_DIR}/${subject}/asl/DC ]
		then
			mkdir ${FS_DIR}/${subject}/asl/DC
		else
			rm -rf ${FS_DIR}/${subject}/asl/DC/*
		fi
		echo "fslroi ${for_asl} ${DCDIR}/aslC0 0 1"
		fslroi ${for_asl} ${DCDIR}/aslC0 0 1
		echo "fslroi ${rev_asl} ${DCDIR}/aslC0_back 0 1"
		fslroi ${rev_asl} ${DCDIR}/aslC0_back 0 1
		
		gunzip -f ${DCDIR}/*gz

		# Shift the reverse DWI by 1 voxel AP
		# Only for Philips images, for *unknown* reason
		# Then LR-flip the image for CMTK
		matlab -nodisplay <<EOF
		cd ${DCDIR}
		V = spm_vol('aslC0_back.nii');
		Y = spm_read_vols(V);
		
		Y = circshift(Y, [0 -1 0]);
		V.fname = 'saslC0_back.nii';
		spm_write_vol(V,Y);
		
		Y = flipdim(Y, 1);
		V.fname = 'raslC0_back.nii';
		spm_write_vol(V,Y);
EOF

		# Normalize the signal
		S=`fslstats ${DCDIR}/aslC0.nii -m`
		fslmaths ${DCDIR}/aslC0.nii -div $S -mul 1000 ${DCDIR}/aslC0_norm -odt double
		
		S=`fslstats ${DCDIR}/raslC0_back.nii -m`
		fslmaths ${DCDIR}/raslC0_back.nii -div $S -mul 1000 ${DCDIR}/raslC0_back_norm -odt double
		
		# Launch CMTK
		echo "cmtk epiunwarp --smooth-sigma-max 30 --smooth-sigma-diff 0.1 --smoothness-constraint-weight 5000000 --folding-constraint-weight 100000 --iterations 50000 -x --write-jacobian-fwd ${DCDIR}/jacobian_fwd.nii ${DCDIR}/b0_norm.nii.gz ${DCDIR}/rb0_back_norm.nii.gz ${DCDIR}/b0_norm_unwarp.nii ${DCDIR}/rb0_back_norm_unwarp.nii ${DCDIR}/dfield.nrrd"
		cmtk epiunwarp --smooth-sigma-max 30 --smooth-sigma-diff 0.1 --smoothness-constraint-weight 5000000 --folding-constraint-weight 100000 --iterations 50000 -x --write-jacobian-fwd ${DCDIR}/jacobian_fwd.nii ${DCDIR}/aslC0_norm.nii.gz ${DCDIR}/raslC0_back_norm.nii.gz ${DCDIR}/aslC0_norm_unwarp.nii ${DCDIR}/raslC0_back_norm_unwarp.nii ${DCDIR}/dfield.nrrd
		
		gzip -f ${DCDIR}/*.nii
	fi
	
	# Apply distortion corrections to the whole ASL
	if [ ! -e ${FS_DIR}/${subject}/asl/asl_distcor.nii.gz ]
	then
		echo "fslsplit ${for_asl} ${DCDIR}/voltmp -t"
		fslsplit ${for_asl} ${DCDIR}/voltmp -t
		
		for I in `ls ${DCDIR} | grep voltmp`
		do
			echo "cmtk reformatx --floating ${DCDIR}/${I} --linear -o ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/b0_norm.nii.gz ${DCDIR}/dfield.nrrd"
			cmtk reformatx --floating ${DCDIR}/${I} --linear -o ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/aslC0_norm.nii.gz ${DCDIR}/dfield.nrrd
			
			echo "cmtk imagemath --in ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/jacobian_fwd.nii.gz --mul --out ${DCDIR}/${I%.nii.gz}_ucorr_jac.nii.gz"
			cmtk imagemath --in ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz ${DCDIR}/jacobian_fwd.nii.gz --mul --out ${DCDIR}/${I%.nii.gz}_ucorr_jac.nii.gz
			
			rm -f ${DCDIR}/${I%.nii.gz}_ucorr.nii.gz
		done
		
		echo "fslmerge -t ${FS_DIR}/${subject}/asl/asl_distcor.nii.gz ${DCDIR}/*ucorr_jac.nii.gz"
		fslmerge -t ${FS_DIR}/${subject}/asl/asl_distcor.nii.gz ${DCDIR}/*ucorr_jac.nii.gz
		
		rm -f ${DCDIR}/*ucorr_jac.nii.gz ${DCDIR}/voltmp*
		gzip -f ${DCDIR}/*.nii	
	fi
else
	# Rename asl.nii.gz to asl_distcor.nii.gz
	echo "mv ${for_asl} ${distcor_asl}"
	mv ${for_asl} ${distcor_asl}
fi

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
	fi
fi

################################
## Step 4. Merge and calcul mean of each type of ASL files, then do the substraction
################################

if [ ${BitRecPar} -eq 0 ]
then
	echo "fslmerge -t ${FS_DIR}/${subject}/asl/control ${FS_DIR}/${subject}/asl/RawEpi/repi_00{00..58..2}*.nii"
	fslmerge -t ${FS_DIR}/${subject}/asl/control ${FS_DIR}/${subject}/asl/RawEpi/repi_00{00..58..2}*.nii

	echo "fslmerge -t ${FS_DIR}/${subject}/asl/tag ${FS_DIR}/${subject}/asl/RawEpi/repi_00{01..59..2}*.nii"
	fslmerge -t ${FS_DIR}/${subject}/asl/tag ${FS_DIR}/${subject}/asl/RawEpi/repi_00{01..59..2}*.nii
elif [ ${BitRecPar} -eq 1 ]
then
	echo "fslmerge -t ${FS_DIR}/${subject}/asl/control ${FS_DIR}/${subject}/asl/RawEpi/repi_00{30..59}*.nii"
	fslmerge -t ${FS_DIR}/${subject}/asl/control ${FS_DIR}/${subject}/asl/RawEpi/repi_00{30..59}*.nii

	echo "fslmerge -t ${FS_DIR}/${subject}/asl/tag ${FS_DIR}/${subject}/asl/RawEpi/repi_00{00..29}*.nii"
	fslmerge -t ${FS_DIR}/${subject}/asl/tag ${FS_DIR}/${subject}/asl/RawEpi/repi_00{00..29}*.nii
fi

echo "fslmaths ${FS_DIR}/${subject}/asl/control -Tmean ${FS_DIR}/${subject}/asl/control_mean"
fslmaths ${FS_DIR}/${subject}/asl/control -Tmean ${FS_DIR}/${subject}/asl/control_mean

# Remove NaNs
echo "fslmaths ${FS_DIR}/${subject}/asl/control_mean -nan ${FS_DIR}/${subject}/asl/control_mean"
fslmaths ${FS_DIR}/${subject}/asl/control_mean -nan ${FS_DIR}/${subject}/asl/control_mean

echo "fslmaths ${FS_DIR}/${subject}/asl/tag -Tmean  ${FS_DIR}/${subject}/asl/tag_mean"
fslmaths ${FS_DIR}/${subject}/asl/tag -Tmean  ${FS_DIR}/${subject}/asl/tag_mean

# Remove NaNs
echo "fslmaths ${FS_DIR}/${subject}/asl/tag_mean -nan ${FS_DIR}/${subject}/asl/tag_mean"
fslmaths ${FS_DIR}/${subject}/asl/tag_mean -nan ${FS_DIR}/${subject}/asl/tag_mean

echo "fslmaths ${FS_DIR}/${subject}/asl/control_mean -sub ${FS_DIR}/${subject}/asl/tag_mean ${FS_DIR}/${subject}/asl/asl_map"
fslmaths ${FS_DIR}/${subject}/asl/control_mean -sub ${FS_DIR}/${subject}/asl/tag_mean ${FS_DIR}/${subject}/asl/asl_map

gunzip ${FS_DIR}/${subject}/asl/*.nii.gz

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
	CBFtemp=6000/2*0.76*0.85*0.83*1.68.*data2./data1*exp((1.525+0.036292)/1.68)*exp(14/50).*data3;

	V1.fname='${FS_DIR}/${subject}/asl/CBF.nii';
	spm_write_vol(V1,CBFtemp);
EOF

# Remove NaNs
echo "fslmaths ${FS_DIR}/${subject}/asl/CBF -nan ${FS_DIR}/${subject}/asl/CBF"
fslmaths ${FS_DIR}/${subject}/asl/CBF -nan ${FS_DIR}/${subject}/asl/CBF
rm -f ${FS_DIR}/${subject}/asl/CBF.nii
gunzip ${FS_DIR}/${subject}/asl/*.nii.gz

fi

################################
## Step 6. Reslice asl_map
################################

if [ ! -f ${FS_DIR}/${subject}/asl/rasl_map.nii ]
then
	matlab -nodisplay <<EOF
	
	disp('reslice asl_map.nii');
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
	f = spm_select('FPList', data_path, '^asl_map.*\.nii$');

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
	echo "fslmaths ${FS_DIR}/${subject}/asl/rasl_map -nan ${FS_DIR}/${subject}/asl/rasl_map"
	fslmaths ${FS_DIR}/${subject}/asl/rasl_map -nan ${FS_DIR}/${subject}/asl/rasl_map
	rm -f ${FS_DIR}/${subject}/asl/rasl_map.nii
	gunzip ${FS_DIR}/${subject}/asl/*.nii.gz
fi

################################
## Step 7. Reslice CBF map
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
	gunzip ${FS_DIR}/${subject}/asl/*.nii.gz
fi

################################
## Step 8. Correct partial volume
################################

	if [ ! -d ${FS_DIR}/${subject}/asl/pve_out ]
	then
		mkdir ${FS_DIR}/${subject}/asl/pve_out
	else
		rm -rf ${FS_DIR}/${subject}/asl/pve_out/*
	fi
	
	cp ${FS_DIR}/${subject}/asl/Structural/brain.nii ${FS_DIR}/${subject}/asl/pve_out
# 	gunzip ${FS_DIR}/${subject}/asl/rCBF.nii.gz
	cp ${FS_DIR}/${subject}/asl/rCBF.nii ${FS_DIR}/${subject}/asl/pve_out
	
	matlab -nodisplay <<EOF
	
	HOME = getenv('HOME');
	configfile = [HOME, '/SVN/matlab/pierre/pve/config_pvec'];
	
	t1_path='${FS_DIR}/${subject}/asl/pve_out/brain.nii';
	pet_path='${FS_DIR}/${subject}/asl/pve_out/rCBF.nii';
	outdir='${FS_DIR}/${subject}/asl/pve_out';
	
	V = spm_vol(t1_path);
	[Y, XYZ] = spm_read_vols(V);
	V.fname = [outdir, '/t1.img'];
	spm_write_vol(V, Y);

	V = spm_vol(pet_path);
	[Y, XYZ] = spm_read_vols(V);
	V.fname = [outdir, '/rpet.img'];
	spm_write_vol(V, Y);

	t1_path = [outdir, '/t1.img'];
	pet_path = [outdir, '/rpet.img'];
	
	disp('Segmentation T1');
	
	%% Step 1. Segment T1 using spm12 segment function
	%--------------------------------------------------------------------------
	
	%% Initialise SPM defaults
	
	spm('defaults', 'FMRI');

	spm_jobman('initcfg');
	matlabbatch={};
	
	matlabbatch{end+1}.spm.spatial.preproc.channel.vols = {[t1_path ',1']};
	matlabbatch{end}.spm.spatial.preproc.channel.biasreg = 0.0001;
	matlabbatch{end}.spm.spatial.preproc.channel.biasfwhm = 60;
	matlabbatch{end}.spm.spatial.preproc.channel.write = [0 0];
	matlabbatch{end}.spm.spatial.preproc.tissue(1).tpm = {'/home/global/matlab_toolbox/spm12b/tpm/TPM.nii,1'};
	matlabbatch{end}.spm.spatial.preproc.tissue(1).ngaus = 2;
	matlabbatch{end}.spm.spatial.preproc.tissue(1).native = [1 0];
	matlabbatch{end}.spm.spatial.preproc.tissue(1).warped = [0 0];
	matlabbatch{end}.spm.spatial.preproc.tissue(2).tpm = {'/home/global/matlab_toolbox/spm12b/tpm/TPM.nii,2'};
	matlabbatch{end}.spm.spatial.preproc.tissue(2).ngaus = 2;
	matlabbatch{end}.spm.spatial.preproc.tissue(2).native = [1 0];
	matlabbatch{end}.spm.spatial.preproc.tissue(2).warped = [0 0];
	matlabbatch{end}.spm.spatial.preproc.tissue(3).tpm = {'/home/global/matlab_toolbox/spm12b/tpm/TPM.nii,3'};
	matlabbatch{end}.spm.spatial.preproc.tissue(3).ngaus = 2;
	matlabbatch{end}.spm.spatial.preproc.tissue(3).native = [1 0];
	matlabbatch{end}.spm.spatial.preproc.tissue(3).warped = [0 0];
	matlabbatch{end}.spm.spatial.preproc.tissue(4).tpm = {'/home/global/matlab_toolbox/spm12b/tpm/TPM.nii,4'};
	matlabbatch{end}.spm.spatial.preproc.tissue(4).ngaus = 3;
	matlabbatch{end}.spm.spatial.preproc.tissue(4).native = [1 0];
	matlabbatch{end}.spm.spatial.preproc.tissue(4).warped = [0 0];
	matlabbatch{end}.spm.spatial.preproc.tissue(5).tpm = {'/home/global/matlab_toolbox/spm12b/tpm/TPM.nii,5'};
	matlabbatch{end}.spm.spatial.preproc.tissue(5).ngaus = 4;
	matlabbatch{end}.spm.spatial.preproc.tissue(5).native = [1 0];
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
	
	disp('correction volume partiel');
	
	%% Step 2. Rescale prob maps to [0 255]
	%% Rename them to _segN.img
	%% Create _GMROI.img
	%--------------------------------------------------------------------------

	Vt1   = spm_vol(t1_path);
	Vseg1 = spm_vol([outdir, '/c1t1.nii']);
	Vseg2 = spm_vol([outdir, '/c2t1.nii']);
	Vseg3 = spm_vol([outdir, '/c3t1.nii']);
	delete([outdir, '/c4t1.nii']);
	delete([outdir, '/c5t1.nii']);

	[Y1, XYZ] = spm_read_vols(Vseg1);
	[Y2, XYZ] = spm_read_vols(Vseg2);
	[Y3, XYZ] = spm_read_vols(Vseg3);

	Y1 = Y1 * 255;
	Y2 = Y2 * 255;
	Y3 = Y3 * 255;

	Y_roi = 51 * double(Y1 > 127.5) + 2 * double(Y2 > 127.5) + 3 * double(Y3 > 127.5);
	Vt1.dt = [2 0];

	Vt1.fname = [outdir, '/t1_seg1.img'];
	spm_write_vol(Vt1, Y1);
	Vt1.fname = [outdir, '/t1_seg2.img'];
	spm_write_vol(Vt1, Y2);
	Vt1.fname = [outdir, '/t1_seg3.img'];
	spm_write_vol(Vt1, Y3);

	Vt1.fname = [outdir, '/t1_GMROI.img'];
	spm_write_vol(Vt1, Y_roi);
	
	%% Step 3. Launch pve
	%--------------------------------------------------------------------------
	
	mni = round(Vt1.dim(3) / 3);
	gmROI_path = [outdir, '/t1_GMROI.img'];
	rpet_path  = [outdir, '/rpet.img'];
	cmdline = ['/home/gregory/matlab/pvelab-20100419/IBB_wrapper/pve/pve -w -s -cs ', num2str(mni), ' ', gmROI_path, ' ', rpet_path, ' ', configfile];
	fid = fopen([outdir '/cmdline.txt'], 'w');
	fprintf(fid, '%s', cmdline);
	fclose(fid);
	disp('Performing PVEc. Please wait...');
	result = system(cmdline);
	
	%% Step 4. Coregister t1_MGRousset.img onto T1
	%--------------------------------------------------------------------------
	
	file_to_copy = '${FS_DIR}/${subject}/asl/pve_out/rpet.hdr';
	file_out = '${FS_DIR}/${subject}/asl/pve_out/t1_MGRousset.hdr';
	copyfile(file_to_copy,file_out,'f');
EOF

gzip ${FS_DIR}/${subject}/asl/*.nii ${FS_DIR}/${subject}/asl/pve_out/*.nii

################################
## Step 9. Map on fsaverage surface rasl_map, rCBF and t1_MGRousset
################################

# Assign new value of SUBJECTS_DIR
SUBJECTS_DIR=${FS_DIR}

echo "mri_convert ${FS_DIR}/${subject}/asl/pve_out/t1_MGRousset.img ${FS_DIR}/${subject}/asl/asl_pve.mgz"
mri_convert ${FS_DIR}/${subject}/asl/pve_out/t1_MGRousset.img ${FS_DIR}/${subject}/asl/asl_pve.mgz

echo "mri_convert ${FS_DIR}/${subject}/asl/rasl_map.nii.gz ${FS_DIR}/${subject}/asl/rasl_map.mgz"
mri_convert ${FS_DIR}/${subject}/asl/rasl_map.nii.gz ${FS_DIR}/${subject}/asl/rasl_map.mgz

echo "mri_convert ${FS_DIR}/${subject}/asl/rCBF.nii.gz ${FS_DIR}/${subject}/asl/rCBF.mgz"
mri_convert ${FS_DIR}/${subject}/asl/rCBF.nii.gz ${FS_DIR}/${subject}/asl/rCBF.mgz

## Freesurfer_write_surf - FreeSurfer I/O function to write a surface file
matlab -nodisplay <<EOF
 
inner_surf = SurfStatReadSurf('${FS_DIR}/${subject}/surf/lh.white');
outer_surf = SurfStatReadSurf('${FS_DIR}/${subject}/surf/lh.pial');

mid_surf.coord = (inner_surf.coord + outer_surf.coord) ./ 2;
mid_surf.tri = inner_surf.tri;

freesurfer_write_surf('${FS_DIR}/${subject}/surf/lh.mid', mid_surf.coord', mid_surf.tri);

inner_surf = SurfStatReadSurf('${FS_DIR}/${subject}/surf/rh.white');
outer_surf = SurfStatReadSurf('${FS_DIR}/${subject}/surf/rh.pial');

mid_surf.coord = (inner_surf.coord + outer_surf.coord) ./ 2;
mid_surf.tri = inner_surf.tri;

freesurfer_write_surf('${FS_DIR}/${subject}/surf/rh.mid', mid_surf.coord', mid_surf.tri);
EOF

## Map on surface rasl_map, rCBF and asl_pve
for var in asl_pve rasl_map rCBF
do
	echo "mri_vol2surf --mov ${FS_DIR}/${subject}/asl/${var}.mgz --hemi lh --surf mid --o lh.${var}.w --regheader ${subject} --out_type paint --fwhm 2"
	mri_vol2surf --mov ${FS_DIR}/${subject}/asl/${var}.mgz --hemi lh --surf mid --o lh.${var}.w --regheader ${subject} --out_type paint --fwhm 2

	echo "mri_vol2surf --mov ${FS_DIR}/${subject}/asl/${var}.mgz --hemi rh --surf mid --o rh.${var}.w --regheader ${subject} --out_type paint --fwhm 2"
	mri_vol2surf --mov ${FS_DIR}/${subject}/asl/${var}.mgz --hemi rh --surf mid --o rh.${var}.w --regheader ${subject} --out_type paint --fwhm 2

	echo "mris_w_to_curv ${subject} lh ${FS_DIR}/${subject}/surf/lh.${var}.w lh.${var}"
	mris_w_to_curv ${subject} lh ${FS_DIR}/${subject}/surf/lh.${var}.w lh.${var}

	echo "mris_w_to_curv ${subject} rh ${FS_DIR}/${subject}/surf/rh.${var}.w rh.${var}"
	mris_w_to_curv ${subject} rh ${FS_DIR}/${subject}/surf/rh.${var}.w rh.${var}

	mv ${FS_DIR}/${subject}/surf/lh.${var} ${FS_DIR}/${subject}/asl/lh.${var}
	mv ${FS_DIR}/${subject}/surf/rh.${var} ${FS_DIR}/${subject}/asl/rh.${var}

	rm -f ${FS_DIR}/${subject}/surf/lh.${var}.w ${FS_DIR}/${subject}/surf/rh.${var}.w

	echo "mri_surf2surf --srcsubject ${subject} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${FS_DIR}/${subject}/asl/lh.${var} --sfmt curv --noreshape --no-cortex --tval ${FS_DIR}/${subject}/asl/lh.fsaverage.${var}.mgh --tfmt curv"
	mri_surf2surf --srcsubject ${subject} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${FS_DIR}/${subject}/asl/lh.${var} --sfmt curv --noreshape --no-cortex --tval ${FS_DIR}/${subject}/asl/lh.fsaverage.${var}.mgh --tfmt curv

	echo "mri_surf2surf --srcsubject ${subject} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${FS_DIR}/${subject}/asl/rh.${var} --sfmt curv --noreshape --no-cortex --tval ${FS_DIR}/${subject}/asl/rh.fsaverage.${var}.mgh --tfmt curv"
	mri_surf2surf --srcsubject ${subject} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${FS_DIR}/${subject}/asl/rh.${var} --sfmt curv --noreshape --no-cortex --tval ${FS_DIR}/${subject}/asl/rh.fsaverage.${var}.mgh --tfmt curv	
	
	for FWHM in 5 10 15 20
	do
		echo "mri_vol2surf --mov ${FS_DIR}/${subject}/asl/${var}.mgz --hemi lh --surf mid --o lh.${var}.w --regheader ${subject} --out_type paint --fwhm 2 --surf-fwhm ${FWHM}"
		mri_vol2surf --mov ${FS_DIR}/${subject}/asl/${var}.mgz --hemi lh --surf mid --o lh.fwhm${FWHM}.${var}.w --regheader ${subject} --out_type paint --fwhm 2 --surf-fwhm ${FWHM}

		echo "mri_vol2surf --mov ${FS_DIR}/${subject}/asl/${var}.mgz --hemi rh --surf mid --o rh.${var}.w --regheader ${subject} --out_type paint --fwhm 2 --surf-fwhm ${FWHM}"
		mri_vol2surf --mov ${FS_DIR}/${subject}/asl/${var}.mgz --hemi rh --surf mid --o rh.fwhm${FWHM}.${var}.w --regheader ${subject} --out_type paint --fwhm 2 --surf-fwhm ${FWHM}
	
		echo "mris_w_to_curv ${subject} lh ${FS_DIR}/${subject}/surf/lh.fwhm${FWHM}.${var}.w lh.fwhm${FWHM}.${var}"
		mris_w_to_curv ${subject} lh ${FS_DIR}/${subject}/surf/lh.fwhm${FWHM}.${var}.w lh.fwhm${FWHM}.${var}

		echo "mris_w_to_curv ${subject} rh ${FS_DIR}/${subject}/surf/rh.fwhm${FWHM}.${var}.w rh.fwhm${FWHM}.${var}"
		mris_w_to_curv ${subject} rh ${FS_DIR}/${subject}/surf/rh.fwhm${FWHM}.${var}.w rh.fwhm${FWHM}.${var}
	
		mv ${FS_DIR}/${subject}/surf/lh.fwhm${FWHM}.${var} ${FS_DIR}/${subject}/asl/lh.fwhm${FWHM}.${var}
		mv ${FS_DIR}/${subject}/surf/rh.fwhm${FWHM}.${var} ${FS_DIR}/${subject}/asl/rh.fwhm${FWHM}.${var}
		
		rm -f ${FS_DIR}/${subject}/surf/lh.fwhm${FWHM}.${var}.w ${FS_DIR}/${subject}/surf/rh.fwhm${FWHM}.${var}.w
		
		echo "mri_surf2surf --srcsubject ${subject} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${FS_DIR}/${subject}/asl/lh.fwhm${FWHM}.${var} --sfmt curv --noreshape --no-cortex --tval ${FS_DIR}/${subject}/asl/lh.fwhm${FWHM}.fsaverage.${var}.mgh --tfmt curv"
		mri_surf2surf --srcsubject ${subject} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${FS_DIR}/${subject}/asl/lh.fwhm${FWHM}.${var} --sfmt curv --noreshape --no-cortex --tval ${FS_DIR}/${subject}/asl/lh.fwhm${FWHM}.fsaverage.${var}.mgh --tfmt curv
		
		echo "mri_surf2surf --srcsubject ${subject} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${FS_DIR}/${subject}/asl/rh.fwhm${FWHM}.${var} --sfmt curv --noreshape --no-cortex --tval ${FS_DIR}/${subject}/asl/rh.fwhm${FWHM}.fsaverage.${var}.mgh --tfmt curv"
		mri_surf2surf --srcsubject ${subject} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${FS_DIR}/${subject}/asl/rh.fwhm${FWHM}.${var} --sfmt curv --noreshape --no-cortex --tval ${FS_DIR}/${subject}/asl/rh.fwhm${FWHM}.fsaverage.${var}.mgh --tfmt curv
	done
done