function [data,data_info] = my_SurfStatReadVol1(fileName,option)
% function my_SurfStatReadVol(fileName)
% Simple wrapper to handle the unzipping of the file for surfstat
% files is a char array
%
% option is a char array. 'flip' = flip x and y dimensions.

if nargin < 2
   doFlip = false; 
end
if strcmp(option,'flip')
    doFlip=true;
end

if regexp(fileName,'.*\.mnc.gz')
      disp([fileName ' is zipped, unzipping']);
      unzippedFname = regexpi(fileName,'(.*)\.gz','tokens');
      unzippedFname = cell2mat(unzippedFname{:});
      [status,result] = system(['gunzip ' fileName]);
      

    if ~isempty(regexp(result,'not in gzip format', 'once' ))
        disp(['!mv ' fileName ' ' unzippedFname])
        eval(['!mv ' fileName ' ' unzippedFname])
    end
      
      [data,data_info] = SurfStatReadVol(unzippedFname);
      eval(['!gzip ' unzippedFname])
else
      [data,data_info] = SurfStatReadVol(fileName);
end



if doFlip
    img = reshape(data,[size(data_info.lat) 1]);
    img = flipdim(img,2);
    img = flipdim(img,1);
    data = reshape(img,1,numel(data_info.lat));
end