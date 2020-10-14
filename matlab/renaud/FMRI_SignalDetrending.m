function X = FMRI_SignalDetrending(epiFile,motionfile,TR)

% Open image:
[hdr,vol]  = niak_read_vol(epiFile);
[numxs numys numslices numframes] = size(vol);
numpix     = numxs*numys;
n_spatial  = 1;
n_trends   = 3;
n_temporal = 3;
vol = vol(:);
vol(isnan(vol)) = 0;
vol = reshape(vol,numxs,numys,numslices,numframes);

% Keep time points that are not excluded:
allpts          = 1:numframes;
exclude         = [];
allpts(exclude) = zeros(1,length(exclude));
keep            = allpts( find( allpts ) );
n               = length(keep);

% Create spatial average, weighted by the first frame:
if length(n_trends)<=3
    spatial_av=zeros(numframes,1);
    tot=sum(sum (sum ( vol(:,:,1:numslices,keep(1)) ) ) );
    for i=1:numframes
        spatial_av(i)=sum(sum(sum(vol(:,:,1:numslices,i).*vol(:,:,1:numslices,keep(1)))))/tot;
     end
     clear d1;
else
    spatial_av=n_trends((1:numframes)+3)';
end

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
if n_spatial>=1 
   trend=spatial_av(keep)-mean(spatial_av(keep));
   spatial_trend=(trend*ones(1,n_spatial)).^(ones(n,1)*(1:n_spatial));
else
   spatial_trend=[];
end 

% Add confounds:   
if exist(motionfile,'file')~=2
	disp('Le fichier n''existe pas');
    X = [spatial_trend temporal_trend];
else
    confounds = load(motionfile);
    confounds = confounds(:,1:6);
    X = [spatial_trend temporal_trend confounds];
end
% X = [spatial_trend temporal_trend];