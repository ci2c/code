#!/bin/bash

InputDataM0=/NAS/tupac/matthieu/Long_MRI/M0;
InputDataM12=/NAS/tupac/matthieu/Long_MRI/M12;
InputTimeDiffFile=/NAS/tupac/matthieu/Long_MRI/TimeDiff.txt;
InputSubjectsFile=/NAS/tupac/matthieu/Long_MRI/Subjects.txt;

## Step 1. Compute Longitudinal Pairwise Registration
if [ -s ${InputSubjectsFile} ] && [ -s ${InputTimeDiffFile} ]
then
	matlab -nodisplay <<EOF
		
	%% Load Matlab Path: Matlab 14 and SPM12 version
	cd ${HOME}
	p = pathdef;
	addpath(p);

	Longitudinal_PairwiseReg('${InputDataM0}', '${InputDataM12}', '${InputTimeDiffFile}', '${InputSubjectsFile}')
EOF
fi

## Step 2. Segment average subjects
if [ -s ${InputSubjectsFile} ]
then	
	while read subject
	do
		qbatch -q M32_q -oe /NAS/tupac/matthieu/Logdir -N LongSeg_${subject}_SPM12 SPM12_SegmentAvgSubject.sh -d ${InputDataM0} -subj ${subject}
		sleep 1
	done < ${InputSubjectsFile}
fi

WaitForJobs.sh LongSeg_

## Step 3. Mutliply segmented class1 images by Jacobian rates
if [ -s ${InputSubjectsFile} ]
then	
	while read subject
	do
		fslmaths ${InputDataM0}/c1avg_${subject}_M0_T1.nii -mul ${InputDataM0}/jd_${subject}_M0_T1_${subject}_M12_T1.nii ${InputDataM0}/c1avg_jd_${subject}_M0_T1.nii.gz
		gunzip ${InputDataM0}/c1avg_jd_${subject}_M0_T1.nii.gz
	done < ${InputSubjectsFile}
fi

## Step 4. Compute DARTEL Template & Normalize class1 modulated by jacobian rate to MNI space
if [ -s ${InputSubjectsFile} ]
then
	matlab -nodisplay <<EOF
		
	%% Load Matlab Path: Matlab 14 and SPM12 version
	cd ${HOME}
	p = pathdef;
	addpath(p);

	DARTELTemplate_NormalizeMNI('${InputDataM0}', '${InputSubjectsFile}');
EOF
fi