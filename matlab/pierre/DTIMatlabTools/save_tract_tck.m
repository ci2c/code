function save_tract_tck(tract,fname)
% usage : save_tract_tck(TRACT, FNAME)
% 
% Inputs :
%       TRACT     : A tract in a structure, as loaded with f_readFiber or
%                      f_readFiber_vtk_bin.
%       FNAME     : filename.tck
%
%
% Pierre Besson @ CHRU Lille, July 2013

if nargin ~= 2
    error('invalid usage');
end

f = fopen(fname, 'w', 'ieee-le');

fprintf(f, 'mrtrix tracks\ndatatype: Float32LE\ncount: %d\n', tract.nFiberNr);
data_offset = ftell(f) + 20;
fprintf(f, 'file: . %d\nEND\n', data_offset);

fwrite (f, zeros(data_offset-ftell(f),1), 'uint8');
Coord = cat(1, tract.fiber(:).xyzFiberCoord);
Length = cat(1, tract.fiber(:).nFiberLength);
Length = cumsum(double(Length));
Coord = insertrows(Coord, NaN, Length);
Coord = [Coord; inf inf inf];

fwrite(f, Coord', 'float32');
fclose(f);