% Performs stats

% % clear singleton
% for i = 1 : length(unique_subj)
%     j = find( strcmp(subj_list_table, unique_subj{i}) );
%     if length(j) == 1
%         subj_list_table(j) = [];
%         subj_age_table(j) = [];
%         subj_gender_table(j) = [];
%         subj_group_table(j) = [];
%         thickness_lh_table(j, :) = [];
%         thickness_rh_table(j, :) = [];
%     end
% end

Age = term(subj_age_table);
Gender = term(subj_gender_table);
% Group = term(subj_group_table);
% Subj = term(subj_list_table);
% ISI = term(interscan_interval);

% M = 1 + Age + Gender + Group + (1 + Age) * random(Subj) + I;
% M = 1 + Age + Gender + Group + random(Subj) + I;
% M = 1 + ISI + Group + ISI*Group + random(Subj) + I;
% M = 1 + Group * ISI + Age;
M = 1 + Age + Gender;
image( M );

% slm = SurfStatLinMod([thickness_lh_table, thickness_rh_table], M, Surf);

% contrast = interscan_interval.*Group.T - interscan_interval.*Group.S - interscan_interval.*Group.PS;
% contrast = Group.T - Group.S;
% % contrast = -interscan_interval;
% 
% slm = SurfStatT(slm, contrast);
% 
% [pval, peak, clus] = SurfStatP(slm, Mask, 0.005);