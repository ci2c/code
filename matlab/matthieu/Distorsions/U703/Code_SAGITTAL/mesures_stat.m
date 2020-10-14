function []=mesures_stat(tabled,sdd,tablec,sdc)

%% Statistiques des cartes de déformations calculées

clear all;
close all;

    % Avant correction

load tabled; load sdd;
mz = []; my = []; mr = [];
sdz = []; sdy = []; sdr = [];
maxz = []; maxy = []; maxr= [];

for i=1:size(tabledf,1)
    
    % moyennes
    
    mz = [mz;tabledf{i,2}.meanz];
    my = [my;tabledf{i,1}.meany];
    mr = [mr;tabledf{i,3}.meanr];
    
    % écarts-type
    
    sdz = [sdz;sdf{i,2}.sdz];
    sdy = [sdy;sdf{i,1}.sdy];
    sdr = [sdr;sdf{i,3}.sdr];
    
    % max
    
    maxz = [maxz;tabledf{i,2}.maxz];
    maxy = [maxy;tabledf{i,1}.maxy];
    maxr = [maxr;tabledf{i,3}.maxr];
    
end

mz = mean(mz); my = mean(my); mr = mean(mr);
sdz = mean(sdz); sdy = mean(sdy); sdr = mean(sdr);
maxz = mean(maxz); maxy = mean(maxy); maxr = mean(maxr);
save statdatad3D mz my mr sdz sdy sdr maxz maxy maxr;
clear mz my mr sdz sdy sdr maxz maxy maxr;

    % Après correction
    
load tablec; load sdc;
mz = []; my = []; mr = [];
sdz = []; sdy = []; sdr = [];
maxz = []; maxy = []; maxr= [];

for i=1:size(tablecff,1)
    
    % moyennes
    
    mz = [mz;tablecff{i,2}.meanz];
    my = [my;tablecff{i,1}.meany];
    mr = [mr;tablecff{i,3}.meanr];
    
    % écarts-type
    
    sdz = [sdz;sdcf{i,2}.sdz];
    sdy = [sdy;sdcf{i,1}.sdy];
    sdr = [sdr;sdcf{i,3}.sdr];
    
    % max
    
    maxz = [maxz;tablecff{i,2}.maxz];
    maxy = [maxy;tablecff{i,1}.maxy];
    maxr = [maxr;tablecff{i,3}.maxr];
    
end

mz = mean(mz); my = mean(my); mr = mean(mr);
sdz = mean(sdz); sdy = mean(sdy); sdr = mean(sdr);
maxz = mean(maxz); maxy = mean(maxy); maxr = mean(maxr);

save statdatac3D mz my mr sdz sdy sdr maxz maxy maxr;
clear mz my mr sdz sdy sdr maxz maxy maxr;
