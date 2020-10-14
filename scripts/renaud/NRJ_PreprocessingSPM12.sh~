#! /bin/bash

if [ $# -lt 10 ]
then
	echo ""
	echo "Usage: NRJ_PreprocessingSPM12.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -nrun <value>  -epi <fmri_file>  -o <name>  [-fwhmvol <value>  -fwhmsurf <value>  -acquis <name>  -rmframe <value>  -tr <value> ]"
	echo ""
	echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
	echo "  -subj                        : Subject I "
	echo "  -nrun                        : Number of runs "
	echo "  -epi                         : EPI directory "
	echo "  -o                           : output directory "
	echo "  -fwhmvol                     : smoothing value (volume) "
	echo "  -fwhmsurf                    : smoothing value (surface) "
	echo "  -acquis                      : 'ascending', 'descending' or 'interleaved' "
	echo "  -rmframe                     : frame for removal "
	echo "  -tr                          : TR value "
	echo ""
	echo "Usage: NRJ_PreprocessingSPM12.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -nrun <value>  -epi <fmri_file>  -o <name>  [-fwhmvol <value>  -fwhmsurf <value>  -acquis <name>  -rmframe <value>  -tr <value> ]"
	echo ""
	exit 1
fi

HOME=/home/renaud
index=1
fwhmvol=6
fwhmsurf=1.5
acquis=ascending
remframe=3
TRtmp=0

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: NRJ_PreprocessingSPM12.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -nrun <value>  -epi <fmri_file>  -o <name>  [-fwhmvol <value>  -fwhmsurf <value>  -acquis <name>  -rmframe <value>  -tr <value> ]"
		echo ""
		echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subj                        : Subject I "
		echo "  -nrun                        : Number of runs "
		echo "  -epi                         : EPI directory "
		echo "  -o                           : output directory "
		echo "  -fwhmvol                     : smoothing value (volume) "
		echo "  -fwhmsurf                    : smoothing value (surface) "
		echo "  -acquis                      : 'ascending', 'descending' or 'interleaved' "
		echo "  -rmframe                     : frame for removal "
		echo "  -tr                          : TR value "
		echo ""
		echo "Usage: NRJ_PreprocessingSPM12.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -nrun <value>  -epi <fmri_file>  -o <name>  [-fwhmvol <value>  -fwhmsurf <value>  -acquis <name>  -rmframe <value>  -tr <value> ]"
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
	-epi)
		index=$[$index+1]
		eval epi=\${$index}
		echo "fMRI file : $epi"
		;;
	-nrun)
		index=$[$index+1]
		eval nruns=\${$index}
		echo "Number of runs : ${nruns}"
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
	-acquis)
		index=$[$index+1]
		eval acquis=\${$index}
		echo "acquisition : ${acquis}"
		;;
	-rmframe)
		index=$[$index+1]
		eval remframe=\${$index}
		echo "frame for removal : ${remframe}"
		;;
	-tr)
		index=$[$index+1]
		eval TRtmp=\${$index}
		echo "TR value : ${TRtmp}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: NRJ_PreprocessingSPM12.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -nrun <value>  -epi <fmri_file>  -o <name>  [-fwhmvol <value>  -fwhmsurf <value>  -acquis <name>  -rmframe <value>  -tr <value> ]"
		echo ""
		echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subj                        : Subject I "
		echo "  -nrun                        : Number of runs "
		echo "  -epi                         : EPI directory "
		echo "  -o                           : output directory "
		echo "  -fwhmvol                     : smoothing value (volume) "
		echo "  -fwhmsurf                    : smoothing value (surface) "
		echo "  -acquis                      : 'ascending', 'descending' or 'interleaved' "
		echo "  -rmframe                     : frame for removal "
		echo "  -tr                          : TR value "
		echo ""
		echo "Usage: NRJ_PreprocessingSPM12.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -nrun <value>  -epi <fmri_file>  -o <name>  [-fwhmvol <value>  -fwhmsurf <value>  -acquis <name>  -rmframe <value>  -tr <value> ]"
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

if [ -z ${epi} ]
then
	 echo "-epi argument mandatory"
	 exit 1
fi

if [ -z ${nruns} ]
then
	 echo "-nrun argument mandatory"
	 exit 1
fi

if [ -z ${output} ]
then
	 echo "-o argument mandatory"
	 exit 1
fi


DIR="${SD}/${SUBJ}"
SUBJECTS_DIR=${SD}

if [ -d ${DIR}/fmri/${output} ]
then
	echo "rm -rf ${DIR}/fmri/${output}"
	rm -rf ${DIR}/fmri/${output}
fi
echo "mkdir -p ${DIR}/fmri/${output}"
mkdir -p ${DIR}/fmri/${output}

if [ ! -f ${DIR}/fmri/${output}/orig.nii ]
then
	echo "mri_convert ${DIR}/mri/orig.mgz ${DIR}/fmri/${output}/orig.nii"
	mri_convert ${DIR}/mri/orig.mgz ${DIR}/fmri/${output}/orig.nii
fi

#=========================================================================================
#                           PREPROCESSING WITH SPM8
#========================================================================================= 

for ((k = 1; k <= ${nruns}; k += 1)) 
do
  
  echo ${k}

  outtmp=runtmp
  if [ ! -d ${DIR}/fmri/${outtmp} ]
  then
  	mkdir ${DIR}/fmri/${outtmp}
  else
	rm -rf ${DIR}/fmri/${outtmp}/*
  fi

  if [ ${k} -lt 10 ]
  then
    runname=run0${k}.nii   
  else
    runname=run${k}.nii
  fi
  epiFile=${epi}/${runname}

  if [ ${TRtmp} -eq 0 ]
  then
	  TR=$(mri_info ${epiFile} | grep TR | awk '{print $2}')
	  TR=$(echo "$TR/1000" | bc -l)
  else
	  TR=${TRtmp}
  fi
  N=$(mri_info ${epiFile} | grep dimensions | awk '{print $6}')

  echo "TR = $TR s"
  echo "N = $N"

  echo "fslsplit ${epiFile} ${DIR}/fmri/${outtmp}/epi_ -t"
  fslsplit ${epiFile} ${DIR}/fmri/${outtmp}/epi_ -t
  for ((ind = 0; ind < ${remframe}; ind += 1))
  do
	  filename=`ls -1 ${DIR}/fmri/${outtmp}/ | sed -ne "1p"`
	  rm -f ${DIR}/fmri/${outtmp}/${filename}
  done
  
  echo "fslmerge -t ${DIR}/fmri/${output}/${runname} ${DIR}/fmri/${outtmp}/epi_*"
  fslmerge -t ${DIR}/fmri/${output}/${runname} ${DIR}/fmri/${outtmp}/epi_*

done

echo "gunzip ${DIR}/fmri/${output}/*.gz"
gunzip ${DIR}/fmri/${output}/*.gz
echo "rm -rf ${DIR}/fmri/${outtmp}"
rm -rf ${DIR}/fmri/${outtmp}

## Processing
echo "NRJ_PreprocessingSPM12Bis(STRUCTURAL_FILE,XFUNCTIONAL_FILES,steps,opt_prep);"
/usr/local/matlab11/bin/matlab -nodisplay <<EOF

% Load Matlab Path
p = pathdef;
addpath(p);

NSUBJECTS=1;
FUNCTIONAL_FILE=cellstr(conn_dir(fullfile('${DIR}/fmri/${output}','run*.nii')));
STRUCTURAL_FILE=cellstr(conn_dir(fullfile('${DIR}/fmri/${output}','orig*.nii')));
nsessions=length(FUNCTIONAL_FILE)/NSUBJECTS;
FUNCTIONAL_FILE=reshape(FUNCTIONAL_FILE,[NSUBJECTS,nsessions]);
STRUCTURAL_FILE={STRUCTURAL_FILE{1:NSUBJECTS}};
for nsub=1:NSUBJECTS,for nses=1:nsessions,functionals{nsub}{nses}{1}=FUNCTIONAL_FILE{nsub,nses};end; end 
for nsub=1:length(functionals)
	for nses=1:length(functionals{nsub})
		[tempa,tempb,tempc]=fileparts(functionals{nsub}{nses}{1}); 
		if length(functionals{nsub}{nses})==1&&strcmp(tempc,'.nii')
			XFUNCTIONAL_FILES{nsub}{nses}=cellstr(spm_select('ExtFPList',tempa,['^',tempb,tempc],1:1e4)); 
		end;
	end;
end

steps = {'segmentation','slicetiming','realignment','coregistration','normalization','smoothing'};

if exist('${DIR}/mri/aparc.a2009s+aseg.mgz','file')
	opt_prep = struct('TR',${TR},'center',1,'reorient',eye(4),'vox',2,'fwhm',${fwhmvol},'fwhmsurf',${fwhmsurf},'segment','new','acquisition','${acquis}','parc','${DIR}/mri/aparc.a2009s+aseg.mgz','structural_template',fullfile(fileparts(which('spm')),'templates','T1.nii'),'functional_template',fullfile(fileparts(which('spm')),'templates','EPI.nii'));
else
	opt_prep = struct('TR',${TR},'center',1,'reorient',eye(4),'vox',2,'fwhm',${fwhmvol},'fwhmsurf',${fwhmsurf},'segment','new','acquisition','${acquis}','structural_template',fullfile(fileparts(which('spm')),'templates','T1.nii'),'functional_template',fullfile(fileparts(which('spm')),'templates','EPI.nii'));
end

NRJ_PreprocessingSPM12Bis(STRUCTURAL_FILE,XFUNCTIONAL_FILES,steps,opt_prep);

EOF

## MASKS
filename=`ls -1 ${DIR}/fmri/${output}/mean* | sed -ne "1p"`
echo "bet ${filename} ${DIR}/fmri/${output}/epi -m -n -f 0.2"
bet ${filename} ${DIR}/fmri/${output}/epi -m -n -f 0.2
gunzip ${DIR}/fmri/${output}/epi_mask.nii.gz

filename=`ls -1 ${DIR}/fmri/${output}/wmean* | sed -ne "1p"`
echo "bet ${filename} ${DIR}/fmri/${output}/wepi -m -n -f 0.2"
bet ${filename} ${DIR}/fmri/${output}/wepi -m -n -f 0.2
gunzip ${DIR}/fmri/${output}/wepi_mask.nii.gz

