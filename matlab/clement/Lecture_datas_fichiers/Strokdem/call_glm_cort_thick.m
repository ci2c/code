
%% Loading Mask 
load('/home/clement/SVN/medial_wall.mat');
mask=~Mask;
surf=SurfStatReadSurf({['/NAS/tupac/protocoles/Strokdem/FS5.1_T2mask/fsaverage/surf/lh.pial'],['/NAS/tupac/protocoles/Strokdem/FS5.1_T2mask/fsaverage/surf/rh.pial']});

%% Loading subjects
[var, name, ~] = xlsread('/NAS/tupac/protocoles/Strokdem/Clinical_Data/Recap_stk.xls');
TC = var(:,6);
TM = var(:,13);

age = var(:,1);
sexe = var(:,2);
net = var(:,3);
icv = var(:,4);

subjid = name(2:end,1);


ID_OK = [];

for j=1:length(subjid)
    file=['/NAS/tupac/protocoles/Strokdem/FS5.1_T2mask/',char(subjid(j)),'/surf/lh.thickness.fwhm20.fsaverage.mgh'];
    if exist(file,'file')
       ID_OK(end+1) = j;
    end
end

%%

Subjid = subjid(ID_OK);
Y = [];
for i=1:length(Subjid)
Y(end+1,:)=SurfStatReadData({['/NAS/tupac/protocoles/Strokdem/FS5.1_T2mask/',char(Subjid(i)),'/surf/lh.thickness.fwhm5.fsaverage.mgh'],['/NAS/tupac/protocoles/Strokdem/FS5.1_T2mask/',char(Subjid(i)),'/surf/rh.thickness.fwhm5.fsaverage.mgh']} );
end 

%%


[C,~,~] = intersect(ID_OK,find(TC == 1));

X = zeros(length(TC),2);
X(TM == 0 & TC == 1,1) = 1;
X(TM == 1 & TC == 1,2) = 1;
Group = term(X(C,:));
Net = term(net(C));
ICV = term(icv(C));

Y = Y(C,:);
    
M = 1 + Group + ICV;


slm = SurfStatLinMod( Y, M, surf );

contrast = [0,1,-1,0];

slm = SurfStatT( slm, contrast );

% resels = SurfStatResels( slm, mask );
% stat_threshold( resels, length(slm.t), 1, slm.df );

[ pval, peak, clus ] = SurfStatP( slm, mask ); 

SurfStatView(pval, surf);
%SurfStatView( slm.t.*mask, surf);

