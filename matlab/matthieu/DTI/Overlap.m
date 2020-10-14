function Overlap(indir, subjects, outdir)


%% Read list of subjects
fid = fopen(fullfile(indir,[subjects '.txt']), 'r');
T = textscan(fid,'%s','delimiter','\n');
SubjectsNames = T{1};
nSubjects = length(SubjectsNames); 
fclose(fid);

clear T fid;

%% Calcul Jaccard index and overlap coefficient between all subjects

InterSubjectsN11 = spm_read_vols(spm_vol(fullfile(outdir,SubjectsNames{1},'dti/bwThresh_Prob_G_postcentral_CC.nii')));
UnionSubjectsN11 = InterSubjectsN11;
MinSubjectsN11 = length(find(InterSubjectsN11 == 1));

InterSubjectsN12 = spm_read_vols(spm_vol(fullfile(outdir,SubjectsNames{1},'dti/bwThresh_Prob_G_temp_sup_lateral_CC.nii')));
UnionSubjectsN12 = InterSubjectsN12;
MinSubjectsN12 = length(find(InterSubjectsN12 == 1));

InterSubjectsN13 = spm_read_vols(spm_vol(fullfile(outdir,SubjectsNames{1},'dti/bwThresh_Prob_precentral_CC.nii')));
UnionSubjectsN13 = InterSubjectsN12;
MinSubjectsN13 = length(find(InterSubjectsN12 == 1));

InterSubjectsN14 = spm_read_vols(spm_vol(fullfile(outdir,SubjectsNames{1},'dti/bwThresh_Prob_S_calcarine_CC.nii')));
UnionSubjectsN14 = InterSubjectsN12;
MinSubjectsN14 = length(find(InterSubjectsN12 == 1));

for i = 1 : nSubjects
    V = spm_vol(fullfile(outdir,SubjectsNames{i},'dti/bwThresh_Prob_G_postcentral_CC.nii'));
    [labels, XYZ] = spm_read_vols(V);
    InterSubjects1 = (InterSubjectsN11&labels);
    UnionSubjects1 = (UnionSubjectsN11|labels);
    MinSubjects1 = min(MinSubjectsN11,length(find(labels == 1)));
    InterSubjectsN11 = InterSubjects1;
    UnionSubjectsN11 = UnionSubjects1;
    MinSubjectsN11 = MinSubjects1;
    
    V = spm_vol(fullfile(outdir,SubjectsNames{i},'dti/bwThresh_Prob_G_temp_sup_lateral_CC.nii'));
    [labels, XYZ] = spm_read_vols(V);
    InterSubjects2 = (InterSubjectsN12&labels);
    UnionSubjects2 = (UnionSubjectsN12|labels);
    MinSubjects2 = min(MinSubjectsN12,length(find(labels == 1)));
    InterSubjectsN12 = InterSubjects2;
    UnionSubjectsN12 = UnionSubjects2;  
    MinSubjectsN12 = MinSubjects2;

    V = spm_vol(fullfile(outdir,SubjectsNames{i},'dti/bwThresh_Prob_precentral_CC.nii'));
    [labels, XYZ] = spm_read_vols(V);
    InterSubjects3 = (InterSubjectsN13&labels);
    UnionSubjects3 = (UnionSubjectsN13|labels);
    MinSubjects3 = min(MinSubjectsN13,length(find(labels == 1)));
    InterSubjectsN13 = InterSubjects3;
    UnionSubjectsN13 = UnionSubjects3; 
    MinSubjectsN13 = MinSubjects3;
    
    V = spm_vol(fullfile(outdir,SubjectsNames{i},'dti/bwThresh_Prob_S_calcarine_CC.nii'));
    [labels, XYZ] = spm_read_vols(V);
    InterSubjects4 = (InterSubjectsN14&labels);
    UnionSubjects4 = (UnionSubjectsN14|labels);
    MinSubjects4 = min(MinSubjectsN14,length(find(labels == 1)));
    InterSubjectsN14 = InterSubjects4;
    UnionSubjectsN14 = UnionSubjects4; 
    MinSubjectsN14 = MinSubjects4;
end

clear V labels XYZ;

Inter1 = length(find(InterSubjects1 == 1));
Union1 = length(find(UnionSubjects1 == 1));

Inter2 = length(find(InterSubjects2 == 1));
Union2 = length(find(UnionSubjects2 == 1));

Inter3 = length(find(InterSubjects3 == 1));
Union3 = length(find(UnionSubjects3 == 1));

Inter4 = length(find(InterSubjects4 == 1));
Union4 = length(find(UnionSubjects4 == 1));

JaccardIndex1 = Inter1/Union1;
JaccardIndex2 = Inter2/Union2;
JaccardIndex3 = Inter3/Union3;
JaccardIndex4 = Inter4/Union4;

OverlapCoeff1 = Inter1/MinSubjects1;
OverlapCoeff2 = Inter2/MinSubjects2;
OverlapCoeff3 = Inter3/MinSubjects3;
OverlapCoeff4 = Inter4/MinSubjects4;

fid = fopen(fullfile(outdir, [ 'Overlap_' subjects '.txt']), 'w');
fprintf(fid, '%s\n %s %d\t %s %d\n %s %d\t %s %d\n\n', 'G_postcentral', 'Nb voxels intersection :',Inter1,'Nb voxels union :',Union1,'JaccardIndex :',JaccardIndex1, 'OverlapCoeff :', OverlapCoeff1);
fprintf(fid, '%s\n %s %d\t %s %d\n %s %d\t %s %d\n\n', 'G_temp_sup_lateral','Nb voxels intersection :',Inter2,'Nb voxels union :',Union2, 'JaccardIndex :',JaccardIndex2, 'OverlapCoeff :', OverlapCoeff2);
fprintf(fid, '%s\n %s %d\t %s %d\n %s %d\t %s %d\n\n', 'precentral','Nb voxels intersection :',Inter3,'Nb voxels union :',Union3, 'JaccardIndex :',JaccardIndex3, 'OverlapCoeff :', OverlapCoeff3);
fprintf(fid, '%s\n %s %d\t %s %d\n %s %d\t %s %d', 'S_calcarine','Nb voxels intersection :',Inter4,'Nb voxels union :',Union4, 'JaccardIndex :',JaccardIndex4, 'OverlapCoeff :', OverlapCoeff4);
fclose(fid);