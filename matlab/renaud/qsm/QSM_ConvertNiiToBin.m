function QSM_ConvertNiiToBin(niiFile,outFile,outformat)

%%
% usage : QSM_ConvertNiiToBin('/path/Mask.nii','/path/Mask.bin','int32');
%
% Convert nii file to bin file
% 
% Inputs :
%    niiFile     : nii file (ex: Mask.nii)
%    outFile     : bin file (ex: Mask.bin)
%    outformat   : form and size of results (ex: 'int32')
%
% Renaud Lopes @ CHRU Lille, Nov 2016
%
%%

% read nifti file
hdr = spm_vol(niiFile);
M   = spm_read_vols(hdr);
M   = M(:,end:-1:1,end:-1:1);
M   = M(:);

% write bin file
fid=fopen(outFile,'w');
fwrite(fid,M,outformat);
