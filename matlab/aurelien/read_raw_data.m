function ksp_final = read_raw_data()

Direc=uigetdir('','Sélectionner le répertoire contenant les données brutes (RAW et LIST)');

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
fid = fopen(ParFile,'r');

tic 
if ( fid == -1 )
    error('Cannot open header file in ');
   
else
    tline=fgetl(fid);
   while   isempty(findstr(tline,'STD'));      tline=fgetl(fid);
         
      if     regexpi(tline, 'number_of_encoding_dimensions') 
              [matches] = regexpi(tline, '^.*(\d$)', 'tokens');
            no_encod_dir = str2num(char(matches{1}));
        elseif regexpi(tline, 'Scan name') 
              [matches] = regexpi(tline, '^.*:(.*)', 'tokens');
            scan_name = (char(matches{1}));  
            disp(['Nom de la sequence : ' strcat(scan_name)]);
        elseif regexpi(tline, 'number_of_dynamic_scans') 
              [matches] = regexpi(tline, '^.*(\d$)', 'tokens');
            no_dyn = str2num(char(matches{1}));
            disp(['Nombre de dynamiques : ' num2str(no_dyn)]);
        elseif regexpi(tline, 'number_of_echoes') 
              [matches] = regexpi(tline, '^.*(\d$)', 'tokens');
            no_echoes = str2num(char(matches{1}));
            disp(['Nombre d''echos : ' num2str(no_echoes)]);
        elseif regexpi(tline, 'number_of_locations') 
              [matches] = regexpi(tline, '^.*(\d$)', 'tokens');
            nb_slices = str2num(char(matches{1}));
            disp(['Nombre de coupes : ' num2str(nb_slices)]);
        elseif regexpi(tline, 'number_of_extra_attribute_1') 
              [matches] = regexpi(tline, '^.*(\d$)', 'tokens');
            nb_extr_1 = str2num(char(matches{1}));
        elseif regexpi(tline, 'number_of_extra_attribute_2') 
              [matches] = regexpi(tline, '^.*(\d$)', 'tokens');
            nb_extr_2 = str2num(char(matches{1}));
        elseif regexpi(tline, 'number_of_signal_averages') 
              [matches] = regexpi(tline, '^.*(\d$)', 'tokens');
            nsa = str2num(char(matches{1}));
        elseif regexpi(tline, 'number of coil channels') 
              [matches] = regexpi(tline,'(\d{1,2}$)', 'tokens');
            nb_coils = str2num(char(matches{1}));
            disp(['Nombre d''elements d''antenne : ' num2str(nb_coils)]);
        elseif regexpi(tline, 'kx_range') 
              [matches] = regexpi(tline, '(-{0,1}\d*)', 'tokens');
            kx_range(1) = str2num(char(matches{4}));
            kx_range(2) = str2num(char(matches{5}));
        elseif regexpi(tline, 'ky_range') 
              [matches] = regexpi(tline, '(-{0,1}\d*)', 'tokens');
            ky_range(1) = str2num(char(matches{4}));
            ky_range(2) = str2num(char(matches{5}));
        elseif regexpi(tline, 'ky_range') 
              [matches] = regexpi(tline, '(-{0,1}\d*)', 'tokens');
            ky_range(1) = str2num(char(matches{4}));
            ky_range(2) = str2num(char(matches{5})); 
        elseif regexpi(tline, 'kz_range') 
              [matches] = regexpi(tline, '(-{0,1}\d*)', 'tokens');
            kz_range(1) = str2num(char(matches{4}));
            kz_range(2) = str2num(char(matches{5})); 
        elseif regexpi(tline, 'kx_oversample_factor') 
              [matches] = regexpi(tline, '^.*(\d\.\d*)', 'tokens');
            kx_oversample = str2num(char(matches{1}));
        elseif regexpi(tline, 'ky_oversample_factor') 
              [matches] = regexpi(tline, '^.*(\d\.\d*)', 'tokens');
            ky_oversample = str2num(char(matches{1}));
        elseif regexpi(tline, 'X-resolution') 
              [matches] = regexpi(tline, '(\d+$)', 'tokens');
            x_res = str2num(char(matches{1}));
        elseif regexpi(tline, 'Y-resolution') 
              [matches] = regexpi(tline, '(\d+$)', 'tokens');
            y_res = str2num(char(matches{1}));
        elseif regexpi(tline, 'X-direction SENSE factor') 
              [matches] = regexpi(tline, '^.*(\d\.\d*)', 'tokens');
              sense_factor_x = str2num(char(matches{1}));   
        elseif regexpi(tline, 'Y-direction SENSE factor') 
              [matches] = regexpi(tline, '^.*(\d\.\d*)', 'tokens');
            sense_factor_y = str2num(char(matches{1}));   
        elseif regexpi(tline, 'Z-direction SENSE factor') 
              [matches] = regexpi(tline, '^.*(\d\.\d*)', 'tokens');
            sense_factor_z = str2num(char(matches{1}));
   end
  
   end

     fclose( fid );
end

%==================LECTURE DU HEADER====================
parsed = textread(ParFile, '%s', 'commentstyle', 'shell'); % textread bcp + rapide
% A=find(strcmp(Truc,'STD')); 
A=find(strcmp(parsed,'STD'), 2);
tA=find(strcmp(parsed,'STD'), 1, 'last');
stddata = parsed(A(1):tA+20);
stddata = reshape(stddata, 21, length(stddata)/21);
stddata=stddata'; 
B=find(strcmp(parsed,'NOI'),2);
tB=find(strcmp(parsed,'NOI'), 1, 'last');
noise=parsed(B(1):tB+20);
noise=reshape(noise, 21, length(noise)/21);
noise=noise';
C=find(strcmp(parsed,'FRX'));
tC=find(strcmp(parsed,'FRX'), 1, 'last');
freq_corr_data=parsed(B(1):tC+20);
freq_corr_data=reshape(freq_corr_data, 21, length(freq_corr_data)/21);
freq_corr_data=freq_corr_data';
D=find(strcmp(parsed,'PHX'));
tD=find(strcmp(parsed,'PHX'), 1, 'last');
phase_corr_data=parsed(B(1):tD+20);
phase_corr_data=reshape(phase_corr_data, 21, length(phase_corr_data)/21);
phase_corr_data=phase_corr_data';

%========================================================

ky=str2num(char(stddata(:,10)));
kz=str2num(char(stddata(:,11)));
loca=str2num(char(stddata(:,6)));
chan=str2num(char(stddata(:,7)));
extr1=str2num(char(stddata(:,8)));
extr2=str2num(char(stddata(:,9)));
echo=str2num(char(stddata(:,5)));
dyn=str2num(char(stddata(:,3)));
aver=str2num(char(stddata(:,13)));
offset=str2num(char(stddata(:,21)));
sizedata=str2num(char(stddata(:,20)));
NOISE_chan=str2num(char(noise(:,7)));
NOISE_size=str2num(char(noise(:,20)));
NOISE_offset=str2num(char(noise(:,21)));
toc
%==========
kyshift = ky + abs(min(ky))+1;
kzshift = kz + abs(min(kz))+1;
loca = loca-min(loca)+1;
chan = chan-min(chan)+1;
dyn = dyn-min(dyn)+1;
extr1 = extr1-min(extr1)+1;
extr2 = extr2-min(extr2)+1;
echo = echo-min(echo)+1;
aver = aver-min(aver)+1;
%==========

tic
fid = fopen(KspFile,'r', 'l');

offksp=(offset(1));
vector=(taille-offksp)/4; % length=(taille-offksp)/4;

fseek(fid,offksp,'bof'); %recherche offset true data

ksp = fread(fid,vector,'float');  % length = (taille fichier totale - offset) /4
kspcomplex = complex(ksp(1:2:end),ksp(2:2:end));
% clear ksp;
% kspreshape = reshape(kspcomplex,sizedata(1)/8,nb_coils,length/((sizedata(1)*nb_coils)/4));
ksp_reshape = reshape(kspcomplex,sizedata(1)/8,vector/(sizedata(1)/4));
% ksp_final = zeros(sizedata(1)/8,max(kyshift),max(kzshift),max(chan),max(loca),max(dyn),max(echo));

for k = 1:size(ky,1),
        kliney = kyshift(k,1);
        klinez = kzshift(k,1);
        no_coil = chan(k,1);
        no_slices = loca(k,1);
        no_dyn = dyn(k,1);
        no_echo = echo(k,1);
        no_aver = aver(k,1);
        ksp_final(:,kliney,klinez,no_coil,no_slices,no_dyn,no_echo,no_aver) = ksp_reshape(:,k);
end

% clear ksp kspcomplex ksp_reshape;
toc
ksp_final=mean(ksp_final,8);
ksp_final = squeeze(ksp_final);

%================Calcul matrice de covariance du bruit============
% offset_noise=NOISE_offset(1);
% fseek(fid,offset_noise,'bof');
% data_noise=fread(fid,(NOISE_offset(end)+NOISE_size(1))/4,'float');
% noise_complex=complex(data_noise(1:2:end),data_noise(2:2:end));
% noise_complex=reshape(noise_complex,(NOISE_size(1)*2)/nb_coils,nb_coils);
% 
% for coil = 1:nb_coils
%     crv(coil)=mean(noise_complex(:,coil));
% end
% 
% noise_conj=conj(noise_complex);
% 
% for k = 1:nb_coils
%     for l = 1:nb_coils
%         covmatrix(k,l)=mean(noise_conj(:,l).*noise_complex(:,k))-mean(noise_conj(:,l)).*mean(noise_complex(:,k));
%     end
% end
% % 
% % cov_mat=xcorr2(noise_complex,noise_conj);
% 
% %==========symetrisation k-space=========
% %==============HALF_FOURIER==============
% k0=abs(min(ky))+1;
% kmax=abs(max(kyshift));
% delta_hf=kmax-k0;
% 
% to_copy = ksp_final(:,37:end,:);
% 
% %===============zerofilling=================
% A(1:size(ksp1,1),1:size(ksp1,2))=ksp1;
% A=circshift(A,[floor((size(A,1)-size(ksp1,1))/2) floor((size(A,2)-size(ksp1,2))/2)]);
% 
% %====================================
% 
% % coil2=ksp_reformat(:,:,1,2);
% % ima2=fft2(coil2);
% % ima2=fftshift(ima2,1);
% % figure,imagesc(abs(ima2));
% % colormap gray;
% 
