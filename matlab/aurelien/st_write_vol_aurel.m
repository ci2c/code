function V = st_write_vol_aurel(data,header,fname)

% write minc or analyze 4D series of images
%
% V = st_write_analyze(data,header,fname)
%
% INPUTS
% data         (4D or 3D array). data(:,:,:,i) is the data of the ith file.
% header       (structure). header(i) is a description an analyze or minc
%               header.
% fname        (String) Analyze: example '/my_path/my_file'. Prefix of the images to
%               write (output /my_path/my_file0001.img, ...)
%               Minc: name of the file to write (full path).
%
% OUTPUTS
% V            (char array). List of the written files.
%
% DEPENDENCES
% st_write_analyze or st_write_minc
%
% COMMENTS
% PB 06/06

% Copyright (C) 07/2009 Vincent Perlbarg, LIF/Inserm/UPMC-Univ Paris 06, 
% vincent.perlbarg@imed.jussieu.fr
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.

[path_f,name_f,ext_f] = fileparts(fname(1,:));
if isempty(ext_f)|strcmp(ext_f,'.nii')
    V = st_write_analyze_aurel(data,header,fname);
elseif strcmp(ext_f,'.mnc')
    st_write_minc(data,header,fname);
else
    fprintf('%s: Unknown file format !',ext_f)
    return
end
    
