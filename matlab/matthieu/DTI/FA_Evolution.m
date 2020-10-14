% NfibersRightFCS = RightFCS_FA.nFiberNr;

[MaxSizeFibers,index] = max(cat(1,RightFCS_FA.fiber.nFiberLength));

length_FA = arrayfun(@(x) length(x.FA),RightFCS_FA.fiber);

FiberFA{MaxSizeFibers} = [];
% idx = [];

idx = arrayfun(@(x) find(x<=length_FA), 1:MaxSizeFibers, 'UniformOutput', false);

for i = 1 : MaxSizeFibers
%     for j = 1 : NfibersRightFCS 
%         if length(RightFCS_FA.fiber(j).FA) >= i
%     idx = find(length_FA >= i);
    FiberFA{i} = arrayfun(@(x) x.FA(i), RightFCS_FA.fiber(idx{i}));
%             FiberFA{i} = [ FiberFA{i} ; RightFCS_FA.fiber(j).FA(i) ];
%         end
%     end
end

% MFiberFA = zeros(MaxSizeFibers,1);
% for i = 1 : MaxSizeFibers
%     MFiberFA(i) = mean(FiberFA{i}(:));
% end

MFiberFA = cellfun(@mean, FiberFA);

figure(1)
plot(RightFCS_FA.fiber(index).cumlength,MFiberFA);

