#!/bin/bash



input=$1

cd ${1}

for subj in $(ls)
do

echo "${subj}"


qbatch -q U1404 -oe /home/julien/log -N FS_${subj}_t1 test_fs_mt1.sh 5.3 ${subj} ${1}${subj} /NAS/dumbo/protocoles/T1_test_FS/U1404_data2 t1.nii.gz

	#cd ${1}${subject}/	
        #mkdir temp/
	#for serie in $(ls -d *)
	#do
		
	#dcm2nii -o ./ ${serie}/*


	#done


done
