#!/bin/bash

input=/home/fatmike/renaud/2012_SEM_14

# Convert DICOMDIR to txt file
if [ ! -f ${input}/temp.txt ]
then
      echo "dcmdump ${input}/DICOMDIR > ${input}/temp.txt"
      dcmdump ${input}/DICOMDIR > ${input}/temp.txt
else
      echo "Conversion DICOMDIR to txt file: already done"
fi

# Patient list
if [ -f ${input}/PatientList.txt ]
then
      echo "Patient list : already done"
else
      echo "Patient list ..."
      grep -i -n "(0010,0010)" ${input}/temp.txt >> ${input}/PatientList.txt
fi

old_IFS=$IFS
IFS=$'\n'
lines=($(cat ${input}/PatientList.txt))
IFS=$old_IFS

# Find dicom images of each patient
rm -f ${input}/patient*
rm -f ${input}/pat*

for idx in $(seq 0 $((${#lines[@]} - 2))); do

      curline="${lines[$idx]}" 
      indcurline=$(echo $curline | cut -d':' -f1)
      echo ${indcurline}

      nextline="${lines[$idx+1]}"
      indnextline=$(echo $nextline | cut -d':' -f1)
      indnextline=$(($indnextline-1))
      echo ${indnextline}

      sed -n ${indcurline},${indnextline}p ${input}/temp.txt >> ${input}/patient${idx}.txt

      grep -i "(0004,1500)" ${input}/patient${idx}.txt >> ${input}/pat${idx}.txt      
      sed 's/.*\[\(.*\)\].*/\1/g' < ${input}/pat${idx}.txt >> ${input}/patt${idx}.txt
      rm -f ${input}/pat${idx}.txt
      sed 's/\\/\//g' < ${input}/patt${idx}.txt >> ${input}/pat${idx}.txt
      rm -f ${input}/patt${idx}.txt
      

      #tmp=$(echo ${curline##*[})
      #name=$(echo $tmp | cut -d']' -f1)
      name=$(echo ${curline} | sed 's/.*\[\(.*\)\].*/\1/g' | tr -d ' ')
      echo $name

      if [ -d ${input}/${name} ]
      then
	    rm -rf ${input}/${name}
      fi
      mkdir ${input}/${name}

      old_IFS=$IFS
      IFS=$'\n'
      imalines=($(cat ${input}/pat${idx}.txt))
      IFS=$old_IFS
      for k in $(seq 0 $((${#imalines[@]} - 1))); do
	  ima="${imalines[$k]}"
	  imapath=$(dirname ${ima})
	  if [ ! -d ${input}/${name}/${imapath} ]
	  then
		mkdir -p ${input}/${name}/${imapath}
	  fi
	  echo "cp ${input}/${ima} ${input}/${name}/${imapath}/"
	  cp ${input}/${ima} ${input}/${name}/${imapath}/
      done

done
 
# Last subject
echo "Last subject ..."

fin=$(sed -n -e '$=' ${input}/temp.txt)
subj=$((${#lines[@]} - 1))
curline="${lines[$subj]}" 
indcurline=$(echo $curline | cut -d':' -f1)
echo ${indcurline}
sed -n ${indcurline},${fin}p ${input}/temp.txt >> ${input}/patient${subj}.txt

grep -i "(0004,1500)" ${input}/patient${subj}.txt >> ${input}/pat${subj}.txt
sed 's/.*\[\(.*\)\].*/\1/g' < ${input}/pat${subj}.txt >> ${input}/patt${subj}.txt
rm -f ${input}/pat${subj}.txt
sed 's/\\/\//g' < ${input}/patt${subj}.txt >> ${input}/pat${subj}.txt
rm -f ${input}/patt${subj}.txt

name=$(echo ${curline} | sed 's/.*\[\(.*\)\].*/\1/g' | tr -d ' ')
echo $name

if [ -d ${input}/${name} ]
then
      rm -rf ${input}/${name}
fi
mkdir ${input}/${name}

old_IFS=$IFS
IFS=$'\n'
imalines=($(cat ${input}/pat${subj}.txt))
IFS=$old_IFS
for k in $(seq 0 $((${#imalines[@]} - 1))); do
    tmpima="${imalines[$k]}"
    ima=$(echo ${tmpima} | sed 's/.*\[\(.*\)\].*/\1/g')
    imapath=$(dirname ${ima})
    if [ ! -d ${input}/${name}/${imapath} ]
    then
	mkdir -p ${input}/${name}/${imapath}
    fi
    echo "cp -f ${input}/${ima} ${input}/${name}/${imapath}/"
    cp -f ${input}/${ima} ${input}/${name}/${imapath}/
done


# Convert DICOM to NIFTI
echo "Convert DICOM to NIFTI"
for idx in $(seq 0 $((${#lines[@]} - 1))); do 
      curline="${lines[$idx]}" 
      name=$(echo ${curline} | sed 's/.*\[\(.*\)\].*/\1/g' | tr -d ' ')
      echo "Patient : ${name}" 
      mcverter -o ${input}/${name}/ -f fsl -n -x -m DTI ${input}/${name}/DICOM/
      mcverter -o ${input}/${name}/ -f nifti -d -n ${input}/${name}/DICOM/
done