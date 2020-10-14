function applyParcellation(fsdir, subj, annot)
% usage : applyParcellation(fsdir, subj, annot)
%
% Inputs :
%    fsdir            : equivalent to FS SUBJECTS_DIR
%    subj             : subject name
%    annot            : annotation to divide (i.e. aparc.a2009s)
%                The two files lh.$annot and rh.$annot are expected to be
%                found in $fsdir/fsaverage/label
%
% Pierre Besson @ CHRU Lille, Jun 2012

if nargin ~= 3
    error('invalid usage');
end

% offsets used for left / right distinction
offset_lh = 10000;
offset_rh = 20000;

% set some path
LUT_path_fsav = [fsdir, '/fsaverage/label/', annot, 'LUT.txt'];
LUT_path_subj = [fsdir, '/', subj, '/label/', annot, 'LUT.txt'];
path_white_lh = [fsdir, '/', subj, '/surf/lh.white'];
path_white_rh = [fsdir, '/', subj, '/surf/rh.white'];
path_pial_lh = [fsdir, '/', subj, '/surf/lh.pial'];
path_pial_rh = [fsdir, '/', subj, '/surf/rh.pial'];

% resample fsaverage annotation to individual annotation
Template2Indiv(fsdir, subj, [annot, '.annot']);

% copy colorLUT
[s,w] = unix(['cp -f ' LUT_path_fsav ' ' LUT_path_subj]);

% create the aseg volume
[s,w] = unix(['mri_convert ', fsdir, '/', subj, '/mri/aparc.a2009s+aseg.mgz ', fsdir, '/', subj, '/mri/', annot, '.nii --out_orientation RAS']);

[vertices, label_lh, colortable_lh] = read_annotation([fsdir, '/', subj, '/label/lh.', annot, '.annot']);
[vertices, label_rh, colortable_rh] = read_annotation([fsdir, '/', subj, '/label/rh.', annot, '.annot']);

correct_aseg(label_rh, colortable_rh, offset_rh, path_white_rh, path_pial_rh, [fsdir, '/', subj, '/mri/', annot, '.nii']);
correct_aseg(label_lh, colortable_lh, offset_lh, path_white_lh, path_pial_lh, [fsdir, '/', subj, '/mri/', annot, '.nii']);

% post-proc
[s,w] = unix(['mri_convert ', fsdir, '/', subj, '/mri/', annot, '.nii ', fsdir, '/', subj, '/mri/', annot, '.mgz']);
delete([fsdir, '/', subj, '/mri/', annot, '.nii']);

% stats of the new parcellation
[s,w] = unix(['SUBJECTS_DIR=' fsdir '; mris_anatomical_stats -mgz -cortex ' fsdir '/' subj '/label/lh.cortex.label -f ' fsdir '/' subj '/stats/lh.' annot '.stats -b -a ' fsdir '/' subj '/label/lh.' annot '.annot -c ' fsdir '/' subj '/label/' annot '.ctab ' subj ' lh white']);
[s,w] = unix(['SUBJECTS_DIR=' fsdir '; mris_anatomical_stats -mgz -cortex ' fsdir '/' subj '/label/rh.cortex.label -f ' fsdir '/' subj '/stats/rh.' annot '.stats -b -a ' fsdir '/' subj '/label/rh.' annot '.annot -c ' fsdir '/' subj '/label/' annot '.ctab ' subj ' rh white']);