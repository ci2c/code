function PlotFAvsDist(Featurepath, Fiberspath, FibersDistpath, Increment)
% 
% usage : PlotFAvsDist(Feature, Fibers, FibersDist, Increment)
%
% Feature     : Path to the feature volume.
% Fibers      : Path to the fiber tracts.
% FibersDist  : Path to the fiber tracts compensated for distance.
% Increment   : Distance increment (default = 2).
% 
% Pierre Besson, 2010

if nargin ~= 3 & nargin ~=4
    error('Invalid usage');
end

if nargin < 4
    Increment = 2;
end

% Load data
Feature = load_nifti(Featurepath);
Fibers = load_nifti(Fiberspath);
FibDist = load_nifti(FibersDistpath);


Distance = FibDist.vol ./ Fibers.vol;
Distance(isnan(Distance)) = 0;
Distance(isinf(Distance)) = 0;

WFeature = Feature.vol .* Fibers.vol;
MeanVec = [];
StdVec = [];
DistVec = [];
NbFib = [];
NbVox = [];

MIN = min(Distance(Distance(:)~=0));
MAX = min(800, max(Distance(:)));

for d = MIN : Increment : MAX
    Region = ((Distance >= d) & (Distance < d + Increment));
    Bin = sum(WFeature(Region(:)));
    NFib = sum(Fibers.vol(Region(:)));
    Mean = Bin ./ NFib;
    Var = var(Feature.vol(Region(:)), Fibers.vol(Region(:)));
    Std = sqrt(Var);
    MeanVec = [MeanVec, Mean];
    StdVec = [StdVec, Std];
    DistVec = [DistVec, d];
    NbFib = [NbFib, NFib];
    NbVox = [NbVox, sum(Region(:))];
end


figure, plot(DistVec, MeanVec);
hold on, plot(DistVec, StdVec + MeanVec, 'r--');
hold on, plot(DistVec, -StdVec + MeanVec, 'r--');

figure, plot(DistVec, NbFib)
figure, plot(DistVec, NbVox)

Mean = sum(WFeature(Fibers.vol(:)~=0)) ./ sum(Fibers.vol(Fibers.vol(:)~=0));
Var = var(Feature.vol(Fibers.vol(:)~=0), Fibers.vol(Fibers.vol(:)~=0));
SD = sqrt(Var);
disp(['Mean = ', num2str(Mean)]);
disp(['SD = ', num2str(SD)]);
