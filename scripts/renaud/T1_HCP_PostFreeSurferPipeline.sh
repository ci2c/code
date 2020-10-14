#! /bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: T1_HCP_PostFreeSurferPipeline.sh -StudyFolder <SUBJECTS_DIR>  -Subjlist <SUBJ_ID>  [-runlocal -ist2] "
	echo ""
	echo "  -StudyFolder                 : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
	echo "  -Subjlist                    : Subject ids "
	echo "  Options  "
	echo "  -runlocal                    : run in local "
	echo "  -ist2	                     : using of T2 image "
	echo ""
	echo "Usage: T1_HCP_PostFreeSurferPipeline.sh -StudyFolder <SUBJECTS_DIR>  -Subjlist <SUBJ_ID>  [-runlocal -ist2] "
	echo ""
	exit 1
fi

user=`whoami`

#EnvironmentScript="/NAS/tupac/renaud/HCP/scripts/Pipelines-3.14.1/Examples/Scripts/SetUpHCPPipeline.sh" #Pipeline environment script
##Set up pipeline environment variables and software
#. ${EnvironmentScript}

HOME=/home/${user}
index=1
command_line_specified_run_local="FALSE"
useT2="FALSE"

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: T1_HCP_PostFreeSurferPipeline.sh -StudyFolder <SUBJECTS_DIR>  -Subjlist <SUBJ_ID>  [-runlocal -ist2] "
		echo ""
		echo "  -StudyFolder                 : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -Subjlist                    : Subject ids "
		echo "  Options  "
		echo "  -runlocal                    : run in local "
		echo "  -ist2	                     : using of T2 image "
		echo ""
		echo "Usage: T1_HCP_PostFreeSurferPipeline.sh -StudyFolder <SUBJECTS_DIR>  -Subjlist <SUBJ_ID>  [-runlocal -ist2] "
		echo ""
		exit 1
		;;
	-StudyFolder)
		index=$[$index+1]
		eval StudyFolder=\${$index}
		echo "SUBJECTS DIR : $StudyFolder"
		;;
	-Subjlist)
		index=$[$index+1]
		eval Subjlist=\${$index}
		echo "SUBJECT ID : $Subjlist"
		;;
	-runlocal)
		eval command_line_specified_run_local="TRUE"
		echo "running in local"
		;;
	-ist2)
		eval useT2="TRUE"
		echo "using of T2 image"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: T1_HCP_PostFreeSurferPipeline.sh -StudyFolder <SUBJECTS_DIR>  -Subjlist <SUBJ_ID>  [-runlocal -ist2] "
		echo ""
		echo "  -StudyFolder                 : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -Subjlist                    : Subject ids "
		echo "  Options  "
		echo "  -runlocal                    : run in local "
		echo "  -ist2	                     : using of T2 image "
		echo ""
		echo "Usage: T1_HCP_PostFreeSurferPipeline.sh -StudyFolder <SUBJECTS_DIR>  -Subjlist <SUBJ_ID>  [-runlocal -ist2] "
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

RUN=""

if [ ! ${command_line_specified_run_local} = "TRUE" ]
then
      QUEUE="-q fs_q"
else
      QUEUE=""
fi

PRINTCOM=""


########################################## INPUTS ########################################## 

#Scripts called by this script do assume they run on the outputs of the FreeSurfer Pipeline

######################################### DO WORK ##########################################

if [ ! $useT2 = "FALSE" ] ; then

      echo "Using of T2 image"
      
      for Subject in $Subjlist ; do
      
	  echo $Subject
      
	  #Input Variables
	  SurfaceAtlasDIR="${HCPPIPEDIR_Templates}/standard_mesh_atlases"
	  GrayordinatesSpaceDIR="${HCPPIPEDIR_Templates}/91282_Greyordinates"
	  GrayordinatesResolutions="2" #Usually 2mm, if multiple delimit with @, must already exist in templates dir
	  HighResMesh="164" #Usually 164k vertices
	  LowResMeshes="32" #Usually 32k vertices, if multiple delimit with @, must already exist in templates dir
	  SubcorticalGrayLabels="${HCPPIPEDIR_Config}/FreeSurferSubcorticalLabelTableLut.txt"
	  FreeSurferLabels="${HCPPIPEDIR_Config}/FreeSurferAllLut.txt"
	  ReferenceMyelinMaps="${HCPPIPEDIR_Templates}/standard_mesh_atlases/Conte69.MyelinMap_BC.164k_fs_LR.dscalar.nii"
	  # RegName="MSMSulc" #MSMSulc is recommended, if binary is not available use FS (FreeSurfer)
	  RegName="FS" 

	  if [ -n "${command_line_specified_run_local}" ] ; then
	      queuing_command=""
	  else
	      if [ ! -d ${StudyFolder}/log ] ; then
		  mkdir ${StudyFolder}/log
	      fi
	      queuing_command="qstat ${QUEUE} -oe ${StudyFolder}/log/ -N fshcp_${Subject}"
	  fi

	  ${queuing_command} ${HCPPIPEDIR}/PostFreeSurfer/PostFreeSurferPipeline.sh \
	      --path="$StudyFolder" \
	      --subject="$Subject" \
	      --surfatlasdir="$SurfaceAtlasDIR" \
	      --grayordinatesdir="$GrayordinatesSpaceDIR" \
	      --grayordinatesres="$GrayordinatesResolutions" \
	      --hiresmesh="$HighResMesh" \
	      --lowresmesh="$LowResMeshes" \
	      --subcortgraylabels="$SubcorticalGrayLabels" \
	      --freesurferlabels="$FreeSurferLabels" \
	      --refmyelinmaps="$ReferenceMyelinMaps" \
	      --regname="$RegName" \
	      --printcom=$PRINTCOM

	  # The following lines are used for interactive debugging to set the positional parameters: $1 $2 $3 ...
	  
	  echo "set -- --path="$StudyFolder" \
	      --subject="$Subject" \
	      --surfatlasdir="$SurfaceAtlasDIR" \
	      --grayordinatesdir="$GrayordinatesSpaceDIR" \
	      --grayordinatesres="$GrayordinatesResolutions" \
	      --hiresmesh="$HighResMesh" \
	      --lowresmesh="$LowResMeshes" \
	      --subcortgraylabels="$SubcorticalGrayLabels" \
	      --freesurferlabels="$FreeSurferLabels" \
	      --refmyelinmaps="$ReferenceMyelinMaps" \
	      --regname="$RegName" \
	      --printcom=$PRINTCOM"
	      
	  echo ". ${EnvironmentScript}"
	  
      done
      
      
else

      echo "Without T2 image"
      
      for Subject in $Subjlist ; do
      
	  echo $Subject
      
	  #Input Variables
	  SurfaceAtlasDIR="${HCPPIPEDIR_Templates}/standard_mesh_atlases"
	  GrayordinatesSpaceDIR="${HCPPIPEDIR_Templates}/91282_Greyordinates"
	  GrayordinatesResolutions="2" #Usually 2mm, if multiple delimit with @, must already exist in templates dir
	  HighResMesh="164" #Usually 164k vertices
	  LowResMeshes="32" #Usually 32k vertices, if multiple delimit with @, must already exist in templates dir
	  SubcorticalGrayLabels="${HCPPIPEDIR_Config}/FreeSurferSubcorticalLabelTableLut.txt"
	  FreeSurferLabels="${HCPPIPEDIR_Config}/FreeSurferAllLut.txt"
	  ReferenceMyelinMaps="${HCPPIPEDIR_Templates}/standard_mesh_atlases/Conte69.MyelinMap_BC.164k_fs_LR.dscalar.nii"
	  # RegName="MSMSulc" #MSMSulc is recommended, if binary is not available use FS (FreeSurfer)
	  RegName="FS"
	  
	  if [ -n "${command_line_specified_run_local}" ] ; then
	      queuing_command=""
	  else
	      if [ ! -d ${StudyFolder}/log ] ; then
		  mkdir ${StudyFolder}/log
	      fi
	      queuing_command="qstat ${QUEUE} -oe ${StudyFolder}/log/ -N fshcp_${Subject}"
	  fi
	  
	  ${queuing_command} T1_PostFreeSurferPipelineWithoutT2.sh \
	      --path="$StudyFolder" \
	      --subject="$Subject" \
	      --surfatlasdir="$SurfaceAtlasDIR" \
	      --grayordinatesdir="$GrayordinatesSpaceDIR" \
	      --grayordinatesres="$GrayordinatesResolutions" \
	      --hiresmesh="$HighResMesh" \
	      --lowresmesh="$LowResMeshes" \
	      --subcortgraylabels="$SubcorticalGrayLabels" \
	      --freesurferlabels="$FreeSurferLabels" \
	      --refmyelinmaps="$ReferenceMyelinMaps" \
	      --regname="$RegName" \
	      --printcom=$PRINTCOM

	  # The following lines are used for interactive debugging to set the positional parameters: $1 $2 $3 ...
	  
	  echo "set -- --path="$StudyFolder" \
	      --subject="$Subject" \
	      --surfatlasdir="$SurfaceAtlasDIR" \
	      --grayordinatesdir="$GrayordinatesSpaceDIR" \
	      --grayordinatesres="$GrayordinatesResolutions" \
	      --hiresmesh="$HighResMesh" \
	      --lowresmesh="$LowResMeshes" \
	      --subcortgraylabels="$SubcorticalGrayLabels" \
	      --freesurferlabels="$FreeSurferLabels" \
	      --refmyelinmaps="$ReferenceMyelinMaps" \
	      --regname="$RegName" \
	      --printcom=$PRINTCOM"
	      
	  echo ". ${EnvironmentScript}"
	  
      done

fi
