#! /bin/bash

if [ $# -lt 14 ]
then
	echo ""
	echo "Usage:  ProjFMRIOnSurf_SUMA.sh  -i <data_path>  -suma <suma_path>  -sid <subject>  -tr <value>  -fwhm <value>  -o <output_directory>  -pref <output_prefix>"
	echo ""
	echo "  -i                           : Path to epi data "
	echo "  -suma                        : Path to suma directory "
	echo "  -sid			     : subject id "
	echo "  -tr                          : TR value "
	echo "  -fwhm                        : smoothing value "
	echo "  -o                           : Output directory"
	echo "  -pref                        : Output files prefix" 
	echo ""
	echo "Usage:  ProjFMRIOnSurf_SUMA.sh  -i <data_path>  -suma <suma_path>  -sid <subject>  -tr <value>  -fwhm <value>  -o <output_directory>  -pref <output_prefix>"
	echo ""
	echo "Author: Renaud Lopes - CHRU Lille - Jan 20, 2012"
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
		echo "Usage:  ProjFMRIOnSurf_SUMA.sh  -i <data_path>  -suma <suma_path>  -sid <subject>  -tr <value>  -fwhm <value>  -o <output_directory>  -pref <output_prefix>"
		echo ""
		echo "  -i                           : Path to epi data "
		echo "  -suma                        : Path to suma directory "
		echo "  -sid			     : subject id "
		echo "  -tr                          : TR value "
		echo "  -fwhm                        : smoothing value "
		echo "  -o                           : Output directory"
		echo "  -pref                        : Output files prefix" 
		echo ""
		echo "Usage:  ProjFMRIOnSurf_SUMA.sh  -i <data_path>  -suma <suma_path>  -sid <subject>  -tr <value>  -fwhm <value>  -o <output_directory>  -pref <output_prefix>"
		echo ""
		echo "Author: Renaud Lopes - CHRU Lille - Jan 20, 2012"
		echo ""
		exit 1
		;;
	-i)
		index=$[$index+1]
		eval epi=\${$index}
		echo "epi data : ${epi}"
		;;
	-suma)
		index=$[$index+1]
		eval sumadir=\${$index}
		echo "suma directory : ${sumadir}"
		;;
	-sid)
		index=$[$index+1]
		eval SUBJ=\${$index}
		echo "Subject id : ${SUBJ}"
		;;
	-tr)
		index=$[$index+1]
		eval TR=\${$index}
		echo "TR : ${TR}"
		;;
	-fwhm)
		index=$[$index+1]
		eval fwhm=\${$index}
		echo "fwhm : ${fwhm}"
		;;
	-o)
		index=$[$index+1]
		eval outdir=\${$index}
		echo "Output directory : ${outdir}"
		;;
	-pref)
		index=$[$index+1]
		eval pref=\${$index}
		echo "Output prefix : ${pref}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage:  ProjFMRIOnSurf_SUMA.sh  -i <data_path>  -suma <suma_path>  -sid <subject>  -tr <value>  -fwhm <value>  -o <output_directory>  -pref <output_prefix>"
		echo ""
		echo "  -i                           : Path to epi data "
		echo "  -suma                        : Path to suma directory "
		echo "  -sid			     : subject id "
		echo "  -tr                          : TR value "
		echo "  -fwhm                        : smoothing value "
		echo "  -o                           : Output directory"
		echo "  -pref                        : Output files prefix" 
		echo ""
		echo "Usage:  ProjFMRIOnSurf_SUMA.sh  -i <data_path>  -suma <suma_path>  -sid <subject>  -tr <value>  -fwhm <value>  -o <output_directory>  -pref <output_prefix>"
		echo ""
		echo "Author: Renaud Lopes - CHRU Lille - Jan 20, 2012"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done


## Check mandatory arguments
if [ -z ${epi} ]
then
	 echo "-i argument mandatory"
	 exit 1
fi

if [ -z ${sumadir} ]
then
	 echo "-suma argument mandatory"
	 exit 1
fi

if [ -z ${SUBJ} ]
then
	 echo "-sid argument mandatory"
	 exit 1
fi

if [ -z ${fwhm} ]
then
	 echo "-fwhm argument mandatory"
	 exit 1
fi

if [ -z ${outdir} ]
then
	 echo "-o argument mandatory"
	 exit 1
fi

if [ -z ${pref} ]
then
	 echo "-pref argument mandatory"
	 exit 1
fi

## Creates out dir
if [ ! -d ${outdir} ]
then
	mkdir ${outdir}
fi


clip=100

#=================================================================================
## BUILD FMRI SURFACE

echo "Convert volumes to surface space"
for h in l r; do

	# Convert volumes to surface space.
	echo "3dVol2Surf"
	if [ ! -f "${outdir}"/rmcf_"$pref"_"$h"h.niml.dset ]
	then
		3dVol2Surf \
			-spec "${sumadir}"/${SUBJ}_"$h"h.spec \
			-surf_A "${sumadir}"/"$h"h.smoothwm.asc \
			-surf_B "${sumadir}"/"$h"h.pial.asc \
			-sv "${sumadir}"/${SUBJ}_SurfVol+orig \
			-grid_parent ${epi} \
			-map_func ave \
			-f_steps 10 \
			-f_index nodes \
			-f_p1_fr 0 \
			-f_pn_mm 1 \
			-oob_value 0 \
			-outcols_NSD_format \
			-out_niml "${outdir}"/rmcf_"$pref"_"$h"h.niml.dset
		echo "output:" "${outdir}"/rmcf_"$pref"_"$h"h.niml.dset
		
		# smoothing
		echo ""
		echo "smoothing ..."
		infile=rmcf_"$pref"_"$h"h.niml.dset
		bm="$infile"
		cd ${sumadir}
		echo "Using" "$bm" "as blurmaster..."

		SurfSmooth \
			-met HEAT_07 \
			-surf_A "$h"h.smoothwm.asc \
			-surf_B "$h"h.pial.asc \
			-input "${outdir}/${infile}" \
			-spec "${SUBJ}"_"$h"h.spec \
			-target_fwhm "$fwhm" \
			-blurmaster "${outdir}/$bm" \
			-detrend_master \
			-bmall \
			-output "${outdir}/${infile/.niml.dset/}"_sm"$fwhm".niml.dset


		# Compute time-series mean for each node on the surface.
		echo "Compute time-series mean for each node on the surface."
		cd "${outdir}"
		3dTstat \
			-prefix	rmcf_"$pref"_mean_"$h"h_sm"$fwhm".niml.dset \
			./rmcf_"$pref"_"$h"h_sm"$fwhm".niml.dset
		echo "output:" "${outdir}"/rmcf_"$pref"_mean_"$h"h_sm"$fwhm".niml.dset

		# Scale time-series within each voxel to mean of 100.
		# Voxel values thus represent percentage of mean.
		echo "Scale time-series within each voxel to mean of 100"
		3dcalc \
			-gscale \
			-a "${outdir}"/rmcf_"$pref"_"$h"h_sm"$fwhm".niml.dset \
			-b "${outdir}"/rmcf_"$pref"_mean_"$h"h_sm"$fwhm".niml.dset \
		 	-expr '(100*a/b)*step(b-'"$clip"')' \
			-prefix "${outdir}"/rmcf_"$pref"_pc_"$h"h_sm"$fwhm".niml.dset
		echo "output:" "${outdir}"/rmcf_"$pref"_pc_"$h"h_sm"$fwhm".niml.dset

		# Make sure file header has correct TR information.
		echo "Make sure file header has correct TR information"
		echo "3drefit -TR "$TR"s "${outdir}"/rmcf_"$pref"_pc_"$h"h_sm"$fwhm".niml.dset"
		3drefit -TR "$TR"s "${outdir}"/rmcf_"$pref"_pc_"$h"h_sm"$fwhm".niml.dset
		echo "reset TR to" "$TR" "s in" "${outdir}"/rmcf_"$pref"_pc_"$h"h_sm"$fwhm".niml.dset

	else
		echo "Mapping: already done"
	fi

done




