#! /bin/bash

if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: FMRI_PrepAndICA.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -o <path>  [-fwhmsurf <value>  -noprep  -noica  -fwhmvol <value>  -refslice <value>  -acquis <name>  -resampling <value>  -rmframe <value>  -ncomp <value>  -tr <value>  -v8]"
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
	echo "  -resampling                  : '0' = no resampling ; '1' = resampling epi on anat "
	echo "  -rmframe                     : frame for removal "
	echo "  -ncomp                       : number of components "
	echo "  -tr                          : TR value "
	echo "  -v8                          : SPM version: spm8 "
	echo ""
	echo "Usage: FMRI_PrepAndICA.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -o <path>  [-fwhmsurf <value>  -noprep  -noica  -fwhmvol <value>  -refslice <value>  -acquis <name>  -resampling <value>  -rmframe <value>  -ncomp <value>  -tr <value>  -v8]"
	echo ""
	exit 1
fi

HOME=/home/renaud
index=1
fwhmsurf=1.5
fwhmvol=6
refslice=1
acquis=interleaved
resamp=0
remframe=5
ncomps=40
TRtmp=0
spm8=0
doprep=1
doica=1

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: FMRI_PrepAndICA.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -o <path>  [-fwhmsurf <value>  -noprep  -noica  -fwhmvol <value>  -refslice <value>  -acquis <name>  -resampling <value>  -rmframe <value>  -ncomp <value>  -tr <value>  -v8]"
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
		echo "  -resampling                  : '0' = no resampling ; '1' = resampling epi on anat "
		echo "  -rmframe                     : frame for removal "
		echo "  -ncomp                       : number of components "
		echo "  -tr                          : TR value "
		echo "  -v8                          : SPM version: spm8 "
		echo ""
		echo "Usage: FMRI_PrepAndICA.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -o <path>  [-fwhmsurf <value>  -noprep  -noica  -fwhmvol <value>  -refslice <value>  -acquis <name>  -resampling <value>  -rmframe <value>  -ncomp <value>  -tr <value>  -v8]"
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
	-noica)
		doica=0
		echo "Do not ICA"
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
		echo "Apply linear registration"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: FMRI_PrepAndICA.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -o <path>  [-fwhmsurf <value>  -noprep  -noica  -fwhmvol <value>  -refslice <value>  -acquis <name>  -resampling <value>  -rmframe <value>  -ncomp <value>  -tr <value>  -v8]"
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
		echo "  -resampling                  : '0' = no resampling ; '1' = resampling epi on anat "
		echo "  -rmframe                     : frame for removal "
		echo "  -ncomp                       : number of components "
		echo "  -tr                          : TR value "
		echo "  -v8                          : SPM version: spm8 "
		echo ""
		echo "Usage: FMRI_PrepAndICA.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -o <path>  [-fwhmsurf <value>  -noprep  -noica  -fwhmvol <value>  -refslice <value>  -acquis <name>  -resampling <value>  -rmframe <value>  -ncomp <value>  -tr <value>  -v8]"
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

if [ ! -d ${outdir} ]
then
	echo "mkdir -p ${outdir}"
	mkdir -p ${outdir}
fi

if [ ! -f ${outdir}/orig.nii ]
then
	echo "mri_convert ${DIR}/mri/orig.mgz ${outdir}/orig.nii"
	mri_convert ${DIR}/mri/orig.mgz ${outdir}/orig.nii
fi
anatFile=${outdir}/orig.nii

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
	spmout=${outdir}/spm8
	version=8
else
	spmout=${outdir}/spm12
	version=12
fi

if [ ${doprep} -eq 1 ]
then 	

	if [ -d ${spmout} ]
	then
		rm -rf ${spmout}
	fi
	mkdir -p ${spmout}/tmp
	echo "cp ${anatFile} ${spmout}/"
	cp ${anatFile} ${spmout}/

	echo "fslsplit ${epi} ${spmout}/tmp/epi_ -t"
	fslsplit ${epi} ${spmout}/tmp/epi_ -t
	for ((ind = 0; ind < ${remframe}; ind += 1))
	do
		filename=`ls -1 ${spmout}/tmp/ | sed -ne "1p"`
		rm -f ${spmout}/tmp/${filename}
	done

	echo "fslmerge -t ${spmout}/epi.nii ${spmout}/tmp/epi_*"
  	fslmerge -t ${spmout}/epi.nii ${spmout}/tmp/epi_*
	
	echo "gunzip ${spmout}/*.gz"
	gunzip ${spmout}/*.gz
	echo "rm -rf ${spmout}/tmp"
	rm -rf ${spmout}/tmp

	if [ ${spm8} -eq 1 ]
	then
		echo "FMRI_PreprocessingBySPM8('${spmout}','epi_','${anatFile}',${TR},${N},${refslice},${fwhmsurf},${fwhmvol},'epi2anat','${acquis}');"
/usr/local/matlab11/bin/matlab -nodisplay <<EOF

		% Load Matlab Path
		cd ${HOME}
		p = pathdef;
		addpath(p);

		FMRI_PreprocessingBySPM8('${spmout}','epi_','${anatFile}',${TR},${N},${refslice},${fwhmsurf},${fwhmvol},'epi2anat','${acquis}');  
EOF

	else
		if [ ! -f ${outdir}/y_orig.nii ]
		then 
			rm -f ${outdir}/y_orig.nii
		fi

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

		% Load Matlab Path
		p = pathdef;
		addpath(p);

		NSUBJECTS=1;
		FUNCTIONAL_FILE=cellstr(conn_dir(fullfile('${spmout}','epi*.nii')));
		STRUCTURAL_FILE=cellstr(conn_dir(fullfile('${spmout}','orig*.nii')));
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

		FMRI_PreprocessingBySPM12(STRUCTURAL_FILE,XFUNCTIONAL_FILES,steps,opt_prep);
EOF

	fi
	
	if [ -f ${outdir}/epi_v${version}_mask.nii ]
	then
		rm -f ${outdir}/epi_v${version}_mask.nii
	fi
	if [ -f ${outdir}/wepi_v${version}_mask.nii ]
	then
		rm -f ${outdir}/wepi_v${version}_mask.nii
	fi

	# Native space
	filename=`ls -1 ${spmout}/mean* | sed -ne "1p"`
	echo "bet ${filename} ${outdir}/epi_v${version} -m -n -f 0.5"
	bet ${filename} ${outdir}/epi_v${version} -m -n -f 0.5
	gunzip ${outdir}/epi_v${version}_mask.nii.gz

	# Normalized space
	filename=`ls -1 ${spmout}/wmean* | sed -ne "1p"`
	echo "bet ${filename} ${outdir}/wepi_v${version} -m -n -f 0.5"
	bet ${filename} ${outdir}/wepi_v${version} -m -n -f 0.5
	gunzip ${outdir}/wepi_v${version}_mask.nii.gz

else
	echo "No preprocessing"
fi

epiFile=`ls -1 ${spmout}/sv*.nii | sed -ne "1p"`
if [ ! -f ${epiFile} ]
then
	echo "no preprocessed epi file"
	exit 1
fi

if [ ! -f ${outdir}/epi_v${version}_mask.nii ]
then
	filename=`ls -1 ${spmout}/mean* | sed -ne "1p"`
	echo "bet ${filename} ${outdir}/epi_v${version} -m -n -f 0.5"
	bet ${filename} ${outdir}/epi_v${version} -m -n -f 0.5
	gunzip ${outdir}/epi_v${version}_mask.nii.gz
fi


#=========================================================================================
#                              ICA Decomposition
#=========================================================================================

if [ ${doica} -eq 1 ]
then

	icafolder=ica_${ncomps}_vol_v${version}

	## Delete ICA folder
	if [ -d ${outdir}/${icafolder} ]
	then
		echo "rm -rf ${outdir}/${icafolder}"
		rm -rf ${outdir}/${icafolder}
	fi

	## Creates ICA folder
	mkdir ${outdir}/${icafolder}

	## ICA Decomposition
	/usr/local/matlab11/bin/matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);

	hdr  = spm_vol('${epiFile}');
	vol  = spm_read_vols(hdr);
	dim  = size(vol);
	sica = FMRI_ICA(vol,fullfile('${outdir}',['epi_v' num2str(${version}) '_mask.nii']),${TR},${ncomps});

	save(fullfile('${outdir}','${icafolder}','sica.mat'),'sica');

	mask = 1:size(sica.S,1);

	mepiFile = spm_select('FPList', '${spmout}', '^mean.*\.nii$');
	hdrmap   = spm_vol(mepiFile);
	ind      = find(sica.mask(:)>0);

	mapFiles = {};
	for j = 1:sica.nbcomp
		sig_c = FMRI_CorrectSignalOnSurface(double(sica.S(:,j)),mask,0.05,0);

		map      = zeros(dim(1)*dim(2)*dim(3),1);
		map(ind) = sig_c;
		map      = reshape(map,dim(1),dim(2),dim(3));

		mapFiles{j} = fullfile('${outdir}','${icafolder}',['ica_map_' num2str(j) '.nii']);
	 	hdrmap.fname = mapFiles{j};
		spm_write_vol(hdrmap,map);
	end

	mapFiles{end+1} = fullfile('${outdir}',['epi_v' num2str(${version}) '_mask.nii']);

	if ${version}==8

		% Template Normalization
		spm('Defaults','fMRI');
		spm_jobman('initcfg'); % SPM8 and SPM12

		clear jobs
		jobs = {};

		a = which('spm_normalise');
		[path] = fileparts(a);
		    
		jobs{1}.spm.spatial.normalise.estwrite.subj.source       = {mepiFile};
		jobs{1}.spm.spatial.normalise.estwrite.subj.wtsrc        = '';
		jobs{1}.spm.spatial.normalise.estwrite.subj.resample     = mapFiles;
		jobs{1}.spm.spatial.normalise.estwrite.eoptions.template = {fullfile(path,'templates/EPI.nii')};
		jobs{1}.spm.spatial.normalise.estwrite.eoptions.weight   = '';
		jobs{1}.spm.spatial.normalise.estwrite.eoptions.smosrc   = 8;
		jobs{1}.spm.spatial.normalise.estwrite.eoptions.smoref   = 0;
		jobs{1}.spm.spatial.normalise.estwrite.eoptions.regtype  = 'mni';
		jobs{1}.spm.spatial.normalise.estwrite.eoptions.cutoff   = 25;
		jobs{1}.spm.spatial.normalise.estwrite.eoptions.nits     = 16;
		jobs{1}.spm.spatial.normalise.estwrite.eoptions.reg      = 1;
		jobs{1}.spm.spatial.normalise.estwrite.roptions.preserve = 0;
		jobs{1}.spm.spatial.normalise.estwrite.roptions.bb       = [-78 -112 -50; 78 76 85];
		jobs{1}.spm.spatial.normalise.estwrite.roptions.vox      = [2 2 2];
		jobs{1}.spm.spatial.normalise.estwrite.roptions.interp   = 2;
		jobs{1}.spm.spatial.normalise.estwrite.roptions.wrap     = [0 0 0];
		jobs{1}.spm.spatial.normalise.estwrite.roptions.prefix   = 'w';

		spm_jobman('run',jobs);

	else

		% Template Normalization
		spm('Defaults','fMRI');
		spm_jobman('initcfg'); % SPM8 and SPM12
	
		matlabbatch = {};
		[p,n,e] = fileparts('${anatFile}');    
		if ~exist(fullfile(p,['y_' n e]),'file')
			matlabbatch{end+1}.spm.spatial.normalise.est.subj.vol        = cellstr(anatFile);
			matlabbatch{end}.spm.spatial.normalise.est.eoptions.biasreg  = 0.0001;
			matlabbatch{end}.spm.spatial.normalise.est.eoptions.biasfwhm = 60;
			matlabbatch{end}.spm.spatial.normalise.est.eoptions.tpm      = {'/home/global/matlab_toolbox/spm12b/tpm/TPM.nii'};
			matlabbatch{end}.spm.spatial.normalise.est.eoptions.affreg   = 'mni';
			matlabbatch{end}.spm.spatial.normalise.est.eoptions.reg      = [0 0.001 0.5 0.05 0.2];
			matlabbatch{end}.spm.spatial.normalise.est.eoptions.fwhm     = 0;
			matlabbatch{end}.spm.spatial.normalise.est.eoptions.samp     = 3;
		end

		matlabbatch{end+1}.spm.spatial.normalise.write.subj.def      = cellstr(fullfile(p,['y_' n e]));
		matlabbatch{end}.spm.spatial.normalise.write.subj.resample   = mapFiles;
		matlabbatch{end}.spm.spatial.normalise.write.woptions.bb     = [-78 -112 -70; 78 76 85];
		matlabbatch{end}.spm.spatial.normalise.write.woptions.vox    = [2 2 2];
		matlabbatch{end}.spm.spatial.normalise.write.woptions.interp = 4;

		spm_jobman('run',matlabbatch);

	end

	EOF



	#=========================================================================================
	#                             Mapping on cortical surface
	#=========================================================================================

	epiFile=`ls -1 ${spmout}/ss*.nii | sed -ne "1p"`

	if [ ! -f ${outdir}/${icafolder}/rh.fsaverage_ica_map_${ncomps}.mgh ]
	then

		if [ ! -f ${outdir}/register_epi2struct_v${version}.dat ]
		then
			echo "tkregister2 --mov ${epiFile} --s ${SUBJ} --regheader --noedit --reg ${outdir}/register_epi2struct_v${version}.dat"
			tkregister2 --mov ${epiFile} --s ${SUBJ} --regheader --noedit --reg ${outdir}/register_epi2struct_v${version}.dat
		fi

		for ((ind = 1; ind <= ${ncomps}; ind += 1))
		do

			# native surface
	
			# Left hemisphere
			echo "mri_vol2surf --mov ${outdir}/${icafolder}/ica_map_${ind}.nii --reg ${outdir}/register_epi2struct_v${version}.dat --interp trilin --projfrac 0.5 --hemi lh --o ${outdir}/${icafolder}/lh.ica_map_${ind}.mgh --noreshape --cortex --surfreg sphere.reg"
			mri_vol2surf --mov ${outdir}/${icafolder}/ica_map_${ind}.nii --reg ${outdir}/register_epi2struct_v${version}.dat --interp trilin --projfrac 0.5 --hemi lh --o ${outdir}/${icafolder}/lh.ica_map_${ind}.mgh --noreshape --cortex --surfreg sphere.reg
				 
			# Right hemisphere
			echo "mri_vol2surf --mov ${outdir}/${icafolder}/ica_map_${ind}.nii --reg ${outdir}/register_epi2struct_v${version}.dat --interp trilin --projfrac 0.5 --hemi rh --o ${outdir}/${icafolder}/rh.ica_map_${ind}.mgh --noreshape --cortex --surfreg sphere.reg"
			mri_vol2surf --mov ${outdir}/${icafolder}/ica_map_${ind}.nii --reg ${outdir}/register_epi2struct_v${version}.dat --interp trilin --projfrac 0.5 --hemi rh --o ${outdir}/${icafolder}/rh.ica_map_${ind}.mgh --noreshape --cortex --surfreg sphere.reg
	
			# fsaverage surface
	
			# Left hemisphere
			echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${outdir}/${icafolder}/lh.ica_map_${ind}.mgh --sfmt curv --noreshape --cortex --tval ${outdir}/${icafolder}/lh.fsaverage_ica_map_${ind}.mgh --tfmt curv"
			mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${outdir}/${icafolder}/lh.ica_map_${ind}.mgh --sfmt curv --noreshape --cortex --tval ${outdir}/${icafolder}/lh.fsaverage_ica_map_${ind}.mgh --tfmt curv
	
			# Right hemisphere
			echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${outdir}/${icafolder}/lh.ica_map_${ind}.mgh --sfmt curv --noreshape --cortex --tval ${outdir}/${icafolder}/lh.fsaverage_ica_map_${ind}.mgh --tfmt curv"
			mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${outdir}/${icafolder}/lh.ica_map_${ind}.mgh --sfmt curv --noreshape --cortex --tval ${outdir}/${icafolder}/lh.fsaverage_ica_map_${ind}.mgh --tfmt curv
	
		done
	
	else

		echo "Mapping on cortical surface: already done"
	
	fi

fi	
