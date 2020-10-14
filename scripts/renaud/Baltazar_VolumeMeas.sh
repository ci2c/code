#! /bin/bash

if [ $# -lt 2 ]
then
	echo ""
	echo "Usage: Baltazar_VolumeMeas.sh -i <SUBJECTS_DIR> "
	echo ""
	echo "  -i   : Path to data (i.e. SUBJECTS_DIR)"
	echo ""
	echo "Usage: Baltazar_VolumeMeas.sh -i <SUBJECTS_DIR> "
	echo ""
	exit 1
fi

index=1

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: Baltazar_VolumeMeas.sh -i <SUBJECTS_DIR> "
		echo ""
		echo "  -i   : Path to data (i.e. SUBJECTS_DIR)"
		echo ""
		echo "Usage: Baltazar_VolumeMeas.sh -i <SUBJECTS_DIR> "
		echo ""
		exit 1
		;;
	-i)
		index=$[$index+1]
		eval input=\${$index}
		echo "data path : $input"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: Baltazar_VolumeMeas.sh -i <SUBJECTS_DIR> "
		echo ""
		echo "  -i   : Path to data (i.e. SUBJECTS_DIR)"
		echo ""
		echo "Usage: Baltazar_VolumeMeas.sh -i <SUBJECTS_DIR> "
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${input} ]
then
	echo "-i argument mandatory"
	exit 1
fi

echo > ${input}/volume_measures.txt
for i in `find ${input} -type f -name aseg.stats`
do
	echo >> ${input}/volume_measures.txt
	echo "$i" >> ${input}/volume_measures.txt
	grep lhCortex $i |sed -n "s/.*\(.[0-9].[0-9].[0-9]\.[0-9].*\),.*$/lhCortex \1 mm3/p" >> ${input}/volume_measures.txt
	grep rhCortex $i |sed -n "s/.*\(.[0-9].[0-9].[0-9]\.[0-9].*\),.*$/rhCortex \1 mm3/p" >> ${input}/volume_measures.txt
	grep lhCorticalWhiteMatter $i |sed -n "s/.*\(.[0-9].[0-9].[0-9]\.[0-9].*\),.*$/lhWM \1 mm3/p" >> ${input}/volume_measures.txt
	grep rhCorticalWhiteMatter $i |sed -n "s/.*\(.[0-9].[0-9].[0-9]\.[0-9].*\),.*$/rhWM \1 mm3/p" >> ${input}/volume_measures.txt
	grep IntraCranialVol $i |sed -n "s/.*\(.[0-9].[0-9].[0-9]\.[0-9].*\),.*$/ICV \1 mm3/p" >> ${input}/volume_measures.txt
	awk '$5 == "Left-Hippocampus" {print "left hippo\t" $4 " mm3";}' $i >> ${input}/volume_measures.txt
	awk '$5 == "Right-Hippocampus" {print "right hippo\t" $4 " mm3";}' $i >> ${input}/volume_measures.txt
	awk '$5 == "Left-Amygdala" {print "left amygdala\t" $4 " mm3";}' $i >> ${input}/volume_measures.txt
	awk '$5 == "Right-Amygdala" {print "right amydala\t" $4 " mm3";}' $i >> ${input}/volume_measures.txt
done
