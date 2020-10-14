function rec = read_rec()

[fid,chemin]=uigetfile('');

basename=strtok(char(fid),'.');

try
ParFile = strcat(chemin, strcat(basename, '.par'));
RecFile = strcat(chemin, strcat(basename, '.rec'));
catch
ParFile = strcat(chemin, strcat(basename, '.PAR'));
RecFile = strcat(chemin, strcat(basename, '.REC'));
end
    
parsed = textread(ParFile, '%s', 'commentstyle', 'shell'); % textread bcp + rapide
fileid = fopen(RecFile, 'r');
fid = fread(fileid, 'uint16');

nbslices=parsed(67);
res_x=parsed(247);
res_y=parsed(247);
nbslices=str2double(char(nbslices(1)));
res_x=str2double(char(res_x(1)));
res_y=str2double(char(res_y(1)));
rec=reshape(fid,res_x,res_y,nbslices);
for n = 1:nbslices
    rec(:,:,n)=rot90(rec(:,:,n),3);
end