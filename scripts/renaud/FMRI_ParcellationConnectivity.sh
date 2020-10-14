#! /bin/bash

if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: FMRI_ParcellationConnectivity.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -ospm <folder>  [-fwhmvol <value>  -refslice <value>  -acquis <name>  -rmframe <value>  -noprep  -lp <value>  -hp <value> ]"
	echo ""
	echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
	echo "  -subj                        : Subject I "
	echo "  -epi                         : fmri file "
	echo "  -ospm                        : output spm directory "
	echo "  -fwhmvol                     : smoothing value (volume) "
	echo "  -refslice                    : slice of reference for slice timing correction "
	echo "  -acquis                      : 'ascending' or 'interleaved' "
	echo "  -rmframe                     : frame for removal "
	echo "  -noprep                      : no preprocessing step "
	echo "  -lp                          : low-pass filtering "
	echo "  -hp                          : high-pass filtering "
	echo ""
	echo "Usage: FMRI_ParcellationConnectivity.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -ospm <folder>  [-fwhmvol <value>  -refslice <value>  -acquis <name>  -rmframe <value>  -noprep  -lp <value>  -hp <value> ]"
	echo ""
	exit 1
fi

HOME=/home/renaud
index=1
fwhmvol=6
refslice=1
acquis=interleaved
remframe=5
doprep=1
highpass=0.005
lowpass=0.1

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: FMRI_ParcellationConnectivity.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -ospm <folder>  [-fwhmvol <value>  -refslice <value>  -acquis <name>  -rmframe <value>  -noprep  -lp <value>  -hp <value> ]"
		echo ""
		echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subj                        : Subject I "
		echo "  -epi                         : fmri file "
		echo "  -ospm                        : output spm directory "
		echo "  -fwhmvol                     : smoothing value (volume) "
		echo "  -refslice                    : slice of reference for slice timing correction "
		echo "  -acquis                      : 'ascending' or 'interleaved' "
		echo "  -rmframe                     : frame for removal "
		echo "  -noprep                      : no preprocessing step "
		echo "  -lp                          : low-pass filtering "
		echo "  -hp                          : high-pass filtering "
		echo ""
		echo "Usage: FMRI_ParcellationConnectivity.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -ospm <folder>  [-fwhmvol <value>  -refslice <value>  -acquis <name>  -rmframe <value>  -noprep  -lp <value>  -hp <value> ]"
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
	-ospm)
		index=$[$index+1]
		eval spmout=\${$index}
		echo "output spm directory : $spmout"
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
	-rmframe)
		index=$[$index+1]
		eval remframe=\${$index}
		echo "frame for removal : ${remframe}"
		;;
	-noprep)
		doprep=0
		echo "doprep = ${doprep}"
		echo "No preprocessing step"
		;;
	-lp)
		index=$[$index+1]
		eval lowpass=\${$index}
		echo "low-pass filtering : ${lowpass}"
		;;
	-hp)
		index=$[$index+1]
		eval highpass=\${$index}
		echo "high-pass filtering : ${highpass}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: FMRI_ParcellationConnectivity.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -ospm <folder>  [-fwhmvol <value>  -refslice <value>  -acquis <name>  -rmframe <value>  -noprep  -lp <value>  -hp <value> ]"
		echo ""
		echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subj                        : Subject I "
		echo "  -epi                         : fmri file "
		echo "  -ospm                        : output spm directory "
		echo "  -fwhmvol                     : smoothing value (volume) "
		echo "  -refslice                    : slice of reference for slice timing correction "
		echo "  -acquis                      : 'ascending' or 'interleaved' "
		echo "  -rmframe                     : frame for removal "
		echo "  -noprep                      : no preprocessing step "
		echo "  -lp                          : low-pass filtering "
		echo "  -hp                          : high-pass filtering "
		echo ""
		echo "Usage: FMRI_ParcellationConnectivity.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -ospm <folder>  [-fwhmvol <value>  -refslice <value>  -acquis <name>  -rmframe <value>  -noprep  -lp <value>  -hp <value> ]"
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

if [ -z ${spmout} ]
then
	 echo "-ospm argument mandatory"
	 exit 1
fi


DIR="${SD}/${SUBJ}"
SUBJECTS_DIR=${SD}

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

if [ ! -f ${DIR}/${spmout}/orig_2mm.nii ]
then
	echo "mri_convert -vs 2 2 2 ${DIR}/${spmout}/orig.nii ${DIR}/${spmout}/orig_2mm.nii"
	mri_convert -vs 2 2 2 ${DIR}/${spmout}/orig.nii ${DIR}/${spmout}/orig_2mm.nii
fi

if [ ! -f ${DIR}/${spmout}/aparc.nii ]
then
	echo "mri_convert ${DIR}/mri/aparc.a2009s+aseg.mgz ${DIR}/${spmout}/aparc.nii"
	mri_convert ${DIR}/mri/aparc.a2009s+aseg.mgz ${DIR}/${spmout}/aparc.nii
fi

if [ ! -f ${DIR}/${spmout}/aparc_2mm.nii ]
then
	echo "mri_convert -vs 2 2 2 ${DIR}/${spmout}/aparc.nii ${DIR}/${spmout}/aparc_2mm.nii"
	mri_convert -vs 2 2 2 ${DIR}/${spmout}/aparc.nii ${DIR}/${spmout}/aparc_2mm.nii
fi

LOI=/home/renaud/SVN/scripts/renaud/aparc2009LOIConn.txt

TR=$(mri_info ${epi} | grep TR | awk '{print $2}')
TR=$(echo "$TR/1000" | bc -l)
N=$(mri_info ${epi} | grep dimensions | awk '{print $6}')

echo $TR
echo $N

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
	for ((ind = 0; ind < ${remframe}; ind += 1))
	do
		filename=`ls -1 ${DIR}/${spmout}/spm/ | sed -ne "1p"`
		rm -f ${DIR}/${spmout}/spm/${filename}
	done

	echo "gunzip ${DIR}/${spmout}/spm/*.gz"
	gunzip ${DIR}/${spmout}/spm/*.gz

	echo "${DIR}/${spmout}/spm"
	cd ${DIR}/${spmout}/spm

	echo "FMRI_PreprocessSPM8ForConn('${DIR}/${spmout}',${TR},${N},${refslice},${fwhmvol},'epi2anat','${acquis}');"
/usr/local/matlab11/bin/matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);

	FMRI_PreprocessSPM8ForConn('${DIR}/${spmout}',${TR},${N},${refslice},${fwhmvol},'${acquis}');

EOF

	echo "fslmerge -t ${DIR}/${spmout}/epi_spm.nii ${DIR}/${spmout}/spm/rr*"
	fslmerge -t ${DIR}/${spmout}/epi_spm.nii ${DIR}/${spmout}/spm/rr*
	echo "3drefit -TR ${TR}s ${DIR}/${spmout}/epi_spm.nii.gz"
	3drefit -TR ${TR}s ${DIR}/${spmout}/epi_spm.nii.gz
	#echo "gunzip ${DIR}/${spmout}/epi_spm.nii.gz"
	#gunzip ${DIR}/${spmout}/epi_spm.nii.gz

	filename=`ls -1 ${DIR}/${spmout}/spm/rmean* | sed -ne "1p"`
	echo "bet ${filename} ${DIR}/${spmout}/epi -m -n -f 0.5"
	bet ${filename} ${DIR}/${spmout}/epi -m -n -f 0.5
	#gunzip ${DIR}/${spmout}/epi_mask.nii.gz

	if [ ! -f ${DIR}/${spmout}/epi_spm.nii.gz ]
	then
		echo "no preprocessing epi file"
		exit 1
	fi
	
# 	# Grandmean scaling
# 	echo "Grand-mean scaling ${SUBJ}"
# 	fslmaths ${DIR}/${spmout}/epi_spm.nii -ing 10000 ${DIR}/${spmout}/epi_gms.nii.gz -odt float
# 
# 	# Temporal filtering
# 	echo "Band-pass filtering ${SUBJ}"
# 	3dFourier -lowpass ${lowpass} -highpass ${highpass} -retrend -prefix ${DIR}/${spmout}/epi_filt.nii.gz ${DIR}/${spmout}/epi_gms.nii.gz
# 
 	# Detrending
 	echo "Removing linear and quadratic trends for ${SUBJ}"
 	3dTstat -mean -prefix ${DIR}/${spmout}/epi_spm_mean.nii.gz ${DIR}/${spmout}/epi_spm.nii.gz
 	3dDetrend -polort 2 -prefix ${DIR}/${spmout}/epi_dt.nii.gz ${DIR}/${spmout}/epi_spm.nii.gz
 	3dcalc -a ${DIR}/${spmout}/epi_spm_mean.nii.gz -b ${DIR}/${spmout}/epi_dt.nii.gz -expr 'a+b' -prefix ${DIR}/${spmout}/epi_pp.nii.gz
	
fi

inEPI=${DIR}/${spmout}/epi_pp.nii.gz

# make nuisance directory
nuisance_dir=${DIR}/${spmout}/nuisance
mkdir -p ${nuisance_dir}

# 2. Seperate motion parameters into seperate files
echo "Splitting up ${subject} motion parameters"
motion=$(ls ${DIR}/${spmout}/spm/rp*)
awk '{print $1}' ${motion} > ${nuisance_dir}/mc1.1D
awk '{print $2}' ${motion} > ${nuisance_dir}/mc2.1D
awk '{print $3}' ${motion} > ${nuisance_dir}/mc3.1D
awk '{print $4}' ${motion} > ${nuisance_dir}/mc4.1D
awk '{print $5}' ${motion} > ${nuisance_dir}/mc5.1D
awk '{print $6}' ${motion} > ${nuisance_dir}/mc6.1D

## Extract signal for global, csf, and wm
# Global
echo "Extracting global signal for ${SUBJ}"
3dmaskave -mask ${DIR}/${spmout}/epi_mask.nii.gz -quiet ${inEPI} > ${nuisance_dir}/global.1D

# WM and CSF
/usr/local/matlab11/bin/matlab -nodisplay <<EOF

% Load Matlab Path
cd ${HOME}
p = pathdef;
addpath(p);

T1_NewSegment('${DIR}/${spmout}/orig.nii');

EOF

echo "binarize segmentation"
mri_binarize --i ${DIR}/${spmout}/c2orig.nii --min 0.9 --o ${DIR}/${spmout}/bc2orig.nii
mri_binarize --i ${DIR}/${spmout}/c3orig.nii --min 0.9 --o ${DIR}/${spmout}/bc3orig.nii

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

% Load Matlab Path
cd ${HOME}
p = pathdef;
addpath(p);

spm('Defaults','fMRI');

spm_jobman('initcfg'); % SPM8 only

matlabbatch{1}.spm.spatial.coreg.write.ref = {'${DIR}/${spmout}/orig_2mm.nii,1'};
matlabbatch{1}.spm.spatial.coreg.write.source = {
                                                 '${DIR}/${spmout}/bc2orig.nii,1'
                                                 '${DIR}/${spmout}/bc3orig.nii,1'
                                                 };
matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 0;
matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap   = [0 0 0];
matlabbatch{1}.spm.spatial.coreg.write.roptions.mask   = 0;
matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'r';

spm_jobman('run',matlabbatch);

EOF

echo "Extracting CSF signal for ${SUBJ}"
3dmaskave -mask ${DIR}/${spmout}/rbc3orig.nii -quiet ${inEPI} > ${nuisance_dir}/csf.1D
echo "Extracting WM signal for ${SUBJ}"
3dmaskave -mask ${DIR}/${spmout}/rbc2orig.nii -quiet ${inEPI} > ${nuisance_dir}/wm.1D

# perform nuisance variable regression
3dDeconvolve -polort A -num_stimts 8 \
                        -stim_file 1 ${nuisance_dir}/mc1.1D -stim_base 1 -stim_label 1 roll \
                        -stim_file 2 ${nuisance_dir}/mc2.1D -stim_base 2 -stim_label 2 pitch \
                        -stim_file 3 ${nuisance_dir}/mc3.1D -stim_base 3 -stim_label 3 yaw \
                        -stim_file 4 ${nuisance_dir}/mc4.1D -stim_base 4 -stim_label 4 dS \
                        -stim_file 5 ${nuisance_dir}/mc5.1D -stim_base 5 -stim_label 5 dL \
                        -stim_file 6 ${nuisance_dir}/mc6.1D -stim_base 6 -stim_label 6 dP \
                        -stim_file 7 ${nuisance_dir}/csf.1D -stim_base 7 -stim_label 7 csf \
                        -stim_file 8 ${nuisance_dir}/wm.1D -stim_base 8 -stim_label 8 wm \
                        -TR_1D ${TR}s -bucket ${DIR}/${spmout}/epi_nu_bucket -cbucket ${DIR}/${spmout}/epi_nu_cbucket \
                        -x1D ${DIR}/${spmout}/epi_nu_x1D.xmat.1D -input ${inEPI} -errts ${DIR}/${spmout}/epi_nu.nii.gz

# make sure that the TR is correct
echo "3drefit -TR ${TR}s ${DIR}/${spmout}/epi_nu.nii.gz"
3drefit -TR ${TR}s ${DIR}/${spmout}/epi_nu.nii.gz

# Bandpass filter
echo "3dBandpass -nodetrend -dt ${TR} -prefix ${DIR}/${spmout}/epi_ff.nii.gz ${highpass} ${lowpass} ${DIR}/${spmout}/epi_nu.nii.gz"
3dBandpass -nodetrend -dt ${TR} -prefix ${DIR}/${spmout}/epi_ff.nii.gz ${highpass} ${lowpass} ${DIR}/${spmout}/epi_nu.nii.gz

# Smoothing
3dmerge -1blur_fwhm ${fwhmvol} -doall -prefix ${DIR}/${spmout}/epi_smff.nii ${DIR}/${spmout}/epi_ff.nii.gz
3dmerge -1blur_fwhm ${fwhmvol} -doall -prefix ${DIR}/${spmout}/epi_smnu.nii ${DIR}/${spmout}/epi_nu.nii.gz
3dmerge -1blur_fwhm ${fwhmvol} -doall -prefix ${DIR}/${spmout}/epi_smspm.nii ${inEPI}

gunzip ${DIR}/${spmout}/epi_ff.nii.gz
gunzip ${inEPI}
gunzip ${DIR}/${spmout}/epi_nu.nii.gz

# Connectivity matrix
/usr/local/matlab11/bin/matlab -nodisplay <<EOF

% Load Matlab Path
cd ${HOME}
p = pathdef;
addpath(p);

[tseries,C,Cpar,Cz,Cparz] = FMRI_ConnectivityMatrix('${DIR}/${spmout}/epi_smff.nii','${DIR}/${spmout}/aparc_2mm.nii','${LOI}');
save('${DIR}/${spmout}/ConnMatrix_smff.mat','C','Cpar','Cz','Cparz');

[tseries,C,Cpar,Cz,Cparz] = FMRI_ConnectivityMatrix('${DIR}/${spmout}/epi_smnu.nii','${DIR}/${spmout}/aparc_2mm.nii','${LOI}');
save('${DIR}/${spmout}/ConnMatrix_smnu.mat','C','Cpar','Cz','Cparz');

[tseries,C,Cpar,Cz,Cparz] = FMRI_ConnectivityMatrix('${DIR}/${spmout}/epi_smspm.nii','${DIR}/${spmout}/aparc_2mm.nii','${LOI}');
save('${DIR}/${spmout}/ConnMatrix_smspm.mat','C','Cpar','Cz','Cparz');

[tseries,C,Cpar,Cz,Cparz] = FMRI_ConnectivityMatrix('${DIR}/${spmout}/epi_pp.nii','${DIR}/${spmout}/aparc_2mm.nii','${LOI}');
save('${DIR}/${spmout}/ConnMatrix_spm.mat','C','Cpar','Cz','Cparz');

[tseries,C,Cpar,Cz,Cparz] = FMRI_ConnectivityMatrix('${DIR}/${spmout}/epi_ff.nii','${DIR}/${spmout}/aparc_2mm.nii','${LOI}');
save('${DIR}/${spmout}/ConnMatrix_ff.mat','C','Cpar','Cz','Cparz');

[tseries,C,Cpar,Cz,Cparz] = FMRI_ConnectivityMatrix('${DIR}/${spmout}/epi_nu.nii','${DIR}/${spmout}/aparc_2mm.nii','${LOI}');
save('${DIR}/${spmout}/ConnMatrix_nu.mat','C','Cpar','Cz','Cparz');

EOF

