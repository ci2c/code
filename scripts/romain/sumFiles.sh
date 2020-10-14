#!/bin/bash

        fileN="/NAS/dumbo/protocoles/IRMf_memoire/FS5.3/wmean.nii.gz"
        rm $fileN
        for SUBJ in `ls /NAS/dumbo/protocoles/IRMf_memoire/FS5.3/*_enc/fmri/mot/wcon_0001.nii`
        do
                echo ${SUBJ}
                if [ ! -f $fileN ]
                then
                        echo "fslmaths ${SUBJ} -add 0 $fileN"
                        `fslmaths ${SUBJ} -add 0 $fileN`
                else
                        echo "fslmaths $fileN -add ${SUBJ} $fileN"
                        `fslmaths $fileN -add ${SUBJ} $fileN`
                fi
        done
        



fileN="/NAS/dumbo/protocoles/IRMf_memoire/FS5.3/wmean.nii.gz"
rm $fileN
cell_TD=("gunther" "dequeant" "comblez" "frion" "wasselin" "richard" "dadoun" "marcy" "picquet" "puthoste");
for ELEMENT in "${cell_TD[@]}"
do
        ARG="/NAS/dumbo/protocoles/IRMf_memoire/FS5.3/${ELEMENT}_enc/fmri/mot/wcon_0001.nii"
        if [ ! -f $fileN ]
        then
                echo "fslmaths ${ARG} -add 0 $fileN"
                `fslmaths ${ARG} -add 0 $fileN`
        else
                echo "fslmaths $fileN -add ${ARG} $fileN"
                `fslmaths $fileN -add ${ARG} $fileN`
        fi
done
