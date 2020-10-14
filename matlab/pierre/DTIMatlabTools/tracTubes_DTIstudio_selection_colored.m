function H = tracTubes_DTIstudio_selection_colored(tracts,selection,data,cmap,interpolate)
% ------------------------------------------------------
%   H = tracTubes_DTIstudio_selection_colored(tracts,selection,data,cmap,interpolate)
% ------------------------------------------------------
% 
% A function to plot the lines imported from DTI studio as .dat files
% 
%   tracts       : The tract structure. To read it into matlab, use f_readFiber.m
%   selection    : A vector of line indices
%   data         : A volume of data, must be in the same space as the
%                  tracts! A correction factor of +1 will be applied to the
%                  tract coordinates within this script.
%
%
%
% Luis Concha. MNI. May, 2008. Based on a script made at the University
% of Alberta (tracTubes).
%
%   See also tracTubes_DTIstudio_selection.



for lineidx = 1 : length(selection)
   thisLine = selection(lineidx);
   myLine = tracts.fiber(thisLine).xyzFiberCoord +1;    % Get coords and fix the +1 offset.

   if interpolate == 0
        floored_myLine = floor(myLine);
        ind = sub2ind(size(data),floored_myLine(:,2),floored_myLine(:,1),floored_myLine(:,3));
        myLineData  = data(ind);
%         myLineData = interp3(data,floored_myLine(:,1),floored_myLine(:,2),floored_myLine(:,3));

   else
        myLineData = interp3(data,myLine(:,1),myLine(:,2),myLine(:,3));
   end
   myLine = myLine -1;
   H(thisLine) = cline(myLine(:,1),myLine(:,2),myLine(:,3),myLineData);
   colormap(cmap);
   hold on
   
  
end

set(gcf,'Renderer','OpenGL');

% set(H,'EdgeAlpha',0);