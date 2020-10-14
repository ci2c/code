fclose all

dir_l=strcat('/NAS/dumbo/clement/ashs/Results/231023MB/final/231023MB_left_corr_usegray_volumes.txt');
dir_r=strcat('/NAS/dumbo/clement/ashs/Results/231023MB/final/231023MB_right_corr_usegray_volumes.txt');
    

TCog=struct('CA1',{},'CA2',{},'CA3',{},'DG',{},'subiculum',{},'ERC',{});

% Gauche
i=1;
    fid=fopen(dir_l,'rt');
        
        if fid ~= -1
           j=j+1;
           fseek(fid,0,'bof'); %Go première ligne
           tline=fgetl(fid); %Récupération de la ligne
           
           a = strread(tline,'%s','delimiter',' ');
           zob=char(a(3));
           switch (zob)
               
               case 'CA1'
                   CA1_g=a(5);
               case 'CA2'
                   CA2_g=a(5);
               case 'DG'
                   DG_g=a(5);
               case 'CA3'
                   CA3_g=a(5);
               case 'subiculum'
                   sub_g=a(5);
               case 'ERC'
                   ERC_g=a(5);
           end
           tline=fgetl(fid);
        end
        
        
        fclose(fid);
    
        
        fid=fopen(dir_r,'rt');
        
        if fid ~= -1
           fseek(fid,0,'bof'); %Go première ligne
           tline=fgetl(fid); %Récupération de la ligne
           
           a = strread(tline,'%s','delimiter',' ');
           
           switch a(3)
               
               case 'CA1'
                   CA1_r=a(5);
               case 'CA2'
                   CA2_r=a(5);
               case 'DG'
                   DG_r=a(5);
               case 'CA3'
                   CA3_r=a(5);
               case 'subiculum'
                   sub_r=a(5);
               case 'ERC'
                   ERC_r=a(5);
           end
           
           tline=fgetl(fid);
        end
        
       TCog(i).CA1=[CA1_g,CA1_d];
       TCog(i).CA2=[CA2_g,CA2_d];
       TCog(i).CA3=[CA3_g,CA3_d];
       TCog(i).DG=[DG_g,DG_d];
       TCog(i).subiculum=[sub_g;sub_d];
       TCog(i).ERC=[ERC_g,ERC_d];
       
       fclose(fid);