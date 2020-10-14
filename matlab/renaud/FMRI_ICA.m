function sica = FMRI_ICA(vol,maskFile,TR,nbcomp)

% usage : sica = FMRI_ICA(vol,TR,[nbcomp])
%
% Inputs :
%    vol             : 4D volume
%    maskFile      : nifti mask
%    TR            : TR
%
% Options :
%    nbcomp        : number of components (Default: 40)
%
% Renaud Lopes @ CHRU Lille, Feb 2013

if nargin ~= 3 && nargin ~= 4
    error('invalid usage');
end

default_nbcomp = 40;

% check args
if nargin < 4
    nbcomp = default_nbcomp;
end

%% READ DATA

dim     = size(vol);
hmask   = spm_vol(maskFile);
mask    = spm_read_vols(hmask);
tseries = reshape(vol,dim(1)*dim(2)*dim(3),dim(4));
ind     = find(mask(:)>0);
tseries = tseries(ind,:);
tseries = tseries';

%% DETRENDING

ord_detr = 2;
fprintf('Correction of %ith order polynomial trends \n',ord_detr)
tseries = detrend_array(tseries,ord_detr);

%% NORMALISE

type_norm = 0;
fprintf('Correction to zero mean and unit temporal variance \n');
[tseries,M,Varr] = st_normalise(tseries,type_norm);

%% SICA

% sica computation
optsica.algo          = 'Infomax';
optsica.param_nb_comp = nbcomp;
optsica.type_nb_comp  = 0;

res_ica = st_do_sica(tseries,optsica);

sica.S       = res_ica.composantes;
res_ica      = rmfield(res_ica,'composantes');
sica.A       = res_ica.poids;
res_ica      = rmfield(res_ica,'poids');
sica.nbcomp  = res_ica.nbcomp;
sica.contrib = res_ica.contrib;
sica.mask    = mask;
if isfield(res_ica,'residus')
    sica.residus = res_ica.residus;
end
if isfield(res_ica,'prior')
    sica.prior = res_ica.prior;
end
clear res_ica
sica.TR = TR;
