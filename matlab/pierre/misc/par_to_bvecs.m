function [bvecs, bvals] = par_to_bvecs(par_file)
%
% usage : [BVECS, BVALS] = par_to_bvecs(par_file)
%
% Extract bvecs out of a .par file
%
% BVECS is RPI oriented
%
% Input :
%     PAR_FILE   : .par file
%
% Output :
%     BVECS      : corresponding bvecs
%     BVALS      : corresponding bvals
%
% Pierre Besson @ CHRU Lille, June 2011

if nargin ~= 1
    error('invalid usage');
end

try
    fid = fopen(par_file, 'r');
catch
    error(['can not read ', par_file]);
end

while 1
    tline = fgetl(fid);
    if ~isempty(regexpi(tline, 'Max. number of slices'))
        nb_slices = str2num(tline(43:end));
        break;
    end
end

while 1
    tline = fgetl(fid);
    if ~isempty(regexpi(tline, 'Angulation midslice'))
        rotations = str2num(tline(43:end));
        break;
    end
end

while 1
    tline = fgetl(fid);
    if ~isempty(regexpi(tline, 'Max. number of gradient orients'))
        matches = regexpi(tline, '\d');
        nb_gradient = str2num(tline(matches));
        break;
    end
end

while 1
    tline = fgetl(fid);
    if ~isempty(regexpi(tline, '#sl ec dyn'))
        tline = fgetl(fid);
        break;
    end
end

[Temp, COUNT] = fscanf(fid,'%f',[49, nb_slices * nb_gradient]);
bvals = Temp(end-15, 1:nb_slices:end);
Temp = Temp(end-3 : end-1, 1:nb_slices:end);

rotation_x = [1 0 0; 0 cos(degtorad(rotations(1))) -sin(degtorad(rotations(1))); 0 sin(degtorad(rotations(1))) cos(degtorad(rotations(1)))];
rotation_y = [cos(degtorad(rotations(2))) 0 sin(degtorad(rotations(2))); 0 1 0; -sin(degtorad(rotations(2))) 0 cos(degtorad(rotations(2)))];
rotation_z = [cos(degtorad(rotations(3))) -sin(degtorad(rotations(3))) 0; sin(degtorad(rotations(3))) cos(degtorad(rotations(3))) 0; 0 0 1];

bvecs = rotation_x * rotation_y * rotation_y * Temp;
% bvecs(2, :) = -bvecs(2, :);
% bvecs(3, :) = -bvecs(3, :);

Temp = bvecs;
bvecs(1, :) = -Temp(3, :);
bvecs(2, :) = Temp(1, :);
bvecs(3, :) = -Temp(2, :);

