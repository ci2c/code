#!/bin/bash

6   Left-Cerebellum-Exterior                0   148 0   0
7   Left-Cerebellum-White-Matter            220 248 164 0
8   Left-Cerebellum-Cortex                  230 148 34  0
9   Left-Thalamus                           0   118 14  0
10  Left-Thalamus-Proper                    0   118 14  0
11  Left-Caudate                            122 186 220 0
12  Left-Putamen                            236 13  176 0
13  Left-Pallidum                           12  48  255 0
14  3rd-Ventricle                           204 182 142 0
15  4th-Ventricle                           42  204 164 0
16  Brain-Stem                              119 159 176 0
17  Left-Hippocampus                        220 216 20  0

#./takeshots -l listsubj.txt -m pial -m inflated -p aparc
#./makehtml -l listsubj.txt -m pial -m inflated -p aparc -d /path/to/html
#/NAS/tupac/protocoles/healthy_volunteers/html/index.html

less $FREESURFER_HOME/FreeSurferColorLUT.txt
NbROI="17"
NameROI="Left-Hippocampus"

Volumes=`more /NAS/dumbo/HBC/Freesurfer5.0/*/stats/aseg.stats | sed -n 's/^ 12  ${NbROI}\s*\S*\s*//p' | sed -n 's/${NameROI}.*$/\r/p'`
echo ${Volumes}>Volumes.txt

R --no-save <<EOF
data<-read.csv("Volumes.txt", header=F)
summary(data)
boxplot(data)
EOF
