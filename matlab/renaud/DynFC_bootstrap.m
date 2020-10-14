function varargout = DynFC_bootstrap(tseries,varargin)

% usage : varargout = DynFC_bootstrap(tseries,varargin)
%
% Inputs :
%    tseries       : BOLD time-courses [nodes x Time]
%
% Options
%    TR            : TR value (Default: 2.4)
%    detrending    : do detrending (Default: true)
%    despiking     : do despiking (Default: false)
%    window        : window size (Default: 30)
%    methodCorr    : type of correlation ('L1' or 'correlation') (Default:
%                    'correlation')
%    alpha         : threshold for significativity (Default: 0.95)
%    mccount       : Number of simulations (Monte-Carlo simulation) (Default: 1000) 
%
% Output :
%    FNCdyn        : Dynamic BOLD connectivity
%    changeSig     : timings of connectivity changes
%    numOfStates   : number of connectivity changes
%    windowTimes   : windows of interest
%    FNCdynres     : Resmapling dynamic BOLD connectivity signal
%
% Renaud Lopes @ CHRU Lille, July 2014


%% ----------default arguments-----------
Args = struct('TR',2.4, ...
            'detrending',true, ... 
            'despiking',false, ... 
            'window',30, ...
            'methodCorr','correlation', ...
            'alpha',0.95, ...
            'mccount',1000);

Args = parseArguments(varargin,Args,{'BlackandWhite'});

% TR         = Args.TR;
% window     = Args.window;
% methodCorr = Args.methodCorr;
% dospiking  = Args.despiking;
% alpha      = Args.alpha;
% mccount    = Args.mccount;

%% 

nbins = 1000;
    
fprintf('\n');
fprintf('\t Computing dynamic FNC on subject ')

[FNCdyn,windowTimes,blambda,tcwin,A,Pdyn] = DynamicFunctionalConnectivityAnalysis(tseries,'TR',Args.TR,'wsize',Args.window,'method',Args.methodCorr,'allVoxels','no','detrending',Args.detrending,'window_alpha',1,'Despiking',Args.despiking);
%FNCdyn = niak_fisher(FNCdyn);

fprintf('\n');
fprintf('\t Done ')

%FNCdyn = (FNCdyn-mean(FNCdyn(:)))./(std((FNCdyn(:))));
%FNCdyn = FNCdyn*-1; % for anticorrelated

FNCdynres = zeros(length(windowTimes),size(FNCdyn,2));
deb = min(find(windowTimes==1));
fin = max(find(windowTimes==1));
FNCdynres(deb:fin,:) = FNCdyn;

%     figure; plot(tseries([1 2],:)');
%     figure; plot(FNCdynres)

nsig = size(tseries,1);
for k = 1:nsig
    ar1(k) = ar1nv(tseries(k,:));
end
nT  = size(tseries,2);
nC  = nsig*(nsig-1)/2;
wlc = zeros(nC,nbins);
nS  = size(FNCdyn,1);

fprintf('\n');
fprintf('\t Computing dynamic FNC on surrogate ')
fprintf('\n');
fprintf('\t %d rep ', Args.mccount)
for ii = 1:Args.mccount

    fprintf('%d, ', ii)

    tser_tmp = zeros(nsig,nT);
    for k = 1:nsig
        tser_tmp(k,:) = rednoise(nT,ar1(k),1)'; 
    end

    Surrogate = DynamicFunctionalConnectivityAnalysis(tser_tmp,Args.TR,'wsize',Args.window,'method',Args.methodCorr,'allVoxels','no','detrending',Args.detrending,'window_alpha',1,'Despiking',Args.despiking);
    %Surrogate(:,ii) = niak_fisher(Surrogate(:,ii));

    for k = 1:nC
        cd = squeeze(Surrogate(:,k));  % *-1 for anticorrelated
        cd = max(min(cd,1),0);
        cd = floor(cd*(nbins-1))+1;
        for jj=1:length(cd)
            wlc(k,cd(jj)) = wlc(k,cd(jj))+1;
        end
    end

end
fprintf('\n');
fprintf('\t Done ')
fprintf('\n');

changeSig   = zeros(nS,nC);
numOfStates = zeros(1,nC);
for k = 1:nC

    rsqy  = ((1:nbins)-.5)/nbins;
    ptile = wlc(k,:);
    idx   = find(ptile~=0);
    ptile = ptile(idx);
    rsqy  = rsqy(idx);
    ptile = cumsum(ptile);
    ptile = (ptile-.5)/ptile(end);
    sig95 = interp1(ptile,rsqy,Args.alpha)';

    FNCsig(:,k) = FNCdyn(:,k)./sig95;

    a = FNCsig(1:end-1,k);
    b = FNCsig(2:end,k);
    idneg = find(a>=1 & b<1)+1;
    idpos = find(a<1 & b>=1)+1;

    changeSig([idneg;idpos],k) = FNCdyn([idneg;idpos],k);
    %figure; subplot(2,1,1); plot(1:size(FNCdyn,1),FNCdyn(:,k),1:size(FNCdyn,1),changeSig(:,k),'+r'); subplot(2,1,2); plot(FNCsig(:,k));

    numOfStates(1,k) = length(idneg)+length(idpos);

end
    
varargout = {FNCdyn,FNCsig,changeSig,numOfStates,windowTimes,FNCdynres};
varargout = varargout(1:nargout);

