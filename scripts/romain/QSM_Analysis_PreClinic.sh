#! /bin/bash

if [ $# -lt 4   ]
then
	echo ""
	echo "Usage: QSM_Analysis_PreClinic.sh -ir <realdir>  -ii <imadir> -o <outdir>  -echo <file>  [-sd <path>  -m <mask>  -a <algorithm>  -dosmv  -r <value>] "
	echo ""
	echo "  -ii                          : Path to imaginary dicom folder "
	echo "  -ir                          : Path to real dicom folder "
	echo "  -o                           : output folder "
	echo "  -echo                        : nifti image file (.nii.gz or .nii) "
	echo "  Options  "
	echo "  -m                           : specify mask (.nii) in 3D multi-echo space (Default: no mask) "
	exit 1
fi

user=`whoami`
HOME=/home/${user}
index=1
FS=""
mask=""
algo="1"
doSMV="0"
radius="5"


while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
	        echo ""
	        echo "Usage: QSM_Analysis_PreClinic.sh -ir <realdir>  -ii <imadir> -o <outdir>  -echo <file>  [-sd <path>  -m <mask>  -a <algorithm>  -dosmv  -r <value>] "
	        echo ""
	        echo "  -ii                          : Path to imaginary dicom folder "
	        echo "  -ir                          : Path to real dicom folder "
	        echo "  -o                           : output folder "
	        echo "  -echo                        : nifti image file (.nii.gz or .nii) "
	        echo "  Options  "
	        echo "  -m                           : specify mask (.nii) in 3D multi-echo space (Default: no mask) "
	        echo ""
	        echo "Usage: QSM_Analysis_PreClinic.sh -i <bruckerdir>  -o <outdir>  -echo <file>  [-sd <path>  -m <mask>  -a <algorithm>  -dosmv  -r <value>] "
	        echo ""
		exit 1
		;;
	-ir)
		index=$[$index+1]
		eval ir=\${$index}
		echo "Real folder : ${ir}"
		;;
	-ii)
		index=$[$index+1]
		eval ii=\${$index}
		echo "Imaginary folder : ${ii}"
		;;
	-o)
		index=$[$index+1]
		eval OUTDIR=\${$index}
		echo "output folder : ${OUTDIR}"
		;;
	-echo)
		index=$[$index+1]
		eval ECHO=\${$index}
		echo "nifti image : ${ECHO}"
		;;
	-m)
		index=$[$index+1]
		eval mask=\${$index}
		echo "mask to use : ${mask}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
	        echo ""
	        echo "Usage: QSM_Analysis_PreClinic.sh -ir <realdir>  -ii <imadir> -o <outdir>  -echo <file>  [-sd <path>  -m <mask>  -a <algorithm>  -dosmv  -r <value>] "
	        echo ""
	        echo "  -ii                          : Path to imaginary dicom folder "
	        echo "  -ir                          : Path to real dicom folder "
	        echo "  -o                           : output folder "
	        echo "  -echo                        : nifti image file (.nii.gz or .nii) "
	        echo "  Options  "
	        echo "  -m                           : specify mask (.nii) in 3D multi-echo space (Default: no mask) "
	        echo ""
	        echo "Usage: QSM_Analysis_PreClinic.sh -i <bruckerdir>  -o <outdir>  -echo <file>  [-sd <path>  -m <mask>  -a <algorithm>  -dosmv  -r <value>] "
	        echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done


## Check mandatory arguments
if [ -z ${ii} ]
then
	 echo "-ii argument mandatory"
	 exit 1
fi

if [ -z ${ir} ]
then
	 echo "-ir argument mandatory"
	 exit 1
fi

if [ -z ${OUTDIR} ]
then
	 echo "-o argument mandatory"
	 exit 1
fi

if [ -z ${ECHO} ]
then
	 echo "-echo argument mandatory"
	 exit 1
fi

# Create out folder
if [ ! -d ${OUTDIR} ]; then
	mkdir ${OUTDIR}
fi

# Create real image for registering
#fslroi ${ECHO} ${OUTDIR}/real_gre 1 1
#gunzip -f ${OUTDIR}/real_gre.nii.gz
# ==========================================================================================
#                                    QSM ANALYSIS
# ==========================================================================================

echo "QSM Analysis..."
echo "computeQSM_preclinic('${ir}','${ii}','${OUTDIR}','${ECHO}','${mask}');"

if [ ${algo} -eq "1" ]; then

matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);
	%Pour ajouter la version MEDI 2019 dans son path
	run('/home/global/matlab_toolbox/MEDI_toolbox_2019/MEDI_set_path')
	disp('computeQSM_PreClinic(ii,ir,outdir,echo,all)');
	if isempty('${mask}')
		disp(1)
		computeQSM_preclinic('${ir}','${ii}','${OUTDIR}','${ECHO}');
	else
		disp(2)
		computeQSM_preclinic('${ir}','${ii}','${OUTDIR}','${ECHO}','${mask}');
	end
	
EOF

else

echo "Sorry the cpp version of MEDI toolbox is not ready for Brucker's data....."

fi
