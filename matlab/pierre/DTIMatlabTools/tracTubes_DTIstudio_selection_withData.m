function H = tracTubes_DTIstudio_selection_withData(tracts,selection,cmap,dataType)

%
% Luis Concha. MNI. June, 2008. Based on a script made at the University
% of Alberta (tracTubes).
%
%   See also tracTubes_DTIstudio_selection.



for lineidx = 1 : length(selection)
   thisLine = selection(lineidx);
   myLine = tracts.fiber(thisLine).xyzFiberCoord +1;    % Get coords and fix the +1 offset.
   eval(['myLineData = tracts.fiber(thisLine).data.' dataType '_pp;'])
   H(thisLine) = cline(myLine(:,1),myLine(:,2),myLine(:,3),myLineData);
   colormap(cmap);
   hold on
   
  
end
colorbar
set(gcf,'Renderer','OpenGL');

% set(H,'EdgeAlpha',0);