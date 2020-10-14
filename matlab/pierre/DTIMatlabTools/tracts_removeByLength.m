function tracts2 = tracts_removeByLength(tracts,lengthThreshold)
% function tracts2 = tracts_removeByLength(tracts,lengthThreshold)
%
% Remove individual tracts in a fiber bundle if they are shorter than a
% certain lengthThreshold.
% tracts are loaded by f_readFiber.
%
% Luis Concha. BIC. April 2008.


tracts2 = tracts;
nFib      = tracts.nFiberNr;


toRemove = false(nFib,1);
for f = 1 : nFib
   
    if tracts2.fiber(f).nFiberLength < lengthThreshold
        toRemove(f) = 1;
    end
    
end

fprintf(1,'Remove %d fibers out of %d\n      (%d remaining).\n',sum(toRemove),...
    nFib,nFib-sum(toRemove));
tracts2.fiber(toRemove) = [];

tracts2.nFiberNr = length(tracts2.fiber);