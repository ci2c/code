function ksp_final = read_CPX_data()

clear all

Direc=uigetdir('','Sélectionner le répertoire contenant les données brutes (CPX et LIST)');
tic
DirList = dir(Direc);
cd(Direc);
for m=1:length(DirList)
        if ~isempty(strfind(DirList(m).name,'.list'))
            ParFile = DirList(m).name;
        end
    if ~isempty(strfind(DirList(m).name,'.data'))
            KspFile = DirList(m).name;
    end
end

d=dir(KspFile);
taille=d.bytes;
% [status nblineparfile]=system('more *.list |wc -l');
% nblineparfile=str2num(nblineparfile);
fid = fopen(ParFile,'r');
toc
% Data_array = textscan(fid, '%s %d %d %d %d8 %d8 %d8 %d8 %d8 %d8 %d8 %d8 %d8 %d8 %d8 %d8 %d8 %d8 %d8 %d8 %d8', 'CollectOutput', 1,'CommentStyle','#','Delimiter','\b','multipledelimsasone', 1);

% READ DATA HEADER--------------------------------------------------
% h=waitbar(0,'lecture du fichier LIST : allez prendre un café !!!');
tic
if ( fid == -1 )
    error('Cannot open header file in ');
else
   n=1;
%    p=1;
%    for p=1:nblineparfile,
%        waitbar(p/nblineparfile)
   while ( ~feof( fid ) )
        tline=fgetl(fid); 
      if     regexpi(tline, 'number_of_encoding_dimensions') 
              [matches] = regexpi(tline, '^.*(\d$)', 'tokens');
            no_encod_dir = str2num(char(matches{1}));
            disp(['séquence ',num2str(no_encod_dir),'D'])
        elseif regexpi(tline, 'number_of_dynamic_scans') 
              [matches] = regexpi(tline, '^.*(\d$)', 'tokens');
            no_dyn = str2num(char(matches{1}));
            disp(['nombre de dynamiques : ', num2str(no_dyn)])
        elseif regexpi(tline, 'number_of_echoes') 
              [matches] = regexpi(tline, '^.*(\d$)', 'tokens');
            no_echoes = str2num(char(matches{1}));
        elseif regexpi(tline, 'number_of_locations') 
              [matches] = regexpi(tline, '^.*(\d$)', 'tokens');
            nb_slices = str2num(char(matches{1}));
            disp(['nombre de coupes : ', num2str(nb_slices)])
        elseif regexpi(tline, 'number_of_extra_attribute_1') 
              [matches] = regexpi(tline, '^.*(\d$)', 'tokens');
            nb_extr_1 = str2num(char(matches{1}));
        elseif regexpi(tline, 'number_of_extra_attribute_2') 
              [matches] = regexpi(tline, '^.*(\d$)', 'tokens');
            nb_extr_2 = str2num(char(matches{1}));
        elseif regexpi(tline, 'number_of_signal_averages') 
              [matches] = regexpi(tline, '^.*(\d$)', 'tokens');
            nsa = str2num(char(matches{1}));
        elseif regexpi(tline, '0  number of coil channels') 
              [matches] = regexpi(tline, '(\d{1,2}$)', 'tokens');
            nb_coils_0 = str2num(char(matches{1}));
            disp(['nombre de canaux loca 0 : ', num2str(nb_coils_0)])
        elseif regexpi(tline, '1  number of coil channels') 
              [matches] = regexpi(tline, '(\d+$)', 'tokens');
            nb_coils_1 = str2num(char(matches{1}));
            disp(['nombre de canaux loca 1 : ', num2str(nb_coils_1)])
        elseif regexpi(tline, 'X-resolution') 
              [matches] = regexpi(tline, '(\d+$)', 'tokens');
            x_res = str2num(char(matches{1}));
            disp(['X size : ', num2str(x_res)])
        elseif regexpi(tline, 'Y-resolution') 
              [matches] = regexpi(tline, '(\d+$)', 'tokens');
            y_res = str2num(char(matches{1}));
            disp(['Y size : ', num2str(y_res)])
        elseif regexpi(tline, 'Z-resolution') 
              [matches] = regexpi(tline, '(\d+$)', 'tokens');
            z_res = str2num(char(matches{1})); 
            disp(['Z size : ', num2str(z_res)])
        elseif regexpi(tline, '^\s\sSTD') 
            [matches] = regexpi(tline, '(-{0,1}\d+)', 'tokens');
            y(n) = str2num(char(matches{9}));  
            mix(n) = str2num(char(matches{1}));
            dyn(n) = str2num(char(matches{2}));
            echo(n) = str2num(char(matches{4}));
            loca(n) = str2num(char(matches{5}));
            chan(n) = str2num(char(matches{6}));
            extr1(n) = str2num(char(matches{7}));
            extr2(n) = str2num(char(matches{8}));
            z(n) = str2num(char(matches{10}));
            sizedata(n) = str2num(char(matches{19}));
            offset(n) = str2num(char(matches{20}));
            n=n+1;
%            disp(['ligne processée : ', num2str(n)])
      end
   end
  
%   end
%      p=p+1;
     fclose( fid );
end
% close(h)
toc
%END READ HEADER------------------------------------


%-------------MISE EN FORME SPACE et indice paramètres-------

yshift = y + abs(min(y))+1;
zshift = z + abs(min(z))+1;
loca2 = loca-min(loca)+1;
chan2 = chan-min(chan)+1;

dyn = dyn-min(dyn)+1;
extr1 = extr1-min(extr1)+1;
extr2 = extr2-min(extr2)+1;
echo = echo-min(echo)+1;

%----------------------------------------


%--------------READ CPX DATA-----------------------------
tic
fid = fopen(KspFile,'r', 'l');

offksp=(offset(1));
vec=(taille-offksp)/4;

fseek(fid,offksp,'bof'); %recherche offset true data

ksp = fread(fid,vec,'float');  % 
kspcomplex = complex(ksp(1:2:end),ksp(2:2:end));
% clear ksp;
sizef = size(kspcomplex);
gap = (y_res*x_res) + 64;

Index = (1 : gap : sizef)';
Period = 0:63;
Index = repmat(Index, 1, 64);
Period = repmat(Period, size(Index, 1), 1);
Index = Index + Period;

kspcomplex(Index(:)) = [];

vector=(size(kspcomplex,1))*2;

ksp_reshape = reshape(kspcomplex,sizedata(1)/8,vector/(sizedata(1)/4));

ksp_final = zeros(sizedata(1)/8,max(yshift),max(zshift),max(chan2),max(loca),max(dyn),max(echo));

for k = 1:size(y,2),
        liney = yshift(1,k);
        linez = zshift(1,k);
        no_coil = chan2(1,k);
        no_slices = loca2(1,k);
        no_dyn = dyn(1,k);
        no_echo = echo(1,k);
        ksp_final(:,liney,linez,no_coil,no_slices,no_dyn,no_echo) = ksp_reshape(:,k);
%         disp(num2str(k))
end
% clear ksp_reshape;ksp

toc

ksp_final = flipdim(ksp_final,1);
total = size(ksp_final,3);


wsize = 512;
for actual = 1:total,
    
scrsz = get(0,'ScreenSize');
f = figure(1);
set(f,  'Position', [scrsz(3)/2-bitshift(wsize,-1) scrsz(4)/2-bitshift(wsize,-1) wsize wsize],...
    'Color',[1 1 1],...
    'Name','Autoview',...
    'NumberTitle','off',...
    'MenuBar','none');
axes('Position',[0 0 1 1],'Parent',f);

imagesc(imresize(abs(ksp_final(:,:,actual,1,1,1,1)),[wsize,wsize],'bilinear')); colormap(gray);
text(wsize/2,10,sprintf('%04d/%04d',actual,total),'FontName','verdana','FontWeight','bold','Color','white','HorizontalAlignment','center');
text(wsize/2,wsize-10,'Test aurelien monnet - 2010','FontName','verdana','FontWeight','bold','Color','white','HorizontalAlignment','center');
drawnow;
clf;
end

close Autoview
