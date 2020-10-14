function u = EPIcorrfast3D(V_forward, V_backward, sigmas, Lambda1, Lambda2, u)
% usage : U = EPIcorrfast3D(V_forward, V_backward, [SIGMAS, LAMBDA1, LAMBDA2, U_INIT])
%
% Inputs :
%       V_forward          : Path to forward readout EPI (3D image)
%                            (displacements toward +y)
%       V_backward         : Path to backward readout EPI (3D image)
%                            (displacements toward -y)
%       SIGMAS             : SD of the blurring kernels. Default : 4:-0.25:0
%       LAMBDA1            : Magnitude displacement term. Default : 0
%       LAMBDA2            : Smoothness field term. Default : 10
%       U_INIT             : Initial deformation field. Default : zeros
%
% Outputs :
%       U                  : Output deformation field
%
% Pierre Besson @ CHRU Lille, Nov. 2011

if nargin ~= 2 && nargin ~= 5 && nargin ~=6
    error('invalid usage');
end

if nargin >= 5 && ~isempty(Lambda2)
    manual_lambda2 = true;
else
    manual_lambda2 = false;
end

if nargin == 2
    sigmas = 4:-0.25:0;
    Lambda1 = 0;
    Lambda2 = 10;
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
catch
    error(['error reading ', V_backward]);
end



% Init variables & param
nx = size(Y_1, 1);
ny = size(Y_1, 2);
nz = size(Y_1, 3);

if nz > 1
    lim_inf = 0.01;
    lim_sup = 0.08;
else
    lim_inf = 0.1;
    lim_sup = 0.8;
end

if nargin ~= 6
    u = zeros([nx, ny, nz]);
    u_init = u;
end

if nargin == 6
    if ischar(u)
        u = spm_vol(u);
        u = spm_read_vols(u);
    end
    u_init = u;
end

Nu = numel(u);
delta_grad = 0.1;
delta = 0.1;

XYZ_orig = [XYZ_orig; ones(1, length(XYZ_orig))];

% Construct delta matrices
FF = 1:nx*ny*nz+1:nx*nx*ny*ny*nz*nz;
FF = mod(FF, nx*ny*nz);
FF(FF==0) = nx*ny*nz;
Delta_mat = sparse(FF,1:nx*ny*nz,ones(length(FF), 1), nx*ny*nz, nx*ny*nz);
Indices = diag(Delta_mat) ~= 0;
[Id0, Jd0] = find(Delta_mat~=0);


FF = 1 + nx*ny*nz*nx : nx*ny*nz+1 : nx*nx*ny*ny*nz*nz;
[Xr, Yr, Zr] = coord1Dto3D(FF, nx*ny*nz, nx*ny*nz, 1);
FF = mod(FF, nx*ny*nz);
FF(FF==0) = nx*ny*nz;
[Xi, Yi, Zi] = coord1Dto3D(Yr, nx, ny, nz);
FF(Yi==1) = [];
Yr(Yi==1) = [];
Delta_mat_m = sparse(FF,Yr,ones(length(FF), 1), nx*ny*nz, nx*ny*nz);
Indices_m = sum(Delta_mat_m) ~= 0;
[Idm, Jdm] = find(Delta_mat_m~=0);


FF = 1 + nx*ny*nz*2*nx : nx*ny*nz+1 : nx*nx*ny*ny*nz*nz;
[Xr, Yr, Zr] = coord1Dto3D(FF, nx*ny*nz, nx*ny*nz, 1);
FF = mod(FF, nx*ny*nz);
FF(FF==0) = nx*ny*nz;
[Xi, Yi, Zi] = coord1Dto3D(Yr, nx, ny, nz);
FF(Yi<3) = [];
Yr(Yi<3) = [];
Delta_mat_mm = sparse(FF,Yr,ones(length(FF), 1), nx*ny*nz, nx*ny*nz);


FF = 1 + nx : nx*ny*nz+1 : nx*nx*ny*ny*nz*nz;
[Xr, Yr, Zr] = coord1Dto3D(FF, nx*ny*nz, nx*ny*nz, 1);
FF = mod(FF, nx*ny*nz);
FF(FF==0) = nx*ny*nz;
[Xi, Yi, Zi] = coord1Dto3D(Yr, nx, ny, nz);
FF(Yi==ny) = [];
Yr(Yi==ny) = [];
Delta_mat_p = sparse(FF,Yr,ones(length(FF), 1), nx*ny*nz, nx*ny*nz);

% top (x-1)
FF = 0 : nx*ny*nz+1 : nx*nx*ny*ny*nz*nz;
FF(1) = [];
[Xr, Yr, Zr] = coord1Dto3D(FF, nx*ny*nz, nx*ny*nz, 1);
FF = mod(FF, nx*ny*nz);
FF(FF==0) = nx*ny*nz;
[Xi, Yi, Zi] = coord1Dto3D(Yr, nx, ny, nz);
FF(Xi==1) = [];
Yr(Xi==1) = [];
Delta_mat_xm = sparse(FF,Yr,ones(length(FF), 1), nx*ny*nz, nx*ny*nz);
Indices_xm = sum(Delta_mat_xm) ~= 0;
[Idxm, Jdxm] = find(Delta_mat_xm~=0);

% less deep (z-1)
FF = 1 - nx * ny : nx*ny*nz+1 : nx*nx*ny*ny*nz*nz;
FF(FF<1) = [];
[Xr, Yr, Zr] = coord1Dto3D(FF, nx*ny*nz, nx*ny*nz, 1);
FF = mod(FF, nx*ny*nz);
FF(FF==0) = nx*ny*nz;
[Xi, Yi, Zi] = coord1Dto3D(Yr, nx, ny, nz);
FF(Zi==1) = [];
Yr(Zi==1) = [];
Delta_mat_zm = sparse(FF,Yr,ones(length(FF), 1), nx*ny*nz, nx*ny*nz);
Indices_zm = sum(Delta_mat_zm) ~= 0;
[Idzm, Jdzm] = find(Delta_mat_zm~=0);

% bottom (x+1)
FF = 2 : nx*ny*nz+1 : nx*nx*ny*ny*nz*nz;
[Xr, Yr, Zr] = coord1Dto3D(FF, nx*ny*nz, nx*ny*nz, 1);
FF = mod(FF, nx*ny*nz);
FF(FF==0) = nx*ny*nz;
[Xi, Yi, Zi] = coord1Dto3D(Yr, nx, ny, nz);
FF(Xi==nx) = [];
Yr(Xi==nx) = [];
Delta_mat_xp = sparse(FF,Yr,ones(length(FF), 1), nx*ny*nz, nx*ny*nz);

% deeper (z+1)
FF = 1 + nx * ny : nx*ny*nz+1 : nx*nx*ny*ny*nz*nz;
[Xr, Yr, Zr] = coord1Dto3D(FF, nx*ny*nz, nx*ny*nz, 1);
FF = mod(FF, nx*ny*nz);
FF(FF==0) = nx*ny*nz;
[Xi, Yi, Zi] = coord1Dto3D(Yr, nx, ny, nz);
FF(Zi==nz) = [];
Yr(Zi==nz) = [];
Delta_mat_zp = sparse(FF,Yr,ones(length(FF), 1), nx*ny*nz, nx*ny*nz);

clear FF;

% Get delta indices and stuffs
% By convention
% mm = 1 ; m = 2 ; i = 3 ; p = 4
Delta_struc = 3.*Delta_mat + 2.*Delta_mat_m + 4.*Delta_mat_p + Delta_mat_mm;
[Ids, Jds] = find(Delta_struc~=0);
II = mod(find(Delta_struc ~= 0), nx*ny*nz);
Ii = mod(find(Delta_mat ~= 0), nx*ny*nz);
Im = mod(find(Delta_mat_m ~= 0), nx*ny*nz);
Imm = mod(find(Delta_mat_mm ~= 0), nx*ny*nz);
Ip = mod(find(Delta_mat_p ~= 0), nx*ny*nz);
II(II==0) = nx*ny*nz;
Ii(Ii==0) = nx*ny*nz;
Im(Im==0) = nx*ny*nz;
Imm(Imm==0) = nx*ny*nz;
Ip(Ip==0) = nx*ny*nz;
IStruc = Delta_struc(Delta_struc(:)~=0);

% Construct matrices for calculating U smoothness (local difference)
Nm = nx*nx*ny*ny*nz*nz;
Mgx = Delta_mat + Delta_mat_m + Delta_mat_xm + Delta_mat_zm + Delta_mat_xp + Delta_mat_zp + Delta_mat_p;
[Idmgx, Jdmgx] = find(Mgx~=0);
N_N = sum(Mgx);
Imx = mod(find(Mgx), nx*ny*nz);
Imx(Imx==0) = nx*ny*nz;
Diag = 1 : nx*ny*nz+1 : Nm;
DiagMat = sparse(nx*ny*nz, nx*ny*nz);


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

% verbose
Lambda2orig = Lambda2;
ite = 1;
N_average = 50;
im_diff = Inf(1, N_average);
N_inc = [];


n_rep = 1;
while ite <= length(sigmas)
    % load blurred images
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
    U_term = U_term_init;                  % Modify the Jaccobian
    U_term(IStruc==1) = U_term(IStruc==1) + delta ./ 2; % Imm
    U_term(IStruc==2) = U_term(IStruc==2) + delta ./ 2; % Im
    U_term(IStruc==3) = U_term(IStruc==3) - delta ./ 2; % Ii
    U_term(IStruc==4) = U_term(IStruc==4) - delta ./ 2; % Ip
    Delta_vec = delta .* (Delta_mat(Delta_struc(:)~=0) + Delta_mat_m(Delta_struc(:)~=0));
    Fpp = EPIcostfuncfast3D(V_f, V_b, XYZmask, U_mat, U_term, Delta_vec, Delta_struc, Lambda1, Lambda2, Ids, Jds);
    U_term = U_term_init;                  % Modify the Jaccobian
    U_term(IStruc==1) = U_term(IStruc==1) - delta ./ 2;
    U_term(IStruc==2) = U_term(IStruc==2) + delta ./ 2;
    U_term(IStruc==3) = U_term(IStruc==3) + delta ./ 2;
    U_term(IStruc==4) = U_term(IStruc==4) - delta ./ 2;
    Delta_vec = delta .* (Delta_mat(Delta_struc(:)~=0) - Delta_mat_m(Delta_struc(:)~=0));
    Fpm = EPIcostfuncfast3D(V_f, V_b, XYZmask, U_mat, U_term, Delta_vec, Delta_struc, Lambda1, Lambda2, Ids, Jds);
    U_term = U_term_init;                  % Modify the Jaccobian
    U_term(IStruc==1) = U_term(IStruc==1) + delta ./ 2;
    U_term(IStruc==2) = U_term(IStruc==2) - delta ./ 2;
    U_term(IStruc==3) = U_term(IStruc==3) - delta ./ 2;
    U_term(IStruc==4) = U_term(IStruc==4) + delta ./ 2;
    Delta_vec = delta .* (-Delta_mat(Delta_struc(:)~=0) + Delta_mat_m(Delta_struc(:)~=0));
    Fmp = EPIcostfuncfast3D(V_f, V_b, XYZmask, U_mat, U_term, Delta_vec, Delta_struc, Lambda1, Lambda2, Ids, Jds);
    U_term = U_term_init;                  % Modify the Jaccobian
    U_term(IStruc==1) = U_term(IStruc==1) - delta ./ 2;
    U_term(IStruc==2) = U_term(IStruc==2) - delta ./ 2;
    U_term(IStruc==3) = U_term(IStruc==3) + delta ./ 2;
    U_term(IStruc==4) = U_term(IStruc==4) + delta ./ 2;
    Delta_vec = delta .* (-Delta_mat(Delta_struc(:)~=0) - Delta_mat_m(Delta_struc(:)~=0));
    Fmm = EPIcostfuncfast3D(V_f, V_b, XYZmask, U_mat, U_term, Delta_vec, Delta_struc, Lambda1, Lambda2, Ids, Jds);
    
    
    Hm = sparse(Idm, Jdm, (Fpp(Indices_m) - Fmp(Indices_m) - Fpm(Indices_m) + Fmm(Indices_m)) ./ (4 * delta * delta), Nu, Nu);
    
    if Lambda2 ~= 0
        Mx = sparse(Idmgx, Jdmgx, u(Imx), Nu, Nu);
        
        Mi = Mx;
        mean_i = sum(Mi) ./ N_N;
        DiagMat = sparse(1:Nu, 1:Nu, mean_i, Nu, Nu);
        
%         Mpp = Mx + delta_grad .* Delta_mat + delta_grad .* Delta_mat_xm;
%         Mpm = Mx + delta_grad .* Delta_mat - delta_grad .* Delta_mat_xm;
%         Mmp = Mx - delta_grad .* Delta_mat + delta_grad .* Delta_mat_xm;
%         Mmm = Mx - delta_grad .* Delta_mat - delta_grad .* Delta_mat_xm;
%         
%         Gpp = Mpp - Mgx * DiagMat;
%         Gpp = sum(Gpp.*Gpp);
%         Gpm = Mpm - Mgx * DiagMat;
%         Gpm = sum(Gpm.*Gpm);
%         Gmp = Mmp - Mgx * DiagMat;
%         Gmp = sum(Gmp.*Gmp);
%         Gmm = Mmm - Mgx * DiagMat;
%         Gmm = sum(Gmm.*Gmm);
%         
%         Grad = (Gpp - Gpm - Gmp + Gmm) ./ (4 .* delta_grad .* delta_grad);
%         Hm = Hm + sparse(Idxm, Jdxm, Lambda2 .* Grad(Indices_xm), Nu, Nu);
%         
%         Mpp = Mx + delta_grad .* Delta_mat + delta_grad .* Delta_mat_m;
%         Mpm = Mx + delta_grad .* Delta_mat - delta_grad .* Delta_mat_m;
%         Mmp = Mx - delta_grad .* Delta_mat + delta_grad .* Delta_mat_m;
%         Mmm = Mx - delta_grad .* Delta_mat - delta_grad .* Delta_mat_m;
%         
%         Gpp = Mpp - Mgx * DiagMat;
%         Gpp = sum(Gpp.*Gpp);
%         Gpm = Mpm - Mgx * DiagMat;
%         Gpm = sum(Gpm.*Gpm);
%         Gmp = Mmp - Mgx * DiagMat;
%         Gmp = sum(Gmp.*Gmp);
%         Gmm = Mmm - Mgx * DiagMat;
%         Gmm = sum(Gmm.*Gmm);
%         
%         Grad = (Gpp - Gpm - Gmp + Gmm) ./ (4 .* delta_grad .* delta_grad);
%         Hm = Hm + sparse(Idm, Jdm, Lambda2 .* Grad(Indices_m), Nu, Nu);
%         
%         Mpp = Mx + delta_grad .* Delta_mat + delta_grad .* Delta_mat_zm;
%         Mpm = Mx + delta_grad .* Delta_mat - delta_grad .* Delta_mat_zm;
%         Mmp = Mx - delta_grad .* Delta_mat + delta_grad .* Delta_mat_zm;
%         Mmm = Mx - delta_grad .* Delta_mat - delta_grad .* Delta_mat_zm;
%         
%         Gpp = Mpp - Mgx * DiagMat;
%         Gpp = sum(Gpp.*Gpp);
%         Gpm = Mpm - Mgx * DiagMat;
%         Gpm = sum(Gpm.*Gpm);
%         Gmp = Mmp - Mgx * DiagMat;
%         Gmp = sum(Gmp.*Gmp);
%         Gmm = Mmm - Mgx * DiagMat;
%         Gmm = sum(Gmm.*Gmm);
%         
%         Grad = (Gpp - Gpm - Gmp + Gmm) ./ (4 .* delta_grad .* delta_grad);
%         Hm = Hm + sparse(Idzm, Jdzm, Lambda2 .* Grad(Indices_zm), Nu, Nu);
        
    end

    
    H = Hm + Hm';

    % get grad and H diag
    Delta_vec = 0 .* Delta_vec;
    Tu = EPIcostfuncfast3D(V_f, V_b, XYZmask, U_mat, U_term_init, Delta_vec, Delta_struc, Lambda1, Lambda2, Ids, Jds);
    
    U_term = U_term_init;
    U_term(IStruc==4) = U_term(IStruc==4) - delta ./ 2; % Ip
    U_term(IStruc==2) = U_term(IStruc==2) + delta ./ 2; % Im
    Delta_vec = delta .* Delta_mat(Delta_struc(:)~=0);
    Tuip = EPIcostfuncfast3D(V_f, V_b, XYZmask, U_mat, U_term, Delta_vec, Delta_struc, Lambda1, Lambda2, Ids, Jds);
    U_term = U_term_init;
    U_term(IStruc==4) = U_term(IStruc==4) + delta ./ 2;
    U_term(IStruc==2) = U_term(IStruc==2) - delta ./ 2;
    Delta_vec = -Delta_vec;
    Tuim = EPIcostfuncfast3D(V_f, V_b, XYZmask, U_mat, U_term, Delta_vec, Delta_struc, Lambda1, Lambda2, Ids, Jds);
    
    g = ((Tuip - Tuim) ./ (2 * delta))';
    Hg0 = sparse(Id0, Jd0, ( Tuip(Indices) + Tuim(Indices) - 2 .* Tu(Indices) ) ./ (delta .* delta), Nu, Nu);
    
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
        
        Hg0 = Hg0 + sparse(Id0, Jd0, Lambda2 .* Grad(Indices)', Nu, Nu);
        
        Grad = (Gp - Gm) ./ (2 * delta_grad);
        g = g + Lambda2 * Grad';
    end
    
    H = H + Hg0;
    toc

    [v, flag_temp] = bicgstab(H, -g, 1e-12, 50000);
    disp(['min(v) = ', num2str(min(v)), ' max(v) = ', num2str(max(v))]);
    
    if max(abs(v)) > 0.8
        if Lambda2 < 2*Lambda2orig
            disp('Displacement too large !');
            disp(['Reprocess ite ', num2str(n_rep), ' setting lambda2 = ', num2str(Lambda2 / 0.75)]);
            Lambda2 = Lambda2 / 0.75;
            continue;
        else
            disp('Displacement too large !');
            disp(['cutting |v| > 0.8']);
            v(abs(v) > 0.8) = 0.8;
        end
    end
    
    u2 = u + reshape(v, size(u));
    disp(['Stats at iteration ', num2str(n_rep), '  sigma = ', num2str(sigmas(ite))]);
    disp(['min(u) = ', num2str(min(u(:))), ' max(u) = ', num2str(max(u(:)))]);
    
    % verbose
    v_f_out = EPIresample(V_f, u2, 1, XYZ_orig(1:3, :));
    v_b_out = EPIresample(V_b, u2, 0, XYZ_orig(1:3, :));

    im_diff = [im_diff, sum( (v_f_out(:) - v_b_out(:)) .* (v_f_out(:) - v_b_out(:)))];
    relative_error = (mean(im_diff(end-N_average:end-1)) - im_diff(end)) / mean(im_diff(end-N_average:end-1));
    disp(['im_diff = ', num2str(im_diff(end)), '    ', num2str(100*relative_error), ' %']);
    
    if manual_lambda2 ~= true
        if ite == 1 && n_rep == 6
            start_error = (mean(im_diff(end-5:end-1)) - im_diff(end)) / mean(im_diff(end-5:end-1));
            if (100 .* relative_error) > lim_sup || start_error < 0
                disp('Initial Lambda2 too small !');
                disp(['Restart using ', num2str(Lambda2 * 1.75)]);
                Lambda2 = 1.75 * Lambda2;
                Lambda2orig = Lambda2;
                ite = 1;
                n_rep = 1;
                im_diff = Inf(1, N_average);
                N_inc = [];
                u = u_init;
                continue;
            else
                if (100 .* start_error) < lim_inf
                    disp('Initial Lambda2 too large !');
                    disp(['Restart using ', num2str(Lambda2 / 5)]);
                    Lambda2 = Lambda2 / 5;
                    Lambda2orig = Lambda2;
                    ite = 1;
                    n_rep = 1;
                    im_diff = Inf(1, N_average);
                    N_inc = [];
                    u = u_init;
                    continue;
                end
            end
        end
    end
    
    if relative_error <= 0
        if ~isempty(N_inc)
            if max(abs(v)) > 1 && Lambda2 < 2 * Lambda2orig
                disp('Displacement too large !');
                disp(['Reprocess ite ', num2str(n_rep), ' setting lambda2 = ', num2str(Lambda2 / 0.75)]);
                Lambda2 = Lambda2 / 0.75;
                continue;
            end
                disp(['growing diff ! Setting Lambda2 = ', num2str(0.95*Lambda2)]);
                Lambda2 = 0.95 * Lambda2;
                N_inc = [N_inc, 1];
                im_diff(end) = [];
        else
            u = u2;
            if n_rep == 55
                N_inc = 0;
            end
        end
    else
        u = u2;
        N_inc = [N_inc, 0];
    end

    if length(N_inc) > 500 && (sum(N_inc(end-499:end)) == 0 || (relative_error > 0 && relative_error < 0.1/100))
        disp(['stagnating ! Decreasing Lambda2 = ', num2str(0.95*Lambda2)]);
        Lambda2 = 0.95 * Lambda2;
        N_inc = [N_inc, 1];
        u = u2;
    end
    
    if ite==1
        N_inc_max = 10;
    else
        N_inc_max = round(2 + ite / 5);
    end
    
    if sum(N_inc) > N_inc_max
        ite = ite + 1;
        n_rep = 1;
        N_inc = [];
        im_diff = repmat(im_diff(end), 1, N_average);
        % Lambda2 = Lambda2orig;
        continue;
    end
    
    n_rep = n_rep + 1;
end


% delete temp images
for ite = 1 : length(unique_sigmas)
    delete([path_f, name_f, '_blur_', num2str(unique_sigmas(ite)), ext_f], [path_b, name_b, '_blur_', num2str(unique_sigmas(ite)), ext_b]);
end

disp('ok');
