#! /bin/bash

directory='/NAS/tupac/protocoles/Strokdem/par'
patient='/NAS/tupac/protocoles/Strokdem/20140904PatientList.txt'

for subjid in $directory/*
do
	
	for data in $subjid/*
	do

		for f in $data/*.PAR
		do
			#echo `basename $f`
			if [ -e ${f%%.*}.PAR ]
			then
				g=${f%%.*}
				g=`basename $g`
				echo `basename $f`
				if [ ${g:0:2} == "et" ]
				then
					chiffre=`expr "$g" : '\(^et.\([0-9][_]*\)*\)'`
				else		
					if [ ${g:0:2} == "da" ]
					then
						chiffre=`expr "$g" : '\(^da.\([0-9][_]*\)*\)'`
					else	
						chiffre=`expr "$g" : '\(.\([0-9][_]*\)*\)'`
					fi
				fi
				d=${g:${#chiffre}}
				d=${d:0: -3}

				#echo $g $d
				case "$d" in
				'mips3d_carotids' )
					h='MIP_s3D_CAROTIDS_SEN'
					;;
				's3d_carotidssen' )
					h='s3D_CAROTIDS_SENSE'
					;;
				'flair_longtrcle' )
					h='FLAIR_longTR_CLEAR'
					;;
				's3dt1iso1mmhr' )
					h='s3DT1_ISO_1mm_HR'
					;;
				'dwisense' )
					h='DWI_SENSE'
					;;
				'ddwisense' )
					h='dDWI_SENSE'
					;;
				't2etoileclear' )
					h='T2_ETOILE_CLEAR'			
					;;
				'asl_multiphases' )
					h='ASL_MultiPhase_SENSE'
					;;
				'tset23mmclea' )
					h='TSE_T2_3_MM_CLEAR'			
					;;
				'fe_epi64x64res' )
					h='FE_EPI_64x64_resting'
					;;
				't2w_vista_hrsen' )
					h='T2W_VISTA_HR_SENSE'
					;;
				't1w_segdclear' )
					h='T1W_SE_GD_CLEAR'
					;;
				'dticorrections' )
					h='DTI_corrections_GOOD'
					;;
				'wipwippcaslse' )
					h='WIP_WIP_PCASL_SENSE'
					;;
				'wipdti_15dirse' )
					h='WIP_DTI_15dir_serie'
					;;
				'wipb0map' )
					h='WIP_B0_MAP'
					;;
				'wipwippcaslco' )
					h='WIP_WIP_PCASL_CORR_S'
					;;
				'wipt1w_segdcl' )
					h='WIP_T1W_SE_GD_CLEAR'
					;;
				'wipt2w_vista_hr' )	
					h='WIP_T2W_VISTA_HR_SENSE'
					;;
				'wipfe_epi64x64' )
					h='WIP_FE_EPI_64x64_resting'
					;;
				'wipasl_multipha' )
					h='WIP_ASL_MultiPhase_SENSE'
					;;
				'wipdticorrections')
					h='WIP_DTI_corrections'
					;;
				'wipdticorrecti')
					h='WIP_DTI_corrections'
					;;
				'wipdwisense' )
					h='WIP_DWI_SENSE'
					;;
				'wipddwisense' )
					h='WIP_dDWI_SENSE'
					;;	
				'wipdti_15dirse' )
					h='WIP_DTI_15dir_serie'			
					;;
				'wipsurvey')
					h='WIP_SURVEY'
					;;
				'vs3d_carotidsto' )
					h='Vs3D_CAROTIDS_tourne'
					;;
				'vs3d_carotidsse' )
					h='Vs3D_CAROTIDS_SENSE'
					;;
				't1w_ffegadocle' )
					h='T1W_FFE_GADO_CLEAR'
					;;
				'wipt2etoilecl' )
					h='WIP_T2_ETOILE_CLEAR'
					;;
				'wipflair_longtr' )
					h='WIP_FLAIR_longTR_CLEAR'
					;;
				'wips3dt1iso1m' )
					h='WIP_s3dt1_ISO_1mm_HR'
					;;
				'newseries' )
					h='NEW_SERIES'
					;;
				* ) #ax, sag, coro, survey
					if [ ${#d} -lt 10 ] 
					then
						#echo $g $d $(echo $d | tr [a-z] [A-Z])
						h=$(echo $d | tr [a-z] [A-Z])
					fi
					;;
				esac
				#echo $h
				
				mkdir $data/$h/
				mv ${f%%.*}.par $data/$h/
				mv ${f%%.*}.rec $data/$h/
				echo ${f%%.*}.par 
				echo ${f%%.*}.rec 
				echo $data/$h
				dcm2nii -o $data/$h $data/$h/$g.par

			fi
		done
	done
done


