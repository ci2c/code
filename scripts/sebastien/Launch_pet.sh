#! /bin/bash

SD=/home/fatmike/sebastien/FS5.1

if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: Launch_pet.sh -subj <SUBJ_ID> -fwhm <FWHM>  -o <pet_dir>  -d <pet_dicom>"
	echo ""
	echo "  -subj                            : Subject ID "
	echo "  -fwhm <FWHM>                     : Set FWHM of surface kernel blur"
	echo "  -o                               : PET directory "
	echo "  -d                               : PET DICOM directory "
	echo ""
	echo "Usage: Launch_pet.sh -sd <SUBJCETS_DIR>  -subj <SUBJ_ID>  -fwhm <FWHM>  -d <pet_dicom>"
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
		echo "Usage: Launch_pet.sh -subj <SUBJ_ID> -fwhm <FWHM>  -o <pet_dir>  -d <pet_dicom>"
		echo ""
		echo "  -subj                            : Subject ID"
		echo "  -fwhm <FWHM>                     : Set FWHM of surface kernel blur"
		echo "  -o                               : PET directory "
		echo "  -d                               : PET DICOM directory " 
		echo ""
		echo "Usage: Launch_pet.sh -subj <SUBJ_ID>  -fwhm <FWHM>  -o <pet_dir>  -d <pet_dicom>"
		echo ""
		exit 1
		;;
	-subj)
		index=$[$index+1]
		eval SUBJ=\${$index}
		echo "Subj : $SUBJ"
		;;
	-fwhm)
		index=$[$index+1]
		eval FWHM=\${$index}
		echo "FWHM : $FWHM"
		;;
	-o)
		index=$[$index+1]
		eval PETDIR=\${$index}
		echo "PET directory : $PETDIR"
		;;
	-d)
		index=$[$index+1]
		eval DICOMDIR=\${$index}
		echo "PET DICOM directory : $DICOMDIR"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: PET_ProjectOnSurface.sh -sd <SUBJCETS_DIR>  -subj <SUBJ_ID> -fwhm <FWHM>  -o <pet_dir> "
		echo ""
		echo "  -sd                              : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subj                            : Subject ID"
		echo "  -fwhm <FWHM>                     : Set FWHM of surface kernel blur"
		echo "  -o                               : PET directory "
		echo ""
		echo "Usage: PET_ProjectOnSurface.sh -sd <SUBJCETS_DIR>  -subj <SUBJ_ID>  -fwhm <FWHM> "
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

mkdir ${SD}/${SUBJ}/${PETDIR}
mcverter -o ${SD}/${SUBJ}/${PETDIR} -f nifti -n -m BASE_3D_AC ${DICOMDIR}/*
mri_convert ${SD}/${SUBJ}/${PETDIR}/*.nii ${SD}/${SUBJ}/${PETDIR}/pet_las.nii --out_orientation LAS

PET_ProjectOnSurface.sh -sd ${SD} -subj ${SUBJ} -fwhm ${FWHM} -o ${PETDIR}

