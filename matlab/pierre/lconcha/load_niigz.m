function nii = load_niigz(filename)


eval(['!gunzip ' filename])

nozipFname = regexprep(filename,'\.gz','');
nii = load_nii(nozipFname);

eval(['!gzip ' nozipFname])


