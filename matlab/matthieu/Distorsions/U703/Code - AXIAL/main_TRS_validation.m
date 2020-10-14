clear all;
close all;

%% Création de variables %%

    % Tables de valeurs statistiques de déformations après correction ('c') suivant les méthodes d'obtention des centres de
    % gravité choisies : m -> automatique + ajout manuel ou f -> fitting polynomial
    
tablecmf=[];
tablecfm=[];
tablecff=[];

    % Variables de stockage des centres de gravité après correction ('c') suivant les méthodes d'obtention des centres de
    % gravité choisies 
    
CGTcmf=[];
CGTcmm=[];
CGTcfm=[];
CGTcff=[];

%% Validation de la correction sur les images corrigées après détection
%% automatique + ajout manuel des centres de gravité  %%

        name1='Corrigées_manuel\TRS.';
        name3='.dcm';

for cp = 1:62
%         cp=35;
        name=strcat(name1,int2str(cp),name3);
        
    if exist(name)~=0
        
        % Calcul erreurs résiduelles sur images corrigées manuelles : détection manuelle et fit 
        
        [Cgc,Imac] = detection_TRS(name,cp);
        [Cgct,PIc] = tri_TRS(Imac,Cgc);  
        
        % détection auto + manuelle
            
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

%% Validation de la correction sur les images corrigées après obtention des
%% centres de gravité par fitting polynomial  %%

        name1='Corrigées_fit\TRS.';
        name3='.dcm';
        
for cp=1:62
        
%         cp=29;
        name=strcat(name1,int2str(cp),name3);
        
    if exist(name)~=0
        
        % Calcul erreurs résiduelles sur images corrigées fit : détection manuelle et fit 
        
        [Cgc,Imac] = detection_TRS(name,cp);
        [Cgct,PIc] = tri_TRS(Imac,Cgc);  
        
        % détection auto + manuelle
            
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


