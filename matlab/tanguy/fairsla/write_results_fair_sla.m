function write_results_fair_sla(sd,subj,stats)

fid = fopen(fullfile(sd,subj,'/mri/results.txt'),'w');
fprintf(fid,'%s\n',['résultats pour : ' subj]);


for i = 1 : length(stats)
    fprintf(fid,'%s\n',['name  : ' stats(i).name]);
    
    fprintf(fid,'%s\n',['volume  : ' num2str(stats(i).volume)]);
    
    fprintf(fid,'%s\n',['min  : ' num2str(stats(i).min)]);
    
    fprintf(fid,'%s\n',['max  : ' num2str(stats(i).max)]);
    
    fprintf(fid,'%s\n',['moy  : ' num2str(stats(i).moy)]);
    
    fprintf(fid,'%s\n',['std  : ' num2str(stats(i).std)]);
    
    fprintf(fid,'%s\n','');
    fprintf(fid,'%s\n','');
    fprintf(fid,'%s\n','');
    
end



fclose(fid)