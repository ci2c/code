function V = st_write_analyze_aurel(data,header,fname)

% write analyze 4D series of images
%
% V = st_write_analyze(data,header,fname)
%
% INPUTS
% data         (4D or 3D array). data(:,:,:,i) is the data of the ith file.
% header       (structure). header(i) is a description of the .hdr and .mat
%              of each file.
% file_name    (String, example '/my_path/my_file*.img') Filter of the images to
%               write.
%
% OUTPUTS
% V            (char array). List of the written files.

%
% DEPENDENCES
% spm_write_vol (SPM2)
%
% COMMENTS
% Vincent Perlbarg 02/07/05. Mod PB 06/06

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


nt = size(data,4);

if size(fname,1) == nt
    V = fname;
else
    V = [];
    for i = 1:nt
        num = num2str(i);
        l = length(num);
        num = [repmat('0',[1 4-l]) num ];
        V = [V;strcat(fname,num,'.nii')];
    end
end
for i = 1:nt
    header.fname = V(i,:);
    if exist('spm_write_vol.m')==2
        warning off
        spm_write_vol(header,data(:,:,:,i));
        warning off
    else
        st_write_analyze_emu(header,data(:,:,:,i));
    end
end


