function [csf, gm, wm, air] = tissuemaps2(img,sl)
%   Multi-contrast neurological tissue segmentation
%   Required functions:
%   
%   Usage: [csf, gm, wm, air] = tissuemaps(img,sl)
%   Author: Marc Lebel
%   Date: 09/2006
%   
%   Input:
%   img = the image matrix of size M x N x O x P
%       M x N: in-plane matrix
%       O    : number of slices
%       P    : number of contrasts
%   sl = image slice to manualy select csf, gm, wm, air
%   
%   Outputs:
%   csf = csf map of size M x N
%   gm  = gm  map of size M x N
%   wm  = wm  map of size M x N
%   air = air map of size M x N (if three or more scans)

%   Check input arguments
if nargin < 1
    error('tissuemaps2: function requires at least one input')
end

%   Add normalization condition
N = size(img);
%img(:,:,:,N(4)+1) = ones(N(1),N(2),N(3));

%   Get and check img size
N = size(img);
if length(N) ~= 4
    error('tissuemaps: img must be M x N x O x P')
end
nTR = N(4);
if nTR < 3
    error('tissuemaps: requires at least 3 contrasts')
end

%   If not provided, choose middle slice
if nargin < 2
    sl = round(N(3)/2);
end

%   Generate initial kmeans-like mask
%   Adjust nT to make an nT-bit image to help find rois
nT = 10;
tempimg = (squeeze(img(:,:,sl,1)));
% [dummy,ind] = sort(tempimg(:));
% tempimg(tempimg < dummy(round(length(ind)*0.050))) = dummy(round(length(ind)*0.050));
% tempimg(tempimg > dummy(round(length(ind)*0.999))) = dummy(round(length(ind)*0.999));
% mxval = max(abs(tempimg(:)));
% mask = double(int8(nT*tempimg/mxval));
im2 = tempimg - min(tempimg(:));
mask = round((im2.*10) ./ max(im2(:)));
clear dummy ind mxval

%   Create figure window
fnum = figure('Name','TissueMaps 1.0','NumberTitle','off','Position',[50,100,768,798],'DockControls','off','MenuBar','none','Toolbar','none','Resize','off');
infot = uicontrol('Style','text','String','Select CSF, GM, WM, and air points. Hit enter to continue.','Position',[0 768 768 20],'FontSize',14,'BackgroundColor','w','HorizontalAlignment','center');
ax = axes('Units','pixels','Position',[0 0 768 768],'XTick',[],'YTick',[]);
set([infot,ax],'Units','normalized');

%   Plot mask and get regions for csf, gm, wm
set(fnum,'CurrentAxes',ax);
imagesc(mask);axis square;colormap gray;
set(gcf,'Color','w');
x = [];
while length(x) ~= 4
    [x,y] = getpts(ax);
    if length(x) ~= 4
        set(infot,'String','Please select 4 points for CSF, GM, WM, and air. Hit enter to continue.');
    end
end
close;
drawnow;

%   Convert these points to rois over full volume
x = round(x);
y = round(y);
ind = sub2ind([N(1) N(2)],y,x);
roi_csf = find(mask == mask(ind(1)));
roi_gm  = find(mask == mask(ind(2)));
roi_wm  = find(mask == mask(ind(3)));
roi_sig = find(mask ~= mask(ind(4))); % Could be used for masking

%   Normalize image intensities to csf in image 1
%   (helps evenly weight the unity normalization)
normsig = img(:,:,sl,1);
normsig = median(normsig(roi_csf));
img(:,:,:,1:nTR-1) = img(:,:,:,1:nTR-1)./normsig;
clear normsig

%   Determine average tissue signal in each image
b = [];
for i = 1:nTR
    img_temp = img(:,:,sl,i);
    if nTR > 3
        b = [b;median(img_temp(roi_csf)) median(img_temp(roi_gm)) median(img_temp(roi_wm)) 0];
    else
        b = [b;median(img_temp(roi_csf)) median(img_temp(roi_gm)) median(img_temp(roi_wm))];
    end
end
% if nTR > 3
%     b(end,end) = 1;
% end
clear img_temp

%   Compute weighted pseudo inverse (weighting only affects things when overdetermined)
W = diag([ones(1,nTR-1) 1]);
B = inv((W*b)' * (W*b)) * (W*b)' * W';

%   Initialize output variables
csf = zeros(N(1),N(2),N(3));
gm  = zeros(N(1),N(2),N(3));
wm  = zeros(N(1),N(2),N(3));
air = zeros(N(1),N(2),N(3));

%   Loop through each slice then each pixel location and solve for concentrations
my_textProgress(0,N(3),'Calculating tissue concentration. % done: ');
for i = 1:N(1)
    my_textProgress(i,N(1))
    for j = 1:N(2)
        for k = 1:N(3)
            
            %   Obtain signal vector
            S = img(i,j,k,:);            

            %   Compute concentrations
            C = B * S(:);
            
            %   Return concentration to storage variables
            csf(i,j,k) = C(1);
            gm(i,j,k)  = C(2);
            wm(i,j,k)  = C(3);
%             if nTR > 3
%                 air(i,j,k) = C(4);
%             end
        end
    end
end
return
