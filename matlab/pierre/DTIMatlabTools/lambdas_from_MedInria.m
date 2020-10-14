function [tensor,lambdas] =  lambdas_from_MedInria(filename)
% function [tensor,lambdas] =  lambdas_from_MedInria(filename)
% 
% Returns lambdas, a 4D matrix of size [m n p 3] with the three eigenvalues
% in the fourth dimension.
%
% You can run [adc,fa,perp] = calcFA(lambdas); to get the second order
% DTI parameters.
%
% Luis Concha. August, 2008.
% BIC, MNI.

fprintf(1,'Loading %s...',filename);
[tensor, hdr]=loadinr(filename);
fprintf(1,' Done.\n');


fprintf(1,'Calculating eigenvalues...');
tensor_r = reshape(tensor,size(tensor,1)*size(tensor,2)*size(tensor,3),6);
notZeros = all(tensor_r,2);
index    = find(notZeros);
lambdas = zeros(size(tensor,1)*size(tensor,2)*size(tensor,3),3);
for i = 1 : length(index)
    thisPos = index(i);
    ten     = tensor_r(thisPos,:);
    xx  = ten(1);
    xy  = ten(2); 
    yy  = ten(3);
    xz  = ten(4);
    yz  = ten(5);
    zz  = ten(6);

    fullten = [xx xy xz;...
               xy yy yz;...
               xz xy zz];

    [v,d] = eig(fullten);
    evalues = sort(diag(abs(d)),'descend');
    e1 = evalues(1);
    e2 = evalues(2);
    e3 = evalues(3);
    lambdas(thisPos,:) = [e1 e2 e3];

end
lambdas = reshape(lambdas,size(tensor,1),size(tensor,2),size(tensor,3),3);
fprintf(1,' Done.\n');




% THIS IS A SLOWER VERSION USING A FOR LOOP


% fullten = zeros(3,3);
% lambdas = zeros(size(tensor,1),size(tensor,2),size(tensor,3),3);
% for i = 1 : size(tensor,1)
%     for j = 1 : size(tensor,2)
%         for k = 1 : size(tensor,3)
%             if squeeze(tensor(i,j,k,:)) == [0 0 0 0 0 0]',continue,end;
%             ten = squeeze(tensor(i,j,k,:));
%             xx  = ten(1);
%             xy  = ten(2); 
%             yy  = ten(3);
%             xz  = ten(4);
%             yz  = ten(5);
%             zz  = ten(6);
%             
%             fullten = [xx xy xz;...
%                        xy yy yz;...
%                        xz xy zz];
%             
%             [v,d] = eig(fullten);
%             evalues = sort(diag(abs(d)),'descend');
%             e1 = evalues(1);
%             e2 = evalues(2);
%             e3 = evalues(3);
%             lambdas(i,j,k,:) = [e1 e2 e3];
%         end
%     end
% end

% [adc,fa,perp] = calcFA(lambdas);