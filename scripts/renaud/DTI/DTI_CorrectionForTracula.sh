#!/bin/bash
set -e


if [ $# -lt 10 ]
then
	echo ""
	echo "Usage: DTI_CorrectionForTracula.sh  -dtipos <path>  -dtineg <path>  -subj <name>  -o <path>  -echospacing <value>  [-denoise  -pedir <value>  -b0dist <value>  -b0max <value>  -onlypos]"
	echo ""
	echo "NIFTI IMAGE WHITHOUT EXTENSION"
	echo "  -dtipos                   : PA dti file (nifti image) + need bval and bvec with same name "
	echo "  -dtineg                   : AP dti file (nifti image) + need bval and bvec with same name "
	echo "  -subj                     : Subject's Freesurfer folder "
	echo "  -o                        : output folder "
	echo "  -echospacing              : echo spacing in ms "
	echo " "
	echo "Options :"
	echo "  -denoise                  : do dwi denoising (Default: NONE)"
	echo "  -pedir                    : phase encoding direction (Default: 2 for +=PA and -=AP)"
	echo "  -b0dist                   : minimum distance in volumes between b0s considered for preprocessing (Default: 3)"
	echo "  -b0max                    : Volumes with a bvalue smaller than this value will be considered as b0s (Default: 50)"
	echo "  -onlypos                  : Keep only gradient diffusions from PA file (Default: no)"
	echo ""
	echo "Usage: DTI_CorrectionForTracula.sh  -dtipos <path>  -dtineg <path>  -subj <name>  -o <path>  -echospacing <value>  [-denoise  -pedir <value>  -b0dist <value>  -b0max <value>  -onlypos]"
	echo ""
	exit 1
fi


#### Inputs ####
index=1
echo "------------------------"

ToDenoising="NONE"
Gdcoeffs="NONE"
PEdir="2"
echo_spacing=0.7005818
b0dist="3"               # Minimum distance in volumes between b0s considered for preprocessing
b0maxbval=50             # Volumes with a bvalue smaller than this value will be considered as b0s
OnlyPos=0


while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: DTI_CorrectionForTracula.sh  -dtipos <path>  -dtineg <path>  -subj <name>  -o <path>  -echospacing <value>  [-denoise  -pedir <value>  -b0dist <value>  -b0max <value>  -onlypos]"
		echo ""
		echo "NIFTI IMAGE WHITHOUT EXTENSION"
		echo "  -dtipos                   : PA dti file (nifti image) + need bval and bvec with same name "
		echo "  -dtineg                   : AP dti file (nifti image) + need bval and bvec with same name "
		echo "  -subj                     : Subject's Freesurfer folder "
		echo "  -o                        : output folder "
		echo "  -echospacing              : echo spacing in ms "
		echo " "
		echo "Options :"
		echo "  -denoise                  : do dwi denoising (Default: NONE)"
		echo "  -pedir                    : phase encoding direction (Default: 2 for +=PA and -=AP)"
		echo "  -b0dist                   : minimum distance in volumes between b0s considered for preprocessing (Default: 3)"
		echo "  -b0max                    : Volumes with a bvalue smaller than this value will be considered as b0s (Default: 50)"
		echo "  -onlypos                  : Keep only gradient diffusions from PA file (Default: no)"
		echo ""
		echo "Usage: DTI_CorrectionForTracula.sh  -dtipos <path>  -dtineg <path>  -subj <name>  -o <path>  -echospacing <value>  [-denoise  -pedir <value>  -b0dist <value>  -b0max <value>  -onlypos]"
		echo ""
		exit 1
		;;
	-dtipos)
		PosInputImages=`expr $index + 1`
		eval PosInputImages=\${$PosInputImages}
		echo "  |-------> DTI pos file : $PosInputImages"
		index=$[$index+1]
		;;
	-dtineg)
		NegInputImages=`expr $index + 1`
		eval NegInputImages=\${$NegInputImages}
		echo "  |-------> DTI neg file : ${NegInputImages}"
		index=$[$index+1]
		;;
	-o)
		outdir=`expr $index + 1`
		eval outdir=\${$outdir}
		echo "  |-------> output folder : ${outdir}"
		index=$[$index+1]
		;;
	-subj)
		SUBJ=`expr $index + 1`
		eval SUBJ=\${$SUBJ}
		echo "  |-------> subject's FS folder : ${SUBJ}"
		index=$[$index+1]
		;;
	-echospacing)
		echo_spacing=`expr $index + 1`
		eval echo_spacing=\${$echo_spacing}
		echo "  |-------> echo spacing : ${echo_spacing}"
		index=$[$index+1]
		;;
	-denoise)
		ToDenoising=1
		echo "Do dwi denoising"
		;;	
	-pedir)
		PEdir=`expr $index + 1`
		eval PEdir=\${$PEdir}
		echo "  |-------> phase encoding direction : ${PEdir}"
		index=$[$index+1]
		;;
	-b0dist)
		b0dist=`expr $index + 1`
		eval b0dist=\${$b0dist}
		echo "  |-------> minimum distance between b0 : ${b0dist}"
		index=$[$index+1]
		;;
	-b0max)
		b0maxbval=`expr $index + 1`
		eval b0maxbval=\${$b0maxbval}
		echo "  |-------> b0 max value : ${b0maxbval}"
		index=$[$index+1]
		;;
	-onlypos)
		OnlyPos=1
		echo "Keep only PA gradient diffusions"
		;;
	-*)
		TEMP=`expr $index`
		eval TEMP=\${$TEMP}
		echo "${TEMP} : unknown argument"
		echo ""
		echo "Enter $0 -help for help"
		exit 1
		;;
	esac
	index=$[$index+1]
done
#################


#=============================================================================
#
# Function Description
#  find the minimum of two specified numbers
#
min()
{
	if [ $1 -le $2 ]
	then
		echo $1
	else
		echo $2
	fi
}

isodd(){
	echo "$(( $1 % 2 ))"
}


#=============================================================================
# HCP script


# --------------------------------------------------------------------------------
#                         Load Function Libraries
# --------------------------------------------------------------------------------

source $HCPPIPEDIR/global/scripts/log.shlib  # Logging related functions
source $HCPPIPEDIR/global/scripts/opts.shlib # Command line option functions


#DIR="/NAS/tupac/protocoles/healthy_volunteers/data/T01S01_831014RL"
#StudyFolder="/NAS/tupac/protocoles/healthy_volunteers/reproducibility"
#Subject="T01S01_831014RL_T2"
#DWIName="dti_denoise"

#PosInputImages=${DIR}/x20160404_154949WIPDTI32DIRSENSEs701a1007.nii.gz
#NegInputImages=${DIR}/x20160404_154949WIPcorrectiondtiSENSEs601a1006.nii.gz

#outdir=${StudyFolder}/${Subject}/${DWIName}


echo " "
echo "START: DTI_CorrectionForTracula.sh"
echo " START: `date`"
echo ""


echo ""
echo "################################################################################################"
echo "##                                     CONFIGURATIONS "
echo "################################################################################################"
echo ""

# Establish output directory paths
if [ ${outdir} ]; then rm -rf ${outdir}; fi

# Make sure output directories exist
mkdir -p ${outdir}

echo "outdir: ${outdir}"
mkdir ${outdir}/rawdata
mkdir ${outdir}/topup
mkdir ${outdir}/eddy
mkdir ${outdir}/data

if [ ${PEdir} -eq 1 ] ; then    # RL/LR phase encoding
	basePos="RL"
	baseNeg="LR"
elif [ ${PEdir} -eq 2 ] ; then  # PA/AP phase encoding
	basePos="PA"
	baseNeg="AP"
else
	echo "ERROR: Invalid Phase Encoding Directory (PEdir} specified: ${PEdir}"
	exit 1
fi

echo "basePos: ${basePos}"
echo "baseNeg: ${baseNeg}"

rawdir=${outdir}/rawdata

Pos_count=1
absname=`${FSLDIR}/bin/imglob ${PosInputImages}`
${FSLDIR}/bin/imcp ${absname} ${outdir}/rawdata/${basePos}_${Pos_count}
cp ${absname}.bval ${outdir}/rawdata/${basePos}_${Pos_count}.bval
cp ${absname}.bvec ${outdir}/rawdata/${basePos}_${Pos_count}.bvec

Neg_count=1
absname=`${FSLDIR}/bin/imglob ${NegInputImages}`
NegVols=`${FSLDIR}/bin/fslval ${NegInputImages} dim4`
if [ ${OnlyPos} -eq 1 ] || [ ${NegVols} -eq 1 ]; then

	${FSLDIR}/bin/fslroi ${absname} ${outdir}/rawdata/${baseNeg}_${Neg_count} 0 1
	echo "0" > ${outdir}/rawdata/${baseNeg}_${Neg_count}.bval
	echo "0" > ${outdir}/rawdata/${baseNeg}_${Neg_count}.bvec
	echo "0" >> ${outdir}/rawdata/${baseNeg}_${Neg_count}.bvec
	echo "0" >> ${outdir}/rawdata/${baseNeg}_${Neg_count}.bvec

else

	${FSLDIR}/bin/imcp ${absname} ${outdir}/rawdata/${baseNeg}_${Neg_count}
	cp ${absname}.bval ${outdir}/rawdata/${baseNeg}_${Neg_count}.bval
	cp ${absname}.bvec ${outdir}/rawdata/${baseNeg}_${Neg_count}.bvec

fi

# Compute Total_readout in secs with up to 6 decimal places
any=`ls ${rawdir}/${basePos}*.nii* |head -n 1`
echo $any
if [ ${PEdir} -eq 1 ]; then    #RL/LR phase encoding
	dimP=`${FSLDIR}/bin/fslval ${any} dim1`
elif [ ${PEdir} -eq 2 ]; then  #PA/AP phase encoding
	dimP=`${FSLDIR}/bin/fslval ${any} dim2`
fi
echo $dimP
nPEsteps=$(($dimP - 1))                         #If GRAPPA is used this needs to include the GRAPPA factor! 
ro_time=`echo "${echo_spacing} * ${nPEsteps}" | bc -l`
ro_time=`echo "scale=6; ${ro_time} / 1000" | bc -l`
echo "Total readout time is $ro_time secs"


echo ""
echo "################################################################################################"
echo "##                                     FLIP FOR FSL "
echo "################################################################################################"
echo ""


cmd="DTI_TransposeGradientFiles.sh ${outdir}/rawdata/${basePos}_${Pos_count}.bval ${outdir}/rawdata/${basePos}_${Pos_count}.bvec"
echo ${cmd};eval ${cmd};
cmd="DTI_TransposeGradientFiles.sh ${outdir}/rawdata/${baseNeg}_${Neg_count}.bval ${outdir}/rawdata/${baseNeg}_${Neg_count}.bvec"
echo ${cmd};eval ${cmd};

cp ${outdir}/rawdata/${basePos}_${Pos_count}_t.bval ${outdir}/rawdata/backup.bvals
cp ${outdir}/rawdata/${basePos}_${Pos_count}_t.bvec ${outdir}/rawdata/backup.bvecs
mv ${outdir}/rawdata/${basePos}_${Pos_count}_t.bval ${outdir}/rawdata/${basePos}_${Pos_count}.mghdti.bvals
mv ${outdir}/rawdata/${basePos}_${Pos_count}_t.bvec ${outdir}/rawdata/${basePos}_${Pos_count}.mghdti.bvecs
mv ${outdir}/rawdata/${baseNeg}_${Neg_count}_t.bval ${outdir}/rawdata/${baseNeg}_${Neg_count}.mghdti.bvals
mv ${outdir}/rawdata/${baseNeg}_${Neg_count}_t.bvec ${outdir}/rawdata/${baseNeg}_${Neg_count}.mghdti.bvecs

flip4fsl ${outdir}/rawdata/${basePos}_${Pos_count}.nii.gz ${outdir}/rawdata/${basePos}_${Pos_count}_flip.nii.gz
flip4fsl ${outdir}/rawdata/${baseNeg}_${Neg_count}.nii.gz ${outdir}/rawdata/${baseNeg}_${Neg_count}_flip.nii.gz

rm -f ${outdir}/rawdata/${basePos}_${Pos_count}.mghdti.bvals ${outdir}/rawdata/${basePos}_${Pos_count}.mghdti.bvecs ${outdir}/rawdata/${baseNeg}_${Neg_count}.mghdti.bvals ${outdir}/rawdata/${baseNeg}_${Neg_count}.mghdti.bvecs
rm -f ${outdir}/rawdata/${basePos}_${Pos_count}.bval ${outdir}/rawdata/${basePos}_${Pos_count}.bvec ${outdir}/rawdata/${baseNeg}_${Neg_count}.bval ${outdir}/rawdata/${baseNeg}_${Neg_count}.bvec ${outdir}/rawdata/${basePos}_${Pos_count}.nii.gz ${outdir}/rawdata/${baseNeg}_${Neg_count}.nii.gz

mv ${outdir}/rawdata/${basePos}_${Pos_count}_flip.mghdti.bvals ${outdir}/rawdata/${basePos}_${Pos_count}.bval
mv ${outdir}/rawdata/${basePos}_${Pos_count}_flip.mghdti.bvecs ${outdir}/rawdata/${basePos}_${Pos_count}.bvec
mv ${outdir}/rawdata/${basePos}_${Pos_count}_flip.nii.gz ${outdir}/rawdata/${basePos}_${Pos_count}.nii.gz
mv ${outdir}/rawdata/${baseNeg}_${Neg_count}_flip.mghdti.bvals ${outdir}/rawdata/${baseNeg}_${Neg_count}.bval
mv ${outdir}/rawdata/${baseNeg}_${Neg_count}_flip.mghdti.bvecs ${outdir}/rawdata/${baseNeg}_${Neg_count}.bvec
mv ${outdir}/rawdata/${baseNeg}_${Neg_count}_flip.nii.gz ${outdir}/rawdata/${baseNeg}_${Neg_count}.nii.gz



echo ""
echo "################################################################################################"
echo "##                      CREATE 2 FILES FOR EACH PHASE ENCODING DIRECTION "
echo "################################################################################################"
echo ""


# Create two files for each phase encoding direction, that for each series contain the number of 
# corresponding volumes and the number of actual volumes. The file e.g. RL_SeriesCorrespVolNum.txt
# will contain as many rows as non-EMPTY series. The entry M in row J indicates that volumes 0-M 
# from RLseries J has corresponding LR pairs. This file is used in basic_preproc to generate 
# topup/eddy indices and extract corresponding b0s for topup. The file e.g. Pos_SeriesVolNum.txt 
# will have as many rows as maximum series pairs (even unmatched pairs). The entry M N in row J 
# indicates that the RLSeries J has its 0-M volumes corresponding to LRSeries J and RLJ has N 
# volumes in total. This file is used in eddy_combine.
log_Msg "Create two files for each phase encoding direction"


PosVols=`${FSLDIR}/bin/fslval ${outdir}/rawdata/${basePos}_${Pos_count} dim4`
NegVols=`${FSLDIR}/bin/fslval ${outdir}/rawdata/${baseNeg}_${Neg_count} dim4`

CorrVols=`min ${NegVols} ${PosVols}`
echo ${CorrVols} ${PosVols} >> ${outdir}/eddy/Pos_SeriesVolNum.txt
if [ ${PosVols} -ne 0 ]
then
	echo ${CorrVols} >> ${outdir}/rawdata/${basePos}_SeriesCorrespVolNum.txt
fi

echo ${CorrVols} ${NegVols} >> ${outdir}/eddy/Neg_SeriesVolNum.txt
if [ ${NegVols} -ne 0 ]
then
	echo ${CorrVols} >> ${outdir}/rawdata/${baseNeg}_SeriesCorrespVolNum.txt
fi



echo ""
echo "################################################################################################"
echo "##                               SHIFT CORRECTION (Philips) "
echo "################################################################################################"
echo ""

echo "shift correction"

vox_shift="1"

for entry in ${rawdir}/${baseNeg}*.nii*; do

	basename=`basename ${entry%%.*}`
	echo "Processing $basename"

	mkdir ${rawdir}/shiftcor

	fslsplit ${entry} ${rawdir}/shiftcor/epi_ -t
	gunzip ${rawdir}/shiftcor/*.gz

	matlab -nodisplay <<EOF
	cd('${outdir}/rawdata/shiftcor')
	D=dir('epi*.nii');
	for k=1:length(D), EPIshift_and_flip(D(k).name, ['r' D(k).name], ['s' D(k).name], ${vox_shift}); end
EOF

	fslmerge -t ${rawdir}/s${basename} ${rawdir}/shiftcor/sepi*
	${FSLDIR}/bin/immv ${rawdir}/s${basename} ${rawdir}/${basename}

	rm -rf ${rawdir}/shiftcor

done



echo ""
echo "################################################################################################"
echo "##                                      DWI DENOISING "
echo "################################################################################################"
echo ""

if [ $ToDenoising = "NONE" ] ; then echo "do not denoising"; else

	echo "dwi denoising"

	for entry in ${rawdir}/${basePos}*.nii* ${rawdir}/${baseNeg}*.nii*; do

		basename=`basename ${entry%%.*}`
		echo "Processing $basename"

		Nvol=`${FSLDIR}/bin/fslval ${entry} dim4`
		if [[ ${Nvol} -gt 1 ]]; then
			# denoise
			echo "dwidenoise ${entry} ${rawdir}/${basename}_den.nii.gz -noise ${rawdir}/noise_${basename}.nii.gz"
			dwidenoise ${entry} ${rawdir}/${basename}_den.nii.gz -noise ${rawdir}/noise_${basename}.nii.gz

			# compute residual
			echo "mrcalc ${entry} ${rawdir}/${basename}_den.nii.gz -subtract ${rawdir}/residual_${basename}.nii.gz"
			mrcalc ${entry} ${rawdir}/${basename}_den.nii.gz -subtract ${rawdir}/residual_${basename}.nii.gz

			${FSLDIR}/bin/immv ${rawdir}/${basename}_den ${rawdir}/${basename}
		fi

	done

fi



echo ""
echo "################################################################################################"
echo "##                            INTENSITY NORMALIZATION ACCROSS SERIES "
echo "################################################################################################"
echo ""

echo "Rescaling series to ensure consistency across baseline intensities"

entry_cnt=0
for entry in ${rawdir}/${basePos}*.nii* ${rawdir}/${baseNeg}*.nii*  #For each series, get the mean b0 and rescale to match the first series baseline
do
	basename=`imglob ${entry}`
	echo "Processing $basename"
	
	echo "About to fslmaths ${entry} -Xmean -Ymean -Zmean ${basename}_mean"
	${FSLDIR}/bin/fslmaths ${entry} -Xmean -Ymean -Zmean ${basename}_mean
	if [ ! -e ${basename}_mean.nii.gz ] ; then
		echo "ERROR: Mean file: ${basename}_mean.nii.gz not created"
		exit 1
	fi
	
	echo "Getting Posbvals from ${basename}.bval"
	Posbvals=`cat ${basename}.bval`
	echo "Posbvals: ${Posbvals}"
	
	mcnt=0
	for i in ${Posbvals} #extract all b0s for the series
	do
		echo "Posbvals i: ${i}"
		cnt=`$FSLDIR/bin/zeropad $mcnt 4`
		echo "cnt: ${cnt}"
		if [ $i -lt ${b0maxbval} ]; then
			echo "About to fslroi ${basename}_mean ${basename}_b0_${cnt} ${mcnt} 1"
			$FSLDIR/bin/fslroi ${basename}_mean ${basename}_b0_${cnt} ${mcnt} 1
		fi
		mcnt=$((${mcnt} + 1))
	done
	
	echo "About to fslmerge -t ${basename}_mean `echo ${basename}_b0_????.nii*`"
	${FSLDIR}/bin/fslmerge -t ${basename}_mean `echo ${basename}_b0_????.nii*`
	
	echo "About to fslmaths ${basename}_mean -Tmean ${basename}_mean"
	${FSLDIR}/bin/fslmaths ${basename}_mean -Tmean ${basename}_mean #This is the mean baseline b0 intensity for the series
	${FSLDIR}/bin/imrm ${basename}_b0_????
	if [ ${entry_cnt} -eq 0 ]; then      #Do not rescale the first series
		rescale=`fslmeants -i ${basename}_mean`
	else
		scaleS=`fslmeants -i ${basename}_mean`
		${FSLDIR}/bin/fslmaths ${basename} -mul ${rescale} -div ${scaleS} ${basename}_new
		${FSLDIR}/bin/imrm ${basename}   #For the rest, replace the original dataseries with the rescaled one
		${FSLDIR}/bin/immv ${basename}_new ${basename}
	fi
	entry_cnt=$((${entry_cnt} + 1))
	${FSLDIR}/bin/imrm ${basename}_mean
done



echo ""
echo "################################################################################################"
echo "##                  B0 EXTRACTION AND CREATION OF INDEX FILES FOR TOPUP/EDDY "
echo "################################################################################################"
echo ""

echo "Extracting b0s from PE_Positive volumes and creating index and series files"
declare -i sesdimt #declare sesdimt as integer
tmp_indx=1
while read line ; do  #Read SeriesCorrespVolNum.txt file
	PCorVolNum[${tmp_indx}]=`echo $line | awk {'print $1'}`
	tmp_indx=$((${tmp_indx}+1))
done < ${rawdir}/${basePos}_SeriesCorrespVolNum.txt

scount=1
scount2=1
indcount=0
for entry in ${rawdir}/${basePos}*.nii*  #For each Pos volume
do
	#Extract b0s and create index file
	basename=`imglob ${entry}`
	Posbvals=`cat ${basename}.bval`
	count=0  #Within series counter
	count3=$((${b0dist} + 1))
	for i in ${Posbvals}
	do
		if [ $count -ge ${PCorVolNum[${scount2}]} ]; then
			tmp_ind=${indcount}
			if [ $[tmp_ind] -eq 0 ]; then
				tmp_ind=$((${indcount}+1))
			fi
			echo ${tmp_ind} >>${rawdir}/index.txt
		else  #Consider a b=0 a volume that has a bvalue<50 and is at least 50 volumes away from the previous
			if [ $i -lt ${b0maxbval} ] && [ ${count3} -gt ${b0dist} ]; then
				cnt=`$FSLDIR/bin/zeropad $indcount 4`
				echo "Extracting Pos Volume $count from ${entry} as a b=0. Measured b=$i" >>${rawdir}/extractedb0.txt
				$FSLDIR/bin/fslroi ${entry} ${rawdir}/Pos_b0_${cnt} ${count} 1
				if [ ${PEdir} -eq 1 ]; then    #RL/LR phase encoding
					echo 1 0 0 ${ro_time} >> ${rawdir}/acqparams.txt
				elif [ ${PEdir} -eq 2 ]; then  #AP/PA phase encoding
					echo 0 1 0 ${ro_time} >> ${rawdir}/acqparams.txt
				fi
				indcount=$((${indcount} + 1))
				count3=0
			fi
			echo ${indcount} >>${rawdir}/index.txt
			count3=$((${count3} + 1))
		fi
		count=$((${count} + 1))
	done
	
	#Create series file
	sesdimt=`${FSLDIR}/bin/fslval ${entry} dim4` #Number of datapoints per Pos series
	for (( j=0; j<${sesdimt}; j++ ))
	do
		echo ${scount} >> ${rawdir}/series_index.txt
	done
	scount=$((${scount} + 1))
	scount2=$((${scount2} + 1))
done

echo "Extracting b0s from PE_Negative volumes and creating index and series files"
tmp_indx=1
while read line ; do  #Read SeriesCorrespVolNum.txt file
	NCorVolNum[${tmp_indx}]=`echo $line | awk {'print $1'}`
	tmp_indx=$((${tmp_indx}+1))
done < ${rawdir}/${baseNeg}_SeriesCorrespVolNum.txt

Poscount=${indcount}
indcount=0
scount2=1
for entry in ${rawdir}/${baseNeg}*.nii* #For each Neg volume
do
	#Extract b0s and create index file
	basename=`imglob ${entry}`
	Negbvals=`cat ${basename}.bval`
	count=0
	count3=$((${b0dist} + 1))
	for i in ${Negbvals}
	do
		if [ $count -ge ${NCorVolNum[${scount2}]} ]; then
			tmp_ind=${indcount}
			if [ $[tmp_ind] -eq 0 ]; then
				tmp_ind=$((${indcount}+1))
			fi
			echo $((${tmp_ind} + ${Poscount})) >>${rawdir}/index.txt
		else #Consider a b=0 a volume that has a bvalue<50 and is at least 50 volumes away from the previous
			if [ $i -lt ${b0maxbval} ] && [ ${count3} -gt ${b0dist} ]; then
				cnt=`$FSLDIR/bin/zeropad $indcount 4`
				echo "Extracting Neg Volume $count from ${entry} as a b=0. Measured b=$i" >>${rawdir}/extractedb0.txt
				$FSLDIR/bin/fslroi ${entry} ${rawdir}/Neg_b0_${cnt} ${count} 1
				if [ ${PEdir} -eq 1 ]; then    #RL/LR phase encoding
					echo -1 0 0 ${ro_time} >> ${rawdir}/acqparams.txt
				elif [ ${PEdir} -eq 2 ]; then  #AP/PA phase encoding
					echo 0 -1 0 ${ro_time} >> ${rawdir}/acqparams.txt
				fi
				indcount=$((${indcount} + 1))
				count3=0
			fi
			echo $((${indcount} + ${Poscount})) >>${rawdir}/index.txt
			count3=$((${count3} + 1))
		fi
		count=$((${count} + 1))
	done
	
	#Create series file
	sesdimt=`${FSLDIR}/bin/fslval ${entry} dim4`
	for (( j=0; j<${sesdimt}; j++ ))
	do
		echo ${scount} >> ${rawdir}/series_index.txt #Create series file
	done
	scount=$((${scount} + 1))
	scount2=$((${scount2} + 1))
done



echo ""
echo "################################################################################################"
echo "##                          MERGING FILES AND CORRECT NUMBER OF SLICES "
echo "################################################################################################"
echo ""

echo "Merging Pos and Neg images"
${FSLDIR}/bin/fslmerge -t ${rawdir}/Pos_b0 `${FSLDIR}/bin/imglob ${rawdir}/Pos_b0_????.*`
${FSLDIR}/bin/fslmerge -t ${rawdir}/Neg_b0 `${FSLDIR}/bin/imglob ${rawdir}/Neg_b0_????.*`
${FSLDIR}/bin/imrm ${rawdir}/Pos_b0_????
${FSLDIR}/bin/imrm ${rawdir}/Neg_b0_????
${FSLDIR}/bin/fslmerge -t ${rawdir}/Pos `echo ${rawdir}/${basePos}*.nii*`
${FSLDIR}/bin/fslmerge -t ${rawdir}/Neg `echo ${rawdir}/${baseNeg}*.nii*`

paste `echo ${rawdir}/${basePos}*.bval` >${rawdir}/Pos.bval
paste `echo ${rawdir}/${basePos}*.bvec` >${rawdir}/Pos.bvec
paste `echo ${rawdir}/${baseNeg}*.bval` >${rawdir}/Neg.bval
paste `echo ${rawdir}/${baseNeg}*.bvec` >${rawdir}/Neg.bvec


dimz=`${FSLDIR}/bin/fslval ${rawdir}/Pos dim3`
if [ `isodd $dimz` -eq 1 ];then
	echo "Remove one slice from data to get even number of slices"
	${FSLDIR}/bin/fslroi ${rawdir}/Pos ${rawdir}/Posn 0 -1 0 -1 1 -1
	${FSLDIR}/bin/fslroi ${rawdir}/Neg ${rawdir}/Negn 0 -1 0 -1 1 -1
	${FSLDIR}/bin/fslroi ${rawdir}/Pos_b0 ${rawdir}/Pos_b0n 0 -1 0 -1 1 -1
	${FSLDIR}/bin/fslroi ${rawdir}/Neg_b0 ${rawdir}/Neg_b0n 0 -1 0 -1 1 -1
	${FSLDIR}/bin/imrm ${rawdir}/Pos
	${FSLDIR}/bin/imrm ${rawdir}/Neg
	${FSLDIR}/bin/imrm ${rawdir}/Pos_b0
	${FSLDIR}/bin/imrm ${rawdir}/Neg_b0
	${FSLDIR}/bin/immv ${rawdir}/Posn ${rawdir}/Pos
	${FSLDIR}/bin/immv ${rawdir}/Negn ${rawdir}/Neg
	${FSLDIR}/bin/immv ${rawdir}/Pos_b0n ${rawdir}/Pos_b0
	${FSLDIR}/bin/immv ${rawdir}/Neg_b0n ${rawdir}/Neg_b0
fi

echo "Perform final merge"
${FSLDIR}/bin/fslmerge -t ${rawdir}/Pos_Neg_b0 ${rawdir}/Pos_b0 ${rawdir}/Neg_b0 
${FSLDIR}/bin/fslmerge -t ${rawdir}/Pos_Neg ${rawdir}/Pos ${rawdir}/Neg
paste ${rawdir}/Pos.bval ${rawdir}/Neg.bval >${rawdir}/Pos_Neg.bvals
paste ${rawdir}/Pos.bvec ${rawdir}/Neg.bvec >${rawdir}/Pos_Neg.bvecs

${FSLDIR}/bin/imrm ${rawdir}/Pos
${FSLDIR}/bin/imrm ${rawdir}/Neg



echo ""
echo "################################################################################################"
echo "##                             MOVE FILES TO APPROPRIATE DIRECTORIES "
echo "################################################################################################"
echo ""

topupdir=${outdir}/topup
eddydir=${outdir}/eddy

echo "Move files to appropriate directories"
mv ${rawdir}/extractedb0.txt ${topupdir}
mv ${rawdir}/acqparams.txt ${topupdir}
${FSLDIR}/bin/immv ${rawdir}/Pos_Neg_b0 ${topupdir}
${FSLDIR}/bin/immv ${rawdir}/Pos_b0 ${topupdir}
${FSLDIR}/bin/immv ${rawdir}/Neg_b0 ${topupdir}

cp ${topupdir}/acqparams.txt ${eddydir}
mv ${rawdir}/index.txt ${eddydir}
mv ${rawdir}/series_index.txt ${eddydir}
${FSLDIR}/bin/immv ${rawdir}/Pos_Neg ${eddydir}
mv ${rawdir}/Pos_Neg.bvals ${eddydir}
mv ${rawdir}/Pos_Neg.bvecs ${eddydir}
mv ${rawdir}/Pos.bv?? ${eddydir}
mv ${rawdir}/Neg.bv?? ${eddydir}


echo ""
echo "################################################################################################"
echo "##                                          TOPUP "
echo "################################################################################################"
echo ""


configdir=${HCPPIPEDIR_Config}
#topup_config_file=${FSLDIR}/etc/flirtsch/b02b0.cnf
topup_config_file=${configdir}/b02b0.cnf

${FSLDIR}/bin/topup --imain=${topupdir}/Pos_Neg_b0 --datain=${topupdir}/acqparams.txt --config=${topup_config_file} --out=${topupdir}/topup_Pos_Neg_b0 -v

dimt=`${FSLDIR}/bin/fslval ${topupdir}/Pos_b0 dim4`
dimt=$((${dimt} + 1))

echo "Applying topup to get a hifi b0"
${FSLDIR}/bin/fslroi ${topupdir}/Pos_b0 ${topupdir}/Pos_b01 0 1
${FSLDIR}/bin/fslroi ${topupdir}/Neg_b0 ${topupdir}/Neg_b01 0 1
${FSLDIR}/bin/applytopup --imain=${topupdir}/Pos_b01,${topupdir}/Neg_b01 --topup=${topupdir}/topup_Pos_Neg_b0 --datain=${topupdir}/acqparams.txt --inindex=1,${dimt} --out=${topupdir}/hifib0

if [ ! -f ${topupdir}/hifib0.nii.gz ]; then
    echo "run_topup.sh -- ERROR -- ${FSLDIR}/bin/applytopup failed to generate ${workingdir}/hifib0.nii.gz"
    # Need to add mechanism whereby scripts that invoke this script (run_topup.sh)
    # check for a return code to determine success or failure
fi

${FSLDIR}/bin/imrm ${topupdir}/Pos_b0*
${FSLDIR}/bin/imrm ${topupdir}/Neg_b0*

echo "Running BET on the hifi b0"
${FSLDIR}/bin/bet ${topupdir}/hifib0 ${topupdir}/nodif_brain -m -f 0.2

if [ ! -f ${topupdir}/nodif_brain.nii.gz ]; then
    echo "run_topup.sh -- ERROR -- ${FSLDIR}/bin/bet failed to generate ${topupdir}/nodif_brain.nii.gz"
    # Need to add mechanism whereby scripts that invoke this script (run_topup.sh)
    # check for a return code to determine success or failure
fi


echo ""
echo "################################################################################################"
echo "##                                       EDDY CORRECTION "
echo "################################################################################################"
echo ""

${FSLDIR}/bin/imcp ${topupdir}/nodif_brain_mask ${eddydir}/

echo ""
echo "EDDY CORRECTION"

echo ""
echo "${FSLDIR}/bin/eddy_openmp \
	--imain=${eddydir}/Pos_Neg \
	--mask=${eddydir}/nodif_brain_mask \
	--index=${eddydir}/index.txt \
	--acqp=${eddydir}/acqparams.txt \
	--bvecs=${eddydir}/Pos_Neg.bvecs \
	--bvals=${eddydir}/Pos_Neg.bvals \
	--fwhm=0 \
	--topup=${topupdir}/topup_Pos_Neg_b0 \
	--out=${eddydir}/eddy_unwarped_images \
	--flm=quadratic \
	--repol"

#eddy_cuda7.0
${FSLDIR}/bin/eddy_openmp \
	--imain=${eddydir}/Pos_Neg \
	--mask=${eddydir}/nodif_brain_mask \
	--index=${eddydir}/index.txt \
	--acqp=${eddydir}/acqparams.txt \
	--bvecs=${eddydir}/Pos_Neg.bvecs \
	--bvals=${eddydir}/Pos_Neg.bvals \
	--fwhm=0 \
	--topup=${topupdir}/topup_Pos_Neg_b0 \
	--out=${eddydir}/eddy_unwarped_images \
	--flm=quadratic \
	--repol



echo ""
echo "################################################################################################"
echo "##                                   COMBINE AND SORT DTI "
echo "################################################################################################"
echo ""

echo ""
echo "COMBINE AND SORT DTI"
echo ""

CombineDataFlag="2"
datadir=${outdir}/data

if [ ${CombineDataFlag} -eq 2 ]; then

	echo "imcp  ${eddydir}/eddy_unwarped_images ${datadir}/data"
	${FSLDIR}/bin/imcp  ${eddydir}/eddy_unwarped_images ${datadir}/data
	cp ${eddydir}/Pos_Neg.bvals ${datadir}/bvals
	cp ${eddydir}/eddy_unwarped_images.eddy_rotated_bvecs ${datadir}/bvecs

else

	echo "JAC resampling has been used. Eddy Output is now combined."
	PosVols=`wc ${eddydir}/Pos.bval | awk {'print $2'}`
	NegVols=`wc ${eddydir}/Neg.bval | awk {'print $2'}`    #Split Pos and Neg Volumes
	${FSLDIR}/bin/fslroi ${eddydir}/eddy_unwarped_images ${eddydir}/eddy_unwarped_Pos 0 ${PosVols}
	${FSLDIR}/bin/fslroi ${eddydir}/eddy_unwarped_images ${eddydir}/eddy_unwarped_Neg ${PosVols} ${NegVols}
	${FSLDIR}/bin/eddy_combine ${eddydir}/eddy_unwarped_Pos ${eddydir}/Pos.bval ${eddydir}/Pos.bvec ${eddydir}/Pos_SeriesVolNum.txt \
                    ${eddydir}/eddy_unwarped_Neg ${eddydir}/Neg.bval ${eddydir}/Neg.bvec ${eddydir}/Neg_SeriesVolNum.txt ${datadir} ${CombineDataFlag}

	${FSLDIR}/bin/imrm ${eddydir}/eddy_unwarped_Pos
	${FSLDIR}/bin/imrm ${eddydir}/eddy_unwarped_Neg
	cp ${datadir}/bvals ${datadir}/bvals_noRot
	cp ${datadir}/bvecs ${datadir}/bvecs_noRot
     
	#rm ${eddydir}/Pos.bv*
	#rm ${eddydir}/Neg.bv*

 
	# Divide Eddy-Rotated bvecs to Pos and Neg
	line1=`awk 'NR==1 {print; exit}' ${eddydir}/eddy_unwarped_images.eddy_rotated_bvecs`
	line2=`awk 'NR==2 {print; exit}' ${eddydir}/eddy_unwarped_images.eddy_rotated_bvecs`
	line3=`awk 'NR==3 {print; exit}' ${eddydir}/eddy_unwarped_images.eddy_rotated_bvecs`   
	Posline1=""
	Posline2=""
	Posline3=""
	for ((i=1; i<=$PosVols; i++)); do
	    Posline1="$Posline1 `echo $line1 | awk -v N=$i '{print $N}'`"
	    Posline2="$Posline2 `echo $line2 | awk -v N=$i '{print $N}'`"
	    Posline3="$Posline3 `echo $line3 | awk -v N=$i '{print $N}'`"
	done
	echo $Posline1 > ${eddydir}/Pos_rotated.bvec
	echo $Posline2 >> ${eddydir}/Pos_rotated.bvec
	echo $Posline3 >> ${eddydir}/Pos_rotated.bvec

	Negline1=""
	Negline2=""
	Negline3=""
	Nstart=$((PosVols + 1 ))
	Nend=$((PosVols + NegVols))
	for  ((i=$Nstart; i<=$Nend; i++)); do
	    Negline1="$Negline1 `echo $line1 | awk -v N=$i '{print $N}'`"
	    Negline2="$Negline2 `echo $line2 | awk -v N=$i '{print $N}'`"
	    Negline3="$Negline3 `echo $line3 | awk -v N=$i '{print $N}'`"
	done
	echo $Negline1 > ${eddydir}/Neg_rotated.bvec
	echo $Negline2 >> ${eddydir}/Neg_rotated.bvec
	echo $Negline3 >> ${eddydir}/Neg_rotated.bvec
	
	# Average Eddy-Rotated bvecs. Get for each direction the two b matrices, average those and then eigendecompose the average b-matrix to get the new bvec and bval.
	# Also outputs an index file (1-based) with the indices of the input (Pos/Neg) volumes that have been retained in the output
	${globalscriptsdir}/average_bvecs.py ${eddydir}/Pos.bval ${eddydir}/Pos_rotated.bvec ${eddydir}/Neg.bval ${eddydir}/Neg_rotated.bvec ${datadir}/avg_data ${eddydir}/Pos_SeriesVolNum.txt ${eddydir}/Neg_SeriesVolNum.txt

	mv ${datadir}/avg_data.bval ${datadir}/bvals
	mv ${datadir}/avg_data.bvec ${datadir}/bvecs
	rm -f ${datadir}/avg_data.bv??

fi


DTI_SortAndAverageB0.sh -dti ${datadir}/data.nii.gz -bval ${datadir}/bvals -bvec ${datadir}/bvecs



echo ""
echo "################################################################################################"
echo "##                                   BIAS FIELD CORRECTION "
echo "################################################################################################"
echo ""

echo ""
echo "BIAS FIELD CORRECTION"
echo ""

${FSLDIR}/bin/imcp ${datadir}/data ${datadir}/data_nobias
rm -f ${datadir}/data.nii.gz

echo "dwi2mask -fslgrad ${datadir}/bvecs ${datadir}/bvals ${datadir}/data_nobias.nii.gz ${datadir}/data_mask.nii.gz"
dwi2mask -fslgrad ${datadir}/bvecs ${datadir}/bvals ${datadir}/data_nobias.nii.gz ${datadir}/data_mask.nii.gz

echo "dwibiascorrect ${datadir}/data_nobias.nii.gz ${datadir}/data.nii.gz -fslgrad ${datadir}/bvecs ${datadir}/bvals -mask ${datadir}/data_mask.nii.gz -fsl -bias ${datadir}/biasfield.nii.gz"
dwibiascorrect ${datadir}/data_nobias.nii.gz ${datadir}/data.nii.gz -fslgrad ${datadir}/bvecs ${datadir}/bvals -mask ${datadir}/data_mask.nii.gz -fsl -bias ${datadir}/biasfield.nii.gz



echo ""
echo "################################################################################################"
echo "##                              CREATE FOLDER AND DATA FOR TRACULA "
echo "################################################################################################"
echo ""

tracdir=${outdir}/tracula/${SUBJ}
mkdir -p ${tracdir}/dlabel/"diff" ${tracdir}/dmri/xfms ${tracdir}/scripts
cp -f ${datadir}/data.nii.gz ${tracdir}/dmri/dwi.nii.gz
cp -f ${datadir}/bvals ${datadir}/bvecs ${tracdir}/dmri/
cp -f ${datadir}/nodif.nii.gz ${tracdir}/dmri/lowb.nii.gz
cp -f ${datadir}/nodif_brain.nii.gz ${tracdir}/dmri/lowb_brain.nii.gz
cp -f ${datadir}/nodif_brain_mask.nii.gz ${tracdir}/dlabel/"diff"/lowb_brain_mask.nii.gz
ln -sf ${tracdir}/dmri/dwi.nii.gz ${tracdir}/dmri/data.nii.gz


echo " "
echo "END: DTI_CorrectionForTracula.sh"
echo " END: `date`"
echo ""

