load('/home/alice/SVN/medial_wall.mat');
mask=~Mask;

surf=SurfStatReadSurf({['/home/fatmike/Protocoles_3T/Strokdem/FS5.1/fsaverage/surf/lh.pial'],['/home/fatmike/Protocoles_3T/Strokdem/FS5.1/fsaverage/surf/rh.pial']});

[Zb, subjidTC, Zd] = xlsread('/home/clement/Documents/Datas STROKDEM/Trouble_Anx');
[Zc, subjidNTC, Ze] = xlsread('/home/clement/Documents/Datas STROKDEM/Non_Trouble_Anx');


ind_excludeTC=[];
ind_excludeNTC=[];

for j=1:length(subjidTC)
    M6TC=['/home/fatmike/Protocoles_3T/Strokdem/FS5.1/',char(subjidTC(j)),'_M6/surf/lh.thickness.fwhm20.fsaverage.mgh'];
    H72TC=['/home/fatmike/Protocoles_3T/Strokdem/FS5.1/',char(subjidTC(j)),'_72H/surf/lh.thickness.fwhm20.fsaverage.mgh'];
    M36TC=['/home/fatmike/Protocoles_3T/Strokdem/FS5.1/',char(subjidTC(j)),'_M36/surf/lh.thickness.fwhm20.fsaverage.mgh'];
     A=exist(M6TC,'file');
     %B=exist(H72TC,'file');
    %C=exist(M36TC,'file');
    if (A==0)
        ind_excludeTC=[ind_excludeTC j];
    end
end

for j=1:length(subjidNTC)
    M6NTC=['/home/fatmike/Protocoles_3T/Strokdem/FS5.1/',char(subjidNTC(j)),'_M6/surf/lh.thickness.fwhm20.fsaverage.mgh'];
    H72NTC=['/home/fatmike/Protocoles_3T/Strokdem/FS5.1/',char(subjidNTC(j)),'_72H/surf/lh.thickness.fwhm20.fsaverage.mgh'];
    M36NTC=['/home/fatmike/Protocoles_3T/Strokdem/FS5.1/',char(subjidNTC(j)),'_M36/surf/lh.thickness.fwhm20.fsaverage.mgh'];
     A=exist(M6NTC,'file');
     %B=exist(H72NTC,'file');
    %C=exist(M36NTC,'file');
    if (A==0 )
        ind_excludeNTC=[ind_excludeNTC j];
    end
end

j=1;


 if length(ind_excludeTC)==0
     SubjidTC=subjidTC;
 else
    for i=1:length(subjidTC)
        if (i~=ind_excludeTC)
            SubjidTC(j)=subjidTC(i);
            ind_S(j)=i;
            j=j+1;
        end
    end
 end

j=1;

 if length(ind_excludeNTC)==0
     SubjidNTC=subjidNTC;
 else
    for i=1:length(subjidNTC)
        if (i~=ind_excludeNTC)
            SubjidNTC(j)=subjidNTC(i);
            ind_S(j)=i;
            j=j+1;
        end
    end
 end 

clear i

%%


for i=1:length(SubjidTC)
    
%disp(SubjidTC(i));
%Y_72HTC(i,:)=SurfStatReadData({['/home/fatmike/Protocoles_3T/Strokdem/FS5.1/',char(SubjidTC(i)),'_72H/surf/lh.thickness.fwhm20.fsaverage.mgh'],['/home/fatmike/Protocoles_3T/Strokdem/FS5.1/',char(SubjidTC(i)),'_72H/surf/rh.thickness.fwhm20.fsaverage.mgh']} );
Y_M6TC(i,:)=SurfStatReadData({['/home/fatmike/Protocoles_3T/Strokdem/FS5.1/',char(SubjidTC(i)),'_M6/surf/lh.thickness.fwhm20.fsaverage.mgh'],['/home/fatmike/Protocoles_3T/Strokdem/FS5.1/',char(SubjidTC(i)),'_M6/surf/rh.thickness.fwhm20.fsaverage.mgh']} );
%Y_M36TC(i,:)=SurfStatReadData({['/home/fatmike/Protocoles_3T/Strokdem/FS5.1/',char(SubjidTC(i)),'_M36/surf/lh.thickness.fwhm20.fsaverage.mgh'],['/home/fatmike/Protocoles_3T/Strokdem/FS5.1/',char(SubjidTC(i)),'_M36/surf/rh.thickness.fwhm20.fsaverage.mgh']} );

end 

for i=1:length(SubjidNTC)
%disp(SubjidNTC(i));
%Y_72HNTC(i,:)=SurfStatReadData({['/home/fatmike/Protocoles_3T/Strokdem/FS5.1/',char(SubjidNTC(i)),'_72H/surf/lh.thickness.fwhm20.fsaverage.mgh'],['/home/fatmike/Protocoles_3T/Strokdem/FS5.1/',char(SubjidNTC(i)),'_72H/surf/rh.thickness.fwhm20.fsaverage.mgh']} );
Y_M6NTC(i,:)=SurfStatReadData({['/home/fatmike/Protocoles_3T/Strokdem/FS5.1/',char(SubjidNTC(i)),'_M6/surf/lh.thickness.fwhm20.fsaverage.mgh'],['/home/fatmike/Protocoles_3T/Strokdem/FS5.1/',char(SubjidNTC(i)),'_M6/surf/rh.thickness.fwhm20.fsaverage.mgh']} );
%Y_M36NTC(i,:)=SurfStatReadData({['/home/fatmike/Protocoles_3T/Strokdem/FS5.1/',char(SubjidNTC(i)),'_M36/surf/lh.thickness.fwhm20.fsaverage.mgh'],['/home/fatmike/Protocoles_3T/Strokdem/FS5.1/',char(SubjidNTC(i)),'_M36/surf/rh.thickness.fwhm20.fsaverage.mgh']} );


end 

%%

Nntc = size(ageNTA,1);
Ntc  = size(ageTA,1);

Y = [Y_M6TC;Y_M6NTC];


X = zeros(Nntc+Ntc,4);
X(1:Nntc,1)=ones(Nntc,1);
X(Nntc+1:end,1)=zeros(Ntc,1);
X(1:Nntc,2)=zeros(Nntc,1);
X(Nntc+1:end,2)=ones(Ntc,1);
X(1:Ntc,3)=ageTA;
X(Ntc+1:end,3)=ageNTA;
X(:,4) = [sexeNTA;sexeTA];


age = [ageNTA;ageTA];
sexe = [sexeNTA;sexeTA];
Age = term(age);
Sexe = term(sexe);

group={};
for k = 1:Nntc
    group{end+1} = 'NTA';
end
for k = 1:Ntc
    group{end+1} = 'TA';
end

Group = term(group);
 M = 1 + Group + Age + Sexe;
% M = 1 + Group + Age;
% M = 1 + Group + Sexe;
% M = 1 + Group;

figure; image(M);

slm = SurfStatLinMod( Y, M, surf);

contrast = Group.NTA - Group.TA;

slm = SurfStatT( slm, contrast );

% resels = SurfStatResels( slm, mask );
% stat_threshold( resels, length(slm.t), 1, slm.df );

[ pval, peak, clus ] = SurfStatP( slm, mask ); 

SurfStatView( pval, surf);