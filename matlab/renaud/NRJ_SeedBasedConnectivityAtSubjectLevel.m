function NRJ_SeedBasedConnectivityAtSubjectLevel(epiFiles,seedFile,outFile,filter,label)

if nargin < 4
    filter = struct('do',true,'flag_mean',1,'tr',2,'hp',0.01,'lp',0.1);
end
if nargin < 5
    label = [];
end

optn.type = 'mean_var';

% Concatenate runs
tseries = [];
for k = 1:length(epiFiles)    
    [hdr,vol] = niak_read_vol(epiFiles{k});
    dim       = size(vol);
    vol       = reshape(vol,dim(1)*dim(2)*dim(3),dim(4))';
    vol       = niak_normalize_tseries(vol,optn);
    tseries   = [tseries; vol];
end

% filtering
if filter.do
    tseries = niak_filter_tseries(tseries,filter);
end

% seed
[hseed,seedVol] = niak_read_vol(seedFile);
seedVol         = seedVol(:);
if isempty(label)
    seed = mean(tseries(:,find(seedVol>0)),2);
else
    seed = mean(tseries(:,find(seedVol<label+0.1 & seedVol>label-0.1)),2);
end

% seed-based connectivity
conn = corr(tseries,seed);
conn = niak_fisher(conn);
conn(isnan(conn)) = 0;

% write results
hseed.file_name=outFile;
conn = reshape(conn,dim(1),dim(2),dim(3));
niak_write_vol(hseed,conn);
