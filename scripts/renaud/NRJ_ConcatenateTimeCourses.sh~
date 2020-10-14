#! /bin/bash

if [ $# -lt 16 ]
then
	echo ""
	echo "Usage: NRJ_ConcatenateTimeCourses.sh -i <path>  -o <path>  -pref <name>  -Nm <value>  -m <name>  -b <path>  -wm <path>  -vent <path>  [-tr <value>  -f <value> <value>  -fwhm <value>  -oname <name> ]"
	echo ""
	echo "  -i                           : epi folder"
	echo "  -o                           : output folder "
	echo "  -pref                        : epi prefix "
	echo "  -Nm                          : number of masks (this argument is always before the next one (-m) "
	echo "  -m                           : masks files "
	echo "  -b                           : brain mask files "
	echo "  -wm                          : white matter mask "
	echo "  -vent                        : Ventricles mask "
	echo "  -tr                          : TR value "
	echo "  -f                           : do filtering step (Default no) "
	echo "  -fwhm                        : do smoothing step (Default no) "
	echo "  -oname                       : output filename (Default data.mat) "
	echo ""
	echo "Usage: NRJ_ConcatenateTimeCourses.sh -i <path>  -o <path>  -pref <name>  -Nm <value>  -m <name>  -b <path>  -wm <path>  -vent <path>  [-tr <value>  -f <value> <value>  -fwhm <value> ]"
	echo ""
	exit 1
fi

HOME=/home/renaud
index=1
TR=2
highpass=-1
fwhmvol=-1
outname=data.mat

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: NRJ_ConcatenateTimeCourses.sh -i <path>  -o <path>  -pref <name>  -Nm <value>  -m <name>  -b <path>  -wm <path>  -vent <path>  [-tr <value>  -f <value> <value>  -fwhm <value> ]"
		echo ""
		echo "  -i                           : epi folder"
		echo "  -o                           : output folder "
		echo "  -pref                        : epi prefix "
		echo "  -Nm                          : number of masks (this argument is always before the next one (-m) "
		echo "  -m                           : masks files "
		echo "  -b                           : brain mask files "
		echo "  -wm                          : white matter mask "
		echo "  -vent                        : Ventricles mask "
		echo "  -tr                          : TR value "
		echo "  -f                           : do filtering step (Default no) "
		echo "  -fwhm                        : do smoothing step (Default no) "
		echo ""
		echo "Usage: NRJ_ConcatenateTimeCourses.sh -i <path>  -o <path>  -pref <name>  -Nm <value>  -m <name>  -b <path>  -wm <path>  -vent <path>  [-tr <value>  -f <value> <value>  -fwhm <value> ]"
		echo ""
		exit 1
		;;
	-i)
		input=`expr $index + 1`
		eval input=\${$input}
		echo "  |-------> EPI Dir : $input"
		index=$[$index+1]
		;;
	-o)
		outdir=`expr $index + 1`
		eval outdir=\${$outdir}
		echo "  |-------> output folder : $outdir"
		index=$[$index+1]
		;;
	-pref)
		prefepi=`expr $index + 1`
		eval prefepi=\${$prefepi}
		echo "  |-------> EPI prefix : $prefepi"
		index=$[$index+1]
		;;
	-Nm)
		nmask=`expr $index + 1`
		eval nmask=\${$nmask}
		echo "  |-------> Number of masks : $nmask"
		index=$[$index+1]
		;;
	-m)
		declare -a masks
		echo "  |-------> masks:" 
		for ((ind = 0; ind < ${nmask}; ind += 1))
		do
			tmp=`expr $index + 1`
			eval tmp=\${$tmp}
			masks[ind]=${tmp}
			index=$[$index+1]
			echo "            ${masks[ind]}"
		done
		;;
	-b)
		brainMask=`expr $index + 1`
		eval brainMask=\${$brainMask}
		echo "  |-------> Brain mask : $brainMask"
		index=$[$index+1]
		;;
	-wm)
		wmMask=`expr $index + 1`
		eval wmMask=\${$wmMask}
		echo "  |-------> White matter mask : $wmMask"
		index=$[$index+1]
		;;
	-vent)
		ventMask=`expr $index + 1`
		eval ventMask=\${$ventMask}
		echo "  |-------> Ventricles mask : $ventMask"
		index=$[$index+1]
		;;
	-tr)
		TR=`expr $index + 1`
		eval TR=\${$TR}
		echo "  |-------> TR value : $TR"
		index=$[$index+1]
		;;
	-f)
		tmp=`expr $index + 1`
		eval highpass=\${$tmp}
		index=$[$index+1]
		tmp=`expr $index + 1`
		eval lowpass=\${$tmp}
		index=$[$index+1]
		echo "  |-------> Bandpass filtering : $highpass $lowpass"
		;;
	-fwhm)
		fwhmvol=`expr $index + 1`
		eval fwhmvol=\${$fwhmvol}
		echo "  |-------> smoothing value : $fwhmvol"
		index=$[$index+1]
		;;
	-oname)
		outname=`expr $index + 1`
		eval outname=\${$outname}
		echo "  |-------> out filename : $outname"
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

## Check mandatory arguments
if [ -z ${input} ]
then
	 echo "-i argument mandatory"
	 exit 1
fi

if [ -z ${outdir} ]
then
	 echo "-o argument mandatory"
	 exit 1
fi

if [ -z ${prefepi} ]
then
	 echo "-pref argument mandatory"
	 exit 1
fi

if [ -z ${nmask} ]
then
	 echo "-Nm argument mandatory"
	 exit 1
fi

if [ -z ${masks[0]} ]
then
	 echo "-m argument mandatory"
	 exit 1
fi

if [ -d ${outdir} ]
then
	echo "delete out folder"
	rm -rf ${outdir}
fi
echo "create out folder"
mkdir -p ${outdir}

if [ -f ${outdir}/roiMasks.txt ]
then
	rm -f ${outdir}/roiMasks.txt
fi
for ((ind = 0; ind < ${nmask}; ind += 1))
do
	echo ${masks[ind]} >> ${outdir}/roiMasks.txt
done

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);

	epiFiles=cellstr(conn_dir(fullfile('${input}',['${prefepi}' '*.nii'])));
	motionFiles=cellstr(conn_dir(fullfile('${input}',['rp_' '*.txt'])));

	roiFiles=textread('${outdir}/roiMasks.txt','%s\n');

	preproc.conf.do = true;
	if ${highpass}==-1
		preproc.filt.do = false;
	else
		preproc.filt.do = true;
		preproc.filt.hp = ${highpass};
		preproc.filt.lp = ${lowpass};
	end
	if ${fwhmvol}==-1
		preproc.fwhm.do = false;
	else
		preproc.fwhm.do   = true;
		preproc.fwhm.fwhm = ${fwhmvol};
	end

	epiFiles
	motionFiles
	preproc
	roiFiles{1}
	roiFiles{2}	

	[tseries_all,coord_rois,all_rois,all_mask,all_ind_roi,all_hdr] = FMRI_ConcatenateTimeCourses(epiFiles,'${outdir}',${TR}, '${brainMask}', motionFiles, '${ventMask}', '${wmMask}', roiFiles,preproc);

	save(fullfile('${outdir}','${outname}'),'tseries_all','coord_rois','all_rois','all_mask','all_ind_roi','all_hdr','preproc');

EOF
