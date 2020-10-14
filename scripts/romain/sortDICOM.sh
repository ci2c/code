#!/bin/bash

pattern="(0008,0008) CS [ORIGINAL\PRIMARY\M_FFE\M\FFE]           #  28, 5 ImageType"

#"0018,0081" champ contenant les TEs...

for file in `ls /NAS/tupac/protocoles/3DMULTIGRE_greg/phantom/phantom8/phantom8_exam1_sag/3DMULTIGRE_SAG_STRICT_201` 
#`ls /NAS/tupac/renaud/QSM/data/207186^X_COMAJ_2016-09-26/201_3DMULTIGRE_SAG_STRICT`
do
        resu=`dcmdump -M +P "0008,0008" /NAS/tupac/protocoles/3DMULTIGRE_greg/phantom/phantom8/phantom8_exam1_sag/3DMULTIGRE_SAG_STRICT_201/${file}`
        if [ "${resu}" = "${pattern}" ]
        then
                cp /NAS/tupac/protocoles/3DMULTIGRE_greg/phantom/phantom8/phantom8_exam1_sag/3DMULTIGRE_SAG_STRICT_201/${file} /NAS/tupac/protocoles/3DMULTIGRE_greg/phantom/phantom8/phantom8_exam1_sag/201_magnitude/
        fi
done
