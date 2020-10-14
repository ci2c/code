function mask = tract_vtk2mask(fibers_fname,DTIimage,fixTractCoordinates,minTractLength)
% function mask = tract_vtk2mask(fibers_fname,DTIimage,params)
% 
% Generate a binary mask from a set of tracts.
% fibers_fname: Vtk file containing the tracts. Can be from BIC diffusion tools
%               or from MedINRIA (not tested).
% DTIimage:     filename of a single image from the DTI data set from which 
%               the tracts were derived. Minc file.
% fixTractCoordinates:  true or false.
% minTractLength : to avoid short fibers in skull.
%
% Luis Concha. BIC. July, 2008.
             



 % load lambdas
info     = mnc_info(DTIimage);
dims     = [info.xspace.length info.yspace.length info.zspace.length];
voxDim   = abs([info.xspace.step;info.yspace.step;info.zspace.step])';
w_dims   = dims .* voxDim;


disp('Reading tracts');
try
    disp('Binary vtk file');
    tracts = f_readFiber_vtk_bin(fibers_fname,dims,voxDim);     % load a vtk version of the files
catch
    disp('ASCII vtk file');
    tracts = f_readFiber_vtk(fibers_fname,voxDim,dims);
end
disp('Removing short tracts');
tracts = tracts_removeByLength(tracts,minTractLength);     % Remove short fibers
tracts2 = tracts;
disp('Done');


if fixTractCoordinates
    fprintf(1,'Putting tracts in the right place...');
    for f = 1 : tracts2.nFiberNr
       scaleVec = [tracts2.fPixelSizeWidth tracts2.fPixelSizeHeight tracts2.fSliceThickness];
       shift  = repmat([w_dims(2) w_dims(1) 0] - [info.xspace.start info.yspace.start info.zspace.start],...
                       tracts2.fiber(f).nFiberLength,1);
       tracts2.fiber(f).xyzFiberCoord = tracts2.fiber(f).xyzFiberCoord + shift;

       scale  = repmat([tracts2.fPixelSizeWidth tracts2.fPixelSizeHeight tracts2.fSliceThickness],...
                         tracts2.fiber(f).nFiberLength,1);
       tracts2.fiber(f).xyzFiberCoord = tracts2.fiber(f).xyzFiberCoord ./ scale;
    end
    fprintf(1,' Done.\n')
end

mask = tract2mask(tracts2,'frequency');
mask = flipdim(mask,1);