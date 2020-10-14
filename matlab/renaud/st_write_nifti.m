function V = st_write_nifti(data,header,fname)

% write analyze 4D series of images
%
% V = st_write_nifti(data,header,fname)
%
% INPUTS
% data         (4D or 3D array). data(:,:,:,i) is the data of the ith file.
% header       (structure). header(i) is a description of the header
%              of each file.
% file_name    (String, example '/my_path/my_file*.nii') Filter of the images to
%               write.
%
% OUTPUTS
% V            (char array). List of the written files.


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