function X = FMRI_Detrending(infile,outfile,maskfile,wmfile,csffile,motionfile,TR)

% Open image:
[hdr,epi] = niak_read_vol(infile);
[numxs,numys,numslices,numframes] = size(epi);
numpix     = numxs*numys;
n_trends   = 3;
n_temporal = 3;

% Keep time points that are not excluded:
allpts          = 1:numframes;
exclude         = [];
allpts(exclude) = zeros(1,length(exclude));
keep            = allpts( find( allpts ) );
n               = length(keep);

% Create temporal trends:
n_spline=round(n_temporal*TR*n/360)
if n_spline>=0 
   trend=((2*keep-(max(keep)+min(keep)))./(max(keep)-min(keep)))';
   if n_spline<=3
      temporal_trend=(trend*ones(1,n_spline+1)).^(ones(n,1)*(0:n_spline));
   else
      temporal_trend=(trend*ones(1,4)).^(ones(n,1)*(0:3));
      knot=(1:(n_spline-3))/(n_spline-2)*(max(keep)-min(keep))+min(keep);
      for k=1:length(knot)
         cut=keep'-knot(k);
         temporal_trend=[temporal_trend (cut>0).*(cut./max(cut)).^3];
      end
   end
else
   temporal_trend=[];
end 

% Create spatial trends:
[hdrm,mask]        = niak_read_vol(maskfile);
[hdrw,wm]          = niak_read_vol(wmfile);
[hdrc,csf]         = niak_read_vol(csffile);
epi                = reshape(epi,numpix*numslices,numframes);
ind                = find(mask(:)==0);
epi(ind,:)         = 0;
spatial_trend      = zeros(numframes,3);
ind                = find(mask(:)>0);
spatial_trend(:,1) = mean(epi(ind,:),1)';
ind                = find(wm(:)>0);
spatial_trend(:,2) = mean(epi(ind,:),1)';
ind                = find(csf(:)>0);
spatial_trend(:,3) = mean(epi(ind,:),1)';
clear hdrm hdrw hdrc csf wm mask;

% Motion trends
[p,n,e] = fileparts(files_in.motion_param);
if strcmp(e,'.mat')
    transf = load(files_in.motion_param);
    [rot,tsl] = niak_transf2param(transf.transf);
    motion = [tsl;rot];
elseif strcmp(e,'.txt') || strcmp(e,'')
    motion = load(files_in.motion_param)';
%     rot = motion(4:6,:);
%     tsl = motion(1:3,:);
end

X = [spatial_trend temporal_trend motion];
clear spatial_trend temporal_trend motion;

% - calcul des betas
X    = X';
beta = epi*X'*pinv(X*X');
% - calcul des residus
epi  = epi - beta*X;
epi  = reshape(epi,numxs,numys,numslices,numframes);

% writing file_out
hdr_out            = hdr;
hdr_out.file_name  = outfile;
opt_hist.command   = 'FMRI_Detrending';
opt_hist.files_in  = infile;
opt_hist.files_out = outfile;
opt_hist.comment   = sprintf('Detrending');
hdr_out            = niak_set_history(hdr_out,opt_hist);
niak_write_vol(hdr_out,epi);
clear epi;
