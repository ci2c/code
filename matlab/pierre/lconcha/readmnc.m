function data = readmnc(fname,scale)
%
% function data = readmnc(fname,scale)
%
% Read a mnc file into matlab as a 3D matrix.
%
% fname :   The mnc file.
% scale :   A scaling factor to apply to the image volume. Use scale=0 for
%           no scaling (use original data, default).
%
%
% See also: savemnc
% Luis Concha. BIC MNI McGill. January 2008.

if nargin < 2
    scale = 0;
end

% First we need to use a temporary nii file
[success,message,messageid] = fileattrib('/tmp/')
if message.UserWrite
   tmpFolder = '/tmp/';
else
	tmpFolder    = '/data/noel/noel2/luis/tmp/'
end

tmpFileName  = [tmpFolder 'tmp' num2str(floor(now)) '.nii']
tmpFileName2 = [tmpFolder 'tmp' num2str(floor(now)) '.txt']

% Look for spaces in file names
fname = regexprep(fname,'\s','\\ ');
tmpFileName = regexprep(tmpFileName,'\s','\\ ');

disp(['!mnc2nii -double ' fname ' ' tmpFileName ' > ' tmpFileName2])
eval(['!mnc2nii -double ' fname ' ' tmpFileName ' > ' tmpFileName2])

% get the info
% eval(['!mincinfo ' fname ' > ' tmpFileName2])
% eval(['!rm ' tmpFileName2])

% now read the nii and reshape the data for proper orientation
nii     = load_nii(tmpFileName);
nii.img = permute(nii.img,[2 1 3]);
nii.img = flipdim(nii.img,1);
data    = nii.img;
%assignin('base','nii',nii);

% Finally, delete the temporary nii file
eval(['!rm ' tmpFileName])
eval(['!rm ' tmpFileName2])

% SCALE THE DATA
if scale == 0
    disp('Rescaling using the nii header to get back original data.');  
    data = (data - nii.original.hdr.dime.scl_inter) ./ nii.original.hdr.dime.scl_slope;
else
    data = data.*scale;
end


