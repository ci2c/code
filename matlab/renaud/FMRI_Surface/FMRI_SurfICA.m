function sica = FMRI_SurfICA(plh,prh,TR,nbcomp)

% usage : V = FMRI_SurfICA(fspath,sesspath,TR,plh,prh,[nbcomp])
%
% Inputs :
%    fspath        : path to freesurfer folder
%    sesspath      : path to data
%    TR            : TR
%    plh           : FMRI mapping file (left) (nifti)
%    prh           : FMRI mapping file (right) (nifti)
%
% Options :
%    nbcomp        : number of components (Default: 40)
%
% Renaud Lopes @ CHRU Lille, Mar 2012

if nargin ~= 3 && nargin ~= 4
    error('invalid usage');
end

default_nbcomp = 40;

% check args
if nargin < 4
    nbcomp = default_nbcomp;
end

%% READ DATA

hdr_lh   = load_nifti(plh);
hdr_rh   = load_nifti(prh);
data_lh  = squeeze(hdr_lh.vol);
data_rh  = squeeze(hdr_rh.vol);
nbleft   = size(data_lh,1);
clear hdr_lh hdr_rh;

data     = [data_lh;data_rh];
tseries  = data';
clear data_lh data_rh data; 

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
if isfield(res_ica,'residus')
    sica.residus = res_ica.residus;
end
if isfield(res_ica,'prior')
    sica.prior = res_ica.prior;
end
clear res_ica
sica.TR = TR;

