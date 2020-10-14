#! /bin/bash

if [ $# -lt 10 ]
then
	echo ""
	echo "Usage: PRESTO_Preprocessing.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -par <par_file>  -o <folder>  -tr <value>  [-fwhmvol <value>  -fwhmsurf <value>  -rmframe <value>  ]"
	echo ""
	echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
	echo "  -subj                        : Subject I "
	echo "  -par                         : PAR file "
	echo "  -o                           : output directory "
	echo "  -fwhmvol                     : smoothing value (volume) "
	echo "  -fwhmsurf                    : smoothing value (surface) "
	echo "  -rmframe                     : frame for removal "
	echo "  -tr                          : TR value "
	echo ""
	echo "Usage: PRESTO_Preprocessing.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -par <par_file>  -o <folder>  -tr <value>  [-fwhmvol <value>  -fwhmsurf <value>  -rmframe <value>  ]"
	echo ""
	exit 1
fi

HOME=/home/renaud
index=1
fwhmvol=6
fwhmsurf=1.5
remframe=3
TR=1

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: PRESTO_Preprocessing.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -par <par_file>  -o <folder>  -tr <value>  [-fwhmvol <value>  -fwhmsurf <value>  -rmframe <value>  ]"
		echo ""
		echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subj                        : Subject I "
		echo "  -par                         : PAR file "
		echo "  -o                           : output directory "
		echo "  -fwhmvol                     : smoothing value (volume) "
		echo "  -fwhmsurf                    : smoothing value (surface) "
		echo "  -rmframe                     : frame for removal "
		echo "  -tr                          : TR value "
		echo ""
		echo "Usage: PRESTO_Preprocessing.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -par <par_file>  -o <folder>  -tr <value>  [-fwhmvol <value>  -fwhmsurf <value>  -rmframe <value>  ]"
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
	-par)
		index=$[$index+1]
		eval parFile=\${$index}
		echo "PAR file : $parFile"
		;;
	-o)
		index=$[$index+1]
		eval output=\${$index}
		echo "Output folder : ${output}"
		;;
	-fwhmvol)
		index=$[$index+1]
		eval fwhmvol=\${$index}
		echo "fwhm volume : ${fwhmvol}"
		;;
	-fwhmsurf)
		index=$[$index+1]
		eval fwhmsurf=\${$index}
		echo "fwhm surface : ${fwhmsurf}"
		;;
	-rmframe)
		index=$[$index+1]
		eval remframe=\${$index}
		echo "frame for removal : ${remframe}"
		;;
	-tr)
		index=$[$index+1]
		eval TR=\${$index}
		echo "TR value : ${TR}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: PRESTO_Preprocessing.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -par <par_file>  -o <folder> -tr <value>  [-fwhmvol <value>  -fwhmsurf <value>  -rmframe <value>  ]"
		echo ""
		echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subj                        : Subject I "
		echo "  -par                         : PAR file "
		echo "  -o                           : output directory "
		echo "  -fwhmvol                     : smoothing value (volume) "
		echo "  -fwhmsurf                    : smoothing value (surface) "
		echo "  -rmframe                     : frame for removal "
		echo "  -tr                          : TR value "
		echo ""
		echo "Usage: PRESTO_Preprocessing.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -par <par_file>  -o <folder>  -tr <value>  [-fwhmvol <value>  -fwhmsurf <value>  -rmframe <value>  ]"
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

if [ -z ${parFile} ]
then
	 echo "-par argument mandatory"
	 exit 1
fi

if [ -z ${output} ]
then
	 echo "-o argument mandatory"
	 exit 1
fi

if [ -z ${TR} ]
then
	 echo "-tr argument mandatory"
	 exit 1
fi

DIR="${SD}/${SUBJ}"
SUBJECTS_DIR=${SD}

if [ -d ${DIR}/${output} ]
then
	echo "rm -rf ${DIR}/${output}"
	rm -rf ${DIR}/${output}
fi
echo "mkdir -p ${DIR}/${output}"
mkdir -p ${DIR}/${output}

if [ ! -f ${DIR}/${output}/orig.nii ]
then
	echo "mri_convert ${DIR}/mri/orig.mgz ${DIR}/${output}/orig.nii"
	mri_convert ${DIR}/mri/orig.mgz ${DIR}/${output}/orig.nii
fi
anatFile=${DIR}/${output}/orig.nii

echo "TR = $TR s"

## Processing
echo "PRESTO_Par2Nii(${parFile},fullfile(${DIR},${output}),'presto');"
echo "PRESTO_PreprocessingSPM12(anatFile,epiFile,nsubjects,steps,opt);"
/usr/local/matlab11/bin/matlab -nodisplay <<EOF

% Load Matlab Path
p = pathdef;
addpath(p);

addpath(genpath('/home/renaud/NAS/renaud/scripts/NeuroElf_v09c'))

% Convert PAR to NIFTI
PRESTO_Par2Nii('${parFile}',fullfile('${DIR}','${output}'),'presto');
epiFile = fullfile('${DIR}','${output}','presto.nii');

% Preprocessing
if exist('${DIR}/mri/aparc.a2009s+aseg.mgz','file')
	opt = struct('TR',${TR},'vox',2,'fwhm',${fwhmvol},'fwhmsurf',${fwhmsurf},'segment','new','structural_template',fullfile(fileparts(which('spm')),'templates','T1.nii'),'functional_template',fullfile(fileparts(which('spm')),'templates','EPI.nii'),'parc','${DIR}/mri/aparc.a2009s+aseg.mgz'); 
else
	opt = struct('TR',${TR},'vox',2,'fwhm',${fwhmvol},'fwhmsurf',${fwhmsurf},'segment','new','structural_template',fullfile(fileparts(which('spm')),'templates','T1.nii'),'functional_template',fullfile(fileparts(which('spm')),'templates','EPI.nii'));
end

steps = {'segmentation','realignment','coregistration','normalization','smoothing'};

nsubjects=1;
PRESTO_PreprocessingSPM12('${anatFile}',epiFile,nsubjects,steps,opt);

EOF

## MASKS
filename=`ls -1 ${DIR}/${output}/mean* | sed -ne "1p"`
echo "bet ${filename} ${DIR}/${output}/epi -m -n -f 0.2"
bet ${filename} ${DIR}/${output}/epi -m -n -f 0.2
gunzip ${DIR}/${output}/epi_mask.nii.gz

filename=`ls -1 ${DIR}/${output}/wmean* | sed -ne "1p"`
echo "bet ${filename} ${DIR}/${output}/wepi -m -n -f 0.2"
bet ${filename} ${DIR}/${output}/wepi -m -n -f 0.2
gunzip ${DIR}/${output}/wepi_mask.nii.gz

