#!/bin/bash

cmd="freeview "
for good_output in $*
do
	cmd="${cmd} -v ${good_output}/mri/T1.mgz ${good_output}/mri/wm.mgz ${good_output}/mri/brainmask.mgz ${good_output}/mri/aseg.mgz:colormap=lut:opacity=0.2 "
	cmd="${cmd} -f ${good_output}/surf/lh.white:edgecolor=blue ${good_output}/surf/lh.pial:edgecolor=red ${good_output}/surf/rh.white:edgecolor=blue ${good_output}/surf/rh.pial:edgecolor=red"
done
echo "${cmd}"; eval "${cmd} &"



