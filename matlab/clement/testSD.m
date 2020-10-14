z = find(FoTC==0)

for i=1:size(z)
    
FoTC=[FoTC(1:(z(i)-1));FoTC((z(i)+1):end)]

z = find(FoTC==0)
end