function FMRI_CreateEdgeFileBrainNet(outfile,M)

fid = fopen(outfile,'w');

for i=1:size(M,1)
    
    for j=1:size(M,2)
        
        fprintf(fid,'%f ',M(i,j));
        
    end
    
    fprintf(fid,'\n');
    
end