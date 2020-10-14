function clearConnectomeFibers(FilePath)
% Usage : clearConnectomeFibers(FILEPATH)
%
% Remove the fiber field to light the Connectome structures
%
% Ex : clearConnectomeFibers('/path/to/connectomes/Connectome*.mat')
%
% Pierre Besson @ CHRU Lille, Oct. 2011.

if nargin ~= 1
    error('invalid usage');
end

List = SurfStatListDir(FilePath);

for i = 1 : length(List)
    disp(['Loading ' char(List(i))]);
    eval(['load ' char(List(i))]);
    
    Connectome.fibers = [];
    
    eval(['save ', char(List(i)), ' Connectome -v7.3']);
    
    clear Connectome;
end