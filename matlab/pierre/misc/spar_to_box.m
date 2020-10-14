function Box = spar_to_box(spar_path)
% usage : BOX = spar_to_box(SPAR_PATH];
%
% INPUT :
% -------
%    SPAR_PATH         : Path to spar file
%
% OUTPUT :
% --------
%    BOX               : 3 x 8 corners coordinates in world coordinates
%
% See also measure_in_box
%
% Pierre Besson @ CHRU Lille, Mar. 2012

if nargin ~= 1
    error('invalid usage');
end

try
    fid = fopen(spar_path);
catch
    error(['cannot open ' spar_path]);
end

ap_size       = [];
lr_size       = [];
cc_size       = [];
ap_off_center = [];
lr_off_center = [];
cc_off_center = [];
ap_angulation = [];
lr_angulation = [];
cc_angulation = [];

nline = 1;

while 1
    tline = fgetl(fid);
    
    if ischar(tline) & strfind(tline, 'ap_size')
        T = textscan(tline, '%s %f', 'delimiter', ':');
        ap_size = cell2mat(T(2));
    end
    
    if ischar(tline) & strfind(tline, 'lr_size')
        T = textscan(tline, '%s %f', 'delimiter', ':');
        lr_size = cell2mat(T(2));
    end
    
    if ischar(tline) & strfind(tline, 'cc_size')
        T = textscan(tline, '%s %f', 'delimiter', ':');
        cc_size = cell2mat(T(2));
    end
    
    if ischar(tline) & strfind(tline, 'ap_off_center')
        T = textscan(tline, '%s %f', 'delimiter', ':');
        ap_off_center = cell2mat(T(2));
    end
    
    if ischar(tline) & strfind(tline, 'lr_off_center')
        T = textscan(tline, '%s %f', 'delimiter', ':');
        lr_off_center = cell2mat(T(2));
    end
    
    if ischar(tline) & strfind(tline, 'cc_off_center')
        T = textscan(tline, '%s %f', 'delimiter', ':');
        cc_off_center = cell2mat(T(2));
    end
    
    if ischar(tline) & strfind(tline, 'ap_angulation')
        T = textscan(tline, '%s %f', 'delimiter', ':');
        ap_angulation = cell2mat(T(2));
    end
    
    if ischar(tline) & strfind(tline, 'lr_angulation')
        T = textscan(tline, '%s %f', 'delimiter', ':');
        lr_angulation = cell2mat(T(2));
    end
    
    if ischar(tline) & strfind(tline, 'cc_angulation')
        T = textscan(tline, '%s %f', 'delimiter', ':');
        cc_angulation = cell2mat(T(2));
    end
    
    if ~isempty(ap_size) && ~isempty(lr_size) && ~isempty(cc_size) && ~isempty(ap_off_center) && ~isempty(lr_off_center) && ~isempty(cc_off_center) && ~isempty(ap_angulation) && ~isempty(lr_angulation) && ~isempty(cc_angulation)
        break;
    end
    
    nline = nline + 1;
    if nline > 10000
        error('could not find all tags');
    end
end
fclose(fid);

size_factor = [lr_size; ap_size; cc_size];

Box = zeros(3, 8);
Box(:,1) = [ 0.5;  0.5;  0.5] .* size_factor;
Box(:,2) = [ 0.5; -0.5;  0.5] .* size_factor;
Box(:,3) = [ 0.5;  0.5; -0.5] .* size_factor;
Box(:,4) = [ 0.5; -0.5; -0.5] .* size_factor;
Box(:,5) = [-0.5;  0.5;  0.5] .* size_factor;
Box(:,6) = [-0.5; -0.5;  0.5] .* size_factor;
Box(:,7) = [-0.5;  0.5; -0.5] .* size_factor;
Box(:,8) = [-0.5; -0.5; -0.5] .* size_factor;

lr_angulation = -lr_angulation;

R_lr = [1 0 0; 0 cos(deg2rad(lr_angulation)) -sin(deg2rad(lr_angulation)); 0 sin(deg2rad(lr_angulation)) cos(deg2rad(lr_angulation))];
R_ap = [cos(deg2rad(ap_angulation)) 0 sin(deg2rad(ap_angulation)); 0 1 0; -sin(deg2rad(ap_angulation)) 0 cos(deg2rad(ap_angulation))];
R_cc = [cos(deg2rad(cc_angulation)) -sin(deg2rad(cc_angulation)) 0; sin(deg2rad(cc_angulation)) cos(deg2rad(cc_angulation)) 0; 0 0 1];

Box = R_lr * R_ap * R_cc * Box;
Box(1,:) = Box(1,:) - lr_off_center;
Box(2,:) = Box(2,:) - ap_off_center;
Box(3,:) = Box(3,:) + cc_off_center;
