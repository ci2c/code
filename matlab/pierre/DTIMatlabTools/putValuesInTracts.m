function [tracts2,valuesPerLine] = putValuesInTracts(tracts,maps,fixOffset)


% Prepare variables
nFib      = tracts.nFiberNr;
nPointsInFiber = zeros(nFib,1);
for f = 1 : nFib
    nPointsInFiber(f) = tracts.fiber(f).nFiberLength;
end

nPointsTotal = sum(nPointsInFiber);
allPointsInAllFibers = zeros(nPointsTotal,5); % [x y z fiberIdx vertexInFiberIdx]


% Reshape all the points in the tracts, just to make the calculation faster
% and avoid a for loop, always advisable because matlab can be horribly
% and stupidly slow when it comes to for loops.
pos = 0;
disp('Preparing coordinates');
for f = 1 : nFib
    
        allPointsInAllFibers(pos+1:pos+nPointsInFiber(f),:) = [tracts.fiber(f).xyzFiberCoord ...
                                                         repmat(f,nPointsInFiber(f),1) ...
                                                         [1:1:nPointsInFiber(f)]'];
        pos = pos + nPointsInFiber(f);
    
end

if fixOffset
    allPointsInAllFibers(:,1:3) = allPointsInAllFibers(:,1:3) +1;  % fix matlab's offset
end


disp('Getting data')
e1_pp   = interp3(maps.e1,allPointsInAllFibers(:,1),allPointsInAllFibers(:,2),allPointsInAllFibers(:,3));
perp_pp = interp3(maps.PERP,allPointsInAllFibers(:,1),allPointsInAllFibers(:,2),allPointsInAllFibers(:,3));
FA_pp   = interp3(maps.FA,allPointsInAllFibers(:,1),allPointsInAllFibers(:,2),allPointsInAllFibers(:,3));
ADC_pp  = interp3(maps.ADC,allPointsInAllFibers(:,1),allPointsInAllFibers(:,2),allPointsInAllFibers(:,3));


% allocate memory  EXPECTS ALL FIBERS TO HAVE SAME LENGTH, AS THE
% SAMPLELINES GIVEN BY T-LINKING. DO NOT USE ON OTHER TRACTS
valuesPerLine.FA   = zeros(tracts.nFiberNr,tracts.fiber(1).nFiberLength+2);
valuesPerLine.ADC  = zeros(tracts.nFiberNr,tracts.fiber(1).nFiberLength+2);
valuesPerLine.e1   = zeros(tracts.nFiberNr,tracts.fiber(1).nFiberLength+2);
valuesPerLine.perp = zeros(tracts.nFiberNr,tracts.fiber(1).nFiberLength+2);

tracts2.fiber(tracts.nFiberNr).data.e1_pp = NaN;
tracts2.fiber(tracts.nFiberNr).data.e1_mean = NaN;
tracts2.fiber(tracts.nFiberNr).data.e1_std = NaN;

tracts2.fiber(tracts.nFiberNr).data.perp_pp = NaN;
tracts2.fiber(tracts.nFiberNr).data.perp_mean = NaN;
tracts2.fiber(tracts.nFiberNr).data.perp_std = NaN;

tracts2.fiber(tracts.nFiberNr).data.FA_pp = NaN;
tracts2.fiber(tracts.nFiberNr).data.FA_mean = NaN;
tracts2.fiber(tracts.nFiberNr).data.FA_std = NaN;

tracts2.fiber(tracts.nFiberNr).data.ADC_pp = NaN;
tracts2.fiber(tracts.nFiberNr).data.ADC_mean = NaN;
tracts2.fiber(tracts.nFiberNr).data.ADC_std = NaN;
% end of memory allocation



tracts2 = tracts;
progBar = progress('init','Organizing data...');  
for f = 1 : nFib
    if ~mod(f,100)
        progBar = progress(f./nFib,progBar);
    end
    index = find(allPointsInAllFibers(:,4) == f);

    tracts2.fiber(f).data.e1_pp   = e1_pp(index);
    tracts2.fiber(f).data.e1_mean = mean(e1_pp(index));
    tracts2.fiber(f).data.e1_std  = std(e1_pp(index));
    valuesPerLine.e1(f,:) = [nanmean(e1_pp(index)) nanstd(e1_pp(index)) e1_pp(index)'];
    
    tracts2.fiber(f).data.perp_pp   = perp_pp(index);
    tracts2.fiber(f).data.perp_mean = mean(perp_pp(index));
    tracts2.fiber(f).data.perp_std  = std(perp_pp(index));
    valuesPerLine.perp(f,:) = [nanmean(perp_pp(index)) nanstd(perp_pp(index)) perp_pp(index)'];
    
    tracts2.fiber(f).data.FA_pp   = FA_pp(index);
    tracts2.fiber(f).data.FA_mean = mean(FA_pp(index));
    tracts2.fiber(f).data.FA_std  = std(FA_pp(index));
    valuesPerLine.FA(f,:) = [nanmean(FA_pp(index)) nanstd(FA_pp(index)) FA_pp(index)'];
    
    tracts2.fiber(f).data.ADC_pp   = ADC_pp(index);
    tracts2.fiber(f).data.ADC_mean = mean(ADC_pp(index));
    tracts2.fiber(f).data.ADC_std  = std(ADC_pp(index));
    valuesPerLine.ADC(f,:) = [nanmean(ADC_pp(index)) nanstd(ADC_pp(index)) ADC_pp(index)'];
    

end

