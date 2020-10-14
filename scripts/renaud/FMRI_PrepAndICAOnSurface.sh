#! /bin/bash

if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: FMRI_PrepAndICAOnSurface.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -o <path>  [-fwhmsurf <value>  -noprep  -fwhmvol <value>  -refslice <value>  -acquis <name>  -resampling <value>  -rmframe <value>  -ncomp <value>  -tr <value>  -s <value>  -surffwhm <value>  -v8]"
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
	echo "  -s                           : method for smoothing "
	echo "  -surffwhm                    : smoothing value (surface) "
	echo "  -v8                          : SPM version: spm8 "
	echo ""
	echo "Usage: FMRI_PrepAndICAOnSurface.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -o <path>  [-fwhmsurf <value>  -noprep  -fwhmvol <value>  -refslice <value>  -acquis <name>  -resampling <value>  -rmframe <value>  -ncomp <value>  -tr <value>  -s <value>  -surffwhm <value>  -v8]"
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
smooth=1
surffwhm=6

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: FMRI_PrepAndICAOnSurface.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -o <path>  [-fwhmsurf <value>  -noprep  -fwhmvol <value>  -refslice <value>  -acquis <name>  -resampling <value>  -rmframe <value>  -ncomp <value>  -tr <value>  -s <value>  -surffwhm <value>  -v8]"
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
		echo "  -s                           : method for smoothing "
		echo "  -surffwhm                    : smoothing value (surface) "
		echo "  -v8                          : SPM version: spm8 "
		echo ""
		echo "Usage: FMRI_PrepAndICAOnSurface.sh <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -o <path>  [-fwhmsurf <value>  -noprep  -fwhmvol <value>  -refslice <value>  -acquis <name>  -resampling <value>  -rmframe <value>  -ncomp <value>  -tr <value>  -s <value>  -surffwhm <value>  -v8]"
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
	-s)
		index=$[$index+1]
		eval smooth=\${$index}
		echo "method for smoothing : ${smooth}"
		;;
	-surffwhm)
		index=$[$index+1]
		eval surffwhm=\${$index}
		echo "smoothing value in surface : ${surffwhm}"
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
		echo "Usage: FMRI_PrepAndICAOnSurface.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -o <path>  [-fwhmsurf <value>  -noprep  -fwhmvol <value>  -refslice <value>  -acquis <name>  -resampling <value>  -rmframe <value>  -ncomp <value>  -tr <value>  -s <value>  -surffwhm <value>  -v8]"
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
		echo "  -s                           : method for smoothing "
		echo "  -surffwhm                    : smoothing value (surface) "
		echo "  -v8                          : SPM version: spm8 "
		echo ""
		echo "Usage: FMRI_PrepAndICAOnSurface.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -o <path>  [-fwhmsurf <value>  -noprep  -fwhmvol <value>  -refslice <value>  -acquis <name>  -resampling <value>  -rmframe <value>  -ncomp <value>  -tr <value>  -s <value>  -surffwhm <value>  -v8]"
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
#                              Project FMRI onto surface
#=========================================================================================

if [ ! -f ${DIR}/surf/lh.mid ]
then

/usr/local/matlab11/bin/matlab -nodisplay <<EOF
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

fi

if [ ! -f ${outdir}/register_epi2struct.dat ]
then
	echo "tkregister2 --mov ${spmout}/ssarepi.nii --s ${SUBJ} --regheader --noedit --reg ${outdir}/register_epi2struct.dat"
	tkregister2 --mov ${spmout}/ssarepi.nii --s ${SUBJ} --regheader --noedit --reg ${outdir}/register_epi2struct.dat
fi

if [ ! -f ${outdir}/surfepi_sm${smooth}.rh.nii ]
then

	if [ ${smooth} -eq 1 ]
	then
	
		# Left hemisphere
		echo "mri_vol2surf --mov ${spmout}/ssarepi.nii --reg ${outdir}/register_epi2struct.dat --interp trilin --projfrac 0.5 --hemi lh --o ${outdir}/surfepi_sm${smooth}.lh.nii --noreshape --cortex --surfreg sphere.reg"
		mri_vol2surf --mov ${spmout}/ssarepi.nii --reg ${outdir}/register_epi2struct.dat --interp trilin --projfrac 0.5 --hemi lh --o ${outdir}/surfepi_sm${smooth}.lh.nii --noreshape --cortex --surfreg sphere.reg
		 
		# Right hemisphere
		echo "mri_vol2surf --mov ${spmout}/ssarepi.nii --reg ${outdir}/register_epi2struct.dat --interp trilin --projfrac 0.5 --hemi rh --o ${outdir}/surfepi_sm${smooth}.rh.nii --noreshape --cortex --surfreg sphere.reg"
		mri_vol2surf --mov ${spmout}/ssarepi.nii --reg ${outdir}/register_epi2struct.dat --interp trilin --projfrac 0.5 --hemi rh --o ${outdir}/surfepi_sm${smooth}.rh.nii --noreshape --cortex --surfreg sphere.reg	

		# fsaverage
	
		# Left hemisphere
		echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${outdir}/surfepi_sm${smooth}.lh.nii --sfmt curv --noreshape --cortex --tval ${outdir}/surfepi_sm${smooth}_fsaverage.lh.nii --tfmt curv"
		mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${outdir}/surfepi_sm${smooth}.lh.nii --sfmt curv --noreshape --cortex --tval ${outdir}/surfepi_sm${smooth}_fsaverage.lh.nii --tfmt curv
		mris_fwhm --s fsaverage --hemi lh --smooth-only --i ${outdir}/surfepi_sm${smooth}_fsaverage.lh.nii --fwhm ${surffwhm} --o ${outdir}/surfepi_sm${smooth}_${surffwhm}_fsaverage.lh.nii
	
		# Right hemisphere
		echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${outdir}/surfepi_sm${smooth}.rh.nii --sfmt curv --noreshape --cortex --tval ${outdir}/surfepi_sm${smooth}_fsaverage.rh.nii --tfmt curv"
		mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${outdir}/surfepi_sm${smooth}.rh.nii --sfmt curv --noreshape --cortex --tval ${outdir}/surfepi_sm${smooth}_fsaverage.rh.nii --tfmt curv
		mris_fwhm --s fsaverage --hemi rh --smooth-only --i ${outdir}/surfepi_sm${smooth}_fsaverage.rh.nii --fwhm ${surffwhm} --o ${outdir}/surfepi_sm${smooth}_${surffwhm}_fsaverage.rh.nii
	
	else

		# Left hemisphere
		echo "mri_vol2surf --mov ${spmout}/ssarepi.nii --reg ${outdir}/register_epi2struct.dat --interp trilin --projfrac 0.5 --hemi lh --o ${outdir}/surfepi_sm${smooth}.lh.nii --noreshape --cortex --surfreg sphere.reg --surf-fwhm ${surffwhm}"
		mri_vol2surf --mov ${spmout}/ssarepi.nii --reg ${outdir}/register_epi2struct.dat --interp trilin --projfrac 0.5 --hemi lh --o ${outdir}/surfepi_sm${smooth}.lh.nii --noreshape --cortex --surfreg sphere.reg --surf-fwhm ${surffwhm}

		# Right hemisphere
		echo "mri_vol2surf --mov ${spmout}/ssarepi.nii --reg ${outdir}/register_epi2struct.dat --interp trilin --projfrac 0.5 --hemi rh --o ${outdir}/surfepi_sm${smooth}.rh.nii --noreshape --cortex --surfreg sphere.reg --surf-fwhm ${surffwhm}"
		mri_vol2surf --mov ${spmout}/ssarepi.nii --reg ${outdir}/register_epi2struct.dat --interp trilin --projfrac 0.5 --hemi rh --o ${outdir}/surfepi_sm${smooth}.rh.nii --noreshape --cortex --surfreg sphere.reg --surf-fwhm ${surffwhm}
	
	fi

fi


#=========================================================================================
#                              ICA Decomposition
#=========================================================================================

prefix=surfepi_sm${smooth}
icafolder=ica_${ncomps}_surf_nosm${smooth}
input=${outdir}
method=2

## Delete out dir
if [ -d ${input}/${icafolder} ]
then
	echo "rm -rf ${input}/${icafolder}"
	rm -rf ${input}/${icafolder}
fi

## Creates output folder
if [ ! -d ${input}/${icafolder} ]
then
	echo "mkdir ${input}/${icafolder}"
	mkdir ${input}/${icafolder}
fi

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

% Load Matlab Path
cd ${HOME}
p = pathdef;
addpath(p);

surf      = SurfStatReadSurf([fullfile('${SD}/${SUBJ}','surf/lh.white')]);
fnumleft  = size(surf.tri,1);
nbleft    = size(surf.coord,2);
surf      = SurfStatReadSurf([fullfile('${SD}/${SUBJ}','surf/rh.white')]);
fnumright = size(surf.tri,1);
nbright   = size(surf.coord,2);
clear surf;

if(${method}==1)
	sica = FMRI_SurfICANew('${input}',${TR},'${prefix}',${ncomps});
else
	plh  = fullfile('${input}',['${prefix}' '.lh.nii']);
	prh  = fullfile('${input}',['${prefix}' '.rh.nii']);
	sica = FMRI_SurfICA(plh,prh,${TR},${ncomps});
end

save(fullfile('${input}','${icafolder}','sica.mat'),'sica');

mask = 1:size(sica.S,1);

for j = 1:sica.nbcomp
	sig_c = FMRI_CorrectSignalOnSurface(double(sica.S(:,j)),mask,0.05,0);
	write_curv(fullfile('${input}','${icafolder}',['lh.ica_map_' num2str(j)]),sig_c(1:nbleft),fnumleft);
	write_curv(fullfile('${input}','${icafolder}',['rh.ica_map_' num2str(j)]),sig_c(nbleft+1:end),fnumright);
end

EOF


# Resampling to fsaverage and smoothing

SUBJECTS_DIR=${SD}

for ((ind = 1; ind <= ${ncomps}; ind += 1))
do

	# Left hemisphere
	mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${input}/${icafolder}/lh.ica_map_${ind} --sfmt curv --noreshape --cortex --tval ${input}/${icafolder}/lh.fsaverage_ica_map_${ind}.mgh --tfmt curv
	mris_fwhm --s fsaverage --hemi lh --smooth-only --i ${input}/${icafolder}/lh.fsaverage_ica_map_${ind}.mgh --fwhm ${surffwhm} --o ${input}/${icafolder}/lh.sm${surffwhm}_fsaverage_ica_map_${ind}.mgh

	# Right hemisphere
	mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${input}/${icafolder}/rh.ica_map_${ind} --sfmt curv --noreshape --cortex --tval ${input}/${icafolder}/rh.fsaverage_ica_map_${ind}.mgh --tfmt curv
	mris_fwhm --s fsaverage --hemi rh --smooth-only --i ${input}/${icafolder}/rh.fsaverage_ica_map_${ind}.mgh --fwhm ${surffwhm} --o ${input}/${icafolder}/rh.sm${surffwhm}_fsaverage_ica_map_${ind}.mgh
	
done
	
