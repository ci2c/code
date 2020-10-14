function [moy,stdev] = MeanFA_OneRoi(fafile,roifile,threshval)

[hdr,roi] = niak_read_nifti(roifile);
roi       = roi(:);
ind       = find(roi>threshval);
clear hdr roi;

[hdr,fa]  = niak_read_nifti(fafile);
fa        = fa(:);
clear hdr;

moy   = mean(fa(ind));
stdev = std(fa(ind)); 

clear fa ind;