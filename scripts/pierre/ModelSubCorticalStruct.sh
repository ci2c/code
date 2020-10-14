#!/bin/bash

if [ $# -lt 6 ]
then
	echo ""
	echo "Usage: ModelSubCorticalStruct.sh  -fs <fs_dir>  -subj <subj_id>  -sfile <structure_name>  [-tmp <temp_dir>  -segvol <segmentation_volume>  -res <resolution>  -close <nb_close>  -clobber]"
	echo ""
	echo "  -fs <fs_dir>                         : Path to Freesurfer outdir, i.e. SUBJECTS_DIR"
	echo "  -subj <subj_id>                      : Subject ID"
	echo "  -sfile <structure_name>              : Path to the file containing subcortical info. Must be a 2-column list. First column : Label ID; Second column : Label name"
	echo ""
	echo "Options :"
	echo "  -tmp <temp_dir>                      : Path to directory for temp computations. Default = /tmp/"
	echo "  -segvol <segmentation_volume>        : Segmentation to use. Default = aparc.a2009s+aseg.mgz"
	echo "  -resolution <resolution>             : Image isotropic resolution (in  mm) for intermediate calculations. Default = 1"
	echo "  -close <nb_close>                    : Size of the close operator for label morphological operation. Default = 2"
	echo "  -clobber                             : Overwrite output files. Default : Don't overwrite"
	echo " "
	echo "Usage: ModelSubCorticalStruct.sh  -fs <fs_dir>  -subj <subj_id>  -sfile <structure_name>  [-tmp <temp_dir>  -segvol <segmentation_volume>  -res <resolution>  -close <nb_close>  -clobber]"
	echo ""
	exit 1
fi

index=1
imres=1
tmpdir=/tmp/
segvol="aparc.a2009s+aseg.mgz"
volres=1
nb_close=2
clobber=0

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: ModelSubCorticalStruct.sh  -fs <fs_dir>  -subj <subj_id>  -sfile <structure_name>  [-tmp <temp_dir>  -segvol <segmentation_volume>  -res <resolution>  -close <nb_close>  -clobber]"
		echo ""
		echo "  -fs <fs_dir>                         : Path to Freesurfer outdir, i.e. SUBJECTS_DIR"
		echo "  -subj <subj_id>                      : Subject ID"
		echo "  -sfile <structure_name>              : Path to the file containing subcortical info. Must be a 2-column list. First column : Label ID; Second column : Label name"
		echo ""
		echo "Options :"
		echo "  -tmp <temp_dir>                      : Path to directory for temp computations. Default = /tmp/"
		echo "  -segvol <segmentation_volume>        : Segmentation to use. Default = aparc.a2009s+aseg.mgz"
		echo "  -resolution <resolution>             : Image isotropic resolution (in  mm) for intermediate calculations. Default = 1"
		echo "  -close <nb_close>                    : Size of the close operator for label morphological operation. Default = 2"
		echo "  -clobber                             : Overwrite output files. Default : Don't overwrite"
		echo " "
		echo "Usage: ModelSubCorticalStruct.sh  -fs <fs_dir>  -subj <subj_id>  -sfile <structure_name>  [-tmp <temp_dir>  -segvol <segmentation_volume>  -res <resolution>  -close <nb_close>  -clobber]"
		echo ""
		exit 1
		;;
	-fs)
		fs=`expr $index + 1`
		eval fs=\${$fs}
		echo "|> FS dir           : $fs"
		;;
	-subj)
		subj=`expr $index + 1`
		eval subj=\${$subj}
		echo "|> Subject          : $subj"
		;;
	-sfile)
		sfile=`expr $index + 1`
		eval sfile=\${$sfile}
		echo "|> Structure file   : $sfile"
		;;
	-tmp)
		tmpdir=`expr $index + 1`
		eval tmpdir=\${$tmpdir}
		echo "|> Temp dir         : $tmpdir"
		;;
	-res)
		volres=`expr $index + 1`
		eval volres=\${$volres}
		echo "|> Image resolution  : $volres"
		;;
	-close)
		nb_close=`expr $index + 1`
		eval nb_close=\${$nb_close}
		echo "|> Close operations  : $nb_close"
		;;
	-segvol)
		segvol=`expr $index + 1`
		eval segvol=\${$segvol}
		echo "|> Segmentation vol. : $segvol"
		;;
	-clobber)
		clobber=1
		echo "|> Clobber           : $clobber"
		;;
	-*)
		Arg=`expr $index`
		eval Arg=\${$Arg}
		echo "Unknown argument ${Arg}"
		echo ""
		echo "Usage: ModelSubCorticalStruct.sh  -fs <fs_dir>  -subj <subj_id>  -sfile <structure_name>  [-tmp <temp_dir>  -segvol <segmentation_volume>  -res <resolution>  -close <nb_close>  -clobber]"
		echo ""
		echo "  -fs <fs_dir>                         : Path to Freesurfer outdir, i.e. SUBJECTS_DIR"
		echo "  -subj <subj_id>                      : Subject ID"
		echo "  -sfile <structure_name>              : Path to the file containing subcortical info. Must be a 2-column list. First column : Label ID; Second column : Label name"
		echo ""
		echo "Options :"
		echo "  -tmp <temp_dir>                      : Path to directory for temp computations. Default = /tmp/"
		echo "  -segvol <segmentation_volume>        : Segmentation to use. Default = aparc.a2009s+aseg.mgz"
		echo "  -resolution <resolution>             : Image isotropic resolution (in  mm) for intermediate calculations. Default = 1"
		echo "  -close <nb_close>                    : Size of the close operator for label morphological operation. Default = 2"
		echo "  -clobber                             : Overwrite output files. Default : Don't overwrite"
		echo " "
		echo "Usage: ModelSubCorticalStruct.sh  -fs <fs_dir>  -subj <subj_id>  -sfile <structure_name>  [-tmp <temp_dir>  -segvol <segmentation_volume>  -res <resolution>  -close <nb_close>  -clobber]"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

n_struct=`cat ${sfile} | wc -l`
i=1

while [ $i -le ${n_struct} ]
do
	Line=`sed -n "${i}{p;q}" ${sfile}`
	sid=`echo ${Line} | awk  '{print $1}'`
	sname=`echo ${Line} | awk  '{print $2}'`
	
	if [ ! -e ${fs}/${subj}/${sname}/lh.sphere -o ${clobber} -eq 1 ]
	then
		echo "ModelOneROI_SPHARM.sh  -fs ${fs}  -subj ${subj}  -sname ${sname}  -sid ${sid}  -tmp ${tmpdir}  -segvol ${segvol}  -res ${volres}"
		ModelOneROI_SPHARM.sh  -fs ${fs}  -subj ${subj}  -sname ${sname}  -sid ${sid}  -tmp ${tmpdir}  -segvol ${segvol}  -res ${volres}
	else
		echo "${sname} already processed"
	fi
	i=$[$i+1]
done
