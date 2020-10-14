function [lambdas,info]= load_lambdas_mnc_emma(lambdasFnameBase)
% function [lambdas,info]= load_lambdas_mnc_emma(lambdasFnameBase)
%
% Read lambdas using SurfStatReadVol (requires EMMA)
% The output is in the format that SurfStat produces.
%
% Luis Concha. Sept 2008.


filesToLoad = {[lambdasFnameBase '1.mnc'];...
               [lambdasFnameBase '2.mnc'];...
               [lambdasFnameBase '3.mnc']};
disp('Loading:')
disp(filesToLoad)           



% Check if files are zipped (surfstat does not handle them very well)
Dz  = dir([lambdasFnameBase '*.mnc.gz']);
Dnz = dir([lambdasFnameBase '*.mnc']);
if size(Dz) > 0 
   zippedFiles = true;
elseif size(Dnz) > 0
   zippedFiles = false;
else
   disp('Could not find files to load');
   return
end


if zippedFiles
   disp('Unzipping files...');
   eval(['!gunzip ' lambdasFnameBase '*.mnc.gz']) 
end


[ data, data_info ] = SurfStatReadVol(filesToLoad);

lambdas = zeros(3,numel(data_info.lat));
for comp = 1:3
    img = reshape(data(comp,:),size(data_info.lat));
    img = flipdim(img,2);
    img = flipdim(img,1);
    lambdas(comp,:) = reshape(img,1,numel(img));
end


% lambdas = reshape(img,3,numel(data_info.lat));
info    = data_info;


if zippedFiles
   disp('Zipping files...')
   eval(['!gzip ' lambdasFnameBase '*.mnc']) 
end


disp('Finished loading lambdas');

