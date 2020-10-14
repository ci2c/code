#! /bin/bash

if [ $# -lt 14 ]
then
	echo ""
	echo "Usage:  NRJ_Preprocessing.sh  -i <data_path>  -TR <value>  -Ns <value>  -N <value>  -fwhm <value>  -refslice <value>  -remF <value>"
	echo ""
	echo "  -i                           : Path to data "
	echo "  -TR                          : TR value "
	echo "  -Ns                          : Number of sessions "
	echo "  -N                           : Number of slices "
	echo "  -fwhm                        : smoothing value "
	echo "  -refslice                    : slice of reference for slice timing correction "
	echo "  -remF                        : number of first frames to remove "
	echo ""
	echo "Usage:  NRJ_Preprocessing.sh  -i <data_path>  -TR <value>  -Ns <value>  -N <value>  -fwhm <value>  -refslice <value>  -remF <value>"
	echo ""
	echo "Author: Renaud Lopes - CHRU Lille - June 6, 2012"
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
		echo "Usage:  NRJ_Preprocessing.sh  -i <data_path>  -TR <value>  -Ns <value>  -N <value>  -fwhm <value>  -refslice <value>  -remF <value>"
		echo ""
		echo "  -i                           : Path to epi data "
		echo "  -TR                          : TR value "
		echo "  -Ns                          : Number of sessions "
		echo "  -N                           : Number of slices "
		echo "  -fwhm                        : smoothing value "
		echo "  -refslice                    : slice of reference for slice timing correction "
		echo "  -remF                        : number of first frames to remove "
		echo ""
		echo "Usage:  NRJ_Preprocessing.sh  -i <data_path>  -TR <value>  -Ns <value>  -N <value>  -fwhm <value>  -refslice <value>  -remF <value>"
		echo ""
		echo "Author: Renaud Lopes - CHRU Lille - June 6, 2012"
		echo ""
		exit 1
		;;
	-i)
		index=$[$index+1]
		eval input=\${$index}
		echo "data : ${input}"
		;;
	-TR)
		index=$[$index+1]
		eval TR=\${$index}
		echo "TR value : ${TR}"
		;;
	-Ns)
		index=$[$index+1]
		eval Ns=\${$index}
		echo "number of sessions : ${Ns}"
		;;
	-N)
		index=$[$index+1]
		eval N=\${$index}
		echo "number of slices : ${N}"
		;;
	-fwhm)
		index=$[$index+1]
		eval fwhm=\${$index}
		echo "fwhm : ${fwhm}"
		;;
	-refslice)
		index=$[$index+1]
		eval refslice=\${$index}
		echo "slice of reference : ${refslice}"
		;;
	-remF)
		index=$[$index+1]
		eval remFrames=\${$index}
		echo "frames to remove : ${remFrames}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage:  NRJ_Preprocessing.sh  -i <data_path>  -TR <value>  -Ns <value>  -N <value>  -fwhm <value>  -refslice <value>  -remF <value> "
		echo ""
		echo "  -i                           : Path to data "
		echo "  -TR                          : TR value "
		echo "  -Ns                          : Number of sessions "
		echo "  -N                           : Number of slices "
		echo "  -fwhm                        : smoothing value "
		echo "  -refslice                    : slice of reference for slice timing correction "
		echo "  -remF                        : number of first frames to remove "
		echo ""
		echo "Usage:  NRJ_Preprocessing.sh  -i <data_path>  -TR <value>  -Ns <value>  -N <value>  -fwhm <value>  -refslice <value>  -remF <value> "
		echo ""
		echo "Author: Renaud Lopes - CHRU Lille - June 6, 2012"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

for (( i=1; i<=${Ns}; i++ ))
do

    echo " Preprocessing session $i "
    
    if [ ${i} -lt 10 ]
    then
      ses=sess0${i}
    else
      ses=sess${i}
    fi
    
    if [ ! -d ${input}/fmri/${ses}/spm ]
    then
	mkdir ${input}/fmri/${ses}/spm
    else
	rm -f ${input}/fmri/${ses}/spm/*
    fi

    echo "fslsplit ${input}/fmri/${ses}/*.nii ${input}/fmri/${ses}/spm/epi_ -t"
    fslsplit ${input}/fmri/${ses}/*.nii ${input}/fmri/${ses}/spm/epi_ -t
    gunzip ${input}/fmri/${ses}/spm/*.gz

    for (( k=0; k<${remFrames}; k++ ))
    do
	if [ ${k} -lt 10 ]
	then
	    ima=epi_000${k}.nii
	else
	    ima=epi_00${k}.nii
	fi
	rm -f ${input}/fmri/${ses}/spm/${ima}
    done

    echo "NRJ_PreprocessSPM8.sh -epi ${input}/fmri/${ses}/spm -anat ${input}/anat -TR ${TR} -N ${N} -fwhm ${fwhm} -refslice ${refslice} -acquis ascending -coreg epi2anat -resampling 0"
    qbatch -q fs_q -oe /home/renaud/log/ -N pre_${ses} NRJ_PreprocessSPM8.sh -epi ${input}/fmri/${ses}/spm -anat ${input}/anat -TR ${TR} -N ${N} -fwhm ${fwhm} -refslice ${refslice} -acquis ascending -coreg epi2anat -resampling 0

    sleep 5

done

