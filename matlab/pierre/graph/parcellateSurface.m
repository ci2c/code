function parcellateSurface(fpath, cases, fname, nROI)
% Usage : parcellateSurface(fpath, cases, fname, nROI)
%
% Save parcellated surface
%
% fpath   : path to the cases direcroty (equivalent to ${SUBJECTS_DIR})
% cases   : array of strings containing IDs of the cases to process. For
%     example : cases = {'patient1', 'patient023', 'NameP03'};
% fname   : Name of outfile (hemi.fname.annot in surf directory)
% nROI    : Number of ROIs per hemisphere

if nargin ~= 4
    error('Invalid usage');
end

% Store ROIs in a table
R = eq_regions(2, nROI, 'offset', 'extra');
[phi, theta] = sphgrid(512, 1024, 'withpoles');
Regions = zeros(513, 1024);
for i = 1 : nROI
    Regions(R(1, 1, i) <= phi & R(1, 2, i) >= phi & R(2, 1, i) <= theta & R(2, 2, i) >= theta) = i;
    if R(1, 2, i) > 2*pi
        Regions(0 <= phi & (R(1, 2, i)-2*pi) >= phi & R(2, 1, i) <= theta & R(2, 2, i) >= theta) = i;
    end
end

% Random colors
%RandColor = randint(nROI,3,256);
%RandColor = [(1:nROI)', (1:nROI)', (1:nROI)'];
RandColor = combnk(1:25, 3);
RandColor = RandColor(1:nROI, :);

% Create the outfile
for i = 1 : length(cases)
    for hemi = {'lh', 'rh'}
        TempStr = strcat(fpath, '/', char(cases(i)), '/surf/', char(hemi), '.sphere.reg');
        Vert = mat_to_vert(TempStr, Regions);
        % [vertices, faces] = freesurfer_read_surf(TempStr);
        OutStr = strcat(fpath, '/', char(cases(i)), '/label/', char(hemi), '.', fname, '.annot');
        % Create color tab
        % colortable is empty struct if not embedded in .annot. Else, it will be
        % a struct.
        % colortable.numEntries = number of Entries
        % colortable.orig_tab = name of original colortable
        % colortable.struct_names = list of structure names (e.g. central sulcus and so on)
        % colortable.table = n x 5 matrix. 1st column is r, 2nd column is g, 3rd column
        % is b, 4th column is flag, 5th column is resultant integer values
        % calculated from r + g*2^8 + b*2^16 + flag*2^24. flag expected to be
        % all 0.
        colortable.numEntries = nROI+1;
        colortable.orig_tab = 'None';
        colortable.struct_names = {'empty'};
        colortable.table = [0 0 0 0 0];
        colortable.table = [colortable.table; RandColor(:, 1), RandColor(:, 2), RandColor(:, 3), zeros(size(RandColor(:, 1))), RandColor(:, 1) + RandColor(:, 2).*2.^8 + RandColor(:, 3).*2.^16];
        for j = 1 : nROI
            Str = strcat('ROI', int2str(j));
            colortable.struct_names = [colortable.struct_names; Str];
        end
        write_annotation(OutStr, (0:length(Vert)-1)', colortable.table(Vert+1, 5), colortable);
    end
    File = fopen(strcat(fpath, '/', char(cases(i)), '/label/', fname, '.annot.ctab'), 'w');
    for j = 0 : nROI
        fprintf(File, '%d \t %s \t \t %d \t %d \t %d \t %d\n', j, char(colortable.struct_names(j+1)), colortable.table(j+1, 1), colortable.table(j+1, 2), colortable.table(j+1, 3), colortable.table(j+1, 4));
    end
    fclose(File);
end
