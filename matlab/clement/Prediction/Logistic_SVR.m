function [Acc,Acc_mat] = Logistic_SVR(X,Y);


%% LOOCV

loo=@(i,x) x([[1:i-1] [i+1:size(x,1)]],:); %  this leaves input i out



Acc_mat=[];
for i = 1:length(Y)

    X_k=loo(i,X);
    Y_k=loo(i,Y);  

    X_out = X(i,:);
    Y_out = Y(i,:);


    options =['-s 4 -t 0 -n 0.7 -q']; % option for svm train, see doc
    model = svmtrain(Y_k,X_k,options);
    [pred, accuracy, decision_values] = svmpredict(Y_out,X_out,model,'-q -b 0');

    %SVMModel = fitcsvm(X_k,Y_k,'KernelFunction','polynomial','Solver','L1QP','Standardize',true,'ClassNames',[-1 1],'CacheSize','maximal');
    %[pred,score] = predict(SVMModel,X_out);
    Acc_mat(end+1,:)=[Y_out,pred];

end
plot(Acc_mat(:,1),-Acc_mat(:,2),'o')
[ID,~,~] = intersect(find(Acc_mat(:,1) == 1),find(Acc_mat(:,2) == 1));

Acc = length(ID) / sum(Acc_mat(:,1));
%Acc = (sum(Acc_mat(:,1) == Acc_mat(:,2))/length(Y))*100;
