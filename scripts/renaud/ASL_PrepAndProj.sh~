#! /bin/bash

if [ $# -lt 10 ]
then
	echo ""
	echo "Usage:  ASL_PrepAndProj.sh  -sd <path>  -subj <patientname>  -asl <file>  -fwhm <value>  -o <folder>  -TR <value>  -LT <value>  -DT <value>  -TE <value>  -dicom "
	echo ""
	echo "  -sd         : Path to SUBJECTS_DIR "
	echo "  -subj       : Subject name "
	echo "  -asl        : ASL file "
	echo "  -fwhm       : fwhm value "
	echo "  -o          : output folder "
	echo "  -TR         : TR value (ms) "
	echo "  -LT         : labeling time (s) "
	echo "  -DT         : delay time (s) "
	echo "  -TE         : TE value (ms) "
	echo "  -dicom      : using DICOM for conversion "
	echo ""
	echo "Usage:  ASL_PrepAndProj.sh  -sd <path>  -subj <patientname>  -asl <file>  -fwhm <value>  -o <folder>  -TR <value>  -LT <value>  -DT <value>  -TE <value>  -dicom "
	echo ""
	echo "Author: Renaud Lopes - CHRU Lille - Aug 23, 2012"
	echo ""
	exit 1
fi

index=1
dicom=0

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage:  ASL_PrepAndProj.sh  -sd <path>  -subj <patientname>  -asl <file>  -fwhm <value>  -o <folder>  -TR <value>  -LT <value>  -DT <value>  -TE <value>  -dicom "
		echo ""
		echo "  -sd         : Path to SUBJECTS_DIR "
		echo "  -subj       : Subject name "
		echo "  -asl        : ASL file "
		echo "  -fwhm       : fwhm value "
		echo "  -o          : output folder "
		echo "  -TR         : TR value (ms) "
		echo "  -LT         : labeling time (s) "
		echo "  -DT         : delay time (s) "
		echo "  -TE         : TE value (ms) "
		echo "  -dicom      : using DICOM for conversion "
		echo ""
		echo "Usage:  ASL_PrepAndProj.sh  -sd <path>  -subj <patientname>  -asl <file>  -fwhm <value>  -o <folder>  -TR <value>  -LT <value>  -DT <value>  -TE <value>  -dicom "
		echo ""
		echo "Author: Renaud Lopes - CHRU Lille - Aug 23, 2012"
		echo ""
		exit 1
		;;
	-sd)
		index=$[$index+1]
		eval fsdir=\${$index}
		echo "subjects directory : ${fsdir}"
		;;
	-subj)
		index=$[$index+1]
		eval subj=\${$index}
		echo "subject name : ${subj}"
		;;
	-asl)
		index=$[$index+1]
		eval asl=\${$index}
		echo "asl file : ${asl}"
		;;
	-fwhm)
		index=$[$index+1]
		eval FWHM=\${$index}
		echo "fwhm value : ${FWHM}"
		;;
	-o)
		index=$[$index+1]
		eval output=\${$index}
		echo "output : ${output}"
		;;
	-TR)
		index=$[$index+1]
		eval TR=\${$index}
		echo "TR : ${TR}"
		;;
	-LT)
		index=$[$index+1]
		eval Labeltime=\${$index}
		echo "Labeling time : ${Labeltime}"
		;;
	-DT)
		index=$[$index+1]
		eval Delaytime=\${$index}
		echo "Delay time : ${Delaytime}"
		;;
	-TE)
		index=$[$index+1]
		eval TE=\${$index}
		echo "TE : ${TE}"
		;;
	-dicom)
		dicom=1
		echo "dicom = ${dicom}"
		echo "change data format"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage:  ASL_PrepAndProj.sh  -sd <path>  -subj <patientname>  -asl <file>  -fwhm <value>  -o <folder>  -TR <value>  -LT <value>  -DT <value>  -TE <value>  -dicom "
		echo ""
		echo "  -sd         : Path to SUBJECTS_DIR "
		echo "  -subj       : Subject name "
		echo "  -asl        : ASL file "
		echo "  -fwhm       : fwhm value "
		echo "  -o          : output folder "
		echo "  -TR         : TR value (ms) "
		echo "  -LT         : labeling time (s) "
		echo "  -DT         : delay time (s) "
		echo "  -TE         : TE value (ms) "
		echo "  -dicom      : using DICOM for conversion "
		echo ""
		echo "Usage:  ASL_PrepAndProj.sh  -sd <path>  -subj <patientname>  -asl <file>  -fwhm <value>  -o <folder>  -TR <value>  -LT <value>  -DT <value>  -TE <value>  -dicom "
		echo ""
		echo "Author: Renaud Lopes - CHRU Lille - Aug 23, 2012"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${fsdir} ]
then
	 echo "-sd argument mandatory"
	 exit 1
fi

## Check mandatory arguments
if [ -z ${subj} ]
then
	 echo "-subj argument mandatory"
	 exit 1
fi

## Check mandatory arguments
if [ -z ${asl} ]
then
	 echo "-asl argument mandatory"
	 exit 1
fi

## Check mandatory arguments
if [ -z ${FWHM} ]
then
	 echo "-fwhm argument mandatory"
	 exit 1
fi

## Check mandatory arguments
if [ -z ${output} ]
then
	 echo "-o argument mandatory"
	 exit 1
fi

## Check mandatory arguments
if [ -z ${TR} ]
then
	 echo "-TR argument mandatory"
	 exit 1
fi

## Check mandatory arguments
if [ -z ${Labeltime} ]
then
	 echo "-LT argument mandatory"
	 exit 1
fi

## Check mandatory arguments
if [ -z ${Delaytime} ]
then
	 echo "-DT argument mandatory"
	 exit 1
fi

## Check mandatory arguments
if [ -z ${TE} ]
then
	 echo "-TE argument mandatory"
	 exit 1
fi

DIR=${fsdir}/${subj}

if [ ! -d ${DIR}/${output} ]
then
	mkdir  ${DIR}/${output}
fi

t1File=${DIR}/${output}/T1.nii
if [ ! -f ${t1File} ]
then
	mri_convert ${DIR}/mri/orig.mgz ${t1File}
fi

if [ ${dicom} -eq 1 ]
then
	echo "mkdir ${DIR}/${output}/temp"
	mkdir ${DIR}/${output}/temp
	echo "fslsplit ${asl} ${DIR}/${output}/temp/epi_ -t"
	fslsplit ${asl} ${DIR}/${output}/temp/epi_ -t
	echo "fslmerge -t ${DIR}/${output}/asl1.nii ${DIR}/${output}/temp/epi_*[13579].nii.gz"
	fslmerge -t ${DIR}/${output}/asl1.nii ${DIR}/${output}/temp/epi_*[13579].nii.gz
	echo "fslmerge -t ${DIR}/${output}/asl2.nii ${DIR}/${output}/temp/epi_*[02468].nii.gz"
	fslmerge -t ${DIR}/${output}/asl2.nii ${DIR}/${output}/temp/epi_*[02468].nii.gz
	echo "fslmerge -t ${DIR}/${output}/aslref.nii ${DIR}/${output}/asl1.nii ${DIR}/${output}/asl2.nii"
	fslmerge -t ${DIR}/${output}/aslref.nii ${DIR}/${output}/asl1.nii ${DIR}/${output}/asl2.nii
	echo "gunzip ${DIR}/${output}/aslref.nii.gz"
	gunzip ${DIR}/${output}/aslref.nii.gz
	echo "rm -rf ${DIR}/${output}/temp"
	rm -rf ${DIR}/${output}/temp
	asl=${DIR}/${output}/aslref.nii
fi

PVE=pve

# ASL map
/usr/local/matlab11/bin/matlab -nodisplay <<EOF
% Load Matlab Path
p = pathdef;
addpath(p);

opts.realign          = 1;
opts.smooth           = 0;
opts.fwhm             = 6;
opts.FirstimageType   = 0;
opts.SubtractionType  = 2;
opts.SubtractionOrder = 1;
opts.Flag             = [1 1 1 0 0 0 0];
opts.Timeshift        = 0.5;
opts.AslType          = 1;
opts.labeff           = 0.85;
opts.MagType          = 1;

ASL_ProcessSubj('${asl}','${t1File}','${PVE}',${TR},${Delaytime},${TE},${Labeltime},opts);
 
EOF

#==============================================================================================
#                                   Project ASL map onto surface
#==============================================================================================

#ASL_Project.sh -sd ${fsdir} -subj ${subj} -fwhm ${fwhm} -o ${output}

echo "mri_convert ${DIR}/${output}/${PVE}/t1_MGRousset.img ${DIR}/${output}/asl_pve.mgz"
mri_convert ${DIR}/${output}/${PVE}/t1_MGRousset.img ${DIR}/${output}/asl_pve.mgz

# Project T1 onto surface
/usr/local/matlab11/bin/matlab -nodisplay <<EOF
% Load Matlab Path
p = pathdef;
addpath(p);
 
inner_surf = SurfStatReadSurf('${DIR}/surf/lh.white');
outer_surf = SurfStatReadSurf('${DIR}/surf/lh.pial');

mid_surf.coord = (inner_surf.coord + outer_surf.coord) ./ 2;
mid_surf.tri = inner_surf.tri;

freesurfer_write_surf('${DIR}/surf/lh.mid', mid_surf.coord', mid_surf.tri);

inner_surf = SurfStatReadSurf('${DIR}/surf/rh.white');
outer_surf = SurfStatReadSurf('${DIR}/surf/rh.pial');

mid_surf.coord = (inner_surf.coord + outer_surf.coord) ./ 2;
mid_surf.tri = inner_surf.tri;

freesurfer_write_surf('${DIR}/surf/rh.mid', mid_surf.coord', mid_surf.tri);
EOF

SUBJECTS_DIR=${fsdir}
SUBJ=${subj}

echo "mri_vol2surf --mov ${DIR}/${output}/asl_pve.mgz --hemi lh --surf mid --o lh.asl.w --regheader ${SUBJ} --out_type paint --fwhm 2"
mri_vol2surf --mov ${DIR}/${output}/asl_pve.mgz --hemi lh --surf mid --o lh.asl.w --regheader ${SUBJ} --out_type paint --fwhm 2

echo "mri_vol2surf --mov ${DIR}/${output}/asl_pve.mgz --hemi lh --surf mid --o lh.asl.w --regheader ${SUBJ} --out_type paint --fwhm 2 --surf-fwhm ${FWHM}"
mri_vol2surf --mov ${DIR}/${output}/asl_pve.mgz --hemi lh --surf mid --o lh.fwhm${FWHM}.asl.w --regheader ${SUBJ} --out_type paint --fwhm 2 --surf-fwhm ${FWHM}

echo "mri_vol2surf --mov ${DIR}/${output}/asl_pve.mgz --hemi rh --surf mid --o rh.asl.w --regheader ${SUBJ} --out_type paint --fwhm 2"
mri_vol2surf --mov ${DIR}/${output}/asl_pve.mgz --hemi rh --surf mid --o rh.asl.w --regheader ${SUBJ} --out_type paint --fwhm 2

echo "mri_vol2surf --mov ${DIR}/${output}/asl_pve.mgz --hemi rh --surf mid --o rh.asl.w --regheader ${SUBJ} --out_type paint --fwhm 2 --surf-fwhm ${FWHM}"
mri_vol2surf --mov ${DIR}/${output}/asl_pve.mgz --hemi rh --surf mid --o rh.fwhm${FWHM}.asl.w --regheader ${SUBJ} --out_type paint --fwhm 2 --surf-fwhm ${FWHM}

echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.asl.w lh.asl"
mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.asl.w lh.asl

echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.asl.w rh.asl"
mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.asl.w rh.asl

echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm${FWHM}.asl.w lh.fwhm${FWHM}.asl"
mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm${FWHM}.asl.w lh.fwhm${FWHM}.asl

echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm${FWHM}.asl.w rh.fwhm${FWHM}.asl"
mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm${FWHM}.asl.w rh.fwhm${FWHM}.asl

mv ${DIR}/surf/lh.asl ${DIR}/${output}/lh.asl
mv ${DIR}/surf/rh.asl ${DIR}/${output}/rh.asl
mv ${DIR}/surf/lh.fwhm${FWHM}.asl ${DIR}/${output}/lh.fwhm${FWHM}.asl
mv ${DIR}/surf/rh.fwhm${FWHM}.asl ${DIR}/${output}/rh.fwhm${FWHM}.asl

rm -f ${DIR}/surf/lh.asl.w ${DIR}/surf/rh.asl.w ${DIR}/surf/lh.fwhm${FWHM}.asl.w ${DIR}/surf/rh.fwhm${FWHM}.asl.w

# Resample ASL to fsaverage
echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/${output}/lh.asl --sfmt curv --noreshape --no-cortex --tval ${DIR}/${output}/lh.fsaverage.asl.mgh --tfmt curv"
mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/${output}/lh.asl --sfmt curv --noreshape --no-cortex --tval ${DIR}/${output}/lh.fsaverage.asl.mgh --tfmt curv

echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/${output}/lh.fwhm${FWHM}.asl --sfmt curv --noreshape --no-cortex --tval ${DIR}/${output}/lh.fwhm${FWHM}.fsaverage.asl.mgh --tfmt curv"
mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/${output}/lh.fwhm${FWHM}.asl --sfmt curv --noreshape --no-cortex --tval ${DIR}/${output}/lh.fwhm${FWHM}.fsaverage.asl.mgh --tfmt curv

echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/${output}/rh.asl --sfmt curv --noreshape --no-cortex --tval ${DIR}/${output}/rh.fsaverage.asl.mgh --tfmt curv"
mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/${output}/rh.asl --sfmt curv --noreshape --no-cortex --tval ${DIR}/${output}/rh.fsaverage.asl.mgh --tfmt curv

echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/${output}/rh.fwhm${FWHM}.asl --sfmt curv --noreshape --no-cortex --tval ${DIR}/${output}/rh.fwhm${FWHM}.fsaverage.asl.mgh --tfmt curv"
mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/${output}/rh.fwhm${FWHM}.asl --sfmt curv --noreshape --no-cortex --tval ${DIR}/${output}/rh.fwhm${FWHM}.fsaverage.asl.mgh --tfmt curv

rm -f ${DIR}/${output}/${PVE}/cmdline.txt  ${DIR}/${output}/${PVE}/pet.hdr  ${DIR}/${output}/${PVE}/pet.img  ${DIR}/${output}/${PVE}/t1_CSWMROI.hdr  ${DIR}/${output}/${PVE}/t1_CSWMROI.img  ${DIR}/${output}/${PVE}/t1_GMROI.hdr  ${DIR}/${output}/${PVE}/t1_GMROI.img  ${DIR}/${output}/${PVE}/t1.hdr  ${DIR}/${output}/${PVE}/t1.img  ${DIR}/${output}/${PVE}/t1_Meltzer.hdr  ${DIR}/${output}/${PVE}/t1_Meltzer.img  ${DIR}/${output}/${PVE}/t1_MGCS.hdr  ${DIR}/${output}/${PVE}/t1_MGCS.img  ${DIR}/${output}/${PVE}/t1_Occu_Meltzer.hdr  ${DIR}/${output}/${PVE}/t1_Occu_Meltzer.img  ${DIR}/${output}/${PVE}/t1_Occu_MG.hdr  ${DIR}/${output}/${PVE}/t1_Occu_MG.img  ${DIR}/${output}/${PVE}/t1_PSF.hdr  ${DIR}/${output}/${PVE}/t1_PSF.img  ${DIR}/${output}/${PVE}/t1_pve.txt  ${DIR}/${output}/${PVE}/t1_Rousset.Mat  ${DIR}/${output}/${PVE}/t1_seg1.hdr  ${DIR}/${output}/${PVE}/t1_seg1.img  ${DIR}/${output}/${PVE}/t1_seg2.hdr  ${DIR}/${output}/${PVE}/t1_seg2.img  ${DIR}/${output}/${PVE}/t1_seg3.hdr  ${DIR}/${output}/${PVE}/t1_seg3.img  ${DIR}/${output}/${PVE}/t1_seg8.mat  ${DIR}/${output}/${PVE}/t1_Virtual_PET.hdr  ${DIR}/${output}/${PVE}/t1_Virtual_PET.img

