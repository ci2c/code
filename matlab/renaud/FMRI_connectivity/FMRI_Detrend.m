function FMRI_Detrend(opt)

%Detrend

if (opt.DataIsSmoothed==1)
    FunImgDir = 'FunImgNormalizedSmoothed';
else
    FunImgDir = 'FunImgNormalized';
end
cd(fullfile(opt.DataProcessDir,FunImgDir));
for i = 1:opt.SubjectNum
    rest_detrend(fullfile(opt.DataProcessDir,FunImgDir,opt.SubjectID{i}), '_detrend');
end

% Copy the detrended files to DataProcessDir\FunImgNormalizedDetrended or DataProcessDir\FunImgNormalizedSmoothedDetrended
cd(fullfile(opt.DataProcessDir,FunImgDir));
for i = 1:opt.SubjectNum
    cd([opt.SubjectID{i}, '_detrend']);
    mkdir(fullfile('..','..',[FunImgDir,'Detrended'],opt.SubjectID{i}))
    movefile('*',fullfile('..','..',[FunImgDir,'Detrended'],opt.SubjectID{i}))
    cd('..');
    rmdir([opt.SubjectID{i}, '_detrend']);
    fprintf(['Moving Dtrended Files:',opt.SubjectID{i},' OK']);
end
fprintf('\n');
