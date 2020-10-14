#!/bin/bash

if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: SubCortRegAnnot.sh  -fs <FS_dir>  -sname <Struct_name>  -annot <Annot_name>  -subj <subj1> <subj2> ... <subjN>  [-tmpdir <temp_dir>]"
	echo ""
	echo "  -fs <FS_dir>                       : Path to FS output directory (equivalent to SUBJECTS_DIR)"
	echo "  -sname <Struct_name>               : Name of the subcortical structure of interest"
	echo "  -annot <Annot_name>                : Name of the annotation file, i.e. my_parc.annot"
	echo "  -subj <subj1> <subj2> ...          : List of subjects to process"
	echo " "
	echo " Option :"
	echo "  -tmpdir <temp_dir>                 : Path to directory for temp calculations. Default : /tmp/"
	echo ""
	echo "Usage: SubCortRegAnnot.sh  -fs <FS_dir>  -sname <Struct_name>  -annot <Annot_name>  -subj <subj1> <subj2> ... <subjN>  [-tmpdir <temp_dir>]"
	echo ""
	exit 1
fi


index=1
tmpdir=/tmp/

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: SubCortRegAnnot.sh  -fs <FS_dir>  -sname <Struct_name>  -annot <Annot_name>  -subj <subj1> <subj2> ... <subjN>  [-tmpdir <temp_dir>]"
		echo ""
		echo "  -fs <FS_dir>                       : Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -sname <Struct_name>               : Name of the subcortical structure of interest"
		echo "  -annot <Annot_name>                : Name of the annotation file, i.e. my_parc.annot"
		echo "  -subj <subj1> <subj2> ...          : List of subjects to process"
		echo " "
		echo " Option :"
		echo "  -tmpdir <temp_dir>                 : Path to directory for temp calculations. Default : /tmp/"
		echo ""
		echo "Usage: SubCortRegAnnot.sh  -fs <FS_dir>  -sname <Struct_name>  -annot <Annot_name>  -subj <subj1> <subj2> ... <subjN>  [-tmpdir <temp_dir>]"
		echo ""
		exit 1
		;;
	-fs)
		fs=`expr $index + 1`
		eval fs=\${$fs}
		echo "|> FS_dir         : $fs"
		;;
	-sname)
		sname=`expr $index + 1`
		eval sname=\${$sname}
		echo "|> Structure name : $sname"
		;;
	-subj)
		i=$[$index+1]
		eval infile=\${$i}
		subj=""
		while [ "$infile" != "-fs" -a "$infile" != "-sname" -a "$infile" != "-tmpdir" -a "$infile" != "-annot" -a $i -le $# ]
		do
		 	subj="${subj} ${infile}"
		 	i=$[$i+1]
		 	eval infile=\${$i}
		done
		index=$[$i-1]
		echo "|> Subj           : $subj"
		;;
	-tmpdir)
		tmpdir=`expr $index + 1`
		eval tmpdir=\${$tmpdir}
		echo "|> Temp dir       : $tmpdir"
		;;
	-annot)
		annot=`expr $index + 1`
		eval annot=\${$annot}
		echo "|> Annot name     : $annot"
		;;
	-*)
		Temp=`expr $index`
		eval Temp=\${$Temp}
		echo "Unknown argument ${Temp}"
		echo ""
		echo "Usage: SubCortRegAnnot.sh  -fs <FS_dir>  -sname <Struct_name>  -annot <Annot_name>  -subj <subj1> <subj2> ... <subjN>  [-tmpdir <temp_dir>]"
		echo ""
		echo "  -fs <FS_dir>                       : Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -sname <Struct_name>               : Name of the subcortical structure of interest"
		echo "  -annot <Annot_name>                : Name of the annotation file, i.e. my_parc.annot"
		echo "  -subj <subj1> <subj2> ...          : List of subjects to process"
		echo " "
		echo " Option :"
		echo "  -tmpdir <temp_dir>                 : Path to directory for temp calculations. Default : /tmp/"
		echo ""
		echo "Usage: SubCortRegAnnot.sh  -fs <FS_dir>  -sname <Struct_name>  -annot <Annot_name>  -subj <subj1> <subj2> ... <subjN>  [-tmpdir <temp_dir>]"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

SUBJECTS_DIR=${tmpdir}

if [ ! -d ${tmpdir}/${sname} ]
then
	echo "cp -R ${fs}/${sname} ${tmpdir}/"
	cp -R ${fs}/${sname} ${tmpdir}/
	cp -f ${tmpdir}/${sname}/surf/lh.white ${tmpdir}/${sname}/surf/lh.orig
else
	rm -rf ${tmpdir}/${sname}
	echo "cp -R ${fs}/${sname} ${tmpdir}/"
	cp -R ${fs}/${sname} ${tmpdir}/
	cp -f ${tmpdir}/${sname}/surf/lh.white ${tmpdir}/${sname}/surf/lh.orig
fi

# Copy original data to temp dir
for SUBJ in `echo ${subj}`
do
	if [ ! -d ${tmpdir}/${SUBJ} ]
	then
		mkdir ${tmpdir}/${SUBJ}
		echo "cp -R ${fs}/${SUBJ}/${sname} ${tmpdir}/${SUBJ}/surf"
		cp -R ${fs}/${SUBJ}/${sname} ${tmpdir}/${SUBJ}/surf
	else
		rm -rf ${tmpdir}/${SUBJ} 
		mkdir ${tmpdir}/${SUBJ}
		echo "cp -R ${fs}/${SUBJ}/${sname} ${tmpdir}/${SUBJ}/surf"
		cp -R ${fs}/${SUBJ}/${sname} ${tmpdir}/${SUBJ}/surf
	fi
	
	echo "mri_surf2surf --srcsubject ${sname} --srchemi lh --srcsurfreg sphere.reg --trgsubject ${SUBJ} --trghemi lh --trgsurfreg sphere.reg --sval-annot ${tmpdir}/${sname}/lh.${annot} --tval ${tmpdir}/${SUBJ}/surf/lh.${annot}"
	mri_surf2surf --srcsubject ${sname} --srchemi lh --srcsurfreg sphere.reg --trgsubject ${SUBJ} --trghemi lh --trgsurfreg sphere.reg --sval-annot ${tmpdir}/${sname}/lh.${annot} --tval ${tmpdir}/${SUBJ}/surf/lh.${annot}
	
	echo "cp -f ${tmpdir}/${SUBJ}/surf/lh.${annot} ${fs}/${SUBJ}/${sname}/lh.${annot}"
	cp -f ${tmpdir}/${SUBJ}/surf/lh.${annot} ${fs}/${SUBJ}/${sname}/lh.${annot}
done

