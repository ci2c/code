function [R,U,numCompPerRun] = NRJ_ComputeScores(compsName,nsess)

% compute representativity and unicity scores

AA            = compsName;
numCompPerRun = zeros(1,nsess);

for l = 1:nsess
    
    if l<10
        pathRunDir = ['sess0' num2str(l)];
    else
        pathRunDir = ['sess' num2str(l)];
    end
    I = strmatch(pathRunDir,AA);
    numCompPerRun(l) = length(I);
    
end

N0 = sum(numCompPerRun==0);
N1 = sum(numCompPerRun==1);
N2 = sum(numCompPerRun>1);

R = (N1+N2)/(N0+N1+N2);
U = N1/(N1+N2);
