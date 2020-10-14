#! /bin/bash

if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: EPISliceCorrect.sh  -f <forward>  -b <backward>  -o <output_directory>  -pref <output_prefix>"
	echo ""
	echo "  -f                           : Path to forward slice (displacement toward +y)"
	echo "  -b                           : Path to forward slice (displacement toward -y)"
	echo "  -o                           : Output directory"
	echo "  -pref                        : Output files prefix" 
	echo ""
	echo "Usage: EPISliceCorrect.sh  -f <forward>  -b <backward>  -o <output_directory>  -pref <output_prefix>"
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
		echo "Usage: EPISliceCorrect.sh  -f <forward>  -b <backward>  -o <output_directory>  -pref <output_prefix>"
		echo ""
		echo "  -f                           : Path to forward slice (displacement toward +y)"
		echo "  -b                           : Path to forward slice (displacement toward -y)"
		echo "  -o                           : Output directory"
		echo "  -pref                        : Output files prefix" 
		echo ""
		echo "Usage: EPISliceCorrect.sh  -f <forward>  -b <backward>  -o <output_directory>  -pref <output_prefix>"
		echo ""
		exit 1
		;;
	-f)
		index=$[$index+1]
		eval forw=\${$index}
		echo "Forward image : ${forw}"
		;;
	-b)
		index=$[$index+1]
		eval back=\${$index}
		echo "Backward image : ${back}"
		;;
	-o)
		index=$[$index+1]
		eval obase=\${$index}
		echo "Output directory : ${obase}"
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
		echo "Usage: EPISliceCorrect.sh  -f <forward>  -b <backward>  -o <output_directory>  -pref <output_prefix>"
		echo ""
		echo "  -f                           : Path to forward slice (displacement toward +y)"
		echo "  -b                           : Path to forward slice (displacement toward -y)"
		echo "  -o                           : Output directory"
		echo "  -pref                        : Output files prefix" 
		echo ""
		echo "Usage: EPISliceCorrect.sh  -f <forward>  -b <backward>  -o <output_directory>  -pref <output_prefix>"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${forw} ]
then
	 echo "-f argument mandatory"
	 exit 1
fi

if [ -z ${back} ]
then
	 echo "-b argument mandatory"
	 exit 1
fi

if [ -z ${obase} ]
then
	 echo "-o argument mandatory"
	 exit 1
fi

if [ -z ${pref} ]
then
	 echo "-pref argument mandatory"
	 exit 1
fi

outdir=${obase}

/usr/local/matlab11/bin/matlab -nodisplay <<EOF
% Load Matlab Path
cd ${outdir}
u = EPIcorrfast3D('${forw}', '${back}');
% u = EPIcorrfast3D('${forw}', '${back}', [2 2 2 2 2 2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1 1 1 1 1 1 1], 0, 12);
Jacc = EPIcomputeJaccobian(u);
save ${pref} u Jacc
V_f = spm_vol('${forw}');
V_f_out = EPIresample(V_f, u, 1);
V_b = spm_vol('${back}');
V_b_out = EPIresample(V_b, u, 0);
V_f.fname = '${outdir}/${pref}_forward.nii';
V_f = spm_write_vol(V_f, V_f_out);
V_b.fname = '${outdir}/${pref}_backward.nii';
V_b = spm_write_vol(V_b, V_b_out);
V_f.fname = '${outdir}/${pref}_displacement.nii';
V_f.dt(1) = 16;
V_f = spm_write_vol(V_f, u);
EOF

