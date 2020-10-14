function FMRIConnectome_SVR(Net_mat,SubjsFile)
%% CONFIG
fsdir     = '/NAS/tupac/protocoles/Strokdem/FS5.1_T2mask';

subjs = textread(SubjsFile,'%s \n');
%% MEASURES
Net_mat=cell2mat(Net_mat);
ID=find(Net_mat > 0);
sz=size(ID);


ConVal=zeros(length(subjs),sz(1));

for i=1:length(subjs)
    
    connFile = fullfile(fsdir,char(subjs(i)),'rsfmri','Craddock_Parc','Connectome_ck.mat');
    load(connFile);
    Cmat=Connectome.Cmat;

    for j=1:sz(1)
    
        ConVal(i,j)=Cmat(ID(j));

    end
end


%% Boucle ConVal et écrire dans fichier csv

Lesion = load('/NAS/tupac/protocoles/Strokdem/Lesions/72H/lesions_vol-Cra.txt');
sz=size(ConVal);

for i=118:sz(2)

    Y=ConVal(:,i);
    
    fid = fopen('/NAS/tupac/protocoles/Strokdem/FMRI/TCog/Network/Con_SVR_test.csv','w');
        fprintf(fid,'%s, %s, %s,','Registry code',strcat('Connexion',num2str(i)),'LesionVol');
        fprintf(fid,'\n');
        for j=1:length(Y)
            s=subjs{j};
            s2=s(1:end-3);
            fprintf(fid,'%s,',s2);
            fprintf(fid,'%f,',Y(j));
            fprintf(fid,'%.0f,',Lesion(j));
            fprintf(fid,'\n');
        end
        fclose(fid);
        
        name=strcat('Connexion',num2str(i));
        SVR_LSM_toolbox(name);

end  
      
        