#!/bin/bash

cmd="freeview -f "
for good_output in $*
do
	for lat in lh rh
	do
		cmd="${cmd} ${good_output}/surf/${lat}.pial:annot=aparc.annot:name=pial_aparc:visible=0 \
	${good_output}/surf/${lat}.pial:annot=aparc.a2009s.annot:name=pial_aparc_des:visible=0 \
	${good_output}/surf/${lat}.inflated:overlay=${lat}.thickness:overlay_threshold=0.1,3::name=inflated_thickness:visible=0 \
	${good_output}/surf/${lat}.inflated:visible=0 \
	${good_output}/surf/${lat}.white:visible=0 \
	${good_output}/surf/${lat}.pial "
	done
done
cmd="${cmd} --viewport 3d"
echo "${cmd}"; eval "${cmd} &"



