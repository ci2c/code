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

% Select = (strcmp(subj_group_table, 'PS') + strcmp(subj_group_table, 'S')) ~= 0;

% subj_age_table_select = subj_age_table(Select);
% subj_gender_table_select = subj_gender_table(Select);
% subj_group_table_select = subj_group_table(Select);

Thickness = [thickness_lh_table, thickness_rh_table];
% Thickness = Thickness(Select, :);


Age = term(subj_age_table);
Gender = term(subj_gender_table);
Group = term(subj_group_table);
Vol_lhyp = term(subj_lhyp_vol);
Vol_rhyp = term(subj_rhyp_vol);

M = 1 + Age + Gender + Vol_lhyp + Vol_rhyp;

slm = SurfStatLinMod(Thickness, M, Surf);

% contrast = Gender.M - Gender.F;
% 
% slm = SurfStatT(slm, contrast);
slm = SurfStatT( slm, -subj_age_table ); 
figure(1)
SurfStatView( slm.t.*Mask, Surf, 'T (24 df) for -age removing gender' );
% SurfStatView( slm.t.*Mask, Surf, 'T (24 df) for males-females removing age' ); 

Yseed = double( Thickness(:, 213254) ); 
figure(2)
subplot(1,2,1)
SurfStatPlot( subj_age_table, Yseed, subj_gender_table );
subplot(1,2,2)
SurfStatPlot( subj_age_table, Yseed, 1, subj_gender_table );

% resels = SurfStatResels( slm, Mask );
% stat_threshold( resels, length(slm.t), 1, slm.df );

% [pval, peak, clus] = SurfStatP(slm, Mask, 0.005);
% figure(2)
% SurfStatView( pval, Surf, 'Males-females removing age' );

slm = SurfStatLinMod( Thickness, 1 + Age + Gender + Age*Gender, Surf );
slm = SurfStatT( slm, subj_age_table.*Gender.M - subj_age_table.*Gender.F ); 
figure(3)
SurfStatView( slm.t.*Mask, Surf, 'T (24 df) for age*(male-female)' );