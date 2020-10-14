function tracts = f_readFiber_tck(fname, thresh)
% 
% usage : TRACTS = f_readFiber_tck(FNAME, [THRESHOLD])
%
% Input :
%      FNAME     : path to tck fiber file (i.e. '/my/fibers/set.tck')
%
% Option :
%      THRESHOLD : single value : discard fibers whose length is less than THRESHOLD
%                  [t_min t_max] : keep only fibers whose length is
%                  comprised between t_min and t_max
%      (defaut : 0)
%
% Output :
%      TRACTS    : our usual fibers structure
% 
% Pierre Besson @ CHRU Lille, May 2011

if nargin ~= 1 && nargin ~= 2
    error('invalid usage');
end

if nargin == 2 && thresh(1) < 0
    error('THRESHOLD must be positive');
end

if nargin == 1
    thresh = 0;
else
    if size(thresh, 2) == 1
        thresh(2) = inf;
    end
end

try
    fid = fopen(fname);
catch
    error('can not open fname file');
end

% Look for file tag
while 1 
   tline = fgetl(fid);
   % disp(tline)
   if regexpi(tline,'file:')
      matches = regexpi(tline,'file:\s.\s(\d*)','tokens');
      offset = str2num(char(matches{1}));
      break
   end
end

fseek(fid, offset, 'bof');
coordinates = fread(fid, 'float', 'ieee-le');
table_length = length(coordinates) ./ 3;
coordinates = single(reshape(coordinates, 3, table_length)');
coordinates(end, :) = [];

end_mark = find(isnan(coordinates(:, 1)));
Nfibers = length(end_mark);

% Allocate memory
tracts.fiber(1).xyzFiberCoord          = single(0);
tracts.fiber(1).nFiberLength           = int32(0);
tracts.fiber(1).rgbFiberColor          = single(rand(1,3));
tracts.fiber(1).rgbPointColor          = single(rand(1,3));
tracts.fiber(1).nSelectFiberStartPoint = single(0);
tracts.fiber(1).nSelectFiberEndPoint   = single(0);
tracts.fiber(1).id                     = int32(0);
tracts.fiber(1).length                 = single(0);
tracts.fiber(1).cumlength              = single(0);

tracts.fiber(Nfibers).xyzFiberCoord          = 0;
tracts.fiber(Nfibers).nFiberLength           = 0;
tracts.fiber(Nfibers).rgbFiberColor          = single(rand(1,3));
tracts.fiber(Nfibers).rgbPointColor          = single(rand(1,3));
tracts.fiber(Nfibers).nSelectFiberStartPoint = single(0);
tracts.fiber(Nfibers).nSelectFiberEndPoint   = single(0);
tracts.fiber(Nfibers).id                     = int32(0);
tracts.fiber(Nfibers).length                 = single(0);
tracts.fiber(Nfibers).cumlength              = single(0);

% Fill structure
tracts.nImgWidth = NaN;
tracts.nImgHeight = NaN;
tracts.nImgSlices = NaN;
tracts.fPixelSizeWidth = NaN;
tracts.fPixelSizeHeight = NaN;
tracts.fSliceThickness = NaN;
tracts.nFiberNr = Nfibers;

end_mark = [0; end_mark];
if length(thresh) == 1 && thresh == 0
    for i = 1 : Nfibers
        tracts.fiber(i).xyzFiberCoord = coordinates(end_mark(i)+1:end_mark(i+1)-1, :);
        tracts.fiber(i).nFiberLength = int32(size(tracts.fiber(i).xyzFiberCoord, 1));
        tracts.fiber(i).nSelectFiberStartPoint = single(0);
        tracts.fiber(i).nSelectFiberEndPoint = single(tracts.fiber(i).nFiberLength - 1);
        tracts.fiber(i).id = int32(repmat(i, tracts.fiber(i).nFiberLength, 1));
        tt = circshift(tracts.fiber(i).xyzFiberCoord, -1);
        tracts.fiber(i).cumlength = single([0; cumsum(sqrt(sum( (tracts.fiber(i).xyzFiberCoord(1:end-1, :) - tt(1:end-1, :)).^2 , 2)))]);
        tracts.fiber(i).length = single(tracts.fiber(i).cumlength(end));

        % Fill up with garbage values
        tracts.fiber(i).rgbPointColor = single(255*ones(size(tracts.fiber(i).xyzFiberCoord)));
        tracts.fiber(i).rgbFiberColor = single(255*ones(1, 3));
    end
else
    j=1;
    for i = 1 : Nfibers
        temp_coord = coordinates(end_mark(i)+1:end_mark(i+1)-1, :);
        tt = circshift(temp_coord, -1);
        temp_length = cumsum( sqrt( sum( (temp_coord(1:end-1, :) - tt(1:end-1, :)).^2, 2 ) ) );
        if (temp_length(end) > thresh(1)) && (temp_length(end) < thresh(2))
            tracts.fiber(j).xyzFiberCoord = single(temp_coord);
            tracts.fiber(j).nFiberLength = int32(size(tracts.fiber(j).xyzFiberCoord, 1));
            tracts.fiber(j).nSelectFiberStartPoint = single(0);
            tracts.fiber(j).nSelectFiberEndPoint = single(tracts.fiber(j).nFiberLength - 1);
            tracts.fiber(j).id = int32(repmat(j, tracts.fiber(j).nFiberLength, 1));
            tracts.fiber(j).cumlength = single([0; temp_length]);
            tracts.fiber(j).length = single(temp_length(end));

            % Fill up with garbage values
            tracts.fiber(j).rgbPointColor = single(255*ones(size(tracts.fiber(j).xyzFiberCoord)));
            tracts.fiber(j).rgbFiberColor = single(255*ones(1, 3));
            j = j + 1;
        end
    end
    tracts.nFiberNr = single(j-1);
    tracts.fiber(j:end) = [];
end
    