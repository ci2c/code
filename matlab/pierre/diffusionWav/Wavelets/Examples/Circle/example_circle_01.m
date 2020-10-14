% This scripts creates diffusion wavelets on a circle

% Create diffusion operator on a circle
fprintf('Creating diffusion operator...\n');
T=MakeCircleDiffusion(512);
T=T^4;

% Create diffusion wavelets
Tree = DWPTree (T, 12, 1e-4, struct('Wavelets',false,'OpThreshold',1e-2,'GSOptions',struct('StopDensity',0.5,'Threshold',1e-2)));

% Show some diffusion scaling functions, in regular scale and log10 scale to show exp. decay
figure;warning off;
subplot(2,2,1);plot(Tree{4,1}.ExtBasis(:,10:5:30));subplot(2,2,2);plot(Tree{7,1}.ExtBasis(:,2:5:15));
subplot(2,2,3);plot(log10(abs(Tree{4,1}.ExtBasis(:,10:5:30))));subplot(2,2,4);plot(log10(abs(Tree{7,1}.ExtBasis(:,2:5:15))));warning on;

% Show some compressed powers of T
figure;subplot(2,4,1);imagesc(Tree{2,1}.T{1});subplot(2,4,2);imagesc(Tree{4,1}.T{1});subplot(2,4,3);imagesc(Tree{6,1}.T{1});subplot(2,4,4);imagesc(Tree{8,1}.T{1});colorbar;
subplot(2,4,5);imagesc(log10(abs(Tree{2,1}.T{1})));subplot(2,4,6);imagesc(log10(abs(Tree{4,1}.T{1})));subplot(2,4,7);imagesc(log10(abs(Tree{6,1}.T{1})));subplot(2,4,8);imagesc(log10(abs(Tree{8,1}.T{1})));colorbar