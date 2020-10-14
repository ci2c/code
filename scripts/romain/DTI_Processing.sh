#! /bin/bash

#
# Function Descripton
#  Show usage information for this script
#

function usage()
{
    cat << EOF
Usage: DTI_Processing.sh  -sd <subjects_dir>  -subj <subject>  -dti <dti_image>  [-hcp -dti_corr -mask -include] 
  -sd                         : SUBJECTS_DIR folder 
  -subj                       : Subject id
  -dti                        : dti image (path/.nii.gz)
Options
  -dti_corr                   : dti_back image (path/.nii.gz) (Si pas fournit alors pas de correction)
  -hcp                        : use of HCP script (default = "-freesurfer")
  -mask                       : masque
  -include                    : option include de mrtrix 
  -nFibers                    : number of fibers to extract
Rq1 le script créra le dossier "dti" (qui sera le répertoire de sortie ${SUBJECTS_DIR}/${SUBJECT}/dti) pour l'option fs ou "Diffusion" (qui sera le répertoire de sortie ${SUBJECTS_DIR}/${SUBJECT}/Diffusion) our l'option hcp
Rq2 les fichiers dti dti_corr fournis en argument seront copiés dans le répertoire de destination (selon fs ou hcp), il faut donc fournir les chemins vers le repertoire data.
EOF
exit
}

if [ $# -lt 4 ]
then
	usage
fi

HOME=/home/${USER}
index=1
useHCP="FALSE"
dist_corr=0
N_Fib=1500000
REP="dti"
while [ $index -le $# ]
do
    eval arg=\${$index}
    echo $arg
    case "$arg" in
    -h|-help)
        usage
        exit 1
        ;;
    -sd)
        index=$[$index+1]
        eval SubjFolder=\${$index}
        echo "SUBJECTS_DIR folder : ${SubjFolder}"
        ;;
    -subj)
        index=$[$index+1]
        eval Subject=\${$index}
        echo "Subject id : ${Subject}"
        ;;
    -dti)
        index=$[$index+1]
        eval DTI=\${$index}
        echo "dti image : ${DTI}"
        ;;
    -dti_corr)
        index=$[$index+1]
        dist_corr=1
        eval DTI_corr=\${$index}
        echo "dti corr image : ${DTI_corr}"
        ;;
    -hcp)
        useHCP="TRUE"
        echo "use of HCP script"
        ;;
    -mask)
		mask=1
		seedMask=`expr $index + 1`
		eval seedMask=\${$seedMask}
		echo "Seed mask : ${seedMask}"
		index=$[$index+1]
		;;
    -include)
		inclmask=1
		includeMask=`expr $index + 1`
		eval includeMask=\${$includeMask}
		echo "Include mask : ${includeMask}"
		index=$[$index+1]
		;;
    -nFibers)
        index=$[$index+1]
        eval N_Fib=\${$index}
        echo "Number of fibers : ${N_Fib}"
        ;;
    -rep)
        index=$[$index+1]
        eval REP=\${$index}
        echo "dti folder : ${REP}"
        ;;
    -*)
        eval infile=\${$index}
                usage
        exit 1
        ;;
    esac
    index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${DTI} ]
then
     echo "-dti argument mandatory"
     exit 1
fi
if [ -z ${SubjFolder} ]
then
     echo "-sd argument mandatory"
     exit 1
fi
if [ -z ${Subject} ]
then
     echo "-subj argument mandatory"
     exit 1
fi

# compress if not
filename=$(basename "${DTI}")
extension="${filename##*.}"
if [ "${extension}" == "nii" ]; then gzip -f ${DTI}; DTI=${DTI}.gz; fi

filename=$(basename "${DTI_corr}")
extension="${filename##*.}"
if [ "${extension}" == "nii" ]; then gzip -f ${DTI_corr}; DTI=${DTI_corr}.gz; fi

dir=$(dirname ${DTI})
filename=$(basename -s .nii.gz "${DTI}")

# Processing
echo -e "\n"
echo -e "\n Start..."

if [ $useHCP = "FALSE" ] ;then
    
    #création rép dti
    if [ ! -d ${SubjFolder}${Subject}/${REP} ] ; then
            cmd="mkdir ${SubjFolder}${Subject}/${REP};" ; echo ${cmd} ; eval ${cmd} 
            cp ${DTI} ${SubjFolder}${Subject}/${REP}/dti.nii.gz;
			if [[ "$dist_cor" -eq 1 ]];then
               cp ${DTI_corr} ${SubjFolder}${Subject}/${REP}/dti_back.nii.gz;
            fi
            cp ${dir}/${filename}.bval ${SubjFolder}${Subject}/${REP}/dti.bval;
            cp ${dir}/${filename}.bvec ${SubjFolder}${Subject}/${REP}/dti.bvec;
    fi
    if [[ "$dist_corr" -eq 1 ]];then
       if [ ! -e ${SubjFolder}${Subject}/${REP}/dti_back.nii.gz ] ; then
            cp ${DTI_corr} ${SubjFolder}${Subject}/${REP}/dti_back.nii.gz;
       fi
    fi
    
    if [ ! -e ${SubjFolder}${Subject}/${REP}/dti.nii.gz ] ; then
            cp ${DTI} ${SubjFolder}${Subject}/${REP}/dti.nii.gz;
    fi
    if [ ! -e ${SubjFolder}${Subject}/${REP}/dti.bval ] ; then
            cp ${dir}/${filename}.bval ${SubjFolder}${Subject}/${REP}/dti.bval;
    fi
	if [ ! -e ${SubjFolder}${Subject}/${REP}/dti.bvec ] ; then
            cp ${dir}/${filename}.bvec ${SubjFolder}${Subject}/${REP}/dti.bvec;
    fi
    echo -e "\n"
    echo -e "\n Use of PB's pipeline (PB stand for Pierre Besson)"
    
    cmd="PrepareSurfaceConnectome.sh -fs ${SubjFolder} -subj ${Subject} -N ${N_Fib} -rep ${REP}"
    if [ -z ${DTI_corr} ];then
    		echo " no distortion correction"
       		cmd="$cmd -no-corr" 	
    fi
    if [[ "$mask" -eq 1 ]];then
    		echo " adding mask ${seedMask}"
       		cmd="$cmd -mask ${seedMask}" 	
    fi
    if [[ "$inclmask" -eq 1 ]];then
    		echo " adding include mask"
       		cmd="$cmd -include $includeMask" 	
    fi
    echo "*****************************"
    echo "*****************************"
    cmd="$cmd ;" 
    echo $cmd ; eval $cmd
    
    #getSurfaceConnectome.sh -fs ${SubjFolder} -subj ${Subject}
else
    echo -e "\n"
    echo -e "\n Use of HCP pipeline"
	echo "$@"
	echo ${HCPPIPEDIR}
	echo $FSLDIR
	echo ${FREESURFER_HOME}
	
	export FSL_DIR="${FSLDIR}"
	export HCPPIPEDIR_Templates=${HCPPIPEDIR}/global/templates
	export HCPPIPEDIR_Bin=${HCPPIPEDIR}/global/binaries
	export HCPPIPEDIR_Config=${HCPPIPEDIR}/global/config
	export HCPPIPEDIR_PreFS=${HCPPIPEDIR}/PreFreeSurfer/scripts
	export HCPPIPEDIR_FS=${HCPPIPEDIR}/FreeSurfer/scripts
	export HCPPIPEDIR_PostFS=${HCPPIPEDIR}/PostFreeSurfer/scripts
	export HCPPIPEDIR_fMRISurf=${HCPPIPEDIR}/fMRISurface/scripts
	export HCPPIPEDIR_fMRIVol=${HCPPIPEDIR}/fMRIVolume/scripts
	export HCPPIPEDIR_tfMRI=${HCPPIPEDIR}/tfMRI/scripts
	export HCPPIPEDIR_dMRI=${HCPPIPEDIR}/DiffusionPreprocessing/scripts
	export HCPPIPEDIR_dMRITract=${HCPPIPEDIR}/DiffusionTractography/scripts
	export HCPPIPEDIR_Global=${HCPPIPEDIR}/global/scripts
	export HCPPIPEDIR_tfMRIAnalysis=${HCPPIPEDIR}/TaskfMRIAnalysis/scripts
	export MSMBin=${HCPPIPEDIR}/MSMBinaries
				
	#commentaire dans /home/romain/SVN/scripts/romain/DTI_HCP_PrePiplines.sh ou dans 
	#StudyFolder="/NAS/tupac/protocoles/healthy_volunteers/" #Location of Subject folders (named by subjectID)
	#SubjectID="T02S01"
	#RawDataDir="${StudyFolder}data/$SubjectID/" 
	#PosData="${RawDataDir}/dti.nii.gz"
	#NegData="${RawDataDir}/dti_back.nii.gz"
	PRINTCOM=""
	EchoSpacing=0.78
	PEdir=1 
	Gdcoeffs="NONE" 
	
	local Diff_pre_batch=""
	Diff_pre_batch+="${HCPPIPEDIR}/DiffusionPreprocessing/DiffPreprocPipeline.sh  "
	Diff_pre_batch+=" --posData="${DTI}" --negData="${DTI_corr}" "
	Diff_pre_batch+=" --path="${SubjFolder}" --subject="${Subject}"" 
	Diff_pre_batch+=" --echospacing="${EchoSpacing}" --PEdir=${PEdir}"
	Diff_pre_batch+=" --gdcoeffs="${Gdcoeffs}""
	Diff_pre_batch+=" --printcom=$PRINTCOM"

	echo -e "Diff_pre_batch: ${Diff_pre_batch}"
    ${Diff_pre_batch}
fi

