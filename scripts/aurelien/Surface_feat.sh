#!/bin/bash

SD=$1
SUBJ=$2
RES=$3

DIR="${SD}/${SUBJ}"
SUBJECTS_DIR=${SD}

# Create ASL directory if needed
if [ ! -d ${DIR}/$RES ]
then
	mkdir ${DIR}/$RES
fi

#if [ ! -d ${DIR}/pet ]
#then
#	mkdir ${DIR}/pet
#fi

#####################################
#matlab -nodisplay <<EOF
#% Load Matlab Path
#cd ${HOME}
#p = pathdef;
#addpath(p);
#cd ${DIR}
 
#inner_surf = SurfStatReadSurf1('${DIR}/surf/lh.white');
#outer_surf = SurfStatReadSurf1('${DIR}/surf/lh.pial');

#mid_surf.coord = (inner_surf.coord + outer_surf.coord) ./ 2;
#mid_surf.tri = inner_surf.tri;

#freesurfer_write_surf('${DIR}/surf/lh.mid', mid_surf.coord', mid_surf.tri);

#inner_surf = SurfStatReadSurf('${DIR}/surf/rh.white');
#outer_surf = SurfStatReadSurf('${DIR}/surf/rh.pial');

#mid_surf.coord = (inner_surf.coord + outer_surf.coord) ./ 2;
#mid_surf.tri = inner_surf.tri;

#freesurfer_write_surf('${DIR}/surf/rh.mid', mid_surf.coord', mid_surf.tri);
#EOF
###############################################

mri_convert ${DIR}/$RES/mean.nii ${DIR}/$RES/ASL.mgz
#mri_convert $DIR/pet/PETrecal.mnc $DIR/pet/PET.mgz
### Project ASL on T1 surface
mri_vol2surf --mov $DIR/$RES/ASL.mgz --hemi lh --surf white --o lh.asl.w --regheader ${SUBJ} --out_type paint --fwhm 3
mri_vol2surf --mov $DIR/$RES/ASL.mgz --hemi rh --surf white --o rh.asl.w --regheader ${SUBJ} --out_type paint --fwhm 3

#mri_vol2surf --mov ${DIR}/pet/PET.mgz --hemi lh --surf mid --o lh.pet.w --regheader ${SUBJ} --out_type paint --fwhm 10
#mri_vol2surf --mov ${DIR}/pet/PET.mgz --hemi rh --surf mid --o rh.pet.w --regheader ${SUBJ} --out_type paint --fwhm 10

echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.asl.w lh.asl.curv"
mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.asl.w lh.asl.curv
#mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.pet.w lh.pet.curv

echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.asl.w rh.asl.curv"
mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.asl.w rh.asl.curv
#mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.pet.w rh.pet.curv

mv ${DIR}/surf/lh.asl.curv ${DIR}/$RES/lh.asl.curv
mv ${DIR}/surf/rh.asl.curv ${DIR}/$RES/rh.asl.curv

#mv ${DIR}/surf/lh.pet.curv ${DIR}/pet/lh.pet.curv
#mv ${DIR}/surf/rh.pet.curv ${DIR}/pet/rh.pet.curv

#rm -f ${DIR}/surf/lh.asl.w ${DIR}/surf/rh.asl.w
#rm -f ${DIR}/surf/lh.pet.w ${DIR}/surf/rh.pet.w


# Resample asl and pet to fsaverage
echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/asl/lh.asl.curv --sfmt curv --noreshape --no-cortex --tval ${DIR}/asl/lh.fsaverage.asl.curv --tfmt curv"
mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/$RES/lh.asl.curv --sfmt curv --noreshape --no-cortex --tval ${DIR}/$RES/lh.fsaverage.asl.mgh --tfmt curv --fwhm 3

#mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/pet/lh.pet.curv --sfmt curv --noreshape --no-cortex --tval ${DIR}/pet/lh.fsaverage.pet.curv --tfmt curv --fwhm 10

echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/asl/rh.asl.curv --sfmt curv --noreshape --no-cortex --tval ${DIR}/asl/rh.fsaverage.asl.curv --tfmt curv"
mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/$RES/rh.asl.curv --sfmt curv --noreshape --no-cortex --tval ${DIR}/$RES/rh.fsaverage.asl.mgh --tfmt curv --fwhm 3

#mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/pet/rh.pet.curv --sfmt curv --noreshape --no-cortex --tval ${DIR}/pet/rh.fsaverage.pet.curv --tfmt curv --fwhm 10

echo "entrée pour quitter"
read q
echo "kthxbye"
