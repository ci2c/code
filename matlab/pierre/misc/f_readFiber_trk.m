function tracts = f_readFiber_trk(fname)
% 
% function tracts = f_readFiber_trk(fname)
%
% tracts    : A structure similar to that created by f_readFiber, which I use
%             to load Trackvis .trk files.
% fname     : Path to the trk file.
% 
% Pierre Besson, 2010


if nargin ~= 1
    error('Invalid usage');
end

fid = fopen(fname, 'r');

% Load header
tracts.header.id_string=fread(fid,6,'uint8=>char')';
tracts.header.dim=fread(fid,3,'uint16=>short')';
tracts.header.voxel_size=fread(fid,3,'float')';
tracts.header.origin = fread(fid,3,'float')';
tracts.header.n_scalars = double(fread(fid,1,'uint16=>short')');
tracts.header.scalar_name = fread(fid,[10,20],'uint8=>char');
tracts.header.n_properties = double(fread(fid,1,'uint16=>short')');
tracts.header.property_name = fread(fid,[10,20],'uint8=>char');
tracts.header.vox_to_ras = fread(fid,[4,4],'float')';
tracts.header.reserved = fread(fid,444,'uint8=>char');
tracts.header.voxel_order = fread(fid,4,'uint8=>char')';
tracts.header.pad2 = fread(fid,4,'uint8=>char')';
tracts.header.image_orientation_patient = fread(fid,6,'float')';
tracts.header.pad1 = fread(fid,2,'uint8=>char');
tracts.header.invert_x = fread(fid,1,'uint8=>uchar');
tracts.header.invert_y = fread(fid,1,'uint8=>uchar');
tracts.header.invert_z = fread(fid,1,'uint8=>uchar');
tracts.header.swap_xy = fread(fid,1,'uint8=>uchar');
tracts.header.swap_yz = fread(fid,1,'uint8=>uchar');
tracts.header.swap_zx = fread(fid,1,'uint8=>uchar');
tracts.header.n_count = fread(fid,1,'uint32=>int32');
tracts.header.version = fread(fid,1,'uint32=>int32');
tracts.header.hdr_size = fread(fid,1,'uint32=>int32');

Mat = tracts.header.vox_to_ras(1:3,1:3) ./ det(tracts.header.vox_to_ras(1:3,1:3));
Orientation = [reshape(tracts.header.image_orientation_patient, 3, 2)'; 0 0 1];
Orientation = (Orientation + Orientation') / 2;
% Orientation = eye(3);
Trans = tracts.header.vox_to_ras(1:3,4);


% Load tracts
if tracts.header.n_count > 0
    % Allocating memory
    disp('Allocating memory...');
    tracts.fiber(tracts.header.n_count).xyzFiberCoord          = NaN;
    tracts.fiber(tracts.header.n_count).nFiberLength           = NaN;
    
    disp('Importing fibers...');
    for Idx = 1 : tracts.header.n_count
        tracts.fiber(Idx).nFiberLength = double(fread(fid, 1, 'uint32=>int32'));
        Stuff = fread(fid, 3 .* tracts.fiber(Idx).nFiberLength, 'float');
        Stuff = reshape(Stuff, 3, tracts.fiber(Idx).nFiberLength);
        tracts.fiber(Idx).xyzFiberCoord = Stuff(1:3, :);
        tracts.fiber(Idx).xyzFiberCoord = Orientation * (Mat * tracts.fiber(Idx).xyzFiberCoord + repmat(Trans, 1, size(Stuff, 2)));
        tracts.fiber(Idx).xyzFiberCoord = (tracts.fiber(Idx).xyzFiberCoord(1:3,:))';
    end
else
    Idx = 1;
    while 1
        try
            tracts.fiber(Idx).nFiberLength = double(fread(fid, 1, 'uint32=>int32'));
            Stuff = fread(fid, (3 + tracts.header.n_scalars) .* tracts.fiber(Idx).nFiberLength, 'float');
            Stuff = reshape(Stuff, 3 + tracts.header.n_scalars, tracts.fiber(Idx).nFiberLength);
            tracts.fiber(Idx).xyzFiberCoord = Stuff(1:3, :);
            tracts.fiber(Idx).xyzFiberCoord = Orientation * (Mat * tracts.fiber(Idx).xyzFiberCoord + repmat(Trans, 1, size(Stuff, 2)));
            tracts.fiber(Idx).xyzFiberCoord = (tracts.fiber(Idx).xyzFiberCoord(1:3,:))';
            Idx = Idx + 1;
        catch
            break;
        end
    end
    tracts.nFiberNr = Idx - 1;
    tracts.fiber(Idx) = [];
end


fclose(fid);