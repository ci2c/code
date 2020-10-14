function diffu = mippermaliktwod(img,n,k,Lambda)
% MIPPERMALIKTWOD  2-D Anisotropic Diffusion
%
%   DIFFUX = MIPPERMALIKTWOD(IMG,N,K,LAMBDA)
%
%   X: Original signal, N: number of iterations
%   Lamda: stability factor
%
%   See also  MIPPERMALIKONED

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

% 2-D Ansitropic diffusion: Perona-Malik Scheme
% x: Original signal, NI: number of iterations
% K: Noise threshold, Lamda: 

% zero padding
diffu = single(padarray(img,[1 1],'symmetric','both'));
deltaE = zeros(size(diffu));
deltaW = diffu;
deltaN = diffu;
deltaS = diffu;
for i = 1:n
    % Derivatives in East, West, North and South directions
    deltaE(2:end-1,:) = diffu(3:end,:)   - diffu(2:end-1,:);
    deltaW(2:end,:)   = diffu(1:end-1,:) - diffu(2:end,:);
    deltaN(:,2:end-1) = diffu(:,3:end)   - diffu(:,2:end-1);
    deltaS(:,2:end)   = diffu(:,1:end-1) - diffu(:,2:end);
    % Compute diffusivity
    cE = exp(-(deltaE/k).^2);
    cW = exp(-(deltaW/k).^2);
    cN = exp(-(deltaN/k).^2);
    cS = exp(-(deltaS/k).^2);
    % Compute fluxes
    fluxE = cE.*deltaE;
    fluxW = cW.*deltaW;
    fluxN = cN.*deltaN;
    fluxS = cS.*deltaS;
    % Update the diffusion process
    diffu = diffu + Lambda*(fluxE + fluxW + fluxN + fluxS);
end
% Unpadding signal
diffu = diffu(2:end-1,2:end-1);