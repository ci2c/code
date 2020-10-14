function mtR = FMRI_CreateCorrNodeFileBrainNet(outfile,resClust,netw)

nameROI   = [];
nameROI   = [];
coord     = [];
maskClust = [];
tabind    = [];
for k = 1:length(netw)
    coord     = [coord;resClust.roi{netw(k)}.coord_mm];
    nameROI   = [nameROI resClust.roi{netw(k)}.nameRoi];
    ind       = find(resClust.stats.maskClust==netw(k));
    maskClust = [maskClust resClust.stats.maskClust(ind)];
    tabind    = [tabind ind];
end
temp = resClust.stats.mtR;
mtR  = zeros(length(tabind),length(tabind));
for i = 1:length(tabind)
    mtR(i,:) = temp(tabind(i),tabind);
end

nodes.coords = coord;
nodes.colors = ones(1,size(coord,1));
nodes.sizes  = 0.5*ones(1,size(coord,1));
for k=1:size(coord,1)
    nodes.labels{k} = nameROI{k};
end

fid = fopen(outfile,'w');

for k = 1:size(nodes.coords,1)
    
    % Coordinates
    fprintf(fid,'%f ',nodes.coords(k,1));
    fprintf(fid,'%f ',nodes.coords(k,2));
    fprintf(fid,'%f ',nodes.coords(k,3));
    
    % Colors
    fprintf(fid,'%f ',nodes.colors(k));
    
    % Sizes
    fprintf(fid,'%f ',nodes.sizes(k));
    
    % Labels
    fprintf(fid,'%s ',nodes.labels{k});
    
    fprintf(fid,'\n');
    
end

fclose(fid);