# !/bin/bash

if [ $# -lt 12 ]
then
	echo ""
	echo "Usage:  ASL_UnWarp.sh  -i <path>  -f1 <asl1>  -f2 <asl2>  -b1 <name>  -b2 <name> -o <path> "
	echo ""
	echo "  -i                           : Path to asl volume "
	echo "  -f1                          : ASL volume 1 "
	echo "  -f2                          : ASL volume 2 "
	echo "  -b1                          : 'backward' volume 1 "
	echo "  -b2                          : 'backward' volume 2 "
	echo "  -o                           : Output folder "
	echo ""
	echo "Usage:  ASL_UnWarp.sh  -i <path>  -f1 <asl1>  -f2 <asl2>  -b1 <name>  -b2 <name>  -o <path> "
	echo ""
	echo "Author: Renaud Lopes - CHRU Lille - Jan 30, 2013"
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
		echo "Usage:  ASL_UnWarp.sh  -i <path>  -f1 <asl1>  -f2 <asl2>  -b1 <name>  -b2 <name> -o <path> "
		echo ""
		echo "  -i                           : Path to asl volume "
		echo "  -f1                          : ASL volume 1 "
		echo "  -f2                          : ASL volume 2 "
		echo "  -b1                          : 'backward' volume 1 "
		echo "  -b2                          : 'backward' volume 2 "
		echo "  -o                           : Output folder "
		echo ""
		echo "Usage:  ASL_UnWarp.sh  -i <path>  -f1 <asl1>  -f2 <asl2>  -b1 <name>  -b2 <name>  -o <path> "
		echo ""
		echo "Author: Renaud Lopes - CHRU Lille - Jan 30, 2013"
		echo ""
		exit 1
		;;
	-i)
		index=$[$index+1]
		eval input=\${$index}
		echo "input folder : ${input}"
		;;
	-f1)
		index=$[$index+1]
		eval asl1=\${$index}
		echo "asl 1 : ${asl1}"
		;;
	-f2)
		index=$[$index+1]
		eval asl2=\${$index}
		echo "asl 2 : ${asl2}"
		;;
	-b1)
		index=$[$index+1]
		eval back1=\${$index}
		echo "backward volume 1 : ${back1}"
		;;
	-b2)
		index=$[$index+1]
		eval back2=\${$index}
		echo "backward volume 2 : ${back2}"
		;;
	-o)
		index=$[$index+1]
		eval output=\${$index}
		echo "output folder : ${output}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage:  ASL_UnWarp.sh  -i <path>  -f1 <asl1>  -f2 <asl2>  -b1 <name>  -b2 <name> -o <path> "
		echo ""
		echo "  -i                           : Path to asl volume "
		echo "  -f1                          : ASL volume 1 "
		echo "  -f2                          : ASL volume 2 "
		echo "  -b1                          : 'backward' volume 1 "
		echo "  -b2                          : 'backward' volume 2 "
		echo "  -o                           : Output folder "
		echo ""
		echo "Usage:  ASL_UnWarp.sh  -i <path>  -f1 <asl1>  -f2 <asl2>  -b1 <name>  -b2 <name>  -o <path> "
		echo ""
		echo "Author: Renaud Lopes - CHRU Lille - Jan 30, 2013"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

if [ -d ${output} ]
then 
	rm -rf ${output}
fi

echo "mkdir ${output}/splitasl"
mkdir -p ${output}/splitasl

echo "fslsplit ${input}/${asl1} ${output}/splitasl/asl1_ -t"
fslsplit ${input}/${asl1} ${output}/splitasl/asl1_ -t

echo "fslsplit ${input}/${asl2} ${output}/splitasl/asl2_ -t"
fslsplit ${input}/${asl2} ${output}/splitasl/asl2_ -t

echo "gunzip ${output}/splitasl/*.gz"
gunzip ${output}/splitasl/*.gz

#===============================================================
#       Recalage des dynamiques sur la première
#                           +
#     Prétraitement des données pour la correction 
#===============================================================

echo ""
echo "recalage + prétraitements"

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

% Load Matlab Path
cd ${HOME}
p = pathdef;
addpath(p);

ASL_RegisterSPM8('${output}/splitasl','asl1_');
ASL_RegisterSPM8('${output}/splitasl','asl2_');
PreprocessEPIUnwarp('${input}/${back1}','ASL',1);
PreprocessEPIUnwarp('${input}/${back2}','ASL',1);

EOF

#===============================================================
#                  Calcul des déformations 
#===============================================================

echo ""
echo "Calcul des déformations"

echo "asl 1"
cmtk epiunwarp --smoothness-constraint-weight 10000 --folding-constraint-weight 10000 --iterations 100 -x --write-jacobian-fwd ${output}/jacobian_fwd1.nii ${output}/splitasl/asl1_0000.nii ${input}/rs${back1} ${output}/asl1_0000.nii ${output}/rs${back1} ${output}/dfield1.nrrd

echo "asl 2"
cmtk epiunwarp --smoothness-constraint-weight 10000 --folding-constraint-weight 10000 --iterations 100 -x --write-jacobian-fwd ${output}/jacobian_fwd2.nii ${output}/splitasl/asl2_0000.nii ${input}/rs${back2} ${output}/asl2_0000.nii ${output}/rs${back2} ${output}/dfield2.nrrd

#===============================================================
#               Application des déformations 
#===============================================================

echo ""
echo "application des déformations"

echo "mkdir ${output}/correct"
mkdir ${output}/correct

for ima in `ls -F ${output}/splitasl/ | grep '^asl1_*.*$'`
do
	echo "${ima}"
	cmtk reformatx --floating ${output}/splitasl/${ima} --linear -o ${output}/correct/${ima} ${output}/asl1_0000.nii.gz ${output}/dfield1.nrrd
	cmtk imagemath --in ${output}/correct/${ima} ${output}/jacobian_fwd1.nii --mul --out ${output}/correct/${ima}
done

for ima in `ls -F ${output}/splitasl/ | grep '^asl2_*.*$'`
do
	echo "${ima}"
	cmtk reformatx --floating ${output}/splitasl/${ima} --linear -o ${output}/correct/${ima} ${output}/asl2_0000.nii.gz ${output}/dfield2.nrrd
	cmtk imagemath --in ${output}/correct/${ima} ${output}/jacobian_fwd2.nii --mul --out ${output}/correct/${ima}
done

