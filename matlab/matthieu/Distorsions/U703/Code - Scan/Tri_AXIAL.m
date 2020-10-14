function Cgt = Tri_AXIAL(Ima,Cg)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Tri des centres de gravités détectés selon y
    %% croissant puis x croissant
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
Cgt = [];               % Centres de gravités triés finaux
ligne = cell(17,1);      % Création d'une cellule constituée des lignes
Cgl = sortrows(Cg,2);   % tri croissant des centres de gravité selon les lignes 
FirstLine = 11;
SecondLine = 13;
NormalLine = 15;

% Construction des lignes triées par ordre croissant et des centres de
% gravité  triés

for l=1:length(ligne)
    if (l == 1) || (l == length(ligne))
        ligne{l} = Cgl((length(Cgt)+1):(length(Cgt)+FirstLine),:);
    elseif (l == 2) || (l == (length(ligne)-1))
        ligne{l} = Cgl((length(Cgt)+1):(length(Cgt)+SecondLine),:);
    else
        ligne{l} = Cgl((length(Cgt)+1):(length(Cgt)+NormalLine),:);
    end
    ligne{l} = sortrows(ligne{l});
    Cgt = [Cgt ; ligne{l}];
end

%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %% Obtention des centres de gravité par fit polynomial du 3eme ordre à
%     %% partir des centres de gravité détectés. Tri
%     %% par la suite de ces nouveaux centres de gravité selon y puis x
%     %% croissants
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     
% Cgc=sortrows(Cg);       % tri croissant des centres de gravité selon les colonnes
% FirstCol = 13;
% SecondCol = 15;
% NormalCol = 17;
% colonne = cell(1,15);   % Création d'une cellule constituée des colonnes
% Cgtmp=[];
% 
% % Construction des colonnes
% 
% for c=1:length(colonne)
%     if (c == 1) || (c == length(colonne))
%         colonne{c} = Cgc((length(Cgtmp)+1):(length(Cgtmp)+FirstCol),:);
%     elseif (c == 2) || (c == (length(colonne)-1))
%         colonne{c} = Cgc((length(Cgtmp)+1):(length(Cgtmp)+SecondCol),:);
%     else
%         colonne{c} = Cgc((length(Cgtmp)+1):(length(Cgtmp)+NormalCol),:);
%     end
%     Cgtmp = [Cgtmp ; colonne{c}];
% end
% 
% % Approximation polynomiale sur les lignes et colonnes
% 
%     % Fit sur les lignes
% 
% pl = cell(length(ligne),1);
% fl = cell(length(ligne),1);
% for i=1:length(ligne)
%     ligne{i} = sortrows(ligne{i});
%     pl{i} = polyfit(ligne{i}(:,1),ligne{i}(:,2),3);
%     fl{i} = polyval(pl{i},[min(Cg(:,1))-1;ligne{i}(:,1);max(Cg(:,1))+1]);
% end
% 
%     % Fit sur les colonnes
%     
% pc = cell(1,length(colonne));
% fc = cell(1,length(colonne));
% for i=1:length(colonne)
%     colonne{i}= sortrows(colonne{i},2);
%     pc{i} = polyfit(colonne{i}(:,2),colonne{i}(:,1),3);
%     fc{i} = polyval(pc{i},[min(Cg(:,2))-1;colonne{i}(:,2);max(Cg(:,2))+1]);
% end
% 
% figure (6)
% imshow(Ima,[],'InitialMagnification','fit');hold on;
% for i=1:length(ligne)
%     plot([min(Cg(:,1))-1;ligne{i}(:,1);max(Cg(:,1))+1],fl{i},'-r','LineWidth',1);
% end
% for i=1:length(colonne)
%     plot(fc{i},[min(Cg(:,2))-1;colonne{i}(:,2);max(Cg(:,2))+1],'-g','LineWidth',1);
% end
% 
% 
% % Récupération des points d'intersection des courbes d'approximation
% % polynomiale : nouveaux centres de gravité obtenus 
% 
% Trous=false(length(ligne),length(colonne));
% PI = [];                    % Récupération de tous les points d'intersection
% for i=1:length(ligne)
%     for j=1:length(colonne)
%         [X0,Y0] = intersections(fc{j},[min(Cg(:,2))-1;colonne{j}(:,2);max(Cg(:,2))+1],[min(Cg(:,1))-1;ligne{i}(:,1);max(Cg(:,1))+1],fl{i});
%         PI= [PI;X0 Y0];     % triage croissant sur les lignes
%     end
% end
% % IndexVides = [1;2;14;15;16;30;226;240;241;242;254];
% % PI(IndexVides,:) = [];
% plot(PI(:,1),PI(:,2),'.w','MarkerSize',12);
% hold off