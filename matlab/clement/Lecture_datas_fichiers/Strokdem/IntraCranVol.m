

liste=dir('/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/'); %met dans 'liste' les repertoires du dossier

s1 = '/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/'; 
s4= '_M6/stats/aseg.stats';


matICV= [];
j=0;

for i=1:length(liste)

    s2 = liste(i).name;
    s3 = s2(1:end-3);
    s=strcat(s1,s3,s4);

    fid=fopen(s,'rt');
    
        if fid ~= -1
            j=j+1;
            fseek(fid,0,'bof');
            tline = fgetl(fid);
            
            while tline~=-1
            a = strread(tline,'%s','delimiter',', ');
                if length(a) > 3 && strcmp(a{3},'IntraCranialVol')
                    mats = str2num(a{7});
                end
             tline = fgetl(fid);
             format ('shortG');
            end
            
            fclose(fid);
            matn(j)={(liste(i).name(1:end-3))};
            matICV(j,1) = [mats];
        end
end


      


