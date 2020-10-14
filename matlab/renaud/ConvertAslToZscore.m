function ConvertAslToZscore(datapath,file_lh,file_rh,method)

global X Y

data_lh = SurfStatReadData( fullfile(datapath,file_lh) );
data_rh = SurfStatReadData( fullfile(datapath,file_rh) );
nb_lh   = length(data_lh);

if(method==1)
    
    % Hemisphere: One by one 
    Mean_lh = mean(data_lh);
    Std_lh  = std(data_lh);
    data_lh_zscore = ( data_lh - Mean_lh) ./ Std_lh ;
    data_lh_zscore(~isfinite(data_lh_zscore))=0;

    Mean_rh = mean(data_rh);
    Std_rh  = std(data_rh);
    data_rh_zscore = ( data_rh - Mean_rh) ./ Std_rh ;
    data_rh_zscore(~isfinite(data_rh_zscore))=0;

    % save
    [pathstr,name,ext] = fileparts(file_lh);
    SurfStatWriteData(fullfile(datapath,[name '.zscore']),data_lh_zscore,'b');

    [pathstr,name,ext] = fileparts(file_rh);
    SurfStatWriteData(fullfile(datapath,[name '.zscore']),data_rh_zscore,'b');
    
elseif(method==2)
    
    % Hemisphere: One by one 
    dstd = norm(data_lh,2) ./ sqrt(length(data_lh) - 1);
    if (dstd ~= 0)
        data_lh_zscore = data_lh./(eps + dstd);
    else
        disp('-- Not converting to z-scores as division by zero warning may occur.');
        data_lh_zscore = data_lh;
    end
    
    dstd = norm(data_rh,2) ./ sqrt(length(data_rh) - 1);
    if (dstd ~= 0)
        data_rh_zscore = data_rh./(eps + dstd);
    else
        disp('-- Not converting to z-scores as division by zero warning may occur.');
        data_rh_zscore = data_rh;
    end

    data_lh_zscore(~isfinite(data_lh_zscore)) = 0;
    data_rh_zscore(~isfinite(data_rh_zscore)) = 0;
    
    % save
    [pathstr,name,ext] = fileparts(file_lh);
    SurfStatWriteData(fullfile(datapath,[name '.zscore']),data_lh_zscore,'b');

    [pathstr,name,ext] = fileparts(file_rh);
    SurfStatWriteData(fullfile(datapath,[name '.zscore']),data_rh_zscore,'b');

else

    % Hemisphere: Together
    data    = [data_lh(:);data_rh(:)];
    MeanVal = mean(data);
    StdVal  = std(data);
    data_zscore = ( data - MeanVal) ./ StdVal ;
    data_zscore(~isfinite(data_zscore))=0;
    
    % save
    [pathstr,name,ext] = fileparts(file_lh);
    SurfStatWriteData(fullfile(datapath,[name '.zscore']),data_zscore(1:nb_lh)','b');

    [pathstr,name,ext] = fileparts(file_rh);
    SurfStatWriteData(fullfile(datapath,[name '.zscore']),data_zscore(nb_lh+1:end)','b');
    
end



% % Histogram computation and normalization
% M = data_lh_zscore(:);
% [Y,X] = hist(M,length(M)/100);
% Y     = Y/(length(M)*(max(X)-min(X)))*length(X);
% 
% % Gaussian parameters fitting.
% par = fminsearch('gaussien',[median(M);1.4826*median(abs(M-median(M)))]);
% %par = fminsearch('gaussien',[mean(M);std(M)]);
% 
% visu=1;
% if visu
%     [err,val] = gaussien(par);
%     figure
%     bar(X,Y); hold on; plot(X,val,'r');
%     title('Empirical distribution and fitted gaussian function');
% end
% 
% % Histogram computation and normalization
% M = data_rh_zscore(:);
% [Y,X] = hist(M,length(M)/100);
% Y     = Y/(length(M)*(max(X)-min(X)))*length(X);
% 
% % Gaussian parameters fitting.
% par = fminsearch('gaussien',[median(M);1.4826*median(abs(M-median(M)))]);
% %par = fminsearch('gaussien',[mean(M);std(M)]);
% 
% visu=1;
% if visu
%     [err,val] = gaussien(par);
%     figure
%     bar(X,Y); hold on; plot(X,val,'r');
%     title('Empirical distribution and fitted gaussian function');
% end
