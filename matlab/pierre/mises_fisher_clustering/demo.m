% This script creates a toy data set and runs the analysis 

%%  Creating the dataset
%--------------------------------------------------------------------------

D = 3;
K = 3;
S = 4;
V = 150;

randn('seed',5);

% Population-level cluster centers
mus = [1, 0, 0;
       1, 1, 0;
       1, 1, 1];
mus = datanor(mus, 'scul', 2);

% sphere parametrization
musparam(:,1) = acos(mus(:,3));
musparam(:,2) = acos(mus(:,1)./sin(musparam(:,1)));


 

% Subject-level cluster centers
for s=1:S
    % Set the noise level for three clusters differently:
    % Add the noise to the sphere parametrization and transform to the
    spsparam{s} = musparam + 0.1*((1:3)'*ones(1,2)).*randn(K, 2);
    sps{s} = [sin(spsparam{s}(:,1)).*cos(spsparam{s}(:,2)), ...
              sin(spsparam{s}(:,1)).*sin(spsparam{s}(:,2)), ...
              cos(spsparam{s}(:,1))];
    
end

% Creating the data
for s=1:S
    dat{s} = kron(sps{s}, ones(50, 1)) + 0.05*randn(V, D); 
end

%% Running the analysis
%--------------------------------------------------------------------------

[grpRes indRes] = discover(dat, K, 5, 0, D, 1e-6);

[cs matchInds scores matching mus_res sps_res] = performMatching(grpRes, ...
                                                                 indRes, 1);                                            
%% Running the Permutation Test
%--------------------------------------------------------------------------
[scores indperms] = performPermutation(indRes, dat, 25, K, D, 1);
    

%% Visualize cluster centers

figure;
for k = 1:K
    subplot(K,1,k)
    bar(mus(k,:))
end
xlabel('Ground Truth');


[junkvar ord] = sort(cs,'descend');

figure;
for k = 1:K
    subplot(K,1,k)
    bar(grpRes.m(ord(k),:))
end
xlabel('Discovered Systems');