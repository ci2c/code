function l=compute_list_roi(roidir)

%%
% Tanguy Hamel @ CHRU Lille, 2013
%%

list=dir(fullfile(roidir,'Freesurfer'));
for i = 3 : size(list,1)
    l{i-2}=list(i).name;
end



fid=fopen(fullfile(roidir,'Manual/list.txt'),'rt');

while feof(fid) == 0
    a=length(l);
    line=fgetl(fid);
    length(line)
    if length(line)>2
        l{a+1} = [line '_vol'];
    end
end
fclose(fid);

