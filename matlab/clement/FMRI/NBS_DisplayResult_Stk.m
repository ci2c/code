function NBS_DisplayResult_Stk(NodeFile)

[cx,cy,cz,color,deg,nam] = textread(NodeFile,'%f %f %f %f %f %s'); %Recup des valeurs de degré

[ID,~] = textread('/NAS/tupac/protocoles/Strokdem/FMRI/Ck_nodes.txt','%f %s'); %Récup des ID des LOI correspondant à chaque deg

%%LH

%Créer vecteur vertices vierge
vert_lh=zeros(149347,1);



for i=1:length(deg)
    
    LOI=fullfile(['/NAS/tupac/protocoles/Strokdem/FMRI/Craddock/LOI_lh/crad_loi_' num2str(ID(i)) '-surf.mgh']);
    if exist(LOI)
    data=SurfStatReadData(LOI);
    id_vert=find(data ~=0);
    vert_lh(id_vert)=round(10*(deg(i))+1);
    end
end

%% RH
vert_rh=zeros(150761,1);


for i=1:length(deg)
    
    LOI=fullfile(['/NAS/tupac/protocoles/Strokdem/FMRI/Craddock/LOI_rh/crad_loi_' num2str(ID(i)) '-surf.mgh']);
    
    if exist(LOI)
    data=SurfStatReadData(LOI);
    
    id_vert=find(data ~=0);
    [sx,sy]=size(id_vert);
    id_vert=reshape(id_vert,sy,sx);
    vert_rh(id_vert)=round(10*(deg(i))+1);
    end
end

write_curv('/NAS/tupac/protocoles/Strokdem/FMRI/Craddock/test_matlabVERT-RH',vert_rh,301522);
write_curv('/NAS/tupac/protocoles/Strokdem/FMRI/Craddock/test_matlabVERT-LH',vert_lh,298694);


cmd = sprintf('Make_montage.sh -fs /NAS/dumbo/protocoles/CogPhenoPark/FS5.3 -subj fsaverage -surf white -lhoverlay %s -rhoverlay %s -fminmax 99 %d -output %s -axial','/NAS/tupac/protocoles/Strokdem/FMRI/Craddock/test_matlabVERT-LH','/NAS/tupac/protocoles/Strokdem/FMRI/Craddock/test_matlabVERT-RH',max(deg)*100,'/NAS/tupac/protocoles/Strokdem/FMRI/Craddock/test_PartCoeff.tiff');
unix(cmd)

