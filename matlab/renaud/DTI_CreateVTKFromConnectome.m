function DTI_CreateVTKFromConnectome(Connectome_file,fibers_file,thresh,numROI,outname)

% Load connectome file
load(Connectome_file);

% Read fibers file
fibers = f_readFiber_tck(fibers_file,thresh);


fibers.fiber(Connectome.region(numROI).selected==0) = [];
fibers.nFiberNr = length(fibers.fiber);

fibers = color_tracts(fibers);

save_tract_vtk(fibers,outname);

%save_nii_to_vtk('nl_transform/source_to_target_nlin.nii','t1.vtk');