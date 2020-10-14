function H = coloredTract(tract,map,voxSize,reduction,clim)
%
% H = coloredTract(tract,map,voxSize,reduction)
% Display colored tracts according to a diffusion parameter.
% 1. Load the tract using ami2lines.m
% 2. Load the map to use as coloring, can use quanTract to do this
% 3. Make sure you know the voxel dimensions in [x y z]
%
% reduction: skip every n lines, speeds up rendering. To display all the
% lines, use reduction = 1
% Example: H = coloredTract(fornix,FA,[1 1 2],5)
%
% Luis Concha. University of Alberta. May, 2007

if nargin<4
   reduction=1; 
   clim = [min(map(:)) max(map(:))];
end

if nargin<5
   clim = [min(map(:)) max(map(:))];
end


for thisLine = 1 : reduction : length(tract)
   myLine = tract{thisLine,3};
   data = zeros(length(myLine),1);
   for v = 1 : length(myLine)
      vPos = myLine(v,:);
      vPos = floor(vPos ./ voxSize);
      vPos = vPos + 1;
      if vPos(3) < 1 || vPos(1) > size(map,1) || vPos(2) > size(map,2)
          data(v)=0;
      else
       data(v) = map(vPos(1),vPos(2),vPos(3));
      end
   end
   
   myLineData = data; 
   H(thisLine) = cline(myLine(:,1),myLine(:,2),myLine(:,3),myLineData);
   hold on
end

set(gcf,'Renderer','OpenGL')
axis image
set(gca,'Color','k')
set(gca,'XColor','r');
set(gca,'YColor','g')
set(gca,'ZColor','b')
set(gcf,'Color','k');
set(gca,'CLim',clim);
camproj('perspective');
colorbar

hold off

