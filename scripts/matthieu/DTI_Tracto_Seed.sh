#!/bin/bash

if [ $# -lt 6 ]
then
	echo ""
	echo "Usage: DTI_Tracto_Seed.sh -seed <SeedOrigin> -rad <Radius> -subjid <SubjId> -od <OutputDir> -lmax <NbHarmonic> -Nfiber <NbFibers>"
	echo ""
	echo "  -seed		: Origin of the seed coordinates for tractography"
	echo "  -radius		: Radius used from seed for tractography"
	echo "  -subjid		: Subject ID"
	echo "  -od		: Path to output directory (processing results)"
	echo "  -lmax		: Maximum harmonic order"
	echo "  -Nfiber		: Number of fibers generated"
	echo ""
	echo "Usage:  DTI_Tracto_Seed.sh -seed <SeedOrigin> -rad <Radius> -subjid <SubjId> -od <OutputDir> -lmax <NbHarmonic> -Nfiber <NbFibers>"
	echo ""
	exit 1
fi

## I/O management
SEED_ORIGIN=$1
Radius=$2
SUBJ_ID=$3
DTI=$4
lmax=$5
Nfiber=$6

if [ ! -e ${DTI}/${SEED_ORIGIN}_${lmax}_${Nfiber}.tck ]
then
	# Stream locally to avoid RAM filling
	rm -f /tmp/${SUBJ_ID}_${SEED_ORIGIN}_${lmax}_${Nfiber}.tck
	SeedCoord=$(cat ${DTI}/${SEED_ORIGIN}.txt)
	streamtrack -debug -info SD_PROB ${DTI}/CSD${lmax}.mif -seed ${SeedCoord},${Radius} -mask ${DTI}/mdti_finalcor_brain_mask.mif /tmp/${SUBJ_ID}_${SEED_ORIGIN}_${lmax}_${Nfiber}.tck -num ${Nfiber}
	
	cp -f /tmp/${SUBJ_ID}_${SEED_ORIGIN}_${lmax}_${Nfiber}.tck ${DTI}/${SEED_ORIGIN}_${lmax}_${Nfiber}.tck
	rm -f /tmp/${SUBJ_ID}_${SEED_ORIGIN}_${lmax}_${Nfiber}.tck
fi

# if [ ! -e ${DTI}/${SEED_ORIGIN}_${lmax}_${Nfiber}_part000001.tck ]
# then
# 	# Cut the fiber file into small matlab files
# 	matlab -nodisplay <<EOF
# 	split_fibers('${DTI}/${SEED_ORIGIN}_${lmax}_${Nfiber}.tck', '${DTI}', '${SEED_ORIGIN}_${lmax}_${Nfiber}');
# EOF
# fi

# if [ ! -e ${DTI}/${SEED_ORIGIN}_${lmax}_${Nfiber}.vtk ]
# then
# 	matlab -nodisplay <<EOF
# 	tracts = f_readFiber_tck('${DTI}/${SEED_ORIGIN}_${lmax}_${Nfiber}.tck');
# 	tract_out = color_tracts(tracts);
# 	save_tract_vtk(tract_out,'${DTI}/${SEED_ORIGIN}_${lmax}_${Nfiber}.vtk');
# EOF
# fi