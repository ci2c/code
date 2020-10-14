#! /bin/bash

if [ $# -lt 12 ]
then
	echo ""
	echo "Usage: FMRI_SubCorticalRegression.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -ospm <folder>  -o <folder>  -coi <file>  -clus <file> "
	echo ""
	echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
	echo "  -subj                        : Subject I "
	echo "  -ospm                        : output spm directory "
	echo "  -o                           : output "
	echo "  -coi                         : coi file "
	echo "  -clus                        : cluster file "
	echo ""
	echo "Usage: FMRI_SubCorticalRegression.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -ospm <folder>  -o <folder>  -coi <file>  -clus <file> "
	echo ""
	exit 1
fi

HOME=/home/renaud
index=1

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: FMRI_SubCorticalRegression.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -ospm <folder>  -o <folder>  -coi <file>  -clus <file> "
		echo ""
		echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subj                        : Subject I "
		echo "  -ospm                        : output spm directory "
		echo "  -o                           : output "
		echo "  -coi                         : coi file "
		echo "  -clus                        : cluster file "
		echo ""
		echo "Usage: FMRI_SubCorticalRegression.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -ospm <folder>  -o <folder>  -coi <file>  -clus <file> "
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
	-ospm)
		index=$[$index+1]
		eval spmout=\${$index}
		echo "output spm directory : $spmout"
		;;
	-o)
		index=$[$index+1]
		eval output=\${$index}
		echo "output : $output"
		;;
	-coi)
		index=$[$index+1]
		eval COI=\${$index}
		echo "coi file : $COI"
		;;
	-clus)
		index=$[$index+1]
		eval CLUS=\${$index}
		echo "cluster file : $CLUS"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: FMRI_PrepForSubCorticalRegression.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -ospm <folder>  -o <folder>  -coi <file>  -clus <file> "
		echo ""
		echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subj                        : Subject I "
		echo "  -ospm                        : output spm directory "
		echo "  -o                           : output "
		echo "  -coi                         : coi file "
		echo "  -clus                        : cluster file "
		echo ""
		echo "Usage: FMRI_PrepForSubCorticalRegression.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -ospm <folder>  -o <folder>  -coi <file>  -clus <file> "
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

if [ -z ${spmout} ]
then
	 echo "-ospm argument mandatory"
	 exit 1
fi

if [ -z ${output} ]
then
	 echo "-o argument mandatory"
	 exit 1
fi

if [ -z ${COI} ]
then
	 echo "-coi argument mandatory"
	 exit 1
fi

if [ -z ${CLUS} ]
then
	 echo "-clus argument mandatory"
	 exit 1
fi

DIR="${SD}/${SUBJ}"
SUBJECTS_DIR=${SD}
outdir=${DIR}/${spmout}/${output}

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

if [ ! -f ${DIR}/${spmout}/epi_subcort1.nii.gz ]
then
/usr/local/matlab11/bin/matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);

	spm('Defaults','fMRI');
	spm_jobman('initcfg'); % SPM8 only

	%% WORKING DIRECTORY
	%--------------------------------------------------------------------------
	clear jobs
	jobs{1}.spm.util.cdir.directory = cellstr('${DIR}/${spmout}');
	
	f = spm_select('FPList', fullfile('${DIR}/${spmout}','spm'), '^epi_.*\.nii$');
	
	a2 = spm_select('FPList', '${DIR}/${spmout}', '^orig_2mm.*\.nii$');
	
	jobs{end+1}.spm.spatial.coreg.write.ref           = cellstr(a2);
	jobs{end}.spm.spatial.coreg.write.source          = editfilenames(f,'prefix','svr');
	jobs{end}.spm.spatial.coreg.write.roptions.interp = 4;
	jobs{end}.spm.spatial.coreg.write.roptions.wrap   = [0 0 0];
	jobs{end}.spm.spatial.coreg.write.roptions.mask   = 0;
	jobs{end}.spm.spatial.coreg.write.roptions.prefix = 'r';
	
	jobs{end+1}.spm.spatial.coreg.write.ref           = cellstr(a2);
	jobs{end}.spm.spatial.coreg.write.source          = editfilenames(f(1,:),'prefix','mean');
	jobs{end}.spm.spatial.coreg.write.roptions.interp = 4;
	jobs{end}.spm.spatial.coreg.write.roptions.wrap   = [0 0 0];
	jobs{end}.spm.spatial.coreg.write.roptions.mask   = 0;
	jobs{end}.spm.spatial.coreg.write.roptions.prefix = 'r';

	spm_jobman('run',jobs);

EOF

	echo "fslmerge -t ${DIR}/${spmout}/epi_subcort1.nii ${DIR}/${spmout}/spm/rsvr*"
	fslmerge -t ${DIR}/${spmout}/epi_subcort1.nii ${DIR}/${spmout}/spm/rsvr*

fi

if [ ! -f ${DIR}/${spmout}/epi_maskSC.nii ]
then
	mri_extract_label ${DIR}/${spmout}/aparc_2mm.nii 17 53 18 54 10 49 12 51 11 50 13 52 28 60 ${DIR}/${spmout}/epi_maskSC.nii
fi

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

	icaFile    = '${DIR}/${spmout}/ica_40_surf_nosm2/sica.mat';
	COIs       = dlmread('${COI}');
	coiNames   = {'SMN','VIS','FPN','SRN','AUD','DMN','SPN'};
	clusFile   = '${CLUS}';
	maskFile   = '${DIR}/${spmout}/epi_maskSC.nii';
	spmDir     = '${DIR}/${spmout}/spm';
	f          = spm_select('FPList',spmDir,'^rp_.*\.txt$');
	motionFile = f(1,:);
	
	seed = FMRI_RegressionOnSSCortical('${SUBJ}',icaFile,COIs,coiNames,clusFile,maskFile,motionFile,spmDir,'${outdir}');

EOF

