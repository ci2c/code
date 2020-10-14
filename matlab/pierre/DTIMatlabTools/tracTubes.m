function H = tracTubes(tracts,width,reduction);
% H = tracTubes(tracts,width,reduction);
% function to display lots of tubes, one for each line in the tract
% Use to display tracts loaded with ami2lines
% 
% example:
% H = tractTubes(fornix,0.1);
% the first argument, tracts (fornix in the example), is the tract to
% display
% the second argument, width (0.1) is the radius of the tubes. With some
% time, the function clinep (called by tracTubes) could be tweaked to
% display variable widths (a hypertube!).
% reduction > 1 (integer) will reduce the number of lines plotted (plot
% only every "reduction" lines)
% H contains the handles for each and every tube. To change some property,
% use set(H(index),'Property',newValue);
%
%
% This function will make Matlab choke if the tract has lots of lines. Use
% reduction > 1 for those cases.
% 

if nargin < 2
    width = 0.1;
    reduction = 1;
elseif nargin < 3
    reduction = 1;
end

for thisLine = 1 : reduction : length(tracts)
   myLine = tracts{thisLine,3};
   myLineData = tracts{thisLine,2}; 
   %tubeplot(myLine',0.5) %another option of doing things
   H(thisLine) = clinep(myLine(:,1),myLine(:,2),myLine(:,3),myLineData,width);
   hold on
end
hold off
shading interp

