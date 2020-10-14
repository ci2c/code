#! /bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: NlFit_2images.sh  -source <SOURCE>  -target <TARGET>  -o <output_directory>  [-keeptmp  -no16  -nolin -fine]"
	echo ""
	echo "  -source                          : Source image (i.e. moving image) (.nii or .nii.gz)"
	echo "  -target                          : Target image (i.e. fixed image) (.nii or .nii.gz)"
	echo "  -o                               : Output directory (example : -o /path/to/output/SubjX_to_b0 )"
	echo ""
	echo "Optional argument :"
	echo "  -keeptmp                         : Keep temporary files. Default : erase them."
	echo "  -no16                            : Skip 16 mm fwhm step. Defaut : don't skip"
	echo "  -nolin                           : No linear co-registration"
	echo "  -fine                            : Proceed to fine co-registration, an additional step without bluring"
	echo ""
	echo "Usage: NlFit_2images.sh  -source <SOURCE>  -target <TARGET>  -o <output_directory>  [-keeptmp  -no16  -nolin -fine]"
	echo ""
	exit 1
fi


index=1
keeptmp=0
nolin=0
t1=""
dti=""
obase=""
no16=0
fine=0

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: NlFit_2images.sh  -source <SOURCE>  -target <TARGET>  -o <output_directory>  [-keeptmp  -no16  -nolin -fine]"
		echo ""
		echo "  -source                          : Source image (i.e. moving image) (.nii or .nii.gz)"
		echo "  -target                          : Target image (i.e. fixed image) (.nii or .nii.gz)"
		echo "  -o                               : Output directory (example : -o /path/to/output/SubjX_to_b0 )"
		echo ""
		echo "Optional argument :"
		echo "  -keeptmp                         : Keep temporary files. Default : erase them."
		echo "  -no16                            : Skip 16 mm fwhm step. Defaut : don't skip"
		echo "  -nolin                           : No linear co-registration"
		echo "  -fine                            : Proceed to fine co-registration, an additional step without bluring"
		echo ""
		echo "Usage: NlFit_2images.sh  -source <SOURCE>  -target <TARGET>  -o <output_directory>  [-keeptmp  -no16  -nolin -fine]"
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
	-nolin)
		nolin=1
		echo "No linear co-registration"
		;;
	-no16)
		no16=1
		echo "Skip 16-mm fwhm"
		;;
	-fine)
		fine=1
		echo "Fine registration"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: NlFit_2images.sh  -source <SOURCE>  -target <TARGET>  -o <output_directory>  [-keeptmp  -no16  -nolin -fine]"
		echo ""
		echo "  -source                          : Source image (i.e. moving image) (.nii or .nii.gz)"
		echo "  -target                          : Target image (i.e. fixed image) (.nii or .nii.gz)"
		echo "  -o                               : Output directory (example : -o /path/to/output/SubjX_to_b0 )"
		echo ""
		echo "Optional argument :"
		echo "  -keeptmp                         : Keep temporary files. Default : erase them."
		echo "  -no16                            : Skip 16 mm fwhm step. Defaut : don't skip"
		echo "  -nolin                           : No linear co-registration"
		echo "  -fine                            : Proceed to fine co-registration, an additional step without bluring"
		echo ""
		echo "Usage: NlFit_2images.sh  -source <SOURCE>  -target <TARGET>  -o <output_directory>  [-keeptmp  -no16  -nolin -fine]"
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

# Convert Files
echo "----------------------------------------"
echo "Convert files"
 
csfsource="source"
csftarget="target"

echo "/usr/local/bic/bin/nii2mnc ${tempdir}/${csfsource}.nii ${outdir}/${csfsource}.mnc -short"
/usr/local/bic/bin/nii2mnc ${tempdir}/${csfsource}.nii ${outdir}/${csfsource}.mnc
echo "/usr/local/bic/bin/nii2mnc ${tempdir}/${csftarget}.nii ${outdir}/${csftarget}.mnc -short"
/usr/local/bic/bin/nii2mnc ${tempdir}/${csftarget}.nii ${outdir}/${csftarget}.mnc


weight=1
stiffness=1
similarity=0.3

if [ ${no16} -eq 0 ]
then
	echo "/usr/local/bic/bin/mincblur -fwhm 16 ${outdir}/${csftarget}.mnc ${outdir}/${csftarget}_16"
	/usr/local/bic/bin/mincblur -fwhm 16 ${outdir}/${csftarget}.mnc ${outdir}/${csftarget}_16
	echo "/usr/local/bic/bin/mincblur -fwhm 16 ${outdir}/${csfsource}.mnc ${outdir}/${csfsource}_16"
	/usr/local/bic/bin/mincblur -fwhm 16 ${outdir}/${csfsource}.mnc ${outdir}/${csfsource}_16
fi
echo "/usr/local/bic/bin/mincblur -fwhm 8 ${outdir}/${csftarget}.mnc ${outdir}/${csftarget}_8"
/usr/local/bic/bin/mincblur -fwhm 8 ${outdir}/${csftarget}.mnc ${outdir}/${csftarget}_8
echo "/usr/local/bic/bin/mincblur -fwhm 8 ${outdir}/${csfsource}.mnc ${outdir}/${csfsource}_8"
/usr/local/bic/bin/mincblur -fwhm 8 ${outdir}/${csfsource}.mnc ${outdir}/${csfsource}_8
echo "/usr/local/bic/bin/mincblur -fwhm 4 ${outdir}/${csftarget}.mnc ${outdir}/${csftarget}_4"
/usr/local/bic/bin/mincblur -fwhm 4 ${outdir}/${csftarget}.mnc ${outdir}/${csftarget}_4
echo "/usr/local/bic/bin/mincblur -fwhm 4 ${outdir}/${csfsource}.mnc ${outdir}/${csfsource}_4"
/usr/local/bic/bin/mincblur -fwhm 4 ${outdir}/${csfsource}.mnc ${outdir}/${csfsource}_4
echo "/usr/local/bic/bin/mincblur -fwhm 2 ${outdir}/${csftarget}.mnc ${outdir}/${csftarget}_2"
/usr/local/bic/bin/mincblur -fwhm 2 ${outdir}/${csftarget}.mnc ${outdir}/${csftarget}_2
echo "/usr/local/bic/bin/mincblur -fwhm 2 ${outdir}/${csfsource}.mnc ${outdir}/${csfsource}_2"
/usr/local/bic/bin/mincblur -fwhm 2 ${outdir}/${csfsource}.mnc ${outdir}/${csfsource}_2

# Linear registration
if [ ${nolin} -eq 0 ]
then
	echo "/usr/local/bic/bin/mritoself ${outdir}/${csfsource}.mnc ${outdir}/${csftarget}.mnc ${outdir}/source_to_target_lin.xfm -clobber"
	/usr/local/bic/bin/mritoself ${outdir}/${csfsource}.mnc ${outdir}/${csftarget}.mnc ${outdir}/source_to_target_lin.xfm -clobber
else
	echo "MNI Transform File" > ${outdir}/source_to_target_lin.xfm
	echo "%" >> ${outdir}/source_to_target_lin.xfm
	echo "%" >> ${outdir}/source_to_target_lin.xfm
	echo "" >> ${outdir}/source_to_target_lin.xfm
	echo "Transform_Type = Linear;" >> ${outdir}/source_to_target_lin.xfm
	echo "Linear_Transform =" >> ${outdir}/source_to_target_lin.xfm
	echo " 1.0 0.0 0.0 0.0" >> ${outdir}/source_to_target_lin.xfm
	echo " 0.0 1.0 0.0 0.0" >> ${outdir}/source_to_target_lin.xfm
	echo " 0.0 0.0 1.0 0.0;" >> ${outdir}/source_to_target_lin.xfm
fi

# Nonlinear registration
if [ ${no16} -eq 0 ]
then
	echo "/usr/local/bic/bin/minctracc -iterations 30 -step 16 16 16 -sub_lattice 6 -lattice_diam 48 48 48 -nonlinear corrcoeff -weight ${weight} -stiffness ${stiffness} -similarity ${similarity} -transformation ${outdir}/source_to_target_lin.xfm ${outdir}/${csfsource}_16_blur.mnc ${outdir}/${csftarget}_16_blur.mnc ${outdir}/source_to_target_16_blur_nlin.xfm -clobber"
	/usr/local/bic/bin/minctracc -iterations 30 -step 16 16 16 -sub_lattice 6 -lattice_diam 48 48 48 -nonlinear corrcoeff -weight ${weight} -stiffness ${stiffness} -similarity ${similarity} -transformation ${outdir}/source_to_target_lin.xfm ${outdir}/${csfsource}_16_blur.mnc ${outdir}/${csftarget}_16_blur.mnc ${outdir}/source_to_target_16_blur_nlin.xfm -clobber

	echo "/usr/local/bic/bin/minctracc -iterations 30 -step 8 8 8 -sub_lattice 6 -lattice_diam 24 24 24 -nonlinear corrcoeff -weight ${weight} -stiffness ${stiffness} -similarity ${similarity} -transformation ${outdir}/source_to_target_16_blur_nlin.xfm ${outdir}/${csfsource}_8_blur.mnc ${outdir}/${csftarget}_8_blur.mnc ${outdir}/source_to_target_8_blur_nlin.xfm -clobber"
	/usr/local/bic/bin/minctracc -iterations 30 -step 8 8 8 -sub_lattice 6 -lattice_diam 24 24 24 -nonlinear corrcoeff -weight ${weight} -stiffness ${stiffness} -similarity ${similarity} -transformation ${outdir}/source_to_target_16_blur_nlin.xfm ${outdir}/${csfsource}_8_blur.mnc ${outdir}/${csftarget}_8_blur.mnc ${outdir}/source_to_target_8_blur_nlin.xfm -clobber
else
	echo "/usr/local/bic/bin/minctracc -iterations 30 -step 8 8 8 -sub_lattice 6 -lattice_diam 24 24 24 -nonlinear corrcoeff -weight ${weight} -stiffness ${stiffness} -similarity ${similarity} -transformation ${outdir}/source_to_target_lin.xfm ${outdir}/${csfsource}_8_blur.mnc ${outdir}/${csftarget}_8_blur.mnc ${outdir}/source_to_target_8_blur_nlin.xfm -clobber"
	/usr/local/bic/bin/minctracc -iterations 30 -step 8 8 8 -sub_lattice 6 -lattice_diam 24 24 24 -nonlinear corrcoeff -weight ${weight} -stiffness ${stiffness} -similarity ${similarity} -transformation ${outdir}/source_to_target_lin.xfm ${outdir}/${csfsource}_8_blur.mnc ${outdir}/${csftarget}_8_blur.mnc ${outdir}/source_to_target_8_blur_nlin.xfm -clobber
fi
 
echo "/usr/local/bic/bin/minctracc -iterations 30 -step 4 4 4 -sub_lattice 6 -lattice_diam 12 12 12 -nonlinear corrcoeff -weight ${weight} -stiffness ${stiffness} -similarity ${similarity} -transformation ${outdir}/source_to_target_8_blur_nlin.xfm ${outdir}/${csfsource}_4_blur.mnc ${outdir}/${csftarget}_4_blur.mnc ${outdir}/source_to_target_4_blur_nlin.xfm -clobber"
/usr/local/bic/bin/minctracc -iterations 30 -step 4 4 4 -sub_lattice 6 -lattice_diam 12 12 12 -nonlinear corrcoeff -weight ${weight} -stiffness ${stiffness} -similarity ${similarity} -transformation ${outdir}/source_to_target_8_blur_nlin.xfm ${outdir}/${csfsource}_4_blur.mnc ${outdir}/${csftarget}_4_blur.mnc ${outdir}/source_to_target_4_blur_nlin.xfm -clobber
 
echo "/usr/local/bic/bin/minctracc -iterations 10 -step 2 2 2 -sub_lattice 6 -lattice_diam 6 6 6 -nonlinear corrcoeff -weight ${weight} -stiffness ${stiffness} -similarity ${similarity} -transformation ${outdir}/source_to_target_4_blur_nlin.xfm ${outdir}/${csfsource}_2_blur.mnc ${outdir}/${csftarget}_2_blur.mnc ${outdir}/source_to_target_nlin.xfm -clobber"
/usr/local/bic/bin/minctracc -iterations 10 -step 2 2 2 -sub_lattice 6 -lattice_diam 6 6 6 -nonlinear corrcoeff -weight ${weight} -stiffness ${stiffness} -similarity ${similarity} -transformation ${outdir}/source_to_target_4_blur_nlin.xfm ${outdir}/${csfsource}_2_blur.mnc ${outdir}/${csftarget}_2_blur.mnc ${outdir}/source_to_target_nlin.xfm -clobber

if [ ${fine} -eq 1 ]
then
	echo "/usr/local/bic/bin/minctracc -iterations 10 -step 1 1 1 -sub_lattice 6 -lattice_diam 6 6 6 -nonlinear corrcoeff -weight ${weight} -stiffness ${stiffness} -similarity ${similarity} -transformation ${outdir}/source_to_target_nlin.xfm ${outdir}/${csfsource}.mnc ${outdir}/${csftarget}.mnc ${outdir}/source_to_target_nlin_fine.xfm -clobber"
	/usr/local/bic/bin/minctracc -iterations 10 -step 1 1 1 -sub_lattice 6 -lattice_diam 6 6 6 -nonlinear corrcoeff -weight ${weight} -stiffness ${stiffness} -similarity ${similarity} -transformation ${outdir}/source_to_target_nlin.xfm ${outdir}/${csfsource}.mnc ${outdir}/${csftarget}.mnc ${outdir}/source_to_target_nlin_fine.xfm -clobber

	echo "/usr/local/bic/bin/mincresample -like ${outdir}/${csftarget}.mnc -transformation ${outdir}/source_to_target_nlin_fine.xfm ${outdir}/source.mnc ${outdir}/source_to_target_nlin_fine.mnc -clobber"
	/usr/local/bic/bin/mincresample -like ${outdir}/${csftarget}.mnc -transformation ${outdir}/source_to_target_nlin_fine.xfm ${outdir}/source.mnc ${outdir}/source_to_target_nlin_fine.mnc -clobber
fi
 
# Apply nl transform
echo "/usr/local/bic/bin/mincresample -like ${outdir}/${csftarget}.mnc -transformation ${outdir}/source_to_target_nlin.xfm ${outdir}/source.mnc ${outdir}/source_to_target_nlin.mnc -clobber"
/usr/local/bic/bin/mincresample -like ${outdir}/${csftarget}.mnc -transformation ${outdir}/source_to_target_nlin.xfm ${outdir}/source.mnc ${outdir}/source_to_target_nlin.mnc -clobber
 
# Convert to nii
/usr/local/matlab11/bin/matlab -nodisplay <<EOF
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
