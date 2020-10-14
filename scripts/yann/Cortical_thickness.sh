#!/bin/bash

index=1

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	
	-fs)
		fs=`expr $index + 1`
		eval fs=\${$fs}
		echo "FS_dir : $fs"
		;;
	-subj)
		i=$[$index+1]
		eval infile=\${$i}
		subj=""
		while [ "$infile" != "-fs" -a $i -le $# ]
		do
		 	subj="${subj} ${infile}"
		 	i=$[$i+1]
		 	eval infile=\${$i}
		done
		index=$[$i-1]
		echo "subj : $subj"
		;;
	esac
	index=$[$index+1]
done

for SUBJ in ${subj}
do	
	DIR=${fs}/${SUBJ}
	cd ${DIR}/surf
	SUBJECTS_DIR=${fs}
echo "mri_surf2surf --hemi rh --srcsubject ${SUBJ} --src_type curv --srcsurfval thickness --fwhm 5 --trgsubject ${SUBJ} --trgsurfval ${SUBJ}/surf/rh.thickness_lissee --trg_type curv"
mri_surf2surf --hemi rh --srcsubject ${SUBJ} --src_type curv --srcsurfval thickness --fwhm 5 --trgsubject ${SUBJ} --trgsurfval ${DIR}/surf/rh.thickness_lissee --trg_type curv
echo "mri_surf2surf --hemi lh --srcsubject ${SUBJ} --src_type curv --srcsurfval thickness --fwhm 5 --trgsubject ${SUBJ} --trgsurfval ${SUBJ}/surf/lh.thickness_lissee --trg_type curv"
mri_surf2surf --hemi lh --srcsubject ${SUBJ} --src_type curv --srcsurfval thickness --fwhm 5 --trgsubject ${SUBJ} --trgsurfval ${DIR}/surf/lh.thickness_lissee --trg_type curv

matlab <<EOF
l = read_curv('${DIR}/surf/lh.thickness_lissee');
r = read_curv('${DIR}/surf/rh.thickness_lissee');
b = [l'  r'];
s = SurfStatReadSurf({'${DIR}/surf/lh.pial','${DIR}/surf/rh.pial'});

SurfStatViewData(b,s,'${SUBJ},Epaisseur corticale (mm)'), SurfStatColLim( [0.5 3] );
set(gcf,'PaperPosition',[-14.482 5.882 70 40],'Position',[1 1 1680 617]);
saveas(gcf,'${SUBJ}.png','png');
EOF
done


