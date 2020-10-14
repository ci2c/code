[a,b,c] = xlsread('/home/fatmike/Protocoles_3T/Strokdem/test/test_reg/ages.xls');


[A,B,C] = xlsread('/home/clement/Documents/Datas STROKDEM/Trouble_Cog');
NageTC = zeros(size(B),1);
for i=1:length(b)
    
index= find(ismember(B,b(i)));

    if index ~= 0
        NageTC(index)=a(i);
    end

end




