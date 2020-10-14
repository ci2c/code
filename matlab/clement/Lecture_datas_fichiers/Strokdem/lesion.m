[dat,subj,c] = xlsread('/home/clement/Documents/Datas_Strokdem/lesion.xls');

[a,b,c] = xlsread('/home/clement/Documents/Datas_Strokdem/Trouble_Cog_hip.xls');

lesTC=[];

for i=1:length(b) 
    index=find(ismember(subj,b(i))); 
    lesTC=[lesTC;dat(i)];

end
