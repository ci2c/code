function Create_AnnotationFile(matrix,outDir,MeasName,NodesFile)
%% CONFIG

%load colormap and community file
load('/NAS/tupac/protocoles/Strokdem/colormap.mat');
label_dir    = '/NAS/tupac/protocoles/Strokdem/Sujets_Sains/FS53/fsaverage/label';

nodes={};
nodes{end+1} = textread(NodesFile,'%s','delimiter','\n','whitespace','');


%% Colormap and scalar vector set up

matrix=matrix(17:end);

val.lh=matrix(1:74);
val.rh=matrix(75:end);

rank=0:1:100;
scalar=zeros(100,1);
for i=1:100
    scalar(i)=max([max(val.lh),max(val.rh)])*rank(i)/100;
end


%% Colormap Modifications
field=fieldnames(val);

% Loop for hemisphere
for k=1:length(fieldnames(val))
    
    X=val.(cell2mat(field(k)));
    tmp=zeros(length(X),3);
    % Loop for components
    for f = 1:length(X)
        range=scalar(2)-scalar(1);
        ID=[];
        z=1;
        while length(ID) == 0
            if z == length(scalar)
                ID = z; 
            else 
                if X(f) >= scalar(z) & X(f) <= scalar(z+1);
                    AC= X(f)-scalar(z);
                    BC= scalar(z+1)-X(f);
                    if AC > BC;
                        ID = z+1;
                    else AC < BC;
                        ID = z;
                    end  
                end
        z=z+1;
            end
        end 
        tmp(f,:) = colormap(ID,:);
    end
    grey=[160 160 160 0];
    tmp=[tmp,zeros(f,1)];
    final_colormap.(cell2mat(field(k)))=[grey;tmp(1:41,:);grey;tmp(42:end,:)]; %Add Unknown and Medial Wall
end

clear field i j k f z 
%% Final file creation
Hemi=fieldnames(final_colormap);

for i=1:length(Hemi)

    Y=final_colormap.(cell2mat(Hemi(i)));
    
    fid = fopen(fullfile(outDir,[ cell2mat(Hemi(i)) '-' MeasName '.ctab.csv']),'w');
        for j=1:length(Y)
            fprintf(fid,'%s %s',nodes{1}{j});
            fprintf(fid,'%.0f %.0f %.0f %.0f',Y(j,:));
            fprintf(fid,'\n');
        end
        fclose(fid);
        
        label_orig=fullfile(label_dir,[ cell2mat(Hemi(i)) '.aparc.a2009s.annot']);
        csv_file=fullfile(outDir,[ cell2mat(Hemi(i)) '-' MeasName '.ctab.csv']);
        new_label=fullfile(outDir,[ cell2mat(Hemi(i)) '-' MeasName '.annot']);
        
        replace_ctab(label_orig,csv_file,new_label);
        cmd = sprintf('rm -rf %s',fullfile(outDir,[ cell2mat(Hemi(i)) '-' MeasName '.ctab.csv']));
        unix(cmd);
end
    
fclose all;