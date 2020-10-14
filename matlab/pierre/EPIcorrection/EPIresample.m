function Y_out = EPIresample(V, u, F, XYZu, outname, jacc_flag)
% usage : Y_out = EPIresample(V, U, Forwardity, [XYZ, Outname, Jaccobian_corr])
%
% Inputs :
%       V                 : Input image structure or image path (3D or 4D)
%                            nx x ny x nz x nt image
%       U                 : Displacement field
%                            nx x ny x nz  nii image
%       Forwardity        : 0 if backward acquisition
%                           1 if forward acquisition
% Option :
%       XYZ               : Points coordinates if V and U don't have the
%                           same size. Set [] if not available
%       Outname           : Outname file .nii
%       Jaccobian_corr    : Correct output image intensity with 
%                           Jaccobian determinant. Default : true
%
% Outputs :
%       Y_out             : Output volume matrix
%
% Pierre Besson @ CHRU Lille, Nov. 2011

if nargin ~= 3 && nargin ~=4 && nargin ~= 5 && nargin ~= 6
    error('invalid usage');
end

if ischar(V)
    V = spm_vol(V);
end

if ischar(u)
    u = spm_vol(u);
    ux = u.dim(1);
    uy = u.dim(2);
    uz = u.dim(3);
    [u, XYZ] = spm_read_vols(u);
else
    ux = size(u,1);
    uy = size(u,2);
    uz = size(u,3);
end

if (V(1).dim(1) ~= ux || V(1).dim(2) ~= uy || V(1).dim(3) ~= uz) && nargin ==3
    error(['V and U do not meet size requirement']);
end

if nargin > 3 && ~isempty(XYZu) && length(XYZu) ~= numel(u)
    error('XYZ must have the same length as the number of elements of u');
end

if F ~= 0 && F ~= 1
    error('invalid F');
end

if nargin < 5
    outname = [];
end

if nargin < 6
    jacc_flag = true;
end

[Y, XYZ] = spm_read_vols(V);

if nargin == 3 || isempty(XYZu)
    XYZ = [XYZ; ones(1, length(XYZ))];
    XYZ = spm_pinv(V(1).mat) * XYZ;
    XYZ(end, :) = [];
else
    XYZ = [XYZu; ones(1, length(XYZu))];
    XYZ = spm_pinv(V(1).mat) * XYZ;
    XYZ(end,:) = [];
end

uip = circshift(u, [0, -1, 0]);
uip(:,end,:) = uip(:,end-1,:);
uim = circshift(u, [0, 1, 0]);
uip(:,end,:) = uip(:,end-1,:);
U_term = (uip - uim) ./ 2;

if size(Y, 4) == 1
    if F == 1
        J = 1 + U_term;
        if jacc_flag
            Y_temp = spm_sample_vol(V, XYZ(1,:)', XYZ(2,:)' + u(:), XYZ(3,:)', 2) .* J(:);
        else
            Y_temp = spm_sample_vol(V, XYZ(1,:)', XYZ(2,:)' + u(:), XYZ(3,:)', 2);
        end
    else
        J = 1 - U_term;
        if jacc_flag
            Y_temp = spm_sample_vol(V, XYZ(1,:)', XYZ(2,:)' - u(:), XYZ(3,:)', 2) .* J(:);
        else
            Y_temp = spm_sample_vol(V, XYZ(1,:)', XYZ(2,:)' - u(:), XYZ(3,:)', 2);
        end
    end

    Y_out = reshape(Y_temp, size(u));
    
    if ~isempty(outname)
        V.fname = outname;
        V = spm_write_vol(V, Y_out);
    end
    
else
    Y_out = [];
    for i = 1 : size(Y, 4)
        if F == 1
            J = 1 + U_term;
            if jacc_flag
                Y_temp = spm_sample_vol(V(i), XYZ(1,:)', XYZ(2,:)' + u(:), XYZ(3,:)', 2) .* J(:);
            else
                Y_temp = spm_sample_vol(V(i), XYZ(1,:)', XYZ(2,:)' + u(:), XYZ(3,:)', 2);
            end
        else
            J = 1 - U_term;
            if jacc_flag
                Y_temp = spm_sample_vol(V(i), XYZ(1,:)', XYZ(2,:)' - u(:), XYZ(3,:)', 2) .* J(:);
            else
                Y_temp = spm_sample_vol(V(i), XYZ(1,:)', XYZ(2,:)' - u(:), XYZ(3,:)', 2);
            end
        end

        Y_out = cat(4, Y_out, reshape(Y_temp, size(u)));
        if ~isempty(outname)
            V(i).fname = outname;
            V(i) = spm_write_vol(V(i), Y_out(:,:,:,i));
        end
    end
end