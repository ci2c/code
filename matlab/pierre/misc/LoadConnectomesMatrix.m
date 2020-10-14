function Matrix = LoadConnectomesMatrix(FilePath)
% Usage : Matrix = LoadConnectomesMatrix(FILEPATH)
%
% Create a 3D Matrix from all the connectivity matrices located in FILEPATH
%
% Ex : M = LoadConnectomeMatrix('/path/to/connectomes/Connectome*.mat')
%
% Pierre Besson @ CHRU Lille, Feb. 2011.

if nargin ~= 1
    error('invalid usage');
end

List = SurfStatListDir(FilePath);

Matrix = [];

for i = 1 : length(List)
    disp(['Loading ' char(List(i))]);
    eval(['load ' char(List(i))]);
    try
        Matrix = cat(3, Matrix, Connectome.Mfa);
        % Matrix = cat(3, Matrix, Mfa_cuts);
        % Matrix = cat(3, Matrix, (Connectome.Mfa) ./ max(Connectome.Mfa(:)));
        % Matrix = cat(3, Matrix, Connectome.M);
        % clear Connectome
    catch
        clear Connectome
        error('all connectome should have same size');
    end
end