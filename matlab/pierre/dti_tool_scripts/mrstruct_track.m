function mrstruct_track(mrstruct_name, start_fa, start_tr, stop_fa, stop_tr, max_angle, rand_sampling, min_vox, rand_samp_no)
%
% usage : mrstruct_track(MRSTRUCT_TENSORS_NAME [, START_FA, START_TRACE, STOP_FA, STOP_TRACE, MAX_ANGLE, RANDOM_SAMPLING, MIN_VOX, RANDOM_SAMPLING_NUMBER])
%
%   Inputs :
%        MRSTRUCT_TENSORS_NAME   : path to the mrstruct tensors .mat to complete (i.e.
%                                   '/path/to/your/file/my_mrstruct_DTD.mat')
%
%   Options :
%        START_FA                : fiber start FA threshold (default : 0.25)
%        START_TRACE             : fiber start trace thrshold (default : 0.0016)
%        STOP_FA                 : fiber stop FA threshold (default : 0.15)
%        STOP_TRACE              : fiber stop trace threshold (default : 0.002)
%        MAX_ANGLE               : fiber angle termination (default : 53.1)
%        RANDOM_SAMPLING         : use random sampler (default : no (=2)) yes = 1
%        MIN_VOX                 : minimum voxel fiber length (default : 5)
%        RANDON_SAMPLING_NUMBER  : number of fiber per voxel (default : 2)
%
% 
% example : mrstruct_track('/my/mrstruct_DTD.mat', 0.2, [], 0.1)
%
% Pierre Besson @ CHRU Lille, May 2011

if nargin < 1 | nargin > 9
    error('invalid usage');
end

if nargin < 2 | isempty(start_fa)
    start_fa = 0.25;
end

if nargin < 3 | isempty(start_tr)
    start_tr = 0.0016;
end

if nargin < 4 | isempty(stop_fa)
    stop_fa = 0.15;
end

if nargin < 5 | isempty(stop_tr)
    stop_tr = 0.002;
end

if nargin < 6 | isempty(max_angle)
    max_angle = 53.1;
end

if nargin < 7 | isempty(rand_sampling)
    rand_sampling = 2;
end

if nargin < 8 | isempty(min_vox)
    min_vox = 5;
end

if nargin < 9 | isempty(rand_samp_no)
    rand_samp_no = 2;
end


matlabbatch{1}.dtijobs.tracking.mori.filename = {mrstruct_name};
matlabbatch{1}.dtijobs.tracking.mori.start.startthreshold.startfaLim = start_fa;
matlabbatch{1}.dtijobs.tracking.mori.start.startthreshold.startTrLim = start_tr;
matlabbatch{1}.dtijobs.tracking.mori.stop.stopthreshold.stopfaLim = stop_fa;
matlabbatch{1}.dtijobs.tracking.mori.stop.stopthreshold.stopTrLim = stop_tr;
matlabbatch{1}.dtijobs.tracking.mori.maxangle = max_angle;
matlabbatch{1}.dtijobs.tracking.mori.randsampler = rand_sampling;
matlabbatch{1}.dtijobs.tracking.mori.minvox = min_vox;
matlabbatch{1}.dtijobs.tracking.mori.randsampno = rand_samp_no;
matlabbatch{1}.dtijobs.tracking.mori.newmorifile.auto = 1;

inputs = cell(0, 1);
spm('defaults', 'PET');
spm_jobman('serial', matlabbatch, '', inputs{:});