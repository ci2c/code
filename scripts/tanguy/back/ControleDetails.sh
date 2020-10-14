#! /bin/bash

if [ $# -lt 2 ]
then
		echo ""
		echo "Usage: Controle.sh -rp <REP> -subj <SUBJ_ID>"
		echo ""
		echo "  -rp                              : directory containing the patient records to control"
		echo ""
		echo "  -subj                              : Subject_id for details"
		echo "Usage: Controle.sh -rp <REP>"
		echo ""
		echo ""
		echo "Author: Tanguy Hamel - CHRU Lille - 2013"
		echo ""

		exit 1
fi



index=1
keeptmp=0
CFLAG=0

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: Controle.sh -rp <REP> -subj <SUBJ_ID>"
		echo ""
		echo "  -rp                              : directory containing the patient records to control"
		echo ""
		echo "  -subj                              : Subject_id for details"
		echo "Usage: Controle.sh -rp <REP>"
		echo ""
		echo ""
		echo "Author: Tanguy Hamel - CHRU Lille - 2013"
		exit 1
		;;
	-rp)
		index=$[$index+1]
		eval REP=\${$index}
		echo "REP : $REP"
		;;
	-subj)
		index=$[$index+1]
		eval SUBJ=\${$index}
		echo "Subj : $SUBJ"
		;;
	
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: Controle.sh -rp <REP> -subj <SUBJ_ID>"
		echo ""
		echo "  -rp                              : directory containing the patient records to control"
		echo ""
		echo "  -subj                              : Subject_id for details"
		echo "Usage: Controle.sh -rp <REP>"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done



DIR=${REP}/${SUBJ}

echo "DIR : ${DIR}"

nb=0;
	
###T1

echo "${nb}"

if [ ! -f  ${DIR}/epilepsy/lh.dxyz ]
then
	echo "not ${DIR}/epilepsy/lh.dxyz"
	nb=$[${nb}+1]
fi

if [ ! -f  ${DIR}/epilepsy/rh.dxyz ]
then
	echo "not ${DIR}/epilepsy/rh.dxyz"
	nb=$[${nb}+1]
fi

if [ ! -f ${DIR}/epilepsy/lh.fsaverage.dxyz.mgh   ]
then
	echo "not ${DIR}/epilepsy/lh.fsaverage.dxyz.mgh "
	nb=$[${nb}+1]
fi
	
if [ ! -f  ${DIR}/epilepsy/rh.fsaverage.dxyz.mgh ]
then
	echo "not ${DIR}/epilepsy/rh.fsaverage.dxyz.mgh"
	nb=$[${nb}+1]
fi

if [ ! -f  ${DIR}/epilepsy/lh.intensity ]
then
	echo "not ${DIR}/epilepsy/lh.intensity"
	nb=$[${nb}+1]
fi

if [ ! -f  ${DIR}/epilepsy/rh.intensity ]
then
	echo "not ${DIR}/epilepsy/rh.intensity"
	nb=$[${nb}+1]
fi

if [ ! -f  ${DIR}/epilepsy/lh.fsaverage.intensity.mgh ]
then
	echo "not ${DIR}/epilepsy/lh.fsaverage.intensity.mgh"
	nb=$[${nb}+1]
fi

if [ ! -f  ${DIR}/epilepsy/rh.fsaverage.intensity.mgh ]
then
	echo "not ${DIR}/epilepsy/rh.fsaverage.intensity.mgh"
	nb=$[${nb}+1]
fi

if [ ! -f  ${DIR}/epilepsy/lh.thickness ]
then
	echo "not ${DIR}/epilepsy/lh.thickness"
	nb=$[${nb}+1]
fi

if [ ! -f  ${DIR}/epilepsy/rh.thickness ]
then
	echo "not ${DIR}/epilepsy/rh.thickness"
	nb=$[${nb}+1]
fi

if [ ! -f  ${DIR}/epilepsy/lh.fsaverage.thickness.mgh ]
then
	echo "not ${DIR}/epilepsy/lh.fsaverage.thickness.mgh"
	nb=$[${nb}+1]
fi

if [ ! -f ${DIR}/epilepsy/rh.fsaverage.thickness.mgh  ]
then
	echo "not ${DIR}/epilepsy/rh.fsaverage.thickness.mgh"
	nb=$[${nb}+1]
fi

if [ ! -f  ${DIR}/epilepsy/lh.depth ]
then
	echo "not ${DIR}/epilepsy/lh.depth"
	nb=$[${nb}+1]
fi

if [ ! -f  ${DIR}/epilepsy/rh.depth ]
then
	echo "not ${DIR}/epilepsy/rh.depth"
	nb=$[${nb}+1]
fi

if [ ! -f  ${DIR}/epilepsy/lh.fsaverage.depth.mgh ]
then
	echo "not ${DIR}/epilepsy/lh.fsaverage.depth.mgh"
	nb=$[${nb}+1]
fi

if [ ! -f ${DIR}/epilepsy/rh.fsaverage.depth.mgh  ]
then
	echo "not ${DIR}/epilepsy/rh.fsaverage.depth.mgh"
	nb=$[${nb}+1]
fi

if [ ! -f  ${DIR}/epilepsy/lh.curv ]
then
	echo "not ${DIR}/epilepsy/lh.curv"
	nb=$[${nb}+1]
fi

if [ ! -f ${DIR}/epilepsy/rh.curv  ]
then
	echo "not ${DIR}/epilepsy/rh.curv"
	nb=$[${nb}+1]
fi

if [ ! -f  ${DIR}/epilepsy/lh.fsaverage.curv.mgh ]
then
	echo "not ${DIR}/epilepsy/lh.fsaverage.curv.mgh"
	nb=$[${nb}+1]
fi

if [ ! -f  ${DIR}/epilepsy/rh.fsaverage.curv.mgh ]
then
	echo "not ${DIR}/epilepsy/rh.fsaverage.curv.mgh"
	nb=$[${nb}+1]
fi

if [ ! -f  ${DIR}/epilepsy/lh.complexity ]
then
	echo "not ${DIR}/epilepsy/lh.complexity"
	nb=$[${nb}+1]
fi

if [ ! -f  ${DIR}/epilepsy/rh.complexity ]
then
	echo "not ${DIR}/epilepsy/rh.complexity"
	nb=$[${nb}+1]
fi

if [ ! -f  ${DIR}/epilepsy/lh.fsaverage.complexity.mgh ]
then
	echo "not ${DIR}/epilepsy/lh.fsaverage.complexity.mgh"
	nb=$[${nb}+1]
fi

if [ ! -f  ${DIR}/epilepsy/rh.fsaverage.complexity.mgh ]
then
	echo "not ${DIR}/epilepsy/rh.fsaverage.complexity.mgh"
	nb=$[${nb}+1]
fi

if [ ! -f  ${DIR}/epilepsy/lh.jacobian ]
then
	echo "not ${DIR}/epilepsy/lh.jacobian"
	nb=$[${nb}+1]
fi

if [ ! -f  ${DIR}/epilepsy/rh.jacobian ]
then
	echo "not ${DIR}/epilepsy/rh.jacobian"
	nb=$[${nb}+1]
fi

if [ ! -f  ${DIR}/epilepsy/lh.fsaverage.jacobian.mgh ]
then
	echo "not ${DIR}/epilepsy/lh.fsaverage.jacobian.mgh "
	nb=$[${nb}+1]
fi

if [ ! -f ${DIR}/epilepsy/rh.fsaverage.jacobian.mgh  ]
then
	echo "not ${DIR}/epilepsy/rh.fsaverage.jacobian.mgh"
	nb=$[${nb}+1]
fi





###FLAIR



if [ ! -f  ${DIR}/epilepsy/lh.flair_nuc.dxyz ]
then
	echo "not ${DIR}/epilepsy/lh.flair_nuc.dxyz"
	nb=$[${nb}+1]
fi

if [ ! -f ${DIR}/epilepsy/rh.flair_nuc.dxyz  ]
then
	echo "not ${DIR}/epilepsy/rh.flair_nuc.dxyz"
	nb=$[${nb}+1]
fi

if [ ! -f  ${DIR}/epilepsy/lh.flair_nuc.fsaverage.dxyz.mgh ]
then
	echo "not ${DIR}/epilepsy/lh.flair_nuc.fsaverage.dxyz.mgh"
	nb=$[${nb}+1]
fi

if [ ! -f  ${DIR}/epilepsy/rh.flair_nuc.fsaverage.dxyz.mgh ]
then
	echo "not ${DIR}/epilepsy/rh.flair_nuc.fsaverage.dxyz.mgh"
	nb=$[${nb}+1]
fi

if [ ! -f ${DIR}/epilepsy/lh.flair_nuc.intensity  ]
then
	echo "not ${DIR}/epilepsy/lh.flair_nuc.intensity"
	nb=$[${nb}+1]
fi

if [ ! -f  ${DIR}/epilepsy/rh.flair_nuc.intensity ]
then
	echo "not ${DIR}/epilepsy/rh.flair_nuc.intensity"
	nb=$[${nb}+1]
fi

if [ ! -f  ${DIR}/epilepsy/lh.flair_nuc.fsaverage.intensity.mgh ]
then
	echo "not ${DIR}/epilepsy/lh.flair_nuc.fsaverage.intensity.mgh"
	nb=$[${nb}+1]
fi

if [ ! -f   ${DIR}/epilepsy/rh.flair_nuc.fsaverage.intensity.mgh ]
then
	echo "not ${DIR}/epilepsy/rh.flair_nuc.fsaverage.intensity.mgh"
	nb=$[${nb}+1]
fi




###PET


if [ ! -f  ${DIR}/epilepsy/lh.pet ]
then
	echo "not ${DIR}/epilepsy/lh.pet"
	nb=$[${nb}+1]
fi

if [ ! -f ${DIR}/epilepsy/rh.pet  ]
then
	echo "not ${DIR}/epilepsy/rh.pet"
	nb=$[${nb}+1]
fi


if [ ! -f  ${DIR}/epilepsy/lh.fsaverage.pet.mgh ]
then
	echo "not ${DIR}/epilepsy/lh.fsaverage.pet.mgh"
	nb=$[${nb}+1]
fi		

if [ ! -f  ${DIR}/epilepsy/rh.fsaverage.pet.mgh ]
then
	echo "not ${DIR}/epilepsy/rh.fsaverage.pet.mgh"
	nb=$[${nb}+1]
fi

	
######## WITH BLUR #########	
	
	
for FWHM in 5 10 15 20 

do

	###T1
		
		if [ ! -f  ${DIR}/epilepsy/lh.fwhm${FWHM}.dxyz ]
		then
			echo "not ${DIR}/epilepsy/lh.fwhm${FWHM}.dxyz"
			nb=$[${nb}+1]
		fi

		if [ ! -f  ${DIR}/epilepsy/rh.fwhm${FWHM}.dxyz ]
		then
			echo "not ${DIR}/epilepsy/rh.fwhm${FWHM}.dxyz"
			nb=$[${nb}+1]
		fi

		if [ ! -f  ${DIR}/epilepsy/lh.fwhm${FWHM}.fsaverage.dxyz.mgh ]
		then
			echo "not ${DIR}/epilepsy/lh.fwhm${FWHM}.fsaverage.dxyz.mgh "
			nb=$[${nb}+1]
		fi

		if [ ! -f  ${DIR}/epilepsy/rh.fwhm${FWHM}.fsaverage.dxyz.mgh  ]
		then
			echo "not ${DIR}/epilepsy/rh.fwhm${FWHM}.fsaverage.dxyz.mgh "
			nb=$[${nb}+1]
		fi

		if [ ! -f  ${DIR}/epilepsy/lh.fwhm${FWHM}.intensity ]
		then
			echo "not ${DIR}/epilepsy/lh.fwhm${FWHM}.intensity"
			nb=$[${nb}+1]
		fi

		if [ ! -f  ${DIR}/epilepsy/lh.fwhm${FWHM}.fsaverage.intensity.mgh ]
		then
			echo "not ${DIR}/epilepsy/lh.fwhm${FWHM}.fsaverage.intensity.mgh"
			nb=$[${nb}+1]
		fi

		if [ ! -f ${DIR}/epilepsy/rh.fwhm${FWHM}.intensity  ]
		then
			echo "not ${DIR}/epilepsy/rh.fwhm${FWHM}.intensity"
			nb=$[${nb}+1]
		fi

		if [ ! -f  ${DIR}/epilepsy/rh.fwhm${FWHM}.fsaverage.intensity.mgh ]
		then
			echo "not ${DIR}/epilepsy/rh.fwhm${FWHM}.fsaverage.intensity.mgh"
			nb=$[${nb}+1]
		fi

		if [ ! -f ${DIR}/epilepsy/lh.fwhm${FWHM}.fsaverage.thickness.mgh  ]
		then
			echo "not ${DIR}/epilepsy/lh.fwhm${FWHM}.fsaverage.thickness.mgh"
			nb=$[${nb}+1]
		fi

		if [ ! -f  ${DIR}/epilepsy/rh.fwhm${FWHM}.fsaverage.thickness.mgh ]
		then
			echo "not ${DIR}/epilepsy/rh.fwhm${FWHM}.fsaverage.thickness.mgh"
			nb=$[${nb}+1]
		fi

		if [ ! -f  ${DIR}/epilepsy/lh.fwhm${FWHM}.thickness.mgh ]
		then
			echo "not ${DIR}/epilepsy/lh.fwhm${FWHM}.thickness.mgh"
			nb=$[${nb}+1]
		fi

		if [ ! -f  ${DIR}/epilepsy/rh.fwhm${FWHM}.thickness.mgh ]
		then
			echo "not ${DIR}/epilepsy/rh.fwhm${FWHM}.thickness.mgh"
			nb=$[${nb}+1]
		fi

		if [ ! -f  ${DIR}/epilepsy/lh.fwhm${FWHM}.depth ]
		then
			echo "not ${DIR}/epilepsy/lh.fwhm${FWHM}.depth"
			nb=$[${nb}+1]
		fi

		if [ ! -f  ${DIR}/epilepsy/rh.fwhm${FWHM}.depth ]
		then
			echo "not ${DIR}/epilepsy/rh.fwhm${FWHM}.depth"
			nb=$[${nb}+1]
		fi

		if [ ! -f  ${DIR}/epilepsy/rh.fwhm${FWHM}.fsaverage.depth.mgh ]
		then
			echo "not ${DIR}/epilepsy/rh.fwhm${FWHM}.fsaverage.depth.mgh"
			nb=$[${nb}+1]
		fi
		
		if [ ! -f  ${DIR}/epilepsy/lh.fwhm${FWHM}.fsaverage.depth.mgh ]
		then
			echo "not ${DIR}/epilepsy/lh.fwhm${FWHM}.fsaverage.depth.mgh"
			nb=$[${nb}+1]
		fi


		if [ ! -f  ${DIR}/epilepsy/lh.fwhm${FWHM}.fsaverage.curv.mgh ]
		then
			echo "not ${DIR}/epilepsy/lh.fwhm${FWHM}.fsaverage.curv.mgh"
			nb=$[${nb}+1]
		fi

		if [ ! -f  ${DIR}/epilepsy/rh.fwhm${FWHM}.fsaverage.curv.mgh ]
		then
			echo "not ${DIR}/epilepsy/rh.fwhm${FWHM}.fsaverage.curv.mgh"
			nb=$[${nb}+1]
		fi

		if [ ! -f ${DIR}/epilepsy/lh.fwhm${FWHM}.fsaverage.complexity.mgh  ]
		then
			echo "not ${DIR}/epilepsy/lh.fwhm${FWHM}.fsaverage.complexity.mgh"
			nb=$[${nb}+1]
		fi

		if [ ! -f  ${DIR}/epilepsy/rh.fwhm${FWHM}.fsaverage.complexity.mgh ]
		then
			echo "not ${DIR}/epilepsy/rh.fwhm${FWHM}.fsaverage.complexity.mgh"
			nb=$[${nb}+1]
		fi

		if [ ! -f  ${DIR}/epilepsy/lh.fwhm${FWHM}.fsaverage.jacobian.mgh ]
		then
			echo "not ${DIR}/epilepsy/lh.fwhm${FWHM}.fsaverage.jacobian.mgh"
			nb=$[${nb}+1]
		fi

		if [ ! -f ${DIR}/epilepsy/rh.fwhm${FWHM}.fsaverage.jacobian.mgh  ]
		then
			echo "not ${DIR}/epilepsy/rh.fwhm${FWHM}.fsaverage.jacobian.mgh"
			nb=$[${nb}+1]
		fi

		if [ ! -f  ${DIR}/epilepsy/lh.fwhm${FWHM}.jacobian.mgh ]
		then
			echo "not ${DIR}/epilepsy/lh.fwhm${FWHM}.jacobian.mgh"
			nb=$[${nb}+1]
		fi

		if [ ! -f  ${DIR}/epilepsy/rh.fwhm${FWHM}.jacobian.mgh ]
		then
			echo "not ${DIR}/epilepsy/rh.fwhm${FWHM}.jacobian.mgh"
			nb=$[${nb}+1]
		fi


		###FLAIR



		if [ ! -f  ${DIR}/epilepsy/lh.fwhm${FWHM}.flair_nuc.dxyz ]
		then
			echo "not ${DIR}/epilepsy/lh.fwhm${FWHM}.flair_nuc.dxyz"
			nb=$[${nb}+1]
		fi

		if [ ! -f ${DIR}/epilepsy/rh.fwhm${FWHM}.flair_nuc.dxyz  ]
		then
			echo "not ${DIR}/epilepsy/rh.fwhm${FWHM}.flair_nuc.dxyz"
			nb=$[${nb}+1]
		fi

		if [ ! -f  ${DIR}/epilepsy/lh.fwhm${FWHM}.flair_nuc.fsaverage.dxyz.mgh ]
		then
			echo "not ${DIR}/epilepsy/lh.fwhm${FWHM}.flair_nuc.fsaverage.dxyz.mgh"
			nb=$[${nb}+1]
		fi

		if [ ! -f  ${DIR}/epilepsy/rh.fwhm${FWHM}.flair_nuc.fsaverage.dxyz.mgh ]
		then
			echo "not ${DIR}/epilepsy/rh.fwhm${FWHM}.flair_nuc.fsaverage.dxyz.mgh"
			nb=$[${nb}+1]
		fi

		if [ ! -f  ${DIR}/epilepsy/lh.fwhm${FWHM}.flair_nuc.intensity ]
		then
			echo "not ${DIR}/epilepsy/lh.fwhm${FWHM}.flair_nuc.intensity"
			nb=$[${nb}+1]
		fi

		if [ ! -f ${DIR}/epilepsy/rh.fwhm${FWHM}.flair_nuc.intensity  ]
		then
			echo "not ${DIR}/epilepsy/rh.fwhm${FWHM}.flair_nuc.intensity "
			nb=$[${nb}+1]
		fi

		if [ ! -f  ${DIR}/epilepsy/lh.fwhm${FWHM}.flair_nuc.fsaverage.intensity.mgh ]
		then
			echo "not ${DIR}/epilepsy/lh.fwhm${FWHM}.flair_nuc.fsaverage.intensity.mgh"
			nb=$[${nb}+1]
		fi

		if [ ! -f ${DIR}/epilepsy/rh.fwhm${FWHM}.flair_nuc.fsaverage.intensity.mgh  ]
		then
			echo "not ${DIR}/epilepsy/rh.fwhm${FWHM}.flair_nuc.fsaverage.intensity.mgh"
			nb=$[${nb}+1]
		fi
		
		
		###PET


		if [ ! -f  ${DIR}/epilepsy/lh.fwhm${FWHM}.pet ]
		then
			echo "not ${DIR}/epilepsy/lh.fwhm${FWHM}.pet "
			nb=$[${nb}+1]
		fi

		if [ ! -f  ${DIR}/epilepsy/rh.fwhm${FWHM}.pet ]
		then
			echo "not ${DIR}/epilepsy/rh.fwhm${FWHM}.pet "
			nb=$[${nb}+1]
		fi
		
		if [ ! -f  ${DIR}/epilepsy/lh.fwhm${FWHM}.fsaverage.pet.mgh ]
		then
			echo "not ${DIR}/epilepsy/lh.fwhm${FWHM}.fsaverage.pet.mgh "
			nb=$[${nb}+1]
		fi

		if [ ! -f  ${DIR}/epilepsy/rh.fwhm${FWHM}.fsaverage.pet.mgh ]
		then
			echo "not ${DIR}/epilepsy/rh.fwhm${FWHM}.fsaverage.pet.mgh"
			nb=$[${nb}+1]
		fi	
		
		
done


echo "${nb}"
if [ ${nb} -eq 0 ]
then
	echo "${FILE} : Surface_features complete"
else
	echo "${FILE} : ${nb} files missing"
fi

myvar=$(echo * || nb '\$')

