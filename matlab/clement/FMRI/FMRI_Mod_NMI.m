 function [NMI] = FMRI_Mod_NMI(coA,coB)
% Script for NMI (Normalized mutual information) calculation for modularity
% between two graph network. Adapted from A. Alexander-Bloch et al., 2012,
% orginal from Kuncheva and Hadjitodorov, 2004. 
%
% NMI = FMRI_Mod_NMI(CM1,CM2)
%
% Input  : coA/B, community assignment of matrix A and B
%          
%
% Output : NMI, Normalized Mutual Information 
%
% NMI quantify the similarity between the community structure of two graph.
% It ranges from 0 to ~1, where 1 means that the community structures are
% identical. 
%
% Clément Bournonville, Ci2C, CHU Lille 2016
%
 
 
%% CONFIG
Nn      = length(coA);% Number of nodes

%% LOAD matrices and compute CO

%Sujet A
comA=coA;
id=unique(coA);
clear f 
for f = 1:length(id)
    if length(find(id(f) == coA)) == 1
        comA(find(id(f) == coA)) = 841; %841 means "All single node in the same community"
    end
end     
        

%Sujet B


comB=coB;
id=unique(coB);
clear f 
for f = 1:length(id)
    if length(find(id(f) == coB)) == 1
        comB(find(id(f) == coB)) = 841;
    end
end    


clear f id 
IsoNa=find(comA == 841);
IsoNb=find(comB == 841);

x=842;
for f =1:length(IsoNa);
    if length(find(IsoNa(f) == IsoNb)) == 1
        id = IsoNa(f);
        comA(id) = x;
        comB(id) = x;
    x=x+1;
    end
end


%% NMI

S1=0;
for i=1:length(unique(comA))
    modA=unique(comA);
    for j=1:length(unique(comB))
       modB=unique(comB);
       
       na=find(comA == modA(i));
       nb=find(comB == modB(j));
       
       Na=length(na);
       Nb=length(nb);
       
       Nab=0;
       for k=1:length(na)
           ov= na(k) == nb;
           Nab=Nab+sum(ov);
       end
       tmp=Nab*log((Nab*Nn)/(Na*Nb));
       if isnan(tmp)
           tmp=0;
       end
       S1=S1+tmp;

    end
end    

S2=0;
for i=1:length(unique(comA))
    modA=unique(comA);
    na=find(comA == modA(i));
    Na=length(na);
    
    S2=S2+(Na*log(Na/Nn));
end

S3=0;
for i=1:length(unique(comB))
    modB=unique(comB);
    nb=find(comB == modB(i));
    Na=length(nb);
    
    S3=S3+(Nb*log(Nb/Nn));
end

NMI=(-2*S1)/(S2+S3);
