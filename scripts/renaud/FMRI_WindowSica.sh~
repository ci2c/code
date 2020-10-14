#! /bin/bash

if [ $# -lt 16 ]
then
	echo ""
	echo "Usage:  FMRI_WindowSica.sh  -i <data_path>  -pref <prefix>  -a <anat_path>  -o <out_path>  -w <value>  -ov <value>  -tr <value>  -N <value>"
	echo ""
	echo "  -i                    : Path to data "
	echo "  -pref                 : prefix of input files "
	echo "  -a                    : structural data "
	echo "  -o                    : Path to output "
	echo "  -w                    : number of windows "
	echo "  -ov                   : overlap between windows "
	echo "  -tr                   : TR value "
	echo "  -N                    : number of components "
	echo ""
	echo "Usage:  FMRI_WindowSica.sh  -i <data_path>  -pref <prefix>  -a <anat_path>  -o <out_path>  -w <value>  -ov <value>  -tr <value>  -N <value>"
	echo ""
	echo "Author: Renaud Lopes - CHRU Lille - June 6, 2012"
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
		echo "Usage:  FMRI_WindowSica.sh  -i <data_path>  -pref <prefix>  -a <anat_path>  -o <out_path>  -w <value>  -ov <value>  -tr <value>  -N <value>"
		echo ""
		echo "  -i                    : Path to data "
		echo "  -pref                 : prefix of input files "
		echo "  -a                    : structural data "
		echo "  -o                    : Path to output "
		echo "  -w                    : number of windows "
		echo "  -ov                   : overlap between windows "
		echo "  -tr                   : TR value "
		echo "  -N                    : number of components "
		echo ""
		echo "Usage:  FMRI_WindowSica.sh  -i <data_path>  -pref <prefix>  -a <anat_path>  -o <out_path>  -w <value>  -ov <value>  -tr <value>  -N <value>"
		echo ""
		echo "Author: Renaud Lopes - CHRU Lille - June 6, 2012"
		echo ""
		exit 1
		;;
	-i)
		index=$[$index+1]
		eval input=\${$index}
		echo "data : ${input}"
		;;
	-pref)
		index=$[$index+1]
		eval prefix=\${$index}
		echo "prefix of input files : ${prefix}"
		;;
	-a)
		index=$[$index+1]
		eval anatpath=\${$index}
		echo "structural : ${anatpath}"
		;;
	-o)
		index=$[$index+1]
		eval outdir=\${$index}
		echo "output : ${outdir}"
		;;
	-w)
		index=$[$index+1]
		eval nwind=\${$index}
		echo "number of windows : ${nwind}"
		;;
	-ov)
		index=$[$index+1]
		eval overlap=\${$index}
		echo "overlap : ${overlap}"
		;;
	-tr)
		index=$[$index+1]
		eval TR=\${$index}
		echo "TR : ${TR}"
		;;
	-N)
		index=$[$index+1]
		eval ncomp=\${$index}
		echo "number of components : ${ncomp}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage:  FMRI_WindowSica.sh  -i <data_path>  -pref <prefix>  -a <anat_path>  -o <out_path>  -w <value>  -ov <value>  -tr <value>  -N <value>"
		echo ""
		echo "  -i                    : Path to data "
		echo "  -pref                 : prefix of input files "
		echo "  -a                    : structural data "
		echo "  -o                    : Path to output "
		echo "  -w                    : number of windows "
		echo "  -ov                   : overlap between windows "
		echo "  -tr                   : TR value "
		echo "  -N                    : number of components "
		echo ""
		echo "Usage:  FMRI_WindowSica.sh  -i <data_path>  -pref <prefix>  -a <anat_path>  -o <out_path>  -w <value>  -ov <value>  -tr <value>  -N <value>"
		echo ""
		echo "Author: Renaud Lopes - CHRU Lille - June 6, 2012"
		echo ""
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

if [ -z ${prefix} ]
then
	 echo "-pref argument mandatory"
	 exit 1
fi

if [ -z ${anatpath} ]
then
	 echo "-a argument mandatory"
	 exit 1
fi

if [ -z ${outdir} ]
then
	 echo "-o argument mandatory"
	 exit 1
fi

if [ -z ${nwind} ]
then
	 echo "-w argument mandatory"
	 exit 1
fi

if [ -z ${overlap} ]
then
	 echo "-ov argument mandatory"
	 exit 1
fi

if [ -z ${TR} ]
then
	 echo "-tr argument mandatory"
	 exit 1
fi

if [ -z ${ncomp} ]
then
	 echo "-N argument mandatory"
	 exit 1
fi

echo "FMRI_WindowSica('${input}','${prefix}','${anatpath}','${outdir}',${nwind},${overlap},${TR},${ncomp})"

matlab -nodisplay <<EOF
% Load Matlab Path
p = pathdef;
addpath(p);

VoxSize=[3 3 3];
BoundingBox=[-90 -126 -72;90 90 108];
FMRI_WindowSica('${input}','${prefix}','${anatpath}','${outdir}',${nwind},${overlap},${TR},${ncomp},VoxSize,BoundingBox);
 
EOF