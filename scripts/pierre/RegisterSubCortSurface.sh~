#!/bin/bash

if [ $# -lt 6 ]
then
	echo ""
	echo "Usage: RegisterSubCortSurface.sh  -fs <FS_dir>  -sname <Struct_name>  -subj <subj1> <subj2> ... <subjN>   [-template <template>  -tmpdir <temp_dir>]"
	echo ""
	echo "  -fs <FS_dir>                       : Path to FS output directory (equivalent to SUBJECTS_DIR)"
	echo "  -sname <Struct_name>               : Name of the subcortical structure"
	echo "                                       Important : The directory FS_dir/Subj/Struct_name muste have been created previously"
	echo "                                       with the script ModelOneROI.sh"
	echo "  -subj <subj1> <subj2> ...          : List of subjects to register to the template"
	echo " "
	echo " Option :"
	echo "  -template <template>               : Path to the file template.tiff to use."
	echo "                                       Created using the script SubCortTemplate.sh."
	echo "                                       Default : ${HOME}/NAS/pierre/Epilepsy/FreeSurfer5.0/SUBSAMPLED_SURFACE_TARGET/Struct_name.tiff"
	echo "  -tmpdir <temp_dir>                 : Path to directory for temp calculations. Default : /tmp/"
	echo ""
	echo "Usage: RegisterSubCortSurface.sh  -fs <FS_dir>  -sname <Struct_name>  -subj <subj1> <subj2> ... <subjN>   [-template <template>  -tmpdir <temp_dir>]"
	echo ""
	exit 1
fi


index=1
tmpdir=/tmp/
template=""

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: RegisterSubCortSurface.sh  -fs <FS_dir>  -sname <Struct_name>  -subj <subj1> <subj2> ... <subjN>   [-template <template>  -tmpdir <temp_dir>]"
		echo ""
		echo "  -fs <FS_dir>                       : Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -sname <Struct_name>               : Name of the subcortical structure"
		echo "                                       Important : The directory FS_dir/Subj/Struct_name muste have been created previously"
		echo "                                       with the script ModelOneROI.sh"
		echo "  -subj <subj1> <subj2> ...          : List of subjects to register to the template"
		echo " "
		echo " Option :"
		echo "  -template <template>               : Path to the file template.tiff to use."
		echo "                                       Created using the script SubCortTemplate.sh."
		echo "                                       Default : ${HOME}/NAS/pierre/Epilepsy/FreeSurfer5.0/SUBSAMPLED_SURFACE_TARGET/Struct_name.tiff"
		echo "  -tmpdir <temp_dir>                 : Path to directory for temp calculations. Default : /tmp/"
		echo ""
		echo "Usage: RegisterSubCortSurface.sh  -fs <FS_dir>  -sname <Struct_name>  -subj <subj1> <subj2> ... <subjN>   [-template <template>  -tmpdir <temp_dir>]"
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
		while [ "$infile" != "-fs" -a "$infile" != "-sname" -a "$infile" != "-tmpdir" -a "$infile" != "-template" -a $i -le $# ]
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
	-template)
		template=`expr $index + 1`
		eval template=\${$template}
		echo "|> Template       : $template"
		;;
	-*)
		Temp=`expr $index`
		eval Temp=\${$Temp}
		echo "Unknown argument ${Temp}"
		echo ""
		echo "Usage: RegisterSubCortSurface.sh  -fs <FS_dir>  -sname <Struct_name>  -subj <subj1> <subj2> ... <subjN>   [-template <template>  -tmpdir <temp_dir>]"
		echo ""
		echo "  -fs <FS_dir>                       : Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -sname <Struct_name>               : Name of the subcortical structure"
		echo "                                       Important : The directory FS_dir/Subj/Struct_name muste have been created previously"
		echo "                                       with the script ModelOneROI.sh"
		echo "  -subj <subj1> <subj2> ...          : List of subjects to register to the template"
		echo " "
		echo " Option :"
		echo "  -template <template>               : Path to the file template.tiff to use."
		echo "                                       Created using the script SubCortTemplate.sh."
		echo "                                       Default : ${HOME}/NAS/pierre/Epilepsy/FreeSurfer5.0/SUBSAMPLED_SURFACE_TARGET/Struct_name.tiff"
		echo "  -tmpdir <temp_dir>                 : Path to directory for temp calculations. Default : /tmp/"
		echo ""
		echo "Usage: RegisterSubCortSurface.sh  -fs <FS_dir>  -sname <Struct_name>  -subj <subj1> <subj2> ... <subjN>   [-template <template>  -tmpdir <temp_dir>]"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

if [ -z ${template} ]
then
	template=${HOME}/NAS/pierre/Epilepsy/FreeSurfer5.0/SUBSAMPLED_SURFACE_TARGET/${sname}.tiff
fi

# Copy original data to temp dir
for SUBJ in `echo ${subj}`
do
	if [ ! -d ${tmpdir}/${SUBJ} ]
	then
		mkdir ${tmpdir}/${SUBJ}
		echo "cp -R ${fs}/${SUBJ}/${sname} ${tmpdir}/${SUBJ}/surf"
		cp -R ${fs}/${SUBJ}/${sname} ${tmpdir}/${SUBJ}/surf
		cp -R ${fs}/${SUBJ}/mri ${tmpdir}/${SUBJ}/
	else
		rm -rf ${tmpdir}/${SUBJ} 
		mkdir ${tmpdir}/${SUBJ}
		echo "cp -R ${fs}/${SUBJ}/${sname} ${tmpdir}/${SUBJ}/surf"
		cp -R ${fs}/${SUBJ}/${sname} ${tmpdir}/${SUBJ}/surf
		cp -R ${fs}/${SUBJ}/mri ${tmpdir}/${SUBJ}/
	fi
done


SUBJECTS_DIR=${tmpdir}

for SUBJ in `echo ${subj}`
do
	echo "mris_register -curv ${tmpdir}/${SUBJ}/surf/lh.sphere ${template} lh.sphere.reg -nosulc -inflated"
	mris_register -curv ${tmpdir}/${SUBJ}/surf/lh.sphere ${template} lh.sphere.reg -nosulc -inflated
	
	echo "cp -f ${tmpdir}/${SUBJ}/surf/lh.sphere.reg ${fs}/${SUBJ}/${sname}/lh.sphere.reg"
	cp -f ${tmpdir}/${SUBJ}/surf/lh.sphere.reg ${fs}/${SUBJ}/${sname}/lh.sphere.reg
done
