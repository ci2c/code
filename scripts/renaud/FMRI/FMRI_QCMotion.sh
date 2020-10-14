#! /bin/bash

if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: FMRI_QCMotion.sh -d <folder>  -i <fmri>  -mc <ofmri>  -o <oudir>  [-dvth <value>  -fdth <value>] "
	echo ""
	echo "  -d              : working directory"
	echo "  -i              : no motion-corrected fMRI "
	echo "  -mc             : motion-corrected fMRI "
	echo "  -o              : output folder "
	echo "  OPTIONS "
	echo "  -dvth           : threshold value for DVARS (Default: p75 + 1.5*Interquartile) "
	echo "  -fdth           : threshold value for FDRMS (Default: p75 + 1.5*Interquartile) "
	echo "  -"
	echo ""
	echo "Usage: FMRI_QCMotion.sh -d <folder>  -i <fmri>  -mc <ofmri>  -o <oudir>  [-dvth <value>  -fdth <value>] "
	echo ""
	exit 1
fi

user=`whoami`

HOME=/home/${user}
index=1
DVTH="-1"
FDTH="-1"

computemomentspath=/NAS/tupac/renaud/HCP/scripts/hcp_functional_qc_pipeline_customizations-1.0/templates/misc/catalog/HCP_QC_PARALLEL/MotionOutliers/resources

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: FMRI_QCMotion.sh -d <folder>  -i <fmri>  -mc <ofmri>  -o <oudir>  [-dvth <value>  -fdth <value>] "
		echo ""
		echo "  -d              : working directory"
		echo "  -i              : no motion-corrected fMRI "
		echo "  -mc             : motion-corrected fMRI "
		echo "  -o              : output folder "
		echo "  OPTIONS "
		echo "  -dvth           : threshold value for DVARS (Default: p75 + 1.5*Interquartile) "
		echo "  -fdth           : threshold value for FDRMS (Default: p75 + 1.5*Interquartile) "
		echo "  -"
		echo ""
		echo "Usage: FMRI_QCMotion.sh -d <folder>  -i <fmri>  -mc <ofmri>  -o <oudir>  [-dvth <value>  -fdth <value>] "
		echo ""
		exit 1
		;;
	-d)
		index=$[$index+1]
		eval WorkingDirectory=\${$index}
		echo "WorkingDirectory : $WorkingDirectory"
		;;
	-i)
		index=$[$index+1]
		eval InputfMRI=\${$index}
		echo "InputfMRI : $InputfMRI"
		;;
	-mc)
		index=$[$index+1]
		eval OutputfMRI=\${$index}
		echo "OutputfMRI : $OutputfMRI"
		;;
	-o)
		index=$[$index+1]
		eval OutDir=\${$index}
		echo "OutDir : $OutDir"
		;;
	-dvth)
		index=$[$index+1]
		eval DVTH=\${$index}
		echo "DVTH : $DVTH"
		;;
	-fdth)
		index=$[$index+1]
		eval FDTH=\${$index}
		echo "FDTH : $FDTH"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: FMRI_QCMotion.sh -d <folder>  -i <fmri>  -mc <ofmri>  -o <oudir>  [-dvth <value>  -fdth <value>] "
		echo ""
		echo "  -d              : working directory"
		echo "  -i              : no motion-corrected fMRI "
		echo "  -mc             : motion-corrected fMRI "
		echo "  -o              : output folder "
		echo "  OPTIONS "
		echo "  -dvth           : threshold value for DVARS (Default: p75 + 1.5*Interquartile) "
		echo "  -fdth           : threshold value for FDRMS (Default: p75 + 1.5*Interquartile) "
		echo "  -"
		echo ""
		echo "Usage: FMRI_QCMotion.sh -d <folder>  -i <fmri>  -mc <ofmri>  -o <oudir>  [-dvth <value>  -fdth <value>] "
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done


echo ""
echo "START: FMRI_QCMotion.sh"
echo ""

OutputfMRIBasename=`basename ${OutputfMRI}`

if [ ! -d ${OutDir} ]; then mkdir -p ${OutDir}; fi
if [ -f ${OutDir}/QCmotion.txt ]; then rm -f ${OutDir}/QCmotion.txt; fi

echo "       Quality control of motion parameters " >> ${OutDir}/QCmotion.txt
echo "" >> ${OutDir}/QCmotion.txt
echo "" >> ${OutDir}/QCmotion.txt


echo ""
echo "#############################################"
echo "        Plot mcflirt parameters              "
echo "#############################################"
echo ""

matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);

	mc_par_file = '${WorkingDirectory}/${OutputfMRIBasename}.par'
	mc_abs_rms_file = '${WorkingDirectory}/${OutputfMRIBasename}_abs.rms'
	mc_rel_rms_file = '${WorkingDirectory}/${OutputfMRIBasename}_rel.rms'
	outname_prefix = '${OutputfMRIBasename}'
	output_dir = '${OutDir}'

	FMRI_plot_mcflirt_par( mc_par_file, mc_abs_rms_file, mc_rel_rms_file, output_dir, outname_prefix );

EOF

# Convert from radians to degrees: multiply 1-3rd columns by 180/pi = 57.296
awk '{print 57.296*$1, 57.296*$2, 57.296*$3, $4, $5, $6;}' ${WorkingDirectory}/${OutputfMRIBasename}.par > ${WorkingDirectory}/${OutputfMRIBasename}_deg.par

# Compute % of frames with relative movement above specified thresholds
thr1=0.3
pcnt_rel_rms_thr1=`awk 'BEGIN{count=0;} {if ($1 > t) count++} END{printf ("%.2f", count*100/NR)}' t=$thr1  ${WorkingDirectory}/${OutputfMRIBasename}_rel.rms`
thr2=0.5
pcnt_rel_rms_thr2=`awk 'BEGIN{count=0;} {if ($1 > t) count++} END{printf ("%.2f", count*100/NR)}' t=$thr2  ${WorkingDirectory}/${OutputfMRIBasename}_rel.rms`
thr3=0.15
pcnt_rel_rms_thr3=`awk 'BEGIN{count=0;} {if ($1 > t) count++} END{printf ("%.2f", count*100/NR)}' t=$thr3  ${WorkingDirectory}/${OutputfMRIBasename}_rel.rms`

# Compute 90 and 95th percentiles of relative movement
pcntile90_rel_rms=`cat ${WorkingDirectory}/${OutputfMRIBasename}_rel.rms | sort -n | awk 'BEGIN{i=0} {s[i]=$1; i++;} END{print s[int(NR*0.90-0.5)]}'`
pcntile95_rel_rms=`cat ${WorkingDirectory}/${OutputfMRIBasename}_rel.rms | sort -n | awk 'BEGIN{i=0} {s[i]=$1; i++;} END{print s[int(NR*0.95-0.5)]}'`

echo "Frames :" >> ${OutDir}/QCmotion.txt
echo "" >> ${OutDir}/QCmotion.txt
echo "Percent frames with rel.rms > $thr1 = $pcnt_rel_rms_thr1" >> ${OutDir}/QCmotion.txt
echo "Percent frames with rel.rms > $thr2 = $pcnt_rel_rms_thr2" >> ${OutDir}/QCmotion.txt
echo "Percent frames with rel.rms > $thr3 = $pcnt_rel_rms_thr3" >> ${OutDir}/QCmotion.txt
echo "90th percentile rel.rms = $pcntile90_rel_rms" >> ${OutDir}/QCmotion.txt
echo "95th percentile rel.rms = $pcntile95_rel_rms" >> ${OutDir}/QCmotion.txt
mean_rel_rms=`cat ${WorkingDirectory}/${OutputfMRIBasename}_rel_mean.rms`
echo "Mean rel.rms = $mean_rel_rms" >> ${OutDir}/QCmotion.txt
echo "" >> ${OutDir}/QCmotion.txt
echo "" >> ${OutDir}/QCmotion.txt



echo ""
echo "#############################################"
echo "           Intensity parameters              "
echo "#############################################"
echo ""

echo "Intensity :" >> ${OutDir}/QCmotion.txt
echo "" >> ${OutDir}/QCmotion.txt

meanfunc=${WorkingDirectory}/${OutputfMRIBasename}_meanvol  # available by including the -stats option in 'mcflirt'
mask=${WorkingDirectory}/${OutputfMRIBasename}_mask
normfactor=10000

### Normalize ###
echo -e "\n---- Normalize to median of $normfactor within mask ----"

P50=`fslstats $meanfunc -k $mask -P 50`
mcfoutnorm=${OutDir}/${OutputfMRIBasename}_norm
fslmaths $OutputfMRI -div $P50 -mul $normfactor $mcfoutnorm -odt float   #Need '-odt float' here! 


### Compute SD and tSNR ###
echo -e "\n---- Compute SD image and tSNR on motion corrected, median $normfactor normalized time series ----"

fslmaths $mcfoutnorm -Tmean ${mcfoutnorm}_mean
fslmaths $mcfoutnorm -Tstd ${mcfoutnorm}_std
fslmaths ${mcfoutnorm}_mean -div ${mcfoutnorm}_std ${mcfoutnorm}_tSNR
tSNRbrain=`fslstats ${mcfoutnorm}_tSNR -k $mask -P 50`
SDbrain=`fslstats ${mcfoutnorm}_std -k $mask -P 50`

echo "Median tSNR of brain = $tSNRbrain"
echo "Median SD (over time) of brain = $SDbrain"

echo "MOTION_QC_MEDIAN_tSNR=$tSNRbrain" >> ${OutDir}/QCmotion.txt
echo "MOTION_QC_SD=$SDbrain" >> ${OutDir}/QCmotion.txt
echo "MOTION_QC_MEDIANI=$P50" >> ${OutDir}/QCmotion.txt
echo "" >> ${OutDir}/QCmotion.txt


### Compute smoothness (using AFNI's '3dFWHMx') ###

echo -e "\n---- Compute smoothness (using AFNI's '3dFWHMx') of motion corrected, median $normfactor normalized time series ----"

# AFNI needs files with the full extension as input, so get file names with extension
mask3dFWHMx=`imglob -extension $mask`
input3dFWHMx=`imglob -extension $mcfoutnorm`
out3dFWHM=${OutDir}/3dFWHM.txt
rm -f $out3dFWHM  # remove file in case in case it already exists, since 3dFWHMx won't overwrite it
# Detrend over time with mean, linear, quadratic, and 5th order sin/cos terms 
# to keep it simple and fast for all runs
detrendorder=5  
FWHMvals=`3dFWHMx -mask $mask3dFWHMx -detrend $detrendorder -input $input3dFWHMx -combine -out $out3dFWHM`

FWHMx=`echo $FWHMvals | awk '{print $1}'`
FWHMy=`echo $FWHMvals | awk '{print $2}'`
FWHMz=`echo $FWHMvals | awk '{print $3}'`
FWHM=`echo $FWHMvals | awk '{print $4}'`  # final value is the "grand mean" (generated by using the -combine option)
fsl_tsplot -i $out3dFWHM -t '3dFWHMx estimated smoothness (mm)' -u 1 -a x,y,z --ymin=0 --ymax=5 -o ${OutDir}/smoothness.png
fsl_tsplot -i $out3dFWHM -t '3dFWHMx estimated smoothness, x-axis (mm)' -u 1 --start=1 --finish=1 --ymin=0 --ymax=5 -o ${OutDir}/smoothness_x.png
fsl_tsplot -i $out3dFWHM -t '3dFWHMx estimated smoothness, y-axis (mm)' -u 1 --start=2 --finish=2 --ymin=0 --ymax=5 -o ${OutDir}/smoothness_y.png
fsl_tsplot -i $out3dFWHM -t '3dFWHMx estimated smoothness, z-axis (mm)' -u 1 --start=3 --finish=3 --ymin=0 --ymax=5 -o ${OutDir}/smoothness_z.png

echo "FWHM = $FWHM (FWHMx = $FWHMx; FWHMy = $FWHMy; FWHMz = $FWHMz)"

echo "MOTION_QC_FWHMx=$FWHMx" >> ${OutDir}/QCmotion.txt
echo "MOTION_QC_FWHMy=$FWHMy" >> ${OutDir}/QCmotion.txt
echo "MOTION_QC_FWHMz=$FWHMz" >> ${OutDir}/QCmotion.txt
echo "MOTION_QC_FWHM=$FWHM" >> ${OutDir}/QCmotion.txt


### DVARS ###

echo ""
echo "DVARS"

metric=dvars

echo "fsl_motion_outliers -i $mcfoutnorm -o ${OutDir}/${OutputfMRIBasename}_motion_outliers_confound_${metric}.txt -s ${OutDir}/${OutputfMRIBasename}_motion_outliers_${metric}.txt -p ${OutDir}/${OutputfMRIBasename}_motion_outliers_${metric} --${metric} --nomoco -v"

fsl_motion_outliers -i $mcfoutnorm -o ${OutDir}/${OutputfMRIBasename}_motion_outliers_confound_${metric}.txt -s ${OutDir}/${OutputfMRIBasename}_motion_outliers_${metric}.txt -p ${OutDir}/${OutputfMRIBasename}_motion_outliers_${metric} --${metric} --nomoco -v

# Plot over a 0-100 range for now
#fsl_tsplot -i ${OutDir}/${OutputfMRIBasename}_motion_outliers_${metric}.txt -t 'Motion outlier '$OutputfMRIBasename' metric: '$metric -x "frame #" -y "metric value" --ymin=0 --ymax=100 -o ${OutDir}/${metric}.png

# Compute some quantitative metrics
moments=`awk -f $computemomentspath/compute_moments.awk ${OutDir}/${OutputfMRIBasename}_motion_outliers_${metric}.txt`

dvar_mean=`echo $moments | awk '{print $1}'`
dvar_u2=`echo $moments | awk '{print $2}'`
dvar_u3=`echo $moments | awk '{print $3}'`
dvar_u4=`echo $moments | awk '{print $4}'`
dvar_skew=`echo $moments | awk '{print $5}'`
dvar_kurt=`echo $moments | awk '{print $6}'`

echo "" >> ${OutDir}/QCmotion.txt
echo "DVARS" >> ${OutDir}/QCmotion.txt
echo "" >> ${OutDir}/QCmotion.txt

#  echo "Percent frames with dvars > $thr1 = $pcnt_dvar_thr1"
#  echo "Percent frames with dvars > $thr2 = $pcnt_dvar_thr2"
echo "Mean dvar = $dvar_mean" >> ${OutDir}/QCmotion.txt
echo "2nd moment = $dvar_u2" >> ${OutDir}/QCmotion.txt
echo "3rd moment = $dvar_u3" >> ${OutDir}/QCmotion.txt
echo "4th moment = $dvar_u4" >> ${OutDir}/QCmotion.txt
echo "Skewness = $dvar_skew" >> ${OutDir}/QCmotion.txt
echo "kurtosis = $dvar_kurt" >> ${OutDir}/QCmotion.txt


### FDRMS ###

echo ""
echo "FDRMS"

metric=fdrms

echo "fsl_motion_outliers -i $InputfMRI -o ${OutDir}/${OutputfMRIBasename}_motion_outliers_confound_${metric}.txt -s ${OutDir}/${OutputfMRIBasename}_motion_outliers_${metric}.txt -p ${OutDir}/${OutputfMRIBasename}_motion_outliers_${metric} --${metric} -v"

fsl_motion_outliers -i $InputfMRI -o ${OutDir}/${OutputfMRIBasename}_motion_outliers_confound_${metric}.txt -s ${OutDir}/${OutputfMRIBasename}_motion_outliers_${metric}.txt -p ${OutDir}/${OutputfMRIBasename}_motion_outliers_${metric} --${metric} -v

# Plot over a 0-1 range for now
#fsl_tsplot -i ${OutDir}/${OutputfMRIBasename}_motion_outliers_${metric}.txt -t 'Motion outlier '$OutputfMRIBasename' metric: '$metric -x "frame #" -y "metric value" --ymin=0 --ymax=1 -o ${OutDir}/${metric}.png

# Compute some quantitative metrics
moments=`awk -f $computemomentspath/compute_moments.awk ${OutDir}/${OutputfMRIBasename}_motion_outliers_${metric}.txt`

dvar_mean=`echo $moments | awk '{print $1}'`
dvar_u2=`echo $moments | awk '{print $2}'`
dvar_u3=`echo $moments | awk '{print $3}'`
dvar_u4=`echo $moments | awk '{print $4}'`
dvar_skew=`echo $moments | awk '{print $5}'`
dvar_kurt=`echo $moments | awk '{print $6}'`

echo "" >> ${OutDir}/QCmotion.txt
echo "FDRMS" >> ${OutDir}/QCmotion.txt
echo "" >> ${OutDir}/QCmotion.txt

#  echo "Percent frames with dvars > $thr1 = $pcnt_dvar_thr1"
#  echo "Percent frames with dvars > $thr2 = $pcnt_dvar_thr2"
echo "Mean fdrms = $dvar_mean" >> ${OutDir}/QCmotion.txt
echo "2nd moment = $dvar_u2" >> ${OutDir}/QCmotion.txt
echo "3rd moment = $dvar_u3" >> ${OutDir}/QCmotion.txt
echo "4th moment = $dvar_u4" >> ${OutDir}/QCmotion.txt
echo "Skewness = $dvar_skew" >> ${OutDir}/QCmotion.txt
echo "kurtosis = $dvar_kurt" >> ${OutDir}/QCmotion.txt


### DEFINE STRUGGLE FRAME ###

matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);

	dvars_file='${OutDir}/${OutputfMRIBasename}_motion_outliers_dvars.txt';
	fdrms_file='${OutDir}/${OutputfMRIBasename}_motion_outliers_fdrms.txt';

	if ( ${DVTH} < 0 ) && ( ${FDTH} < 0 )
		FMRI_FindMotionOutliers(dvars_file, fdrms_file);
	elif ( ${DVTH} < 0 ) && ( ${FDTH} >= 0 )
		FMRI_FindMotionOutliers(dvars_file, fdrms_file, [], ${FDTH}, []);
	elif ( ${DVTH} >= 0 ) && ( ${FDTH} < 0 )
		FMRI_FindMotionOutliers(dvars_file, fdrms_file, [], [], ${DVTH});
	else
		FMRI_FindMotionOutliers(dvars_file, fdrms_file, [], ${FDTH}, ${DVTH});
	end

EOF

echo "" >> ${OutDir}/QCmotion.txt
echo "STRUGGLING" >> ${OutDir}/QCmotion.txt
echo "" >> ${OutDir}/QCmotion.txt

outlier_file=`ls -1 ${OutDir} | grep "${OutputfMRIBasename}" | grep "FDRMS" | grep "DVARS" | grep ".txt"`
outlier_file=${OutDir}/${outlier_file}
num_zeros=`fgrep -o 0 ${outlier_file} | wc -l`
num_ones=`fgrep -o 1 ${outlier_file} | wc -l`
num_frames=$(( $num_zeros + $num_ones ))
prop=$(awk "BEGIN {print $num_zeros * 100 / $num_frames}")

echo "[MC]: outlier_file = $outlier_file" >> ${OutDir}/QCmotion.txt
echo "[MC]: num_zeros = $num_zeros" >> ${OutDir}/QCmotion.txt
echo "[MC]: num_ones = $num_ones" >> ${OutDir}/QCmotion.txt
echo "[MC]: num_frames = $num_frames" >> ${OutDir}/QCmotion.txt
echo "[MC]: prop = $prop" >> ${OutDir}/QCmotion.txt

rmrunth=50
if (( $(echo "$prop > $rmrunth" | bc -l) )); then
	echo "Run has more than $rm_run_th% outliers, remove this run." >> ${OutDir}/QCmotion.txt
else
	echo "Run has less than $rm_run_th% outliers, nothing change to this run." >> ${OutDir}/QCmotion.txt
fi

echo ""
echo "END: FMRI_QCMotion.sh"
echo ""

