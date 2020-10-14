#!/bin/bash

dir=$1
echo > resultats_freesurfer.txt
for i in `find $dir -type f -name aseg.stats`
do
echo >> resultats_freesurfer.txt
echo "$i" >> resultats_freesurfer.txt
grep lhCortex $i |sed -n "s/.*\(.[0-9].[0-9].[0-9]\.[0-9].*\),.*$/lhCortex \1 mm3/p" >> resultats_freesurfer.txt
grep rhCortex $i |sed -n "s/.*\(.[0-9].[0-9].[0-9]\.[0-9].*\),.*$/rhCortex \1 mm3/p" >> resultats_freesurfer.txt
grep lhCorticalWhiteMatter $i |sed -n "s/.*\(.[0-9].[0-9].[0-9]\.[0-9].*\),.*$/lhWM \1 mm3/p" >> resultats_freesurfer.txt
grep rhCorticalWhiteMatter $i |sed -n "s/.*\(.[0-9].[0-9].[0-9]\.[0-9].*\),.*$/rhWM \1 mm3/p" >> resultats_freesurfer.txt
awk '$5 == "Left-Hippocampus" {print "left hippo\t" $4 " mm3";}' $i >> resultats_freesurfer.txt
awk '$5 == "Right-Hippocampus" {print "right hippo\t" $4 " mm3";}' $i >> resultats_freesurfer.txt
awk '$5 == "Left-Amygdala" {print "left amygdala\t" $4 " mm3";}' $i >> resultats_freesurfer.txt
awk '$5 == "Right-Amygdala" {print "right amydala\t" $4 " mm3";}' $i >> resultats_freesurfer.txt
awk '$5 == "CSF" {print "CSF\t" $4 " mm3";}' $i >> resultats_freesurfer.txt
awk '$5 == "Left-Lateral-Ventricle" {print "left ventricle \t" $4 " mm3";}' $i >> resultats_freesurfer.txt
awk '$5 == "Right-Lateral-Ventricle" {print "right ventricle\t" $4 " mm3";}' $i >> resultats_freesurfer.txt
awk '$5 == "3rd-Ventricle" {print "3rd ventricle\t" $4 " mm3";}' $i >> resultats_freesurfer.txt
awk '$5 == "4th-Ventricle" {print "4th ventricle\t" $4 " mm3";}' $i >> resultats_freesurfer.txt
awk '$5 == "5th-Ventricle" {print "5th ventricle\t" $4 " mm3";}' $i >> resultats_freesurfer.txt
done
