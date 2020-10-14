#! /bin/bash

if [ $# -lt 10 ]
then
	echo ""
	echo "Usage: FMRI_ConnectomeBasedOnCraddockParcellation.sh  -sd <SubjDir>  -subj <SubjName>  -epi <file>  -omat <name>  -odir <dir>   "
	echo ""
	echo "  -sd SubjDir                  : Path to FS output directory (equivalent to SUBJECTS_DIR)"
	echo "  -subj SubjName               : Subject ID"
	echo "  -epi file                    : epi volume (.nii or .nii.gz)"
	echo "  -omat outputFile             : Output file (.mat)"
	echo "  -odir dir                    : Output directory that will be created"
	echo "  -mean_epi                    : mean epi file for registration"
	echo ""
	echo ""
	echo "Usage: FMRI_ConnectomeBasedOnCraddockParcellation.sh  -sd <SubjDir>  -subj <SubjName>  -epi <file>  -omat <name>  -odir <dir>   "
	exit 1
fi

user=`whoami`

HOME=/home/${user}
index=1
LOI=/NAS/tupac/protocoles/Strokdem/FMRI/Ck_nodes.txt

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: FMRI_ConnectomeBasedOnCraddockParcellation.sh  -sd <SubjDir>  -subj <SubjName>  -epi <file>  -omat <name>  -odir <dir>   "
		echo ""
		echo "  -sd SubjDir                  : Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -subj SubjName               : Subject ID"
		echo "  -epi file                    : epi volume (.nii or .nii.gz)"
		echo "  -omat outputFile             : Output file (.mat)"
		echo "  -odir dir                    : Output directory that will be created "
		echo "  -mean_epi                    : mean epi file for registration"
		echo ""
		echo ""
		echo "Usage: FMRI_ConnectomeBasedOnCraddockParcellation.sh  -sd <SubjDir>  -subj <SubjName>  -epi <file>  -omat <name>  -odir <dir>   "
		echo "Perform craddock parcellation and generate connectivity matrix. Use t-2 level parcellation atlas."
		exit 1
		;;
	-sd)
		index=$[$index+1]
		eval SUBJECTS_DIR=\${$index}
		echo "SUBJECT's DIRECTORY : ${SUBJECTS_DIR}"
		;;
	-subj)
		index=$[$index+1]
		eval SUBJ=\${$index}
		echo "SUBJECT's NAME : ${SUBJ}"
		;;
	-epi)
		index=$[$index+1]
		eval EPI=\${$index}
		echo "EPI file : ${EPI}"
		;;
	-omat)
		index=$[$index+1]
		eval OUTFILE=\${$index}
		echo "output file (.mat) : ${OUTFILE}"
		;;
	-odir)
		index=$[$index+1]
		eval DIR=\${$index}
		echo "output directory : ${DIR}"
		;;
	-mean_epi)
		index=$[$index+1]
		eval MEPI=\${$index}
		echo "mean epi : ${MEPI}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: FMRI_ConnectomeBasedOnCraddockParcellation.sh  -sd <SubjDir>  -subj <SubjName>  -epi <file>  -omat <name>  -odir <dir>   "
		echo ""
		echo "  -sd SubjDir                  : Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -subj SubjName               : Subject ID"
		echo "  -epi file                    : epi volume (.nii or .nii.gz)"
		echo "  -omat outputFile             : Output file (.mat)"
		echo "  -odir dir                    : Output directory that will be created"
		echo "  -mean_epi                    : mean epi file for registration"
		echo ""
		echo ""
		echo "Usage: FMRI_ConnectomeBasedOnCraddockParcellation.sh  -sd <SubjDir>  -subj <SubjName>  -epi <file>  -omat <name>  -odir <dir>   "
		exit 1
		;;
	esac
	index=$[$index+1]
done


# CREATE OUTPUT DIRECTORY
if [ ! -d ${DIR} ]; then
    echo "CREATE OUTPUT DIRECTORY"
    echo "mkdir ${DIR}"
    mkdir ${DIR}
fi

TEMPDIR=`mktemp -d --tmpdir=${DIR}`

# CRADDOCK PARCELLATION

cp ${MEPI} ${DIR}/mEPI.nii
cp ${EPI} ${DIR}/EPI.nii
gunzip -f ${DIR}/*.gz

IDmepi=`basename ${MEPI}`
mepi=${IDmepi:0:(${#IDmepi}-4)}

# Extract label from craddock



Nloi=`cat ${LOI} | wc -l`

i=1
while [ ${i} -le ${Nloi} ]
do
	LOI_ID=`sed -n "${i}{p;q}" ${LOI} | awk  '{print $1}'`
	echo "mri_extract_label /NAS/tupac/protocoles/Strokdem/test/temp_craddock/tcorr05_mean_all-cerebellum.nii ${LOI_ID} ${TEMPDIR}/crad_loi_${LOI_ID}.nii"
	mri_extract_label /NAS/tupac/protocoles/Strokdem/test/temp_craddock/tcorr05_2level_all-FRAME31-cerebellum.nii ${LOI_ID} ${TEMPDIR}/crad_loi_${LOI_ID}.nii
	      
	i=$[${i}+1]
done

	# Reslice LOI to DTI space
matlab -nodisplay <<EOF
	spm_jobman('initcfg');

	clear matlabbatch 
	matlabbatch = {};
	%Compute registration matrix for EPI to mni (space of craddock parcellation)
	matlabbatch{end+1}.spm.tools.oldnorm.est.subj.source     = cellstr('${DIR}/mEPI.nii');
	matlabbatch{end}.spm.tools.oldnorm.est.subj.wtsrc        = '';
	matlabbatch{end}.spm.tools.oldnorm.est.eoptions.template = {'/home/global/matlab_toolbox/spm12/toolbox/OldNorm/EPI.nii,1'};
	matlabbatch{end}.spm.tools.oldnorm.est.eoptions.weight   = '';
	matlabbatch{end}.spm.tools.oldnorm.est.eoptions.smosrc   = 0;
	matlabbatch{end}.spm.tools.oldnorm.est.eoptions.smoref   = 0;
	matlabbatch{end}.spm.tools.oldnorm.est.eoptions.regtype  = 'mni';
	matlabbatch{end}.spm.tools.oldnorm.est.eoptions.cutoff   = 25;
	matlabbatch{end}.spm.tools.oldnorm.est.eoptions.nits     = 16;
	matlabbatch{end}.spm.tools.oldnorm.est.eoptions.reg      = 1;

	spm_jobman('run',matlabbatch);

	clear matlabbatch 
	matlabbatch = {};
	%Apply registration to mean epi 
	matlabbatch{end+1}.spm.tools.oldnorm.write.subj.matname    = cellstr('${DIR}/mEPI_sn.mat');
	matlabbatch{end}.spm.tools.oldnorm.write.subj.resample     = cellstr('${DIR}/mEPI.nii');
	matlabbatch{end}.spm.tools.oldnorm.write.roptions.preserve = 0;
	matlabbatch{end}.spm.tools.oldnorm.write.roptions.bb       = [-78 -112 -70; 78 76 85];
	matlabbatch{end}.spm.tools.oldnorm.write.roptions.vox      = [2 2 2];
	matlabbatch{end}.spm.tools.oldnorm.write.roptions.interp   = 4;
	matlabbatch{end}.spm.tools.oldnorm.write.roptions.wrap     = [0 0 0];
	matlabbatch{end}.spm.tools.oldnorm.write.roptions.prefix   = 'w';
	spm_jobman('run',matlabbatch);	

	clear matlabbatch 
	matlabbatch = {};
	%Sample labels to mean epi in mni space
	epiFiles=SurfStatListDir('${TEMPDIR}/crad_loi*.nii');

	matlabbatch{1}.spm.spatial.coreg.write.ref = {'${DIR}/wmEPI.nii,1'};
	matlabbatch{1}.spm.spatial.coreg.write.source = epiFiles;
	matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 0;
	matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
	matlabbatch{1}.spm.spatial.coreg.write.roptions.mask = 0;
	matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'r';

	inputs = cell(0, 1);
	spm('defaults', 'PET');
	spm_jobman('serial', matlabbatch, '', inputs{:});

	epiFiles=SurfStatListDir('${TEMPDIR}/rcrad_loi*.nii');
	clear matlabbatch 
	matlabbatch = {};
	matlabbatch{end+1}.spm.util.defs.comp{1}.inv.comp{1}.sn2def.matname = cellstr('${DIR}/mEPI_sn.mat');
	matlabbatch{end}.spm.util.defs.comp{1}.inv.comp{1}.sn2def.vox       = [2 2 2];
	matlabbatch{end}.spm.util.defs.comp{1}.inv.comp{1}.sn2def.bb        = [-78 -112 -70; 78 76 85];
	matlabbatch{end}.spm.util.defs.comp{1}.inv.space                    = {'${DIR}/EPI.nii'};
	matlabbatch{end}.spm.util.defs.out{1}.pull.fnames                   = epiFiles;
	matlabbatch{end}.spm.util.defs.out{1}.pull.savedir.savesrc          = 1;
	matlabbatch{end}.spm.util.defs.out{1}.pull.interp                   = 0;
	matlabbatch{end}.spm.util.defs.out{1}.pull.mask                     = 1;
	matlabbatch{end}.spm.util.defs.out{1}.pull.fwhm                     = [0 0 0];

	spm_jobman('run',matlabbatch);	

EOF

	rm -f ${TEMPDIR}/crad_loi_*.nii

	# Create label file
matlab -nodisplay <<EOF

cd ${TEMPDIR}

fid = fopen('${LOI}', 'r');
T = textscan(fid, '%d %s');
lid = double(T{1});
fclose(fid);
clear T;

% Load first volume
V = spm_vol(['wrcrad_loi_', num2str(lid(1)), '.nii']);
[Y,XYZ] = spm_read_vols(V);

Labels = zeros(size(Y));
Max = zeros(size(Y));
Labels(Y > 0.01) = lid(1);
Max(Y > 0.01) = Y(Y > 0.01);

% Loop the volumes
for i = 2 : length(lid)
disp(['Processing step ', num2str(i), ' out of ', num2str(length(lid))]);
V = spm_vol(['wrcrad_loi_', num2str(lid(i)), '.nii']);
[Y,XYZ] = spm_read_vols(V);
Labels( ((Y > 0.01) .* (Y > Max)) ~=0 ) = lid(i);
Max( ((Y > 0.01) .* (Y > Max)) ~= 0 ) = Y( ((Y > 0.01) .* (Y > Max)) ~= 0 );
end

V.fname='labels_epi_crad.nii';

V.dt(1) = 64;

V = spm_write_vol(V, Labels);

EOF

mv ${TEMPDIR}/labels_epi_crad.nii ${DIR}/final_epi_crad.nii

matlab -nodisplay <<EOF
fid = fopen('${LOI}', 'r');
T   = textscan(fid, '%d');
lid = double(T{1});
fclose(fid);
clear T;

% Load first volume
[V,Y] = niak_read_vol(fullfile('${TEMPDIR}',['wrcrad_loi_', num2str(lid(1)), '.nii']));

Labels = zeros(size(Y));
Max    = zeros(size(Y));
Labels(Y > 0.01) = lid(1);
Max(Y > 0.01)    = Y(Y > 0.01);

% Loop the volumes
for i = 2 : length(lid)
disp(['Processing step ', num2str(i), ' out of ', num2str(length(lid))]);
[V,Y] = niak_read_vol(fullfile('${TEMPDIR}',['wrcrad_loi_', num2str(lid(i)), '.nii']));
Labels( ((Y > 0.01) .* (Y > Max)) ~=0 ) = lid(i);
Max( ((Y > 0.01) .* (Y > Max)) ~= 0 ) = Y( ((Y > 0.01) .* (Y > Max)) ~= 0 );
end

%V.file_name = fullfile('${DIR}','labels_epi_crad.nii.gz');
%niak_write_vol(V,Labels);
    
% Connectivity matrix
epiFiles{1}   = '${DIR}/EPI.nii';
annotFiles{1} = fullfile('${DIR}','final_epi_crad.nii');
dovoxels      = 0;
typeCorr      = 'R';
[Cmat,labels,tseries,std_tseries] = FMRI_ConnectivityMatrixOnVolume(epiFiles,annotFiles,dovoxels,typeCorr);
Connectome             = struct();
Connectome.Cmat        = Cmat;
Connectome.labidx      = labels;
Connectome.loifs       = '${LOI}';
Connectome.parc        = '${DIR}/final_epi_crad.nii';
Connectome.tseries     = tseries;
Connectome.std_tseries = std_tseries;
Connectome.epiFile     = '${EPI}';
Connectome.subject     = '${SUBJ}';
save('${DIR}/${OUTFILE}','Connectome','-v7.3');

EOF


rm -rf ${TEMPDIR}

gzip ${DIR}/*nii
