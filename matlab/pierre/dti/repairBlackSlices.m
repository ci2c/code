function repairBlackSlices(dti_path, thre)
% usage : repairBlackSlices(DTI_PATH, THRESHOLD)
%
% INPUT :
% -------
%    DTI_PATH        : Path to DTI directory containing :
%               DTI images   : dti?.nii.gz
%               Mask images  : mask?.nii.gz
%
%    THRESHOLD       : z-score threshold for abnormalities (default : 9)
%
% Pierre Besson @ CHRU Lille, Feb. 2011

if nargin ~= 1 && nargin ~= 2
    error('Invalid usage');
end

if nargin == 1
    thre = 9;
end

DTIs = SurfStatListDir(strcat(dti_path, 'dti*nii.gz'));
Masks = SurfStatListDir(strcat(dti_path, 'mask*nii.gz'));

if length(Masks) ~= length(DTIs) && length(Masks) ~= 1
    error('Mismatch between number of masks and number of dti images');
end

if length(Masks) == 1 && length(DTIs) > 1
    disp('One mask found : same mask applied to all dti images');
end

for i = 1 : length(DTIs)
    if length(Masks) > 1
        BS{i} = findBlackSlices(char(DTIs(i)), char(Masks(i)));
    else
        BS{i} = findBlackSlices(char(DTIs(i)), char(Masks(1)));
    end
end


% if only one dti found, just remove the abnormal volume(s)...
if length(DTIs) == 1
    if sum(abs(BS{1}(:)) > thre) == 0
        Report_file = strcat(dti_path, '/dti1.report');
        fid = fopen(Report_file, 'w');
        fprintf(fid, 'No abnormal slice (threshold = %f)\n', thre);
        fprintf(fid, 'Z-score range :\n');
        [slice_min, vol_min] = find(BS{1} == min(BS{1}(:)));
        fprintf(fid, 'Min : %f (volume %d , slice %d)\n', min(BS{1}(:)), vol_min, slice_min-1);
        [slice_max, vol_max] = find(BS{1} == max(BS{1}(:)));
        fprintf(fid, 'Max : %f (volume %d , slice %d)\n', max(BS{1}(:)), vol_max, slice_max-1);
        fclose(fid);
        [s, m] = unix(['cp ', dti_path, '/dti1.nii.gz ', dti_path, '/dti_nobs.nii.gz']);
        [s, m] = unix(['cp ', dti_path, '/dti1.bval ', dti_path, '/dti_nobs.bval']);
        [s, m] = unix(['cp ', dti_path, '/dti1.bvec ', dti_path, '/dti_nobs.bvec']);
        return;
    else
        Report_file = strcat(dti_path, '/dti1.report');
        fid = fopen(Report_file, 'w');
        fprintf(fid, 'Abnormal slice found in this volume (threshold = %f)\n', thre);
        [slice, vol] = find(abs(BS{1}) > thre);
        fprintf(fid, 'volume %d, slice %d, z-score = %f\n', vol, slice-1, BS{1}(slice, vol));
        fclose(fid);
        [s, m] = unix(['fslsplit ', strcat(dti_path, '/dti1.nii.gz'), ' ', strcat(dti_path, '/temp'), ' -t']);
        Unique_vol = unique(vol);
        for j = 1 : length(Unique_vol)
            if Unique_vol(j) < 10
                Temp = strcat(dti_path, '/temp000', num2str(Unique_vol(j)), '.nii.gz');
                [s, m] = unix(['rm -f ', Temp]);
            else
                Temp = strcat(dti_path, '/temp00', num2str(Unique_vol(j)), '.nii.gz');
                [s, m] = unix(['rm -f ', Temp]);
            end
        end
        [s, m] = unix(['fslmerge -t ', strcat(dti_path, '/dti_nobs'), ' ', strcat(dti_path, '/temp*')]);
        [s, m] = unix(['rm -f ', strcat(dti_path, '/temp*')]);
        Bvec = textread(strcat(dti_path, '/dti1.bvec'));
        Bvec(:, end) = [];     
        Bvec(:, Unique_vol+1) = [];
        dlmwrite(strcat(dti_path, '/dti_nobs.bvec'), Bvec, 'delimiter', ' ', 'precision', '%.14f');
        Bval = textread(strcat(dti_path, '/dti1.bval'));
        Bval(:, end) = [];
        Bval(:, Unique_vol+1) = [];
        dlmwrite(strcat(dti_path, '/dti_nobs.bval'), Bval, 'delimiter', ' ');
        return;
    end
end


% if several dti found, check all of them
Dti_ok = 0; % Flag for a full DTI ok
for i = 1 : length(DTIs)
    if sum(abs(BS{i}(:)) > thre) == 0 && Dti_ok == 0
        Dti_ok = i;
        Report_file = strcat(dti_path, '/dti', num2str(i), '.report');
        fid = fopen(Report_file, 'w');
        fprintf(fid, 'No abnormal slice (threshold = %f)\n', thre);
        fprintf(fid, 'Z-score range :\n');
        [slice_min, vol_min] = find(BS{i} == min(BS{i}(:)));
        fprintf(fid, 'Min : %f (volume %d , slice %d)\n', min(BS{i}(:)), vol_min, slice_min-1);
        [slice_max, vol_max] = find(BS{i} == max(BS{i}(:)));
        fprintf(fid, 'Max : %f (volume %d , slice %d)\n', max(BS{i}(:)), vol_max, slice_max-1);
        fclose(fid);
        [s, m] = unix(['cp ', dti_path, '/dti', num2str(i), '.nii.gz ', dti_path, '/dti_nobs.nii.gz']);
        [s, m] = unix(['cp ', dti_path, '/dti', num2str(i), '.bval ', dti_path, '/dti_nobs.bval']);
        [s, m] = unix(['cp ', dti_path, '/dti', num2str(i), '.bvec ', dti_path, '/dti_nobs.bvec']);
    else
        if sum(abs(BS{i}(:)) > thre) == 0
            Report_file = strcat(dti_path, '/dti', num2str(i), '.report');
            fid = fopen(Report_file, 'w');
            fprintf(fid, 'No abnormal slice (threshold = %f)\n', thre);
            fprintf(fid, 'Z-score range :\n');
            [slice_min, vol_min] = find(BS{i} == min(BS{i}(:)));
            fprintf(fid, 'Min : %f (volume %d , slice %d)\n', min(BS{i}(:)), vol_min, slice_min-1);
            [slice_max, vol_max] = find(BS{i} == max(BS{i}(:)));
            fprintf(fid, 'Max : %f (volume %d , slice %d)\n', max(BS{i}(:)), vol_max, slice_max-1);
            fclose(fid);
        else
            Report_file = strcat(dti_path, '/dti', num2str(i), '.report');
            fid = fopen(Report_file, 'w');
            LL = size(BS{i}, 1);
            fprintf(fid, 'Abnormal slice found in this volume\n');
            [slice, vol] = find(abs(BS{i}) > thre);
            fprintf(fid, 'volume %d, slice %d, z-score = %f\n', [vol, slice-1, BS{i}(slice + LL .* (vol-1))]');
            fclose(fid);
        end
    end
end

dti_to_repair = 0;
NbVol = inf;
if Dti_ok == 0
    % Find dti with fewest bad volumes
    for i = 1 : length(DTIs)
        [slice_i, vol_i] = find(abs(BS{i}) > thre);
        if length(unique(vol_i)) < NbVol
            NbVol = length(unique(vol_i));
            dti_to_repair = i;
        end
    end

    [slice_i, vol_i] = find(abs(BS{dti_to_repair}) > thre);
    Bvec_i = textread(strcat(dti_path, '/dti', num2str(dti_to_repair),'.bvec'));
    Bvec_i(:, end) = [];
    Final_Bvec = Bvec_i;
    
    dti_to_use = 1 : length(DTIs);
    dti_to_use(dti_to_repair) = [];
    Bvec_to_use = [];
    for j = dti_to_use
        [slice_j, vol_j] = find(abs(BS{j}) > thre);
        Unique_vol_j = unique(vol_j);
        Bvec_j = textread(strcat(dti_path, '/dti', num2str(j),'.bvec'));
        Bvec_j(:, end) = [];
        Nvols = length(Bvec_j);
        Vols = 0 : Nvols-1;
        Bvec_j(:, Unique_vol_j) = [];
        Vols(Unique_vol_j+1) = [];
        Bvec_to_use = [Bvec_to_use, [Bvec_j; Vols; repmat(j, 1, length(Bvec_j))]];
    end
    
    Vol_for_replacement = [];
    unique_vol_i = unique(vol_i);
    Lu = length(unique_vol_i);
    for i = 1 : Lu
        Distance = distance(Bvec_i(:, unique_vol_i(i)), Bvec_to_use(1:3, :));
        Dist_min = find(Distance == min(Distance));
        Dist_min = Dist_min(1);
        Final_Bvec(:, unique_vol_i(i)) = Bvec_to_use(1:3, Dist_min);
        Vol_for_replacement = [Vol_for_replacement; [unique_vol_i(i), Bvec_to_use(4, Dist_min), Bvec_to_use(5, Dist_min)]];
    end
    
    [s, m] = unix(['fslsplit ', strcat(dti_path, '/dti', num2str(dti_to_repair), '.nii.gz'), ' ', strcat(dti_path, '/tempi'), ' -t']);
    for j = 1 : size(Vol_for_replacement)
        [s, m] = unix(['fslroi ', strcat(dti_path, '/dti', num2str(Vol_for_replacement(j, 3)), '.nii.gz'), ' ', strcat(dti_path, '/tempj'), ' ', num2str(Vol_for_replacement(j, 2)), ' 1']);
        if Vol_for_replacement(j, 1) < 10
            [s, m] = unix(['mv -f ', strcat(dti_path, '/tempj.nii.gz'), ' ', strcat(dti_path, '/tempi000', num2str(Vol_for_replacement(j, 1)), '.nii.gz')]);
        else
            [s, m] = unix(['mv -f ', strcat(dti_path, '/tempj.nii.gz'), ' ', strcat(dti_path, '/tempi00', num2str(Vol_for_replacement(j, 1)), '.nii.gz')]);
        end
    end
    
    [s, m] = unix(['fslmerge -t ', strcat(dti_path, '/dti_nobs'), ' ', strcat(dti_path, '/tempi0*')]);
    [s, m] = unix(['rm -f ', strcat(dti_path, '/tempi0*'), ' ', strcat(dti_path, '/tempj*')]);
    fid = fopen(strcat(dti_path, '/dti_nobs.report'), 'w');
    fprintf(fid, '%s %s %s %s\n', 'original_dti', 'volume_of_original_dti', 'dti_of_replacement', 'volume_of_dti_of_replacement');
    for i = 1 : size(Vol_for_replacement, 1)
        fprintf(fid, '%d %d %d %d\n', dti_to_repair, Vol_for_replacement(i, 1), Vol_for_replacement(i, 3), Vol_for_replacement(i, 2));
    end
    fclose(fid);
    
    dlmwrite(strcat(dti_path, '/dti_nobs.bvec'), Final_Bvec, 'delimiter', ' ', 'precision', '%.14f');
    [s, m] = unix(['cp ', strcat(dti_path, '/dti', num2str(dti_to_repair), '.bval'), ' ', strcat(dti_path, '/dti_nobs.bval')]);
end