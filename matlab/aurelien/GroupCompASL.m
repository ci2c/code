Surf = SurfStatReadSurf({'../lh.pial', '../rh.pial'});
load medial_wall

% Thickness_lh_list = SurfStatListDir('cont*lh.thickness*20*');
% Thickness_rh_list = SurfStatListDir('cont*rh.thickness*20*');
% 
% Data_lh = SurfStatReadData(Thickness_lh_list);
% Data_rh = SurfStatReadData(Thickness_rh_list);
% 
% Data = [Data_lh, Data_rh];
% 
% Group = repmat({'brux'}, 19, 1);
% Group = cat(1, Group, repmat({'lille'}, 9, 1));
% 
% group = term(Group);
% M = 1 + group;
% 
% slm = SurfStatLinMod(Data, M, Surf);
% 
% contrast = group.brux - group.lille;
% 
% slm = SurfStatT(slm, contrast);
% 
% [pval, peak, clus] = SurfStatP(slm, ~Mask);



% Controls = SurfStatListDir('cont*lh.thickness*20*');
% Patients = SurfStatListDir('patient*lh.thickness*20*');
% 
% Thickness_lh_list = SurfStatListDir('*lh.thickness*20*');
% Thickness_rh_list = SurfStatListDir('*rh.thickness*20*');
% 
% Data_lh = SurfStatReadData(Thickness_lh_list);
% Data_rh = SurfStatReadData(Thickness_rh_list);
% 
% Data = [Data_lh, Data_rh];
% 
% Group = repmat({'control'}, size(Controls, 1), 1);
% Group = cat(1, Group, repmat({'patient'}, size(Patients, 1), 1));
% 
% group = term(Group);
% 
% M = 1 + group;
% 
% slm = SurfStatLinMod(Data, M, Surf);
% 
% contrast = group.control - group.patient;
% 
% slm = SurfStatT(slm, contrast);
% 
% [pval, peak, clus] = SurfStatP(slm, ~Mask);
% 
% SurfStatView(pval, Surf, 'p-val')
% 
% % z-score stuff
% Mean = mean(Data(group.control==1, :));
% Std = std(Data(group.control==1, :));
% 
% Atro = zeros(size(Mean));
% F = find(group.patient==1);
% for i = 1 : length(F)
%     Zs = (Data(F(i), :) - Mean) ./ Std;
%     Zs(isnan(Zs)) = 0;
%     Zs(isinf(Zs)) = 0;
%     Atro(Zs < -2) = Atro(Zs < -2) + 1;
%     % figure, SurfStatViewData(Zs .* (abs(Zs) > 2), Surf, num2str(i));
%     % SurfStatColLim([-5, 5]);
% end
% 
% Atro = 100 .* Atro ./ length(F);

Controls = SurfStatListDir('cont*lh*complexity*25*');
Patients = SurfStatListDir('patient*lh*complexity*25*');

Complexity_lh_list = SurfStatListDir('*lh.*complexity*25*');
Complexity_rh_list = SurfStatListDir('*rh.*complexity*25*');

Data_lh = SurfStatReadData(Complexity_lh_list);
Data_rh = SurfStatReadData(Complexity_rh_list);

Data = [Data_lh, Data_rh];

Group = repmat({'control'}, size(Controls, 1), 1);
Group = cat(1, Group, repmat({'patient'}, size(Patients, 1), 1));

group = term(Group);
M = 1 + group;

slm = SurfStatLinMod(Data, M, Surf);

contrast = (group.control - group.patient);

slm = SurfStatT(slm, contrast);
[pval, peak, clus] = SurfStatP(slm, ~Mask);

% z-score stuff
Mean = mean(Data(group.control==1, :));
Std = std(Data(group.control==1, :));

Atro = zeros(size(Mean));
F = find(group.patient==1);
for i = 1 : length(F)
    Zs = (Data(F(i), :) - Mean) ./ Std;
    Zs(isnan(Zs)) = 0;
    Zs(isinf(Zs)) = 0;
    Atro(abs(Zs) > 2) = Atro(abs(Zs) > 2) + 1;
    % figure, SurfStatViewData(Zs .* (abs(Zs) > 2), Surf, num2str(i));
    % SurfStatColLim([-5, 5]);
end

Atro = 100 .* Atro ./ length(F);

% 
% SurfStatView(pval, Surf, 'p-val')