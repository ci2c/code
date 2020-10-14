function Cgt = Tri_COR(Ima,Cg)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Tri des centres de gravités détectés selon y
    %% croissant puis x croissant
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
Cgt = [];               % Centres de gravités triés finaux
ligne = cell(14,1);      % Création d'une cellule constituée des lignes
Cgl = sortrows(Cg,2);   % tri croissant des centres de gravité selon les lignes z
FirstPlan = 154;
SecondPlan = 182;
NormalPlan = 210;

% Construction des lignes triées par ordre croissant et des centres de
% gravité triés

for l=1:length(ligne)
    if (size(Cgl,1)==FirstPlan)
        ligne{l} = Cgl((length(Cgt)+1):(length(Cgt)+11),:);
    elseif (size(Cgl,1)==SecondPlan)
        ligne{l} = Cgl((length(Cgt)+1):(length(Cgt)+13),:);
    else
        ligne{l} = Cgl((length(Cgt)+1):(length(Cgt)+15),:);
    end
    ligne{l} = sortrows(ligne{l});
    Cgt = [Cgt ; ligne{l}];
end