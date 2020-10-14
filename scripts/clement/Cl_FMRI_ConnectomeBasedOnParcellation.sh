#! /bin/bash

if [ $# -lt 10 ]
then
    echo ""
    echo "Usage: FMRI_ConnectomeBasedOnFreesurferParcellation.sh  -sd <SubjDir>  -subj <SubjName>  -epi <file>  -omat <name>  -odir <dir>  [-useFirst  -loifs1  -loifs2  -loifsl  -parcfsl <file> ] "
    echo ""
    echo "  -sd SubjDir                  : Path to FS output directory (equivalent to SUBJECTS_DIR)"
    echo "  -subj SubjName               : Subject ID"
    echo "  -epi file                    : epi volume (.nii or .nii.gz)"
    echo "  -omat outputFile             : Output file (.mat)"
    echo "  -odir dir                    : Output directory "
    echo ""
    echo "  Options "
    echo "  -useFirst                    : Use FSL FIRST segmentation for subcortical regions "
    echo "  -parcfsl                     : parcellation file from FSL (*_fast_firstseg.nii.gz) (MANDATORY: TO DEFINE IF FSL) "
    echo "  -loifs1                      : name of Freesurfer LOI (.txt) without FSL FIRST "
    echo "  -loifs2                      : name of Freesurfer LOI (.txt) with FSL FIRST "
    echo "  -loifsl                      : name of FSL LOI (.txt) "
    echo ""
    echo "Usage: FMRI_ConnectomeBasedOnFreesurferParcellation.sh  -sd <SubjDir>  -subj <SubjName>  -epi <file>  -omat <name>  -odir <dir>  [-useFirst  -loifs1  -loifs2  -loifsl  -parcfsl <file> ] "
    exit 1
fi

user=`whoami`

HOME=/home/${user}
index=1
UseFirst=0
LOIFS1=/home/renaud/NAS/renaud/volunteers_1000connectome/beijing/aparc2009LOI.txt
LOIFS2=/home/renaud/NAS/renaud/volunteers_1000connectome/beijing/aparc2009LOI_FS.txt
LOIFSL=/home/renaud/NAS/renaud/volunteers_1000connectome/beijing/aparc2009LOI_FSL.txt
parcnameFSL=""

while [ $index -le $# ]
do
    eval arg=\${$index}
    case "$arg" in
    -h|-help)
        echo ""
        echo "Usage: FMRI_ConnectomeBasedOnFreesurferParcellation.sh  -sd <SubjDir>  -subj <SubjName>  -epi <file>  -omat <name>  -odir <dir>  [-useFirst  -loifs1  -loifs2  -loifsl  -parcfsl <file> ] "
        echo ""
        echo "  -sd SubjDir                  : Path to FS output directory (equivalent to SUBJECTS_DIR)"
        echo "  -subj SubjName               : Subject ID"
        echo "  -epi file                    : epi volume (.nii or .nii.gz)"
        echo "  -omat outputFile             : Output file (.mat)"
        echo "  -odir dir                    : Output directory "
        echo ""
        echo "  Options "
        echo "  -useFirst                    : Use FSL FIRST segmentation for subcortical regions"
        echo "  -parcfsl                     : parcellation file from FSL (*_fast_firstseg.nii.gz) (MANDATORY: TO DEFINE IF FSL) "
        echo "  -loifs1                      : name of Freesurfer LOI (.txt) without FSL FIRST "
        echo "  -loifs2                      : name of Freesurfer LOI (.txt) with FSL FIRST "
        echo "  -loifsl                      : name of FSL LOI (.txt) "
        echo ""
        echo "Usage: FMRI_ConnectomeBasedOnFreesurferParcellation.sh  -sd <SubjDir>  -subj <SubjName>  -epi <file>  -omat <name>  -odir <dir>  [-useFirst  -loifs1  -loifs2  -loifsl  -parcfsl <file> ] "
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
    -useFirst)
        UseFirst=1
        echo "Use FSL FIRST segmentation for subcortical regions"
        ;;
    -loifs1)
        index=$[$index+1]
        eval LOIFS1=\${$index}
        echo "LOI FS (without FSL) : ${LOIFS1}"
        ;;
    -loifs2)
        index=$[$index+1]
        eval LOIFS2=\${$index}
        echo "LOI FS (with FSL) : ${LOIFS2}"
        ;;
    -loifsl)
        index=$[$index+1]
        eval LOIFSL=\${$index}
        echo "LOI FSL : ${LOIFSL}"
        ;;
    -parcfsl)
        index=$[$index+1]
        eval parcnameFSL=\${$index}
        echo "PARCELLATION FSL : ${parcnameFSL}"
        ;;
    -*)
        eval infile=\${$index}
        echo "${infile} : unknown option"
        echo ""
        echo "Usage: FMRI_ConnectomeBasedOnFreesurferParcellation.sh  -sd <SubjDir>  -subj <SubjName>  -epi <file>  -omat <name>  -odir <dir>  [-useFirst  -loifs1  -loifs2  -loifsl  -parcfsl <file> ] "
        echo ""
        echo "  -sd SubjDir                  : Path to FS output directory (equivalent to SUBJECTS_DIR)"
        echo "  -subj SubjName               : Subject ID"
        echo "  -epi file                    : epi volume (.nii or .nii.gz)"
        echo "  -omat outputFile             : Output file (.mat)"
        echo "  -odir dir                    : Output directory "
        echo ""
        echo "  Options "
        echo "  -useFirst                    : Use FSL FIRST segmentation for subcortical regions"
        echo "  -parcfsl                     : parcellation file from FSL (*_fast_firstseg.nii.gz) (MANDATORY: TO DEFINE IF FSL) "
        echo "  -loifs1                      : name of Freesurfer LOI (.txt) without FSL FIRST "
        echo "  -loifs2                      : name of Freesurfer LOI (.txt) with FSL FIRST "
        echo "  -loifsl                      : name of FSL LOI (.txt) "
        echo ""
        echo "Usage: FMRI_ConnectomeBasedOnFreesurferParcellation.sh  -sd <SubjDir>  -subj <SubjName>  -epi <file>  -omat <name>  -odir <dir>  [-useFirst  -loifs1  -loifs2  -loifsl  -parcfsl <file> ] "
        exit 1
        ;;
    esac
    index=$[$index+1]
done

# CREATE OUTPUT DIRECTORY
if [ ! -d ${DIR} ]
then
    echo "CREATE OUTPUT DIRECTORY"
    echo "mkdir ${DIR}"
    mkdir ${DIR}
fi

# CREATE PARCELLATION IMAGE
echo "CREATE PARCELLATION IMAGE"
if [ ! -f ${DIR}/parc_las.nii.gz ]
then
    mri_convert -i ${SUBJECTS_DIR}/${SUBJ}/mri/aparc.a2009s+aseg.mgz -o ${DIR}/parc_las.nii.gz --out_orientation LAS
fi

fslroi ${EPI} ${DIR}/dyntemp.nii.gz 0 1
if [ ! -f ${DIR}/parc_las_res.nii.gz ]
then
    mri_convert -i ${DIR}/parc_las.nii.gz -o ${DIR}/parc_las_res.nii.gz -rl ${DIR}/dyntemp.nii.gz -rt nearest
fi

parcname=${DIR}/parc_las.nii.gz

if [ ${UseFirst} -eq 0 ]
then

    echo "no FSL"
    
    TEMPDIR=`mktemp -d --tmpdir=${DIR}`

    # Freesurfer labels
    NloiFS=`cat ${LOIFS1} | wc -l`
    echo $NloiFS

    i=1
    while [ ${i} -le ${NloiFS} ]
    do
      echo $i
      
      LOI_ID=`sed -n "${i}{p;q}" ${LOIFS1} | awk  '{print $1}'`
      mri_extract_label ${parcname} ${LOI_ID} ${TEMPDIR}/loi_${LOI_ID}.nii.gz
      
      mri_convert -i ${TEMPDIR}/loi_${LOI_ID}.nii.gz -o ${TEMPDIR}/epi_loi_${LOI_ID}.nii.gz -rl ${DIR}/dyntemp.nii.gz -rt cubic
      
      i=$[${i}+1]
    done

    rm -rf ${TEMPDIR}/epi_loi_17.nii.gz ${TEMPDIR}/epi_loi_53.nii.gz 
    mri_convert -i ${SUBJECTS_DIR}/${SUBJ}/mri/${SUBJ}_hpg.nii -o ${TEMPDIR}/epi_loi_17.nii.gz -rl ${mEPI} -rt cubic
    mri_convert -i ${SUBJECTS_DIR}/${SUBJ}/mri/${SUBJ}_hpd.nii -o ${TEMPDIR}/epi_loi_53.nii.gz -rl ${mEPI} -rt cubic

    # Create label file
    /usr/local/matlab/bin/matlab -nodisplay <<EOF

    cd ${HOME}
    p = pathdef;
    addpath(p);

    fid = fopen('${LOIFS1}', 'r');
    T   = textscan(fid, '%d %s');
    lid = double(T{1});
    fclose(fid);
    clear T;

    % Load first volume
    [V,Y] = niak_read_vol(fullfile('${TEMPDIR}',['epi_loi_', num2str(lid(1)), '.nii.gz']));

    Labels = zeros(size(Y));
    Max    = zeros(size(Y));
    Labels(Y > 0.01) = lid(1);
    Max(Y > 0.01)    = Y(Y > 0.01);

    % Loop the volumes
    for i = 2 : length(lid)
    disp(['Processing step ', num2str(i), ' out of ', num2str(length(lid))]);
    [V,Y] = niak_read_vol(fullfile('${TEMPDIR}',['epi_loi_', num2str(lid(i)), '.nii.gz']));
    Labels( ((Y > 0.01) .* (Y > Max)) ~=0 ) = lid(i);
    Max( ((Y > 0.01) .* (Y > Max)) ~= 0 ) = Y( ((Y > 0.01) .* (Y > Max)) ~= 0 );
    end

    V.file_name = fullfile('${DIR}','labels_epi_nofsl.nii.gz');
    niak_write_vol(V,Labels);
    
    % Connectivity matrix
    epiFiles{1}   = '${EPI}';
    annotFiles{1} = fullfile('${DIR}','labels_epi_nofsl.nii.gz');
    dovoxels      = 0;
    typeCorr      = 'R';
    [Cmat,labels,tseries,std_tseries] = FMRI_ConnectivityMatrixOnVolume(epiFiles,annotFiles,dovoxels,typeCorr);
    Connectome             = struct();
    Connectome.Cmat        = Cmat;
    Connectome.labidx      = labels;
    Connectome.loifs       = '${LOIFS1}';
    Connectome.parc        = '${DIR}/parc_las.nii.gz';
    Connectome.tseries     = tseries;
    Connectome.std_tseries = std_tseries;
    Connectome.epiFile     = '${EPI}';
    Connectome.subject     = '${SUBJ}';
    save('${DIR}/${OUTFILE}','Connectome','-v7.3');

EOF

    rm -rf ${TEMPDIR}

else

    echo "FSL"

    TEMPDIR=`mktemp -d --tmpdir=${DIR}`

    # FSL labels
    NloiFSL=`cat ${LOIFSL} | wc -l`
    echo $NloiFSL

    i=1
    while [ ${i} -le ${NloiFSL} ]
    do
      echo $i
      
      LOI_ID=`sed -n "${i}{p;q}" ${LOIFSL} | awk  '{print $1}'`
      mri_extract_label ${parcnameFSL} ${LOI_ID} ${TEMPDIR}/loi_${LOI_ID}.nii.gz
      
      mri_convert -i ${TEMPDIR}/loi_${LOI_ID}.nii.gz -o ${TEMPDIR}/epi_loi_${LOI_ID}.nii.gz -rl ${DIR}/dyntemp.nii.gz -rt cubic
      
      i=$[${i}+1]
    done

    # Freesurfer labels
    NloiFS=`cat ${LOIFS2} | wc -l`
    echo $NloiFS

    i=1
    while [ ${i} -le ${NloiFS} ]
    do
      echo $i
      
      LOI_ID=`sed -n "${i}{p;q}" ${LOIFS2} | awk  '{print $1}'`
      mri_extract_label ${parcname} ${LOI_ID} ${TEMPDIR}/loi_${LOI_ID}.nii.gz
      
      mri_convert -i ${TEMPDIR}/loi_${LOI_ID}.nii.gz -o ${TEMPDIR}/epi_loi_${LOI_ID}.nii.gz -rl ${DIR}/dyntemp.nii.gz -rt cubic
      
      i=$[${i}+1]
    done

    rm -rf ${TEMPDIR}/epi_loi_17.nii.gz ${TEMPDIR}/epi_loi_53.nii.gz 
    mri_convert -i ${SUBJECTS_DIR}/${SUBJ}/mri/${SUBJ}_hpg.nii -o ${TEMPDIR}/epi_loi_17.nii.gz -rl ${DIR}/dyntemp.nii.gz -rt cubic
    mri_convert -i ${SUBJECTS_DIR}/${SUBJ}/mri/${SUBJ}_hpd.nii -o ${TEMPDIR}/epi_loi_53.nii.gz -rl ${DIR}/dyntemp.nii.gz -rt cubic

    
    # Create label file
    /usr/local/matlab/bin/matlab -nodisplay <<EOF

    cd ${HOME}
    p = pathdef;
    addpath(p);

    fid = fopen('${LOIFSL}', 'r');
    T   = textscan(fid, '%d %s');
    lid = double(T{1});
    fclose(fid);
    clear T;

    % Load first volume
    [V,Y] = niak_read_vol(fullfile('${TEMPDIR}',['epi_loi_', num2str(lid(1)), '.nii.gz']));

    Labels = zeros(size(Y));
    Max    = zeros(size(Y));
    Labels(Y > 0.01) = lid(1);
    Max(Y > 0.01)    = Y(Y > 0.01);

    % Loop the volumes
    for i = 2 : length(lid)
    disp(['Processing step ', num2str(i), ' out of ', num2str(length(lid))]);
    [V,Y] = niak_read_vol(fullfile('${TEMPDIR}',['epi_loi_', num2str(lid(i)), '.nii.gz']));
    Labels( ((Y > 0.01) .* (Y > Max)) ~=0 ) = lid(i);
    Max( ((Y > 0.01) .* (Y > Max)) ~= 0 ) = Y( ((Y > 0.01) .* (Y > Max)) ~= 0 );
    end


    % Labels : assigne le numéro de label auquels les voxels appartiennent.

    fid = fopen('${LOIFS2}', 'r');
    T   = textscan(fid, '%d %s');
    lid = double(T{1});
    fclose(fid);
    clear T;

    % Loop the volumes
    for i = 1 : length(lid)
    disp(['Processing step ', num2str(i), ' out of ', num2str(length(lid))]);
    [V,Y] = niak_read_vol(fullfile('${TEMPDIR}',['epi_loi_', num2str(lid(i)), '.nii.gz']));
    Labels( ((Y > 0.01) .* (Y > Max)) ~=0 ) = lid(i);
    Max( ((Y > 0.01) .* (Y > Max)) ~= 0 ) = Y( ((Y > 0.01) .* (Y > Max)) ~= 0 );
    end

    V.file_name = fullfile('${DIR}','labels_epi_fsl.nii.gz');
    niak_write_vol(V,Labels);
    
    % Connectivity matrix
    epiFiles{1}   = '${EPI}';
    annotFiles{1} = fullfile('${DIR}','labels_epi_fsl.nii.gz');
    dovoxels      = 0;
    typeCorr      = 'R';
    [Cmat,labels,tseries,std_tseries] = FMRI_ConnectivityMatrixOnVolume(epiFiles,annotFiles,dovoxels,typeCorr);
    Connectome             = struct();
    Connectome.Cmat        = Cmat;
    Connectome.labidx      = labels;
    Connectome.loifs       = '${LOIFS2}';
    Connectome.loifsl      = '${LOIFSL}';
    Connectome.parc        = '${DIR}/parc_las.nii.gz';
    Connectome.parc2       = '${parcnameFSL}';
    Connectome.tseries     = tseries;
    Connectome.std_tseries = std_tseries;
    Connectome.epiFile     = '${EPI}';
    Connectome.subject     = '${SUBJ}';
    save('${DIR}/${OUTFILE}','Connectome','-v7.3');

EOF

    rm -rf ${TEMPDIR}

fi

rm -f ${DIR}/dyntemp.nii.gz

gzip ${EPI}
