#! /bin/bash

if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: FCON_PrepAndICA.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -o <path>  [-fwhmsurf <value>  -noprep  -fwhmvol <value>  -refslice <value>  -acquis <name>  -rmframe <value>  -ncomp <value>  -tr <value>  -v8]"
	echo ""
	echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
	echo "  -subj                        : Subject I "
	echo "  -epi                         : fmri file "
	echo "  -o                           : output path "
	echo "  -fwhmsurf                    : smoothing value (volume) before projection "
	echo "  -noprep                      : do not fMRI preprocessing "
	echo "  -fwhmvol                     : smoothing value (volume) "
	echo "  -refslice                    : slice of reference for slice timing correction "
	echo "  -acquis                      : 'ascending' or 'interleaved' "
	echo "  -rmframe                     : frame for removal "
	echo "  -ncomp                       : number of components "
	echo "  -tr                          : TR value "
	echo "  -v8                          : SPM version: spm8 "
	echo ""
	echo "Usage: FMRI_PrepAndICA.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -o <path>  [-fwhmsurf <value>  -noprep  -fwhmvol <value>  -refslice <value>  -acquis <name>  -rmframe <value>  -ncomp <value>  -tr <value>  -v8]"
	echo ""
	exit 1
fi

HOME=/home/renaud
index=1
fwhmsurf=1.5
fwhmvol=6
refslice=1
acquis=interleaved
remframe=5
ncomps=40
TRtmp=0
spm8=0
doprep=1

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: FMRI_PrepAndICA.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -o <path>  [-fwhmsurf <value>  -noprep  -fwhmvol <value>  -refslice <value>  -acquis <name>  -rmframe <value>  -ncomp <value>  -tr <value>  -v8]"
		echo ""
		echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subj                        : Subject I "
		echo "  -epi                         : fmri file "
		echo "  -o                           : output path "
		echo "  -fwhmsurf                    : smoothing value (volume) before projection "
		echo "  -noprep                      : do not fMRI preprocessing "
		echo "  -fwhmvol                     : smoothing value (volume) "
		echo "  -refslice                    : slice of reference for slice timing correction "
		echo "  -acquis                      : 'ascending' or 'interleaved' "
		echo "  -rmframe                     : frame for removal "
		echo "  -ncomp                       : number of components "
		echo "  -tr                          : TR value "
		echo "  -v8                          : SPM version: spm8 "
		echo ""
		echo "Usage: FMRI_PrepAndICA.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -o <path>  [-fwhmsurf <value>  -noprep  -fwhmvol <value>  -refslice <value>  -acquis <name>  -rmframe <value>  -ncomp <value>  -tr <value>  -v8]"
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
	-noprep)
		doprep=0
		echo "Do not fMRI preprocessing"
		;;
	-o)
		index=$[$index+1]
		eval outdir=\${$index}
		echo "output path : $outdir"
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
	-ncomp)
		index=$[$index+1]
		eval ncomps=\${$index}
		echo "number of components : ${ncomps}"
		;;
	-tr)
		index=$[$index+1]
		eval TRtmp=\${$index}
		echo "TR value : ${TRtmp}"
		;;
	-v8)
		spm8=1
		echo "SPM version: spm8"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: FMRI_PrepAndICA.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -o <path>  [-fwhmsurf <value>  -noprep  -fwhmvol <value>  -refslice <value>  -acquis <name>  -rmframe <value>  -ncomp <value>  -tr <value>  -v8]"
		echo ""
		echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subj                        : Subject I "
		echo "  -epi                         : fmri file "
		echo "  -o                           : output path "
		echo "  -fwhmsurf                    : smoothing value (volume) before projection "
		echo "  -noprep                      : do not fMRI preprocessing "
		echo "  -fwhmvol                     : smoothing value (volume) "
		echo "  -refslice                    : slice of reference for slice timing correction "
		echo "  -acquis                      : 'ascending' or 'interleaved' "
		echo "  -rmframe                     : frame for removal "
		echo "  -ncomp                       : number of components "
		echo "  -tr                          : TR value "
		echo "  -v8                          : SPM version: spm8 "
		echo ""
		echo "Usage: FMRI_PrepAndICA.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -o <path>  [-fwhmsurf <value>  -noprep  -fwhmvol <value>  -refslice <value>  -acquis <name>  -rmframe <value>  -ncomp <value>  -tr <value>  -v8]"
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

if [ -z ${outdir} ]
then
	 echo "-o argument mandatory"
	 exit 1
fi


DIR="${SD}/${SUBJ}"
SUBJECTS_DIR=${SD}

if [ ! -d ${outdir}/anat ]
then
	echo "mkdir -p ${outdir}/anat"
	mkdir -p ${outdir}/anat
fi

if [ ! -f ${outdir}/anat/orig.nii ]
then
	echo "mri_convert ${DIR}/mri/orig.mgz ${outdir}/anat/orig.nii"
	mri_convert ${DIR}/mri/orig.mgz ${outdir}/anat/orig.nii
fi
if [ ! -f ${outdir}/anat/parc.nii ]
then
	echo "mri_convert ${DIR}/mri/aparc.a2009s+aseg.mgz ${outdir}/anat/parc.nii"
	mri_convert ${DIR}/mri/aparc.a2009s+aseg.mgz ${outdir}/anat/parc.nii
fi
anatFile=${outdir}/anat/orig.nii
parcFile=${outdir}/anat/parc.nii

if [ ${TRtmp} -eq 0 ]
then
	TR=$(mri_info ${epi} | grep TR | awk '{print $2}')
	TR=$(echo "$TR/1000" | bc -l)
else
	TR=${TRtmp}
fi
N=$(mri_info ${epi} | grep dimensions | awk '{print $6}')

echo $TR
echo $N

#=========================================================================================
#                           PREPROCESSING WITH SPM
#=========================================================================================

if [ ${spm8} -eq 1 ]
then
	version=8
	spmout=${outdir}/fmri_${version}
else
	version=12
	spmout=${outdir}/fmri_${version}
fi

if [ ${doprep} -eq 1 ]
then 	

	if [ -d ${spmout} ]
	then
		rm -rf ${spmout}
	fi
	mkdir ${spmout}

	echo "fslsplit ${epi} ${spmout}/epi_ -t"
	fslsplit ${epi} ${spmout}/epi_ -t
	for ((ind = 0; ind < ${remframe}; ind += 1))
	do
		filename=`ls -1 ${spmout}/ | sed -ne "1p"`
		rm -f ${spmout}/${filename}
	done
	echo "fslmerge -t ${spmout}/fmri.nii ${spmout}/epi_*"
	fslmerge -t ${spmout}/fmri.nii ${spmout}/epi_*
	echo "gunzip ${spmout}/fmri.nii.gz"
	gunzip ${spmout}/fmri.nii.gz
	rm -f ${spmout}/epi_*

	if [ ${spm8} -eq 1 ]
	then
		echo "FConn_PreprocessingSPM8 running..."
/usr/local/matlab11/bin/matlab -nodisplay <<EOF

		% Load Matlab Path
		cd ${HOME}
		p = pathdef;
		addpath(p);

		funcFile   = cellstr(conn_dir(fullfile('${outdir}','fmri.nii')));
		structFile = cellstr(conn_dir(fullfile('${outdir}','orig.nii')));
		
		nsubjects  = length(funcFile);
		nsessions  = length(funcFile)/nsubjects;
		funcFile   = reshape(funcFile,[nsubjects,nsessions]);

		disp([num2str(size(funcFile,1)),' subjects']);
		disp([num2str(size(funcFile,2)),' sessions']);

		for nsub=1:nsubjects 
		    for nses=1:nsessions
			functionalFiles{nsub}{nses}{1}=funcFile{nsub,nses};
			structuralFiles{nsub}{1} = structFile{nsub};
		    end
		end

		steps = {'segmentation','slicetiming','realignment','coregistration','normalization','smoothing'};
		opt = struct('TR',${TR},'center',1,'reorient',eye(4),'vox',2,'fwhmsurf',${fwhmsurf},'fwhm', ${fwhmvol},'segment','new','acquisition','${acquis}','parc','${parcFile}','structural_template',fullfile(fileparts(which('spm')),'templates','T1.nii'),'functional_template',fullfile(fileparts(which('spm')),'templates','EPI.nii'));

		for nsub=1:length(functionalFiles)
		    for nses=1:length(functionalFiles{nsub})
			if ~iscell(functionalFiles{nsub}{nses})
			    functionalFiles{nsub}{nses}=cellstr(functionalFiles{nsub}{nses});
			end
		    end
		end

		xfunctionalFiles = functionalFiles;
		for nsub=1:length(functionalFiles)
		    for nses=1:length(functionalFiles{nsub})
			[tempa,tempb,tempc]=fileparts(functionalFiles{nsub}{nses}{1}); 
			if length(functionalFiles{nsub}{nses})==1&&strcmp(tempc,'.nii'),
			    xfunctionalFiles{nsub}{nses}=cellstr(spm_select('ExtFPList',tempa,['^',tempb,tempc],1:1e4)); 
			end
		    end
		end
		nsubjects = length(functionalFiles);
		for nsub=1:length(structuralFiles),if ~iscell(structuralFiles{nsub}),structuralFiles{nsub}=cellstr(structuralFiles{nsub});end;end

		FConn_PreprocessingSPM8(structuralFiles,xfunctionalFiles,steps,opt);
EOF

	else
		if [ ! -f ${outdir}/y_c0orig.nii ]
		then 
			rm -f ${outdir}/y_c0orig.nii
		fi

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

		% Load Matlab Path
		cd ${HOME}
		p = pathdef;
		addpath(p);

		funcFile   = cellstr(conn_dir(fullfile('${outdir}','fmri.nii')));
		structFile = cellstr(conn_dir(fullfile('${outdir}','orig.nii')));
		
		nsubjects  = length(funcFile);
		nsessions  = length(funcFile)/nsubjects;
		funcFile   = reshape(funcFile,[nsubjects,nsessions]);

		disp([num2str(size(funcFile,1)),' subjects']);
		disp([num2str(size(funcFile,2)),' sessions']);

		for nsub=1:nsubjects 
		    for nses=1:nsessions
			functionalFiles{nsub}{nses}{1}=funcFile{nsub,nses};
			structuralFiles{nsub}{1} = structFile{nsub};
		    end
		end

		steps = {'segmentation','slicetiming','realignment','coregistration','normalization','smoothing'};
		opt = struct('TR',${TR},'center',1,'reorient',eye(4),'vox',2,'fwhmsurf',${fwhmsurf},'fwhm', ${fwhmvol},'segment','new','acquisition','${acquis}','parc','${parcFile}','structural_template',fullfile(fileparts(which('spm')),'templates','T1.nii'),'functional_template',fullfile(fileparts(which('spm')),'templates','EPI.nii'));

		for nsub=1:length(functionalFiles)
		    for nses=1:length(functionalFiles{nsub})
			if ~iscell(functionalFiles{nsub}{nses})
			    functionalFiles{nsub}{nses}=cellstr(functionalFiles{nsub}{nses});
			end
		    end
		end

		xfunctionalFiles = functionalFiles;
		for nsub=1:length(functionalFiles)
		    for nses=1:length(functionalFiles{nsub})
			[tempa,tempb,tempc]=fileparts(functionalFiles{nsub}{nses}{1}); 
			if length(functionalFiles{nsub}{nses})==1&&strcmp(tempc,'.nii'),
			    xfunctionalFiles{nsub}{nses}=cellstr(spm_select('ExtFPList',tempa,['^',tempb,tempc],1:1e4)); 
			end
		    end
		end
		nsubjects = length(functionalFiles);
		for nsub=1:length(structuralFiles),if ~iscell(structuralFiles{nsub}),structuralFiles{nsub}=cellstr(structuralFiles{nsub});end;end

		FConn_PreprocessingSPM12(structuralFiles,xfunctionalFiles,steps,opt);
EOF

	fi
	
	# Native space
	filename=`ls -1 ${spmout}/mean*.nii | sed -ne "1p"`
	echo "bet ${filename} ${spmout}/epi_v${version} -m -n -f 0.5"
	bet ${filename} ${spmout}/epi_v${version} -m -n -f 0.5
	gunzip ${spmout}/epi_v${version}_mask.nii.gz

	# Normalized space
	filename=`ls -1 ${spmout}/wmean*.nii | sed -ne "1p"`
	echo "bet ${filename} ${spmout}/wepi_v${version} -m -n -f 0.5"
	bet ${filename} ${spmout}/wepi_v${version} -m -n -f 0.5
	gunzip ${spmout}/wepi_v${version}_mask.nii.gz

else
	echo "No preprocessing"
fi

