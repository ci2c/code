
% first make a variable that is a MxNxD matrix, where D is the number of
% dimensions used for clustering. Of course, it can only handle 2d slices
% now, but could be tweaked to handle 3d data sets.
% for example:
% multiDim = cat(3,img1,img2,img3);


nDims = size(multiDim,3);
disp(['This Data set has ' num2str(nDims) ' dimensions']);

nElems = numel(multiDim(:,:,1));
mat = zeros(nElems,nDims);

for d = 1:nDims
       mat(:,d) = reshape(multiDim(:,:,d),nElems,1);
end


numTissues = input('How many tissues do you want to segment?    ');
labels = zeros(size(multiDim,1),size(multiDim,2),numTissues);
allIDs = zeros(nElems,numTissues);

%find air in images
disp(['Finding noise...']);
IDnoise =kmeans(mat,4,'distance','city','display','final'); % find noise and 3 tissues
theNoiseID = IDnoise(1);                                    % first pixel's gotta be noise, right?
NoiseIndex = find(IDnoise == theNoiseID);
NoiseMask = ones(size(multiDim,1),size(multiDim,2));
NoiseMask(NoiseIndex) = 0;                                  % here's the mask for noise/air




for i = 1 : numTissues;
    disp(['k-means clustering is congregating ' num2str(i+1) ' tissues']);
    idx3=kmeans(mat,i+1,'distance','cityblock','display','final');
    idx3(NoiseIndex) = NaN;
    allIDs(:,i) = idx3;
    labs = reshape(idx3,size(multiDim,1),size(multiDim,2));
    labels(:,:,i) = labs;
end

imagescn(labels);colormap(gray);

figure;scatter3(mat(:,1),mat(:,2),mat(:,3),1,allIDs(:,3))
xlabel('TI = 571');ylabel('TI = 1386');zlabel('TI =2620 ')