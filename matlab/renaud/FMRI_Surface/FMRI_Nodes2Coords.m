function CS = FMRI_Nodes2Coords(cs1,cs2,idxs,linedef)

% usage : CS = FMRI_Nodes2Coords(cs1,cs2,[idxs,linedef])
% maps vertex indices from two surfaces to coordinates
% 
% Inputs :
%    cs1,cs2  : 3xN coordinates for N nodes for the two surfaces.
%
% Options :
%    idxs     : Px1 node indices to be used (default: all nodes)
%    linedef  : 1x3 vector [S,MN,MAX] that specifies that S steps are taken
%             along the lines from nodes on C1 to C2. MN and MX are 
%             relative indices, where 0 corresponds to C1 and 1 to C2. The
%             default is [5,0,1].
%             Examples: [1,0.5,0.5] - an intermediate surface in between the 
%                                     two input surfaces C1 and C2.
%                       [10,0,1]    - ten coordinates per node along the
%                                     lines connecting the two surfaces    
%                       [2,0,1]     - the same coordinates as the input 
%                                     surfaces
%
% Output :
%   CS        : 3xSxP array, where CS(:,I,J) are the coordinates for the I-th 
%               step on the line connecting the nodes on C1 and
%               C2 with index IDXS(J).
%
% Renaud Lopes @ CHRU Lille, Mar 2012

% check input size, transpose if necessary
if size(cs1,1) ~= 3, cs1=cs1'; end
if size(cs2,1) ~= 3, cs2=cs2'; end
if ~isequal(size(cs1),size(cs2))
    error('Number of vertices in surfaces do not match, or not 3xQ matrices')
end
   
% select all nodes, if idxs is not given
if nargin<3 || isempty(idxs) || ~(isnumeric(idxs) || islogical(idxs))
    idxs=1:size(cs1,2);
end

% selected nodes
cs1 = cs1(:,idxs);
cs2 = cs2(:,idxs);
ncs = size(cs1,2); % number of nodes

onesurface = isempty(cs2);
if onesurface
    CS = cs1;
    return
end

% definition of lines between two surfaces
defaultlinedef = [5 0 1];
if nargin<4,linedef=defaultlinedef; end
if numel(linedef)>3, error('Unexpected line definition, should be 1x3'); end
linedef=[linedef(:); defaultlinedef((numel(linedef)+1):end)']; % set unset values

steps  = linedef(1);
minpos = linedef(2);
maxpos = linedef(3);

if steps==1
    relpos = (minpos+maxpos)/2; % of only one step, take average of start and end position
else
    relpos = minpos:(maxpos-minpos)/(steps-1):maxpos; % weights for surface 1
end
steps_12 = repmat(relpos, 3,1);
steps_21 = repmat(1-relpos, 3,1); % reverse weights for surface 2, so that steps_12+steps_21==[1,1,....1]

% construct a 4-dimesional matrix so that cs_rep(I,J,K,L) is the coordinate
% of the I-th spatial dimension (1..3 for x..z), J-th step from surf1 to surf2, 
% K-th node, and K-th surface (1 or 2).
cs_rep = zeros(3, steps, ncs, 2); %vertices from both surfaces
for i=1:steps
    cs_rep(:,i,:,1) = cs1; % coordinates surface 1
    cs_rep(:,i,:,2) = cs2; % coordinates surface 2
end

% a weighting matrix, that for every step has the weight of the coordinate
% of surf1 and surf2 (weights add up to 1)
steps_rep          = zeros(3, steps, ncs, 2);
steps_rep(:,:,:,1) = repmat(steps_12,[1,1,ncs]);
steps_rep(:,:,:,2) = repmat(steps_21,[1,1,ncs]);

% multiply coordinates with weights from surface 1 and surface 2, and sum
% them
CS = sum(steps_rep .* cs_rep, 4);
