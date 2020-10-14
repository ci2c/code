function u = EPIcorrfast(V_forward, V_backward, sigmas, Lambda1, Lambda2, u)
% usage : U = EPIcorrfast(V_forward, V_backward, [SIGMAS, LAMBDA1, LAMBDA2, U_INIT])
%
% Inputs :
%       V_forward          : Path to forward readout EPI (2D image)
%                            (displacements toward +y)
%       V_backward         : Path to backward readout EPI (2D image)
%                            (displacements toward -y)
%       SIGMAS             : SD of the blurring kernels. Default : 4:-0.25:0
%       LAMBDA1            : Magnitude displacement term. Default : 0
%       LAMBDA2            : Smoothness field term. Default : 1
%       U_INIT             : Initial deformation field. Default : zeros
%
% Outputs :
%       U                  : Output deformation field
%
% Pierre Besson @ CHRU Lille, Nov. 2011

if nargin ~= 2 && nargin ~= 5 && nargin ~=6
    error('invalid usage');
end

if nargin == 2
    sigmas = 4:-0.25:0;
    Lambda1 = 0;
    Lambda2 = 1;
end


EPIcutimage(V_forward, V_backward);

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
nx = size(Y_1, 1);
ny = size(Y_1, 2);
nz = size(Y_1, 3);
if nargin ~= 6
    u = zeros([nx, ny, nz]);
    u_init = u;
end

if nargin == 6
    u_init = u;
end

Nu = numel(u);
voxel_size = sqrt( (sum( V_f.mat(1:3,1:3) .* V_f.mat(1:3,1:3))) );
delta_grad = 0.1;
delta = 0.3;

XYZ_orig = [XYZ_orig; ones(1, length(XYZ_orig))];

% Construct delta matrices
Delta_mat = sparse(nx * ny, nx * ny);
% Delta_mat(eye(nx*ny)~=0) = 1;
Delta_mat(1:nx*ny+1:nx*nx*ny*ny) = 1;
Delta_mat(:, 1:nx) = 0;
Delta_mat(:, end - nx + 1 : end) = 0;
Indices = diag(Delta_mat) ~= 0;

Delta_mat_m = sparse(nx*ny, nx*ny);
FF = 1 + nx*ny*nx : nx*ny+1 : nx*nx*ny*ny;
Delta_mat_m(FF) = 1;
Delta_mat_m(:, 1:nx) = 0;
Delta_mat_m(:, end-nx+1 : end) = 0;

Delta_mat_mm = sparse(nx*ny, nx*ny);
FF = 1 + nx*ny*2*nx : nx*ny+1 : nx*nx*ny*ny;
Delta_mat_mm(FF) = 1;
Delta_mat_mm(:, 1:nx) = 0;
Delta_mat_mm(:, end-nx+1 : end) = 0;

Delta_mat_p = sparse(nx*ny, nx*ny);
FF = 1 + nx : nx*ny+1 : nx*nx*ny*ny;
FF( floor(FF / (nx*ny) + 1) > mod(FF, nx*ny) & mod(FF, nx*ny) ~= 0 ) = [];
Delta_mat_p(FF) = 1;
Delta_mat_p(:, 1:nx) = 0;
Delta_mat_p(:, 1:nx) = 0;

Delta_mat_b = sparse(nx*ny, nx*ny);
FF = 2 : nx*ny+1 : nx*nx*ny*ny;
Delta_mat_b(FF) = 1;
Delta_mat_b(:, 1:nx) = 0;
Delta_mat_b(:, end-nx+1:end) = 0;

Delta_mat_d = sparse(nx*ny, nx*ny);
FF = nx*ny-nx+3 : nx*ny+1 : nx*nx*ny*ny;
Delta_mat_d(FF) = 1;
Delta_mat_d(:, 1:nx) = 0;
Delta_mat_d(:, end-nx+1:end) = 0;

Delta_mat_dm = sparse(nx*ny, nx*ny);
FF = nx+2 : nx*ny+1 : nx*nx*ny*ny;
Delta_mat_dm(FF) = 1;
Delta_mat_dm(:, 1:nx) = 0;
Delta_mat_dm(:, end-nx+1:end) = 0;

Delta_mat_h = sparse(nx*ny, nx*ny);
FF = 0 : nx*ny+1 : nx*nx*ny*ny;
Delta_mat_h(FF(FF>1)) = 1;
Delta_mat_h(:, 1:nx) = 0;
Delta_mat_h(:, end-nx+1:end) = 0;

Delta_mat_dh = sparse(nx*ny, nx*ny);
FF = -nx : nx*ny+1 : nx*nx*ny*ny;
Delta_mat_dh(FF>0) = 1;
Delta_mat_dh(:, 1:nx) = 0;
Delta_mat_dh(:, end-nx+1:end) = 0;

clear FF;

% Get delta indices and stuffs
% By convention
% mm = 1 ; m = 2 ; i = 3 ; p = 4
Delta_struc = 3.*Delta_mat + 2.*Delta_mat_m + 4.*Delta_mat_p + Delta_mat_mm;
II = mod(find(Delta_struc ~= 0), nx*ny);
Ii = mod(find(Delta_mat ~= 0), nx*ny);
Im = mod(find(Delta_mat_m ~= 0), nx*ny);
Imm = mod(find(Delta_mat_mm ~= 0), nx*ny);
Ip = mod(find(Delta_mat_p ~= 0), nx*ny);
II(II==0) = nx*ny;
Ii(Ii==0) = nx*ny;
Im(Im==0) = nx*ny;
Imm(Imm==0) = nx*ny;
Ip(Ip==0) = nx*ny;
IStruc = Delta_struc(Delta_struc(:)~=0);

% Construct matrices for calculating U smoothness (local difference)
Mgx = sparse(nx * ny, nx * ny);
Nm = nx*nx*ny*ny;

FF = 0 : nx*ny+1 : Nm;
FF = [FF, 1 : nx*ny+1 : Nm, 2 : nx*ny+1 : Nm];
FF = [FF,  nx : nx*ny+1 : Nm, nx+1 : nx*ny+1 : Nm, nx+2 : nx*ny+1 : Nm];
FF = [FF,  -nx : nx*ny+1 : Nm, -nx+1 : nx*ny+1 : Nm, -nx+2 : nx*ny+1 : Nm];

Mgx(FF(FF>0)) = 1;

N_N = sum(Mgx);
Imx = mod(find(Mgx), nx*ny);
Imx(Imx==0) = nx*ny;
Diag = 1 : nx*ny+1 : Nm;
DiagMat = sparse(nx*ny, nx*ny);


% Keep original images
V_f_orig = V_f;
V_b_orig = V_b;

% blur all images
[path_f, name_f, ext_f] = fileparts(V_forward);
[path_b, name_b, ext_b] = fileparts(V_backward);

if ~isempty(path_f)
    path_f = [path_f, filesep];
end

if ~isempty(path_b)
    path_b = [path_b, filesep];
end

unique_sigmas = unique(sigmas);
for ite = 1 : length(unique_sigmas)
    blurImage(V_f_orig, unique_sigmas(ite), [path_f, name_f, '_blur_', num2str(unique_sigmas(ite)), ext_f]);
    blurImage(V_b_orig, unique_sigmas(ite), [path_b, name_b, '_blur_', num2str(unique_sigmas(ite)), ext_b]);
end

% If sigma == 0, use normalized images insteed of raw ones
if sum(sigmas==0) ~= 0
    V_f_orig = spm_vol([path_f, name_f, '_blur_', num2str(0), ext_f]);
    V_b_orig = spm_vol([path_b, name_b, '_blur_', num2str(0), ext_b]);
end

Lambda2orig = Lambda2;
ite = 1;
% Debugging
v_min = [];
v_max = [];
u_min = [];
u_max = [];
im_diff = [inf inf inf inf inf];
N_inc = [];
%
n_rep = 1;

while ite <= length(sigmas)
    % load blurred images

    % delta = 0.1 + sigmas(ite) .* voxel_size(2) ./ 8;

    V_f = spm_vol([path_f, name_f, '_blur_', num2str(sigmas(ite)), ext_f]);
    V_b = spm_vol([path_b, name_b, '_blur_', num2str(sigmas(ite)), ext_b]);
    
    
    % get coordinates of interest
    tic;
    XYZ = spm_pinv(V_f.mat) * XYZ_orig;
    XYZ(end, :) = [];
    XYZmask = XYZ(:, II);
    
    % cirshift and reshape of u
    uip = circshift(u, [0, -1, 0]);
    uip(:,end,:) = uip(:,end-1,:);
    uim = circshift(u, [0, 1, 0]);
    uim(:, 1, :) = uim(:,2,:);
    
    U_term_init = (uip(II) - uim(II)) ./ 2;
    
    U_mat = u(II);
    
    % Init H & g
    H = sparse(Nu, Nu);
    
    U_term = U_term_init;                  % Modify the Jaccobian
    U_term(IStruc==1) = U_term(IStruc==1) + delta ./ 2; % Imm
    U_term(IStruc==2) = U_term(IStruc==2) + delta ./ 2; % Im
    U_term(IStruc==3) = U_term(IStruc==3) - delta ./ 2; % Ii
    U_term(IStruc==4) = U_term(IStruc==4) - delta ./ 2; % Ip
    Delta_vec = delta .* (Delta_mat(Delta_struc(:)~=0) + Delta_mat_m(Delta_struc(:)~=0));
    Fpp = EPIcostfuncfast(V_f, V_b, XYZmask, U_mat, U_term, Delta_vec, Delta_struc, Lambda1, Lambda2);
    U_term = U_term_init;                  % Modify the Jaccobian
    U_term(IStruc==1) = U_term(IStruc==1) - delta ./ 2;
    U_term(IStruc==2) = U_term(IStruc==2) + delta ./ 2;
    U_term(IStruc==3) = U_term(IStruc==3) + delta ./ 2;
    U_term(IStruc==4) = U_term(IStruc==4) - delta ./ 2;
    Delta_vec = delta .* (Delta_mat(Delta_struc(:)~=0) - Delta_mat_m(Delta_struc(:)~=0));
    Fpm = EPIcostfuncfast(V_f, V_b, XYZmask, U_mat, U_term, Delta_vec, Delta_struc, Lambda1, Lambda2);
    U_term = U_term_init;                  % Modify the Jaccobian
    U_term(IStruc==1) = U_term(IStruc==1) + delta ./ 2;
    U_term(IStruc==2) = U_term(IStruc==2) - delta ./ 2;
    U_term(IStruc==3) = U_term(IStruc==3) - delta ./ 2;
    U_term(IStruc==4) = U_term(IStruc==4) + delta ./ 2;
    Delta_vec = delta .* (-Delta_mat(Delta_struc(:)~=0) + Delta_mat_m(Delta_struc(:)~=0));
    Fmp = EPIcostfuncfast(V_f, V_b, XYZmask, U_mat, U_term, Delta_vec, Delta_struc, Lambda1, Lambda2);
    U_term = U_term_init;                  % Modify the Jaccobian
    U_term(IStruc==1) = U_term(IStruc==1) - delta ./ 2;
    U_term(IStruc==2) = U_term(IStruc==2) - delta ./ 2;
    U_term(IStruc==3) = U_term(IStruc==3) + delta ./ 2;
    U_term(IStruc==4) = U_term(IStruc==4) + delta ./ 2;
    Delta_vec = delta .* (-Delta_mat(Delta_struc(:)~=0) - Delta_mat_m(Delta_struc(:)~=0));
    Fmm = EPIcostfuncfast(V_f, V_b, XYZmask, U_mat, U_term, Delta_vec, Delta_struc, Lambda1, Lambda2);
    
    
    H(Delta_mat_m~=0) = (Fpp(Indices) - Fmp(Indices) - Fpm(Indices) + Fmm(Indices)) ./ (4 * delta * delta);
    % DEBUG
    if sum(~isfinite(H(:))~=0)
        disp('bizbiz');
    end
    %
    
    if Lambda2 ~= 0
        Mx = Mgx;
        Mx(Mgx~=0) = u(Imx);
        
        Mi = Mx;
        mean_i = sum(Mi) ./ N_N;
        DiagMat(Diag) = mean_i;
        
        Mpp = Mx + delta_grad .* Delta_mat + delta_grad .* Delta_mat_h;
        Mpm = Mx + delta_grad .* Delta_mat - delta_grad .* Delta_mat_h;
        Mmp = Mx - delta_grad .* Delta_mat + delta_grad .* Delta_mat_h;
        Mmm = Mx - delta_grad .* Delta_mat - delta_grad .* Delta_mat_h;
        
        Gpp = Mpp - Mgx * DiagMat;
        Gpp = sum(Gpp.*Gpp);
        Gpm = Mpm - Mgx * DiagMat;
        Gpm = sum(Gpm.*Gpm);
        Gmp = Mmp - Mgx * DiagMat;
        Gmp = sum(Gmp.*Gmp);
        Gmm = Mmm - Mgx * DiagMat;
        Gmm = sum(Gmm.*Gmm);
        
        Grad = (Gpp - Gpm - Gmp + Gmm) ./ (4 .* delta_grad .* delta_grad);
        
        H(Delta_mat_h~=0) = Lambda2 .* Grad(Indices);
        
        Mpp = Mx + delta_grad .* Delta_mat + delta_grad .* Delta_mat_p;
        Mpm = Mx + delta_grad .* Delta_mat - delta_grad .* Delta_mat_p;
        Mmp = Mx - delta_grad .* Delta_mat + delta_grad .* Delta_mat_p;
        Mmm = Mx - delta_grad .* Delta_mat - delta_grad .* Delta_mat_p;
        
        Gpp = Mpp - Mgx * DiagMat;
        Gpp = sum(Gpp.*Gpp);
        Gpm = Mpm - Mgx * DiagMat;
        Gpm = sum(Gpm.*Gpm);
        Gmp = Mmp - Mgx * DiagMat;
        Gmp = sum(Gmp.*Gmp);
        Gmm = Mmm - Mgx * DiagMat;
        Gmm = sum(Gmm.*Gmm);
        
        Grad = (Gpp - Gpm - Gmp + Gmm) ./ (4 .* delta_grad .* delta_grad);
        
        H(Delta_mat_p~=0) = Lambda2 .* Grad(Indices);
        
        Mpp = Mx + delta_grad .* Delta_mat + delta_grad .* Delta_mat_d;
        Mpm = Mx + delta_grad .* Delta_mat - delta_grad .* Delta_mat_d;
        Mmp = Mx - delta_grad .* Delta_mat + delta_grad .* Delta_mat_d;
        Mmm = Mx - delta_grad .* Delta_mat - delta_grad .* Delta_mat_d;
        
        Gpp = Mpp - Mgx * DiagMat;
        Gpp = sum(Gpp.*Gpp);
        Gpm = Mpm - Mgx * DiagMat;
        Gpm = sum(Gpm.*Gpm);
        Gmp = Mmp - Mgx * DiagMat;
        Gmp = sum(Gmp.*Gmp);
        Gmm = Mmm - Mgx * DiagMat;
        Gmm = sum(Gmm.*Gmm);
        
        Grad = (Gpp - Gpm - Gmp + Gmm) ./ (4 .* delta_grad .* delta_grad);
        
        H(Delta_mat_d~=0) = Lambda2 .* Grad(Indices);
        
        Mpp = Mx + delta_grad .* Delta_mat + delta_grad .* Delta_mat_dm;
        Mpm = Mx + delta_grad .* Delta_mat - delta_grad .* Delta_mat_dm;
        Mmp = Mx - delta_grad .* Delta_mat + delta_grad .* Delta_mat_dm;
        Mmm = Mx - delta_grad .* Delta_mat - delta_grad .* Delta_mat_dm;
        
        Gpp = Mpp - Mgx * DiagMat;
        Gpp = sum(Gpp.*Gpp);
        Gpm = Mpm - Mgx * DiagMat;
        Gpm = sum(Gpm.*Gpm);
        Gmp = Mmp - Mgx * DiagMat;
        Gmp = sum(Gmp.*Gmp);
        Gmm = Mmm - Mgx * DiagMat;
        Gmm = sum(Gmm.*Gmm);
        
        Grad = (Gpp - Gpm - Gmp + Gmm) ./ (4 .* delta_grad .* delta_grad);
        
        H(Delta_mat_dm~=0) = Lambda2 .* Grad(sum(Delta_mat_dm)~=0);
    end

    H = H + H';
    
    
    
    % get grad and H diag
    Delta_vec = 0 .* Delta_vec;
    Tu = EPIcostfuncfast(V_f, V_b, XYZmask, U_mat, U_term_init, Delta_vec, Delta_struc, Lambda1, Lambda2);
    
    U_term = U_term_init;
    U_term(IStruc==4) = U_term(IStruc==4) - delta ./ 2; % Ip
    U_term(IStruc==2) = U_term(IStruc==2) + delta ./ 2; % Im
    Delta_vec = delta .* Delta_mat(Delta_struc(:)~=0);
    Tuip = EPIcostfuncfast(V_f, V_b, XYZmask, U_mat, U_term, Delta_vec, Delta_struc, Lambda1, Lambda2);
    U_term = U_term_init;
    U_term(IStruc==4) = U_term(IStruc==4) + delta ./ 2;
    U_term(IStruc==2) = U_term(IStruc==2) - delta ./ 2;
    Delta_vec = -Delta_vec;
    Tuim = EPIcostfuncfast(V_f, V_b, XYZmask, U_mat, U_term, Delta_vec, Delta_struc, Lambda1, Lambda2);
    
    g = ((Tuip - Tuim) ./ (2 * delta))';
    H(Delta_mat~=0) = ( Tuip(Indices) + Tuim(Indices) - 2 .* Tu(Indices) ) ./ (delta .* delta);
    
    if Lambda2 ~= 0
        Mp = Mx + delta_grad .* Delta_mat;
        Mm = Mx - delta_grad .* Delta_mat;
        
        Gp = Mp - Mgx * DiagMat;
        Gp = sum(Gp.*Gp);
        Gm = Mm - Mgx * DiagMat;
        Gm = sum(Gm.*Gm);
        Gi = Mi - Mgx * DiagMat;
        Gi = sum(Gi.*Gi);
        
        Grad = (Gp + Gm - 2*Gi) ./ (delta_grad .* delta_grad);
        
        H(Delta_mat~=0) = H(Delta_mat~=0) + Lambda2 .* Grad(Indices)';
        
        Grad = (Gp - Gm) ./ (2 * delta_grad);
        g = g + Lambda2 * Grad';
    end
    
    
    % Cancel boundary artefacts
    g(1:nx) = 0;
    g(end - nx + 1 : end) = 0;
    H(1:nx, :) = 0;
    H(:, 1:nx) = 0;
    H(end-nx+1 : end, end-nx+1:end) = 0;
    H(end-nx+1 : end, :) = 0;
    H(:, end-nx+1:end) = 0;
    
    toc

    v = bicgstab(H, -g, 1e-12, 50000);
    
    disp(['min(v) = ', num2str(min(v)), ' max(v) = ', num2str(max(v))]);
    
%     if max(abs(v)) > 2 && Lambda2 < 2*Lambda2orig
%         disp('Displacement too large !');
%         disp(['Reprocess ite ', num2str(n_rep), ' setting lambda2 = ', num2str(Lambda2 / 0.75)]);
%         Lambda2 = Lambda2 / 0.75;
%         continue;
%     end

        
    if max(abs(v)) > 0.8
        disp('Displacement too large !');
        disp(['cutting |v| > 0.8']);
        v(abs(v) > 0.8) = 0.8;
    end
    
    u2 = u + reshape(v, size(u));
%     figure, imagesc(u), colorbar
%     title(['u at ite = ', num2str(ite)]);
    disp(['Stats at iteration ', num2str(n_rep), '  sigma = ', num2str(sigmas(ite))]);
    disp(['min(u) = ', num2str(min(u(:))), ' max(u) = ', num2str(max(u(:)))]);
    
    % debugging
    v_min = [v_min, min(v)];
    v_max = [v_max, max(v)];
    u_min = [u_min, min(u2(:))];
    u_max = [u_max, max(u2(:))];
%     v_f_out = EPIresample(V_f_orig, u2, 1);
%     v_b_out = EPIresample(V_b_orig, u2, 0);
    v_f_out = EPIresample(V_f, u2, 1, XYZ_orig(1:3, :));
    v_b_out = EPIresample(V_b, u2, 0, XYZ_orig(1:3, :));

    im_diff = [im_diff, sum( (v_f_out(:) - v_b_out(:)) .* (v_f_out(:) - v_b_out(:)))];
    relative_error = (mean(im_diff(end-5:end-1)) - im_diff(end)) / mean(im_diff(end-5:end-1));
    disp(['im_diff = ', num2str(im_diff(end)), '    ', num2str(100*relative_error), ' %']);
    
    if ite == 1 && n_rep == 6 
        if (100 .* relative_error) > 12 || relative_error < 0
            disp('Initial Lambda2 too small !');
            disp(['Restart using ', num2str(Lambda2 * 2.5)]);
            Lambda2 = 2.5 * Lambda2;
            Lambda2orig = Lambda2;
            ite = 1;
            n_rep = 1;
            v_min = [];
            v_max = [];
            u_min = [];
            u_max = [];
            im_diff = [inf inf inf inf inf];
            N_inc = [];
            u = u_init;
            continue;
        else
            if (100 .* relative_error) < 5 && Lambda2 > 1e-2
                disp('Initial Lambda2 too large !');
                disp(['Restart using ', num2str(Lambda2 / 5)]);
                Lambda2 = Lambda2 / 5;
                Lambda2orig = 4*Lambda2;
                ite = 1;
                n_rep = 1;
                v_min = [];
                v_max = [];
                u_min = [];
                u_max = [];
                im_diff = [inf inf inf inf inf];
                N_inc = [];
                u = u_init;
                continue;
            end
        end
    end
    
    if relative_error <= 0
        if max(abs(v)) > 1 && Lambda2 < 2 * Lambda2orig
            disp('Displacement too large !');
            disp(['Reprocess ite ', num2str(n_rep), ' setting lambda2 = ', num2str(Lambda2 / 0.75)]);
            Lambda2 = Lambda2 / 0.75;
            continue;
        end
        if length(N_inc) > 10
            disp(['growing diff ! Setting Lambda2 = ', num2str(0.8*Lambda2)]);
            Lambda2 = 0.8 * Lambda2;
            N_inc = [N_inc, 1];
            im_diff(end) = [];
        else
            disp(['adjusting Lambda2 = ' num2str(Lambda2 * 0.8)]);
            Lambda2 = Lambda2 * 0.8;
            % N_inc = [N_inc, 0.15];
            N_inc = [N_inc, 0];
            u = u2;
        end
    else
        N_inc = [N_inc, 0];
        u = u2;
    end
    
%     if (abs(relative_error) < 1e-6 && n_rep > 10) || n_rep > 1500
%         disp('stagnating ! Dicrease Sigma');
%         ite = ite + 1;
%         n_rep = 1;
%         u = u2;
%         continue;
%     end

    if mod(n_rep, 500) == 0
        % disp(['stagnating ! Dicreasing Lambda2 = ', num2str(0.8*Lambda2)]);
        disp(['stagnating ! Increasing Lambda2 = ', num2str(1.3*Lambda2)]);
        % N_inc = [N_inc, 1];
        % Lambda2 = 0.8 * Lambda2;
        Lambda2 = 1.3 * Lambda2;
        u = u2;
    end
    
    if length(N_inc) > 15 && sum(N_inc) > 15
        ite = ite + 1;
        n_rep = 1;
        N_inc = [];
        Ref = im_diff(end);
        im_diff = [Ref Ref Ref Ref Ref];
        % Lambda2 = Lambda2;
        Lambda2 = Lambda2orig;
        % Lambda2 = Lambda2orig .* 0.8^ite;
        figure, subplot(1,2,1), imagesc(v_f_out);
        subplot(1,2,2), imagesc(v_b_out);
        continue;
    end
    
    n_rep = n_rep + 1;
end


% delete temp images
for ite = 1 : length(unique_sigmas)
    delete([path_f, name_f, '_blur_', num2str(unique_sigmas(ite)), ext_f], [path_b, name_b, '_blur_', num2str(unique_sigmas(ite)), ext_b]);
end

disp('ok');
