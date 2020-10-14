function [u, Jacc] = EPIcorr(V_forward, V_backward, sigmas, Lambda1, Lambda2, u)
% usage : [U, JACC] = EPIcorr(V_forward, V_backward, [SIGMAS, LAMBDA1, LAMBDA2, U_INIT])
%
% Inputs :
%       V_forward          : Path to forward readout EPI (2D image)
%                            (displacements toward +y)
%       V_backward         : Path to backward readout EPI (2D image)
%                            (displacements toward -y)
%       SIGMAS             : SD of the blurring kernels. Default : 9:-0.25:0
%       LAMBDA1            : Magnitude displacement term. Default : 0
%       LAMBDA2            : Smoothness field term. Default : 1e-3
%       U_INIT             : Initial deformation field. Default : zeros
%
% Outputs :
%       U                  : Output deformation field
%       JACC               : Jaccobian
%
% Pierre Besson @ CHRU Lille, Nov. 2011

if nargin ~= 2 && nargin ~= 5 && nargin ~=6
    error('invalid usage');
end

if nargin == 2
    sigmas = 9:-0.25:0;
    Lambda1 = 0;
    Lambda2 = 1e-3;
end

try
    V_f = spm_vol(V_forward);
    [Y_1, XYZ_orig] = spm_read_vols(V_f);
catch
    error(['error reading ', V_forward]);
end

try
    V_b = spm_vol(V_backward);
    [Y_2, XYZ] = spm_read_vols(V_b);
catch
    error(['error reading ', V_backward]);
end

% Init variables & param
if nargin ~= 6
    u = zeros([size(Y_1, 1), size(Y_1, 2), size(Y_1, 3)]);
end
    
U_table = zeros([size(Y_1, 1), size(Y_1, 2), size(Y_1, 3), length(sigmas)]);
Nu = numel(u);
s_y = sqrt(sum(V_f.mat .* V_f.mat));
% delta = 1e-1;
% delta = s_y(2) ./ 4;
delta = 1e-1;

XYZ_orig = [XYZ_orig; ones(1, length(XYZ_orig))];

Indices = ones(size(u));
Indices(:, 1, :) = 0;
Indices = find(Indices);
Index_table1m = zeros(size(Indices));
nx = size(Y_1, 1);
K1 = numel(Indices);

% Keep original images
V_f_orig = V_f;
V_b_orig = V_b;

% blur all images
unique_sigmas = unique(sigmas);
for ite = 1 : length(unique_sigmas)
    blurImage(V_f_orig, unique_sigmas(ite), ['V_f_blur_', num2str(unique_sigmas(ite)), '.nii']);
    blurImage(V_b_orig, unique_sigmas(ite), ['V_b_blur_', num2str(unique_sigmas(ite)), '.nii']);
end


ite = 1;
while ite <= length(sigmas)
    % load blurred images
    V_f = spm_vol(['V_f_blur_', num2str(sigmas(ite)), '.nii']);
    V_b = spm_vol(['V_b_blur_', num2str(sigmas(ite)), '.nii']);
    
    XYZ = spm_pinv(V_f.mat) * XYZ_orig;
    XYZ(end, :) = [];
    
    % Init H & g
    H = sparse(Nu, Nu);
    g = zeros(Nu, 1);
    Hdiag = g;

    tic;


    Temp1 = zeros(size(Indices));
    % Compute H at non left boundary voxels, assuming H is symmetric
    tic;
    parfor i = 1 : K1
        k = Indices(i);
        xp = u;
        xp(k) = xp(k) + delta;
        xm = u;
        xm(k) = xm(k) - delta;

        xpp = xp;
        xpp(k - nx) = xpp(k - nx) + delta;
        xpm = xp;
        xpm(k - nx) = xpm(k - nx) - delta;
        Index_table1m(i) = (k - nx) + (k - 1) .* Nu;

        xmp = xm;
        xmp(k - nx) = xmp(k - nx) + delta;
        xmm = xm;
        xmm(k - nx) = xmm(k - nx) - delta;

        Temp1(i) = ( EPIcostfunc(V_f, V_b, XYZ, xpp, Lambda1, Lambda2) - EPIcostfunc(V_f, V_b, XYZ, xmp, Lambda1, Lambda2) - EPIcostfunc(V_f, V_b, XYZ, xpm, Lambda1, Lambda2) + EPIcostfunc(V_f, V_b, XYZ, xmm, Lambda1, Lambda2) ) ./ (4 .* delta .* delta);
    end

    toc


    H(Index_table1m) = Temp1;
    H = H + H';


    % Get grad vector and H diag
    Tu = EPIcostfunc(V_f, V_b, XYZ, u);

    parfor i = 1 : Nu
        uipd = u;
        uipd(i) = u(i) + delta;
        Tuipd = EPIcostfunc(V_f, V_b, XYZ, uipd, Lambda1, Lambda2);

        uimd = u;
        uimd(i) = u(i) - delta;
        Tuimd = EPIcostfunc(V_f, V_b, XYZ, uimd, Lambda1, Lambda2);

        g(i) = (Tuipd - Tuimd) ./ (2 * delta);
        Hdiag(i) = (Tuipd + Tuimd - 2 .* Tu) ./ (delta .* delta);
    end

    toc

    H(1 : (Nu+1) : (Nu * Nu) ) = Hdiag;
    
    % Cancel boundary artefacts
    g(1:nx) = 0;
    g(end - nx + 1 : end) = 0;
    H(1:nx, :) = 0;
    H(:, 1:nx) = 0;
    H(end-nx+1 : end, end-nx+1:end) = 0;
    H(end-nx+1 : end, :) = 0;
    H(:, end-nx+1:end) = 0;

    v = bicgstab(H, -g, 1e-12, 50000);
    
    if max(abs(v)) > 1
        disp('Displacement too large !');
        disp(['Reprocess ite ', num2str(ite), ' setting lambda2 = ', num2str(2*Lambda2)]);
        Lambda2 = 2 * Lambda2;
        continue;
    end

    u = u + reshape(v, size(u));
    U_table(:,:,:,ite) = u;
%     figure, imagesc(u), colorbar
%     title(['u at ite = ', num2str(ite)]);
    disp(['Stats at iteration ', num2str(ite), '  sigma = ', num2str(sigmas(ite))]);
    disp(['min(u) = ', num2str(min(u(:))), ' max(u) = ', num2str(max(u(:)))]);
    ite = ite + 1;
end



disp('done');