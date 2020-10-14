function Cgt = Tri_AXIAL(Cg)
 
Cgt = [];               % Final sorted control points
ligne = cell(11,1);     % Create vecorized cells, each containing a line of control points of the phantom
Cgl = sortrows(Cg,2);   % Rising sort of control points according lines 
FirstLine = 7;
SndThirdLine = 9;
CentralLine = 10;
NormalLine = 11;
LastLine = 3;

%% Compute lines of the phantom sorted by rising order, then control points
%% sorted by rising order inside a line %%

for l=1:length(ligne)
    if (l == 2) || (l == 10)
        ligne{l} = Cgl((length(Cgt)+1):(length(Cgt)+FirstLine),:);
    elseif (l == 3) || (l == 4) || (l == 8) || (l == 9)
        ligne{l} = Cgl((length(Cgt)+1):(length(Cgt)+SndThirdLine),:);
    elseif (l == 1) || (l == length(ligne))
        ligne{l} = Cgl((length(Cgt)+1):(length(Cgt)+LastLine),:);
    elseif (l == 6)
        ligne{l} = Cgl((length(Cgt)+1):(length(Cgt)+CentralLine),:);
    else
        ligne{l} = Cgl((length(Cgt)+1):(length(Cgt)+NormalLine),:);
    end
    ligne{l} = sortrows(ligne{l});
    Cgt = [Cgt ; ligne{l}];
end

% figure (15)
% plot(Cgt(:,1),Cgt(:,2),'.');