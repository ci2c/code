function new = genparams(old)
%   Function to randomly step sequence parameters for simulated annealing

%   Define sequence info
ns = 40;
etl = 141;
esp = 3;

%   Define timing parameter step size in ms (gaussian SD)
step = 1000;

%   Get parameter matrix size
N = size(old);

%   Save old parameters
new = old;

%   Define required scans
%new(:,1) = [1; 1; 1; 1900; 6000];
%new(:,2) = [1; 0; 1; 1   ; 6000];

% %   Randomly determine which entry to change
%   Modify x if want to force certain scans
% Luis: You could force the first sequence to not change, so that you use
% the realIR in the scanning protocol.
%   2 <= y <= 5
%   1 <= x <= #scans
y = round(1.5+(4-eps)*rand);
% x = round(0.5+(N(2)-eps)*rand);
% Modified by Luis to force to keep the first scan:
x = round(2 + (N(2)-2) .* rand(1));
%x = 3;


%   Apply change
if y == 2 % Change sequence type
    %   Select sequence flexibility
    %new(y,x) = round(-0.5+3*rand);  % Permit double, single and no inv. (value between 0 and 2)
    new(y,x) = round(rand);          % Permit single and no inv. (value between 0 and 1)
    
    %   Also step one of the timing constants
    %   3 <= y2 <= 5
    y2 = round(2.5+(3-eps)*rand);
    new(y2,x) = abs(old(y2,x) + step*randn);
else % Change sequence timings
    new(y,x) = abs(old(y,x) + step*randn);
end

%   Add sequence type checks
%   ensure 0s < tr < 10s and add concatenation requirements
for i = 1:N(2)
    
    %   Check that TR < 10000. 1.5T setting.
    if new(5,i) > 10000;
        new(5,i) = 10000 - abs(round(10*randn));
    end
    %   Prevent large inversion time
    if new(4,i) > 5000
        new(4,i) = 5000;
    end
    if new(3,i) > 5000
        new(3,i) = 5000;
    end
    
    if new(2,i) == 0 % No inv.
        %   No TR fix required
        if new(5,i) < (etl+0.5)*esp + 1
            new(5,i) = (etl+0.5)*esp + 1;
        end
        %   Determine concatenations. Need to fix this.
        new(1,i) = max(2,ceil(2*ns*(etl+0.5)*esp/(new(5,i) + eps)));
    end
    if new(2,i) == 1 % Single inv.
        %   Check TR
        if new(5,i) < new(4,i) + (etl+0.5)*esp + 1
            new(5,i) = new(4,i) + (etl+0.5)*esp + 1;
        end
        %   Determine concatenations (minimum of 2 concatenations) (may be a bug here, should use tr too)
        new(1,i) = max(2,ceil( ns / (new(4,i) / ((etl+0.5)*esp) ) ));
    elseif new(2,i) == 2 % Double inv.
        %   Check TR
        if new(5,i) < new(4,i) + new(3,i) + (etl+0.5)*esp + 1
            new(5,i) = new(4,i) + new(3,i) + (etl+0.5)*esp + 1;
        end
        %   Determine concatenations (minimum of 2 concatenations)
        new(1,i) = max(2,ceil(2*ns*etl*esp/(new(5,i) + eps)));
    end
end

new = round(new);
