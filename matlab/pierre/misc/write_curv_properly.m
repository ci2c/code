function write_curv_properly(curv, fname, SD, SUBJID)
% usage : write_curv_properly(CURV, FNAME, [SD, SUBJID])
%
% Write a curv file CURV into the file FNAME.
% Does it properly so it can be opened with tksurfer and freeview
% 
% Inputs :
%      CURV       : Vector of the surface feature
%      FNAME      : Output name (must begin with lh. or rh.)
%      SD         : Subjects directory. 
%                     If not specified, system default SD is used.
%      SUBJID     : Subject ID.
%                     If not specified, fsaverage is used.
%      
%
% Pierre Besson @ CHRU Lille, Apr. 2011

if nargin < 2 && nargin > 4
    error('invalid usage');
end

% Manage inputs
if size(curv, 1) > size(curv, 2)
    curv = curv';
end

if ~isempty(findstr(fname, 'lh.'))
    hemi='lh';
else
    if ~isempty(findstr(fname, 'rh.'))
        hemi='rh';
    else
        error('FNAME should begin by either lh. or rh.');
    end
end

if nargin < 4
    SUBJID='fsaverage';
end


% Do the stuff
Temp = strcat(fname, '.temp');
SurfStatWriteData(Temp, curv, 'b');

if nargin < 3
    [s, m] = unix(['mri_surf2surf --s ', SUBJID, ' --hemi ', hemi, ' --sval ', Temp, ' --sfmt curv --tval ', fname, ' --tfmt curv']);
    delete(Temp);
else
    [s, m] = unix(['SUBJECTS_DIR=', SD, '; mri_surf2surf --s ', SUBJID, ' --hemi ', hemi, ' --sval ', Temp, ' --sfmt curv --tval ', fname, ' --tfmt curv']);
    delete(Temp);
end