function tracts = tracts_flip_x(tracts)
% 
%usage : tracts = tracts_flip_x(tracts_in)
%
%input  :
%      tracts_in       : input tract structure as provided by f_readFiber*
%                         functions
%
%output :
%      tracts
%
%Pierre Besson @ CHR Lille, December 2010

if nargin ~= 1
    error('invalid usage');
end

Coord = cat(1, tracts.fiber.xyzFiberCoord)';
Coord = [Coord; ones(1, length(Coord))];
L = cat(1, tracts.fiber.nFiberLength);
Lindex = [0; cumsum(L)];

%
%
%
%
% Coord(1, :) = Nii.quatern_x + Coord(1,:);
Coord(1, :) = -Coord(1,:);
Coord = Coord(1:3,:)';

for i = 1 : length(Lindex)-1
    try
        tracts.fiber(i).xyzFiberCoord = Coord(Lindex(i)+1:Lindex(i+1), :);
    catch
        disp('??!!??!!');
        pause(0.1);
    end
end