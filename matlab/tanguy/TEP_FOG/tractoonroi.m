function tractoonroi(sd,name,roi)



%% initialisation des différentes variables

sd
name
roi


prefix='tep';
thresh      = 0;


%% files path

fibers_path = fullfile(sd,name,'dti/mrtrix/whole_brain_8_500000.tck');
fa_path     = fullfile(sd,name,'dti/mrtrix/fa.nii');

% roimap      = fullfile(sd,name,'dti/old_process/mrtrix/thresh_tep_to_dti_ras.nii');
sl=find(roi=='/');
roiname=roi(sl(end)+1:end);
out_name = ['tracto_' roiname];
outfile     = fullfile(sd,name,'dti/mrtrix/tracto/',out_name)
roi_name =  [roi '.nii'];

%% Lecture de la roi

V=spm_vol(roi_name);


%% do [fibers,Connectome] = TractoOnROI(fibers_path,fa_path,V,prefix,thresh);
% fibers_path : chemin vers le fichier de tracto tck
% fa_path : chemin vers le fichier fa.nii
% V : masque 
% prefix : 
% thresh :

% codes : 



map = spm_read_vols(V);
nbvox_roi=sum(map(:)~=0);
% Read fibers
fibers  = f_readFiber_tck(fibers_path,thresh);
fibers  = sampleFibers(fibers, fa_path, 'fa', 2); % add fa
nFibers = fibers.nFiberNr;
nROI    = max(map(:));
clear map;

FibersCoord = cat(1, fibers.fiber.xyzFiberCoord)';
FibersCoord = [FibersCoord; ones(1, length(FibersCoord))];
FibersCoord = spm_pinv(V.mat) * FibersCoord;
FibersID    = cat(1, fibers.fiber.id);

T = round(spm_sample_vol(V, double(FibersCoord(1, :)'), double(FibersCoord(2, :)'), double(FibersCoord(3, :)'), 0));

% Preallocate memory
Connectome.region(1).name     = NaN;
Connectome.region(1).label    = NaN;
Connectome.region(1).selected = NaN;

tic;
for i = 1 : nROI
    disp(['Processing step ', num2str(i, '%.3d'), ' out of ', num2str(1), ' | Time : ', num2str(toc)]);
    Connectome.region(i).name  = prefix;
    Connectome.region(i).label = i;
    
    UU = unique(FibersID(T == i));
    
    
    empt=zeros(nFibers,1);
    empt(UU)=1;
    Connectome.region(i).selected = sparse(empt);
end

region_of_interest.V=V;
region_of_interest.size=nbvox_roi;



%% prep fibers saving
ind               = find(Connectome.region(1).selected~=1);
fibers.fiber(ind) = [];
nfib              = length(setdiff([1:fibers.nFiberNr],ind'));
fibers.nFiberNr   = fibers.nFiberNr - length(ind);


%% save fibers 
save_tract_vtk(fibers, [outfile '.vtk'], 'BINARY', 'fa');
save([outfile '.mat'],'fibers','Connectome','region_of_interest');

tracks       = read_mrtrix_tracks(fibers_path);
tracks.max_num_tracks = num2str(fibers.nFiberNr);
tracks.count = num2str(fibers.nFiberNr);
tracks.data  = [];
for j = 1:nfib
    tracks.data{j} = fibers.fiber(j).xyzFiberCoord;
end
write_mrtrix_tracks(tracks, [outfile '.tck']);


%% cleaning
clear tracks fibers Connectome V ind;
