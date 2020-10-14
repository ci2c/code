clear all

load('/home/alice/SVN/medial_wall.mat');
mask=~Mask;

surf=SurfStatReadSurf({['/home/fatmike/Protocoles_3T/Strokdem/FS5.1/fsaverage/surf/lh.pial'],['/home/fatmike/Protocoles_3T/Strokdem/FS5.1/fsaverage/surf/rh.pial']});

[ageTC, subjidTC, sexeTC] = xlsread('/home/clement/Documents/Datas STROKDEM/Trouble_Cog');
[ageNTC, subjidNTC, sexeNTC] = xlsread('/home/clement/Documents/Datas STROKDEM/Non_Trouble_Cog');


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

% 
YM6_TC=mean(Y_M6TC).*mask;
YM6_NTC=mean(Y_M6NTC).*mask;
DiffM6Cog=YM6_NTC-YM6_TC;
%figure, SurfStatView(YM6_Cog, surf);
%figure, SurfStatView(YM6_NoCog, surf);
figure, SurfStatView(DiffM6Cog, surf);
%SurfStatColLim([-0.5,0.5]);

% YM36_TC=mean(Y_M36TC).*mask;
% YM36_NTC=mean(Y_M36NTC).*mask;
% DiffM36Cog=YM36_NTC-YM36_TC;
% %figure, SurfStatView(YM6_Cog, surf);
% %figure, SurfStatView(YM6_NoCog, surf);
% figure, SurfStatView(DiffM36Cog, surf);
% SurfStatColLim([-1,1]);



% Y72H_TC=mean(Y_72HTC).*mask;
% Y72H_NTC=mean(Y_72HNTC).*mask;
% Diff72HCog=Y72H_NTC-Y72H_TC;
% %figure, SurfStatView(Y72H_Cog, surf);
% %figure, SurfStatView(Y72H_NoCog, surf);
% figure, SurfStatView(Diff72HCog, surf);
% %SurfStatColLim([-1,1]);




    
