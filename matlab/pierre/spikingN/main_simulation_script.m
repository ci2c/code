function [Ms Z] = main_simulation_script(htype,h,p)
%MAIN SIMULATION SCRIPT

%Inputs:        htype,  hierarchical connectivity type; 'pow' or 'exp'
%               h    ,  exponent size (e.g. 8/3 if 'pow', 4/5 if 'exp')
%               p    ,  proportion of intermodule edges (e.g. 0.3)

%Outputs:       MS   ,  module spike matrix
%               Z    ,  avalanche distributions and their properties
%                       (see powerlaw_pval function for details)

rand('twister',sum(100*clock))

if ~exist('zeta_table.mat')
    powerlaw_fit('zeta_table',5000,1.01:0.01:5)
end
powerlaw_fit('zeta_table')

n0= 100;             %size of each module
t = 300e3;          %simulation time (5 minutes)
mem = 5;            %allocated memory for spike raster (holds up to 5Hz spike activity)

tic,
disp('0. Generation of connectivity matrix')
[A ih] = make_fractal2(n0,p*hierarchical_form(7,htype,h),[]);

n = size(A,1);
net = makenet(...
    'S',        ...         %type               |needs to be set to 'S' (sparse)
    A,          ...         %A                  |Adjacency matrix
    ih,         ...         %ih                 |inhibitory neurons; logical index vector
    1,          ...         %delta_t            |integration timestep (ms)
    t,          ...         %T                  |total integration time (ms)
    1,          ...         %bin_size           |bin size (ms)
    1.2,        ...         %Iext               |external current
    ...
    0.1,        ...         %relative SD        |standard deviation of parameters relative to mean
    0.01,       ...         %g                  |leakage conductance
    0,          ...         %E                  |resting potential
    3,          ...         %tau_1              |PSP time constant 1
    1,          ...         %tau_2              |PSP time constant 2
    20,         ...         %V0                 |PSP magnitude constant
    10,         ...         %delays             |maximum delay length
    ...
    2,          ...         %stdp_rule          |STDP rule: 1, additive; 2, multiplicative
    15,         ...         %tau_pos            |STDP time constant positive
    30,         ...         %tau_neg            |STDP time constant negative
    0.75,       ...         %w_pos              |STDP weight constant positive
    0.5,        ...         %w_neg              |STDP weight constant negative
    1           ...         %w_max              |STDP maximum weight bound
    );
net.V=5*rand(1,n);
net.Eta=1;
toc,

disp('1. Transients');
[VS net]=simunets_mex(net,mem,t);

disp('2. Main simulation');
[VS net]=simunets_mex(net,mem,t);
toc,

disp('3. Detection of module spikes')
Ms=false(n/n0,length(VS));
for i=0:n0:n-n0;
    Ns0=VS(nonzeros( (i+(1:n0)).*~net.ih(i+(1:n0)) ), :);
    thr=modulespike_thr(size(Ns0,1),nnz(any(Ns0,1)),full(sum(Ns0,2)),100);
    Ms(round(i/n0+1),sum(Ns0,1)>round(thr))=1;
end
Ms=sparse(Ms);
toc,

disp('4. Assessment of power laws')
Z=avapower(Ms,1,1000);
toc,
