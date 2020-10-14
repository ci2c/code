function diffux = mippermalikoned(x,n,k,Lambda) 
% MIPADFONED  1-D Ansitropic diffusion: Perona-Malik Scheme
%
%   DIFFUX = MIPPERMALIKONED(X,N,K,LAMDA)
%
%   X: Original signal, N: number of iterations
%   K: Noise threshold, Lamda: stability constant
%
%   See also MIPPERMALIKTWOD MIPLINONED

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

% zero padding
diffux = padarray(x,[0 1],'symmetric','both');
deltaE = zeros(size(diffux));
deltaW = diffux;
for i  = 1:n
    % Derivatives in East and West directions
    deltaE(2:end-1) = diffux(3:end)   - diffux(2:end-1);
    deltaW(2:end)   = diffux(1:end-1) - diffux(2:end);
    % Diffusivity
    cE = exp(-(deltaE/k).^2);
    cW = exp(-(deltaW/k).^2);
    % Fluxes
    fluxE = cE.*deltaE;
    fluxW = cW.*deltaW;
    % Update the diffusion process
    diffux = diffux + Lambda*(fluxE + fluxW);
end
% Unpadding signal
diffux = diffux(2:end-1);