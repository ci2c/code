function [data_lh,data_rh] = ConvertAslToZscore(file_lh,file_rh)

global X Y

data_lh = SurfStatReadData( file_lh );
data_rh = SurfStatReadData( file_rh );

% Histogram computation and normalization
M = [data_lh data_rh];
M     = M(:);
[Y,X] = hist(M,length(M)/100);
Y     = Y/(length(M)*(max(X)-min(X)))*length(X);

% Gaussian parameters fitting.
par = fminsearch('gaussien',[median(M);1.4826*median(abs(M-median(M)))]);
%par = fminsearch('gaussien',[mean(M);std(M)]);

visu=1;
if visu
    [err,val] = gaussien(par);
    figure
    bar(X,Y); hold on; plot(X,val,'r');
    title('Empirical distribution and fitted gaussian function');
end