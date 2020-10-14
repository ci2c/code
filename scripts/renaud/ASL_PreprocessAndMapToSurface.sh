#! /bin/bash

if [ $# -lt 12 ]
then
	echo ""
	echo "Usage:  ASL_PreprocessAndMapToSurface.sh  -sd <path>  -subj <patientname>  -asl1 <path>  -asl2 <path>  -o <name>  -fwhm <value> "
	echo ""
	echo "  -sd          : Path to SUBJECTS_DIR "
	echo "  -subj        : Subject name "
	echo "  -asl1        : asl control file (.nii) "
	echo "  -asl2        : asl label file (.nii) "
	echo "  -o           : output name "
	echo "  -fwhm        : fwhm value "
	echo ""
	echo "Usage:  ASL_PreprocessAndMapToSurface.sh  -sd <path>  -subj <patientname>  -asl1 <path>  -asl2 <path>  -o <name>  -fwhm <value> "
	echo ""
	echo "Author: Renaud Lopes - CHRU Lille - Mar 31, 2014"
	echo ""
	exit 1
fi

index=1

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage:  ASL_PreprocessAndMapToSurface.sh  -sd <path>  -subj <patientname>  -asl1 <path>  -asl2 <path>  -o <name>  -fwhm <value> "
		echo ""
		echo "  -sd          : Path to SUBJECTS_DIR "
		echo "  -subj        : Subject name "
		echo "  -asl1        : asl control file (.nii) "
		echo "  -asl2        : asl label file (.nii) "
		echo "  -o           : output name "
		echo "  -fwhm        : fwhm value "
		echo ""
		echo "Usage:  ASL_PreprocessAndMapToSurface.sh  -sd <path>  -subj <patientname>  -asl1 <path>  -asl2 <path>  -o <name>  -fwhm <value> "
		echo ""
		echo "Author: Renaud Lopes - CHRU Lille - Mar 31, 2014"
		echo ""
		exit 1
		;;
	-sd)
		index=$[$index+1]
		eval SUBJECTS_DIR=\${$index}
		echo "subjects dir : ${SUBJECTS_DIR}"
		;;
	-subj)
		index=$[$index+1]
		eval SUBJ=\${$index}
		echo "subject name : ${SUBJ}"
		;;
	-asl1)
		index=$[$index+1]
		eval asl1=\${$index}
		echo "asl (control) : ${asl1}"
		;;
	-asl2)
		index=$[$index+1]
		eval asl2=\${$index}
		echo "asl (label) : ${asl2}"
		;;
	-o)
		index=$[$index+1]
		eval output=\${$index}
		echo "out folder : ${output}"
		;;
	-fwhm)
		index=$[$index+1]
		eval FWHM=\${$index}
		echo "fwhm value : ${FWHM}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage:  ASL_PreprocessAndMapToSurface.sh  -sd <path>  -subj <patientname>  -asl1 <path>  -asl2 <path>  -o <name>  -fwhm <value> "
		echo ""
		echo "  -sd          : Path to SUBJECTS_DIR "
		echo "  -subj        : Subject name "
		echo "  -asl1        : asl control file (.nii) "
		echo "  -asl2        : asl label file (.nii) "
		echo "  -o           : output name "
		echo "  -fwhm        : fwhm value "
		echo ""
		echo "Usage:  ASL_PreprocessAndMapToSurface.sh  -sd <path>  -subj <patientname>  -asl1 <path>  -asl2 <path>  -o <name>  -fwhm <value> "
		echo ""
		echo "Author: Renaud Lopes - CHRU Lille - Mar 31, 2014"
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

if [ -z ${asl1} ]
then
	 echo "-asl1 argument mandatory"
	 exit 1
fi

if [ -z ${asl2} ]
then
	 echo "-asl1 argument mandatory"
	 exit 1
fi

if [ -z ${output} ]
then
	 echo "-o argument mandatory"
	 exit 1
fi

if [ -z ${FWHM} ]
then
	 echo "-fwhm argument mandatory"
	 exit 1
fi

DIR=${SUBJECTS_DIR}/${SUBJ}

if [ -d ${DIR}/${output} ]
then
	rm -rf ${DIR}/${output}
fi
mkdir ${DIR}/${output}

mri_convert ${DIR}/mri/T1.mgz ${DIR}/${output}/t1.nii

fslmerge -t ${DIR}/${output}/asl.nii ${asl1} ${asl2}
gunzip ${DIR}/${output}/asl.nii.gz
asl=${DIR}/${output}/asl.nii

# -----------------------------------------------------------------
#                       PREPROCESSING
# -----------------------------------------------------------------

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

% Load Matlab Path
p = pathdef;
addpath(p);

NSUBJECTS=1;
ASL_FILE        = cellstr('${asl}');
STRUCTURAL_FILE = cellstr(fullfile('${DIR}','${output}','t1.nii'));
nsessions       = length(ASL_FILE)/NSUBJECTS;
ASL_FILE        = reshape(ASL_FILE,[NSUBJECTS,nsessions]);
STRUCTURAL_FILE = {STRUCTURAL_FILE{1:NSUBJECTS}};
for nsub=1:NSUBJECTS,for nses=1:nsessions,asls{nsub}{nses}{1}=ASL_FILE{nsub,nses};end; end 
for nsub=1:length(asls)
	for nses=1:length(asls{nsub})
		[tempa,tempb,tempc]=fileparts(asls{nsub}{nses}{1}); 
		if length(asls{nsub}{nses})==1&&strcmp(tempc,'.nii')
			XASL_FILES{nsub}{nses}=cellstr(spm_select('ExtFPList',tempa,['^',tempb,tempc],1:1e4)); 
		end;
	end;
end

steps = {'segmentation','slicetiming','realignment','coregistration','normalization','smoothing'};

if exist('${DIR}/mri/aparc.a2009s+aseg.mgz','file')
	opt_prep = struct('vox',2,'fwhm',${FWHM},'fwhmsurf',1.5,'parc','${DIR}/mri/aparc.a2009s+aseg.mgz');
else
	opt_prep = struct('vox',2,'fwhm',${FWHM},'fwhmsurf',1.5);
end

ASL_PreprocessingBySPM12(STRUCTURAL_FILE,XASL_FILES,steps,opt_prep);

EOF

# -----------------------------------------------------------------
#                       ASL MAP
# -----------------------------------------------------------------

mkdir ${DIR}/${output}/splittmp
fslsplit ${DIR}/${output}/rasl.nii ${DIR}/${output}/splittmp/epi_ -t
fslmerge -t ${DIR}/${output}/rlabel.nii ${DIR}/${output}/splittmp/epi_00{30..59}*
fslmerge -t ${DIR}/${output}/rcontrol.nii ${DIR}/${output}/splittmp/epi_00{00..29}*
fslmaths ${DIR}/${output}/rlabel -Tmean ${DIR}/${output}/rlabel_mean
fslmaths ${DIR}/${output}/rcontrol -Tmean ${DIR}/${output}/rcontrol_mean
fslmaths ${DIR}/${output}/rlabel_mean -sub ${DIR}/${output}/rcontrol_mean ${DIR}/${output}/asl_map
gunzip ${DIR}/${output}/*.gz
rm -rf ${DIR}/${output}/splittmp

# -----------------------------------------------------------------
#                       CBF MAP
# -----------------------------------------------------------------

# CBF map
/usr/local/matlab11/bin/matlab -nodisplay <<EOF
% Load Matlab Path
p = pathdef;
addpath(p);

disp('calcul carto CBF');
ASL_CBFMap(fullfile('${DIR}','${output}','rcontrol_mean.nii'),fullfile('${DIR}','${output}','asl_map.nii'),fullfile('${DIR}','${output}','CBF.nii'),fullfile('${DIR}','${output}','t1.nii'));

EOF

# -----------------------------------------------------------------
#                       PVE correction
# -----------------------------------------------------------------

/usr/local/matlab11/bin/matlab -nodisplay <<EOF
% Load Matlab Path
p = pathdef;
addpath(p);

disp('calcul carto CBF');
ASL_pve(fullfile('${DIR}','${output}','t1.nii'), fullfile('${DIR}','${output}','rCBF.nii'), fullfile('${DIR}','${output}','pve'));

file_to_copy = fullfile('${DIR}','${output}','pve','rasl.hdr');
file_out     = fullfile('${DIR}','${output}','pve','t1_MGRousset.hdr');
copyfile(file_to_copy,file_out,'f');

EOF


# -----------------------------------------------------------------
#                     Mapping ASL on surface
# -----------------------------------------------------------------

echo "mri_convert ${DIR}/${output}/pve/t1_MGRousset.img ${DIR}/${output}/asl_pve.nii"
mri_convert ${DIR}/${output}/pve/t1_MGRousset.img ${DIR}/${output}/asl_pve.nii

### Project T1 onto surface
/usr/local/matlab11/bin/matlab -nodisplay <<EOF
% Load Matlab Path
p = pathdef;
addpath(p);
 
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

#---------------------- PERFUSION ------------------------
echo "mri_vol2surf --mov ${DIR}/${output}/asl_map.nii --hemi lh --surf mid --o lh.aslmap.w --regheader ${SUBJ} --out_type paint --fwhm 2"
mri_vol2surf --mov ${DIR}/${output}/asl_map.nii --hemi lh --surf mid --o lh.aslmap.w --regheader ${SUBJ} --out_type paint --fwhm 2

echo "mri_vol2surf --mov ${DIR}/${output}/asl_map.nii --hemi lh --surf mid --o lh.aslmap.w --regheader ${SUBJ} --out_type paint --fwhm 2 --surf-fwhm ${FWHM}"
mri_vol2surf --mov ${DIR}/${output}/asl_map.nii --hemi lh --surf mid --o lh.fwhm${FWHM}.aslmap.w --regheader ${SUBJ} --out_type paint --fwhm 2 --surf-fwhm ${FWHM}

echo "mri_vol2surf --mov ${DIR}/${output}/asl_map.nii --hemi rh --surf mid --o rh.aslmap.w --regheader ${SUBJ} --out_type paint --fwhm 2"
mri_vol2surf --mov ${DIR}/${output}/asl_map.nii --hemi rh --surf mid --o rh.aslmap.w --regheader ${SUBJ} --out_type paint --fwhm 2

echo "mri_vol2surf --mov ${DIR}/${output}/asl_map.nii --hemi rh --surf mid --o rh.aslmap.w --regheader ${SUBJ} --out_type paint --fwhm 2 --surf-fwhm ${FWHM}"
mri_vol2surf --mov ${DIR}/${output}/asl_map.nii --hemi rh --surf mid --o rh.fwhm${FWHM}.aslmap.w --regheader ${SUBJ} --out_type paint --fwhm 2 --surf-fwhm ${FWHM}

echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.aslmap.w lh.aslmap"
mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.aslmap.w lh.aslmap

echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.aslmap.w rh.aslmap"
mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.aslmap.w rh.aslmap

echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm${FWHM}.aslmap.w lh.fwhm${FWHM}.aslmap"
mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm${FWHM}.aslmap.w lh.fwhm${FWHM}.aslmap

echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm${FWHM}.aslmap.w rh.fwhm${FWHM}.aslmap"
mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm${FWHM}.aslmap.w rh.fwhm${FWHM}.aslmap

mv ${DIR}/surf/lh.aslmap ${DIR}/surf/lh.aslmap
mv ${DIR}/surf/rh.aslmap ${DIR}/asl/rh.aslmap
mv ${DIR}/surf/lh.fwhm${FWHM}.aslmap ${DIR}/${output}/lh.fwhm${FWHM}.aslmap
mv ${DIR}/surf/rh.fwhm${FWHM}.aslmap ${DIR}/${output}/rh.fwhm${FWHM}.aslmap

rm -f ${DIR}/surf/lh.aslmap.w ${DIR}/surf/rh.aslmap.w ${DIR}/surf/lh.fwhm${FWHM}.aslmap.w ${DIR}/surf/rh.fwhm${FWHM}.aslmap.w

# Resample ASL to fsaverage
echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/${output}/lh.aslmap --sfmt curv --noreshape --no-cortex --tval ${DIR}/${output}/lh.fsaverage.aslmap.mgh --tfmt curv"
mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/${output}/lh.aslmap --sfmt curv --noreshape --no-cortex --tval ${DIR}/${output}/lh.fsaverage.aslmap.mgh --tfmt curv

echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/${output}/lh.fwhm${FWHM}.aslmap --sfmt curv --noreshape --no-cortex --tval ${DIR}/${output}/lh.fwhm${FWHM}.fsaverage.aslmap.mgh --tfmt curv"
mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/${output}/lh.fwhm${FWHM}.aslmap --sfmt curv --noreshape --no-cortex --tval ${DIR}/${output}/lh.fwhm${FWHM}.fsaverage.aslmap.mgh --tfmt curv

echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/${output}/rh.aslmap --sfmt curv --noreshape --no-cortex --tval ${DIR}/${output}/rh.fsaverage.aslmap.mgh --tfmt curv"
mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/${output}/rh.aslmap --sfmt curv --noreshape --no-cortex --tval ${DIR}/${output}/rh.fsaverage.aslmap.mgh --tfmt curv

echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/${output}/rh.fwhm${FWHM}.aslmap --sfmt curv --noreshape --no-cortex --tval ${DIR}/${output}/rh.fwhm${FWHM}.fsaverage.aslmap.mgh --tfmt curv"
mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/${output}/rh.fwhm${FWHM}.aslmap --sfmt curv --noreshape --no-cortex --tval ${DIR}/${output}/rh.fwhm${FWHM}.fsaverage.aslmap.mgh --tfmt curv


#---------------------- CBF------------------------
echo "mri_vol2surf --mov ${DIR}/${output}/asl_pve.nii --hemi lh --surf mid --o lh.asl.w --regheader ${SUBJ} --out_type paint --fwhm 2"
mri_vol2surf --mov ${DIR}/${output}/asl_pve.nii --hemi lh --surf mid --o lh.asl.w --regheader ${SUBJ} --out_type paint --fwhm 2

echo "mri_vol2surf --mov ${DIR}/${output}/asl_pve.nii --hemi lh --surf mid --o lh.asl.w --regheader ${SUBJ} --out_type paint --fwhm 2 --surf-fwhm ${FWHM}"
mri_vol2surf --mov ${DIR}/${output}/asl_pve.nii --hemi lh --surf mid --o lh.fwhm${FWHM}.asl.w --regheader ${SUBJ} --out_type paint --fwhm 2 --surf-fwhm ${FWHM}

echo "mri_vol2surf --mov ${DIR}/${output}/asl_pve.nii --hemi rh --surf mid --o rh.asl.w --regheader ${SUBJ} --out_type paint --fwhm 2"
mri_vol2surf --mov ${DIR}/${output}/asl_pve.nii --hemi rh --surf mid --o rh.asl.w --regheader ${SUBJ} --out_type paint --fwhm 2

echo "mri_vol2surf --mov ${DIR}/${output}/asl_pve.nii --hemi rh --surf mid --o rh.asl.w --regheader ${SUBJ} --out_type paint --fwhm 2 --surf-fwhm ${FWHM}"
mri_vol2surf --mov ${DIR}/${output}/asl_pve.nii --hemi rh --surf mid --o rh.fwhm${FWHM}.asl.w --regheader ${SUBJ} --out_type paint --fwhm 2 --surf-fwhm ${FWHM}

echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.asl.w lh.asl"
mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.asl.w lh.asl

echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.asl.w rh.asl"
mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.asl.w rh.asl

echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm${FWHM}.asl.w lh.fwhm${FWHM}.asl"
mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm${FWHM}.asl.w lh.fwhm${FWHM}.asl

echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm${FWHM}.asl.w rh.fwhm${FWHM}.asl"
mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm${FWHM}.asl.w rh.fwhm${FWHM}.asl

mv ${DIR}/surf/lh.asl ${DIR}/surf/lh.asl
mv ${DIR}/surf/rh.asl ${DIR}/asl/rh.asl
mv ${DIR}/surf/lh.fwhm${FWHM}.asl ${DIR}/${output}/lh.fwhm${FWHM}.asl
mv ${DIR}/surf/rh.fwhm${FWHM}.asl ${DIR}/${output}/rh.fwhm${FWHM}.asl

rm -f ${DIR}/surf/lh.asl.w ${DIR}/surf/rh.asl.w ${DIR}/surf/lh.fwhm${FWHM}.asl.w ${DIR}/surf/rh.fwhm${FWHM}.asl.w

# Resample ASL to fsaverage
echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/${output}/lh.asl --sfmt curv --noreshape --no-cortex --tval ${DIR}/${output}/lh.fsaverage.asl.mgh --tfmt curv"
mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/${output}/lh.asl --sfmt curv --noreshape --no-cortex --tval ${DIR}/${output}/lh.fsaverage.asl.mgh --tfmt curv

echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/${output}/lh.fwhm${FWHM}.asl --sfmt curv --noreshape --no-cortex --tval ${DIR}/${output}/lh.fwhm${FWHM}.fsaverage.asl.mgh --tfmt curv"
mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/${output}/lh.fwhm${FWHM}.asl --sfmt curv --noreshape --no-cortex --tval ${DIR}/${output}/lh.fwhm${FWHM}.fsaverage.asl.mgh --tfmt curv

echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/${output}/rh.asl --sfmt curv --noreshape --no-cortex --tval ${DIR}/${output}/rh.fsaverage.asl.mgh --tfmt curv"
mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/${output}/rh.asl --sfmt curv --noreshape --no-cortex --tval ${DIR}/${output}/rh.fsaverage.asl.mgh --tfmt curv

echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/${output}/rh.fwhm${FWHM}.asl --sfmt curv --noreshape --no-cortex --tval ${DIR}/${output}/rh.fwhm${FWHM}.fsaverage.asl.mgh --tfmt curv"
mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/${output}/rh.fwhm${FWHM}.asl --sfmt curv --noreshape --no-cortex --tval ${DIR}/${output}/rh.fwhm${FWHM}.fsaverage.asl.mgh --tfmt curv

