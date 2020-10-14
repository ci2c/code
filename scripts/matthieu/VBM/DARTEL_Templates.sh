#! /bin/bash

if [ $# -lt 2 ]
then
	echo ""
	echo "Usage: DARTEL_Templates.sh -i <paths_rc_images> "
	echo ""
	echo "  -i        : variable containing paths of imported rc1 and rc2 images separated by coma (rc?.nii)"
	echo ""
	echo "Usage: DARTEL_Templates.sh -i <paths_rc_images> "
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
		echo "Usage: DARTEL_Templates.sh -i <paths_rc_images> "
		echo ""
		echo "  -i        : variable containing paths of imported rc1 and rc2 images separated by coma (rc?.nii)"
		echo ""
		echo "Usage: DARTEL_Templates.sh -i <paths_rc_images> "
		echo ""
		exit 1
		;;
	-i)
		index=$[$index+1]
		eval input=\${$index}
		echo "paths of imported rc1 and rc2 images : $input"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: DARTEL_Templates.sh -i <paths_rc_images> "
		echo ""
		echo "  -i        : variable containing paths of imported rc1 and rc2 images separated by coma (rc?.nii)"
		echo ""
		echo "Usage: DARTEL_Templates.sh -i <paths_rc_images> "
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

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

DARTEL_Templates(${input});
 
EOF
