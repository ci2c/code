function Template2Indiv(Subjdir, Subj, parcname)
% Usage : Template2Indiv(SUBJDIR, SUBJ, PARCNAME)
%
% Parcellate individual's surface based on template surface parcellation
%
% SUBJDIR     : Equivalent to FreeSurfer ${SUBJECTS_DIR}
% SUBJ        : ID (name) of the subject to process. 
%                  Example : SUBJ = 'patient1'
% PARCNAME    : Name of parcellation file to use 
%                  Example : PARCNAME='aparc.a2009s.annot'
%
% Pierre Besson, 2010

if nargin ~= 3
    error('Invalid usage');
end


[s,w] = unix(['SUBJECTS_DIR=', Subjdir, '; mri_surf2surf --srcsubject fsaverage --srchemi lh --srcsurfreg sphere.reg --trgsubject ', Subj, ' --trghemi lh --trgsurfreg sphere.reg --sval-annot ', parcname, ' --tval ', Subjdir, '/', Subj, '/label/lh.', parcname]);
[s,w] = unix(['SUBJECTS_DIR=', Subjdir, '; mri_surf2surf --srcsubject fsaverage --srchemi rh --srcsurfreg sphere.reg --trgsubject ', Subj, ' --trghemi rh --trgsurfreg sphere.reg --sval-annot ', parcname, ' --tval ', Subjdir, '/', Subj, '/label/rh.', parcname]);

% Read fsaverage parcellations
% try
%     Path=strcat(Subjdir, '/fsaverage/label/lh.', parcname);
%     [vertices, FS_label_left, left_colortable] = read_annotation(Path);
%     
%     Path=strcat(Subjdir, '/fsaverage/label/rh.', parcname);
%     [vertices, FS_label_right, right_colortable] = read_annotation(Path);
% catch
%     error('Invalid PARCNAME');
% end
% 
% % Read fsaverage sphere
% Path=strcat(Subjdir, '/fsaverage/surf/lh.sphere.reg');
% fsav_surf_left = SurfStatReadSurf(Path);
% offset = repmat(mean(fsav_surf_left.coord, 2), 1, size(fsav_surf_left.coord, 2));
% fsav_surf_left.coord = fsav_surf_left.coord - offset;
% Path=strcat(Subjdir, '/fsaverage/surf/rh.sphere.reg');
% fsav_surf_right = SurfStatReadSurf(Path);
% offset = repmat(mean(fsav_surf_right.coord, 2), 1, size(fsav_surf_right.coord, 2));
% fsav_surf_right.coord = fsav_surf_right.coord - offset;
% 
% 
% % Read subject data
% Path=strcat(Subjdir, '/', Subj, '/surf/lh.sphere.reg');
% subj_surf_left = SurfStatReadSurf(Path);
% offset = repmat(mean(subj_surf_left.coord, 2), 1, size(subj_surf_left.coord, 2));
% subj_surf_left.coord = subj_surf_left.coord - offset;
% Path=strcat(Subjdir, '/', Subj, '/surf/rh.sphere.reg');
% subj_surf_right = SurfStatReadSurf(Path);
% offset = repmat(mean(subj_surf_right.coord, 2), 1, size(subj_surf_right.coord, 2));
% subj_surf_right.coord = subj_surf_right.coord - offset;
% 
% 
% % Interpolate labels on subject's sphere
% Subj_label_left = griddata3(fsav_surf_left.coord(1,:)', fsav_surf_left.coord(2,:)', fsav_surf_left.coord(3,:)', FS_label_left, subj_surf_left.coord(1,:)', subj_surf_left.coord(2,:)', subj_surf_left.coord(3,:)', 'nearest');
% Subj_label_right = griddata3(fsav_surf_right.coord(1,:)', fsav_surf_right.coord(2,:)', fsav_surf_right.coord(3,:)', FS_label_right, subj_surf_right.coord(1,:)', subj_surf_right.coord(2,:)', subj_surf_right.coord(3,:)', 'nearest');
% 
% 
% % Save interpolated subject labels
% Path=strcat(Subjdir, '/', Subj, '/label/lh.', parcname);
% write_annotation(Path, (0:length(subj_surf_left.coord)-1)', Subj_label_left', left_colortable);
% Path=strcat(Subjdir, '/', Subj, '/label/rh.', parcname);
% write_annotation(Path, (0:length(subj_surf_right.coord)-1)', Subj_label_right', right_colortable);