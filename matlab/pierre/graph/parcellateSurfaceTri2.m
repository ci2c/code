function parcellateSurfaceTri2(fpath, cases, fname)
% Usage : parcellateSurfaceTri2(fpath, cases, fname)
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
RandColor = combnk(20:75, 3);
RandColor = RandColor(1:nROI, :);

% To_delete obtained from fsaverage to make sure that same triangles are
% always discarded
To_delete.lh = [2;6;18;26;27;37;59;60;61;62;63;64;84;85;86;87;88;94;106;119;142;143;144;155;156;219;220;221;222;223;224;225;228;229;230;231;232;233;234;235;236;246;247;250;306;307;308;309;310;311;312;313;314;315;316;317;318;319;320;323;324;328;329;330;343;344;345;382;383;427;428;429;430;431;432;436;518;519;522;523;524;525;526;529;530;531;532;533;534;553;594;595;596;597;598;600;601;602;603;605];
            
To_delete.rh = [2;19;26;32;34;62;63;64;66;75;84;85;94;101;103;104;105;106;114;119;142;144;154;155;156;228;229;231;232;233;234;235;236;240;241;242;244;247;305;306;307;308;309;310;340;343;344;367;372;373;374;375;376;377;378;379;380;381;382;383;384;385;386;409;427;428;430;431;517;518;519;520;521;527;528;529;530;531;532;533;534;589;590;591;592;593;594;595;596;597;598;599;600;601;602;603;604;605;606];

% Create the outfile
for i = 1 : length(cases)
    % Color the surfaces
    for hemi = {'lh', 'rh'}
        TempStr = strcat(fpath, '/', char(cases(i)), '/surf/', char(hemi), '.sphere.reg');
        Surf = SurfStatReadSurf(TempStr);
        Surf.coord = Surf.coord';
        Vert.(char(hemi)) = zeros(size(Surf.coord, 1), 1);
        for j = 1 : size(Vert.(char(hemi)), 1)
            Mat = repmat(Surf.coord(j, :), nROI, 1);
            Dist = sqrt(sum((Mat - Centroids).^2,2));
            Vert.(char(hemi))(j) = min(find(Dist == min(Dist)));
        end
    end
    
    % Discard ROIs in flat regions and reorder ROIs
    % [v, SegLab, SegCol] = read_annotation(strcat(fpath, '/', 'fsaverage', '/label/lh.aparc.annot'));
    %[v, SegLab, SegCol] = read_annotation(strcat(fpath, '/', 'fsaverage', '/label/lh.aparc.a2005s.annot'));
    % To_delete.lh = unique(Vert.lh(find(SegLab==1639705)));
    %To_delete.lh = unique(Vert.lh(find(SegLab==3289650)));
    %To_delete.lh=[];
    for j = 1 : length(To_delete.lh)
        Vert.lh = Vert.lh .* (Vert.lh ~= To_delete.lh(j));
        %% Petit test
        %Vert.lh(Vert.lh == To_delete.lh(j)) = 9999;
    end
    %% Petit test suite
    %Vert.lh(Vert.lh ~= 9999) = 1;
    
    List = unique(Vert.lh);
    List(List==0)=[];
    Vertex = Vert.lh;
    for j = 1 : length(List)
        Vert.lh(find(Vertex == List(j))) = j;
    end
    
    % [v, SegLab, SegCol] = read_annotation(strcat(fpath, '/', 'fsaverage', '/label/rh.aparc.annot'));
    % To_delete.rh = unique(Vert.rh(find(SegLab==1639705)));
    for j = 1 : length(To_delete.rh)
        Vert.rh = Vert.rh .* (Vert.rh ~= To_delete.rh(j));
    end
    
    List = unique(Vert.rh);
    List(List==0)=[];
    Vertex = Vert.rh;
    for j = 1 : length(List)
        Vert.rh(find(Vertex == List(j))) = j;
    end
    
    % Write lh annot file --- ROI starts at 1
    OutStr = strcat(fpath, '/', char(cases(i)), '/label/lh.', fname, '.annot');
    L = length(unique(Vert.lh));
    if min(L) ~= 0
        L=L+1;
    end
    colortable_lh.numEntries = L;
    colortable_lh.orig_tab = 'None';
    colortable_lh.struct_names = {'empty'};
    colortable_lh.table = [0 0 0 0 0];
    colortable_lh.table = [colortable_lh.table; RandColor(1:L-1, 3), RandColor(1:L-1, 2), RandColor(1:L-1, 1), zeros(size(RandColor(1:L-1, 1))), RandColor(1:L-1, 3) + RandColor(1:L-1, 2).*2.^8 + RandColor(1:L-1, 1).*2.^16];
    for j = 1 : L-1
        Str = strcat('ROI', int2str(j));
        colortable_lh.struct_names = [colortable_lh.struct_names; Str];
    end
    write_annotation(OutStr, (0:length(Vert.lh)-1)', colortable_lh.table(Vert.lh+1, 5), colortable_lh);
    
    % Write rh annot file --- ROI starts at 1000
    OutStr = strcat(fpath, '/', char(cases(i)), '/label/rh.', fname, '.annot');
    L = length(unique(Vert.rh));
    if min(L) ~= 0
        L=L+1;
    end
    colortable_rh.numEntries = L;
    colortable_rh.orig_tab = 'None';
    colortable_rh.struct_names = {'empty'};
    colortable_rh.table = [1 1 1 0 65793];
    colortable_rh.table = [colortable_rh.table; RandColor(1:L-1, 3)+25, RandColor(1:L-1, 2)+25, RandColor(1:L-1, 1)+25, zeros(size(RandColor(1:L-1, 1))), RandColor(1:L-1, 3)+25 + (RandColor(1:L-1, 2)+25).*2.^8 + (RandColor(1:L-1, 1)+25).*2.^16];
    for j = 1000 : 1000+L-1
        Str = strcat('ROI', int2str(j));
        colortable_rh.struct_names = [colortable_rh.struct_names; Str];
    end
    write_annotation(OutStr, (0:length(Vert.rh)-1)', colortable_rh.table(Vert.rh+1, 5), colortable_rh);
    
    % Write ctab file
    File = fopen(strcat(fpath, '/', char(cases(i)), '/label/', fname, '.annot.ctab'), 'w');
    for j = 0 : colortable_lh.numEntries-1
        fprintf(File, '%d \t %s \t \t %d \t %d \t %d \t %d\n', j, char(colortable_lh.struct_names(j+1)), colortable_lh.table(j+1, 1), colortable_lh.table(j+1, 2), colortable_lh.table(j+1, 3), colortable_lh.table(j+1, 4));
    end
    for j = 0 : colortable_rh.numEntries-1
        fprintf(File, '%d \t %s \t \t %d \t %d \t %d \t %d\n', j, char(colortable_rh.struct_names(j+1)), colortable_rh.table(j+1, 1), colortable_rh.table(j+1, 2), colortable_rh.table(j+1, 3), colortable_rh.table(j+1, 4));
    end
    fclose(File);
end
