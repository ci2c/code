function [FWPM,FWPMP,calcPeak,centerPos] = mipresolutionlineProfile(lprof,prcnt)

% MIPRESOLUTIONLINEPROFILE Performance parameters of Gamma Cameras and
% SPECT systems
%
%   [FWPM,FWPMP,PEAK,CENPOS] = MIPRESOLUTIONLINEPROFILE(LPROF,PRCNT)
%   
%   This function computes the resolution from a line source profile
%
%   See also 

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

[my,mp] = max(lprof);
x = mp-1:mp+1;
y = lprof(mp-1:mp+1);
p = polyfit(x,y,2); 
peakpos   = -(p(2)/(p(1)*2));
calcPeak  = p(1)*peakpos^2+p(2)*peakpos+p(3);
fwpmValue = calcPeak*prcnt;
bw        = lprof > fwpmValue;
[L,numR]  = bwlabel(bw);
Label     = L(mp);
ppf       = find(L == Label,1,'first');
pps       = find(L == Label,1,'last');
FWPMP(1)  = ppf - (lprof(ppf) - fwpmValue )/(lprof(ppf)-lprof(ppf-1));
FWPMP(2)  = pps + (lprof(pps) - fwpmValue )/(lprof(pps)-lprof(pps+1));
FWPM      = FWPMP(2) - FWPMP(1);
centerPos = FWPMP(1) + (FWPMP(2) - FWPMP(1))/2;
figure;hold on;plot(lprof);
errorbar([FWPMP(1) FWPMP(2)],[prcnt*calcPeak prcnt*calcPeak],...
    0.03,'color','r','LineWidth',1.5)
line([FWPMP(1) FWPMP(2)],[prcnt*calcPeak prcnt*calcPeak],...
    'LineWidth',1.5,'Color','r');grid on;