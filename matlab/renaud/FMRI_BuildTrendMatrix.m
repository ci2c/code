function X = FMRI_BuildTrendMatrix(data,TR,exclude)

% Init:
[numxs numys numslices numframes] = size(data);
numpix     = numxs*numys;
n_spatial  = 1;
n_trends   = 3;
n_temporal = 8;

% Keep time points that are not excluded:
allpts          = 1:numframes;
allpts(exclude) = zeros(1,length(exclude));
keep            = allpts( find( allpts ) );
n               = length(keep);

% Create spatial average, weighted by the first frame:
if length(n_trends)<=3
    spatial_av=zeros(numframes,1);
    tot=sum(sum(sum(data(:,:,:,keep(1)))));
    for i=1:numframes
        spatial_av(i)=sum(sum(sum(data(:,:,:,i).*data(:,:,:,keep(1)))))/tot;
     end
     clear d1;
else
    spatial_av=n_trends((1:numframes)+3)';
end

% Create temporal trends:
n_spline = round(n_temporal*TR*n/360)
if n_spline>=0 
   trend = ((2*keep-(max(keep)+min(keep)))./(max(keep)-min(keep)))';
   if n_spline<=3
      temporal_trend = (trend*ones(1,n_spline+1)).^(ones(n,1)*(0:n_spline));
   else
      temporal_trend = (trend*ones(1,4)).^(ones(n,1)*(0:3));
      knot = (1:(n_spline-3))/(n_spline-2)*(max(keep)-min(keep))+min(keep);
      for k=1:length(knot)
         cut = keep'-knot(k);
         temporal_trend = [temporal_trend (cut>0).*(cut./max(cut)).^3];
      end
   end
else
   temporal_trend = [];
end 

% Create spatial trends:
if n_spatial>=1 
   trend = spatial_av(keep)-mean(spatial_av(keep));
   spatial_trend = (trend*ones(1,n_spatial)).^(ones(n,1)*(1:n_spatial));
else
   spatial_trend = [];
end 

X = [spatial_trend temporal_trend];


