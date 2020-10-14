function [courbes_R,decours]=FMRI_ReadNiftiTc(mask_R,fichier,norm)

% [courbes_R,decours]=st_read_analyze_tc(mask_R,fichier,repertoire,norm,opt)
% 
% ENTREES 
% mask_R        masque de r�ions d'int�et
% fichier       est le masque des fichiers a lire ( ex: 'mon_fichier*.img')
% norm          =1, normalisation des donn�s
%               =0, donnees brutes                        
%
% SORTIES
% courbes_R     cell dont l'entree i contient les TCs des voxels de la region i
% decours       est une matrice dont la colonne i est le TC moyen dans la region i
%
% Renaud Lopes @ CHRU Lille, June 2012


% Arguments par defaut
if nargin < 3
    norm = 0;
end

if nargout > 2
    mask_f=zeros(size(mask_R));
    mask_f_v=mask_f(:);
end

% On selectionne les fichiers
F = fichier;

% recuperation des infos sur les volumes
warning off
P = spm_vol(F);
warning on
nb_of_files = prod(size(P));

% lecture des coordonnees
[nx,ny,nz] = size(mask_R);
nb_regions = length(unique(mask_R))-1;
for i=1:nb_regions
    ind=find(mask_R(:)==i);
    [x{i},y{i},z{i}]=ind2sub([nx,ny,nz],ind);
    MAP(i).ind = ind;
    MAP(i).size = [nx,ny,nz];
    R{i} = find(mask_R==i);
end

% stockage du decours temporel de chaque point dans T
% le meme decours est rearrange dans TT pour faire un plot
for j=1:nb_regions
    courbes_R{j}=zeros(nb_of_files,length(x{j}));
    for i = 1:nb_of_files
        warning off
        T_tmp = spm_sample_vol(P(i),x{j},y{j},z{j},0);
        warning on
        courbes_R{j}(i,:)=T_tmp';
    end        
    if norm == 1
        va = var(courbes_R{j});
        I=find(va==0);
        if length(I)~=0
            J=find(va~=0);
            if nargout > 2
                mask_f_v(R{j}(J))=j;
            end
            courbes_R{j}=courbes_R{j}(:,J);
        end

        courbes_R{j}=st_normalise(courbes_R{j});
    end
    decours(:,j) = mean(courbes_R{j},2);
   % waitbar(j/nb_regions,h)
end


function courbes2 = st_normalise(courbes)
courbes2 = courbes-ones([size(courbes,1) 1])*mean(courbes,1);
courbes2 = courbes2./(ones([size(courbes,1) 1])*sqrt((1/(size(courbes2,1)-1))*sum(courbes2.^2,1)));
