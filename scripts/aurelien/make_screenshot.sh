#!/bin/bash

if [ $# -lt 3 ]
then
	echo ""
	echo "Usage : make_screenshot.sh -fs FS_DIR -s subject -od OUT_DIR [-p orientation -inc increment]"
	echo
	exit 1
fi

index=1
INC=2
ORIENT=1

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage:"
		echo ""
		echo "  -fs FS_DIR                  : Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -s SubjName               : Subject ID"
		echo "	-od outdir 		: output directory"
		echo "	-p orientation		: ax,AX,sag,SAG,coro,CORO (default : ax)"
		echo "	-inc increment		: 1 (default 2 : every 2 images)"
		echo "Usage: "
		exit 1
		;;
	-fs)
		fs=`expr $index + 1`
		eval fs=\${$fs}
		echo "  |-------> SubjDir : $fs"
		index=$[$index+1]
		;;
	-s)
		subj=`expr $index + 1`
		eval subj=\${$subj}
		echo "  |-------> Subject Name : ${subj}"
		index=$[$index+1]
		;;
	-od)
		outdir=`expr $index + 1`
		eval outdir=\${$outdir}
		echo "  |-------> Output directory : ${outdir}"
		index=$[$index+1]
		;;
	-p)
		ORIENT=`expr $index + 1`
		eval ORIENT=\${$ORIENT}
		ORIENT=${ORIENT,,}
		echo "  |-------> Orientation : ${ORIENT}"
		if [ $ORIENT = ax ]; then
		ORIENT=1
		elif [ $ORIENT = sag ]; then
		ORIENT=2
		elif [ $ORIENT = coro ]; then
		ORIENT=0
		else
		echo "orientation erronee"
		exit 1
		fi
		index=$[$index+1]
		;;
	-inc)
		INC=`expr $index + 1`
		eval INC=\${$INC}
		echo "  |-------> increment : $INC"
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

if [ ! -d ${outdir} ]
then
	mkdir ${outdir}
fi

cat > /tmp/script_${subj}.tcl << EOF
SetCursor 0 128 128 128
SetZoomLevel 1
# SetOrientation orientation 
# orientation:
# 0     coronal
# 1     axial
# 2     sagittal
SetOrientation $ORIENT
# Turn cursor display off.
SetDisplayFlag 3 0
# Turn the axes on.
SetDisplayFlag 22 1

SetDisplayConfig 1 1 0

for { set slice 0 } { \$slice < 256 } { incr slice $INC } {

    SetSlice \$slice
    RedrawScreen
    SaveTIFF $outdir/screenshot-\$slice.tif
}
QuitMedit
EOF

export SUBJECTS_DIR=$fs
tkmedit $subj T1.mgz -surfs -tcl /tmp/script_${subj}.tcl
echo "capture d'ecran terminee"
