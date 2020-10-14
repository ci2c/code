function getMultiVolConnectMatrix(fibers_path, outdir, ROI, SeqDti, thresh)
% usage : getMultiVolConnectMatrix(fibers_path, outdir, ROI, SeqDti, [THRESHOLD])
%
% INPUT :
% -------
%
%    fibers_path       : Path to fibers
%
%    outdir            : Path to the output directory to store the fiber
%                        file passing through the LABEL_vol
%
%    ROI               : Path to text file of the registered and binarised ROIs
%
%    SeqDti            : Number of dti
%
%    THRESHOLD         : Minimum fiber length required (default : 0) (works
%    only with mrtrix fibers)
%
% OUTPUT :
% --------
%    CONNECTOME        : Connectome structure
%
% Matthieu Vanhoutte @ CHRU Lille, May 2014

%% Check inputs
if nargin ~= 4 && nargin ~= 5
    error('invalid usage');
end

if nargin < 5
    thresh = 0;
end

Connectome.threshold = thresh;

%% Load fibers
if strfind(fibers_path, '.fib')
    disp('MedINRIA fibers');
    fibers = f_readFiber_vtk_bin(fibers_path);
    fibers = tracts_flip_x(tracts_flip_y(fibers));
else
    if strfind(fibers_path, 'FTR.mat')
        disp('dti tool fibers');
        fibers = FTRtoTracts(fibers_path);
    else
        if strfind(fibers_path, '.tck')
            disp('mrtrix fibers');
            fibers = f_readFiber_tck(fibers_path, thresh);
        else
            error('unrecognized fibers type');
        end
    end
end

%% Read registered and binarised ROIs, define names and values of label
fid = fopen(ROI, 'r');
T = textscan(fid,'%s','delimiter','\n');
Names = T{1};
Ts = length(Names);
LOI = 1:Ts;   
fclose(fid);

clear T Ts;

nFibers = fibers.nFiberNr;
nROI = length(LOI);

clear labels XYZ;

%% Load metadata of volume and concatenate voxel coordinates and Id of all fibers
V = spm_vol(fullfile(outdir, ['r' Names{1} 'b_' SeqDti '_LAS.nii']));

FibersCoord = cat(1, fibers.fiber.xyzFiberCoord)';
FibersCoord = [FibersCoord; ones(1, length(FibersCoord))];
FibersCoord = spm_pinv(V.mat) * FibersCoord;
for j = 1 : 3
    FibersCoordd(:, j) = double(FibersCoord(j, :)');
end
FibersID = cat(1, fibers.fiber.id);

%% Preallocate memory
T{1,nROI} = NaN;
Connectome.region(nROI).name = NaN;
Connectome.region(nROI).label = NaN;
Connectome.region(nROI).selected = NaN;

%% Determine number of fibers passing through each ROI and save tracks
for i = 1 : nROI
    tic;
%     V = spm_vol(fullfile(outdir, ['r' Names{i} 'b_' SeqDti '_LAS.nii']));
%     [labels, XYZ] = spm_read_vols(V);
%     labels = labels*LOI(i);
%     W = V;
%     W.fname = fullfile(outdir, ['r' Names{i} 'bl_' SeqDti '_LAS.nii']);
%     spm_write_vol(W,labels);
    V = spm_vol(fullfile(outdir, ['r' Names{i} 'bl_' SeqDti '_LAS.nii']));
    
    T{1,i} = round(spm_sample_vol(V, FibersCoordd(:, 1), FibersCoordd(:, 2), FibersCoordd(:, 3), 0));
        
    Connectome.region(i).name = Names{i};
    Connectome.region(i).label = LOI(i);
    UU = unique(FibersID(T{1,i} == LOI(i)));
    Connectome.region(i).selected = sparse(double(UU), 1, ones(size(UU)), double(nFibers), 1);
    
%     Tmp.fiber = fibers.fiber(logical(Connectome.region(i).selected));
%     
%     if isempty(Tmp.fiber)
%         NbFibres = 0;
%     else
%         Tmp.nFiberNr = length(Tmp.fiber);
%         NbFibres = Tmp.nFiberNr;
%         
%        save_tract_tck(Tmp,fullfile(outdir, [Names{i} '.tck']));
%     end   
%     fid = fopen(fullfile(outdir, [ 'NbFibres_' SeqDti '.txt']), 'a');
% 	fprintf(fid, '%s %d\n', Names{i}, NbFibres);
%     fclose(fid);  
    
    disp(['1 - Processing step ', num2str(i, '%.3d'), ' out of ', num2str(nROI), ' | Time : ', num2str(toc)]);
end

% %% Determine number of fibers passing through combination of 2 ROIs and save tracks
% for i = 1 : (nROI-1)
%     tic;
%     for j = (i+1) : nROI
%         InterConnectome = (Connectome.region(i).selected&Connectome.region(j).selected);
%         Tmp.fiber = fibers.fiber(InterConnectome);
% 
%         if isempty(Tmp.fiber)
%             NbFibres = 0;
%         else
%             Tmp.nFiberNr = length(Tmp.fiber);
%             NbFibres = Tmp.nFiberNr;
% 
%            save_tract_tck(Tmp,fullfile(outdir, [Names{i} '_2_' Names{j} '.tck']));
%         end   
%         fid = fopen(fullfile(outdir, [ 'NbFibres_' SeqDti '.txt']), 'a');
%         fprintf(fid, '%s_2_%s %d\n', Names{i}, Names{j}, NbFibres);
%         fclose(fid);  
%     end
%     disp(['2 - Processing step ', num2str(i, '%.3d'), ' out of ', num2str(nROI-1), ' | Time : ', num2str(toc)]);
% end

%% Determine number of fibers passing through combination of 3 ROIs and save tracks
for i = 1 : (nROI-2)
    tic;
    for j = (i+1) : (nROI-1)
        for k = (i+2) : nROI
            InterConnectome = (Connectome.region(i).selected&Connectome.region(j).selected&Connectome.region(k).selected);
            Tmp.fiber = fibers.fiber(InterConnectome);

            if isempty(Tmp.fiber)
                NbFibres = 0;
            else
                Tmp.nFiberNr = length(Tmp.fiber);
                NbFibres = Tmp.nFiberNr;

                save_tract_tck(Tmp,fullfile(outdir, [Names{i} '_2_' Names{j} '_2_' Names{k} '.tck']));
            end   
            fid = fopen(fullfile(outdir, [ 'NbFibres_' SeqDti '.txt']), 'a');
            fprintf(fid, '%s_2_%s_2_%s %d\n', Names{i}, Names{j}, Names{k}, NbFibres);
            fclose(fid);  
        end
    end
    disp(['3 - Processing step ', num2str(i, '%.3d'), ' out of ', num2str(nROI-2), ' | Time : ', num2str(toc)]);
end

%% Determine number of fibers passing through combination of 4 ROIs and save tracks
for i = 1 : (nROI-3)
    tic
    for j = (i+1) : (nROI-2)
        for k = (i+2) : (nROI-1)
            for l = (i+3) : nROI
                InterConnectome = (Connectome.region(i).selected&Connectome.region(j).selected&Connectome.region(k).selected&Connectome.region(l).selected);
                Tmp.fiber = fibers.fiber(InterConnectome);

                if isempty(Tmp.fiber)
                    NbFibres = 0;
                else
                    Tmp.nFiberNr = length(Tmp.fiber);
                    NbFibres = Tmp.nFiberNr;

                    save_tract_tck(Tmp,fullfile(outdir, [Names{i} '_2_' Names{j} '_2_' Names{k} '_2_' Names{l} '.tck']));
                end   
                fid = fopen(fullfile(outdir, [ 'NbFibres_' SeqDti '.txt']), 'a');
                fprintf(fid, '%s_2_%s_2_%s_2_%s %d\n', Names{i}, Names{j}, Names{k}, Names{l},NbFibres);
                fclose(fid);
            end
        end
    end
    disp(['4 - Processing step ', num2str(i, '%.3d'), ' out of ', num2str(nROI-3), ' | Time : ', num2str(toc)]);
end


