clear all;
close all;

%% Création de variables %%

    % Tables de valeurs statistiques de déformations après correction ('c') suivant les méthodes d'obtention des centres de
    % gravité choisies : m -> automatique + ajout manuel ou f -> fitting
    % polynomial
    
tablecmm=[];
tablecmf=[];
tablecfm=[];
tablecff=[];

    % Variables de stockage des centres de gravité après correction ('c') suivant les méthodes d'obtention des centres de
    % gravité choisies 
    
CGScmf=[];
CGScmm=[];
CGScfm=[];
CGScff=[];

%% Validation de la correction sur les images corrigées après détection
%% automatique + ajout manuel des centres de gravité  %%

        name1='Corrigées_manuel\SAG.';
        name3='.dcm';

for cp = 1:68
%         cp=35;
        name=strcat(name1,int2str(cp),name3);
        
    if exist(name)~=0
        
        % Calcul erreurs résiduelles sur images corrigées manuelles : détection manuelle et fit 
        
        [Cgc,Imac] = detection_SAG(name,cp);
        [Cgct,PIc] = tri_SAG(Imac,Cgc);  
        
        % détection auto + manuelle
            
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

%% Validation de la correction sur les images corrigées après obtention des
%% centres de gravité par fitting polynomial  %%

        name1='Corrigées_fit\SAG.';
        name3='.dcm';
        
for cp=1:68
        
%         cp=35;
        name=strcat(name1,int2str(cp),name3);
        
    if exist(name)~=0
        
        % Calcul erreurs résiduelles sur images corrigées fit : détection manuelle et fit 
        
        [Cgc,xyc] = detection_SAG(name,cp);
        [Cgct,PIc] = tri_SAG(Cgc,xyc);  
        
        % détection auto + manuelle
            
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


