function [fibmni,posc_new,posc_orig,mbeg,mend] = DTI_NonLinearTransTracts2MNI(dtiFile,transMat,fibFile,t1Natif,t1MNI,opt)

if nargin < 6
    thresh = 0;
    interp = 0;
    voxinit = [1 1 1];
    bbinit  = [-78 -112 -70; 78 76 85];
else
    if isfield(opt,'thresh')
        thresh = opt.thresh;
    else
        thresh = 0;
    end
    if isfield(opt,'interp')
        interp = opt.interp;
    else
        interp = 0;
    end
    if isfield(opt,'voxinit')
        voxinit = opt.voxinit;
    else
        voxinit = [1 1 1];
    end
    if isfield(opt,'bbinit')
        bbinit = opt.bbinit;
    else
        bbinit = [-78 -112 -70; 78 76 85];
    end
end

% Deformation field
defs.comp{1}.def = cellstr(transMat);
Nii = nifti(defs.comp{1}.def);
vx  = sqrt(sum(Nii.mat(1:3,1:3).^2));
o   = Nii.mat\[0 0 0 1]';
o   = o(1:3)';
dm  = size(Nii.dat);
bb  = [-vx.*(o-1) ; vx.*(dm(1:3)-o)];

defs.comp{2}.idbbvox.vox = voxinit;
defs.comp{2}.idbbvox.bb  = bbinit;
defs.comp{2}.idbbvox.vox(~isfinite(defs.comp{2}.idbbvox.vox)) = vx(~isfinite(defs.comp{2}.idbbvox.vox));
defs.comp{2}.idbbvox.bb(~isfinite(defs.comp{2}.idbbvox.bb)) = bb(~isfinite(defs.comp{2}.idbbvox.bb));

defs.out{1}.pull.fnames  = fibFile;
defs.out{1}.pull.savedir.savesrc = 1;
defs.out{1}.pull.interp  = interp;
defs.out{1}.pull.mask    = 1;
defs.out{1}.pull.fwhm    = [0 0 0];
defs.out{1}.pull.prefix  = 'wm1';

[Def,mat] = get_comp(defs.comp);

% Get mask
oM  = zeros(4,4);
odm = zeros(1,3);
dim = size(Def);
msk = true(dim);
NI = nifti(dtiFile);
dm = NI.dat.dim(1:3);
M0 = NI.mat;
j  = 1;
M = inv(M0);
if ~all(M(:)==oM(:)) || ~all(dm==odm)
    tmp = affine(Def,M);
    msk = tmp(:,:,:,1)>=1 & tmp(:,:,:,1)<=size(NI.dat,1) ...
        & tmp(:,:,:,2)>=1 & tmp(:,:,:,2)<=size(NI.dat,2) ...
        & tmp(:,:,:,3)>=1 & tmp(:,:,:,3)<=size(NI.dat,3);
end
oM  = M;
odm = dm;

% num = 1;
oM = zeros(4,4);
[pth,nam,ext,num] = spm_fileparts(dtiFile);
NI = nifti(fullfile(pth,[nam ext]));
% NO = NI;
% wd = pth;
% NO.descrip = sprintf('Warped');
% NO.dat.fname = fullfile(wd,[defs.out{1}.pull.prefix nam ext]);
% dim            = size(Def);
% dim            = dim(1:3);
% NO.dat.dim     = [dim NI.dat.dim(4:end)];
% NO.dat.offset  = 0; % For situations where input .nii images have an extension.
% NO.mat         = mat;
% NO.mat0        = mat;
% NO.mat_intent  = 'Aligned';
% NO.mat0_intent = 'Aligned';
% out{1}         = [NO.dat.fname, ',', num2str(num)]; 
% NO.extras      = [];
% %create(NO);

% Smoothing settings
vx  = sqrt(sum(mat(1:3,1:3).^2));
krn = max(defs.out{1}.pull.fwhm./vx,0.25);

M0 = NI.mat;
M  = inv(M0);
if ~all(M(:)==oM(:))
    % Generate new deformation (if needed)
    Y = affine(Def,M);
end
oM = M;

mbeg = 0;
mend = 0;

% Read fibers
fibers = f_readFiber_tck(fibFile,thresh);

% Loop on fibers
[hdr,vol]    = niak_read_vol(dtiFile);
[ht1,t1nat]  = niak_read_vol(t1Natif);
[hmni,t1mni] = niak_read_vol(t1MNI);
intrp     = interp;
intrp     = [intrp*[1 1 1], 0 0 0];
Nfibers   = length(fibers.fiber);
posc_orig = zeros(Nfibers,2);
posc_new  = zeros(Nfibers,2);

fibmni.nImgWidth        = fibers.nImgWidth;
fibmni.nImgHeight       = fibers.nImgHeight;
fibmni.nImgSlices       = fibers.nImgSlices;
fibmni.fPixelSizeWidth  = fibers.fPixelSizeWidth;
fibmni.fPixelSizeHeight = fibers.fPixelSizeHeight;
fibmni.fSliceThickness  = fibers.fSliceThickness;
fibmni.nFiberNr         = fibers.nFiberNr;

tic
for j = 1:Nfibers
    
    if mod(j,100)==0; disp(['Loading fiber -> ' num2str(j)]); end
    
    % Get voxel coordinates
    coord  = fibers.fiber(j).xyzFiberCoord;
    voxels = niak_coord_world2vox(coord,hdr.info.mat)';
    
    % Identify the voxels that have a fiber going through them,
    % make an image volume that incorporates this information.
    Mat_fib = zeros(size(vol));
    p1 = voxels(:,1);
    p2 = unique(voxels(:,2:end-1)','rows');
    p3 = voxels(:,end);
    Mat_fib(sub2ind(size(vol),p2(:,1),p2(:,2),p2(:,3))) = 2;
    Mat_fib(p1(1),p1(2),p1(3)) = 1;
    Mat_fib(p3(1),p3(2),p3(3)) = 3;
    
    % % and then apply the transformation to MNI space.
    C   = spm_diffeo('bsplinc',single(Mat_fib),intrp);
    dat = spm_diffeo('bsplins',C,Y,intrp);
    if defs.out{1}.pull.mask
        dat(~msk) = NaN;
    end
    if sum(defs.out{1}.pull.fwhm.^2)~=0
        spm_smooth(dat,dat,krn); % Side effects
    end
%     NO.dat(:,:,:,1,1,1) = dat;
    
    idx=find(dat==1 | dat==2 | dat==3);
    txyz = zeros(length(idx),3);
    [txyz(:,1),txyz(:,2),txyz(:,3)] = ind2sub(size(dat),idx);
    tval = dat(idx);
    
    coordmni = niak_coord_vox2world(txyz,hmni.info.mat);
    tt = circshift(coordmni, -1);
    temp_length = cumsum( sqrt( sum( (coordmni(1:end-1, :) - tt(1:end-1, :)).^2, 2 ) ) );
    fibmni.fiber(j).xyzFiberCoord          = coordmni;
    fibmni.fiber(j).voxels                 = txyz;
    fibmni.fiber(j).nFiberLength           = length(tval);
    fibmni.fiber(j).rgbFiberColor          = single(255*ones(1, 3));
    fibmni.fiber(j).rgbPointColor          = single(255*ones(size(fibmni.fiber(j).xyzFiberCoord))); 
    fibmni.fiber(j).nSelectFiberStartPoint = 0;
    fibmni.fiber(j).nSelectFiberEndPoint   = fibmni.fiber(j).nFiberLength-1;
    fibmni.fiber(j).id                     = j*ones(fibmni.fiber(j).nFiberLength,1);
    fibmni.fiber(j).length                 = single(temp_length(end));
    fibmni.fiber(j).cumlength              = single([0; temp_length]);
    
    posc_orig(j,:) = [t1nat(floor(voxels(1,1)),floor(voxels(2,1)),floor(voxels(3,1))) ...
        t1nat(floor(voxels(1,end)),floor(voxels(2,end)),floor(voxels(3,end)))];
    tind = sub2ind(size(dat),txyz(:,1),txyz(:,2),txyz(:,3));
    % beg
    idx = find(tind(tval==1));
    vec = t1mni(tind(idx));
    if length(idx)>0
        id = find(vec==posc_orig(j,1));
        if length(id)>0
            begc = txyz(idx(id(1)),:);
            posc_new(j,1) = posc_orig(j,1);
        else
            begc = txyz(idx(1),:);
            posc_new(j,1) = t1mni(txyz(idx(1),1),txyz(idx(1),2),txyz(idx(1),3));
        end
    else
        posc_new(j,1) = t1mni(txyz(1,1),txyz(1,2),txyz(1,3));
        begc = txyz(1,:);
    end
    
    % end
    idx = find(tval==3);
    vec = t1mni(tind(idx));
    if length(idx)>0
        id = find(vec==posc_orig(j,2));
        if length(id)>0
            endc = txyz(idx(id(end)),:);
            posc_new(j,2) = posc_orig(j,2);
        else
            endc = txyz(idx(end),:);
            posc_new(j,2) = t1mni(txyz(idx(end),1),txyz(idx(end),2),txyz(idx(end),3));
        end
    else
        posc_new(j,2) = t1mni(txyz(end,1),txyz(end,2),txyz(end,3));
        endc = txyz(end,:);
    end
    
    fibmni.fiber(j).begincoord = begc;
    fibmni.fiber(j).endcoord   = endc;
    
%     if isempty(find(tval==1,1));
%         vec = t1mni(tind(tval==3));
%         if find(vec,posc_orig(j,2))
%             posc_new(j,:)=[posc_orig(j,2) posc_orig(j,2)];
%         else
%             posc_new(j,:)=[vec(1) vec(1)];
%         end
%     else
%         vec = t1mni(tind(tval==1));
%         if find(vec,posc_orig(j,1))
%             posc_new(j,1)=posc_orig(j,1);
%         else
%             posc_new(j,1)=vec(1);
%         end
%         vec = t1mni(tind(tval==3));
%         if find(vec,posc_orig(j,2))
%             posc_new(j,2)=posc_orig(j,2);
%         else
%             posc_new(j,2)=vec(1);
%         end
%     end
    
    %clear txyz idx tval tind C dat coord voxels Mat_fib p1 p2 p3;
    
end
time_to_convert = toc;

% Check that the fibers start and end in the same regions as they
% did before the transformation.
match_orig = ones(Nfibers,2);
match_orig(find(posc_orig(:,1)-posc_new(:,1)),1) = 0;
match_orig(find(posc_orig(:,2)-posc_new(:,2)),2) = 0;
mbeg = mbeg + length(find(match_orig(:,1)));
mend = mend +  length(find(match_orig(:,2)));

%==========================================================================
% function [Def,mat] = get_comp(job)
%==========================================================================
function [Def,mat] = get_comp(job)
% Return the composition of a number of deformation fields.

if isempty(job)
    error('Empty list of jobs in composition');
end
[Def,mat] = get_job(job{1});
for i=2:numel(job)
    Def1         = Def;
    mat1         = mat;
    [Def,mat]    = get_job(job{i});
    M            = inv(mat1);
    tmp          = zeros(size(Def),'single');
    tmp(:,:,:,1) = M(1,1)*Def(:,:,:,1)+M(1,2)*Def(:,:,:,2)+M(1,3)*Def(:,:,:,3)+M(1,4);
    tmp(:,:,:,2) = M(2,1)*Def(:,:,:,1)+M(2,2)*Def(:,:,:,2)+M(2,3)*Def(:,:,:,3)+M(2,4);
    tmp(:,:,:,3) = M(3,1)*Def(:,:,:,1)+M(3,2)*Def(:,:,:,2)+M(3,3)*Def(:,:,:,3)+M(3,4);
    Def(:,:,:,1) = single(spm_diffeo('bsplins',Def1(:,:,:,1),tmp,[1,1,1,0,0,0]));
    Def(:,:,:,2) = single(spm_diffeo('bsplins',Def1(:,:,:,2),tmp,[1,1,1,0,0,0]));
    Def(:,:,:,3) = single(spm_diffeo('bsplins',Def1(:,:,:,3),tmp,[1,1,1,0,0,0]));
    clear tmp
end


%==========================================================================
% function [Def,mat] = get_job(job)
%==========================================================================
function [Def,mat] = get_job(job)
% Determine what is required, and pass the relevant bit of the
% job out to the appropriate function.

fn = fieldnames(job);
fn = fn{1};
switch fn
    case {'comp'}
        [Def,mat] = get_comp(job.(fn));
    case {'def'}
        [Def,mat] = get_def(job.(fn));
    case {'dartel'}
        [Def,mat] = get_dartel(job.(fn));
    case {'sn2def'}
        [Def,mat] = get_sn2def(job.(fn));
    case {'inv'}
        [Def,mat] = get_inv(job.(fn));
    case {'id'}
        [Def,mat] = get_id(job.(fn));
    case {'idbbvox'}
        [Def,mat] = get_idbbvox(job.(fn));
    otherwise
        error('Unrecognised job type');
end


%==========================================================================
% function [Def,mat] = get_def(job)
%==========================================================================
function [Def,mat] = get_def(job)
% Load a deformation field saved as an image
Nii = nifti(job{1});
Def = single(Nii.dat(:,:,:,1,:));
d   = size(Def);
if d(4)~=1 || d(5)~=3, error('Deformation field is wrong!'); end
Def = reshape(Def,[d(1:3) d(5)]);
mat = Nii.mat;


%==========================================================================
% function [Def,mat] = get_idbbvox(job)
%==========================================================================
function [Def,mat] = get_idbbvox(job)
% Get an identity transform based on bounding box and voxel size.
% This will produce a transversal image.
[mat, dim] = spm_get_matdim('', job.vox, job.bb);
Def = identity(dim, mat);


%==========================================================================
% function Def = affine(y,M)
%==========================================================================
function Def = affine(y,M)
Def          = zeros(size(y),'single');
Def(:,:,:,1) = y(:,:,:,1)*M(1,1) + y(:,:,:,2)*M(1,2) + y(:,:,:,3)*M(1,3) + M(1,4);
Def(:,:,:,2) = y(:,:,:,1)*M(2,1) + y(:,:,:,2)*M(2,2) + y(:,:,:,3)*M(2,3) + M(2,4);
Def(:,:,:,3) = y(:,:,:,1)*M(3,1) + y(:,:,:,2)*M(3,2) + y(:,:,:,3)*M(3,3) + M(3,4);


%==========================================================================
% function Def = identity(d,M)
%==========================================================================
function Def = identity(d,M)
[y1,y2]   = ndgrid(single(1:d(1)),single(1:d(2)));
Def       = zeros([d 3],'single');
for y3=1:d(3)
    Def(:,:,y3,1) = y1*M(1,1) + y2*M(1,2) + (y3*M(1,3) + M(1,4));
    Def(:,:,y3,2) = y1*M(2,1) + y2*M(2,2) + (y3*M(2,3) + M(2,4));
    Def(:,:,y3,3) = y1*M(3,1) + y2*M(3,2) + (y3*M(3,3) + M(3,4));
end




% transMat = '/NAS/tupac/protocoles/healthy_volunteers/FS53/T02S01/dti/nemo/y_t1_dti_ras.nii';
% t1File   = '/NAS/tupac/protocoles/healthy_volunteers/FS53/T02S01/dti/nemo/t1_dti_ras.nii';
% fibFile  = '/NAS/tupac/protocoles/healthy_volunteers/FS53/T02S01/dti/nemo/whole_brain_6_1500000_part000001.tck';
% thresh   = 30;
% dtiFile  = '/NAS/tupac/protocoles/healthy_volunteers/FS53/T02S01/dti/nemo/rwm_mask_dti.nii';
% wt1File  = '/NAS/tupac/protocoles/healthy_volunteers/FS53/T02S01/dti/nemo/w8t1_dti_ras.nii';
% dtiFibFile = '/NAS/tupac/protocoles/healthy_volunteers/FS53/T02S01/dti/nemo/fiber1_dti.nii';

