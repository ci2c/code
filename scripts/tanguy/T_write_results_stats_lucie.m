function T_write_results_stats_lucie(statsdir,subj,stats)

fid = fopen(fullfile(statsdir,'/results.txt'),'w');
fprintf(fid,'%s\n',['resultats pour : ' ]);


for i = 1 : length(stats)
    tr(i,:)=stats(i).name(1:2);
end
if all(tr(:,2)=='m')
    ind1=3;
elseif (all(tr(:,1)=='m') || all(tr(:,1)=='r'))
    ind1=2;
else
    ind1=1;
end

for i = 1 : length(stats)
    
    roib=stats(i).name;
    ind2b=strfind(roib,'_');
    ind2=ind2b(1);
    if isempty(strfind(roib,'_l_'))
        s='right';
    else
        s='left';
    end
    roi=[roib(ind1:ind2-1) ' - ' s];
       
    fprintf(fid,'%s\n',['name  : ' roi ':']);
    
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
