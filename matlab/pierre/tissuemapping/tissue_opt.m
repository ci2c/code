function cost = tissue_opt(S)

%   4.7 T Parameters
% T1a = 4618; % CSF
% T1b = 2000; % GM
% T1c = 1226; % WM
% Moa = 1;    % CSF
% Mob = 0.92; % GM
% Moc = 0.79; % WM

% %   1.5 T Parameters
% T1a = 3500; % CSF
% T1b = 1000; % GM
% T1c = 700;  % WM
% Moa = 1;    % CSF
% Mob = 0.92; % GM
% Moc = 0.79; % WM


%   3.0 T Parameters
T1a = 3700; % CSF
T1b = 1820; % GM
T1c = 1084;  % WM
Moa = 1;    % CSF
Mob = 0.92; % GM
Moc = 0.79; % WM
Params.FieldStrength = '3T';
Params.T1.CSF = T1a;
Params.T1.GM  = T1b;
Params.T1.WM  = T1c;
Params.PD.CSF = Moa;
Params.PD.GM  = Mob;
Params.PD.WM  = Moc;


%   Define some sequence info
etl = 141;
esp = 3;
Params.EchoTrainLength = etl;
Params.EchoSpacing     = esp;

%   Ensure proper input size
N = size(S);
if N(1) ~= 5 || N(2) < 2
    error('tissue_opt: Bad input');
end

%   Create critical cost penalties
%   Ensure the first three sequences are different to prevent singular matrix inversion.
% if isequal(S(:,1),S(:,2)) %|| isequal(S(:,1),S(:,3)) || isequal(S(:,2),S(:,3))
%     cost = Inf;
%     return;
% end

%   Create b matrix (N(2) sequences x 3 tissues) representing tissue signal
b = zeros(N(2),3);
for i = 1:N(2)
    if S(2,i) == 0
        %    No IR sequence
        b(i,1) = Moa.*(1 - exp(-(S(5,i)-etl*esp)./T1a));
        b(i,2) = Mob.*(1 - exp(-(S(5,i)-etl*esp)./T1b));
        b(i,3) = Moc.*(1 - exp(-(S(5,i)-etl*esp)./T1c));
    elseif S(2,i) == 1
        %    Single IR Sequence
        b(i,1) = Moa.*(1 - 2*exp(-S(4,i)./T1a) + exp(-(S(5,i)-etl*esp)./T1a));
        b(i,2) = Mob.*(1 - 2*exp(-S(4,i)./T1b) + exp(-(S(5,i)-etl*esp)./T1b));
        b(i,3) = Moc.*(1 - 2*exp(-S(4,i)./T1c) + exp(-(S(5,i)-etl*esp)./T1c));
    else
        %   Doube IR sequence
        b(i,1) = Moa.*(1 - 2*exp(-S(4,i)./T1a) + 2*exp(-(S(3,i)+S(4,i))/T1a) - exp(-(S(5,i)-etl*esp)./T1a));
        b(i,2) = Mob.*(1 - 2*exp(-S(4,i)./T1b) + 2*exp(-(S(3,i)+S(4,i))/T1b) - exp(-(S(5,i)-etl*esp)./T1b));
        b(i,3) = Moc.*(1 - 2*exp(-S(4,i)./T1c) + 2*exp(-(S(3,i)+S(4,i))/T1c) - exp(-(S(5,i)-etl*esp)./T1c));
    end
end

%   Add air segmentation, if enough scans
%   Add normalization condition
% if N(2) > 2
%     b(:,4) = zeros(N(2),1);
%     b(N(2)+1,:) = ones(1,4);
% else
%     b(N(2)+1,:) = ones(1,3);
% end

%   Create critical cost penalties
%   Ensure the first three sequences are different to prevent singular matrix inversion.
if isequal(b(1,:),b(2,:)) || isequal(b(1,:),b(3,:)) || isequal(b(2,:),b(3,:))
    cost = Inf;
    return;
end

%   Compute inverse
A = b\eye(N(2));

%   Square A for noise additive terms
A = sqrt(sum(A.^2,2));

%   Apply weighting function and compute raw noise cost
%w = [1;10;2]; %  [CSF,GM,WM]
w = [1;1;1]; %  [CSF,GM,WM]
% if N(2) > 2
%     w = [1;1;1;1];
% end
w = w ./ sum(w);
A = A .* w;
cost = sum(A);

%   Compute net repetition times using the first row representing # of concatenations
time = sum(S(1,:).*S(5,:));

%   Uncomment to optimize per unit time
%cost = sqrt(time) * cost;

%   Add minor penalty costs
%   Augment cost function if parameters are outside desired range
max_time = 10000*1000;  %   Max total TR time
penalty = 10;

%   Total repetition times
if time > max_time
    cost = penalty * cost + cost*(time-max_time).^2;
end

%   Prevent unused inversion times from diverging
tau1 = sum(S(4,:));
tau2 = sum(S(3,:));
if tau1 > 1.25*time
    cost = penalty * cost + cost*(tau1-1.25*time).^2;
end
if tau2 > 1.25*time
    cost = penalty * cost + cost*(tau2-1.25*time).^2;
end

%   Repetition time
% tau = S(4,:) < 10000;
% if sum(tau)>0
%     cost = penalty * cost + cost*sum((tau.*S(4,:)-10000.*tau).^2);
% end

assignin('base','Params',Params);
