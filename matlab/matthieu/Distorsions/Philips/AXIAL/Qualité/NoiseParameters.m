function [SNR,Nr,Nb] = NoiseParameters(ROI,ROIb,ROIfond)
     
NdGmax = double(max(ROI(find(ROI~=0))));
NdGmin = double(min(ROI(find(ROI~=0))));
NdGmean = double(mean(ROI(find(ROI~=0))));
Sigma = std(double(ROI(find(ROI~=0))));

ROIdiff = ROI-ROIb;
if isempty(find(ROIdiff~=0))
    Sigma_diff = 0;
else
    Sigma_diff = std(double(ROIdiff(find(ROIdiff~=0))));
end

Sigma_fond = std(double(ROIfond(find(ROIfond~=0))));

%% Calcul des paramètres de bruit relatifs la région ROI
% SNR = 20*log10((NdGmax-NdGmin)/Sigma);
if (Sigma_diff==0)
    SNR = 0;
else
    SNR = sqrt(2)*NdGmean/Sigma_diff;
end
Nr = Sigma/NdGmean*100;
Nb = Sigma_fond/NdGmean*100;