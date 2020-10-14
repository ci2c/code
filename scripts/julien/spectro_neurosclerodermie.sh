#!/bin/sh

cd /NAS/dumbo/protocoles/neurosclerodermie/data/

for subject in $(ls -d *)
do
#echo ${subject}

	cd /NAS/dumbo/protocoles/neurosclerodermie/data/${subject}/spectro/
	for spectro in $(ls *.SDAT)
	do
		#echo ${spectro}
		spectro_analyse.sh -i /NAS/dumbo/protocoles/neurosclerodermie/data/${subject}/spectro/${spectro} -o /NAS/dumbo/protocoles/neurosclerodermie/output/ -s ${subject}
	done
	




done
