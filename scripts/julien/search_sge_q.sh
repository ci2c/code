#!/bin/bash

# require qbatch
# require qstat


index=1

while [ $index -le $# ]
do
eval arg=\${$index}
case "$arg" in
-h|-help)
echo ""
echo ""
echo ""
exit 1
;;
-sge)
index=$[$index+1]
eval sge_list=\${$index}
;;
-subject)
index=$[$index+1]
eval subject=\${$index}
;;
-*)
eval infile=\${$index}
echo "${infile} : unknown option"
exit 1
;;
esac
index=$[$index+1]
done



patient_in_sge_q=$(cat ${sge_list} | grep -n "${subject}" | wc -l)

if [ ${patient_in_sge_q} -gt 0 ]
then
	patient_job_line=$(cat ${sge_list} | grep -n "${subject}" | sed s/:/\\n/ | sed -n 1p)
	patient_job_status_line=$((${patient_job_line}-3))
	job_status=$(cat ${sge_list} | sed -n ${patient_job_status_line}p | sed -e 's/.*\"\(.*\)\".*/\1/')
	job_number=$(cat ${sge_list} | sed -n $((${patient_job_line}-2))p | sed 's#</.*##;s#.*>##')
	job_prio=$(cat ${sge_list} | sed -n $((${patient_job_line}-1))p | sed 's#</.*##;s#.*>##')
	job_owner=$(cat ${sge_list} | sed -n $((${patient_job_line}+1))p | sed 's#</.*##;s#.*>##')
	job_state=$(cat ${sge_list} | sed -n $((${patient_job_line}+2))p | sed 's#</.*##;s#.*>##')
	job_start_time=$(cat ${sge_list} | sed -n $((${patient_job_line}+3))p | sed 's#</.*##;s#.*>##')
	job_queue_name=$(cat ${sge_list} | sed -n $((${patient_job_line}+4))p | sed 's#</.*##;s#.*>##')
	job_slot=$(cat ${sge_list} | sed -n $((${patient_job_line}+5))p | sed 's#</.*##;s#.*>##')
	echo "${job_status};${job_number};${job_prio};$job_owner;$job_state;$job_start_time;$job_queue_name;$job_slot"
else 
	echo "no"
fi

