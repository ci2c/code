
load('/home/alice/SVN/medial_wall.mat');
mask=~Mask;

surf=SurfStatReadSurf({['/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/fsaverage/surf/lh.pial'],['/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/fsaverage/surf/rh.pial']});

[Zb, subjidTD, Zd] = xlsread('/home/clement/Documents/Datas STROKDEM/Depressifs');
[Zc, subjidNTD, Ze] = xlsread('/home/clement/Documents/Datas STROKDEM/Non_Depressifs');


ind_excludeTD=[];
ind_excludeNTD=[];

for j=1:length(subjidTD)
    M6TD=['/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/',char(subjidTD(j)),'_M6/surf/lh.thickness.fwhm20.fsaverage.mgh'];
    H72TD=['/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/',char(subjidTD(j)),'_72H/surf/lh.thickness.fwhm20.fsaverage.mgh'];
    M36TD=['/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/',char(subjidTD(j)),'_M36/surf/lh.thickness.fwhm20.fsaverage.mgh'];
     A=exist(M6TD,'file');
     %B=exist(H72TD,'file');
    %C=exist(M36TD,'file');
    if (A==0)
        ind_excludeTD=[ind_excludeTD j];
    end
end

for j=1:length(subjidNTD)
    M6NTD=['/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/',char(subjidNTD(j)),'_M6/surf/lh.thickness.fwhm20.fsaverage.mgh'];
    H72NTD=['/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/',char(subjidNTD(j)),'_72H/surf/lh.thickness.fwhm20.fsaverage.mgh'];
    M36NTD=['/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/',char(subjidNTD(j)),'_M36/surf/lh.thickness.fwhm20.fsaverage.mgh'];
     A=exist(M6NTD,'file');
     %B=exist(H72NTD,'file');
    %C=exist(M36NTD,'file');
    if (A==0 )
        ind_excludeNTD=[ind_excludeNTD j];
    end
end

j=1;


 if length(ind_excludeTD)==0
     SubjidTD=subjidTD;
 else
    for i=1:length(subjidTD)
        if (i~=ind_excludeTD)
            SubjidTD(j)=subjidTD(i);
            ind_S(j)=i;
            j=j+1;
        end
    end
 end

j=1;

 if length(ind_excludeNTD)==0
     SubjidNTD=subjidNTD;
 else
    for i=1:length(subjidNTD)
        if (i~=ind_excludeNTD)
            SubjidNTD(j)=subjidNTD(i);
            ind_S(j)=i;
            j=j+1;
        end
    end
 end 

clear i

%%


for i=1:length(SubjidTD)
    
%disp(SubjidTD(i));
%Y_72HTD(i,:)=SurfStatReadData({['/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/',char(SubjidTD(i)),'_72H/surf/lh.thickness.fwhm20.fsaverage.mgh'],['/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/',char(SubjidTD(i)),'_72H/surf/rh.thickness.fwhm20.fsaverage.mgh']} );
Y_M6TD(i,:)=SurfStatReadData({['/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/',char(SubjidTD(i)),'_M6/surf/lh.thickness.fwhm20.fsaverage.mgh'],['/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/',char(SubjidTD(i)),'_M6/surf/rh.thickness.fwhm20.fsaverage.mgh']} );
%Y_M36TD(i,:)=SurfStatReadData({['/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/',char(SubjidTD(i)),'_M36/surf/lh.thickness.fwhm20.fsaverage.mgh'],['/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/',char(SubjidTD(i)),'_M36/surf/rh.thickness.fwhm20.fsaverage.mgh']} );

end 

for i=1:length(SubjidNTD)
%disp(SubjidNTD(i));
%Y_72HNTD(i,:)=SurfStatReadData({['/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/',char(SubjidNTD(i)),'_72H/surf/lh.thickness.fwhm20.fsaverage.mgh'],['/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/',char(SubjidNTD(i)),'_72H/surf/rh.thickness.fwhm20.fsaverage.mgh']} );
Y_M6NTD(i,:)=SurfStatReadData({['/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/',char(SubjidNTD(i)),'_M6/surf/lh.thickness.fwhm20.fsaverage.mgh'],['/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/',char(SubjidNTD(i)),'_M6/surf/rh.thickness.fwhm20.fsaverage.mgh']} );
%Y_M36NTD(i,:)=SurfStatReadData({['/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/',char(SubjidNTD(i)),'_M36/surf/lh.thickness.fwhm20.fsaverage.mgh'],['/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/',char(SubjidNTD(i)),'_M36/surf/rh.thickness.fwhm20.fsaverage.mgh']} );


end 

%%

ageTD = Zb(:,1);
sexeTD = Zb(:,2);

ageNTD = Zc(:,1);
sexeNTD = Zc(:,2);


NNTD = size(ageNTD,1);
NTD  = size(ageTD,1);

Y = [Y_M6TD;Y_M6NTD];


% X = zeros(NNTD+NTD,4);
% X(1:NNTD,1)=ones(NNTD,1);
% X(NNTD+1:end,1)=zeros(NTD,1);
% X(1:NNTD,2)=zeros(NNTD,1);
% X(NNTD+1:end,2)=ones(NTD,1);
% X(1:NTD,3)=ageTD;
% X(NTD+1:end,3)=ageNTD;
% X(:,4) = [sexeNTD;sexeTD];


age = [ageNTD;ageTD];
sexe = [sexeNTD;sexeTD];
Age = term(age);
Sexe = term(sexe);

group={};
for k = 1:NNTD
    group{end+1} = 'NTD';
end
for k = 1:NTD
    group{end+1} = 'TD';
end

Group = term(group);
M = 1 + Group + Age + Sexe;
% M = 1 + Group + Age;
% M = 1 + Group + Sexe;


% figure; image(M);

slm = SurfStatLinMod( Y, M, surf);

contrast = Group.TD - Group.NTD;

slm = SurfStatT( slm, contrast );

resels = SurfStatResels( slm, mask );
stat_threshold( resels, length(slm.t), 1, slm.df );

[ pval, peak, clus ] = SurfStatP( slm, mask ); 


% avsurfinfl = SurfStatInflate(surf ); 
% SurfStatView( pval, avsurfinfl);

SurfStatView( pval, surf);
%figure, SurfStatView( slm.t.*mask, surf);