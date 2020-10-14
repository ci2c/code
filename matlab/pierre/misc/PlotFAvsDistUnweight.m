function PlotFAvsDistUnweight(Featurepath, Fiberspath, FibersDistpath, TextCurv, Increment)
% 
% usage : PlotFAvsDistUnweight(Feature, Fibers, FibersDist, TextCurv, Increment)
%
% Feature     : Path to the feature volume.
% Fibers      : Path to the fiber tracts.
% FibersDist  : Path to the fiber tracts compensated for distance.
% TextCurv    : Name of the output text file
% Increment   : Distance increment (default = 2).
% 
% Pierre Besson @ CHRU Lille, Sep. 2011

if nargin ~= 4 & nargin ~=5
    error('Invalid usage');
end

if nargin < 5
    Increment = 2;
end

% Load data
Feature = load_nifti(Featurepath);
Fibers = load_nifti(Fiberspath);
FibDist = load_nifti(FibersDistpath);


Distance = FibDist.vol ./ Fibers.vol;
Distance(isnan(Distance)) = 0;
Distance(isinf(Distance)) = 0;

MeanVec = [];
StdVec = [];
DistVec = [];

MIN = min(Distance(Distance(:)~=0));
MAX = min(800, max(Distance(:)));

for d = MIN : Increment : MAX
    Region = ((Distance >= d) & (Distance < d + Increment));
    Mean = mean(Feature.vol(Region(:)));
    Std = std(Feature.vol(Region(:)));
    MeanVec = [MeanVec, Mean];
    StdVec = [StdVec, Std];
    DistVec = [DistVec, d];
end

figure, plot(DistVec, MeanVec);
% hold on, plot(DistVec, StdVec + MeanVec, 'r--');
% hold on, plot(DistVec, -StdVec + MeanVec, 'r--');

dlmwrite(TextCurv, [DistVec', MeanVec'], 'delimiter', ' ');

Mean = mean(Feature.vol(Fibers.vol(:)~=0));
SD = std(Feature.vol(Fibers.vol(:)~=0));
disp(['Mean = ', num2str(Mean)]);
disp(['SD = ', num2str(SD)]);
