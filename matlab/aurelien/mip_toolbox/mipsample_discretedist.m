function x = mipsample_discretedist(P, n)

% This function draws samples from a discrete distribution
% whose pdf is given by P for a given sample size n
% P: discerete distribution
% n: number of samples
% x: output samples

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

F = cumsum(P);
for i = 1:n
    U = rand(1,1);
    for k = 1:length(P)
        if U <= F(k)
            x(i) = k;
            break;
        end
    end
end
