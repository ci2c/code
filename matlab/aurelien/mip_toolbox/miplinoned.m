function diffux = miplinoned(x,n,Lambda) 
% MIPLINONED  1-D Linear diffusion
%
%   DIFFUX = MIPLINONED(X,N,LAMBDA)
%
%   X: Original signal, N: number of iterations
%   Lamda: stability factor
%
%   See also MIPADFONED

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

% zero padding
diffux = padarray(x,[0 3],'symmetric','both');
deltaE = zeros(size(diffux));
deltaW = diffux;
for i  = 1:n
    % For linear diffusion process
    % Second derivative using Laplacian function
    Ixx = 2*del2(diffux);
    % Update linear diffusion process
    diffux = diffux + Lambda*Ixx;
end
% Unpadding signal
diffux = diffux(4:end-3);