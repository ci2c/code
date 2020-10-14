#!/bin/bash

out_type=$1
WD=/NAS/dumbo/gadeline/memoire/shape
#phiFile=/NAS/dumbo/nicolas/CHOPA/ShapeAnalysis/caudeg_shape/aaa.caudeg_bin_close_to_template_paraPhi.txt
#thetaFile=/NAS/dumbo/nicolas/CHOPA/ShapeAnalysis/caudeg_shape/aaa.caudeg_bin_close_to_template_paraTheta.txt

phiPar="--visMode DistanceMap --distMapMin 0 --distMapMax 6.28 --br 255 --bg 255 --bb 255"
thetaPar="--visMode DistanceMap --distMapMin 0 --distMapMax 3.14 --br 255 --bg 255 --bb 255 "
# ${WD}/${out_type}/${I%SPHARM_ellalign.meta}_paraPhi.txt
# ${WD}/${out_type}/${I%SPHARM_ellalign.meta}_paraTheta.txt

# for out_type in output_caudate_l output_caudate_r output_pallidum_l output_pallidum_r output_putamen_l output_putamen_r
	for I in `ls ${WD}/${out_type} | grep templateSPHARM_ellalign.meta`
	do
		KWMeshVisu --mesh ${WD}/${out_type}/${I} --image ${WD}/${out_type}/${I%.meta}_phi.bmp --scalar ${WD}/${out_type}/${I%SPHARM_ellalign.meta}_paraPhi.txt ${phiPar}
		sleep 1
		KWMeshVisu --mesh ${WD}/${out_type}/${I} --image ${WD}/${out_type}/${I%.meta}_theta.bmp --scalar ${WD}/${out_type}/${I%SPHARM_ellalign.meta}_paraTheta.txt ${thetaPar}
		sleep 1
	done
