%% Clustering spectral des sujets avec TC en fonction du réseau PSCI

load('/NAS/tupac/protocoles/Strokdem/Prediction/Data_for_prediction.mat','X','S','coeff','Y','id','nFC');

[a,b,~] = xlsread('/NAS/tupac/protocoles/Strokdem/Prediction/MTL_binary.xls');
TC = find(a(:,5) == 1);

[C,~]=intersect(S,TC);
X=X(C,:);

V = zeros(length(C),length(C));

% for i = 1:length(C)
%     for j = 1:length(C)
%         
%         R = dist(X(i,:),X(j,:));
%         V(i,j) = R(1,2);
%     end
% end

V =dist(X');

di = 1:length(C)+1:length(C).^2;
V(di) = 0;

V(V < 0) = 0;

%% Spectral Clustering 

% Degree matrix
D = zeros(size(V));
D(di) = sum(V,2);

% Laplacian matrix
I = eye(size(V));
D2 = D.^(-1/2);
D2(isinf(D2)) = 0;

L = I - D2*V*D2;
[v,d] = eig(L);
d = diag(d);

K = v(:,2:3);
IDX = kmeans(K,2);

CogClass = zeros(length(a),1);
CogClass(C) = IDX;