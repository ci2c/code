#! /bin/bash

if [ $# -lt 2 ]
then
	echo ""
	echo "Usage: MNI_Normalise.sh -t <template_path> -f <paths_flowfields> -i <paths_rc_images>"
	echo ""
	echo "  -t        : path of the template file (Template6.nii)"
	echo ""
	echo "  -f        : variable containing paths of flow fields separated by coma (u_*.nii)"
	echo ""
	echo "  -i        : variable containing paths of grey matter images separated by coma (c1*.nii)"
	echo ""
	echo "Usage: MNI_Normalise.sh -t <template_path> -f <paths_flowfields> -i <paths_rc_images>"
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
		echo "Usage: MNI_Normalise.sh -t <template_path> -f <paths_flowfields> -i <paths_rc_images>"
		echo ""
		echo "  -t        : path of the template file (Template6.nii)"
		echo ""
		echo "  -f        : variable containing paths of flow fields separated by coma (u_*.nii)"
		echo ""
		echo "  -i        : variable containing paths of grey matter images separated by coma (c1*.nii)"
		echo ""
		echo "Usage: MNI_Normalise.sh -t <template_path> -f <paths_flowfields> -i <paths_rc_images>"
		echo ""
		exit 1
		;;
	-t)
		index=$[$index+1]
		eval template_path=\${$index}
		echo "path of the template : $template_path"
		;;
	-f)
		index=$[$index+1]
		eval flowfield_path=\${$index}
		echo "paths of the flowfields images : $flowfield_path"
		;;
	-i)
		index=$[$index+1]
		eval greymatter_path=\${$index}
		echo "paths of the grey matter images : $greymatter_path"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: MNI_Normalise.sh -t <template_path> -f <paths_flowfields> -i <paths_rc_images>"
		echo ""
		echo "  -t        : path of the template file (Template6.nii)"
		echo ""
		echo "  -f        : variable containing paths of flow fields separated by coma (u_*.nii)"
		echo ""
		echo "  -i        : variable containing paths of grey matter images separated by coma (c1*.nii)"
		echo ""
		echo "Usage: MNI_Normalise.sh -t <template_path> -f <paths_flowfields> -i <paths_rc_images>"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${template_path} ]
then
	 echo "-t argument mandatory"
	 exit 1
elif [ -z ${flowfield_path} ]
then
	 echo "-f argument mandatory"
	 exit 1	
elif [ -z ${greymatter_path} ]
then
	 echo "-i argument mandatory"
	 exit 1	
fi

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

MNI_Normalise(${template_path},${flowfield_path},${greymatter_path});
 
EOF
