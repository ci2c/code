function [R,U,numCompPerRun] = FMRI_ComputeScores(compsName,sessname)

% compute representativity and unicity scores

for k = 1:size(compsName,1)
    [s,AA(k,:)]   = strtok(char(compsName(k,:)),'S');
end
numCompPerRun = zeros(1,length(sessname));

for k=1:length(sessname)

    I = strmatch(sessname{k},AA);
    numCompPerRun(k) = length(I);
    
end

N0 = sum(numCompPerRun==0);
N1 = sum(numCompPerRun==1);
N2 = sum(numCompPerRun>1);

R  = (N1+N2)/(N0+N1+N2);
U  = N1/(N1+N2);

clear AA;