function Mat = Incidence2Connectivity(Selected)

% Compute connectivity matrices
Mat = Selected' * Selected;
clear Selected;
disp('Mask upper matrix');
Mask = logical(Mat);
Mask = triu(Mask, 1);
Mat = Mask .* Mat;
clear Mask;
disp('Get sqrt');
Mat = sqrt(Mat);
disp('Get indices');
[index_i, index_j, index_k] = find(Mat);
clear Mat;
disp('Correct for areas');
disp('Step 1.');
Ai = A(index_i);
disp('Step 2.');
Ai = Ai + A(index_j);
disp('Step 3.');
index_k = 2 .* index_k ./ Ai;
clear Ai;
disp('Remove NaN areas...');
index_k(~isfinite(index_k)) = 0;
disp('Setting Mat...');
Mat = sparse(index_i, index_j, index_k, n_all, n_all);
clear index_i index_j index_k;

return Mat;