function DGPaths(BaseDirectory)
% DGPATHS adds the various directories used by the diffusion geometry code
% to the current path.  DGPaths will assume the current directory is the
% base directory unless an 

fprintf('DGPaths.m: setting diffusion geometry paths ... \n');

if nargin==0
    Prefix  = [pwd filesep];
else
    Prefix  = [BaseDirectory filesep];
end    

appendpath([Prefix 'Diffusions']);

% choose your nearest neighbors code by changing this line
appendpath([Prefix 'Diffusions' filesep 'Nearest Neighbors' filesep 'Windows']);
appendpath([Prefix 'MEX']);
appendpath([Prefix 'Wavelets']);
appendpath([Prefix 'Misc']);
appendpath([Prefix 'Drawing']);

fprintf('DGPaths.m: disabling case sensitivity warning ... \n');
warning('off','MATLAB:dispatcher:InexactMatch');

function appendpath(string)

fprintf('\t%s\\ \n', string);
addpath(string);

