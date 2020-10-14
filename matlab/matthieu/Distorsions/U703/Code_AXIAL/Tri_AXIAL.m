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
% gravité triés

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