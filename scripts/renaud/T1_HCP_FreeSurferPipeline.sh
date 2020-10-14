#! /bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: T1_HCP_FreeSurferPipeline.sh -StudyFolder <SUBJECTS_DIR>  -Subjlist <SUBJ_ID>  [-runlocal -ist2] "
	echo ""
	echo "  -StudyFolder                 : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
	echo "  -Subjlist                    : Subject ids "
	echo "  Options  "
	echo "  -runlocal                    : run in local "
	echo "  -ist2	                     : using of T2 image "
	echo ""
	echo "Usage: T1_HCP_FreeSurferPipeline.sh -StudyFolder <SUBJECTS_DIR>  -Subjlist <SUBJ_ID>  [-runlocal -ist2] "
	echo ""
	exit 1
fi

user=`whoami`

#EnvironmentScript="/NAS/tupac/renaud/HCP/scripts/Pipelines-3.13.1/Examples/Scripts/SetUpHCPPipeline.sh" #Pipeline environment script
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
		echo "Usage: T1_HCP_FreeSurferPipeline.sh -StudyFolder <SUBJECTS_DIR>  -Subjlist <SUBJ_ID>  [-runlocal -ist2] "
		echo ""
		echo "  -StudyFolder                 : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -Subjlist                    : Subject ids "
		echo "  Options  "
		echo "  -runlocal                    : run in local "
		echo "  -ist2	                     : using of T2 image "
		echo ""
		echo "Usage: T1_HCP_FreeSurferPipeline.sh -StudyFolder <SUBJECTS_DIR>  -Subjlist <SUBJ_ID>  [-runlocal -ist2] "
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
		echo "Usage: T1_HCP_FreeSurferPipeline.sh -StudyFolder <SUBJECTS_DIR>  -Subjlist <SUBJ_ID>  [-runlocal -ist2] "
		echo ""
		echo "  -StudyFolder                 : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -Subjlist                    : Subject ids "
		echo "  Options  "
		echo "  -runlocal                    : run in local "
		echo "  -ist2	                     : using of T2 image "
		echo ""
		echo "Usage: T1_HCP_FreeSurferPipeline.sh -StudyFolder <SUBJECTS_DIR>  -Subjlist <SUBJ_ID>  [-runlocal -ist2] "
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

#Scripts called by this script do assume they run on the outputs of the PreFreeSurfer Pipeline

######################################### DO WORK ##########################################

if [ ! $useT2 = "FALSE" ] ; then

      echo "Using of T2 image"
      
      for Subject in $Subjlist ; do
      echo $Subject

      #Input Variables
      SubjectID="$Subject" #FreeSurfer Subject ID Name
      SubjectDIR="${StudyFolder}/${Subject}/T1w" #Location to Put FreeSurfer Subject's Folder
      T1wImage="${StudyFolder}/${Subject}/T1w/T1w_acpc_dc_restore.nii.gz" #T1w FreeSurfer Input (Full Resolution)
      T1wImageBrain="${StudyFolder}/${Subject}/T1w/T1w_acpc_dc_restore_brain.nii.gz" #T1w FreeSurfer Input (Full Resolution)
      T2wImage="${StudyFolder}/${Subject}/T1w/T2w_acpc_dc_restore.nii.gz" #T2w FreeSurfer Input (Full Resolution)

      if [ -n "${command_line_specified_run_local}" ] ; then
	  queuing_command=""
      else
	  if [ ! -d ${StudyFolder}/log ] ; then
	      mkdir ${StudyFolder}/log
	  fi
	  queuing_command="qstat ${QUEUE} -oe ${StudyFolder}/log/ -N fshcp_${Subject}"
      fi

      ${queuing_command} ${HCPPIPEDIR}/FreeSurfer/FreeSurferPipeline.sh \
	  --subject="$Subject" \
	  --subjectDIR="$SubjectDIR" \
	  --t1="$T1wImage" \
	  --t1brain="$T1wImageBrain" \
	  --t2="$T2wImage" \
	  --printcom=$PRINTCOM
	  
      # The following lines are used for interactive debugging to set the positional parameters: $1 $2 $3 ...

      echo "set -- --subject="$Subject" \
	  --subjectDIR="$SubjectDIR" \
	  --t1="$T1wImage" \
	  --t1brain="$T1wImageBrain" \
	  --t2="$T2wImage" \
	  --printcom=$PRINTCOM"

      echo ". ${EnvironmentScript}"

    done
      
else

      echo "Without T2 image"
      
      for Subject in $Subjlist ; do
      echo $Subject

      #Input Variables
      SubjectID="$Subject" #FreeSurfer Subject ID Name
      SubjectDIR="${StudyFolder}/${Subject}/T1w" #Location to Put FreeSurfer Subject's Folder
      T1wImage="${StudyFolder}/${Subject}/T1w/T1w_acpc_dc_restore.nii.gz" #T1w FreeSurfer Input (Full Resolution)
      T1wImageBrain="${StudyFolder}/${Subject}/T1w/T1w_acpc_dc_restore_brain.nii.gz" #T1w FreeSurfer Input (Full Resolution)

      if [ -n "${command_line_specified_run_local}" ] ; then
	  queuing_command=""
      else
	  if [ ! -d ${StudyFolder}/log ] ; then
	      mkdir ${StudyFolder}/log
	  fi
	  queuing_command="qstat ${QUEUE} -oe ${StudyFolder}/log/ -N fshcp_${Subject}"
      fi

      ${queuing_command} T1_FreeSurferPipelineWithoutT2.sh \
	  --subject="$Subject" \
	  --subjectDIR="$SubjectDIR" \
	  --t1="$T1wImage" \
	  --t1brain="$T1wImageBrain" \
	  --printcom=$PRINTCOM
	  
      # The following lines are used for interactive debugging to set the positional parameters: $1 $2 $3 ...

      echo "set -- --subject="$Subject" \
	  --subjectDIR="$SubjectDIR" \
	  --t1="$T1wImage" \
	  --t1brain="$T1wImageBrain" \
	  --printcom=$PRINTCOM"

      echo ". ${EnvironmentScript}"

    done


fi


