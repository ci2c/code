function tracts2 = putTractInRightPlace_fromMedInria(tract,info);


% [allFibers,tract] = f_readFiber_vtk_bin_selection('new_plante_amelie_myriam_fibers.fib',...
%     'new_plante_amelie_myriam_UF right.fib')
% info = mnc_info('new_plante_amelie_myriam_UF_right_bin_Dist_final.mnc');
% dist = readmnc('new_plante_amelie_myriam_UF_right_bin_Dist_final.mnc');

tracts2 = tract;

%dims     = [info.DimSizes(4) info.DimSizes(3) info.DimSizes(2)];%[info.xspace.length info.yspace.length info.zspace.length];
%voxDim   = abs([info.Steps(3) info.Steps(2) info.Steps(1)]);%abs([info.xspace.step;info.yspace.step;info.zspace.step])';
%w_dims   = dims .* voxDim;
%start    = [info.Starts(3) info.Starts(2) info.Starts(1)];%[info.xspace.start info.yspace.start info.zspace.start];

dims     = [info.xspace.length info.yspace.length info.zspace.length];
voxDim   = abs([info.xspace.step;info.yspace.step;info.zspace.step])';
w_dims   = dims .* voxDim;
start    = [info.xspace.start info.yspace.start info.zspace.start];


for f = 1 : tracts2.nFiberNr
    x = tracts2.fiber(f).xyzFiberCoord(:,1) +1;
    y = tracts2.fiber(f).xyzFiberCoord(:,2) +1;
    z = tracts2.fiber(f).xyzFiberCoord(:,3) +1;
    
    x = w_dims(1) - x + abs(start(1));
    y = w_dims(2) - y + abs(start(2));
    z = z + abs(start(3));%w_dims(3) -abs(start(3)) + z;
    
    x = x ./ voxDim(1);
    y = y ./ voxDim(2);
    z = z ./ voxDim(3);
    
    tracts2.fiber(f).xyzFiberCoord = [x y z];
end
% hold off;H = tracTubes_DTIstudio_selection(tracts2,[1:1:tracts2.nFiberNr]);ylabel('y');
% set(gca,'XLim',[0 128]);
% set(gca,'YLim',[0 128]);
% set(gca,'ZLim',[0 60]);
% view(2)
% axis square


