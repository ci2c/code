clear all  

liste=dir('/home/fatmike/guillaume/data/Freesurfer/'); %met dans 'liste' les repertoires du dossier

[StatFile,CortName]=textread('/home/fatmike/guillaume/data/Cortex.txt','%s %s');
subj={};
%%  Récupération des valeurs de volume, surface, épaisseur corticaux (Seg FS)
for i=3:length(liste)
    subj{end+1}=liste(i).name;
end

for j=1:length(StatFile)
z=1;
for i=1:length(liste)
    % lh

    % lecture fichier
    
    File=fullfile('/home/fatmike/guillaume/data/Freesurfer/',liste(i).name,'stats',['lh.' cell2mat(StatFile(j))]);

    fid=fopen(File,'rt');

    if fid ~= -1 %Si il arrive à aller chercher le fichier
        %text=fread(fid,[1 Inf],'int8');
        text=textscan(fid,'%s');
        text=text{1,1};
        fclose(fid);
        
        
        % récupération des datas
        
        ind=find(ismember(text,char(CortName(j))));
        
        Name=(cell2mat(CortName(j)));
    
        Stats.(Name(1:9)).left.vol(i,1)=str2num(char(text(ind+2)));
        Stats.(Name(1:9)).left.surf(i,1)=str2num(char(text(ind+3)));
        Stats.(Name(1:9)).left.thick(i,1)=str2num(char(text(ind+4)));
        z=z+1;
    end
    
    %rh 
    File=fullfile('/home/fatmike/guillaume/data/Freesurfer/',liste(i).name,'stats',['rh.' cell2mat(StatFile(j))]);

    fid=fopen(File,'rt');

    if fid ~= -1 %Si il arrive à aller chercher le fichier
        %text=fread(fid,[1 Inf],'int8');
        text=textscan(fid,'%s');
        text=text{1,1};
        fclose(fid);
        
        
        % récupération des datas
        
        ind=find(ismember(text,char(CortName(j))));
        
        Name=(cell2mat(CortName(j)));
    
        Stats.(Name(1:9)).right.vol(i,1)=str2num(char(text(ind+2)));
        Stats.(Name(1:9)).right.surf(i,1)=str2num(char(text(ind+3)));
        Stats.(Name(1:9)).right.thick(i,1)=str2num(char(text(ind+4)));
    end
    
    
    end
    
end

%%  Récupération des valeurs de volume, surface, épaisseur corticaux (Roi)

for i=1:length(liste)
  
           File=fullfile('/home/fatmike/guillaume/data/Freesurfer/',liste(i).name,'stats','aseg.stats');
           ic=0;
           fid=fopen(File,'rt');
      
           if fid ~= -1
            j=j+1;
            fseek(fid,0,'bof');
            tline = fgetl(fid);
            
            while tline~=-1
            z = strread(tline,'%s','delimiter',', ');
                if length(z) > 3 && strcmp(z{3},'IntraCranialVol')
                    ic = str2num(z{7});
                end
             tline = fgetl(fid);
             format ('shortG');
            end
            fclose(fid);
           end
          ICVNTC(i,1)=ic; 
end 
for i=1:length(liste)    
% lh 
    File=fullfile('/home/fatmike/guillaume/data/Freesurfer/',liste(i).name,'mri','frontalgauche.nii');
    
    if exist(File) ~= 0
    nii=load_untouch_nii(File);
    count=sum(nii.img(:)~=0);
    Stats.frontal.left(i,1)=count;
    end
    
%rh    
    File=fullfile('/home/fatmike/guillaume/data/Freesurfer/',liste(i).name,'mri','frontaldroit.nii');
    
    if exist(File) ~= 0
    nii=load_untouch_nii(File);
    count=sum(nii.img(:)~=0);
    Stats.frontal.right(i,1)=count;
    end
   
end

disp('finished')
