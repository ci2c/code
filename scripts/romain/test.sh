#!/bin/bash


#find /NAS/dumbo/protocoles/IRMf_memoire/data/delille/log/ -iname "*Retrieval*.*" | xargs grep '.*\/._encoding_faces.(.*bmp)\s\d*\n(.*trigger.*\n)*.*bouton_(\d).*'

BRANCH_REGEX1='.*\/._encoding_faces.(.*bmp)\s\d*'
BRANCH_REGEX2_opt1='.*bouton_?.*'
BRANCH_REGEX2_opt2='trigger'
BRANCH_REGEX2_opt3='croix'

FS_PATH="/NAS/dumbo/protocoles/IRMf_memoire/data/delille/log/"

if [ -s ${FS_PATH}/memoryEpilepsyRetrieval2Runs_suj2_delille_08-Apr-2015.log ]
then	
	while read SENTENCE1 
	do
		if [[ $SENTENCE1 =~ $BRANCH_REGEX1 ]];
		then
			echo ${BASH_REMATCH[1]}
			while read SENTENCE2
			do
				if [[ $SENTENCE2 =~ $BRANCH_REGEX2_opt1 ]];
				then
					echo "ici" "#${BASH_REMATCH[1]}
					break
#				elif [[ $SENTENCE2 =~ $BRANCH_REGEX2_opt2 ]]
#				then
#					echo "opt2"
				elif [[ $SENTENCE2 =~ $BRANCH_REGEX2_opt3 ]]
				then
					echo "opt3"
					break
#				else
#					echo "opt4 : ${SENTENCE2}"
				fi
			done
		fi
	done < ${FS_PATH}/memoryEpilepsyRetrieval2Runs_suj2_delille_08-Apr-2015.log
fi
