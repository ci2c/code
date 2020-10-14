clear all;
close all;

%% Cr�ation de variables %%

    % Tables de valeurs statistiques de d�formations apr�s correction ('c') suivant les m�thodes d'obtention des centres de
    % gravit� choisies : m -> automatique + ajout manuel ou f -> fitting polynomial
    
tablecmf=[];
tablecfm=[];
tablecff=[];

    % Variables de stockage des centres de gravit� apr�s correction ('c') suivant les m�thodes d'obtention des centres de
    % gravit� choisies 
    
CGTcmf=[];
CGTcmm=[];
CGTcfm=[];
CGTcff=[];

%% Validation de la correction sur les images corrig�es apr�s d�tection
%% automatique + ajout manuel des centres de gravit�  %%

        name1='Corrig�es_manuel\TRS.';
        name3='.dcm';

for cp = 1:62
%         cp=35;
        name=strcat(name1,int2str(cp),name3);
        
    if exist(name)~=0
        
        % Calcul erreurs r�siduelles sur images corrig�es manuelles : d�tection manuelle et fit 
        
        [Cgc,Imac] = detection_TRS(name,cp);
        [Cgct,PIc] = tri_TRS(Imac,Cgc);  
        
        % d�tection auto + manuelle
            
        [Rc,qc,depc,Pfc,errorc,CGc,Cthc] = recalage_TRS(name,Cgct);
        CGTcmm=[CGTcmm;CGc];
        table = Deformations_TRS(Pfc,CGc,cp);
        tablecmm=[tablecmm;table];
        clear Cgc Rc qc depc Pfc errorc CGc Cthc table;
        
        % fitting polynomial
            
        [Rc,qc,depc,Pfc,errorc,CGc,Cthc] = recalage_TRS(name,PIc);
        CGTcmf=[CGTcmf;CGc];
        table = Deformations_TRS(Pfc,CGc,cp);
        tablecmf=[tablecmf;table];
        clear Rc qc depc Pfc errorc CGc Cthc table Cgct PIc;
        
        
    end
    
end

clear name1 name3 name cp;

%% Validation de la correction sur les images corrig�es apr�s obtention des
%% centres de gravit� par fitting polynomial  %%

        name1='Corrig�es_fit\TRS.';
        name3='.dcm';
        
for cp=1:62
        
%         cp=29;
        name=strcat(name1,int2str(cp),name3);
        
    if exist(name)~=0
        
        % Calcul erreurs r�siduelles sur images corrig�es fit : d�tection manuelle et fit 
        
        [Cgc,Imac] = detection_TRS(name,cp);
        [Cgct,PIc] = tri_TRS(Imac,Cgc);  
        
        % d�tection auto + manuelle
            
        [Rc,qc,depc,Pfc,errorc,CGc,Cthc] = recalage_TRS(name,Cgct);
        CGTcfm=[CGTcfm;CGc];
        table = Deformations_TRS(Pfc,CGc,cp);
        tablecfm=[tablecfm;table];
        clear Cgc  Rc qc depc Pfc errorc CGc Cthc table;
        
        % fitting polynomial
            
        [Rc,qc,depc,Pfc,errorc,CGc,Cthc] = recalage_TRS(name,PIc);
        CGTcff=[CGTcff;CGc];
        table = Deformations_TRS(Pfc,CGc,cp);
        tablecff=[tablecff;table];
        clear Rc qc depc Pfc errorc CGc Cthc table Cgct PIc Imac;
        
        
    end 
   
end    

clear name1 name3 name;


