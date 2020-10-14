#!/bin/bash
set -e


if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: FMRI_SliceTimingCorr.sh  -i <file>  -o <file>  -order <name>  -tr <value> "
	echo ""
	echo "  -i                : 4d fmri file (.nii.gz) "
	echo "  -o                : output 4d fmri file (.nii.gz) "
	echo "  -order            : slice acquisition order (ascending | interleavedPhilips | interleavedDescending | interleavedAscending) "
	echo "  -tr               : TR value (in sec) "
	echo ""
	echo "Usage: FMRI_SliceTimingCorr.sh  -i <file>  -o <file>  -order <name>  -tr <value> "
	echo ""
	exit 1
fi


#### Inputs ####
user=`whoami`
HOME=/home/${user}
index=1
echo "------------------------"


while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: FMRI_SliceTimingCorr.sh  -i <file>  -o <file>  -order <name>  -tr <value> "
		echo ""
		echo "  -i                : 4d fmri file (.nii.gz) "
		echo "  -o                : output 4d fmri file (.nii.gz) "
		echo "  -order            : slice acquisition order (ascending | interleavedPhilips | interleavedDescending | interleavedAscending)  "
		echo "  -tr               : TR value (in sec) "
		echo ""
		echo "Usage: FMRI_SliceTimingCorr.sh  -i <file>  -o <file>  -order <name>  -tr <value> "
		echo ""
		exit 1
		;;
	-i)
		fmri=`expr $index + 1`
		eval fmri=\${$fmri}
		echo "  |-------> fmri file : $fmri"
		index=$[$index+1]
		;;
	-o)
		outfmri=`expr $index + 1`
		eval outfmri=\${$outfmri}
		echo "  |-------> output file : ${outfmri}"
		index=$[$index+1]
		;;
	-order)
		sliceorder=`expr $index + 1`
		eval sliceorder=\${$sliceorder}
		echo "  |-------> slice acquisition order : ${sliceorder}"
		index=$[$index+1]
		;;
	-tr)
		TR=`expr $index + 1`
		eval TR=\${$TR}
		echo "  |-------> TR value : ${TR}"
		index=$[$index+1]
		;;
	-*)
		TEMP=`expr $index`
		eval TEMP=\${$TEMP}
		echo "${TEMP} : unknown argument"
		echo ""
		echo "Enter $0 -help for help"
		exit 1
		;;
	esac
	index=$[$index+1]
done
#################


echo ""
echo "START: FMRI_SliceTimingCorr.sh"
echo ""

# Number of slices
ns=$(fslinfo ${fmri} | grep ^dim3 | awk '{print $2}')

outdir=`dirname ${outfmri}`

matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);

	if strcmp('${sliceorder}','ascending')
		sliceorder = 1:1:${ns};
	elseif strcmp('${sliceorder}','interleavedPhilips')
		sliceorder = [];
		space      = round(sqrt(${ns}));
		for k=1:space
			tmp        = k:space:${ns};
			sliceorder = [sliceorder tmp];
		end
	elseif strcmp('${sliceorder}','interleavedDescending')
		sliceorder = [${ns}:-2:1 ${ns}-1:-2:1];
	elseif strcmp('${sliceorder}','interleavedAscending')
		sliceorder = [1:2:${ns} 2:2:${ns}];
	else
		sliceorder = 1:1:${ns};
	end

	ofile = fullfile('${outdir}','orderfile.txt');
	fid=fopen(ofile,'w');
	fprintf(fid,'%i\n',sliceorder');
	fclose(fid);

EOF

echo "${FSLDIR}/bin/slicetimer -i ${fmri} -o ${outfmri} -r ${TR} --ocustom=${outdir}/orderfile.txt"
${FSLDIR}/bin/slicetimer -i ${fmri} -o ${outfmri} -r ${TR} --ocustom=${outdir}/orderfile.txt

echo ""
echo "END: FMRI_SliceTimingCorr.sh"
echo ""

