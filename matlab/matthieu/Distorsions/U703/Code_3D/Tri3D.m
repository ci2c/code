function CGt = Tri3D(CG)

CG = sortrows(CG,1);
CGt = [];
tmp = [];
FirstPlan = 182;
SecondPlan = 210;
NormalPlan = 238;
NbColFstPlan = 13;
NbColSdPlan = 15;
NbColNormalPlan = 17;

plan = cell(1,15);             
ligne = cell(14,15);   

% Construction des plans sagittaux et des lignes de chaque plan triées
% suivant x puis z croissant

for i=1:length(plan)
    if (i==1) || (i==length(plan))
        plan{i} = CG((size(tmp,1)+1):(size(tmp,1)+FirstPlan),:);
    elseif (i==2) || (i==(length(plan)-1))
        plan{i} = CG((size(tmp,1)+1):(size(tmp,1)+SecondPlan),:); 
    else
        plan{i} = CG((size(tmp,1)+1):(size(tmp,1)+NormalPlan),:); 
    end
    plan{i} = sortrows(plan{i},3);           % Formation des lignes suivant z croissant dans les plans sagittaux formés
    tmp = [tmp ; plan{i}];
end

for i=1:length(plan)
    for k=1:size(ligne,1)  
        if (i==1) || (i==size(ligne,2))
            ligne{k,i} = plan{i}(((k-1)*NbColFstPlan+1):k*NbColFstPlan,:);    % Récupération des lignes
        elseif (i==2) || (i==(size(ligne,2)-1))
            ligne{k,i} = plan{i}(((k-1)*NbColSdPlan+1):k*NbColSdPlan,:);
        else
            ligne{k,i} = plan{i}(((k-1)*NbColNormalPlan+1):k*NbColNormalPlan,:);
        end
        ligne{k,i} = sortrows(ligne{k,i},2);        % Tri selon y croissant
        CGt = [CGt ; ligne{k,i}];
    end
end