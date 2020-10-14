function [A ih]=make_fractal2(n0,P,A,ih)
%make_fractal2: Hierarchical modularity connectivity matrix

%Input:         n0:     size of single module
%               P:      within-module connection probability vector
%               []:     this input should be an empty variable

%Output:        A:      adjacency matrix
%               ih:     inhibitory neuron logical index vector

%based on the Maslov/Sneppen algorithm, coded as a mex-file.

%modification history
%May 2009: original
%Jan 2010: added romiok_dir as a mex-file.

m=length(P);                                %number of scales
n=n0*2^m;                                   %number of nodes

if ~exist('ih','var')                       %create new adjacency matrix
    K=A;                                    %get degree vector
    A=false(n,n);
    ih=false(1,n);                          %vector of inhib neurons
    n0i=round(0.2*n0);                      %number of inhib neurons in a module
    
    for i=0:n0:n-n0
        ih(i+(1:n0i))=1;                    %inhib neuron indices
        A(i+(1:n0i),i+(n0i+1:n0))=1;
    end

    if isempty(K);
        for i=0:n0:n-n0
            A(i+(n0i+1:n0),i+(1:n0))=1;   	%fill n0 modules
        end
        A(1:n+1:end)=0;                     %clear diagonal
        
    else
        if isscalar(K);
            K=K(ones(1,n));
        end
        k=sum(K);                        	%number of edges
        for i=find(~ih);                  	%assign excitatory out-edges
            A(i,[1:i-1 i+1:end])=K(i)*K([1:i-1 i+1:end])/(k-K(i))>rand(1,n-1);
        end
    end
end

k=nnz(A);                                	%number of edges
Kr=uint64(P*k./2.^(m-1:-1:0));              %number of edges to randomize (no longer a probability)

%2.^(m-1:-1:0) divides the proportion of outer edges by the number of hierarchical
%modules at that scale. E.g. there are two modules at the second last scale; hence
%the proportion of intermodule connections (P(end-1)*k) should be divided by (2^1)=2

for i=m:-1:1;                           	%from largest to smallest scale
    h=2^i*n0;
    for j=0:h:n-n0
        A(j+(1:h),j+(1:h))=romiok_dir(A(j+(1:h),j+(1:h)),ih(j+(1:h)),Kr(i));    %randomize
    end
end
