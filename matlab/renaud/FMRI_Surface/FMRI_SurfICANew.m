function sica = FMRI_SurfICANew(datapath,TR,prefix,nbcomp)

% usage : V = FMRI_SurfICA(datapath,TR,[nbcomp])
%
% Inputs :
%    datapath      : path to data
%    TR            : TR
%    prefix        : prefix of projection files
%
% Options :
%    nbcomp        : number of components (Default: 40)
%
% Renaud Lopes @ CHRU Lille, Jul 2012

if nargin ~= 3 && nargin ~= 4
    error('invalid usage');
end

default_nbcomp = 40;

% check args
if nargin < 4
    nbcomp = default_nbcomp;
end

%% READ DATA

List_lh = SurfStatListDir(fullfile(datapath,['lh.' prefix '*']));
List_rh = SurfStatListDir(fullfile(datapath,['rh.' prefix '*']));
tseries = SurfStatReadData([List_lh, List_rh]);
clear List_rh List_lh;

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
