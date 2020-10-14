#!/bin/bash

if [ $# -lt 17 ]
then
	echo ""
	echo "Usage: Make_montage.sh  -fs  <SubjDir>  -subj  <SubjName>  -surf <Surface>  -lhoverlay <Overlay>  -rhoverlay <Overlay>  -fminmax <MIN> <MAX>  -fmid <MID>  -output <outname.tiff>  [-template -axial]"
	echo ""
	echo "  -fs SubjDir                  : Path to FS output directory (equivalent to SUBJECTS_DIR)"
	echo "  -subj SubjName               : Subject ID"
	echo "  -surf Surface                : Surface to display (white, pial or inflated)"
	echo "  -lhoverlay Overlay           : Name of the left overlay to display (example : lh.fwhm5.thickness.mgh)"
	echo "  -rhoverlay Overlay           : Name of the right overlay to display (example : rh.fwhm5.thickness.mgh)"
	echo "  -fminmax MIN MAX             : Min and Max of the overlay display"
	echo "  -fmid MID                    : set the overlay threshold midpoint value"
	echo "  -output outname.tiff         : Name of the output image"
	echo " "
	echo " Option :"
	echo "  -template                    : Use template surfaces (fsaverage) for display. Default : auto-guess"
	echo "  -template5                   : Use template surfaces (fsaverage5) for display. Default : auto-guess"
	echo "  -axial                       : Add axial views"
	echo ""
	echo "Usage: Make_montage.sh  -fs  <SubjDir>  -subj  <SubjName>  -surf <Surface>  -lhoverlay <Overlay>  -rhoverlay <Overlay>  -fminmax <MIN> <MAX>  -output <outname.tiff>  [-template -axial]"
	exit 1
fi


#### Inputs ####
template_flag=0
template5_flag=0
axial_flag=0
index=1
echo "------------------------"

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: Make_montage.sh  -fs  <SubjDir>  -subj  <SubjName>  -surf <Surface>  -lhoverlay <Overlay>  -rhoverlay <Overlay>  -fminmax <MIN> <MAX>  -fmid <MID>  -output <outname.tiff>  [-template -axial]"
		echo ""
		echo "  -fs SubjDir                  : Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -subj SubjName               : Subject ID"
		echo "  -surf Surface                : Surface to display (white, pial or inflated)"
		echo "  -lhoverlay Overlay           : Name of the left overlay to display (example : lh.fwhm5.thickness.mgh)"
		echo "  -rhoverlay Overlay           : Name of the right overlay to display (example : rh.fwhm5.thickness.mgh)"
		echo "  -fminmax MIN MAX             : Min and Max of the overlay display"
		echo "  -fmid MID                    : set the overlay threshold midpoint value"
		echo "  -output outname.tiff         : Name of the output image"
		echo " "
		echo " Option :"
		echo "  -template                    : Use template surfaces (fsaverage) for display. Default : auto-guess"
		echo "  -template5                   : Use template surfaces (fsaverage5) for display. Default : auto-guess"
		echo "  -axial                       : Add axial views"
		echo ""
		echo "Usage: Make_montage.sh  -fs  <SubjDir>  -subj  <SubjName>  -surf <Surface>  -lhoverlay <Overlay>  -rhoverlay <Overlay>  -fminmax <MIN> <MAX>  -fmid <MID>  -output <outname.tiff>  [-template -axial]"
		exit 1
		;;
	-fs)
		fs=`expr $index + 1`
		eval fs=\${$fs}
		echo "  |-------> SubjDir : $fs"
		index=$[$index+1]
		;;
	-lhoverlay)
		lhoverlay=`expr $index + 1`
		eval lhoverlay=\${$lhoverlay}
		echo "  |-------> Overlay Name : ${lhoverlay}"
		index=$[$index+1]
		;;
	-rhoverlay)
		rhoverlay=`expr $index + 1`
		eval rhoverlay=\${$rhoverlay}
		echo "  |-------> Overlay Name : ${rhoverlay}"
		index=$[$index+1]
		;;
	-subj)
		subj=`expr $index + 1`
		eval subj=\${$subj}
		echo "  |-------> Subject Name : ${subj}"
		index=$[$index+1]
		;;
	-fminmax)
		fminmax=`expr $index + 1`
		eval MIN=\${$fminmax}
		index=$[$index+1]
		fminmax=`expr $index + 1`
		eval MAX=\${$fminmax}
		echo "  |-------> fminmax : ${MIN} to ${MAX}"
		index=$[$index+1]
		;;
	-fmid)
		fmid=`expr $index + 1`
		eval MID=\${$fmid}
		echo "  |-------> fmid : ${MID}"
		index=$[$index+1]
		;;
	-output)
		output=`expr $index + 1`
		eval output=\${$output}
		echo "  |-------> Output directory : ${output}"
		index=$[$index+1]
		;;
	-template)
		template_flag=1
		echo "  |-------> Use template surface"
		#index=$[$index+1]
		;;
	-template5)
		template5_flag=1
		echo "  |-------> Use template surface (fsaverage5)"
		#index=$[$index+1]
		;;
	-axial)
		axial_flag=1
		echo "  |-------> Add axial views"
		#index=$[$index+1]
		;;
	-surf)
		surf=`expr $index + 1`
		eval surf=\${$surf}
		echo "  |-------> Surface : ${surf}"
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
#################

echo "axial flag: ${axial_flag}"

SUBJECTS_DIR=${fs}

# Auto guess whether to use the template surface or not
is_fsaverage=`echo ${overlay} | grep fsaverage`
if [ -n "${is_fsaverage}" ]
then
	template_flag=1
	echo "Auto-guess found that the overlay must be displayed on template surface"
fi

# Auto guess whether to use the template surface or not
is_fsaverage5=`echo ${overlay} | grep fsaverage5`
if [ -n "${is_fsaverage5}" ]
then
	template5_flag=1
	echo "Auto-guess found that the overlay must be displayed on template surface"
fi

# Auto set surface if not provided
if [ ! -n ${surf} ]
then
	surf=white
fi

# Check other arguments
if [ ! -n ${fs} ]
then
	echo "-fs option must be provided"
	exit 1
fi

if [ ! -n ${subj} ]
then
	echo "-subj option must be provided"
	exit 1
fi

if [ ! -n ${lhoverlay} ]
then
	echo "-lhoverlay option must be provided"
	exit 1
fi

if [ ! -n ${rhoverlay} ]
then
	echo "-rhoverlay option must be provided"
	exit 1
fi

if [ ! -n ${MIN}  ]
then
	echo "-fminmax option must have 2 arguments"
	exit 1
fi

if [ ! -n ${MAX}  ]
then
	echo "-fminmax option must have 2 arguments"
	exit 1
fi

if [ ! -n ${output}  ]
then
	echo "-output option must be provided"
	exit 1
fi

# Create outdir if needed
outdir=`dirname ${output}`
if [ ! -d ${outdir} ]
then
	mkdir ${outdir}
fi

# Create a temp dir within outdir
mkdir ${outdir}/temp_$$
temp=${outdir}/temp_$$

# Find the overlay file
# Path_lh=`find ${fs}/${subj} -name l*${overlay}`
# Path_rh=`find ${fs}/${subj} -name r*${overlay}`
Path_lh=${lhoverlay}
Path_rh=${rhoverlay}


if [ ${template_flag} -eq 0 ]
then
	echo "translate_brain_y -40" > ${temp}/view1-2.tcl
	echo "redraw" >> ${temp}/view1-2.tcl
	echo "save_tiff ${temp}/view1.tiff" >> ${temp}/view1-2.tcl
	echo "rotate_brain_y 180" >> ${temp}/view1-2.tcl
	echo "redraw" >> ${temp}/view1-2.tcl
	echo "save_tiff ${temp}/view2.tiff" >> ${temp}/view1-2.tcl
	echo "exit" >> ${temp}/view1-2.tcl
	tksurfer ${subj} lh ${surf} -overlay ${Path_lh} -fminmax ${MIN} ${MAX} -fmid ${MID} -tcl ${temp}/view1-2.tcl
	echo "translate_brain_y -40" > ${temp}/view3.tcl
	echo "rotate_brain_y 180" >> ${temp}/view3.tcl
	echo "redraw" >> ${temp}/view3.tcl
	echo "save_tiff ${temp}/view3.tiff" >> ${temp}/view3.tcl
	echo "exit" >> ${temp}/view3.tcl
	tksurfer ${subj} rh ${surf} -overlay ${Path_rh} -fminmax ${MIN} ${MAX} -fmid ${MID} -tcl ${temp}/view3.tcl
	echo "translate_brain_y -40" > ${temp}/view4.tcl
	echo "redraw" >> ${temp}/view4.tcl
	echo "save_tiff ${temp}/view4.tiff" >> ${temp}/view4.tcl
	echo "exit" >> ${temp}/view4.tcl
	tksurfer ${subj} rh ${surf} -overlay ${Path_rh} -fminmax ${MIN} ${MAX} -fmid ${MID} -tcl ${temp}/view4.tcl -colscalebarflag 0
	convert -crop 500x400+50+200 ${temp}/view1.tiff ${temp}/view1_crop.tiff
	convert -crop 500x400+50+200 ${temp}/view2.tiff ${temp}/view2_crop.tiff
	convert -crop 500x400+50+200 ${temp}/view3.tiff ${temp}/view3_crop.tiff
	convert -crop 550x400+50+200 ${temp}/view4.tiff ${temp}/view4_crop.tiff
	if [ ${axial_flag} -eq 0 ]
	then
		montage -tile 4x1 -mode Concatenate ${temp}/view1_crop.tiff ${temp}/view2_crop.tiff ${temp}/view3_crop.tiff ${temp}/view4_crop.tiff ${output}
	else
		echo "rotate_brain_y -90" > ${temp}/axial1.tcl
		echo "rotate_brain_x 90" >> ${temp}/axial1.tcl
		echo "redraw" >> ${temp}/axial1.tcl
		echo "save_tiff ${temp}/view_axial1.tiff" >> ${temp}/axial1.tcl
		echo "exit" >> ${temp}/axial1.tcl
		tksurfer ${subj} lh ${surf} -overlay ${Path_lh} -fminmax ${MIN} ${MAX} -fmid ${MID} -tcl ${temp}/axial1.tcl
		
		echo "rotate_brain_y 90" > ${temp}/axial2.tcl
		echo "rotate_brain_x 90" >> ${temp}/axial2.tcl
		echo "redraw" >> ${temp}/axial2.tcl
		echo "save_tiff ${temp}/view_axial2.tiff" >> ${temp}/axial2.tcl
		echo "exit" >> ${temp}/axial2.tcl
		tksurfer ${subj} rh ${surf} -overlay ${Path_rh} -fminmax ${MIN} ${MAX} -fmid ${MID} -tcl ${temp}/axial2.tcl
		
		echo "rotate_brain_y 90" > ${temp}/axial3.tcl
		echo "rotate_brain_x -90" >> ${temp}/axial3.tcl
		echo "redraw" >> ${temp}/axial3.tcl
		echo "save_tiff ${temp}/view_axial3.tiff" >> ${temp}/axial3.tcl
		echo "exit" >> ${temp}/axial3.tcl
		tksurfer ${subj} lh ${surf} -overlay ${Path_lh} -fminmax ${MIN} ${MAX} -fmid ${MID} -tcl ${temp}/axial3.tcl
		
		echo "rotate_brain_y -90" > ${temp}/axial4.tcl
		echo "rotate_brain_x -90" >> ${temp}/axial4.tcl
		echo "redraw" >> ${temp}/axial4.tcl
		echo "save_tiff ${temp}/view_axial4.tiff" >> ${temp}/axial4.tcl
		echo "exit" >> ${temp}/axial4.tcl
		tksurfer ${subj} rh ${surf} -overlay ${Path_rh} -fminmax ${MIN} ${MAX} -fmid ${MID} -tcl ${temp}/axial4.tcl
		
		convert -crop 160x400+225+100 ${temp}/view_axial1.tiff ${temp}/view_axial1_crop.tiff
		convert -crop 160x400+215+100 ${temp}/view_axial2.tiff ${temp}/view_axial2_crop.tiff
		convert -crop 160x400+215+100 ${temp}/view_axial3.tiff ${temp}/view_axial3_crop.tiff
		convert -crop 160x400+215+100 ${temp}/view_axial4.tiff ${temp}/view_axial4_crop.tiff
		#montage -tile 6x1 -mode Concatenate ${temp}/view1_crop.tiff ${temp}/view2_crop.tiff ${temp}/view_axial2_crop.tiff ${temp}/view_axial1_crop.tiff ${temp}/view3_crop.tiff ${temp}/view4_crop.tiff ${output}
		montage -tile 8x1 -mode Concatenate ${temp}/view1_crop.tiff ${temp}/view2_crop.tiff ${temp}/view_axial3_crop.tiff ${temp}/view_axial4_crop.tiff ${temp}/view_axial2_crop.tiff ${temp}/view_axial1_crop.tiff ${temp}/view3_crop.tiff ${temp}/view4_crop.tiff ${output}
	fi
	rm -rf ${temp}
elif [ ${template_flag} -eq 1 ]
then
	echo "translate_brain_y -40" > ${temp}/view1-2.tcl
	echo "redraw" >> ${temp}/view1-2.tcl
	echo "save_tiff ${temp}/view1.tiff" >> ${temp}/view1-2.tcl
	echo "rotate_brain_y 180" >> ${temp}/view1-2.tcl
	echo "redraw" >> ${temp}/view1-2.tcl
	echo "save_tiff ${temp}/view2.tiff" >> ${temp}/view1-2.tcl
	echo "exit" >> ${temp}/view1-2.tcl
	tksurfer fsaverage lh ${surf} -overlay ${Path_lh} -fminmax ${MIN} ${MAX} -fmid ${MID} -tcl ${temp}/view1-2.tcl
	echo "translate_brain_y -40" > ${temp}/view3.tcl
	echo "rotate_brain_y 180" >> ${temp}/view3.tcl
	echo "redraw" >> ${temp}/view3.tcl
	echo "save_tiff ${temp}/view3.tiff" >> ${temp}/view3.tcl
	echo "exit" >> ${temp}/view3.tcl
	tksurfer fsaverage rh ${surf} -overlay ${Path_rh} -fminmax ${MIN} ${MAX} -fmid ${MID} -tcl ${temp}/view3.tcl
	echo "translate_brain_y -40" > ${temp}/view4.tcl
	echo "redraw" >> ${temp}/view4.tcl
	echo "save_tiff ${temp}/view4.tiff" >> ${temp}/view4.tcl
	echo "exit" >> ${temp}/view4.tcl
	tksurfer fsaverage rh ${surf} -overlay ${Path_rh} -fminmax ${MIN} ${MAX} -fmid ${MID} -tcl ${temp}/view4.tcl -colscalebarflag 0
	convert -crop 500x400+50+200 ${temp}/view1.tiff ${temp}/view1_crop.tiff
	convert -crop 500x400+50+200 ${temp}/view2.tiff ${temp}/view2_crop.tiff
	convert -crop 500x400+50+200 ${temp}/view3.tiff ${temp}/view3_crop.tiff
	convert -crop 550x400+50+200 ${temp}/view4.tiff ${temp}/view4_crop.tiff
	if [ ${axial_flag} -eq 0 ]
	then
		montage -tile 4x1 -mode Concatenate ${temp}/view1_crop.tiff ${temp}/view2_crop.tiff ${temp}/view3_crop.tiff ${temp}/view4_crop.tiff ${output}
	else
		echo "rotate_brain_y -90" > ${temp}/axial1.tcl
		echo "rotate_brain_x 90" >> ${temp}/axial1.tcl
		echo "redraw" >> ${temp}/axial1.tcl
		echo "save_tiff ${temp}/view_axial1.tiff" >> ${temp}/axial1.tcl
		echo "exit" >> ${temp}/axial1.tcl
		tksurfer fsaverage lh ${surf} -overlay ${Path_lh} -fminmax ${MIN} ${MAX} -fmid ${MID} -tcl ${temp}/axial1.tcl
		
		echo "rotate_brain_y 90" > ${temp}/axial2.tcl
		echo "rotate_brain_x 90" >> ${temp}/axial2.tcl
		echo "redraw" >> ${temp}/axial2.tcl
		echo "save_tiff ${temp}/view_axial2.tiff" >> ${temp}/axial2.tcl
		echo "exit" >> ${temp}/axial2.tcl
		tksurfer fsaverage rh ${surf} -overlay ${Path_rh} -fminmax ${MIN} ${MAX} -fmid ${MID} -tcl ${temp}/axial2.tcl
		
		echo "rotate_brain_y 90" > ${temp}/axial3.tcl
		echo "rotate_brain_x -90" >> ${temp}/axial3.tcl
		echo "redraw" >> ${temp}/axial3.tcl
		echo "save_tiff ${temp}/view_axial3.tiff" >> ${temp}/axial3.tcl
		echo "exit" >> ${temp}/axial3.tcl
		tksurfer fsaverage lh ${surf} -overlay ${Path_lh} -fminmax ${MIN} ${MAX} -fmid ${MID} -tcl ${temp}/axial3.tcl
		
		echo "rotate_brain_y -90" > ${temp}/axial4.tcl
		echo "rotate_brain_x -90" >> ${temp}/axial4.tcl
		echo "redraw" >> ${temp}/axial4.tcl
		echo "save_tiff ${temp}/view_axial4.tiff" >> ${temp}/axial4.tcl
		echo "exit" >> ${temp}/axial4.tcl
		tksurfer fsaverage rh ${surf} -overlay ${Path_rh} -fminmax ${MIN} ${MAX} -fmid ${MID} -tcl ${temp}/axial4.tcl
		
		convert -crop 160x400+225+100 ${temp}/view_axial1.tiff ${temp}/view_axial1_crop.tiff
		convert -crop 160x400+215+100 ${temp}/view_axial2.tiff ${temp}/view_axial2_crop.tiff
		convert -crop 160x400+215+100 ${temp}/view_axial3.tiff ${temp}/view_axial3_crop.tiff
		convert -crop 160x400+215+100 ${temp}/view_axial4.tiff ${temp}/view_axial4_crop.tiff
		#montage -tile 6x1 -mode Concatenate ${temp}/view1_crop.tiff ${temp}/view2_crop.tiff ${temp}/view_axial2_crop.tiff ${temp}/view_axial1_crop.tiff ${temp}/view3_crop.tiff ${temp}/view4_crop.tiff ${output}
		montage -tile 8x1 -mode Concatenate ${temp}/view1_crop.tiff ${temp}/view2_crop.tiff ${temp}/view_axial3_crop.tiff ${temp}/view_axial4_crop.tiff ${temp}/view_axial2_crop.tiff ${temp}/view_axial1_crop.tiff ${temp}/view3_crop.tiff ${temp}/view4_crop.tiff ${output}
	fi
	rm -rf ${temp}
else
	echo "translate_brain_y -40" > ${temp}/view1-2.tcl
	echo "redraw" >> ${temp}/view1-2.tcl
	echo "save_tiff ${temp}/view1.tiff" >> ${temp}/view1-2.tcl
	echo "rotate_brain_y 180" >> ${temp}/view1-2.tcl
	echo "redraw" >> ${temp}/view1-2.tcl
	echo "save_tiff ${temp}/view2.tiff" >> ${temp}/view1-2.tcl
	echo "exit" >> ${temp}/view1-2.tcl
	tksurfer fsaverage5 lh ${surf} -overlay ${Path_lh} -fminmax ${MIN} ${MAX} -fmid ${MID} -tcl ${temp}/view1-2.tcl
	echo "translate_brain_y -40" > ${temp}/view3.tcl
	echo "rotate_brain_y 180" >> ${temp}/view3.tcl
	echo "redraw" >> ${temp}/view3.tcl
	echo "save_tiff ${temp}/view3.tiff" >> ${temp}/view3.tcl
	echo "exit" >> ${temp}/view3.tcl
	tksurfer fsaverage5 rh ${surf} -overlay ${Path_rh} -fminmax ${MIN} ${MAX} -fmid ${MID} -tcl ${temp}/view3.tcl
	echo "translate_brain_y -40" > ${temp}/view4.tcl
	echo "redraw" >> ${temp}/view4.tcl
	echo "save_tiff ${temp}/view4.tiff" >> ${temp}/view4.tcl
	echo "exit" >> ${temp}/view4.tcl
	tksurfer fsaverage5 rh ${surf} -overlay ${Path_rh} -fminmax ${MIN} ${MAX} -fmid ${MID} -tcl ${temp}/view4.tcl -colscalebarflag 0
	convert -crop 500x400+50+200 ${temp}/view1.tiff ${temp}/view1_crop.tiff
	convert -crop 500x400+50+200 ${temp}/view2.tiff ${temp}/view2_crop.tiff
	convert -crop 500x400+50+200 ${temp}/view3.tiff ${temp}/view3_crop.tiff
	convert -crop 550x400+50+200 ${temp}/view4.tiff ${temp}/view4_crop.tiff
	if [ ${axial_flag} -eq 0 ]
	then
		montage -tile 4x1 -mode Concatenate ${temp}/view1_crop.tiff ${temp}/view2_crop.tiff ${temp}/view3_crop.tiff ${temp}/view4_crop.tiff ${output}
	else
		echo "rotate_brain_y -90" > ${temp}/axial1.tcl
		echo "rotate_brain_x 90" >> ${temp}/axial1.tcl
		echo "redraw" >> ${temp}/axial1.tcl
		echo "save_tiff ${temp}/view_axial1.tiff" >> ${temp}/axial1.tcl
		echo "exit" >> ${temp}/axial1.tcl
		tksurfer fsaverage5 lh ${surf} -overlay ${Path_lh} -fminmax ${MIN} ${MAX} -fmid ${MID} -tcl ${temp}/axial1.tcl
		
		echo "rotate_brain_y 90" > ${temp}/axial2.tcl
		echo "rotate_brain_x 90" >> ${temp}/axial2.tcl
		echo "redraw" >> ${temp}/axial2.tcl
		echo "save_tiff ${temp}/view_axial2.tiff" >> ${temp}/axial2.tcl
		echo "exit" >> ${temp}/axial2.tcl
		tksurfer fsaverage5 rh ${surf} -overlay ${Path_rh} -fminmax ${MIN} ${MAX} -fmid ${MID} -tcl ${temp}/axial2.tcl
		
		echo "rotate_brain_y -90" > ${temp}/axial3.tcl
		echo "rotate_brain_x -90" >> ${temp}/axial3.tcl
		echo "redraw" >> ${temp}/axial3.tcl
		echo "save_tiff ${temp}/view_axial3.tiff" >> ${temp}/axial3.tcl
		echo "exit" >> ${temp}/axial3.tcl
		tksurfer fsaverage5 lh ${surf} -overlay ${Path_lh} -fminmax ${MIN} ${MAX} -fmid ${MID} -tcl ${temp}/axial3.tcl
		
		convert -crop 160x400+225+100 ${temp}/view_axial1.tiff ${temp}/view_axial1_crop.tiff
		convert -crop 160x400+215+100 ${temp}/view_axial2.tiff ${temp}/view_axial2_crop.tiff
		convert -crop 160x400+215+100 ${temp}/view_axial3.tiff ${temp}/view_axial3_crop.tiff
		#montage -tile 6x1 -mode Concatenate ${temp}/view1_crop.tiff ${temp}/view2_crop.tiff ${temp}/view_axial2_crop.tiff ${temp}/view_axial1_crop.tiff ${temp}/view3_crop.tiff ${temp}/view4_crop.tiff ${output}
		montage -tile 7x1 -mode Concatenate ${temp}/view1_crop.tiff ${temp}/view2_crop.tiff ${temp}/view_axial3_crop.tiff ${temp}/view_axial2_crop.tiff ${temp}/view_axial1_crop.tiff ${temp}/view3_crop.tiff ${temp}/view4_crop.tiff ${output}
	fi
	rm -rf ${temp}
fi
