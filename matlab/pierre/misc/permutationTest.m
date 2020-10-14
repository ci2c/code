function test_stat = permutationTest(Mat, DM, contrast, testType, nRun, permType)
%
% test_stat = permutationTest(MAT, DM, contrast, [testType, nRun, permType])
%
% INPUTS :
%       MAT        : N x M connectivity vectors (N subjects, M dependant variables)
%       DM         : N x P design matrix (N subjects, P independant
%                                         variables)
%       contrast   : 1 x P contrast
%
% OPTIONS :
%       testType   : Type of test: {'onesample','ttest','ftest'}
%                      Default : 'ttest'
%       nRUN       : Number of runs. Default : 10 000
%       permType   : 0 for permutation sampling ; 1 for bootstrap. 
%                      Default : 0
%
% OUTPUT :
%       test_stat  : t stats
%
% Pierre Besson @ CHRU Lille, July 2013
% inspired from Zalesky's NBSglm


% check args
if nargin < 3
    error('not enough arguments');
end

if nargin > 6
    error('too many arguments');
end

if nargin < 6
    permType = 0;
end

if nargin < 4
    testType = 'ttest';
else
    if sum(strcmp({'onesample', 'ttest', 'ftest'}, testType)) == 0
        error('invalid test type');
    end
end

if nargin < 5
    nRun = 10000;
end

if size(Mat, 1) ~= size(DM, 1)
    error('Mat and DM should have the same number of rows');
end

if size(contrast, 1) ~= 1
    error('contrast should have one row');
end

if size(DM, 2) ~= size(contrast, 2)
    error('DM and contrast should have the same number of columns');
end


p = length(contrast);
M = size(Mat, 2);
n = size(Mat, 1);

ind_nuisance = find(~contrast);

if isempty(ind_nuisance)
    % No nuisance predictors
    
else
    % regress out nuisance predictors and compute residual
    DM_nuisance = DM(:, ind_nuisance);
    b = zeros(length(ind_nuisance), M);
    resid_y = zeros(n, M);
    % regress leaving-out zeros
    % b = DM_nuisance\Mat;
    b = pinv(DM_nuisance)*Mat;
    zero_ind = sum(Mat==0);
    zero_ind = find(zero_ind ~= 0);
    Mat_zero = Mat(:, zero_ind);
    for ii = 1 : size(Mat_zero, 2)
        Temp_mat = Mat_zero(:, ii);
        Temp_DM  = DM_nuisance;
        Temp_DM(Temp_mat==0, :) = [];
        Temp_mat(Temp_mat==0) = [];
        % b_temp = Temp_DM \ Temp_mat;
        b_temp = pinv(Temp_DM) * Temp_mat;
        b(:, zero_ind(ii)) = b_temp;
    end
    resid_y = Mat - DM_nuisance * b;
    resid_y(Mat == 0) = 0;
end


h = waitbar(0, 'Please wait...');
test_stat = zeros(nRun + 1, M);
for ii = 1 : nRun + 1
    y_perm = zeros(n, M);
    if ii == 1
        % Don't permute the first run
        y_perm = Mat;
    else
        if permType == 0
            randchoice = randperm(n)';
        else
            randchoice = randi(n, n, 1);
        end
        if isempty(ind_nuisance)
            if permType == 0
                randchoice = randperm(n)';
            else
                randchoice = randi(n, n, 1);
            end
            y_perm = Mat(randchoice, :);
        else
            resid_y = resid_y(randchoice, :);
        end
    end
    
    if ~isempty(ind_nuisance)
        y_perm = resid_y + DM_nuisance * b;
        y_perm(resid_y == 0) = 0;
    end
    
    b_perm = zeros(p, M);
    % b_perm = DM\y_perm;
    b_perm = pinv(DM) * y_perm;
    % leave-out zeros
    zero_ind = sum(y_perm==0);
    zero_ind = find(zero_ind ~= 0);
    y_perm_zero = y_perm(:, zero_ind);
    for jj = 1 : size(y_perm_zero, 2)
        Temp_y = y_perm_zero(:, jj);
        Temp_DM  = DM;
        Temp_DM(Temp_y==0, :) = [];
        Temp_y(Temp_y==0) = [];
        % b_temp = Temp_DM \ Temp_y;
        b_temp = pinv(Temp_DM) * Temp_y;
        b_perm(:, zero_ind(jj)) = b_temp;
    end
    
    % Compute statistics of interest
    if strcmp(testType, 'onesample')
        if ii == 1
            % test_stat(i,:) = mean(y_perm);
            test_stat(ii, :) = sum(y_perm(y_perm~=0)) ./ sum(y_perm~=0);
        else
            temp = y_perm .* randi([0 1], n, M);
            test_stat(ii, :) = sum(temp(y_perm~=0)) ./ sum(y_perm~=0);
            % test_stat(i,:) = mean(y_perm.*randi([0 1], n, M));
        end
    elseif strcmp(testType, 'ttest')
        resid = zeros(n, M);
        mse = zeros(n, M);
        resid = y_perm - DM * b_perm;
        resid(y_perm==0) = 0;
        mse = sum(resid.^2) ./ (n-p-sum(y_perm==0));
        % se = sqrt(mse*(contrast*inv(DM'*DM)*contrast'));
        se = sqrt(mse*(contrast*pinv(DM'*DM)*contrast'));
        test_stat(ii, :) = (contrast * b_perm) ./ se;
    elseif strcmp(testType, 'ftest')
        disp('not yet implemented');
        return
    else
        disp('not yet implemented');
        return
    end
    waitbar(ii/(nRun+1), h);
end

test_stat(isnan(test_stat)) = 0;
    

% InitDiff = nz_mean(Mat1) - nz_mean(Mat2);
% 
% C = zeros(size(InitDiff));
% 
% nG1 = size(Mat1, 2);
% nG2 = size(Mat2, 2);
% Mat = [Mat1, Mat2];
% 
% for i = 1 : nRun
%     if permType == 0
%         T = randperm(nG1 + nG2);
%     else
%         T = randi(nG1 + nG2, nG1 + nG2, 1);
%     end
%     G1 = Mat(:, T(1 : nG1));
%     G2 = Mat(:, T(nG1+1 : end));
%     
%     C = C + ( (nz_mean(G1) - nz_mean(G2)) > InitDiff );
% end