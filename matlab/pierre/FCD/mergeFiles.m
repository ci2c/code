function mergeFiles(pattern, output)
% 
% Merge several files into one
%
% usage : mergeFiles(pattern, output)
%
% Inputs
%     pattern      : regexp pattern of input files to merge
%     output       : output name
%              File will be saved in ASCII using SurfStatWriteData
%              and will not be readable by freesurfer
%
% Pierre Besson @ CHRU Lille, 2012

if nargin ~= 2
    error('invalid usage');
end

file_list = SurfStatListDir(pattern);

Data = SurfStatReadData(file_list);

SurfStatWriteData(output, Data, 'b');