#! /bin/bash

if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: PRESTO_ICAOnSurface.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -pref <prefix>  -i <path>  [-tr <value>  -ncomp <value>  -smo <value> ]"
	echo ""
	echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
	echo "  -subj                        : Subject I "
	echo "  -pref                        : prefix epi file "
	echo "  -i                           : input folder "
	echo "  -tr                          : TR value "
	echo "  -ncomp                       : number of components "
	echo "  -smo                         : smoothing value "
	echo ""
	echo "Usage: PRESTO_ICAOnSurface.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -pref <prefix>  -i <path>  [-tr <value>  -ncomp <value>  -smo <value> ]"
	echo ""
	exit 1
fi

HOME=/home/renaud
index=1
N=40
TR=1
surffwhm=6

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: PRESTO_ICAOnSurface.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -pref <prefix>  -i <path>  [-tr <value>  -ncomp <value>  -smo <value> ]"
		echo ""
		echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subj                        : Subject I "
		echo "  -pref                        : prefix epi file "
		echo "  -i                           : input folder "
		echo "  -tr                          : TR value "
		echo "  -ncomp                       : number of components "
		echo "  -smo                         : smoothing value "
		echo ""
		echo "Usage: PRESTO_ICAOnSurface.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -pref <prefix>  -i <path>  [-tr <value>  -ncomp <value>  -smo <value> ]"
		echo ""
		exit 1
		;;
	-sd)
		index=$[$index+1]
		eval SD=\${$index}
		echo "SD : $SD"
		;;
	-subj)
		index=$[$index+1]
		eval SUBJ=\${$index}
		echo "Subj : $SUBJ"
		;;
	-pref)
		index=$[$index+1]
		eval prefepi=\${$index}
		echo "prefix epi file : $prefepi"
		;;
	-i)
		index=$[$index+1]
		eval input=\${$index}
		echo "input folder : $input"
		;;
	-tr)
		index=$[$index+1]
		eval TR=\${$index}
		echo "TR value : ${TR}"
		;;
	-ncomp)
		index=$[$index+1]
		eval N=\${$index}
		echo "number of components : ${N}"
		;;
	-smo)
		index=$[$index+1]
		eval surffwhm=\${$index}
		echo "smoothing value : ${surffwhm}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: PRESTO_ICAOnSurface.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -pref <prefix>  -i <path>  [-tr <value>  -ncomp <value>  -smo <value> ]"
		echo ""
		echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subj                        : Subject I "
		echo "  -pref                        : prefix epi file "
		echo "  -i                           : input folder "
		echo "  -tr                          : TR value "
		echo "  -ncomp                       : number of components "
		echo "  -smo                         : smoothing value "
		echo ""
		echo "Usage: PRESTO_ICAOnSurface.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -pref <prefix>  -i <path>  [-tr <value>  -ncomp <value>  -smo <value> ]"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${SD} ]
then
	 echo "-sd argument mandatory"
	 exit 1
fi

if [ -z ${SUBJ} ]
then
	 echo "-subj argument mandatory"
	 exit 1
fi

if [ -z ${prefepi} ]
then
	 echo "-pref argument mandatory"
	 exit 1
fi

if [ -z ${input} ]
then
	 echo "-i argument mandatory"
	 exit 1
fi

DIR="${SD}/${SUBJ}"
SUBJECTS_DIR=${SD}

#=========================================================================================
#                              ICA Decomposition
#=========================================================================================

outdir=ica_${N}
method=2

## Delete out dir
if [ -d ${input}/${outdir} ]
then
	echo "rm -rf ${input}/${outdir}"
	rm -rf ${input}/${outdir}
fi

## Creates output folder
if [ ! -d ${input}/${outdir} ]
then
	echo "mkdir ${input}/${outdir}"
	mkdir ${input}/${outdir}
fi

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

% Load Matlab Path
p = pathdef;
addpath(p);

surf      = SurfStatReadSurf([fullfile('${DIR}','surf/lh.white')]);
fnumleft  = size(surf.tri,1);
nbleft    = size(surf.coord,2);
surf      = SurfStatReadSurf([fullfile('${DIR}','surf/rh.white')]);
fnumright = size(surf.tri,1);
nbright   = size(surf.coord,2);
clear surf;

if(${method}==1)
	sica = FMRI_SurfICANew('${input}',${TR},'${prefepi}',${N});
else
	plh  = fullfile('${input}',['${prefepi}' '.lh.nii']);
	prh  = fullfile('${input}',['${prefepi}' '.rh.nii']);
	sica = FMRI_SurfICA(plh,prh,${TR},${N});
end

save(fullfile('${input}','${outdir}','sica.mat'),'sica');

mask = 1:size(sica.S,1);

for j = 1:sica.nbcomp
	sig_c = FMRI_CorrectSignalOnSurface(double(sica.S(:,j)),mask,0.05,0);
	write_curv(fullfile('${input}','${outdir}',['lh.ica_map_' num2str(j)]),sig_c(1:nbleft),fnumleft);
	write_curv(fullfile('${input}','${outdir}',['rh.ica_map_' num2str(j)]),sig_c(nbleft+1:end),fnumright);
end

EOF


# Resampling to fsaverage and smoothing

SUBJECTS_DIR=${SD}

for ((ind = 1; ind <= ${N}; ind += 1))
do

	# Left hemisphere
	mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${input}/${outdir}/lh.ica_map_${ind} --sfmt curv --noreshape --cortex --tval ${input}/${outdir}/lh.fsaverage_ica_map_${ind}.mgh --tfmt curv
	mris_fwhm --s fsaverage --hemi lh --smooth-only --i ${input}/${outdir}/lh.fsaverage_ica_map_${ind}.mgh --fwhm ${surffwhm} --o ${input}/${outdir}/lh.sm${surffwhm}_fsaverage_ica_map_${ind}.mgh

	# Right hemisphere
	mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${input}/${outdir}/rh.ica_map_${ind} --sfmt curv --noreshape --cortex --tval ${input}/${outdir}/rh.fsaverage_ica_map_${ind}.mgh --tfmt curv
	mris_fwhm --s fsaverage --hemi rh --smooth-only --i ${input}/${outdir}/rh.fsaverage_ica_map_${ind}.mgh --fwhm ${surffwhm} --o ${input}/${outdir}/rh.sm${surffwhm}_fsaverage_ica_map_${ind}.mgh
	
done
