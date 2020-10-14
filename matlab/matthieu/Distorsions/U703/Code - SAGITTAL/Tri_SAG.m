function Cgt = Tri_SAG(Ima,Cg)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Tri des centres de gravités détectés selon z
    %% croissant puis y croissant
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Cgt = [];               % Centres de gravités triés finaux
ligne = cell(14,1);      % Création d'une cellule constituée des lignes
Cgl = sortrows(Cg,2);   % tri croissant des centres de gravité selon les lignes 
FirstPlan = 182;
SecondPlan = 210;

% Construction des lignes triées par ordre croissant et des centres de
% gravité triés

for l=1:length(ligne)    % Tri suivant z croissant (orientation ligne -1 dans Orientation Patient) 
    if (size(Cgl,1)==FirstPlan)
        ligne{l} = Cgl((length(Cgt)+1):(length(Cgt)+13),:);
    elseif (size(Cgl,1)==SecondPlan)
        ligne{l} = Cgl((length(Cgt)+1):(length(Cgt)+15),:);
    else
        ligne{l} = Cgl((length(Cgt)+1):(length(Cgt)+17),:);
    end
    ligne{l} = sortrows(ligne{l});
    Cgt=[Cgt ; ligne{l}];
end