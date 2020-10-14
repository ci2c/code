#! /bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: SPM_Coregister_PET_MRI.sh -r <ReferenceImg> -s <SourceImg>"
	echo ""
	echo "	-r	: input path of the reference image (MRI) "
	echo "	-s	: input path of the source image (mean PET) "
	echo ""
	echo "Usage: SPM_Coregister_PET_MRI.sh -r <ReferenceImg> -s <SourceImg>"
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
		echo "Usage: SPM_Coregister_PET_MRI.sh -r <ReferenceImg> -s <SourceImg>"
		echo ""
		echo "	-r	: input path of the reference image (MRI) "
		echo "	-s	: input path of the source image (mean PET) "
		echo ""
		echo "Usage: SPM_Coregister_PET_MRI.sh -r <ReferenceImg> -s <SourceImg>"
		echo ""
		exit 1
		;;
	-r)
		index=$[$index+1]
		eval RefFile=\${$index}
		echo "path of reference image : $RefFile"
		;;
	-s)
		index=$[$index+1]
		eval SrcFile=\${$index}
		echo "path of the source image : $SrcFile"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: SPM_Coregister_PET_MRI.sh -r <ReferenceImg> -s <SourceImg>"
		echo ""
		echo "	-r	: input path of the reference image (MRI) "
		echo "	-s	: input path of the source image (mean PET) "
		echo ""
		echo "Usage: SPM_Coregister_PET_MRI.sh -r <ReferenceImg> -s <SourceImg>"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${RefFile} ]
then
	 echo "-r argument mandatory"
	 exit 1
elif [ -z ${SrcFile} ]
then
	 echo "-s argument mandatory"
	 exit 1
fi

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

Coregister_PET_MRI('${RefFile}','${SrcFile}');
 
EOF
