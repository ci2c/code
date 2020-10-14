function data = bpm_remove_nan_surf(data)

[M,N] = size(data);

for k = 1:max([M,N])    
    surf = data{k};
    [M1,N1] = size(surf);
    AA = surf(:);
    indx = find(isnan(AA));
    AA(indx) = 0;
    surf = reshape(AA,M1,N1);
    data{k} = surf;
end
