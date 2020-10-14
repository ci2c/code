function PlotImageHisto(image_path, out_histo, n_bins)
% 
% usage : PlotImageHisto(image_path, out_histo, n_bins)
%
% image_path  : Path to input image
% out_histo   : Name of the output text file
%
% Option :
% n_bins      : Number of bins (default : 50)
% 
% Pierre Besson @ CHRU Lille, Mar. 2012

if nargin ~= 2 && nargin ~= 3
    error('invalid usage');
end

if nargin == 2
    n_bins = 50;
end

V = load_nifti(image_path);
Vals = V.vol(V.vol(:)~=0);

dlmwrite(out_histo, Vals);

hist(Vals, n_bins);