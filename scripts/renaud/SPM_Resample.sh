#!/bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: SPM_Resample.sh  -r <ref_ima>  -s <source_ima>  [-i <value>  -p <prefix>  -o <out_folder>]"
	echo ""
	echo "  -r <ref_ima>                       : Reference image"
	echo "  -s <source_ima>                    : Image to resample"
	echo "Options :"
	echo "  -i <value>                         : Interpolation method (Default: 4)"
	echo "						0 : nearest neighbour"
	echo "						1 : trilinear"
	echo "						2,3,4,5,6,7 : B-spline (value is the order)"
	echo "  -p <prefix>                        : Prefix of resampled image (Default: r)"
	echo "  -o <out_folder>                    : Ouput folder (Default: pwd)"
	echo " "
	echo "Usage: SPM_Resample.sh  -r <ref_ima>  -s <source_ima>  [-i <value>  -p <prefix>  -o <out_folder>]"
	echo ""
	exit 1
fi

index=1
interp=4
prefix="r"
output=""

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: SPM_Resample.sh  -r <ref_ima>  -s <source_ima>  [-i <value>  -p <prefix>  -o <out_folder>]"
		echo ""
		echo "  -r <ref_ima>                       : Reference image"
		echo "  -s <source_ima>                    : Image to resample"
		echo "Options :"
		echo "  -i <value>                         : Interpolation method (Default: 4)"
		echo "						0 : nearest neighbour"
		echo "						1 : trilinear"
		echo "						2,3,4,5,6,7 : B-spline (value is the order)"
		echo "  -p <prefix>                        : Prefix of resampled image (Default: r)"
		echo "  -o <out_folder>                    : Ouput folder (Default: pwd)"
		echo " "
		echo "Usage: SPM_Resample.sh  -r <ref_ima>  -s <source_ima>  [-i <value>  -p <prefix>  -o <out_folder>]"
		echo ""
		exit 1
		;;
	-r)
		REF=`expr $index + 1`
		eval REF=\${$REF}
		echo "reference image : $REF"
		;;
	-s)
		SOURCE=`expr $index + 1`
		eval SOURCE=\${$SOURCE}
		echo "source image : $SOURCE"
		;;
	-i)
		interp=`expr $index + 1`
		eval interp=\${$interp}
		echo "interpolation method : $interp"
		;;
	-p)
		prefix=`expr $index + 1`
		eval prefix=\${$prefix}
		echo "prefix : $prefix"
		;;
	-o)
		output=`expr $index + 1`
		eval output=\${$output}
		echo "output folder : $output"
		;;
	esac
	index=$[$index+1]
done


matlab -nodisplay <<EOF

cd ${HOME}
p = pathdef;
addpath(p);
spm_get_defaults;
spm_jobman('initcfg');
matlabbatch = {};
matlabbatch{1}.spm.spatial.coreg.write.ref             = cellstr('${REF}');
matlabbatch{1}.spm.spatial.coreg.write.source          = cellstr('${SOURCE}');
matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = ${interp};
matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap   = [0 0 0];
matlabbatch{1}.spm.spatial.coreg.write.roptions.mask   = 0;
matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = '${prefix}';
spm_jobman('run',matlabbatch);

EOF

if [ -n "$output" ]; then
	name=$(basename "$SOURCE")
	name="$prefix""$name"
	DIR=$(dirname "$SOURCE")
	mv "$DIR"/"$name" "$output"/
fi


