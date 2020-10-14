clear all;
close all;

%% Cr�ation de variables %%

    % Tables de valeurs statistiques de d�formations apr�s correction ('c') suivant les m�thodes d'obtention des centres de
    % gravit� choisies : m -> automatique + ajout manuel ou f -> fitting
    % polynomial
    
tablecmm=[];
tablecmf=[];
tablecfm=[];
tablecff=[];

    % Variables de stockage des centres de gravit� apr�s correction ('c') suivant les m�thodes d'obtention des centres de
    % gravit� choisies 
    
CGScmf=[];
CGScmm=[];
CGScfm=[];
CGScff=[];

%% Validation de la correction sur les images corrig�es apr�s d�tection
%% automatique + ajout manuel des centres de gravit�  %%

        name1='Corrig�es_manuel\SAG.';
        name3='.dcm';

for cp = 1:68
%         cp=35;
        name=strcat(name1,int2str(cp),name3);
        
    if exist(name)~=0
        
        % Calcul erreurs r�siduelles sur images corrig�es manuelles : d�tection manuelle et fit 
        
        [Cgc,Imac] = detection_SAG(name,cp);
        [Cgct,PIc] = tri_SAG(Imac,Cgc);  
        
        % d�tection auto + manuelle
            
        [Rc,qc,depc,Pfc,errorc,CGc,Cthc] = recalage_SAG(name,Cgct);
        CGScmm=[CGScmm;CGc];
        table = Deformations_SAG(Pfc,CGc,cp);
        tablecmm=[tablecmm;table];
        clear Cgc Rc qc depc Pfc errorc CGc Cthc table;
        
        % fitting polynomial
            
        [Rc,qc,depc,Pfc,errorc,CGc,Cthc] = recalage_SAG(name,PIc);
        CGScmf=[CGScmf;CGc];
        table = Deformations_SAG(Pfc,CGc,cp);
        tablecmf=[tablecmf;table];
        clear Rc qc depc Pfc errorc CGc Cthc table Cgct PIc;
        
        
    end
    
end

clear name1 name3 name cp;

%% Validation de la correction sur les images corrig�es apr�s obtention des
%% centres de gravit� par fitting polynomial  %%

        name1='Corrig�es_fit\SAG.';
        name3='.dcm';
        
for cp=1:68
        
%         cp=35;
        name=strcat(name1,int2str(cp),name3);
        
    if exist(name)~=0
        
        % Calcul erreurs r�siduelles sur images corrig�es fit : d�tection manuelle et fit 
        
        [Cgc,xyc] = detection_SAG(name,cp);
        [Cgct,PIc] = tri_SAG(Cgc,xyc);  
        
        % d�tection auto + manuelle
            
        [Rc,qc,depc,Pfc,errorc,CGc,Cthc] = recalage_SAG(name,Cgct);
        CGScfm=[CGScfm;CGc];
        table = Deformations_SAG(Pfc,CGc,cp);
        tablecfm=[tablecfm;table];
        clear Cgc Rc qc depc Pfc errorc CGc Cthc table;
        
        % fitting polynomial
            
        [Rc,qc,depc,Pfc,errorc,CGc,Cthc] = recalage_SAG(name,PIc);
        CGScff=[CGScff;CGc];
        table = Deformations_SAG(Pfc,CGc,cp);
        tablecff=[tablecff;table];
        clear Rc qc depc Pfc errorc CGc Cthc table Cgct PIc Imac;
        
        
    end 
   
end    

clear name1 name3 name;


