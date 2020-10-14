function [CO,D] = Topo_CoClassification(A,iter_nb,gamma)
% CO = CoClassification ( A, iter_nb, gamma );
%
% This function compute a consensus partition of the network from
% connectivity matrix A. The community structure is computed iter_nb times
% with Louvain algorithm and a final Louvain is applied to generate the
% partition. Adapated from Dwyer et al., 2014. DOI : 10.1523/JNEUROSCI.1634-14.2014
%
% Input :           A         :   N-by-N binary/non-negative weighted connectivity matrix
%                   inter_nb  :   number of times the community structure will be calculated (1000 is advised).
%                   gamma     :   gamma coefficient for Louvain alg.
%
%
%
% Ouput :          CO         :  1-by-N vector final community structure for the matrix.
%                  D          :  N-by-N consensus matrix that contain number of times two nodes are belonging to the same module.
%
%
% Clément Bournonville, Ci2C, CHU Lille 2016
%

%% Community detection

[x,y,~] = size(A);
Com = zeros(x,y,iter_nb);

di=1:x+1:x*x;

for f=1:iter_nb
    
    M  = community_louvain(A,gamma);
    co = unique(M);
    
    tmp = zeros(size(A));
    
    for k = 1:length(co)
        ID = find(M == co(k));
        for i = 1:length(ID)
            tmp( ((ID-1)*x) + ID(i) ) = 1;
        end
        tmp(di) = 0;
        Com(:,:,f) = tmp;
    end
end

%% Final consensus partition

D  = sum(Com,3);
CO = community_louvain(D,gamma);

    