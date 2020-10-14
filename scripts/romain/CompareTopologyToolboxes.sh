#!/bin/bash

matlab -nodisplay <<EOF

cd /home/romain/SVN/matlab/romain/matlab_bgl/

load('/NAS/dumbo/HBC/Freesurfer5.0/$1/connectome/Connectome_Struc_Voxel.mat')

tic
cc_bgl = clustering_coefficients(connectomeVox);
toc

cd /home/romain/SVN/matlab/romain/gaimc-master/
tic
cc_gaimc = clustercoeffs(connectomeVox,1,1);
toc

tic
cc_bct=clustering_coef_wu(connectomeVox);
toc

cd /NAS/dumbo/HBC/Freesurfer5.0/$1/connectome

save('clustering_coefficients.mat','cc_bgl','cc_gaimc','cc_bct') 
EOF
