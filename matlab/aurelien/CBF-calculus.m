clear all;

[fid1,chemin1]=uigetfile('');
disp([chemin1 fid1]);
ima1=dicomread([chemin1 fid1]);
ima1=double(ima1);
header=dicominfo([chemin1 fid1]);

slope=header.PerFrameFunctionalGroupsSequence.Item_1.Private_2005_140f.Item_1.Private_2005_100e;

ima1=ima1./slope;
control=ima1(:,:,1);
tag=ima1(:,:,2);
diff=control-tag;

CBF=1./((2./0.9).*(control./diff)./((exp(-1.2./0.91)-exp(-1.2./0.53))./(0.91-0.53)));

% X=0:0.01:2;
% CBF=1./((2./0.9).*(100./X)./((exp(-1.2./0.91)-exp(-1.2./0.53))./(0.91-0.53)));
% plot(X,CBF)
