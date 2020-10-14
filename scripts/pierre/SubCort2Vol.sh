#!/bin/bash

if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: SubCort2Vol.sh  -fs <FS_dir>  -sfile <Structure_file>  -annot <Annot_name>  -subj <subj1> <subj2> ... <subjN>  [-segvol <segmentation_vol>]"
	echo ""
	echo "  -fs <FS_dir>                       : Path to FS output directory (equivalent to SUBJECTS_DIR)"
	echo "  -sfile <Structure_file>            : Path to the file containing subcortical info. Must be a 2-column list. First column : Label ID; Second column : Label name"
	echo "  -annot <Annot_name>                : Name of the annotation file, i.e. my_parc.annot"
	echo "  -subj <subj1> <subj2> ...          : List of subjects to process"
	echo " "
	echo " Option :"
	echo "  -segvol <segmentation_vol>         : Segmentation to use. Default : aparc.a2009s+aseg.mgz"
	echo ""
	echo "Usage: SubCort2Vol.sh  -fs <FS_dir>  -sfile <Structure_file>  -annot <Annot_name>  -subj <subj1> <subj2> ... <subjN>  [-segvol <segmentation_vol>]"
	echo ""
	exit 1
fi


index=1
segvol=aparc.a2009s+aseg.mgz

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: SubCort2Vol.sh  -fs <FS_dir>  -sfile <Structure_file>  -annot <Annot_name>  -subj <subj1> <subj2> ... <subjN>  [-segvol <segmentation_vol>]"
		echo ""
		echo "  -fs <FS_dir>                       : Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -sfile <Structure_file>            : Path to the file containing subcortical info. Must be a 2-column list. First column : Label ID; Second column : Label name"
		echo "  -annot <Annot_name>                : Name of the annotation file, i.e. my_parc.annot"
		echo "  -subj <subj1> <subj2> ...          : List of subjects to process"
		echo " "
		echo " Option :"
		echo "  -segvol <segmentation_vol>         : Segmentation to use. Default : aparc.a2009s+aseg.mgz"
		echo ""
		echo "Usage: SubCort2Vol.sh  -fs <FS_dir>  -sfile <Structure_file>  -annot <Annot_name>  -subj <subj1> <subj2> ... <subjN>  [-segvol <segmentation_vol>]"
		echo ""
		exit 1
		;;
	-fs)
		fs=`expr $index + 1`
		eval fs=\${$fs}
		echo "|> FS_dir         : $fs"
		;;
	-sfile)
		sfile=`expr $index + 1`
		eval sfile=\${$sfile}
		echo "|> Structure file : $sfile"
		;;
	-subj)
		i=$[$index+1]
		eval infile=\${$i}
		subj=""
		while [ "$infile" != "-fs" -a "$infile" != "-sfile" -a "$infile" != "-tmpdir" -a "$infile" != "-annot" -a "$infile" != "-segvol" -a $i -le $# ]
		do
		 	subj="${subj} ${infile}"
		 	i=$[$i+1]
		 	eval infile=\${$i}
		done
		index=$[$i-1]
		echo "|> Subj           : $subj"
		;;
	-annot)
		annot=`expr $index + 1`
		eval annot=\${$annot}
		echo "|> Annot name     : $annot"
		;;
	-segvol)
		segvol=`expr $index + 1`
		eval segvol=\${$segvol}
		echo "|> Seg vol        : $segvol"
		;;
	-*)
		Temp=`expr $index`
		eval Temp=\${$Temp}
		echo "Unknown argument ${Temp}"
		echo ""
		echo "Usage: SubCort2Vol.sh  -fs <FS_dir>  -sfile <Structure_file>  -annot <Annot_name>  -subj <subj1> <subj2> ... <subjN>  [-segvol <segmentation_vol>]"
		echo ""
		echo "  -fs <FS_dir>                       : Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -sfile <Structure_file>            : Path to the file containing subcortical info. Must be a 2-column list. First column : Label ID; Second column : Label name"
		echo "  -annot <Annot_name>                : Name of the annotation file, i.e. my_parc.annot"
		echo "  -subj <subj1> <subj2> ...          : List of subjects to process"
		echo " "
		echo " Option :"
		echo "  -segvol <segmentation_vol>         : Segmentation to use. Default : aparc.a2009s+aseg.mgz"
		echo ""
		echo "Usage: SubCort2Vol.sh  -fs <FS_dir>  -sfile <Structure_file>  -annot <Annot_name>  -subj <subj1> <subj2> ... <subjN>  [-segvol <segmentation_vol>]"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

n_struct=`cat ${sfile} | wc -l`
annot_base=${annot%.annot}

# Loop on subjects & structures
for SUBJ in `echo ${subj}`
do
	DIR=${fs}/${SUBJ}
	i=1
	while [ $i -le ${n_struct} ]
	do
		# Get structure ID and name
		Line=`sed -n "${i}{p;q}" ${sfile}`
		sid=`echo ${Line} | awk  '{print $1}'`
		sname=`echo ${Line} | awk  '{print $2}'`
		
		# Extract ROI ribbon
		echo "mri_extract_label ${DIR}/mri/${segvol} ${sid} ${DIR}/${sname}/label.mgz"
		mri_extract_label ${DIR}/mri/${segvol} ${sid} ${DIR}/${sname}/label.mgz
		
		echo "mri_morphology ${DIR}/${sname}/label.mgz erode 1 ${DIR}/${sname}/label_erode.mgz"
		mri_morphology ${DIR}/${sname}/label.mgz erode 1 ${DIR}/${sname}/label_erode.mgz
		
		echo "mri_convert ${DIR}/${sname}/label.mgz ${DIR}/${sname}/label.nii --out_orientation RAS"
		mri_convert ${DIR}/${sname}/label.mgz ${DIR}/${sname}/label.nii --out_orientation RAS
		
		echo "mri_convert ${DIR}/${sname}/label_erode.mgz ${DIR}/${sname}/label_erode.nii --out_orientation RAS"
		mri_convert ${DIR}/${sname}/label_erode.mgz ${DIR}/${sname}/label_erode.nii --out_orientation RAS
		
		echo "fslmaths ${DIR}/${sname}/label.nii -sub ${DIR}/${sname}/label_erode.nii -bin ${DIR}/${sname}/label_ribbon"
		fslmaths ${DIR}/${sname}/label.nii -sub ${DIR}/${sname}/label_erode.nii -bin ${DIR}/${sname}/label_ribbon
		
		gunzip -f ${DIR}/${sname}/label_ribbon.nii.gz
		rm -f ${DIR}/${sname}/label.mgz ${DIR}/${sname}/label_erode.mgz ${DIR}/${sname}/label.nii ${DIR}/${sname}/label_erode.nii
		
		# Launch matlab
echo ">> subcort_surf_to_vol(${DIR}/${sname}/label_ribbon.nii, ${DIR}/${sname}/${annot_base}.nii, ${DIR}/${sname}/lh.orig, ${DIR}/${sname}/lh.${annot}, ${DIR}/${sname}/${annot_base}.ctab);"
matlab -nodisplay <<EOF
subcort_surf_to_vol('${DIR}/${sname}/label_ribbon.nii', '${DIR}/${sname}/${annot_base}.nii', '${DIR}/${sname}/lh.orig', '${DIR}/${sname}/lh.${annot}', '${DIR}/${sname}/${annot_base}.ctab');
EOF
		
		i=$[$i+1]
	done
done

