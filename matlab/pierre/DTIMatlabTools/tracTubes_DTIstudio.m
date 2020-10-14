function H = tracTubes_DTIstudio(tracts,reduction,colorStyle);
% ------------------------------------------------------
%   H = tracTubes_DTIstudio(tracts,reduction,colorStyle)
% ------------------------------------------------------
% 
% A function to plot the lines imported from DTI studio as .dat files
% 
%   tracts:     The tract structure. To read it into matlab, use f_readFiber.m
%   reduction:  Only plot every "reduction" line. Reduces the complexity and
%               speeds up the visualization.
%   colorStyle: Use 'origin' to color each line according to the xyz
%               coordinate of its first vertex. Anything else will use the random colors
%               assigned by DTIstudio. Default is the random color.
%
%
%
% Luis Concha. MNI. January, 2008. Based on a script made at the University
% of Alberta (tracTubes).
%
%   See also tracTubes.

if nargin < 2
    reduction = 1;
elseif nargin<3
    colorStyle = 'random';
end

for thisLine = 1 : reduction : tracts.nFiberNr
   myLine = tracts.fiber(thisLine).xyzFiberCoord;
   myLineData = sum(tracts.fiber(thisLine).rgbFiberColor); 
   
   if strcmp(colorStyle,'origin')
        theColor(1) = tracts.fiber(thisLine).xyzFiberCoord(1,1)./tracts.nImgWidth;
        theColor(2) = tracts.fiber(thisLine).xyzFiberCoord(1,2)./tracts.nImgHeight;
        theColor(3) = tracts.fiber(thisLine).xyzFiberCoord(1,3)./tracts.nImgSlices;
   else
        theColor = abs(tracts.fiber(thisLine).rgbFiberColor./255);
   end
   if max(theColor) > 1 || min(theColor) < 0
       %disp(['error in line ' num2str(thisLine)]);
       theColor = [0 0 0];
   end
   H(thisLine)=plot3(myLine(:,1),myLine(:,2),myLine(:,3),'Color',theColor);
   hold on
end
hold off
set(gcf,'Renderer','OpenGL');