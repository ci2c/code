function M = getConnectMatrix(fpath, cases, Age, Gender)
% Usage : M = getConnectMatrix(fpath, cases, [Age, Gender])
%
% Returns the connectivity matrix of the Brodmann's areas mean cortical
% thickness.
%
% fpath   : path to the cases direcroty (equivalent to ${SUBJECTS_DIR})
% cases   : array of strings containing IDs of the cases to process. For
%     example : cases = {'patient1', 'patient023', 'NameP03'};
% Age     : Array of age, i.e. Age = [AgePatient1, AgePatient023, AgeNameP03]
% Gender  : Array of gender, i.e Gender = [-1, 1, 1, -1, 1]

if nargin ~= 2 & nargin ~=3 & nargin~=4
    error('Invalid usage')
end

if nargin == 3 & length(cases) ~= length(Age)
    error('cases & Age must have same length');
end

OverAllMean = [];

DATA_left = [];
DATA_right = [];
for k = 1 : length(cases)
    %fprintf('********************************\n');
    fprintf('Processing : %s\n', char(cases{k}));
    [Vmean, Vvert, L, Mean] = getFeatVec(strcat(fpath, '/', char(cases{k})), 'thickness');
    OverAllMean = [OverAllMean; Mean];
    DATA_left = [DATA_left, Vmean(:, 1)];
    DATA_right = [DATA_right, Vmean(:, 2)];
end

% Remove 'unknown' labels
DATA_left(1,:)=[];
DATA_right(1,:)=[];

if nargin > 2
    %% Step 1. Remove overall mean
    for k = 1 : size(DATA_left, 2)
        DATA_left(:, k) = DATA_left(:, k) - ones(size(DATA_left, 1), 1) .* OverAllMean(k, 1);
        DATA_right(:, k) = DATA_right(:, k) - ones(size(DATA_right, 1), 1) .* OverAllMean(k, 2);
    end
    
    % Step 2. Correct for Age
%     for k = 1 : size(DATA_left, 1)
%         [slope, offset] = linfit(DATA_left(k, :), Age);
%         DATA_left(k, :) = DATA_left(k, :) - (slope .* Age + offset);
%         [slope, offset] = linfit(DATA_right(k, :), Age);
%         DATA_right(k, :) = DATA_right(k, :) - (slope .* Age + offset);
%     end
    
    % Removes age, gender and age-gender effect
    X = [ones(length(cases), 1), Age' ./ max(Age'), Gender, (Gender .* Age') ./ max(Age') ];
    for k = 1 : size(DATA_left, 1)
        % Left
        A = X\(DATA_left(k, :)');
        DATA_left(k,:) = (DATA_left(k,:)' - (X(:,1).*A(1) + X(:,2).*A(2) + X(:,3).*A(3) + X(:,4).*A(4)))';
        % Right
        A = X\(DATA_right(k, :)');
        DATA_right(k,:) = (DATA_right(k,:)' - (X(:,1).*A(1) + X(:,2).*A(2) + X(:,3).*A(3) + X(:,4).*A(4)))';
    end
end

DATA = [DATA_left; DATA_right];
M = abs(corrcoef(DATA'));
%M = corrcoef(DATA');
M = M - eye(size(M));
