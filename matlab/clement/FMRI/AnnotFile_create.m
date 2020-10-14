function FMRI_Mod_AnnotationFile_Creat(file,thresVal,outDir)
%% CONFIG

%load colormap and community file
load('/NAS/tupac/protocoles/Strokdem/color_map_Mod.mat');
load(file);

label_dir    = '/NAS/tupac/protocoles/Strokdem/Sujets_Sains/FS53/fsaverage/label';

nodes={};
nodes{end+1} = textread(fullfile('/NAS/tupac/protocoles/Strokdem/test/test_nodes_names.txt'),'%s','delimiter','\n','whitespace','');


%% Colormap and community vector set up
colormap=[colormap(2:42,:);colormap(44:end,:)];
Colormap.lh=colormap;
Colormap.rh=colormap;

Cort_co=co(17:end);
Co.lh=Cort_co(1:74);
Co.rh=Cort_co(75:end);

Comm.lh=unique(Co.lh);
Comm.rh=unique(Co.rh);

clear Components

%% Colormap Modifications
field=fieldnames(Comm);

% Loop for hemisphere
for k=1:length(fieldnames(Comm))
    
    X=Comm.(cell2mat(field(k)));
    
    % Loop for components
    for f = 1:length(X)
    id = find(Co.(cell2mat(field(k))) == X(f));
            %Loop for components ID
            temp_colormap=Colormap.(cell2mat(field(k)));
            for j = 1:length(id) 
                temp_colormap(id(j),:)=[0 0 255 0];
            end
            grey=[160 160 160 0];
            final_colormap=[grey;temp_colormap(1:42,:);grey;temp_colormap(43:end,:)]; %Add Unknown and Medial Wall
            Components.(cell2mat(field(k))).(strcat('ID',num2str(X(f))))=final_colormap;
    end   
end

clear field i j k f z 
%% Final file creation
nodes={};
nodes{end+1}=textread(fullfile('/NAS/tupac/protocoles/Strokdem/test/test_nodes_names.txt'),'%s','delimiter','\n','whitespace','');

Hemi=fieldnames(Components);

for i=1:length(Hemi)
    
    field=fieldnames(Components.(cell2mat(Hemi(i))));
    
    for k =1:length(field)
    
        Y=Components.(cell2mat(Hemi(i))).(cell2mat(field(k)));
    
        fid = fopen(fullfile(outDir,[ cell2mat(Hemi(i)) '-' cell2mat(field(k)) '-' num2str(thresVal) '.ctab.csv']),'w');
        for j=1:length(Y)
            fprintf(fid,'%s %s',nodes{1}{j});
            fprintf(fid,'%.0f %.0f %.0f %.0f',Y(j,:));
            fprintf(fid,'\n');
        end
        fclose(fid);
        replace_ctab(fullfile(label_dir,[ cell2mat(Hemi(i)) '.aparc.a2009s.annot']),fullfile(outDir,[ cell2mat(Hemi(i)) '-' cell2mat(field(k)) '-' num2str(thresVal) '.ctab.csv']),fullfile(outDir,[ cell2mat(Hemi(i)) '-' cell2mat(field(k)) '-' num2str(thresVal) '.annot']));
        cmd = sprintf('rm -rf %s',fullfile(outDir,[ cell2mat(Hemi(i)) '-' cell2mat(field(k)) '-' num2str(thresVal) '.ctab.csv']));
        unix(cmd);
    end
end
    
fclose all;