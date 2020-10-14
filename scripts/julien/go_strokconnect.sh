#!/bin/bash


subj=$1



echo "------------------------------------------------------------------------------------------------------------
 qbatch -q U1404 -oe /home/julien/log -N ${subj} strokconnect_fs.sh ${subj}
"
#test_fs_mt1.sh ${fs_version} ${subj} ${data_source} ${data_destination} ${volume}

qbatch -q fs_q -oe /home/julien/log -N SK_${subj} strokconnect_fs.sh ${subj}



