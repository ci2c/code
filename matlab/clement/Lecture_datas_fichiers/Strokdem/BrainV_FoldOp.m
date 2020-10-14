format ('shortG');
%[a,b,c] = xlsread('/home/fatmike/Protocoles_3T/Strokdem/BrainVisa/NTC_left_Fcoll.xls'); %Fichier xls où j'ai mis l'ID des sujets avec Trouble Mem
valNTC=zeros(size(a),3); 
[A,B,C] = xlsread('/home/clement/Documents/Datas STROKDEM/Non_Trouble_Cog.xls');
valNTC(:,1)=a(:,1); 
for i=1:length(b)
    for j=1:length(B)
    if strcmp(b(i),(B(j)))==1
        valNTC(i,2)=A(j,2);
        valNTC(i,3)=A(j,1);
       j=j+1;
    end
    end
end

valNTC

%clear A B C j i a b c


%%
[c,d,e] = xlsread('/home/fatmike/Protocoles_3T/Strokdem/BrainVisa/TC_left_Fcoll.xls');
valTC=zeros(size(c),3);
[A,B,C] = xlsread('/home/clement/Documents/Datas STROKDEM/Trouble_Cog.xls');
valTC(:,1)=c(:,1);
for i=1:length(d)
    for j=1:length(B)
    if strcmp(d(i),(B(j)))==1
        valTC(i,2)=A(j,2);
        valTC(i,3)=A(j,1);
       j=j+1;
    end
    end
end


clear A B C i j c d e
% %%
% 
% [e,f] = xlsread('/home/fatmike/Protocoles_3T/Strokdem/BrainVisa/BrainVisa_Results/FColl_TCogM6-Dep-left.xls');
% 
% valTC_L=zeros(size(e),3);
% [A,B,C] = xlsread('/home/clement/Documents/Datas STROKDEM/Trouble_Cog');
% valTC_L(:,1)=e;
% for i=1:length(f)
%     for j=1:length(B)
%     if strcmp(f(i),(B(j)))==1
%         valTC_L(i,2)=A(j,2);
%         valTC_L(i,3)=A(j,1);
%        j=j+1;
%     end
%     end
% end
% 
% clear A B C j i
% 
% %%
% 
% 
% [g,h] = xlsread('/home/fatmike/Protocoles_3T/Strokdem/BrainVisa/BrainVisa_Results/FColl_TCogM6-Dep-right.xls');
% valTC_R=zeros(size(g),3);
% [A,B,C] = xlsread('/home/clement/Documents/Datas STROKDEM/Trouble_Cog');
% valTC_R(:,1)=g;
% for i=1:length(h)
%     for j=1:length(B)
%     if strcmp(h(i),(B(j)))==1
%         valTC_R(i,2)=A(j,2);
%         valTC_R(i,3)=A(j,1);
%        j=j+1;
%     end
%     end
% end
% 
% clear A B C i j
