mean_NTC=mean(Y(1:39));
mean_TC=mean(Y(40:end));

Delta=abs(mean_NTC-mean_TC);

eq=[];
sup=[];
inf=[];

for i = 1:100000

    Y2=zeros(length(Y),1);
    R=randperm(length(Y));
    
    for i=1:length(R)
        Y2(R(i))=Y(i);
    end
     
    mean_A=mean(Y2(1:39));
    mean_B=mean(Y2(40:end));
    delt=abs(mean_A-mean_B);
 
    if Delta == delt
        eq=[eq;1];
    elseif delt < Delta 
        inf=[inf;1];
    elseif delt > Delta
        sup=[sup;1];
    end
         
end


disp('Inférieur')
disp(length(inf))

disp('Egal')
disp(length(eq))

disp('Superieur')
disp(length(sup))
