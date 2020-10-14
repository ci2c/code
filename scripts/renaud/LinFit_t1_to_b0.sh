#! /bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: LinFit_t1_to_b0.sh  -source <SOURCE>  -target <TARGET>  -o <output_directory>  [-keeptmp -no16 -newsegment]"
	echo ""
	echo "  -source                          : Source image (i.e. moving image) (.nii or .nii.gz)"
	echo "  -target                          : Target image (i.e. fixed image) (4D .nii or .nii.gz)"
	echo "  -o                               : Output directory (example : -o /path/to/output/SubjX_to_b0 )"
	echo ""
	echo "Optional argument :"
	echo "  -keeptmp                         : Keep temporary files. Default : erase them."
	echo "  -no16                            : Does not perform 16-mm fwhm blur. Default : does it."
	echo "  -newsegment                      : Uses SPM new segment instead of standard segmentation tool. Default : standard"
	echo ""
	echo "Usage: LinFit_t1_to_b0.sh  -source <SOURCE>  -target <TARGET>  -o <output_directory>  [-keeptmp -no16 -newsegment]"
	echo "Renaud Lopes, CHRU Lille, May 15, 2012"
	echo ""
	exit 1
fi


index=1
keeptmp=0
t1=""
dti=""
obase=""
do16=1
newsegment=0

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: LinFit_t1_to_b0.sh  -source <SOURCE>  -target <TARGET>  -o <output_directory>  [-keeptmp -no16 -newsegment]"
		echo ""
		echo "  -source                          : Source image (i.e. moving image) (.nii or .nii.gz)"
		echo "  -target                          : Target image (i.e. fixed image) (4D .nii or .nii.gz)"
		echo "  -o                               : Output directory (example : -o /path/to/output/SubjX_to_b0 )"
		echo ""
		echo "Optional argument :"
		echo "  -keeptmp                         : Keep temporary files. Default : erase them."
		echo "  -no16                            : Does not perform 16-mm fwhm blur. Default : does it."
		echo "  -newsegment                      : Uses SPM new segment instead of standard segmentation tool. Default : standard"
		echo ""
		echo "Usage: LinFit_t1_to_b0.sh  -source <SOURCE>  -target <TARGET>  -o <output_directory>  [-keeptmp -no16 -newsegment]"
		echo "Renaud Lopes, CHRU Lille, May 15, 2012"
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
	-no16)
		do16=0
		echo "No 16-mm fwhm blur"
		;;
	-newsegment)
		newsegment=1
		echo "Uses new segment tool"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: LinFit_t1_to_b0.sh  -source <SOURCE>  -target <TARGET>  -o <output_directory>  [-keeptmp -no16 -newsegment]"
		echo ""
		echo "  -source                          : Source image (i.e. moving image) (.nii or .nii.gz)"
		echo "  -target                          : Target image (i.e. fixed image) (4D .nii or .nii.gz)"
		echo "  -o                               : Output directory (example : -o /path/to/output/SubjX_to_b0 )"
		echo ""
		echo "Optional argument :"
		echo "  -keeptmp                         : Keep temporary files. Default : erase them."
		echo "  -no16                            : Does not perform 16-mm fwhm blur. Default : does it."
		echo "  -newsegment                      : Uses SPM new segment instead of standard segmentation tool. Default : standard"
		echo ""
		echo "Usage: LinFit_t1_to_b0.sh  -source <SOURCE>  -target <TARGET>  -o <output_directory>  [-keeptmp -no16 -newsegment]"
		echo "Renaud Lopes, CHRU Lille, May 15, 2012"
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
if [ ! -d ${outdir}/temp_linfit ]
then
	mkdir ${outdir}/temp_linfit
fi
tempdir=${outdir}/temp_linfit


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
# Run SPM segmentation
echo "----------------------------------------"
echo "Run SPM segmentation..."
matlab -nodisplay <<EOF >> ${outdir}/LinFit_t1_to_b0.log
% Load Matlab Path
cd ${HOME}
p = pathdef;
addpath(p);
cd ${tempdir}

% Find spm templates
t = which('spm');
t = dirname(t);

if ${newsegment} == 0

% Do the Job
matlabbatch{1}.spm.spatial.preproc.data = {
                                           '${sourcet},1'
                                           '${targett},1'
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

else

matlabbatch{1}.spm.tools.preproc8.channel.vols = {
                                                  '${sourcet},1'
                                                  '${targett},1'
                                                  };
matlabbatch{1}.spm.tools.preproc8.channel.biasreg = 0.0001;
matlabbatch{1}.spm.tools.preproc8.channel.biasfwhm = 60;
matlabbatch{1}.spm.tools.preproc8.channel.write = [0 0];
matlabbatch{1}.spm.tools.preproc8.tissue(1).tpm = {[t '/toolbox/Seg/TPM.nii,1']};
matlabbatch{1}.spm.tools.preproc8.tissue(1).ngaus = 2;
matlabbatch{1}.spm.tools.preproc8.tissue(1).native = [1 0];
matlabbatch{1}.spm.tools.preproc8.tissue(1).warped = [0 0];
matlabbatch{1}.spm.tools.preproc8.tissue(2).tpm = {[t '/toolbox/Seg/TPM.nii,2']};
matlabbatch{1}.spm.tools.preproc8.tissue(2).ngaus = 2;
matlabbatch{1}.spm.tools.preproc8.tissue(2).native = [1 0];
matlabbatch{1}.spm.tools.preproc8.tissue(2).warped = [0 0];
matlabbatch{1}.spm.tools.preproc8.tissue(3).tpm = {[t '/toolbox/Seg/TPM.nii,3']};
matlabbatch{1}.spm.tools.preproc8.tissue(3).ngaus = 2;
matlabbatch{1}.spm.tools.preproc8.tissue(3).native = [1 0];
matlabbatch{1}.spm.tools.preproc8.tissue(3).warped = [0 0];
matlabbatch{1}.spm.tools.preproc8.tissue(4).tpm = {[t '/toolbox/Seg/TPM.nii,4']};
matlabbatch{1}.spm.tools.preproc8.tissue(4).ngaus = 3;
matlabbatch{1}.spm.tools.preproc8.tissue(4).native = [1 0];
matlabbatch{1}.spm.tools.preproc8.tissue(4).warped = [0 0];
matlabbatch{1}.spm.tools.preproc8.tissue(5).tpm = {[t '/toolbox/Seg/TPM.nii,5']};
matlabbatch{1}.spm.tools.preproc8.tissue(5).ngaus = 4;
matlabbatch{1}.spm.tools.preproc8.tissue(5).native = [1 0];
matlabbatch{1}.spm.tools.preproc8.tissue(5).warped = [0 0];
matlabbatch{1}.spm.tools.preproc8.tissue(6).tpm = {[t '/toolbox/Seg/TPM.nii,6']};
matlabbatch{1}.spm.tools.preproc8.tissue(6).ngaus = 2;
matlabbatch{1}.spm.tools.preproc8.tissue(6).native = [0 0];
matlabbatch{1}.spm.tools.preproc8.tissue(6).warped = [0 0];
matlabbatch{1}.spm.tools.preproc8.warp.reg = 4;
matlabbatch{1}.spm.tools.preproc8.warp.affreg = 'mni';
matlabbatch{1}.spm.tools.preproc8.warp.samp = 3;
matlabbatch{1}.spm.tools.preproc8.warp.write = [0 0];

inputs = cell(0, 1);
spm('defaults', 'PET');
spm_jobman('serial', matlabbatch, '', inputs{:});

end

EOF

# Convert Files
echo "----------------------------------------"
echo "Convert files"
 
csfsource="c3source"
csftarget="c3target"

echo "nii2mnc ${tempdir}/${csfsource}.nii ${outdir}/${csfsource}.mnc -short"
nii2mnc ${tempdir}/${csfsource}.nii ${outdir}/${csfsource}.mnc -short
echo "nii2mnc ${tempdir}/${csftarget}.nii ${outdir}/${csftarget}.mnc -short"
nii2mnc ${tempdir}/${csftarget}.nii ${outdir}/${csftarget}.mnc -short
echo "nii2mnc ${sourcet} ${outdir}/source.mnc -short"
nii2mnc ${sourcet} ${outdir}/source.mnc -short


# Linear registration
echo "mritoself ${outdir}/${csfsource}.mnc ${outdir}/${csftarget}.mnc ${outdir}/source_to_target_lin.xfm -clobber"
mritoself ${outdir}/${csfsource}.mnc ${outdir}/${csftarget}.mnc ${outdir}/source_to_target_lin.xfm -clobber
 
# Apply linear transform
echo "mincresample -like ${outdir}/${csftarget}.mnc -transformation ${outdir}/source_to_target_lin.xfm ${outdir}/source.mnc ${outdir}/source_to_target_lin.mnc -clobber"
mincresample -like ${outdir}/${csftarget}.mnc -transformation ${outdir}/source_to_target_lin.xfm ${outdir}/source.mnc ${outdir}/source_to_target_lin.mnc -clobber
 
# Convert to nii
matlab -nodisplay <<EOF
% Load Matlab Path
cd ${HOME}
p = pathdef;
addpath(p);
cd ${outdir}
 
% Do the Job
matlabbatch{1}.spm.util.minc.data = {'${outdir}/source_to_target_lin.mnc'};
matlabbatch{1}.spm.util.minc.opts.dtype = 4;
matlabbatch{1}.spm.util.minc.opts.ext = 'nii';
 
inputs = cell(0, 1);
spm('defaults', 'PET');
spm_jobman('serial', matlabbatch, '', inputs{:});
EOF
 
# Remove temp files
if [ ${keeptmp} -eq 0 ]
then
	rm -rf ${tempdir} ${outdir}/${csfsource}.mnc ${outdir}/${csftarget}.mnc
fi
