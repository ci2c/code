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










# Pour chaque dicom
for dcm in $(find ${input} -iname "*")
do


test_dicom=$(dcmftest ${dcm} | cut -c1)
#$(dcmdump -M ${dcm} | sed -n '/# Dicom-File-Format/p')

if [ "${test_dicom}" == "y" ]
#if [ "${test_dicom}" == "# Dicom-File-Format" ]
then

if [ "${dcm}" != "./" ]
then


current_serie_number=$(${dcmdump_path}dcmdump -M +P "0020,0011" ${dcm} | sed -e 's/.*\[\(.*\)\].*/\1/'| sed 's/ /_/g')
if [  "${current_serie_number}" != "0" ]
then

StudyDate=$(${dcmdump_path}dcmdump -M +P "0008,0020" ${dcm} | sed -e 's/.*\[\(.*\)\].*/\1/'| sed 's/ /_/g')
PatientsName=$(${dcmdump_path}dcmdump -M +P "0010,0010" ${dcm} | sed -e 's/.*\[\(.*\)\].*/\1/')
current_patient_name=$(echo ${PatientsName}| sed 's/ /_/g'  | sed 's#/#_#g')
StudyDescription=$(${dcmdump_path}dcmdump -M +P "0008,1030" ${dcm} | sed -e 's/.*\[\(.*\)\].*/\1/' | sed 's#/#_#g')
current_study=$(echo ${StudyDescription} | sed 's/ /_/g' | sed 's/\./_/g')



current_serie_description=$(${dcmdump_path}dcmdump -M +P "0008,103e" ${dcm} | sed -e 's/.*\[\(.*\)\].*/\1/' | sed 's/*/ETOILE/g' | sed 's/ /_/g' | sed 's#/#_#g')

StudyTime=$(${dcmdump_path}dcmdump -M +P "0008,0030" ${dcm} | sed -e 's/.*\[\(.*\)\].*/\1/')
PatientID=$(${dcmdump_path}dcmdump -M +P "0010,0020" ${dcm} | sed -e 's/.*\[\(.*\)\].*/\1/')
AccessessionNumber=$(${dcmdump_path}dcmdump -M +P "0008,0050" ${dcm} | sed -e 's/.*\[\(.*\)\].*/\1/')
PatientsBirthDate=$(${dcmdump_path}dcmdump -M +P "0010,0030" ${dcm} | sed -e 's/.*\[\(.*\)\].*/\1/')
PatientsSex=$(${dcmdump_path}dcmdump -M +P "0010,0040" ${dcm} | sed -e 's/.*\[\(.*\)\].*/\1/')

current_slice_number=$(${dcmdump_path}dcmdump -M +P "0020,0013" ${dcm} | sed -n '2p' | sed -e 's/.*\[\(.*\)\].*/\1/'| sed 's/ /_/g')


echo "Analyse ${dcm} : ${current_patient_name} (${PatientsBirthDate}) - ${StudyDescription} @ ${StudyDate} / ${StudyTime}
S ${current_serie_number} / I ${current_slice_number}
"
mkdir -p ${output}${StudyDate}/${current_patient_name}/${current_study}/${current_serie_number}_${current_serie_description}
cp ${dcm} ${output}${StudyDate}/${current_patient_name}/${current_study}/${current_serie_number}_${current_serie_description}

if [ ! -e  ${output}${StudyDate}/${current_patient_name}/${current_study}/patient.log ]
then
touch ${output}${StudyDate}/${current_patient_name}/${current_study}/patient.log
echo "${PatientsName}" >> ${output}${StudyDate}/${current_patient_name}/${current_study}/patient.log
echo "${PatientID}" >> ${output}${StudyDate}/${current_patient_name}/${current_study}/patient.log
echo "${PatientsBirthDate}" >> ${output}${StudyDate}/${current_patient_name}/${current_study}/patient.log
echo "${PatientsSex}" >> ${output}${StudyDate}/${current_patient_name}/${current_study}/patient.log
fi


if [ ! -e  ${output}${StudyDate}/${current_patient_name}/${current_study}/${current_serie_number}_${current_serie_description}.log ]
then
SeriesDescription=$(${dcmdump_path}dcmdump -M +P "0008,103e" ${dcm} | sed -e 's/.*\[\(.*\)\].*/\1/')
SeriesTime=$(${dcmdump_path}dcmdump -M +P "0008,0031" ${dcm} | sed -e 's/.*\[\(.*\)\].*/\1/')
touch ${output}${StudyDate}/${current_patient_name}/${current_study}/${current_serie_number}_${current_serie_description}.log
echo "${SeriesDescription}" >> ${output}${StudyDate}/${current_patient_name}/${current_study}/${current_serie_number}_${current_serie_description}.log
echo "${SeriesTime}" >> ${output}${StudyDate}/${current_patient_name}/${current_study}/${current_serie_number}_${current_serie_description}.log
echo "${current_serie_number}" >> ${output}${StudyDate}/${current_patient_name}/${current_study}/${current_serie_number}_${current_serie_description}.log
fi #test fichier


if [ ! -e  ${output}${StudyDate}/${current_patient_name}/${current_study}/study.log ]
then
touch ${output}${StudyDate}/${current_patient_name}/${current_study}/study.log
echo "${StudyDescription}" >> ${output}${StudyDate}/${current_patient_name}/${current_study}/study.log
echo "${StudyDate}" >> ${output}${StudyDate}/${current_patient_name}/${current_study}/study.log
echo "${StudyTime}" >> ${output}${StudyDate}/${current_patient_name}/${current_study}/study.log
echo "${AccessessionNumber}" >> ${output}${StudyDate}/${current_patient_name}/${current_study}/study.log
fi


fi

fi
fi
done









