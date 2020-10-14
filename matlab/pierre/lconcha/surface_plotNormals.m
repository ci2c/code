function h = surface_plotNormals(surf,scaleNormal,nNormals,type)
%
% function h = surface_plotNormals(surf,scaleNormal,nNormals,type)
%
% Plot the vertex normals of a surface loaded with SurfStatReadDotObj1.m
%
% surf       : The surface, of course. This is the only mandatory argument.
% scaleNormal: the length of the normal to be shown. Default = 1.
% nNormals   : If the surface has too many triangles, the visualization can
%              choke. This is an integer of the number of normals, randomly
%              selected, to be displayed. Default is 5000.
% type       : String. Select whether to plot "vertex" or "face" normals. Default
%              is vertex.
%
% Luis Concha. BIC. April 2008.

if nargin < 4, type     = 'vertex'; end
if nargin < 3, nNormals = 5000; end
if nargin < 2, scaleNormal = 1; end

if nNormals > length(surf.coord)  & strmatch(type,'vertex')
   nNormals = length(surf.coord);
elseif nNormals > length(surf.tri) && ~strmatch(type,'vertex')
    nNormals = length(surf.tri);
end
    

if strmatch(type,'vertex')
    a = surf.coord;
    n = surf.normal;
    b = a + (n.*scaleNormal);
    index = round(linspace(1,length(a),nNormals));
    x = [a(1,index)' b(1,index)'];
    y = [a(2,index)' b(2,index)'];
    z = [a(3,index)' b(3,index)'];
    h.normals = plot3(x',y',z','Color','r');
else
    if ~isfield(surf,'triNormals')
        disp('Generating surface triangle normals');
        surf.triNormals = computeMeshTriangleNormals(surf);
    end
    if ~isfield(surf,'centroids')
        disp('Generating triangle centroids');
        surf.centroids = computeMeshTriangleCentroids(surf);
    end

    a = surf.centroids;
    n = surf.triNormals;
    b = a + (n.*scaleNormal);
    index = round(linspace(1,length(a),nNormals));
    x = [a(1,index)' b(1,index)'];
    y = [a(2,index)' b(2,index)'];
    z = [a(3,index)' b(3,index)'];
    h.normals = plot3(x',y',z','Color','r');
    
    hold on
    h.centroids = plot3(a(1,index),a(2,index),a(3,index),' .r');
    set(h.centroids,'MarkerSize',10);
    hold off
end

axis image
axis vis3d