clear all; close all;

% Scans = dir_wfp('/home/matthieu/programs/GLM_Flex/ExampleVolumes/*.nii');
Scans = { '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/2506DR/spm/FirstLevel/con_0001.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/2506DR/spm/FirstLevel/con_0002.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/2506DR/spm/FirstLevel/con_0003.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/2506BB/spm/FirstLevel/con_0001.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/2506BB/spm/FirstLevel/con_0002.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/2506BB/spm/FirstLevel/con_0003.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/2506CN/spm/FirstLevel/con_0001.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/2506CN/spm/FirstLevel/con_0002.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/2506CN/spm/FirstLevel/con_0003.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/2304DP/spm/FirstLevel/con_0001.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/2304DP/spm/FirstLevel/con_0002.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/2304DP/spm/FirstLevel/con_0003.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/2304GG/spm/FirstLevel/con_0001.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/2304GG/spm/FirstLevel/con_0002.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/2304GG/spm/FirstLevel/con_0003.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/0309JAR/spm/FirstLevel/con_0001.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/0309JAR/spm/FirstLevel/con_0002.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/0309JAR/spm/FirstLevel/con_0003.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/0309NP/spm/FirstLevel/con_0001.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/0309NP/spm/FirstLevel/con_0002.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/0309NP/spm/FirstLevel/con_0003.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/0309JD/spm/FirstLevel/con_0001.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/0309JD/spm/FirstLevel/con_0002.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/0309JD/spm/FirstLevel/con_0003.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/0309DK/spm/FirstLevel/con_0001.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/0309DK/spm/FirstLevel/con_0002.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/0309DK/spm/FirstLevel/con_0003.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/2506PE/spm/FirstLevel/con_0001.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/2506PE/spm/FirstLevel/con_0002.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/2506PE/spm/FirstLevel/con_0003.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/2506WP/spm/FirstLevel/con_0001.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/2506WP/spm/FirstLevel/con_0002.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/2506WP/spm/FirstLevel/con_0003.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/2506LM/spm/FirstLevel/con_0001.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/2506LM/spm/FirstLevel/con_0002.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/2506LM/spm/FirstLevel/con_0003.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/2304ON/spm/FirstLevel/con_0001.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/2304ON/spm/FirstLevel/con_0002.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/2304ON/spm/FirstLevel/con_0003.img';          
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/2304KN/spm/FirstLevel/con_0001.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/2304KN/spm/FirstLevel/con_0002.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/2304KN/spm/FirstLevel/con_0003.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/2304MF/spm/FirstLevel/con_0001.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/2304MF/spm/FirstLevel/con_0002.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/2304MF/spm/FirstLevel/con_0003.img';  
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/2304CC/spm/FirstLevel/con_0001.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/2304CC/spm/FirstLevel/con_0002.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/2304CC/spm/FirstLevel/con_0003.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/2304RM/spm/FirstLevel/con_0001.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/2304RM/spm/FirstLevel/con_0002.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/2304RM/spm/FirstLevel/con_0003.img'; 
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/2105FB-0309/spm/FirstLevel/con_0001.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/2105FB-0309/spm/FirstLevel/con_0002.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/2105FB-0309/spm/FirstLevel/con_0003.img'; 
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/0309GV/spm/FirstLevel/con_0001.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/0309GV/spm/FirstLevel/con_0002.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/0309GV/spm/FirstLevel/con_0003.img'; 
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/0309GS/spm/FirstLevel/con_0001.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/0309GS/spm/FirstLevel/con_0002.img';
          '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/0309GS/spm/FirstLevel/con_0003.img'; 
       };

clear IN; clear F; clear I;
IN.N_subs       = [9 11];
IN.Between      = [1 2];  % The 1 here is so we can run a one sample t-test across all the data
IN.BetweenLabs  = {{'Patients'} {'GroupeA', 'GroupB'}};
IN.Within       = [3];
IN.WithinLabs   = {{'J' 'N' 'C'}};
IN.FactorLabs   = {'F1' 'F2' 'F3'};
IN.Interactions = {[2 3]};
IN.EqualVar     = [1 0 0];
IN.Independent  = [1 1 0];

F = CreateDesign(IN);
figure(1); imagesc(F.XX); shg

I.OutputDir = '/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages/GLM_Flex/mixedDesignAnova';
I.F = F;
I.Scans = Scans;
I.RemoveOutliers = 0;
I.minN = 2;
I.DoOnlyAll = 1;
I.CompOpt=1;


I = GLM_Flex(I);

%%
I.Cons(1).name = 'Patients';
I.Cons(1).Groups = {1};
I.Cons(1).Levs = [1];
I.Cons(1).ET = [];
I.Cons(1).mean = 0;

I.Cons(2).name = 'Group Effect';
I.Cons(2).Groups = {2 3};
I.Cons(2).Levs = [2];
I.Cons(2).ET = [];
I.Cons(2).mean = 0;

I.Cons(3).name = 'Conditions Effect';
I.Cons(3).Groups = {4 5 6};
I.Cons(3).Levs = [3];
I.Cons(3).ET = [];
I.Cons(3).mean = 0;

I.Cons(4).name = 'Group by Conditions';
I.Cons(4). Groups = {7 8 9 10 11 12};
I.Cons(4).Levs = [2 3];
I.Cons(4).ET = [];
I.Cons(4).mean = 0;

I.Cons(5).name = 'Condition J Vs N+C';
I.Cons(5). Groups = {4 5:6};
I.Cons(5).Levs = [2];
I.Cons(5).ET = [];
I.Cons(5).mean = 0;

I.Cons(6).name = 'Condition N Vs J+C';
I.Cons(6). Groups = {5 [4 6]};
I.Cons(6).Levs = [2];
I.Cons(6).ET = [];
I.Cons(6).mean = 0;

I.Cons(7).name = 'Condition C Vs J+N';
I.Cons(7). Groups = {4:5 6};
I.Cons(7).Levs = [2];
I.Cons(7).ET = [];
I.Cons(7).mean = 0;

I.Cons(8).name = 'Group by Condition J Vs N+C';
I.Cons(8). Groups = {[7 8:9] [10 11:12]};
I.Cons(8).Levs = [2];
I.Cons(8).ET = [];
I.Cons(8).mean = 0;

I.Cons(9).name = 'Group by Condition N Vs J+C';
I.Cons(9). Groups = {[8 [7 9]] [11 [10 12]]};
I.Cons(9).Levs = [2];
I.Cons(9).ET = [];
I.Cons(9).mean = 0;

I.Cons(10).name = 'Group by Condition C Vs J+N';
I.Cons(10). Groups = {[6:7 9] [10:11 12]};
I.Cons(10).Levs = [2];
I.Cons(10).ET = [];
I.Cons(10).mean = 0;

I = GLM_Flex_Contrasts(I);