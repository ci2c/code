#!/bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: BackUpDicom.sh -i <datapath> -f <folder> -o <output> "
	echo ""
	echo "  -i            : data folder "
	echo "  -f            : dicom folder (DICOMDIR inside this folder) "
	echo "  -o            : output folder "
	echo ""
	echo "Usage: BackUpDicom.sh -i <datapath> -f <folder> -o <output> "
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
		echo "Usage: BackUpDicom.sh -i <datapath> -f <folder> -o <output> "
		echo ""
		echo "  -i            : data folder (DICOMDIR inside this folder)"
		echo "  -f            : dicom folder (DICOMDIR inside this folder) "
		echo "  -o            : output folder "
		echo ""
		echo "Usage: BackUpDicom.sh -i <datapath> -f <folder> -o <output> "
		echo ""
		exit 1
		;;
	-i)
		index=$[$index+1]
		eval input=\${$index}
		echo "data folder : ${input}"
		;;
	-f)
		index=$[$index+1]
		eval dcmdir=\${$index}
		echo "dicom folder : ${dcmdir}"
		;;
	-o)
		index=$[$index+1]
		eval output=\${$index}
		echo "output folder : ${output}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: BackUpDicom.sh -i <datapath> -f <folder> -o <output>"
		echo ""
		echo "  -i            : data folder "
		echo "  -f            : dicom folder (DICOMDIR inside this folder) "
		echo "  -o            : output folder "
		echo ""
		echo "Usage: BackUpDicom.sh -i <datapath> -f <folder> -o <output>"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Creates out dir
if [ ! -d ${output}/${dcmdir} ]
then
	mkdir -p ${output}/${dcmdir}
fi

#=================================================================================
# Convert DICOMDIR to txt file
if [ ! -f ${output}/${dcmdir}/temp.txt ]
then
      echo "dcmdump ${input}/${dcmdir}/DICOMDIR > ${output}/${dcmdir}/temp.txt"
      dcmdump ${input}/${dcmdir}/DICOMDIR > ${output}/${dcmdir}/temp.txt
else
      echo "Conversion DICOMDIR to txt file: already done"
fi

#=================================================================================
# Patient list
if [ -f ${output}/${dcmdir}/PatientList.txt ]
then
      echo "Patient list : already done"
else
      echo "Patient list ..."
      grep -i -n "(0010,0010)" ${output}/${dcmdir}/temp.txt >> ${output}/${dcmdir}/PatientList.txt
      grep -i -n "(0008,0020)" ${output}/${dcmdir}/temp.txt >> ${output}/${dcmdir}/StudyDate.txt
fi

old_IFS=$IFS
IFS=$'\n'
lines=($(cat ${output}/${dcmdir}/PatientList.txt))
IFS=$old_IFS

old_IFS=$IFS
IFS=$'\n'
linessd=($(cat ${output}/${dcmdir}/StudyDate.txt))
IFS=$old_IFS

#=================================================================================
# Find dicom images of each patient
rm -f ${output}/${dcmdir}/patient*
rm -f ${output}/${dcmdir}/pat*

for idx in $(seq 0 $((${#lines[@]} - 2))); do

      curline="${lines[$idx]}" 
      curlinesd="${linessd[$idx]}"
      indcurline=$(echo $curline | cut -d':' -f1)
      #echo ${indcurline}

      nextline="${lines[$idx+1]}"
      indnextline=$(echo $nextline | cut -d':' -f1)
      indnextline=$(($indnextline-1))
      #echo ${indnextline}

      sed -n ${indcurline},${indnextline}p ${output}/${dcmdir}/temp.txt >> ${output}/${dcmdir}/patient${idx}.txt

      grep -i "(0004,1500)" ${output}/${dcmdir}/patient${idx}.txt >> ${output}/${dcmdir}/pat${idx}.txt      
      sed 's/.*\[\(.*\)\].*/\1/g' < ${output}/${dcmdir}/pat${idx}.txt >> ${output}/${dcmdir}/patt${idx}.txt
      rm -f ${output}/${dcmdir}/pat${idx}.txt
      sed 's/\\/\//g' < ${output}/${dcmdir}/patt${idx}.txt >> ${output}/${dcmdir}/pat${idx}.txt
      rm -f ${output}/${dcmdir}/patt${idx}.txt
      
      name=$(echo ${curline} | sed 's/.*\[\(.*\)\].*/\1/g' | tr -d ' ')
      stdate=$(echo ${curlinesd} | sed 's/.*\[\(.*\)\].*/\1/g' | tr -d ' ')
      echo "Patient : ${name}_${stdate}"

      if [ ! -d ${output}/${dcmdir}/${name}_${stdate} ]; then
	  mkdir ${output}/${dcmdir}/${name}_${stdate}
      fi

      old_IFS=$IFS
      IFS=$'\n'
      imalines=($(cat ${output}/${dcmdir}/pat${idx}.txt))
      IFS=$old_IFS
      for k in $(seq 0 $((${#imalines[@]} - 1))); do
	  ima="${imalines[$k]}"
	  imapath=$(dirname ${ima})
	  if [ ! -d ${output}/${dcmdir}/${name}_${stdate}/${imapath} ]
	  then
		mkdir -p ${output}/${dcmdir}/${name}_${stdate}/${imapath}
	  fi
	  echo "cp ${input}/${dcmdir}/${ima} ${output}/${dcmdir}/${name}_${stdate}/${imapath}/"
	  cp ${input}/${dcmdir}/${ima} ${output}/${dcmdir}/${name}_${stdate}/${imapath}/
      done

done
 
# Last subject
echo "Last subject ..."

fin=$(sed -n -e '$=' ${output}/${dcmdir}/temp.txt)
subj=$((${#lines[@]} - 1))
curline="${lines[$subj]}" 
curlinesd="${linessd[$subj]}"
indcurline=$(echo $curline | cut -d':' -f1)
sed -n ${indcurline},${fin}p ${output}/${dcmdir}/temp.txt >> ${output}/${dcmdir}/patient${subj}.txt

grep -i "(0004,1500)" ${output}/${dcmdir}/patient${subj}.txt >> ${output}/${dcmdir}/pat${subj}.txt
sed 's/.*\[\(.*\)\].*/\1/g' < ${output}/${dcmdir}/pat${subj}.txt >> ${output}/${dcmdir}/patt${subj}.txt
rm -f ${output}/${dcmdir}/pat${subj}.txt
sed 's/\\/\//g' < ${output}/${dcmdir}/patt${subj}.txt >> ${output}/${dcmdir}/pat${subj}.txt
rm -f ${output}/${dcmdir}/patt${subj}.txt

name=$(echo ${curline} | sed 's/.*\[\(.*\)\].*/\1/g' | tr -d ' ')
stdate=$(echo ${curlinesd} | sed 's/.*\[\(.*\)\].*/\1/g' | tr -d ' ')
echo "Patient : ${name}_${stdate}"

if [ ! -d ${output}/${dcmdir}/${name}_${stdate} ]; then
    mkdir ${output}/${dcmdir}/${name}_${stdate}
fi

old_IFS=$IFS
IFS=$'\n'
imalines=($(cat ${output}/${dcmdir}/pat${subj}.txt))
IFS=$old_IFS
for k in $(seq 0 $((${#imalines[@]} - 1))); do
    tmpima="${imalines[$k]}"
    ima=$(echo ${tmpima} | sed 's/.*\[\(.*\)\].*/\1/g')
    imapath=$(dirname ${ima})
    if [ ! -d ${output}/${dcmdir}/${name}_${stdate}/${imapath} ]
    then
	mkdir -p ${output}/${dcmdir}/${name}_${stdate}/${imapath}
    fi
    #echo "cp -f ${input}/${dcmdir}/${ima} ${input}/${dcmdir}/${name}/${imapath}/"
    cp -f ${input}/${dcmdir}/${ima} ${output}/${dcmdir}/${name}_${stdate}/${imapath}/
done


#==================================================================================
# Copy data into Protocol directory

echo "Copy data into Protocol directory"

curpath=$(pwd)
basepath=/home/notorious/Protocols_3T

echo "Create DICOMDIR for each patient"
for idx in $(seq 0 $((${#lines[@]} - 1))); do

      curline="${lines[$idx]}"
      curlinesd="${linessd[$idx]}"
      name=$(echo ${curline} | sed 's/.*\[\(.*\)\].*/\1/g' | tr -d ' ')
      stdate=$(echo ${curlinesd} | sed 's/.*\[\(.*\)\].*/\1/g' | tr -d ' ')
      echo "Patient : ${name}_${stdate}"
      cd ${output}/${dcmdir}/${name}_${stdate}
      dcmmkdir +r DICOM/*
      dcmdump ${output}/${dcmdir}/${name}_${stdate}/DICOMDIR > ${output}/${dcmdir}/${name}_${stdate}/temp.txt
      linetmp=$(grep -i "(0008,1030)" ${output}/${dcmdir}/${name}_${stdate}/temp.txt)
      proname=$(echo ${linetmp} | sed 's/.*\[\(.*\)\].*/\1/g' | tr -d ' ')
      # free
      sudo rm -f ${output}/${dcmdir}/${name}_${stdate}/temp.txt
      # copy
      if [ ! -d ${basepath}/${proname} ]; then
	    #mkdir -m 775 ${basepath}/${proname}
	    mkdir ${basepath}/${proname}
      fi
      if [ ! -d ${basepath}/${proname}/${name}_${stdate} ]; then
	    #mkdir -m 775 ${basepath}/${proname}/${name}_${stdate}
	    mkdir -m 775 ${basepath}/${proname}/${name}_${stdate}
      fi
      echo "cp -r ${output}/${dcmdir}/${name}_${stdate}/* ${basepath}/${proname}/${name}_${stdate}/"
      cp -r ${output}/${dcmdir}/${name}_${stdate}/* ${basepath}/${proname}/${name}_${stdate}/
      #chmod 775 ${basepath}/${proname}/${name}_${stdate}/*

      # convert DICOM to nifti
      echo "convert DICOM to NIFTI"
      mcverter -o ${basepath}/${proname}/${name}_${stdate}/ -f fsl -n -x -m DTI ${basepath}/${proname}/${name}_${stdate}/DICOM/
      #mcverter -o ${basepath}/${proname}/${name}_${stdate}/ -f nifti -d -n ${output}/${name}_${stdate}/DICOM/
      dcm2nii -o ${basepath}/${proname}/${name}_${stdate}/ ${basepath}/${proname}/${name}_${stdate}/DICOM/*

done

cd ${curpath}

# free
rm -f ${output}/${dcmdir}/patient*
rm -f ${output}/${dcmdir}/pat*

