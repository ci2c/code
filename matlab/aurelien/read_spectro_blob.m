function fid = read_spectro_blob(fname)

if nargin ~= 1
    error('Invalid usage');
end

fileid = fopen(fname, 'r');
fid = fread(fileid, 'uint16');
fid = fid([1:2:length(fid)]) + i*fid([2:2:length(fid)]);
fid = fid(:).';
fid = reshape(fid,length(fid)/2048,2048).';
% spectre=fft(fid);
% spectre=fftshift(spectre);
fclose(fileid);