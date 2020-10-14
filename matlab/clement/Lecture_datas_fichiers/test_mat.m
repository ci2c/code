clear all; 

% Get defformation field

tmpdir=('/NAS/dumbo/protocoles/MCI/Lille/SPHARM/hpg/Results/Obj')
filenames = conn_dir(fullfile(tmpdir,'*.obj'));

SurfFile='/NAS/dumbo/protocoles/MCI/Lille/SPHARM/hpg/stats/MocaV5/glm_moca2.txt_GLM_correctedMean.meta';

    if exist(SurfFile,'file')
        
        [p,n,e] = fileparts(SurfFile);
        nameR   = fullfile(p,[n '.obj']); %Prépare le nom .obj pour le template
        
        if ~exist(nameR,'file')
            Meta2Obj(SurfFile,nameR);
        end
        SurfFile = nameR;
        
    else
        
        disp([struc{k} ': no template file']);
        
    end
    
    SurfRef = SurfStatReadSurf(SurfFile);
    v       = size(SurfRef.coord,2);

    u1 = SurfRef.coord(:,SurfRef.tri(:,1));
    d1 = SurfRef.coord(:,SurfRef.tri(:,2))-u1;
    d2 = SurfRef.coord(:,SurfRef.tri(:,3))-u1;
    c  = cross(d1,d2,1);
    SurfRef.normal = zeros(3,v);
        for j=1:3
        for k=1:3
            AAA = accumarray(SurfRef.tri(:,j),c(k,:)')';
            try
                SurfRef.normal(k,:)=SurfRef.normal(k,:) + AAA;
            catch
                SurfRef.normal(k,:)=SurfRef.normal(k,:) + [AAA, zeros(1, length(SurfRef.normal)-length(AAA))];
            end
        end
    end
    SurfRef.normal=SurfRef.normal./(ones(3,1)*sqrt(sum(SurfRef.normal.^2,1)));

    N = size(filenames,1);
    cmd = sprintf('Number of files : %d',N);
    disp(cmd);
Mat_DispNorm=[];
    for i = 1 : N
        Temp = deblank(filenames(i,:));
        
            Surf = SurfStatReadSurf(Temp);
            Disp = Surf.coord - SurfRef.coord;
            DispNorm = dot(Disp, SurfRef.normal, 1);
            
            Mat_DispNorm(i,:)=DispNorm;
            %SurfStatWriteData([Temp(1:end-4), '_disp.txt'], Disp);
            %SurfStatWriteData([Temp(1:end-4), '_disp_norm.txt'], DispNorm);

    end
  
%%
liste=dir('/NAS/dumbo/protocoles/MCI/Lille/SPHARM/hpg/Results/Obj');

s1G='/NAS/dumbo/protocoles/MCI/Lille/SPHARM/hpg/Results/Obj/';
j=1;

for i=1:length(liste)
    
    s2=liste(i).name;
    fileG=strcat(s1G,s2);
    
    if length(s2) > 2 %Pour enlever les . et ..
        HG_name(j,:,:)={fileG};
        j=j+1;
    end
end
%% 
    
%%% Loading Age and Sexe %%%
load('/NAS/dumbo/protocoles/MCI/Lille/SPHARM/hpg/age_hpgMCI.mat');

load('/NAS/dumbo/protocoles/MCI/Lille/SPHARM/hpg/sexe_hpgMCI.mat');

%%% Loading covar %%%
load('/NAS/dumbo/protocoles/MCI/Lille/SPHARM/hpg/MocaV5.mat');

%load('/NAS/dumbo/protocoles/MCI/Lille/SPHARM/hpg/matt_con_hpgMCI.mat');
%%% Delete NaN and associated values %%%



ind=transpose(find(isnan(MocaV5)==1));


for j=1:length(ind)
    ind=transpose(find(isnan(MocaV5)==1));
    
    for i=ind(1)
        MocaV5=[MocaV5(1:(i-1));MocaV5((i+1):end)];
        age_hpgMCI=[age_hpgMCI(1:(i-1));age_hpgMCI((i+1):end)];
        sexe_hpgMCI=[sexe_hpgMCI(1:(i-1));sexe_hpgMCI((i+1):end)];
        Mat_DispNorm=[Mat_DispNorm(1:(i-1),:);Mat_DispNorm((i+1):end,:)];
        HG_name=[HG_name(1:(i-1));HG_name((i+1):end)];
    end
        
end

age=age_hpgMCI;
sexe=sexe_hpgMCI;

Age=term(age);
Sexe=term(sexe);
MOCAV5=term(MocaV5);

siz=length(MocaV5);
group={};
for n=1:siz
    group{end+1}='CTR';
end

Group=term(group);

M= Group + Age + Sexe + MOCAV5;

surf=SurfStatAvSurf(HG_name); %Pour la visualisation
mask=ones(1,1002);

slm=SurfStatLinMod(Mat_DispNorm, M, surf);
contrast=[0,0,0,1];
slm = SurfStatT( slm, contrast );


[ pval, peak, clus ] = SurfStatP( slm );
figure; SurfStatView(pval, surf,'avec covar');
