function QSM_GeneratePhantomMask(magFile,outFile,clusFile)

%%
% usage : QSM_GeneratePhantomMask('/path/magnitude_echo1.nii','/path/mask.nii');
%
% Generate mask file based on phantom acquisition
% 
% Inputs :
%    magFile     : nifti file of magnitude image
%    outFile     : nifti file for output mask
% 
% Options
%    clusFile    : nifti file for kmeans result (default: [])
%
% Renaud Lopes @ CHRU Lille, Nov 2016


% read data
hdr = spm_vol(magFile);
V = spm_read_vols(hdr);

% dimension
dim = size(V);

% kmeans
V = V(:);
[cidx, ctrs] = kmeans(V, 3, 'Replicates', 5);

% save kmeans result
if nargin == 3
    tmp = reshape(cidx,dim);
    hdr.fname = clusFile;
    spm_write_vol(hdr,tmp);
end

% post-processing
[maxV,maxidx] = max([length(find(cidx==1)) length(find(cidx==2)) length(find(cidx==3))]);
cidx(find(cidx==maxidx))=0;
cidx(find(cidx~=0))=1;
cidx = reshape(cidx,dim);

% create mask file
hdr.fname = outFile;
spm_write_vol(hdr,cidx);
