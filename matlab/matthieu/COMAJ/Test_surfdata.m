clear all; close all;

%% Load group data from file "glimf.txt"
[fileleft, fileright] = textread('/NAS/tupac/matthieu/SVM/V1/glim.MGRousset.gn.fwhm10.txt', '%s %s' );

%% Read group CT data and view meanCT
for k = 1:71
    Y=SurfStatReadData({fileleft{k}, fileright{k}});
%     Y=SurfStatReadData(fileleft{k});
end