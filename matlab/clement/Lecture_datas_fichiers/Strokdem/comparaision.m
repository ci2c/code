clc
clear all
close all

%% Data recuperation
load('/home/alice/SVN/medial_wall.mat');
mask=~Mask;

surf=SurfStatReadSurf({['/home/fatmike/Protocoles_3T/Strokdem/FS5.1/fsaverage/surf/lh.pial'],['/home/fatmike/Protocoles_3T/Strokdem/FS5.1/fsaverage/surf/rh.pial']});

[subjid, age, fat, dep, cog, mem] = textread( '/home/fatmike/Protocoles_3T/Strokdem/test/test_reg/script/Info_Strokdem_M6.txt', '%s %f %s %s %s %s' );
%exclude=[{'731001CL'},{'680917AG'},{'610612HV'},{'600506GH'},{'580620CG'},{'540724JLC'},{'540310PE'},{'531019PL'},{'530816CG'},{'510115PD'},{'420919CB'},{'381020LF'},{'360821GV'},{'340321SG'},{'340303JV'},{'280515LD'},{'360506JB'},{'380611JL'},{'400317CA'},{'420203JL'},{'470101MT'},{'490226YB'},{'510702MFB'},{'520214ML'},{'580714PF'},{'671019LN'},{'230805JA'}, {'251120BL'}, {'300530AH'},{'311006LD'}, {'340301LD'}, {'340608YR'}, {'350517BB'}, {'360110GO'}, {'360821GD'}, {'360826MB'}, {'371218ET'}, {'391130GW'},{'400127AD'},{'400317AC'},{'420608JD'},{'430627KP'},{'470323DV'},{'480815MHJ'},{'481012GT'},{'490522JC'},{'500628MW'},{'560413DC'},{'570226LD'},{'600130DC'},{'630527GT'},{'640425SV'},{'690510ND'},{'690526CR'},{'810305BB'},{'840909AD'},{'500711PF'},{'600816JS'}];

ind_exclude=[];
for j=1:length(subjid)
    M6=['/home/fatmike/Protocoles_3T/Strokdem/FS5.1/',char(subjid(j)),'_M6/surf/lh.thickness.fwhm20.fsaverage.mgh'];
    H72=['/home/fatmike/Protocoles_3T/Strokdem/FS5.1/',char(subjid(j)),'_72H/surf/lh.thickness.fwhm20.fsaverage.mgh'];
    A=exist(M6,'file');
    B=exist(H72,'file');
    if ( A==0 || B==0)
        ind_exclude=[ind_exclude j];
    end
end

j=1;

for i=1:length(subjid)
   if (i~=ind_exclude)
       Subjid(j)=subjid(i);
       ind_S(j)=i;
       j=j+1;
   end
end

Age=age(ind_S);
Cog=cog(ind_S);
Dep=dep(ind_S);
Fat=fat(ind_S);
Mem=mem(ind_S);

ind_nodep=find(strcmp(Dep,'nodep'));
ind_nofat=find(strcmp(Fat,'nofat'));ind_nocog=find(strcmp(Cog,'nocog'));
ind_fat=find(strcmp(Fat,'fat'));ind_cog=find(strcmp(Cog,'cog'));
ind_mem=find(strcmp(Mem,'mem'));ind_dep=find(strcmp(Dep,'dep'));

clear i j A B subjid ind_exclude Mask H72 M6

%%

for i=1:length(Subjid)
   % disp(Subjid(i));
    Y_72H(i,:)=SurfStatReadData({['/home/fatmike/Protocoles_3T/Strokdem/FS5.1/',char(Subjid(i)),'_72H/surf/lh.thickness.fwhm20.fsaverage.mgh'],['/home/fatmike/Protocoles_3T/Strokdem/FS5.1/',char(Subjid(i)),'_72H/surf/rh.thickness.fwhm20.fsaverage.mgh']} );
    Y_M6(i,:)=SurfStatReadData({['/home/fatmike/Protocoles_3T/Strokdem/FS5.1/',char(Subjid(i)),'_M6/surf/lh.thickness.fwhm20.fsaverage.mgh'],['/home/fatmike/Protocoles_3T/Strokdem/FS5.1/',char(Subjid(i)),'_M6/surf/rh.thickness.fwhm20.fsaverage.mgh']} );
   
end
% 
% Y72H_Fat=mean(double(Y_72H(ind_fat,:))).*mask;
% Y72H_NoFat=mean(double(Y_72H(ind_nofat,:))).*mask;
% Diff72HFat=Y72H_NoFat-Y72H_Fat;
% %figure, SurfStatView(Y72H_Fat, surf);
% %figure, SurfStatView(Y72H_NoFat, surf);
% figure, SurfStatView(Diff72HFat, surf);

% YM6_Fat=mean(double(Y_M6(ind_fat,:))).*mask;
% YM6_NoFat=mean(double(Y_M6(ind_nofat,:))).*mask;
% DiffM6Fat=YM6_NoFat-YM6_Fat;
% %figure, SurfStatView(YM6_Fat, surf);
% %figure, SurfStatView(YM6_NoFat, surf);
% figure, SurfStatView(DiffM6Fat, surf);
% 
% 
Y72H_Cog=mean(double(Y_72H(ind_cog,:))).*mask;
Y72H_NoCog=mean(double(Y_72H(ind_nocog,:))).*mask;
Diff72HCog=Y72H_NoCog-Y72H_Cog;
%figure, SurfStatView(Y72H_Cog, surf);
%figure, SurfStatView(Y72H_NoCog, surf);
figure, SurfStatView(Diff72HCog, surf);

YM6_Cog=mean(double(Y_M6(ind_cog,:))).*mask;
YM6_NoCog=mean(double(Y_M6(ind_nocog,:))).*mask;
DiffM6Cog=YM6_NoCog-YM6_Cog;
%figure, SurfStatView(YM6_Cog, surf);
%figure, SurfStatView(YM6_NoCog, surf);
figure, SurfStatView(DiffM6Cog, surf);
% 
% 
% Y72H_Dep=mean(double(Y_72H(ind_dep,:))).*mask;
% Y72H_NoDep=mean(double(Y_72H(ind_nodep,:))).*mask;
% Diff72HDep=Y72H_NoDep-Y72H_Dep;
% %figure, SurfStatView(Y72H_Dep, surf);
% %figure, SurfStatView(Y72H_NoDep, surf);
% figure, SurfStatView(Diff72HDep, surf);
% 
% YM6_Dep=mean(double(Y_M6(ind_dep,:))).*mask;
% YM6_NoDep=mean(double(Y_M6(ind_nodep,:))).*mask;
% DiffM6Dep=YM6_NoDep-YM6_Dep;
% %figure, SurfStatView(YM6_Dep, surf);
% %figure, SurfStatView(YM6_NoDep, surf);
% figure, SurfStatView(DiffM6Dep, surf);
% 
