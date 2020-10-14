function [VT n]=simunets_mex(n,memory,T)
% [VT net_final]=simunetS(net); simulation of a network of I&F neurons
%
% Input:     net,        network generated using makenet (see help file there)
%           [memory,     memory to allocate for spike raster (spikes/neuron/sec) (optional)]
%           [T,          total simulation time (optional)]
% Output:    VT,         spike raster matrix;
%       	 net_final,  final network state

%1. Initialize.
if n.N>2^16-1
    error('There are too many nodes: pIn/pOut needs conversion to uint64.')
end
if exist('T','var')
    n.T=T;                                           	%total simulation time
end
if ~exist('memory','var');
    memory=5;                                           %default 2 spikes/neuron/sec
end

%All voltage V calculations are conducted with U, where U = V - E - I/g
VtoU   = -n.E - n.I ./ n.g;                             %U to V conversion
U      = n.V     + VtoU;                                %initial U
Uthr   = n.Vthr  + VtoU;                                %spike threshold
Urest  = n.Vrest + VtoU;                                %rest potential

St = n.St;                                              %latest spike times
D = uint32(round(n.Delay/n.delta_t));                   %delays as a multiple of time-step
max_D = double(max(D));                                	%maximum delay
n.UD(size(n.UD,1)+1:max_D,:) = 0;                      	%delayed voltage input
n.KD(size(n.KD,1)+1:max_D*2,:) = 0;                    	%delayed PSP response

IS = zeros(1,n.N*n.T*memory/1000);                      %declare spike arrays in Matlab
TS = zeros(1,n.N*n.T*memory/1000);                      %declaration avoids mex memory problems

% mex-specific manipulations %
K  = n.K.';
UD = n.UD.';
KD = n.KD.';
Wv = double(n.Wv);
for i=1:n.N; 
    n.In{i}   = n.In{i}  - 1;
    n.Out{i}  = n.Out{i} - 1;
    n.pIn{i}  = uint32(n.pIn{i})  - uint32(1);
    n.pOut{i} = uint32(n.pOut{i}) - uint32(1);
end
% end mex-specific manipulations %

snmex;

% mex-specific manipulations %
n.K  = K.';
n.UD = UD.';
n.KD = KD.';
n.Wv = single(Wv);
for i=1:n.N; 
    n.In{i}   = n.In{i}  + 1;
    n.Out{i}  = n.Out{i} + 1;
    n.pIn{i}  = uint64(n.pIn{i}  + 1);
    n.pOut{i} = uint64(n.pOut{i} + 1);
end
% end mex-specific manipulations %

ns=nnz(IS);
VT=sparse(IS(1:ns),TS(1:ns),true(1,ns),n.N,n.T/n.bin_size,ns);  %generate spike raster array

%output final variable values
t_delay = mod(round(n.T/n.delta_t)-1,max_D)+1;
n.V     = U     - VtoU;                                 %voltage
n.Vthr  = Uthr  - VtoU;                                 %spike threshold
n.Vrest = Urest - VtoU;                                 %rest potential

n.St=St-n.T;                                          	%spike time array
n.UD=circshift(UD.',-mod(t_delay,max_D));             	%delayed voltage input
n.KD=circshift(KD.',-2*mod(t_delay,max_D));            	%delayed PSP input
