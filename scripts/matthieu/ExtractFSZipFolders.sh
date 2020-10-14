#!/bin/bash

InputSubjectsFile=/NAS/tupac/protocoles/HypoAno/FS5.3/TestExtractionSujets

while read subject
do
  qbatch -q M32_q -oe /NAS/tupac/protocoles/HypoAno/Logdir -N tar_${subject}_label tar -I lbzip2 -C /NAS/tupac/protocoles/HypoAno/FS5.3/ \
  -xvf /NAS/notorious/NAS/marc/freesurfer/${subject}.tar.bz2 ${subject}/label/
sleep 2
  qbatch -q M32_q -oe /NAS/tupac/protocoles/HypoAno/Logdir -N tar_${subject}_mri tar -I lbzip2 -C /NAS/tupac/protocoles/HypoAno/FS5.3/ \
  -xvf /NAS/notorious/NAS/marc/freesurfer/${subject}.tar.bz2 ${subject}/mri/
done < ${InputSubjectsFile}
