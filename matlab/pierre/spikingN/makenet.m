function n=makenet(...
    type, A, ih, delta_t, T, bin_size, I,...
    std, g_mu, E_mu, a_mu, b_mu, V0, d_max,...
    stdp_rule, tau_pos, tau_neg, w_pos, w_neg, w_max...
    )
%Generates a new network (structure) n, with inputs and outputs as described below:
%
%INPUT:     n = makenet(
%               type,               %'W' full, 'S' sparse weights matrix
%               A,                  %connectivity matrix
%               ih,                 %indices of inhibitory neurons
%               delta_t,            %simulation time-step
%               T,                  %total simulation time
%               bin_size,           %spike raster bin size
%               I,                  %injected current
%
%               std,                %standard deviation of all subsequent parameters
%               g_mu,               %mean leakage conductance
%               E_mu,               %mean equilibrium potential
%               alpha_mu,           %mean long decay constant of the PSP
%               beta_mu,            %mean short decay constant of the PSP
%               V0                  %PSP amplitude
%               delay_mu,           %mean delay
%
%               stdp_rule,          %stdp rule: 0, no stdp; 1, additive; 2, multiplicative
%               tau_pos,          	%time-dependency of LTP
%               tau_neg,           	%time-dependency of LTD
%               w_pos,          	%LTP magnitude
%               w_neg,           	%LTD magnitude
%               w_max            	%upper weight bound
%           )
%
%OUTPUT: (PARAMETERS MARKED WITH (*) ARE NOT MODIFIABLE)
%
%Connectivity and weights
% n.N           (*)  	number of neurons
% n.In, n.Out   (*)     indices of in and out neighbors
% n.pIn, n.pOut (*)     pointers to weights of in and out neighbors in n.Wv (type S only)
% n.No          (*)     number of out neighbors
% n.ih          (*)     indices of inhibitory neurons
% n.W / n.Wv        	weights matrix (type W) or weights vector (type S)
%
%Integration parameters
% n.delta_t     (*)     simulation time step
% n.T                   total simulation time
% n.bin_size            spike raster bin size
% n.I                   injected current
% n.g                   leakage conductance
% n.E                   equilibrium potential
% n.c                   time constant [JP's tau]
%
%Voltage parameters
% n.V                   initial voltages
% n.Vthr                spike threshold
% n.Vrest               rest potential
% n.Vspike              spike potential
% n.Trefr               refractory period
%
%STDP parameters
% n.St                  last spike time array
% n.Eta                 STDP rate
% n.stdp_rule           %stdp rule: 0, no stdp; 1, additive; 2, multiplicative
% n.tau_pos             time-dependency of LTP
% n.tau_neg             time-dependency of LTD
% n.w_pos               LTP magnitude
% n.w_neg               LTD magnitude
% n.w_max               upper weight bound
%
%PSP parameters
% n.alpha               PSP slow decay constant [JP's taur]
% n.beta                PSP fast decay constant [JP's tauf]
% n.V0                  PSP amplitude
% n.K                   Initial PSP response
%
%Delay parameters
% n.Delay               Conductance delays
% n.UD                  Delayed voltage input
% n.KD                  Delayed PSP response

N=size(A,1);                                            %number of neurons

if isstruct(delta_t);                                   %input is makenet(type, A_new, ih_new, net_old);
    disp('Modifying connectivity')
    n=delta_t;

    if strcmp(type,'W')
        connectivityW;
    elseif strcmp(type,'S')
        connectivityS
    end

    return
end

if ~exist('d_max','var') && exist('I','var');            %not all parameter values are specified
    disp('Assigning default values to integration/PSP/STDP parameters')
    std=0.1;  g_mu=0.01;  E_mu=-60;  a_mu=3;  b_mu=1;  V0=2; d_max=delta_t;
    stdp_rule=2; tau_pos=15; tau_neg=30; w_pos=15; w_neg=10; w_max=10;
end


if strcmp(type,'W')
    connectivityW;
elseif strcmp(type,'S')
    connectivityS
end

    function connectivityW
        n.No=sum(A,2);                                  %out degree
        n.In=cell(N,1);                                 %in neighbor indices
        n.Out=cell(N,1);                              	%out neighbor indices

        for i=1:N;
            n.In{i} = uint32(find(A(:,i)).');
            n.Out{i}= uint32(find(A(i,:)));
        end

        n.Lind=uint64(find(A));                         %linear indexing
        n.ih=ih;                                     	%indices of inhibitory neurons
    end

    function connectivityS
        n.No=sum(A,2);                                  %out degree
        Ni=sum(A,1);                                    %in degree
        cumNi=cumsum(Ni);                               %cumulative in degree

        n.In=cell(N,1);                                 %in neighbor indices
        n.Out=cell(N,1);                              	%out neighbor indices
        n.pIn=cell(N,1);                             	%pointers to in neighbor weights in Wv
        n.pOut=cell(N,1);                             	%pointers to out neighbor weights in Wv

        for i=1:N;
            n.In{i} = uint32(find(A(:,i)).');
            n.Out{i}= uint32(find(A(i,:)));
            n.pIn{i} = uint64(cumNi(i)-Ni(i)+(1:Ni(i)));
            n.pOut{i}= uint64(cumNi(n.Out{i})-full(sum(A((i+1):N,n.Out{i}),1)));
        end
        n.ih=ih;                                     	%indices of inhibitory neurons
    end

%basic parameters
n.N=N;                                                  %number of neurons
n.delta_t=delta_t;                                    	%simulation timestep (ms)
n.T=T;                                                  %total simulation time (ms)
n.bin_size=bin_size;                                    %spike raster bin size
n.I=I;                                                  %injected current

%integration parameters
n.g=g_mu.*(1+randn(1,N).*std);                          %leakage conductance
n.E=E_mu.*(1+randn(1,N).*std);                       	%equilibrium potential
n.c=0.01;                                               %time constant [JP's tau]

%voltage parameters
n.V=8.*(1+randn(1,N).*(std+1/10));                      %initial voltages
n.Vthr=18;                                              %spike threshold
n.Vspike=100;                                           %spike potential
n.Trefr=3;                                              %refractory period
n.Vrest=0;                                              %rest potential

%PSP parameters
n.alpha=a_mu.*(1+randn(1,N).*std);                  	%PSP slow decay [JP's taur]
n.beta =b_mu.*(1+randn(1,N).*std);                      %PSP fast decay [JP's tauf]
n.K=zeros(2,N);                                         %Initial PSP
n.V0=V0;                                               	%PSP amplitude

%delays
n.Delay=ceil(d_max.*rand(1,N)/delta_t)*delta_t;      	%delays (uniform distribution)
max_D=max(round(n.Delay/delta_t));                      %maximum delay (auxiliary)
n.UD=zeros(max_D,N);                                    %delayed voltage input
n.KD=zeros(2*max_D,N);                                  %delayed PSP response

%STDP parameters and weights matrix
n.Eta=0.5;                                              %STDP rate
n.stdp_rule=stdp_rule;                               	%additive (1) or multiplicative (2) rule
n.tau_pos=tau_pos;                                     	%time-dependency of LTP
n.tau_neg=tau_neg;                                    	%time-dependency of LTD
n.w_pos=w_pos;                                      	%LTP magnitude
n.w_neg=w_neg;                                        	%LTD magnitude
n.w_max=w_max;                                       	%upper weight bound
n.St=-1e10*ones(1,N);                                	%last spike time array
if strcmp(type,'W')
    n.W=zeros(N,N,'single');                            %weights matrix
elseif strcmp(type,'S')
    n.Wv=zeros(1,nnz(A),'single');                      %weights vector
end


%fix invalid parameters
while any(n.g<=0)
    disp('At least one n.g <= 0')
    n.g(n.g<=0)=mean(n.g);
end

while any(n.V>n.Vthr)
    disp('At least one initial V > n.Vthr');
    n.V(n.V>n.Vthr)=mean(n.V);
end

while any(n.Vthr<n.Vrest)
    disp('At least one n.Vrest > n.Vthr')
    n.Vthr(n.Vthr<n.Vrest)=mean(n.Vthr);
end

% while any(n.I./n.g+n.E<n.Vthr)
%     disp('At least one neuron cannot spike (n.I ./ n.g + n.E < n.Vthr)');
%     n.g(n.I./n.g+n.E<n.Vthr)=mean(n.g);
%     if any(n.I./n.g+n.E<n.Vthr), disp('... further fix required')
%         n.E(n.I./n.g+n.E<n.Vthr)=mean(n.E);
%     end
%     if any(n.I./n.g+n.E<n.Vthr), disp('... further fix required')
%         n.Vthr(n.I./n.g+n.E<n.Vthr)=mean(n.Vthr);
%     end
% end

while any(n.alpha<=0)
    disp('At least one n.alpha <= 0')
    n.alpha(n.alpha<=0)=mean(n.alpha);
end

while any(n.beta<=0)
    disp('At least one n.beta <= 0')
    n.beta(n.beta<=0)=mean(n.beta);
end

while any(n.alpha<n.beta)
    disp('At least one PSP response is inverted (n.alpha < n.beta)')
    n.alpha(n.alpha<n.beta)=mean(n.alpha);
    if any(n.alpha<n.beta), disp('... further fix required');
        n.beta(n.alpha<n.beta)=mean(n.beta);
    end
end

while any(n.Delay<n.delta_t)
    disp('At least one n.Delay < delta_t')
    n.Delay(n.Delay<delta_t)=mean(n.Delay);
end

while rem(n.T,n.bin_size);
    disp('n.bin_size is not a factor of n.T');
    f=factor(n.T);
    n.bin_size=f(find(abs(f-n.bin_size)==min(abs(f-n.bin_size)),1));
end

end
