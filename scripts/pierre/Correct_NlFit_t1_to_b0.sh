#! /bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: Correct_NlFit_t1_to_b0.sh  -source <SOURCE>  -target <TARGET>  -o <output_directory>  [-keeptmp]"
	echo ""
	echo "  -source                          : Source image (i.e. moving image) (.nii or .nii.gz)"
	echo "  -target                          : Target image (i.e. fixed image) (4D .nii or .nii.gz)"
	echo "  -o                               : Output directory (example : -o /path/to/output/SubjX_to_b0 )"
	echo ""
	echo "Optional argument :"
	echo "  -keeptmp                         : Keep temporary files. Default : erase them."
	echo ""
	echo "Usage: Correct_NlFit_t1_to_b0.sh  -source <SOURCE>  -target <TARGET>  -o <output_directory>  [-keeptmp]"
	echo ""
	exit 1
fi


index=1
keeptmp=0
t1=""
dti=""
obase=""

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: Correct_NlFit_t1_to_b0.sh  -source <SOURCE>  -target <TARGET>  -o <output_directory>  [-keeptmp]"
		echo ""
		echo "  -source                          : Source image (i.e. moving image) (.nii or .nii.gz)"
		echo "  -target                          : Target image (i.e. fixed image) (4D .nii or .nii.gz)"
		echo "  -o                               : Output directory (example : -o /path/to/output/SubjX_to_b0 )"
		echo ""
		echo "Optional argument :"
		echo "  -keeptmp                         : Keep temporary files. Default : erase them."
		echo ""
		echo "Usage: Correct_NlFit_t1_to_b0.sh  -source <SOURCE>  -target <TARGET>  -o <output_directory>  [-keeptmp]"
		echo ""
		exit 1
		;;
	-source)
		index=$[$index+1]
		eval source=\${$index}
		echo "Source image : $source"
		;;
	-target)
		index=$[$index+1]
		eval target=\${$index}
		echo "Target : $target"
		;;
	-o)
		index=$[$index+1]
		eval obase=\${$index}
		echo "Output_directory : $obase"
		;;
	-keeptmp)
		keeptmp=1
		echo "Keep temp files"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: Correct_NlFit_t1_to_b0.sh  -source <SOURCE>  -target <TARGET>  -o <output_directory>  [-keeptmp]"
		echo ""
		echo "  -source                          : Source image (i.e. moving image) (.nii or .nii.gz)"
		echo "  -target                          : Target image (i.e. fixed image) (4D .nii or .nii.gz)"
		echo "  -o                               : Output directory (example : -o /path/to/output/SubjX_to_b0 )"
		echo ""
		echo "Optional argument :"
		echo "  -keeptmp                         : Keep temporary files. Default : erase them."
		echo ""
		echo "Usage: Correct_NlFit_t1_to_b0.sh  -source <SOURCE>  -target <TARGET>  -o <output_directory>  [-keeptmp]"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done


## Check mandatory arguments
if [ -z ${source} ]
then
	 echo "-source argument mandatory"
	 exit 1
fi

if [ -z ${target} ]
then
	 echo "-target argument mandatory"
	 exit 1
fi

if [ -z ${obase} ]
then
	 echo "-o argument mandatory"
	 exit 1
fi


outdir=${obase}

## Creates out dir
if [ ! -d ${outdir} ]
then
	mkdir ${outdir}
fi

## Creates temp dir
if [ ! -d ${outdir}/temp_nlfit ]
then
	mkdir ${outdir}/temp_nlfit
fi
tempdir=${outdir}/temp_nlfit


## Gunzip .gz
if [ -n "`echo $source | grep .gz`" ]
then
	gunzip ${source}
	source=${source%.gz}
	cp ${source} ${tempdir}/source.nii
	source_base=`basename ${source%.nii}`
	gzip ${source}
else
	cp ${source} ${tempdir}/source.nii
	source_base=`basename ${source%.nii}`
fi

if [ -n "`echo $target | grep .gz`" ]
then
	gunzip $target
	target=${target%.gz}
	cp ${target} ${tempdir}/target.nii
	target_base=`basename ${target%.nii}`
	gzip ${target}
else
	cp ${target} ${tempdir}/target.nii
	target_base=`basename ${target%.nii}`
fi

sourcet=${tempdir}/source.nii
targett=${tempdir}/target.nii


# Register target to tal space
fslroi ${targett} ${tempdir}/b0 0 1
gunzip ${tempdir}/b0.nii.gz
nii2mnc ${tempdir}/b0.nii ${tempdir}/b0.mnc
echo "mritotal ${tempdir}/b0.mnc ${tempdir}/b0_to_tal.xfm -modeldir /usr/local/bic/share/mni-models/ -model icbm_avg_152_t2_tal_lin"
mritotal ${tempdir}/b0.mnc ${tempdir}/b0_to_tal.xfm -modeldir /usr/local/bic/share/mni-models/ -model icbm_avg_152_t2_tal_lin

echo "mincresample -like ${Soft_dir}/freesurfer/mni/share/mni_autoreg/average_305.mnc -transformation ${tempdir}/b0_to_tal.xfm ${tempdir}/b0.mnc ${tempdir}/b0_to_tal.mnc"
mincresample -like ${Soft_dir}/freesurfer/mni/share/mni_autoreg/average_305.mnc -transformation ${tempdir}/b0_to_tal.xfm ${tempdir}/b0.mnc ${tempdir}/b0_to_tal.mnc

# Convert to nii
matlab -nodisplay <<EOF
% Load Matlab Path
cd ${HOME}
p = pathdef;
addpath(p);
cd ${tempdir}
 
% Do the Job
matlabbatch{1}.spm.util.minc.data = {'${tempdir}/b0_to_tal.mnc'};
matlabbatch{1}.spm.util.minc.opts.dtype = 4;
matlabbatch{1}.spm.util.minc.opts.ext = 'nii';
 
inputs = cell(0, 1);
spm('defaults', 'PET');
spm_jobman('serial', matlabbatch, '', inputs{:});
EOF


# Run SPM segmentation
echo "----------------------------------------"
echo "Run SPM segmentation..."
matlab -nodisplay <<EOF >> ${outdir}/NlFit_t1_to_b0.log
% Load Matlab Path
cd ${HOME}
p = pathdef;
addpath(p);
cd ${tempdir}

% Find spm templates
t = which('spm');
t = dirname(t);

% Do the Job
matlabbatch{1}.spm.spatial.preproc.data = {
                                           '${sourcet},1'
                                           };
matlabbatch{1}.spm.spatial.preproc.output.GM = [0 0 1];
matlabbatch{1}.spm.spatial.preproc.output.WM = [0 0 1];
matlabbatch{1}.spm.spatial.preproc.output.CSF = [0 0 1];
matlabbatch{1}.spm.spatial.preproc.output.biascor = 1;
matlabbatch{1}.spm.spatial.preproc.output.cleanup = 0;
matlabbatch{1}.spm.spatial.preproc.opts.tpm = {
                                               [t '/tpm/grey.nii']
                                               [t '/tpm/white.nii']
                                               [t '/tpm/csf.nii']
                                               };
matlabbatch{1}.spm.spatial.preproc.opts.ngaus = [2
                                                 2
                                                 2
                                                 4];
matlabbatch{1}.spm.spatial.preproc.opts.regtype = 'mni';
matlabbatch{1}.spm.spatial.preproc.opts.warpreg = 1;
matlabbatch{1}.spm.spatial.preproc.opts.warpco = 25;
matlabbatch{1}.spm.spatial.preproc.opts.biasreg = 0.0001;
matlabbatch{1}.spm.spatial.preproc.opts.biasfwhm = 60;
matlabbatch{1}.spm.spatial.preproc.opts.samp = 3;
matlabbatch{1}.spm.spatial.preproc.opts.msk = {''};

inputs = cell(0, 1);
spm('defaults', 'PET');
spm_jobman('serial', matlabbatch, '', inputs{:});
EOF


matlab -nodisplay <<EOF >> ${outdir}/NlFit_t1_to_b0.log
% Load Matlab Path
cd ${HOME}
p = pathdef;
addpath(p);
cd ${tempdir}

% Find spm templates
t = which('spm');
t = dirname(t);
matlabbatch{1}.spm.spatial.preproc.data = {
                                           'b0_to_tal.nii,1'
                                           };
matlabbatch{1}.spm.spatial.preproc.output.GM = [0 0 1];
matlabbatch{1}.spm.spatial.preproc.output.WM = [0 0 1];
matlabbatch{1}.spm.spatial.preproc.output.CSF = [0 0 1];
matlabbatch{1}.spm.spatial.preproc.output.biascor = 1;
matlabbatch{1}.spm.spatial.preproc.output.cleanup = 0;
matlabbatch{1}.spm.spatial.preproc.opts.tpm = {
                                               [t '/tpm/grey.nii']
                                               [t '/tpm/white.nii']
                                               [t '/tpm/csf.nii']
                                               };
matlabbatch{1}.spm.spatial.preproc.opts.ngaus = [2
                                                 2
                                                 2
                                                 4];
matlabbatch{1}.spm.spatial.preproc.opts.regtype = '';
matlabbatch{1}.spm.spatial.preproc.opts.warpreg = 1;
matlabbatch{1}.spm.spatial.preproc.opts.warpco = 25;
matlabbatch{1}.spm.spatial.preproc.opts.biasreg = 0.0001;
matlabbatch{1}.spm.spatial.preproc.opts.biasfwhm = 60;
matlabbatch{1}.spm.spatial.preproc.opts.samp = 3;
matlabbatch{1}.spm.spatial.preproc.opts.msk = {''};

inputs = cell(0, 1);
spm('defaults', 'PET');
spm_jobman('serial', matlabbatch, '', inputs{:});

EOF

# Resample target CSF back to native space
nii2mnc ${tempdir}/c3b0_to_tal.nii ${tempdir}/c3b0_to_tal.mnc
xfminvert ${tempdir}/b0_to_tal.xfm ${tempdir}/b0_to_tal_inv.xfm
"mincresample -like ${tempdir}/b0.mnc -transformation ${tempdir}/b0_to_tal_inv.xfm ${tempdir}/c3b0_to_tal.mnc ${tempdir}/c3target.mnc"
mincresample -like ${tempdir}/b0.mnc -transformation ${tempdir}/b0_to_tal_inv.xfm ${tempdir}/c3b0_to_tal.mnc ${tempdir}/c3target.mnc


# Convert Files
echo "----------------------------------------"
echo "Convert files"
 
csfsource="c3source"
csftarget="c3target"

echo "nii2mnc ${tempdir}/${csfsource}.nii ${outdir}/${csfsource}.mnc -short"
nii2mnc ${tempdir}/${csfsource}.nii ${outdir}/${csfsource}.mnc -short
# echo "nii2mnc ${tempdir}/${csftarget}.nii ${outdir}/${csftarget}.mnc -short"
# nii2mnc ${tempdir}/${csftarget}.nii ${outdir}/${csftarget}.mnc -short
cp ${tempdir}/c3target.mnc ${outdir}/${csftarget}.mnc
echo "nii2mnc ${sourcet} ${outdir}/source.mnc -short"
nii2mnc ${sourcet} ${outdir}/source.mnc -short


weight=1
stiffness=1
similarity=0.3

echo "mincblur -fwhm 16 ${outdir}/${csftarget}.mnc ${outdir}/${csftarget}_16"
mincblur -fwhm 16 ${outdir}/${csftarget}.mnc ${outdir}/${csftarget}_16
echo "mincblur -fwhm 16 ${outdir}/${csfsource}.mnc ${outdir}/${csfsource}_16"
mincblur -fwhm 16 ${outdir}/${csfsource}.mnc ${outdir}/${csfsource}_16
echo "mincblur -fwhm 8 ${outdir}/${csftarget}.mnc ${outdir}/${csftarget}_8"
mincblur -fwhm 8 ${outdir}/${csftarget}.mnc ${outdir}/${csftarget}_8
echo "mincblur -fwhm 8 ${outdir}/${csfsource}.mnc ${outdir}/${csfsource}_8"
mincblur -fwhm 8 ${outdir}/${csfsource}.mnc ${outdir}/${csfsource}_8
echo "mincblur -fwhm 4 ${outdir}/${csftarget}.mnc ${outdir}/${csftarget}_4"
mincblur -fwhm 4 ${outdir}/${csftarget}.mnc ${outdir}/${csftarget}_4
echo "mincblur -fwhm 4 ${outdir}/${csfsource}.mnc ${outdir}/${csfsource}_4"
mincblur -fwhm 4 ${outdir}/${csfsource}.mnc ${outdir}/${csfsource}_4
echo "mincblur -fwhm 2 ${outdir}/${csftarget}.mnc ${outdir}/${csftarget}_2"
mincblur -fwhm 2 ${outdir}/${csftarget}.mnc ${outdir}/${csftarget}_2
echo "mincblur -fwhm 2 ${outdir}/${csfsource}.mnc ${outdir}/${csfsource}_2"
mincblur -fwhm 2 ${outdir}/${csfsource}.mnc ${outdir}/${csfsource}_2

# Linear registration
echo "mritoself ${outdir}/${csfsource}.mnc ${outdir}/${csftarget}.mnc ${outdir}/source_to_target_lin.xfm -clobber"
mritoself ${outdir}/${csfsource}.mnc ${outdir}/${csftarget}.mnc ${outdir}/source_to_target_lin.xfm -clobber

# Nonlinear registration
echo "minctracc -iterations 30 -step 16 16 16 -sub_lattice 6 -lattice_diam 48 48 48 -nonlinear corrcoeff -weight ${weight} -stiffness ${stiffness} -similarity ${similarity} -transformation ${outdir}/source_to_target_lin.xfm ${outdir}/${csfsource}_16_blur.mnc ${outdir}/${csftarget}_16_blur.mnc ${outdir}/source_to_target_16_blur_nlin.xfm -clobber"
minctracc -iterations 30 -step 16 16 16 -sub_lattice 6 -lattice_diam 48 48 48 -nonlinear corrcoeff -weight ${weight} -stiffness ${stiffness} -similarity ${similarity} -transformation ${outdir}/source_to_target_lin.xfm ${outdir}/${csfsource}_16_blur.mnc ${outdir}/${csftarget}_16_blur.mnc ${outdir}/source_to_target_16_blur_nlin.xfm -clobber

echo "minctracc -iterations 30 -step 8 8 8 -sub_lattice 6 -lattice_diam 24 24 24 -nonlinear corrcoeff -weight ${weight} -stiffness ${stiffness} -similarity ${similarity} -transformation ${outdir}/source_to_target_16_blur_nlin.xfm ${outdir}/${csfsource}_8_blur.mnc ${outdir}/${csftarget}_8_blur.mnc ${outdir}/source_to_target_8_blur_nlin.xfm -clobber"
minctracc -iterations 30 -step 8 8 8 -sub_lattice 6 -lattice_diam 24 24 24 -nonlinear corrcoeff -weight ${weight} -stiffness ${stiffness} -similarity ${similarity} -transformation ${outdir}/source_to_target_16_blur_nlin.xfm ${outdir}/${csfsource}_8_blur.mnc ${outdir}/${csftarget}_8_blur.mnc ${outdir}/source_to_target_8_blur_nlin.xfm -clobber
 
echo "minctracc -iterations 30 -step 4 4 4 -sub_lattice 6 -lattice_diam 12 12 12 -nonlinear corrcoeff -weight ${weight} -stiffness ${stiffness} -similarity ${similarity} -transformation ${outdir}/source_to_target_8_blur_nlin.xfm ${outdir}/${csfsource}_4_blur.mnc ${outdir}/${csftarget}_4_blur.mnc ${outdir}/source_to_target_4_blur_nlin.xfm -clobber"
minctracc -iterations 30 -step 4 4 4 -sub_lattice 6 -lattice_diam 12 12 12 -nonlinear corrcoeff -weight ${weight} -stiffness ${stiffness} -similarity ${similarity} -transformation ${outdir}/source_to_target_8_blur_nlin.xfm ${outdir}/${csfsource}_4_blur.mnc ${outdir}/${csftarget}_4_blur.mnc ${outdir}/source_to_target_4_blur_nlin.xfm -clobber
 
echo "minctracc -iterations 10 -step 2 2 2 -sub_lattice 6 -lattice_diam 6 6 6 -nonlinear corrcoeff -weight ${weight} -stiffness ${stiffness} -similarity ${similarity} -transformation ${outdir}/source_to_target_4_blur_nlin.xfm ${outdir}/${csfsource}_2_blur.mnc ${outdir}/${csftarget}_2_blur.mnc ${outdir}/source_to_target_nlin.xfm -clobber"
minctracc -iterations 10 -step 2 2 2 -sub_lattice 6 -lattice_diam 6 6 6 -nonlinear corrcoeff -weight ${weight} -stiffness ${stiffness} -similarity ${similarity} -transformation ${outdir}/source_to_target_4_blur_nlin.xfm ${outdir}/${csfsource}_2_blur.mnc ${outdir}/${csftarget}_2_blur.mnc ${outdir}/source_to_target_nlin.xfm -clobber
 
# Apply nl transform
echo "mincresample -like ${outdir}/${csftarget}.mnc -transformation ${outdir}/source_to_target_nlin.xfm ${outdir}/source.mnc ${outdir}/source_to_target_nlin.mnc -clobber"
mincresample -like ${outdir}/${csftarget}.mnc -transformation ${outdir}/source_to_target_nlin.xfm ${outdir}/source.mnc ${outdir}/source_to_target_nlin.mnc -clobber
 
# Convert to nii
matlab -nodisplay <<EOF
% Load Matlab Path
cd ${HOME}
p = pathdef;
addpath(p);
cd ${outdir}
 
% Do the Job
matlabbatch{1}.spm.util.minc.data = {'${outdir}/source_to_target_nlin.mnc'};
matlabbatch{1}.spm.util.minc.opts.dtype = 4;
matlabbatch{1}.spm.util.minc.opts.ext = 'nii';
 
inputs = cell(0, 1);
spm('defaults', 'PET');
spm_jobman('serial', matlabbatch, '', inputs{:});
EOF
 
# Remove temp files
if [ ${keeptmp} -eq 0 ]
then
	rm -rf ${outdir}/source_to_target_8_blur_nlin.xfm ${outdir}/source_to_target_4_blur_nlin.xfm ${outdir}/${csftarget}_8_blur.mnc ${outdir}/${csftarget}_4_blur.mnc ${outdir}/${csftarget}_2_blur.mnc ${outdir}/${csfsource}_8_blur.mnc ${outdir}/${csfsource}_4_blur.mnc ${outdir}/${csfsource}_2_blur.mnc ${tempdir} ${outdir}/${csfsource}.mnc ${outdir}/${csftarget}.mnc ${outdir}/source_to_target_4_blur_nlin* ${outdir}/source_to_target_8_blur_nlin* ${outdir}/source_to_target_lin.xfm ${outdir}/${csfsource}_16_blur.mnc ${outdir}/${csftarget}_16_blur.mnc ${outdir}/source_to_target_16_blur_nlin.xfm
fi
