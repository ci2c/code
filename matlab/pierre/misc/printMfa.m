function printMfa(Connectome, Labels, outname, coordname)
% usage : printMfa(CONNECTOME, LABELS, OUTNAME, COORDNAME)
%
% Inputs :
%       CONNECTOME         : Connectome or path to input connectome
%       LABELS             : Path to the label image
%       OUTNAME            : Output name for matrix .csv
%       COORDNAME          : Output name for coordinates .cvs
%
%
% Pierre Besson @ CHRU Lille, Feb. 2012

if nargin ~= 4
    error('invalid usage');
end

if ischar(Connectome)
    eval(['load ', Connectome]);
end

try
    Connectome.Mfa(1,:) = [];
    Connectome.Mfa(:,1) = [];
catch
    error('Mfa not found in Connectome structure');
end

[i,j,v] = find(tril(Connectome.Mfa, -1));
fid = fopen(outname, 'w');
fprintf(fid, '%d,%d,%f\n', [i'; j'; v']);
fclose(fid);

V = spm_vol(Labels);
[Y, XYZ] = spm_read_vols(V);
fid = fopen(coordname, 'w');
fprintf(fid, '%f,%f,%f\n', XYZ(:, Y(:)~=0));
fclose(fid);