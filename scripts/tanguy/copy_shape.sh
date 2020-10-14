SD=/home/lucie/memoire/
mkdir $SD/Shape
mkdir $SD/Shape/pallidum_left
mkdir $SD/Shape/pallidum_right
mkdir $SD/Shape/putamen_left
mkdir $SD/Shape/putamen_right
mkdir $SD/Shape/caudate_left
mkdir $SD/Shape/caudate_right

for class in DENOVO FAIRPARK TEMOINS PRESTIM
do
	class_prefix=${class,,}
	echo ""
	echo ""
	echo "copie des sujets $class"
	echo "" 
	echo "prefixe : $class_prefix"

	for subj in `ls $SD/$class`
	do
		if [ ! -d $SD/$class/$subj/FS/ROI_analyse/mROI_back ]
		then
			echo ""
			echo ""
			echo "pas de copie pour $class/$subj"
			echo ""
			echo ""
		else
			echo "cp -f $SD/$class/$subj/FS/ROI_analyse/mROI_back/*caudate_l*nii $SD/Shape/caudate_left/${class_prefix}.${subj}.caudate_l.nii"
			cp -f $SD/$class/$subj/FS/ROI_analyse/mROI_back/*caudate_l*nii $SD/Shape/caudate_left/${class_prefix}.${subj}.caudate_l.nii
			echo "cp -f $SD/$class/$subj/FS/ROI_analyse/mROI_back/*caudate_r*nii $SD/Shape/caudate_right/${class_prefix}.${subj}.caudate_r.nii"
			cp -f $SD/$class/$subj/FS/ROI_analyse/mROI_back/*caudate_r*nii $SD/Shape/caudate_right/${class_prefix}.${subj}.caudate_r.nii

			echo "cp -f $SD/$class/$subj/FS/ROI_analyse/mROI_back/*putamen_l*nii $SD/Shape/putamen_left/${class_prefix}.${subj}.putamen_l.nii"
			cp -f $SD/$class/$subj/FS/ROI_analyse/mROI_back/*putamen_l*nii $SD/Shape/putamen_left/${class_prefix}.${subj}.putamen_l.nii
			echo "cp -f $SD/$class/$subj/FS/ROI_analyse/mROI_back/*putamen_r*nii $SD/Shape/putamen_right/${class_prefix}.${subj}.putamen_r.nii"
			cp -f $SD/$class/$subj/FS/ROI_analyse/mROI_back/*putamen_r*nii $SD/Shape/putamen_right/${class_prefix}.${subj}.putamen_r.nii

			echo "cp -f $SD/$class/$subj/FS/ROI_analyse/mROI_back/*pallidum_l*nii $SD/Shape/pallidum_left/${class_prefix}.${subj}.pallidum_l.nii"
			cp -f $SD/$class/$subj/FS/ROI_analyse/mROI_back/*pallidum_l*nii $SD/Shape/pallidum_left/${class_prefix}.${subj}.pallidum_l.nii
			echo "cp -f $SD/$class/$subj/FS/ROI_analyse/mROI_back/*pallidum_r*nii $SD/Shape/pallidum_right/${class_prefix}.${subj}.pallidum_r.nii"
			cp -f $SD/$class/$subj/FS/ROI_analyse/mROI_back/*pallidum_r*nii $SD/Shape/pallidum_right/${class_prefix}.${subj}.pallidum_r.nii
		fi
	done
done



