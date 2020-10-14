function FMRI_SurfRoiSelect(fspath,mapsList,tmapList,outdir,outname,thresh_map,thresh_clus)

% usage : V = FMRI_SurfROISelect(fspath, mappath, maplist, [thresh_map,thresh_clus])
%
% Inputs :
%    fspath           : path to freesurfer folder (${SUBJECTS_DIR}/${SUBJ})
%    outdir           : path to maps folder 
%    mapsList         : list of maps (column 1: left hemisphere; column 2:
%                       right hemisphere) (cell)
%    tmapList         : list of t-maps (column 1: left hemisphere; column 2:
%                       right hemisphere) (cell)
%    outname          : list of output names (cell)
%
% Options :
%    thresh_map       : threshold value applied to the map before the
%                       cluster analysis. Default : 2
%    thresh_clus      : threshold value applied to the number of vertices
%                       in one cluster. Default : 0
%
% Output :
%    clus             : structure of clusters
%
% Renaud Lopes @ CHRU Lille, Mar 2012

if nargin ~= 5 && nargin ~= 6 && nargin ~= 7
    error('invalid usage');
end 

default_threshmap = 0.95;
default_threshclu = 0;

% check args
if nargin < 6
    thresh_map = default_threshmap;    
end

if nargin < 7
    thresh_clus = default_threshclu;
end

% Variables
distancemetric = 'geodesic';
radiusk        = 10;
surfname       = 'white';
hemi           = {'lh','rh'};

% Infos surfaces
for j = 1:length(hemi)
    
    fns1    = fullfile(fspath,'surf',[hemi{j} '.pial']);
    fns2    = fullfile(fspath,'surf',[hemi{j} '.white']);
    [c1,f]  = read_surf(fns1);
    [c2,f_] = read_surf(fns2);
    fnum(j) = size(f_,1);

    % Transpose for vertex selection
    c1 = c1';
    c2 = c2';
    f  = f';
    
    % Construct intermediate surface that is the average of the two surfaces
    nverts                = size(c1,2); % number of vertices in a surface
    intermediatecoords{j} = squeeze(FMRI_Nodes2Coords(c1,c2,1:nverts,[1,0.5,0.5]));
    
    % Find the mapping from nodeidxs to the faces that contain the nodes.
    % This increases the speed of SURFING_SUBSURFACE
    ff{j}  = f+1;
    n2f{j} = surfing_nodeidxs2faceidxs(ff{j});
    
end

% Process
noderoi = {};
for k = 1:size(mapsList,1)
    
    disp(mapsList{k,1})
        
    for j = 1:length(hemi)
        
        % Find activation clusters
        clus_file = fullfile(outdir,[hemi{j} '.' outname{k}]);
        [clus,peak,clusid] = FMRI_SurfCluster(fullfile(fspath,'surf',[hemi{j} '.white']),mapsList{k,j},tmapList{k,j},thresh_map,thresh_clus,clus_file);
        
        noderoi{k,j}.name = clus_file;
        
        if(~isempty(clus.clusid) && ~isempty(peak.max) && ~isempty(clusid))
        
            % number of clusters
            N = length(clus.nvert);
                        
            curv = SurfStatReadData(mapsList{k,j});
            [pth,nam,ext] = fileparts(mapsList{k,j});

            for i=1:N
                
                node_max = peak.vertid(i);
                [coordidxs,dist] = surfing_circleROI(intermediatecoords{j},ff{j},node_max,radiusk,distancemetric,n2f{j});

                % Save
                roi_file = fullfile(outdir,[hemi{j} '.' outname{k} '_Roi' num2str(i)]);
                
                % read map file
                [idx,ia,ib]     = intersect(clus.vert{i},coordidxs);
                coordidxs       = coordidxs(ib,1);
                dist            = dist(ib,1);
                [foo,sidxs]     = sort(dist);
                coordidxs       = coordidxs(sidxs,1);
                dist            = dist(sidxs,1);
                mapp            = zeros(size(curv));
                mapp(coordidxs) = 1;
                %SurfStatWriteData(roi_file,mapp);
                write_curv(roi_file,mapp,fnum(j));

                noderoi{k,j}.coordidxs{i} = coordidxs;
                noderoi{k,j}.dist{i}      = dist;
                noderoi{k,j}.node_max(i)  = node_max;
                
            end
            
        end
                
    end

end

save(fullfile(outdir,'ROI_clusters.mat'),'noderoi');

