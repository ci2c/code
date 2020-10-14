function resClust = FMRI_SelectInterestClasses(res_dir,TempDir,resClust,opt_choice)

maskB       = resClust.maskB;
tMaps       = resClust.tMaps;
opt         = resClust.optClust;
    
nbclasses   = opt.nbclasses;
tMaps_pos   = tMaps;
tMaps_pos(tMaps<0) = 0;
nplot       = ceil(nbclasses/4);
for kk = 1:nplot
    pp = 1;
    cc = {};
    while pp<=4 && (pp+4*(kk-1)) <= nbclasses
        cc{pp} = ['C' num2str(pp+4*(kk-1))];
        pp     = pp+1;
    end
    close(findobj('Name',[cc{1} ' to ' cc{end}]))
end

if strcmp(opt_choice,'auto')

    [m1,m2] = mkdir(res_dir,'templates');

    unix(['cp ', TempDir filesep 'template*.* ', res_dir filesep 'templates']);

    TempDir = [res_dir filesep 'templates' filesep];
    thresC  = 0.25;

    tempList = dir([TempDir,'template*.nii']);
    tempList = strvcat(tempList.name);
    tempList = [repmat(TempDir,[size(tempList,1) 1]) tempList];
    PP       = strvcat([res_dir filesep 'Classes' filesep 'tMapsClass0001.nii'],tempList);
    flag_reslice.interp = 1;
    flag_reslice.wrap   = [0 0 0];
    flag_reslice.mask   = 0;
    flag_reslice.mean   = 0;
    flag_reslice.which  = 1;
    spm_reslice(PP,flag_reslice);

    DirImg        = dir(fullfile(TempDir,'rtemplate*'));
    FileList      = [];
    for j = 1:length(DirImg)
        FileList = [FileList;fullfile(TempDir,[DirImg(j).name])];
    end
    Vtmp            = spm_vol(FileList);
    tMaps_ref       = spm_read_vols(Vtmp);
    [nx,ny,nz,nref] = size(tMaps_ref);
    nclasses        = size(tMaps,4);
    tMaps_ref       = reshape(tMaps_ref,[nx*ny*nz,nref]);
    tMaps_cur       = reshape(tMaps,[nx*ny*nz,nclasses]);
    maskB_v         = maskB(:);
    tMaps_ref       = tMaps_ref(maskB_v,:);
    tMaps_cur       = tMaps_cur(maskB_v,:);
    tMaps_ref(isnan(tMaps_ref)) = 0;
    C      = (1/(size(tMaps_ref,1)-1))*st_normalise(tMaps_ref)'*st_normalise(tMaps_cur);
    scoreC = abs(max(C));
    selCOI = find(scoreC > thresC);
    
    clear Vtmp DirImg FileList;
    
elseif strcmp(opt_choice,'manual')

    nplot = ceil(nbclasses/4);
    for kk = 1:nplot
        h = figure;
        set(h,'Units','normalized')
        set(h,'Position',[0.23125+0.025*(kk-1) 0.143555-0.025*(kk-1) 0.688281 0.259766])
        pp = 1;
        cc = {};
        while pp<=4 && (pp+4*(kk-1)) <= nbclasses
            cc{pp} = ['C' num2str(pp+4*(kk-1))];
            subplot(1,4,pp),st_visu_vol(tMaps_pos(:,:,:,pp+4*(kk-1)),[0 5 0],'jet','retflou',{['C' num2str(pp+4*(kk-1))]},'+90',0);
            pp = pp+1;
        end
        set(h,'Name',[cc{1} ' to ' cc{end}])
    end

    answer = inputdlg('Number of classes of interest');
    selCOI = str2num(answer{1});
    for kk = 1:nplot
        pp = 1;
        cc = {};
        while pp<=4 && (pp+4*(kk-1)) <= nbclasses
            cc{pp} = ['C' num2str(pp+4*(kk-1))];
            pp = pp+1;
        end
        close(findobj('Name',[cc{1} ' to ' cc{end}]))
    end

end
disp(['Classes Selected : ' num2str(selCOI)])

labelCOI = {};
for pp=1:length(selCOI)
    labelCOI{pp} = ['C' num2str(selCOI(pp))];
end

resClust.COI       = [];
resClust.COI.num   = selCOI;
resClust.COI.label = labelCOI;

[a,b] = mkdir([res_dir filesep 'Classes'],'COI');
delete([res_dir filesep 'Classes' filesep 'COI' filesep '*.*'])

for pp = 1:length(selCOI)
    if selCOI(pp)<10
        unix(['cp ', [res_dir filesep 'Classes' filesep 'tMapsClass000',num2str(selCOI(pp)),'.nii '], [res_dir filesep 'Classes' filesep 'COI' filesep 'tMaps_',labelCOI{pp},'.nii']]);
        unix(['cp ', [res_dir filesep 'Classes' filesep 'Thres_tMapsClass000',num2str(selCOI(pp)),'.nii '], [res_dir filesep 'Classes' filesep 'COI' filesep 'Thres_tMaps_',labelCOI{pp},'.nii']]);
    else
        unix(['cp ', [res_dir filesep 'Classes' filesep 'tMapsClass00',num2str(selCOI(pp)),'.nii '], [res_dir filesep 'Classes' filesep 'COI' filesep 'tMaps_',labelCOI{pp},'.nii']]);
        unix(['cp ', [res_dir filesep 'Classes' filesep 'Thres_tMapsClass00',num2str(selCOI(pp)),'.nii '], [res_dir filesep 'Classes' filesep 'COI' filesep 'Thres_tMaps_',labelCOI{pp},'.nii']]);
    end
end

