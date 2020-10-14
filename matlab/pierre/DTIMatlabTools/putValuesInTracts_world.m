function tracts2 = putValuesInTracts_world(tracts,maps,mapNames)




tracts2 = tracts;
for mapnum = 1 : length(mapNames)
   eval(['thisMap.data = maps.' mapNames{mapnum} ';']);
   thisMap.origin = maps.info_lambdas.origin;
   thisMap.vox    = maps.info_lambdas.vox;
   img = reshape(thisMap.data,size(maps.info_lambdas.lat));
   thisMap.data = img;

    pos = 0;


    nFib      = tracts.nFiberNr;
    nPointsInFiber = zeros(nFib,1);
    for f = 1 : nFib
        nPointsInFiber(f) = tracts.fiber(f).nFiberLength;
    end
    nPointsTotal = sum(nPointsInFiber);
    allPointsInAllFibers = zeros(nPointsTotal,3);
    pos = 0;
    for f = 1 : nFib
        allPointsInAllFibers(pos+1:pos+nPointsInFiber(f),:) = [tracts.fiber(f).xyzFiberCoord];
        pos = pos + nPointsInFiber(f);

    end

    coord = allPointsInAllFibers';
    one = ones(size(coord,2),1);
    vox = (double(coord')-one*thisMap.origin)./(one*thisMap.vox(1:3))+1;
    s   = interpn(thisMap.data,vox(:,1),vox(:,2),vox(:,3),'linear',0);

    pos = 0;
    disp(['Getting ' mapNames{mapnum} ' values']);
    for f = 1 : nFib
        nPointsInFiber(f) = tracts.fiber(f).nFiberLength;
        start  = pos+1;
        finish = pos + nPointsInFiber(f);
        eval(['tracts2.fiber(f).data.' mapNames{mapnum} '_mean = mean(s(start:finish));']);
        eval(['tracts2.fiber(f).data.' mapNames{mapnum} '_pp = s(start:finish);']);
        pos = pos + nPointsInFiber(f);
    end
end
