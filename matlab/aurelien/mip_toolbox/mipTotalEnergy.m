
% -------------------------------------------------------------------------
% Compute Total energy sum of Gibbs Energy and LogLikelihood
% -------------------------------------------------------------------------
%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

function energyTotal= mipTotalEnergy(gimg,simg,mu,vars,i,j,label,beta)
energyTotal = LogLikelihood(gimg,mu,vars,i,j,label) + ...
              GibbsEnergy(simg,i,j,label,beta);
% -------------------------------------------------------------------------
% Compute LogLikelihood
% -------------------------------------------------------------------------
function LoL = LogLikelihood(img,mu,vars,i,j,label)
% img is the gray level image
LoL = log((2.0*pi*vars(label)^0.5)) + ...
    (img(i,j)-mu(label))^2/(2.0*vars(label));
% -------------------------------------------------------------------------
% Compute Gibbs Energy
% -------------------------------------------------------------------------
function energy = GibbsEnergy(img,i,j,label,beta);
% img is the labeled image
energy = 0;
% North, south, east and west
if (label == img(i-1,j)) energy = energy-beta;
else energy = energy+beta;end
if (label == img(i,j+1)) energy = energy-beta;
else energy = energy+beta;end
if (label == img(i+1,j)) energy = energy-beta;
else energy = energy+beta;end
if (label == img(i,j-1)) energy = energy-beta;
else energy = energy+beta;end
% diagonal elements
if (label == img(i-1,j-1)) energy = energy-beta;
else energy = energy+beta;end
if (label == img(i-1,j+1)) energy = energy-beta;
else energy = energy+beta;end
if (label == img(i+1,j+1)) energy = energy-beta;
else energy = energy+beta;end
if (label == img(i+1,j-1)) energy = energy-beta;
else energy = energy+beta;end