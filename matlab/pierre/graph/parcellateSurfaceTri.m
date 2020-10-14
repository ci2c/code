function parcellateSurfaceTri(fpath, cases, fname)
% Usage : parcellateSurfaceTri(fpath, cases, fname)
%
% Save parcellated surface
%
% fpath   : path to the cases direcroty (equivalent to ${SUBJECTS_DIR})
% cases   : array of strings containing IDs of the cases to process. For
%     example : cases = {'patient1', 'patient023', 'NameP03'};
% fname   : Name of outfile (hemi.fname.annot in surf directory)

if nargin ~= 3
    error('Invalid usage');
end

% Store ROIs in a table
FV = sphere_tri('ico', 3, 1, 0);
nROI = size(FV.vertices, 1);
Centroids = FV.vertices;

% Color table
RandColor = combnk(1:25, 3);
RandColor = RandColor(1:nROI, :);

% To_delete obtained from fsaverage to make sure that same triangles are
% always discarded
To_delete.lh = [ 2;
     6;
    18;
    26;
    27;
    37;
    59;
    60;
    61;
    62;
    63;
    64;
    84;
    85;
    86;
    87;
    88;
    94;
   106;
   119;
   142;
   143;
   144;
   155;
   156;
   219;
   220;
   221;
   222;
   223;
   224;
   225;
   228;
   229;
   230;
   231;
   232;
   233;
   234;
   235;
   236;
   246;
   247;
   250;
   306;
   307;
   308;
   309;
   310;
   311;
   312;
   313;
   314;
   315;
   316;
   317;
   318;
   319;
   320;
   323;
   324;
   328;
   329;
   330;
   343;
   344;
   345;
   382;
   383;
   427;
   428;
   429;
   430;
   431;
   432;
   436;
   518;
   519;
   522;
   523;
   524;
   525;
   526;
   529;
   530;
   531;
   532;
   533;
   534;
   553;
   594;
   595;
   596;
   597;
   598;
   600;
   601;
   602;
   603;
   605];

             
To_delete.rh = [  2;
    19;
    26;
    32;
    34;
    62;
    63;
    64;
    66;
    75;
    84;
    85;
    94;
   101;
   103;
   104;
   105;
   106;
   114;
   119;
   142;
   144;
   154;
   155;
   156;
   228;
   229;
   231;
   232;
   233;
   234;
   235;
   236;
   240;
   241;
   242;
   244;
   247;
   305;
   306;
   307;
   308;
   309;
   310;
   340;
   343;
   344;
   367;
   372;
   373;
   374;
   375;
   376;
   377;
   378;
   379;
   380;
   381;
   382;
   383;
   384;
   385;
   386;
   409;
   427;
   428;
   430;
   431;
   517;
   518;
   519;
   520;
   521;
   527;
   528;
   529;
   530;
   531;
   532;
   533;
   534;
   589;
   590;
   591;
   592;
   593;
   594;
   595;
   596;
   597;
   598;
   599;
   600;
   601;
   602;
   603;
   604;
   605;
   606];

% Create the outfile
for i = 1 : length(cases)
    for hemi = {'lh', 'rh'}
        OutStr = strcat(fpath, '/', char(cases(i)), '/label/', char(hemi), '.', fname, '.annot');
        TempStr = strcat(fpath, '/', char(cases(i)), '/surf/', char(hemi), '.sphere.reg');
        Surf = SurfStatReadSurf(TempStr);
        Surf.coord = Surf.coord';
        Vert = zeros(size(Surf.coord, 1), 1);
        for j = 1 : size(Vert, 1)
            Mat = repmat(Surf.coord(j, :), nROI, 1);
            Dist = sqrt(sum((Mat - Centroids).^2,2));
            Vert(j) = min(find(Dist == min(Dist)));
        end

        % Step to set to 0 subcortical vertices
        %[v, SegLab, SegCol] = read_annotation(strcat(fpath, '/', 'fsaverage', '/label/', char(hemi),'.aparc.annot'));
        %to_delete = unique(Vert(find(SegLab==1639705)))
        %to_delete = getfield(To_delete, char(hemi));
        to_delete = To_delete.(char(hemi));
        for Index = 1:length(to_delete)
            % Vert(Vert==to_delete(Index)) = 0;
            Vert = Vert .* (Vert~=to_delete(Index));
        end
        
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
