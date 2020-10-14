#!/bin/bash

### Require
#
# DCMTK storescp
# DCMTK movscu
# DCMTK findscu
# DCMTK dcmdump
# dcm_chrulQRP_func
#
#######################################
dcmtk_path="";
timestamp=$(date +%s)
temp_folder=/tmp/pacs_query_${timestamp}/
scripts_folder=~/SVN/scripts/julien/
my_tty="/dev/$(ps ax | grep $$ | awk '{ print $2 }' | sed -n 1p)"
#######################################
export LC_CTYPE=C
export LANG=C
#######################################
####### Conf ##########################

# define slot aet : 4 slots : each slot must be define into Philips PACS with an IP
# that's why only gaia IP was define
#aet_slot1="IMV3tdb2"
slot_basename="IMV3T_s"
port_base="301"  # so 3011 for slot 1, 3012 for slot 2 etc.
max_slot=4
# define PACS cfg
pacs_IP="10.49.24.204"
#10.49.15.51"
pacs_port=107
# define table format
format="| %-30s | %8s | %-20s | %9s | \n"
format_l2="|\e[100m %-30s | %8s | %-20s | %9s \e[0m| \n"
format2="| %-42s | %6s | %9s | %10s | \n"
format2_l2="|\e[100m %-42s | %6s | %9s | %10s \e[0m| \n"
#######################################


if [ $# -lt 1 ]
then
echo "Usage:  dcm_CHRULQRP.sh -p <patientname> -d <date>"
echo "                        -modality <modolity> default MR"
echo "                        -rslot <int> number of simultaneous reciever nodes (default 1)"	
echo "                        -o <path> output path, default /home/RECPAR"
echo "Author: Dumont Julien"
echo ""
exit 1
fi



index=1

while [ $index -le $# ]
do
eval arg=\${$index}
case "$arg" in
-h|-help)
echo "Usage:  dcm_CHRULQRP.sh -p <patientname> -d <date>"
echo "                        -modality <modolity> default MR"
echo "                        -rslot <int> number of simultaneous reciever nodes (default 1)"	
echo "                        -o <path> output path, default /home/RECPAR"
echo "Author: Dumont Julien"
echo ""
echo ""
exit 1
;;
-rslot)
index=$[$index+1]
eval rslot=\${$index}
;;
-p)
index=$[$index+1]
eval patient_q=\${$index}
;;
-d)
index=$[$index+1]
eval date_q=\${$index}
;;
-modality)
index=$[$index+1]
eval modality_q=\${$index}
;;
-o)
index=$[$index+1]
eval output=\${$index}
;;
-*)
eval infile=\${$index}
echo "
${infile} : unknown option
"
echo "Usage:  dcm_CHRULQRP.sh -p <patientname> -d <date>"
echo "                        -modality <modolity> default MR"
echo "                        -rslot <int> number of simultaneous reciever nodes (default 1)"	
echo "                        -o <path> output path, default /home/RECPAR"
echo "Author: Dumont Julien"
exit 1
;;
esac
index=$[$index+1]
done

if [ -z ${output} ]
then
	output="/home/RECPAR/"
fi
if [ -z ${modality_q} ]
then
	modality_q="MR"
fi
if [ -z ${rslot} ]
then
	rslot=1
fi
if [ "${rslot}" -gt "${max_slot}" ]
then
	rslot=4
fi

if [ -z ${patient_q} ]
then
	patient_q="*"
fi

function build_serie_list(){
serie_to_do=$1
max_serie_number=$2



for job in $(echo ${serie_to_do} | tr "," " ");do
	# determine if it is a range of series
		is_a_range=$(echo "${job}" | grep "-" | wc -l)
		if [ ${is_a_range} -eq 1 ];then
			the_range=$(echo ${job} | sed 's#-# #g')
			if  [[ "$(echo ${the_range} | grep "^[ [:digit:] ]*$")" ]];then 
			for i in $(seq ${the_range});do
				if [[ ( "$(echo ${i} | grep "^[ [:digit:] ]*$")" && "${i}" -le "${max_serie_number}" ) ]];then 			
					echo ${i}
				else
					>&2 echo "Bad selection :  ${i}"
				fi
			done
			else
				>&2 echo "Bad selection ${job}"			
			fi
		else
			if [[ ( "$(echo ${job} | grep "^[ [:digit:] ]*$")" && "${job}" -le "${max_serie_number}" ) ]];then 			
				echo ${job}
			else
				>&2 echo "Bad selection :  ${job}"
			fi	
		fi

done


}




echo -e "\e[31m

=================== DCM CHRUL QRP =====================\e[0m"
echo -e "\e[32m patient name  : \e[0m${patient_q}"
echo -e "\e[32m study date    : \e[0m${date_q}"
echo -e "\e[32m modality      : \e[0m${modality_q}"
echo -e "\e[32m recieve slot  : \e[0m${rslot}"
echo -e "\e[32m temp folder   : \e[0m${temp_folder}"
echo -e "\e[32m dicom output  : \e[0m${output}"
echo -e "\e[31m======================================================\e[0m"

mkdir -p ${temp_folder}
touch ${temp_folder}StudyRetrieveLevel.log
# Simple hack to list an entire date (CHRUL_QRP stop at 120 results/query) 
if [ "${patient_q}" == "*" ];then
	printf "No patient name ... starting multi-query ..."
	
	for i in {A..Z}
	do
		printf ${i}
		findscu -S -k 0008,0052=STUDY -k "(0010,0010)=${i}*" -k 0010,0020 -k 0010,0030 -k 0008,1030 -k 0020,000d -k 0008,0060=${modality_q} -k 0008,0061=${modality_q} -k 0008,0020=${date_q} ${pacs_IP} ${pacs_port} 2>&1 | egrep "(0010,0010|0010,0030|0008,1030|0008,0020|0020,000d|0010,0020)" | sed -e 's/.*\[\(.*\)\].*/\1/' | pr -s';' -aT --columns 6 | sort -t';' -k3 >> ${temp_folder}StudyRetrieveLevel.log

	done
	for i in $(seq 0 9)
	do
		printf ${i}
		findscu -S -k 0008,0052=STUDY -k "(0010,0010)=${i}*" -k 0010,0020 -k 0010,0030 -k 0008,1030 -k 0020,000d -k 0008,0060=${modality_q} -k 0008,0061=${modality_q} -k 0008,0020=${date_q} ${pacs_IP} ${pacs_port} 2>&1 | egrep "(0010,0010|0010,0030|0008,1030|0008,0020|0020,000d|0010,0020)" | sed -e 's/.*\[\(.*\)\].*/\1/' | pr -s';' -aT --columns 6 | sort -t';' -k3 >> ${temp_folder}StudyRetrieveLevel.log

	done
	printf "\n"

else
findscu -S -k 0008,0052=STUDY -k "(0010,0010)=${patient_q}" -k 0010,0020 -k 0010,0030 -k 0008,1030 -k 0020,000d -k 0008,0060=${modality_q} -k 0008,0061=${modality_q} -k 0008,0020=${date_q} ${pacs_IP} ${pacs_port} 2>&1 | egrep "(0010,0010|0010,0030|0008,1030|0008,0020|0020,000d|0010,0020)" | sed -e 's/.*\[\(.*\)\].*/\1/' | pr -s';' -aT --columns 6 | sort -t';' -k3 > ${temp_folder}StudyRetrieveLevel.log
fi
echo "+--------------------------------+----------+----------------------+-----------+"
printf "${format}" "Patient" "ddn" "StudyName  " "StudyDate"
echo "+--------------------------------+----------+----------------------+-----------+"


i=0
l=1
while read patient_list
do
let i++

tab_patient[${i}]=$(echo ${patient_list} | awk -F';' '{print $3}')
tab_ddn[${i}]=$(echo ${patient_list} | awk -F';' '{print $5}')
tab_studyname[${i}]=$(echo ${patient_list} | awk -F';' '{print $2}')
tab_studydate[${i}]=$(echo ${patient_list} | awk -F';' '{print $1}')
tab_studyUID[${i}]=$(echo ${patient_list} | awk -F';' '{print $6}')
tab_patientID[${i}]=$(echo ${patient_list} | awk -F';' '{print $4}')

if [ ${l} -eq 1 ];then
	printf "${format_l2}" "$i. ${tab_patient[${i}]:0:25}" "${tab_ddn[${i}]:0:8}" "${tab_studyname[${i}]:0:20}"  "${tab_studydate[${i}]:0:8}"
	l=2
else
	printf "${format}" "$i. ${tab_patient[${i}]:0:25}" "${tab_ddn[${i}]:0:8}" "${tab_studyname[${i}]:0:20}"  "${tab_studydate[${i}]:0:8}"
	l=1
fi

done < ${temp_folder}StudyRetrieveLevel.log

echo "+--------------------------------+----------+----------------------+-----------+"

##########################################################################################
################# SERIES PART ############################################################
##########################################################################################

echo "R<patient number> to retrieve or S<patient number> to show study series"
read cmd_to_do
# extract patient_number
if [ $(echo ${cmd_to_do} | grep "S" | wc -l ) -eq 1 ];then
	select_patient_number=$(echo ${cmd_to_do} | sed -e 's/S\([0-9]*\)/\1/')
	mode="select_series"
elif [ $(echo ${cmd_to_do} | grep "R" | wc -l ) -eq 1 ];then
	select_patient_number=$(echo ${cmd_to_do} | sed -e 's/R\([0-9]*\)/\1/')
	mode="all_series"
else
	echo "Bad choice ..."
	exit 1
fi


	echo "show series from ... ${tab_patient[${select_patient_number}]} (${tab_patientID[${select_patient_number}]} - ${tab_studyUID[${select_patient_number}]})"

findscu -S -k "(0010,0010)=${tab_patient[${select_patient_number}]}" -k 0010,0030 -k 0008,1030 -k 0020,000e -k 0008,103e -k 0020,0011 -k 0008,0031 -k 0020,1209 -k 0010,0020=${tab_patientID[${select_patient_number}]}  -k 0008,0060=${modality_q} -k 0008,0020=${date_q} -k 0008,0052=SERIES -k 0020,000d=${tab_studyUID[${select_patient_number}]}  ${pacs_IP} ${pacs_port}  2>&1 | egrep "(0008,103e|0020,000e|0020,0011|0008,0031|0020,1209)" | sed -e 's/.*\[\(.*\)\].*/\1/' | pr -s';' -aT --columns 5 | sort -t';' -k1 > ${temp_folder}SeriesRetrieveLevel_${tab_studyUID[${select_patient_number}]}.log




echo "+--------------------------------------------+--------+-----------+------------+"
printf "${format2}" "Serie" "Slices" "Time" "Snumber"
echo "+--------------------------------------------+--------+-----------+------------+"

i=0
l=1
while read serie_list
do
let i++

tab_seriename[${i}]=$(echo ${serie_list} | awk -F';' '{print $2}')
tab_serietime[${i}]=$(echo ${serie_list} | awk -F';' '{print $1}')
tab_serieUID[${i}]=$(echo ${serie_list} | awk -F';' '{print $3}')
tab_serienumber[${i}]=$(echo ${serie_list} | awk -F';' '{print $4}')
tab_serieslice[${i}]=$(echo ${serie_list} | awk -F';' '{print $5}')

if [ ${l} -eq 1 ];then
	printf "${format2_l2}" "$i. ${tab_seriename[${i}]:0:37}" "${tab_serieslice[${i}]:0:6}" "${tab_serietime[${i}]:0:6}" "${tab_serienumber[${i}]}"
	l=2
else
	printf "${format2}" "$i. ${tab_seriename[${i}]:0:37}" "${tab_serieslice[${i}]:0:6}" "${tab_serietime[${i}]:0:6}" "${tab_serienumber[${i}]}"
	l=1
fi


done < ${temp_folder}SeriesRetrieveLevel_${tab_studyUID[${select_patient_number}]}.log

echo "+--------------------------------------------+--------+-----------+------------+"

if [ "${mode}" == "select_series" ];then
	echo "Selsect serie(s) to  export ? (ex: 1-4,8,12)"
	read serie_to_do
else
	serie_to_do="1-${i}"
fi


serie_list=$(build_serie_list ${serie_to_do} $i)


for zslot in $(seq 1 ${rslot});do
	sudo xterm -T "Slot ${zslot} : ${slot_basename}${zslot} @ ${port_base}${zslot}" -e storescp +xa  --aetitle ${slot_basename}${zslot} -od /mnt/homes_hdd/CHRULQR_node/slot${zslot} -uf ${port_base}${zslot} -v -su St --fork -xcr "${scripts_folder}dcm_CHRULQRP_func.sh ${output} #p/#f ${temp_folder}/avancement.log ${my_tty}" &
	aet_thread_slot[${zslot}]=$!

done





declare -a slot_slices_q=( $(for i in $(seq 1 ${rslot}); do echo 0; done) )

for job in $(echo ${serie_list});do

	# choose a slot to recieve dicom
	smaller_slot_q=$(echo "${slot_slices_q[@]}" | tr -s ' ' '\n' | awk '{print($0" "NR)}' | sort -g -k1,1 | head -1 | cut -f2 -d' ')	
	smaller_slot_q2=$((${smaller_slot_q} - 1)) # array key begin at 0
	slot_slices_q[${smaller_slot_q2}]=$((${slot_slices_q[${smaller_slot_q2}]} + ${tab_serieslice[${job}]}))
	echo "extract serie ${job} : ${tab_serieUID[${job}]} to slot${smaller_slot_q}"

	#movescu cmd
	movescu -k 0008,0052=SERIES -k 0008,0060=${modality_q} -k 0010,0030 -k 0008,1030 -k 0008,103e -k 0020,0011 -k 0008,0031 -k 0010,0010="${tab_patient[${select_patient_number}]}" -k 0010,0020="${tab_patientID[${select_patient_number}]}" -k 0020,000d=${tab_studyUID[${select_patient_number}]} -k 0020,000e=${tab_serieUID[${job}]} -k 0008,0020=${tab_studydate[${select_patient_number}]} ${pacs_IP} ${pacs_port} -aet ${slot_basename}${smaller_slot_q} &
	movescu_job[${job}]=$!

done

# how many slices are query?
tot_slice=0
for s in $(echo ${slot_slices_q[@]})
do
  tot_slice=$((${tot_slice} + $s ))
done
printf "${tot_slice} dicom in ${rslot} slot(s) "
echo "(${slot_slices_q[@]})"

# waiting end of movescu cmd and close dicom node(s)
if [ "${tot_slice}" -gt "0" ];then
	wait ${movescu_job[*]}	
fi


sudo kill ${aet_thread_slot[*]}




rm -rf ${temp_folder}
for zslot in $(seq 1 ${rslot});do

	sudo rm -rf  /mnt/homes_hdd/CHRULQR_node/slot${zslot}/St_${tab_studyUID[${select_patient_number}]}

done
printf "\n"

