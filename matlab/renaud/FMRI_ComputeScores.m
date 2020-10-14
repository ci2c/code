function [R,U,numCompPerRun] = FMRI_ComputeScores(compsName,subjectlist)

% compute representativity and unicity scores

AA            = compsName;
numCompPerRun = zeros(1,length(subjectlist));

for l = 1:length(subjectlist)
    
    I = strmatch(subjectlist{l},AA);
    numCompPerRun(l) = length(I);
    
end

N0 = sum(numCompPerRun==0);
N1 = sum(numCompPerRun==1);
N2 = sum(numCompPerRun>1);

R = (N1+N2)/(N0+N1+N2);
U = N1/(N1+N2);
