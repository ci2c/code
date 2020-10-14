function [lambdas,info]= load_lambdas_mnc(lambdasFnameBase)


e1       = readmnc([lambdasFnameBase '1.mnc']);
e1       = flipdim(e1,1);
e2       = readmnc([lambdasFnameBase '2.mnc']);
e2       = flipdim(e2,1);
e3       = readmnc([lambdasFnameBase '3.mnc']);
e3       = flipdim(e3,1);

info     = mnc_info([lambdasFnameBase '1.mnc']);
dims     = size(e1);
voxDim   = abs([info.xspace.step;info.yspace.step;info.zspace.step])';
w_dims   = dims .* voxDim;

lambdas = cat(4,e1,e2,e3);

disp('Finished loading lambdas');