#!/bin/bash

if [ $# -lt 7 ]
then
	echo ""
	echo "Usage: SubCortTemplate.sh  -fs <FS_dir>  -sname <Struct_name>  -subj <subj1> <subj2> ... <subjN>  [-tmpdir <temp_dir>  -ite <N_ite>]"
	echo ""
	echo "  -fs <FS_dir>                       : Path to FS output directory (equivalent to SUBJECTS_DIR)"
	echo "  -sname <Struct_name>               : Name of the subcortical structure"
	echo "  -subj <subj1> <subj2> ...          : List of subjects to use for the template"
	echo " "
	echo " Option :"
	echo "  -tmpdir <temp_dir>                 : Path to directory for temp calculations. Default : /tmp/"
	echo "  -ite <N_ite>                       : Number of non-linear registration steps. Default : 5"
	echo ""
	echo "Usage: SubCortTemplate.sh  -fs <FS_dir>  -sname <Struct_name>  -subj <subj1> <subj2> ... <subjN>  [-tmpdir <temp_dir>  -ite <N_ite>]"
	echo ""
	exit 1
fi


index=1
ite=5
tmpdir=/tmp/

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: SubCortTemplate.sh  -fs <FS_dir>  -sname <Struct_name>  -subj <subj1> <subj2> ... <subjN>  [-tmpdir <temp_dir>  -ite <N_ite>]"
		echo ""
		echo "  -fs <FS_dir>                       : Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -sname <Struct_name>               : Name of the subcortical structure"
		echo "  -subj <subj1> <subj2> ...          : List of subjects to use for the template"
		echo " "
		echo " Option :"
		echo "  -tmpdir <temp_dir>                 : Path to directory for temp calculations. Default : /tmp/"
		echo "  -ite <N_ite>                       : Number of non-linear registration steps. Default : 5"
		echo ""
		echo "Usage: SubCortTemplate.sh  -fs <FS_dir>  -sname <Struct_name>  -subj <subj1> <subj2> ... <subjN>  [-tmpdir <temp_dir>  -ite <N_ite>]"
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
		while [ "$infile" != "-fs" -a "$infile" != "-sname" -a "$infile" != "-tmpdir" -a "$infile" != "-ite" -a $i -le $# ]
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
	-ite)
		ite=`expr $index + 1`
		eval ite=\${$ite}
		echo "|> Iterations     : $ite"
		;;
	-*)
		Temp=`expr $index`
		eval Temp=\${$Temp}
		echo "Unknown argument ${Temp}"
		echo ""
		echo "Usage: SubCortTemplate.sh  -fs <FS_dir>  -sname <Struct_name>  -subj <subj1> <subj2> ... <subjN>  [-tmpdir <temp_dir>  -ite <N_ite>]"
		echo ""
		echo "  -fs <FS_dir>                       : Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -sname <Struct_name>               : Name of the subcortical structure"
		echo "  -subj <subj1> <subj2> ...          : List of subjects to use for the template"
		echo " "
		echo " Option :"
		echo "  -tmpdir <temp_dir>                 : Path to directory for temp calculations. Default : /tmp/"
		echo "  -ite <N_ite>                       : Number of non-linear registration steps. Default : 5"
		echo ""
		echo "Usage: SubCortTemplate.sh  -fs <FS_dir>  -sname <Struct_name>  -subj <subj1> <subj2> ... <subjN>  [-tmpdir <temp_dir>  -ite <N_ite>]"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

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

# Create template dir
if [ ! -d ${tmpdir}/${sname} ]
then
	mkdir ${tmpdir}/${sname}
else
	rm -rf ${tmpdir}/${sname}
	mkdir ${tmpdir}/${sname}
fi
templatedir=${tmpdir}/${sname}

# Use first subject as initial template
first_subj=`echo ${subj} | awk  '{print $1}'`
mris_make_template lh sphere ${first_subj} ${templatedir}/template_0.tiff

# Iterate the template
previous=0
iteration=1
while [ ${iteration} -le ${ite} ]
do
	for SUBJ in `echo ${subj}`
	do
		if [ ${iteration} -eq 1 ]
		then
			echo "mris_register -curv ${tmpdir}/${SUBJ}/surf/lh.sphere ${templatedir}/template_${previous}.tiff lh.sphere.reg${previous} -1 -nosulc -inflated"
			mris_register -curv ${tmpdir}/${SUBJ}/surf/lh.sphere ${templatedir}/template_${previous}.tiff lh.sphere.reg${previous} -1 -nosulc -inflated # Added nosulc & inflated
		else
			echo "mris_register -curv ${tmpdir}/${SUBJ}/surf/lh.sphere ${templatedir}/template_${previous}.tiff lh.sphere.reg${previous} -nosulc -inflated"
			mris_register -curv ${tmpdir}/${SUBJ}/surf/lh.sphere ${templatedir}/template_${previous}.tiff lh.sphere.reg${previous} -nosulc -inflated # Added nosulc & inflated
		fi
		sleep 1
	done
	
	mris_make_template lh sphere.reg${previous} ${subj} ${templatedir}/template_${iteration}.tiff
	
	previous=${iteration}
	iteration=$[${iteration}+1]
done

mkdir ${templatedir}/surf

previous=$[${ite}-1]

# Make average surface
echo "mris_make_average_surface -s smoothwm lh white sphere.reg${previous} ${sname} ${subj}"
mris_make_average_surface -s smoothwm lh white sphere.reg${previous} ${sname} ${subj}

# Copy template data back to the original path
if [ ! -d ${fs}/${sname} ]
then
	rm -rf ${fs}/${sname}
	echo "cp -Rf ${templatedir} ${fs}/${sname}"
	cp -Rf ${templatedir} ${fs}/${sname}
else
	echo "cp -Rf ${templatedir} ${fs}/${sname}"
	cp -Rf ${templatedir} ${fs}/${sname}
fi

for SUBJ in `echo ${subj}`
do
	echo "cp -f ${tmpdir}/${SUBJ}/surf/lh.sphere.reg${previous} ${fs}/${SUBJ}/${sname}/lh.sphere.reg"
	cp -f ${tmpdir}/${SUBJ}/surf/lh.sphere.reg${previous} ${fs}/${SUBJ}/${sname}/lh.sphere.reg
done

# Smooth final template
cd ${fs}/${sname}/surf
mris_smooth lh.white lh.smoothwm
mris_smooth lh.smoothwm lh.smoothwm2
mris_inflate lh.smoothwm lh.inflated
cp lh.smoothwm2 lh.pial
mv lh.sphere.reg${previous} lh.sphere.reg

