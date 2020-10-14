function setNodesVolColor(n_att, in_vol, out_vol, Connectome)
% Usage : setNodesVolColor(n_att, in_vol, out_vol, Connectome)
%
% Color a parcellation volume with nodes' attributes
% 
% Inputs :
%       n_att        : nodes attributes (N_node x 1 vector)
%       in_vol       : input segmentation volume (path or spm structure)
%       out_vol      : name of output volume
%       Connectome   : connectome defining nodes order and labels (N_node)
%
% Pierre Besson @ CHRU Lille, Mar 2012

if nargin ~= 4
    error('invalid usage');
end

if length(Connectome.region) ~= length(n_att)
    error('n_att and Connectome should have the same length');
end

if ischar(in_vol)
    in_vol = spm_vol(in_vol);
end

[Y, XYZ] = spm_read_vols(in_vol);
Y = round(Y);
Y2 = zeros(size(Y));

for i = 1 : length(n_att)
    roi_label = Connectome.region(i).label;
    Y2(Y==roi_label) = n_att(i);
end

in_vol.fname = out_vol;
in_vol.dt(1) = 16;
spm_write_vol(in_vol, Y2);