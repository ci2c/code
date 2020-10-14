function spectre = read_spectro(fname)

if nargin ~= 1
    error('Invalid usage');
end

fileid = fopen(fname, 'r', 'l');
fid = fread(fileid, 'float32');
fid = fid([1:2:length(fid)]) + i*fid([2:2:length(fid)]);
fid = fid(:).';
fid = reshape(fid,length(fid)/2048,2048).';
spectre=fft(fid);
spectre=fftshift(spectre);
spectre=flipdim(spectre,1);

Maxi=-Inf;
for phi=-pi:0.005:pi,
spectre_tmp=spectre.*exp(-i.*phi);
re=real(spectre_tmp);
pic=max(re);
if pic > Maxi
    Maxi=pic;
    phase_opt=phi;
end
end

spectre=spectre.*exp(-i.*phase_opt);
reel=real(spectre);
plot(reel);
fclose(fileid);
