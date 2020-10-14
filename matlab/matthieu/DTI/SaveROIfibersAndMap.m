function SaveROIfibersAndMap(fibers_path, label_vol, FA_path, MD_path, L1_path, L2_path, L3_path, Connectome, NotCC, LOI, thresh)
% usage : SaveROIfibersAndMap(fibers_path, label_vol, FA_path, MD_path, L1_path, L2_path, L3_path, Connectome, NotCC, [LOI, thresh]);
%
% INPUT :
% -------
%    fibers_path       : Path to fibers directory and output directory
%
%    label_vol         : Path to segmented volume (in RAS nii format)
%
%    FA_path           : Path to FA volume (i.e. '/my/volume/FA.nii')
%
%    MD_path           : Path to MD volume (i.e. '/my/volume/MD.nii')
%
%    L1_path           : Path to L1 volume (i.e. '/my/volume/L1.nii')
%
%    L2_path           : Path to L2 volume (i.e. '/my/volume/L2.nii')
%
%    L3_path           : Path to L3 volume (i.e. '/my/volume/L3.nii')
%
%    Connectome        : Input connectome structure
%
%    NotCC             : Save fibers and Map passing through left and right FCS, instead of CC 
%
% Option :
%    LOI               : Path to text file containing ID and names of the labels of interest (option)
%    thresh            : Minimum required fiber length (default : Connectome.threshold or 0)
%
% Matthieu Vanhoutte @ CHRU Lille, Apr 2015

if nargin ~= 9 & nargin ~= 10 & nargin ~= 11
    error('invalid usage');
end

if nargin == 9 || nargin == 10
    try 
        thresh = Connectome.threshold;
    catch
        thresh = 0;
    end
end

% Load data
V = spm_vol(label_vol);
[labels, XYZ] = spm_read_vols(V);
labels = round(labels);

if isempty(LOI)
    LOI = unique(labels);
    Ts = length(LOI);
    Names = [repmat('LOI', Ts, 1), num2str((1:Ts)', '%.4d')];
    clear Ts;
else
    fid = fopen(LOI, 'r');
    T = textscan(fid, '%d %s');
    LOI = T{1};
    Names = T{2};
    fclose(fid);
    clear T;
end

nROI = length(LOI);

% Preallocate memory
% TmpFibers.fiber{nROI} = [];
if NotCC
    LeftFCS.fiber = [];
    RightFCS.fiber = [];
else
    CC.fiber = [];
end

% Find split fibers files
F0 = rdir(fullfile(fibers_path,'whole_brain_2_1500000_part*.tck'));

l = 0;

for k=1:length(F0)   
    % Load fibers
    disp('mrtrix fibers');
    disp(k);
    Tract = f_readFiber_tck(F0(k).name, thresh);
    
    nFibers = Tract.nFiberNr;

%     for i = 1 : nROI
%         TmpFibers.fiber{i} = [ TmpFibers.fiber{i} Tract.fiber(logical(Connectome.region(i).selected((l+1):(l+nFibers))))];
%     end

    if NotCC
        LeftFCS.fiber = [ LeftFCS.fiber Tract.fiber(Connectome.region(1).selected((l+1):(l+nFibers)) & Connectome.region(2).selected((l+1):(l+nFibers)) & Connectome.region(3).selected((l+1):(l+nFibers)) & (~Connectome.region(4).selected((l+1):(l+nFibers)))) ];
        RightFCS.fiber = [ RightFCS.fiber Tract.fiber(Connectome.region(5).selected((l+1):(l+nFibers)) & Connectome.region(6).selected((l+1):(l+nFibers)) & Connectome.region(7).selected((l+1):(l+nFibers)) & (~Connectome.region(4).selected((l+1):(l+nFibers)))) ];
    else
        CC.fiber = [ CC.fiber Tract.fiber(Connectome.region(1).selected((l+1):(l+nFibers)) & (~Connectome.region(2).selected((l+1):(l+nFibers)))) ];
    end    
    l = l+nFibers;
end

%% Save the extracted ROI fibers and FA/MD/L1/L2/L3 maps (.tck,.vtk) I

if NotCC
    LeftFCS.nFiberNr = length(LeftFCS.fiber);
    RightFCS.nFiberNr = length(RightFCS.fiber);

    % Color fibers R/L FCS
    save_tract_tck(LeftFCS,fullfile(fibers_path, 'Left_FCS.tck'));
    LeftFCS_Color = color_tracts(LeftFCS);
    save_tract_vtk(LeftFCS_Color,fullfile(fibers_path, 'Left_FCS.vtk'));

    save_tract_tck(RightFCS,fullfile(fibers_path, 'Right_FCS.tck'));
    RightFCS_Color = color_tracts(RightFCS);
    save_tract_vtk(RightFCS_Color,fullfile(fibers_path, 'Right_FCS.vtk'));
    
    % Map FA on R/L FCS
    LeftFCS_FA = sampleFibers(LeftFCS, FA_path, 'FA');
    save_tract_vtk(LeftFCS_FA,fullfile(fibers_path, 'Left_FCS_FA.vtk'),[],'FA');
    RightFCS_FA = sampleFibers(RightFCS, FA_path, 'FA');
    save_tract_vtk(RightFCS_FA,fullfile(fibers_path, 'Right_FCS_FA.vtk'),[],'FA');
    
    % Map MD on R/L FCS
    LeftFCS_MD = sampleFibers(LeftFCS, MD_path, 'MD');
    save_tract_vtk(LeftFCS_MD,fullfile(fibers_path, 'Left_FCS_MD.vtk'),[],'MD');
    RightFCS_MD = sampleFibers(RightFCS, MD_path, 'MD');
    save_tract_vtk(RightFCS_MD,fullfile(fibers_path, 'Right_FCS_MD.vtk'),[],'MD');

    % Map L1 on R/L FCS
    LeftFCS_L1 = sampleFibers(LeftFCS, L1_path, 'L1');
    save_tract_vtk(LeftFCS_L1,fullfile(fibers_path, 'Left_FCS_L1.vtk'),[],'L1');
    RightFCS_L1 = sampleFibers(RightFCS, L1_path, 'L1');
    save_tract_vtk(RightFCS_L1,fullfile(fibers_path, 'Right_FCS_L1.vtk'),[],'L1');
    
    % Map L2 on R/L FCS
    LeftFCS_L2 = sampleFibers(LeftFCS, L2_path, 'L2');
    save_tract_vtk(LeftFCS_L2,fullfile(fibers_path, 'Left_FCS_L2.vtk'),[],'L2');
    RightFCS_L2 = sampleFibers(RightFCS, L2_path, 'L2');
    save_tract_vtk(RightFCS_L2,fullfile(fibers_path, 'Right_FCS_L2.vtk'),[],'L2');
    
    % Map L3 on R/L FCS
    LeftFCS_L3 = sampleFibers(LeftFCS, L3_path, 'L3');
    save_tract_vtk(LeftFCS_L3,fullfile(fibers_path, 'Left_FCS_L3.vtk'),[],'L3');
    RightFCS_L3 = sampleFibers(RightFCS, L3_path, 'L3');
    save_tract_vtk(RightFCS_L3,fullfile(fibers_path, 'Right_FCS_L3.vtk'),[],'L3');
else
    CC.nFiberNr = length(CC.fiber);
    
    % Color fibers CC
    save_tract_tck(CC,fullfile(fibers_path, 'CC.tck'));
    CC_Color = color_tracts(CC);
    save_tract_vtk(CC_Color,fullfile(fibers_path, 'CC.vtk']));
    
    % Map FA on CC
    CC_FA = sampleFibers(CC, FA_path, 'FA');
    save_tract_vtk(CC_FA,fullfile(fibers_path, 'Left_FCS_FA.vtk'),[],'FA');
    
    % Map MD on CC
    CC_MD = sampleFibers(CC, MD_path, 'MD');
    save_tract_vtk(CC_MD,fullfile(fibers_path, 'Left_FCS_MD.vtk'),[],'MD');

    % Map L1 on CC
    CC_L1 = sampleFibers(CC, L1_path, 'L1');
    save_tract_vtk(CC_L1,fullfile(fibers_path, 'Left_FCS_L1.vtk'),[],'L1');
    
    % Map L2 on CC
    CC_L2 = sampleFibers(CC, L2_path, 'L2');
    save_tract_vtk(CC_L2,fullfile(fibers_path, 'Left_FCS_L2.vtk'),[],'L2');
    
    % Map L3 on CC
    CC_L3 = sampleFibers(CC, L3_path, 'L3');
    save_tract_vtk(CC_L3,fullfile(fibers_path, 'Left_FCS_L3.vtk'),[],'L3');
end

% for i = 1 : nROI   
%     ROIfibers.fiber = TmpFibers.fiber{i};
%     ROIfibers.nFiberNr = length(ROIfibers.fiber);
%     
%     % Color fibers
%     ROIfibersColor = color_tracts(ROIfibers);
%     save_tract_tck(ROIfibersColor,fullfile(fibers_path, [Names{i} '.tck']));
%     save_tract_vtk(ROIfibersColor,fullfile(fibers_path, [Names{i} '.vtk']));
% 
%     % Map FA on ROIfibers
%     ROIfibersFA = sampleFibers(ROIfibers, FA_path, 'FA');
%     save_tract_vtk(ROIfibersFA,fullfile(fibers_path, [Names{i} '_FA.vtk']),[],'FA');
%     
%     % Map MD on ROIfibers
%     ROIfibersMD = sampleFibers(ROIfibers, MD_path, 'MD');
%     save_tract_vtk(ROIfibersMD,fullfile(fibers_path, [Names{i} '_MD.vtk']),[],'MD');
% 
%     % Map L1 on ROIfibers
%     ROIfibersL1 = sampleFibers(ROIfibers, L1_path, 'L1');
%     save_tract_vtk(ROIfibersL1,fullfile(fibers_path, [Names{i} '_L1.vtk']),[],'L1');
%     
%     % Map L2 on ROIfibers
%     ROIfibersL2 = sampleFibers(ROIfibers, L2_path, 'L2');
%     save_tract_vtk(ROIfibersL2,fullfile(fibers_path, [Names{i} '_L2.vtk']),[],'L2');
%     
%     % Map L3 on ROIfibers
%     ROIfibersL3 = sampleFibers(ROIfibers, L3_path, 'L3');
%     save_tract_vtk(ROIfibersL3,fullfile(fibers_path, [Names{i} '_L3.vtk']),[],'L3');
    
% end
