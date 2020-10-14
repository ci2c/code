clear all;
close all;

roidef      = 'ROI Center(mm)=(28, 10, 51); Radius=6.00 mm.';
maskFile    = 'Default';
covariablesDef.ort_file = '';
covariablesDef.polort   = 0;
subjects    = {'ALIB','BAUD','BETT','BISI','BOND','DAMB','DEBA','DENI','DETH','DUMO','HERL','LOUG','LUCA','MARQ','POCH','VASS'};

for k = 2:length(subjects)

    subj        = subjects{k};
    disp(['subject : ' subj]);
    datapath    = ['/home/fatmike/renaud/tep_fog/preprocess/FunImgNormalizedSmoothedDetrendedFilteredCovremoved/' subj];
    resFilename = ['/home/fatmike/renaud/tep_fog/voxelseed/281051/FCMap_' subj];
    ResultMaps  = FMRI_ConnectivityVoxelSeed(datapath,roidef,resFilename,maskFile,covariablesDef);

end

