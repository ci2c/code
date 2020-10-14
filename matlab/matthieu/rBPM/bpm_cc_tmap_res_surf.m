function [Tval1, dof, C1, E] = bpm_cc_tmap_res_surf(D,brain_mask,Tval1,C1,E,Ts)
%----------------------------------------------------------------------
%                         BPM Correlation
%----------------------------------------------------------------------
%                            Goal
%  Computes Correlation Coefficient between two data sets
% --------------------------------------------------------------------

% ------- Computing the index to the vertices contained in mask -------%

indx = find(brain_mask == 1);

A = D{1}; 
A1 = A(:,indx);

B = D{2}; 
B1 = B(:,indx);

% Mean and standard deviations are computed vertex wise

Amean = mean(A1);
Bmean = mean(B1);
stdA = std(A1); 
stdB = std(B1);

% Computation of the sample correlation coefficients

n = size(A1,1);
mean_A_mat= ones(n,1)*Amean;
mean_B_mat= ones(n,1)*Bmean;

A2        = (A1-mean_A_mat);
B2        = (B1-mean_B_mat);
C         = ((sum(A2.*B2))./(stdA.*stdB))/(n-1);

% ------- Computing residuals ---------------------%
BETA1     = (stdA./stdB).*C;
BETA0     = Amean - BETA1.*Bmean;
Residuals = A1 - (B1.*(ones(size(B1,1),1)*BETA1) + ones(size(B1,1),1)*BETA0);

% -------- computation of the t-statistics --------%
dof = n-2;
Tval = sqrt(dof) * C./sqrt(1-C.^2);

% Reshaping back to the original slice matrix format the matrices
% containing the t-statistics, p-values and correlation coeffcients.

Tval1(:,indx) = Tval;
indx_nan = isnan(Tval1);
Tval1(indx_nan) = 0;

C1(:,indx) = C;
indx_nan = isnan(C1);
C1(indx_nan) = 0;

for k = 1:Ts 
    R = zeros(1,size(E,2)); 
    R(:,indx)   = Residuals(k,:); 
    indx_nan    = isnan(R);
    R(indx_nan) = 0;
    E(k,:) = R;
end



