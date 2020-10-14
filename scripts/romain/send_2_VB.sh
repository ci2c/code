#! /bin/bash

aide="\n*********************************\n"
aide+="***send_2_VB.sh**\n"
aide+="*********************************\n"
aide+="Usage : send_2_VB -o [PATH] -T1 [FILE] -a [AGE] -s [SEXE]\n"
aide+="    -o : output volume dir\n"
aide+="    -T1 : T1 nii.gz file \n"
aide+="    -a : age\n"
aide+="    -s : sexe \"Male\" \"Female\"\n"
aide+="\nExample :\n"
aide+="bash send_2_VB.sh -o /NAS/tupac/romain/FS_VolBrain/FS60 -T1 /NAS/tupac/protocoles/healthy_volunteers/data/ci2c/T02S02/20160418_145116WIP3DT1CLEARs201a1002.nii.gz -a 24 -s \"Male\" \n"
aide+="\nGood luck, ask for help from Romain VIARD"

if [ $# -lt 4 ]
then
	echo -e ${aide}
	exit 1
fi

index=1
while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo -e ${aide}
		exit 1
		;;
	-o)
		index=$[$index+1]
		eval VOL_OUT=\${$index}
		echo "Out volume folder : ${VOL_OUT}"
		;;
	-T1)
		index=$[$index+1]
		eval FILE_IN=\${$index}
		echo "T1 file : ${FILE_IN}"
		;;
	-a)
		index=$[$index+1]
		eval AGE=\${$index}
		echo "AGE : ${AGE}"
		;;
	-s)
		index=$[$index+1]
		eval SEXE=\${$index}
		echo "SEXE : ${SEXE}"
		;;
	esac
	index=$[$index+1]
done


docker load -i /NAS/tupac/docker_images/from_vb_2_fs.tar
NAME=`basename -s .nii.gz ${FILE_IN}`
cmd="docker run -v ${VOL_OUT}:/mnt/vout -v ${FILE_IN}:/T1_infile.nii.gz:ro -e NAME=${NAME} -e AGE=${AGE} -e SEXE=\"${SEXE}\" romainv/from_vb_2_fs"
echo ${cmd} ; eval ${cmd}
