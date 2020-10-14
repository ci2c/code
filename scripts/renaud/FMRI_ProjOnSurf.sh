#! /bin/bash

if [ $# -lt 14 ]
then
	echo ""
	echo "Usage: FMRI_ProjOnSurf.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -fwhmsurf <value>  -prep <value>  -ospm <folder>  -osurf <folder>  [-TR <value>  -N <value>  -fwhmvol <value>  -refslice <value>  -acquis <name>  -resampling <value>  -rmframe <value>]"
	echo ""
	echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
	echo "  -subj                        : Subject I "
	echo "  -epi                         : fmri file "
	echo "  -fwhmsurf                    : smoothing value (surface) "
	echo "  -prep                        : 1 if do preprocessing; 0 else "
	echo "  -ospm                        : output spm directory "
	echo "  -osurf                       : output surface directory "
	echo "  -TR                          : TR value "
	echo "  -N                           : Number of slices "
	echo "  -fwhmvol                     : smoothing value (volume) "
	echo "  -refslice                    : slice of reference for slice timing correction "
	echo "  -acquis                      : 'ascending' or 'interleaved' "
	echo "  -resampling                  : '0' = no resampling ; '1' = resampling epi on anat "
	echo "  -rmframe                     : frame for removal "
	echo ""
	echo "Usage: FMRI_ProjOnSurf.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -fwhmsurf <value>  -prep <value>  -ospm <folder>  -osurf <folder>  [-TR <value>  -N <value>  -fwhmvol <value>  -refslice <value>  -acquis <name>  -resampling <value>  -rmframe <value>]"
	echo ""
	exit 1
fi

HOME=/home/renaud
index=1
TR=2.4
N=40
fwhmsurf=1.5
fwhmvol=6
refslice=1
acquis=interleaved
resamp=0
remframe=5


while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: FMRI_ProjOnSurf.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -fwhmsurf <value>  -prep <value>  -ospm <folder>  -osurf <folder>  [-TR <value>  -N <value>  -fwhmvol <value>  -refslice <value>  -acquis <name>  -resampling <value>  -rmframe <value>]"
		echo ""
		echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subj                        : Subject I "
		echo "  -epi                         : fmri file "
		echo "  -fwhmsurf                    : smoothing value (surface) "
		echo "  -prep                        : 1 if do preprocessing; 0 else "
		echo "  -ospm                        : output spm directory "
		echo "  -osurf                       : output surface directory "
		echo "  -TR                          : TR value "
		echo "  -N                           : Number of slices "
		echo "  -fwhmvol                     : smoothing value (volume) "
		echo "  -refslice                    : slice of reference for slice timing correction "
		echo "  -acquis                      : 'ascending' or 'interleaved' "
		echo "  -resampling                  : '0' = no resampling ; '1' = resampling epi on anat "
		echo "  -rmframe                     : frame for removal "
		echo ""
		echo "Usage: FMRI_ProjOnSurf.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -fwhmsurf <value>  -prep <value>  -ospm <folder>  -osurf <folder>  [-TR <value>  -N <value>  -fwhmvol <value>  -refslice <value>  -acquis <name>  -resampling <value>  -rmframe <value>]"
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
	-fwhmsurf)
		index=$[$index+1]
		eval fwhmsurf=\${$index}
		echo "fwhm surface : ${fwhmsurf}"
		;;
	-prep)
		index=$[$index+1]
		eval doprep=\${$index}
		echo "do preprocessing : $doprep"
		;;
	-ospm)
		index=$[$index+1]
		eval spmout=\${$index}
		echo "output spm directory : $spmout"
		;;
	-osurf)
		index=$[$index+1]
		eval surfout=\${$index}
		echo "output surface directory : $surfout"
		;;
	-TR)
		index=$[$index+1]
		eval TR=\${$index}
		echo "TR value : ${TR}"
		;;
	-N)
		index=$[$index+1]
		eval N=\${$index}
		echo "number of slices : ${N}"
		;;
	-fwhmvol)
		index=$[$index+1]
		eval fwhmvol=\${$index}
		echo "fwhm volume : ${fwhmvol}"
		;;
	-refslice)
		index=$[$index+1]
		eval refslice=\${$index}
		echo "slice of reference : ${refslice}"
		;;
	-acquis)
		index=$[$index+1]
		eval acquis=\${$index}
		echo "acquisition : ${acquis}"
		;;
	-resampling)
		index=$[$index+1]
		eval resamp=\${$index}
		echo "resampling : ${resamp}"
		;;
	-rmframe)
		index=$[$index+1]
		eval remframe=\${$index}
		echo "frame for removal : ${remframe}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: FMRI_ProjOnSurf.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -fwhmsurf <value>  -prep <value>  -ospm <folder>  -osurf <folder>  [-TR <value>  -N <value>  -fwhmvol <value>  -refslice <value>  -acquis <name>  -resampling <value>  -rmframe <value>]"
		echo ""
		echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subj                        : Subject I "
		echo "  -epi                         : fmri file "
		echo "  -fwhmsurf                    : smoothing value (surface) "
		echo "  -prep                        : 1 if do preprocessing; 0 else "
		echo "  -ospm                        : output spm directory "
		echo "  -osurf                       : output surface directory "
		echo "  -TR                          : TR value "
		echo "  -N                           : Number of slices "
		echo "  -fwhmvol                     : smoothing value (volume) "
		echo "  -refslice                    : slice of reference for slice timing correction "
		echo "  -acquis                      : 'ascending' or 'interleaved' "
		echo "  -resampling                  : '0' = no resampling ; '1' = resampling epi on anat "
		echo "  -rmframe                     : frame for removal "
		echo ""
		echo "Usage: FMRI_ProjOnSurf.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -fwhmsurf <value>  -prep <value>  -ospm <folder>  -osurf <folder>  [-TR <value>  -N <value>  -fwhmvol <value>  -refslice <value>  -acquis <name>  -resampling <value>  -rmframe <value>]"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${SUBJECTS_DIR} ]
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

if [ -z ${fwhmsurf} ]
then
	 echo "-fwhmsurf argument mandatory"
	 exit 1
fi

if [ -z ${doprep} ]
then
	 echo "-prep argument mandatory"
	 exit 1
fi

if [ -z ${spmout} ]
then
	 echo "-ospm argument mandatory"
	 exit 1
fi

if [ -z ${surfout} ]
then
	 echo "-osurf argument mandatory"
	 exit 1
fi


DIR="${SD}/${SUBJ}"
SUBJECTS_DIR=${SD}

## Delete out dir
if [ -d ${DIR}/${surfout} ]
then
	echo "rm -rf ${DIR}/${surfout}"
	rm -rf ${DIR}/${surfout}
fi

## Creates out dir
if [ ! -d ${DIR}/${surfout} ]
then
	echo "mkdir ${DIR}/${surfout}"
	mkdir ${DIR}/${surfout}
fi
if [ ! -d ${DIR}/${spmout} ]
then
	echo "mkdir ${DIR}/${spmout}"
	mkdir ${DIR}/${spmout}
fi

if [ ! -f ${DIR}/${spmout}/orig.nii ]
then
	echo "mri_convert ${DIR}/mri/orig.mgz ${DIR}/${spmout}/orig.nii"
	mri_convert ${DIR}/mri/orig.mgz ${DIR}/${spmout}/orig.nii
fi

#=========================================================================================
#                           PREPROCESSING WITH SPM8
#=========================================================================================
if [ ${doprep} -eq 1 ]
then 

	if [ ! -d ${DIR}/${spmout}/spm ]
	then
		mkdir ${DIR}/${spmout}/spm
	else
		rm -rf ${DIR}/${spmout}/spm/*
	fi

	echo "fslsplit ${epi} ${DIR}/${spmout}/spm/epi_ -t"
	fslsplit ${epi} ${DIR}/${spmout}/spm/epi_ -t
	for ((ind = 1; ind < ${remframe}; ind += 1))
	do
		filename=`ls -1 ${DIR}/${spmout}/spm/ | sed -ne "1p"`
		rm -f ${DIR}/${spmout}/spm/${filename}
	done
	
	echo "gunzip ${DIR}/${spmout}/spm/*.gz"
	gunzip ${DIR}/${spmout}/spm/*.gz
	
	echo "${DIR}/${spmout}/spm"
	cd ${DIR}/${spmout}/spm

	echo "FMRI_SurfPreprocessSPM8('${DIR}/${spmout}',${TR},${N},${refslice},${fwhmsurf},${fwhmvol},'epi2anat','${acquis}',${resamp});"
	/usr/local/matlab11/bin/matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);

	FMRI_SurfPreprocessSPM8('${DIR}/${spmout}',${TR},${N},${refslice},${fwhmsurf},${fwhmvol},'epi2anat','${acquis}',${resamp});
  
EOF

	echo "cd ${DIR}/${spmout}" 
	cd ${DIR}/${spmout}
	echo "fslmerge -t ${DIR}/${spmout}/epi_pre.nii ${DIR}/${spmout}/spm/ss*"
	fslmerge -t ${DIR}/${spmout}/epi_pre.nii ${DIR}/${spmout}/spm/ss*
	echo "gunzip ${DIR}/${spmout}/epi_pre.nii.gz"
	gunzip ${DIR}/${spmout}/epi_pre.nii.gz
	
	echo "fslmerge -t ${DIR}/${spmout}/epi_pre_vol.nii ${DIR}/${spmout}/spm/sv*"
	fslmerge -t ${DIR}/${spmout}/epi_pre_vol.nii ${DIR}/${spmout}/spm/sv*
	echo "gunzip ${DIR}/${spmout}/epi_pre_vol.nii.gz"
	gunzip ${DIR}/${spmout}/epi_pre_vol.nii.gz

else
	echo "no preprocessing"
fi

if [ ! -f ${DIR}/${spmout}/epi_pre.nii ]
then
	echo "no preprocessing epi file"
	exit 1
fi

#=========================================================================================
#                              Project FMRI onto surface
#=========================================================================================

cd ${DIR}/${spmout}

matlab -nodisplay <<EOF
% Load Matlab Path
cd ${HOME}
p = pathdef;
addpath(p);
cd ${DIR}
  
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

echo "tkregister2 --mov ${DIR}/${spmout}/epi_pre.nii --s ${SUBJ} --regheader --noedit --reg ${DIR}/${spmout}/register_epi2struct.dat"
tkregister2 --mov ${DIR}/${spmout}/epi_pre.nii --s ${SUBJ} --regheader --noedit --reg ${DIR}/${spmout}/register_epi2struct.dat

# Left hemisphere
echo "mri_vol2surf --mov ${DIR}/${spmout}/epi_pre.nii --reg ${DIR}/${spmout}/register_epi2struct.dat --interp trilin --projfrac 0.5 --hemi lh --o ${DIR}/${spmout}/surfepi.lh.nii --noreshape --cortex --surfreg sphere.reg"
mri_vol2surf --mov ${DIR}/${spmout}/epi_pre.nii --reg ${DIR}/${spmout}/register_epi2struct.dat --interp trilin --projfrac 0.5 --hemi lh --o ${DIR}/${spmout}/surfepi.lh.nii --noreshape --cortex --surfreg sphere.reg

# Right hemisphere
echo "mri_vol2surf --mov ${DIR}/${spmout}/epi_pre.nii --reg ${DIR}/${spmout}/register_epi2struct.dat --interp trilin --projfrac 0.5 --hemi rh --o ${DIR}/${spmout}/surfepi.rh.nii --noreshape --cortex --surfreg sphere.reg"
mri_vol2surf --mov ${DIR}/${spmout}/epi_pre.nii --reg ${DIR}/${spmout}/register_epi2struct.dat --interp trilin --projfrac 0.5 --hemi rh --o ${DIR}/${spmout}/surfepi.rh.nii --noreshape --cortex --surfreg sphere.reg

