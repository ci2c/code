mean_NTC=mean(Y(1:39));
mean_TC=mean(Y(40:end));

Delta=(meanNTC-meanTC);


for i = 1:10
    Y2=zeros(lengthY,1);
    R=randperm(length(Y));
    
    for i=1:length(R)
        Y2(R(i))=Y(i)
    end
    
    mean_A=mean(Y2(1:39));
    mean_B=mean(Y2(40:end));
    
end


