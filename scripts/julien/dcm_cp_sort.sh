#!/bin/bash

dcmdump_path="";

export LC_CTYPE=C
export LANG=C

if [ $# -lt 3 ]
then
echo "Usage:  dcm_sort.sh  -i <input folder> -o <output folder> -t <folder structure type>"
echo "  -i                         : input folder"
echo "  -o                         : output folder"
echo "  -t                         : type"
echo ""
echo "Author: Dumont Julien - CHRU Lille - Sept , 2014"
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
echo "Usage:  dcm_sort.sh  -i <input folder> -o <output folder> -t <folder structure type>"
echo "  -i                         : input folder"
echo "  -o                         : output folder"
echo "	-t                         : type"
echo ""
echo "Author: Dumont Julien - CHRU Lille - Sept , 2014"
echo ""
exit 1
;;
-i)
index=$[$index+1]
eval input=\${$index}
echo "input folder : ${input}"
;;
-o)
index=$[$index+1]
eval output=\${$index}
echo "output folder : ${output}"
;;
-t)
index=$[$index+1]
eval type=\${$index}
echo "folder type: ${type}"
;;
-*)
eval infile=\${$index}
echo "${infile} : unknown option"
echo ""
echo "Usage:  dcm_sort.sh  -i <input folder> -o <output folder> -t <folder structure type>"
echo "  -i                         : input folder"
echo "  -o                         : output folder"
echo "	-t                         : type"
echo ""
echo "Author: Dumont Julien - CHRU Lille - Sept , 2014"
echo ""
exit 1
;;
esac
index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${input} ]
then
echo "-i argument mandatory"
exit 1
fi

if [ -z ${output} ]
then
echo "-o argument mandatory"
exit 1
fi

if [ -z ${type} ]
then
echo "-t argument mandatory"
exit 1
fi

# Le nom patient et le nom d'examen se test sur le premier fichier dicom
# pour ne pas relire l'info sur chaque fichier
# pas de source d'erreur ETIAM a déjà classé par examen/patient
# on sélectionne les extension .dcm, on ne fera pas de test de validité du dicom
#test_dicom=$(dcmdump -M ${dcm} | sed -n '/# Dicom-File-Format/p')


cd ${input}







# Pour chaque dicom
for dcm in $(find -name "*")
do


test_dicom=$(dcmdump -M ${dcm} | sed -n '/# Dicom-File-Format/p')

if [ "${test_dicom}" == "# Dicom-File-Format" ]
then

if [ "${dcm}" != "." ]
then

StudyDate=$(${dcmdump_path}dcmdump -M +P "0008,0020" ${dcm} | sed -e 's/.*\[\(.*\)\].*/\1/'| sed 's/ /_/g')
PatientsName=$(${dcmdump_path}dcmdump -M +P "0010,0010" ${dcm} | sed -e 's/.*\[\(.*\)\].*/\1/')
current_patient_name=$(echo ${PatientsName}| sed 's/ /_/g' | sed 's#/#_#g')
StudyDescription=$(${dcmdump_path}dcmdump -M +P "0008,1030" ${dcm} | sed -e 's/.*\[\(.*\)\].*/\1/' | sed 's#/#_#g')
current_study=$(echo ${StudyDescription} | sed 's/ /_/g' | sed 's/\./_/g')

current_serie_description=$(${dcmdump_path}dcmdump -M +P "0008,103e" ${dcm} | sed -e 's/.*\[\(.*\)\].*/\1/' | sed 's/*/ETOILE/g' | sed 's/ /_/g' | sed 's#/#_#g')
#StudyTime=$(${dcmdump_path}dcmdump -M +P "0008,0030" ${dcm} | sed -e 's/.*\[\(.*\)\].*/\1/')
#PatientID=$(${dcmdump_path}dcmdump -M +P "0010,0020" ${dcm} | sed -e 's/.*\[\(.*\)\].*/\1/')
#AccessessionNumber=$(${dcmdump_path}dcmdump -M +P "0008,0050" ${dcm} | sed -e 's/.*\[\(.*\)\].*/\1/')
#PatientsBirthDate=$(${dcmdump_path}dcmdump -M +P "0010,0030" ${dcm} | sed -e 's/.*\[\(.*\)\].*/\1/')
#PatientsSex=$(${dcmdump_path}dcmdump -M +P "0010,0040" ${dcm} | sed -e 's/.*\[\(.*\)\].*/\1/')
current_serie_number=$(${dcmdump_path}dcmdump -M +P "0020,0011" ${dcm} | sed -e 's/.*\[\(.*\)\].*/\1/'| sed 's/ /_/g')
current_slice_number=$(${dcmdump_path}dcmdump -M +P "0020,0013" ${dcm} | sed -n '2p' | sed -e 's/.*\[\(.*\)\].*/\1/'| sed 's/ /_/g')
modality=$(${dcmdump_path}dcmdump -M +P "0008,0060" ${dcm} | sed -e 's/.*\[\(.*\)\].*/\1/'| sed 's/ /_/g')

if [ "${StudyDate}" == "" ]
then

	StudyDate="no_date" 

fi

if [ "${PatientsName}" == "" ]
then

	current_patient_name=$(${dcmdump_path}dcmdump -M +P "0020,0010" ${dcm} | sed -e 's/.*\[\(.*\)\].*/\1/')

fi

if [ "${current_study}" == "" ]
then

	current_study=$(${dcmdump_path}dcmdump -M +P "0020,000d" ${dcm} | sed -e 's/.*\[\(.*\)\].*/\1/')

fi

if [ "${current_serie_description}" == "" ]
then

	current_serie_description=$(${dcmdump_path}dcmdump -M +P "0020,000e" ${dcm} | sed -e 's/.*\[\(.*\)\].*/\1/')

fi


echo "Analyse ${dcm} : ${current_patient_name} (${PatientsBirthDate}) - ${StudyDescription} @ ${StudyDate} / ${StudyTime} 
S ${current_serie_number} / I ${current_slice_number}
"


mkdir -p ${output}${current_patient_name}/${StudyDate}/${modality}/${current_study}/${current_serie_number}_${current_serie_description}/
cp ${dcm} ${output}${current_patient_name}/${StudyDate}/${modality}/${current_study}/${current_serie_number}_${current_serie_description}/

if [ ! -e  ${output}${current_patient_name}/${StudyDate}/${modality}/${current_study}/${current_serie_number}_${current_serie_description}.log ]
then

dcm="${dcm//\"/\\\"}"

 touch ${output}${current_patient_name}/${StudyDate}/${modality}/${current_study}/${current_serie_number}_${current_serie_description}.log 
	echo "${dcm}" >> ${output}${current_patient_name}/${StudyDate}/${modality}/${current_study}/${current_serie_number}_${current_serie_description}.log 
fi


fi
fi
done

