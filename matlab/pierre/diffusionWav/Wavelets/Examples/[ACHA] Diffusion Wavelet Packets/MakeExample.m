function [ Points, Basis, Diffusion, Tree ] = MakeExample( ExampleName, Force)
% function [ Points, Basis, Diffusion, Tree ] = MakeExample( ExampleName, Force )
%
% Create the data for one of the examples in the diffusion wavelet packet paper.
% This function first looks for a .mat file with the same name as the
% example and if found, loads the data from there.
%
% In:
%    ExampleName = String indicating which of the following examples to generate
%                  data for:
%
%                  'Circle'      = standard diffusion on the circle
%                  'Anisotropic' = an anistropic diffusion on the circle
%                  'Sphere'      =
%
%    Force       = If true, regenerate the data whether it is already
%                  stored or not.
%
% Uses:
%    DiffusionWaveletTree, MakeDiffusion2
%
% Out:
%
%    Points      = An NxM matrix of N points on the graph.
%    Basis       = The delta basis.
%    Diffusion   = The diffusion operator on the delta basis.
%    Tree        = The diffusion wavelet tree.
%

P = [];
B = [];
T = [];
Tree = [];

DebugPlots = 0;
EigPlot    = 0;

if nargin < 2
   Force = 0;
end


Options.Extend    = 1;
Options.DebugPlot = 0;
Options.DebugOut  = 1;
%Options.SplitFcn  = 'WPSplit';

if strcmpi(ExampleName, 'Circle')

   if ~exist('Circle.mat') | Force
      N          = 1024;
      Delta      = 70;
      TPrecision = 1e-3;
      Levels     = 15;
      Precision  = 1e-10;

      fprintf('[-] Generating diffusion operator ...\n\n');

      % make some points
      Thetas = linspace(0,2*pi, N+1);
      Thetas = Thetas(1:N)';

      Points    = [cos(Thetas) sin(Thetas)];
      Basis     = speye(N);

      Options.NPoints=2;
      Options.Delta=70;
      Diffusion = MakeDiffusion2(Points, 'Gauss', Options);

%      Diffusion = MakeDiffusion(Points, Delta, TPrecision);

      if DebugPlots
            figure; scatter(Points(:,1), Points(:,2)); title('Circle: Points');
         figure; imagesc(Diffusion); title('Circle: image');

         if EigPlot
            figure; plot(flipud(sort(abs(eigs(Diffusion, N-2))))); title('Circle: Eigs');
         end
         [V, D] = eigs(Diffusion, 4);
         figure; scatter(V(:,2), V(:,3)); title('Circle: Coifman-Lafon embedding');
      end

      Tree = [];

      fprintf('[-] Making diffusion wavelet tree ...\n\n');
      % generate the tree
      Tree = DiffusionWaveletTreeF('Full', Options, Basis, Diffusion, ...
         Levels, Precision);

      % save the data to a mat file
%     save 'Circle.mat' Points Basis Diffusion Tree N Precision Levels;
   else
      load 'Circle.mat';
   end
elseif strcmpi(ExampleName, 'Anisotropic')

   if ~exist('Anisotropic.mat') | Force

       N          = 256;
       Levels     = 10;

    %   TPrecision = 1e-3;
       Precision  = 1e-10;

       lNumberOfPoints = N;
       %lImpedance = 0.25+(1.9*((1:lNumberOfPoints)-128)/(lNumberOfPoints)).^6.*sin(pi/lNumberOfPoints*(1:lNumberOfPoints));
       lImpedance =0.5+0.49*sin(2*pi/(lNumberOfPoints-1)*(1:lNumberOfPoints));

       lImpedance = lImpedance * 10;
       %lImpedance(1:floor(lNumberOfPoints/2))=1;
       %lImpedance(floor(lNumberOfPoints/2)+1:lNumberOfPoints)=2;
       %lImpedance=0.5*ones(1,lNumberOfPoints);

       % Allocate memory for the diffusion matrix
       cDiffusionMatrix = zeros(lNumberOfPoints,lNumberOfPoints);

       cDiffusionMatrix(1,[1 2 lNumberOfPoints]) = [4-(lImpedance(1)+lImpedance(lNumberOfPoints)) lImpedance(1) lImpedance(lNumberOfPoints)];      %-(lImpedance(1)+lImpedance(lNumberOfPoints))
       for lk = 2:lNumberOfPoints-1
           cDiffusionMatrix(lk,lk-1:lk+1) = [lImpedance(lk-1) 4-(lImpedance(lk-1)+lImpedance(lk)) lImpedance(lk)];       %-(lImpedance(lk-1)+lImpedance(lk))
       end;
       cDiffusionMatrix(lNumberOfPoints,[1 lNumberOfPoints-1 lNumberOfPoints]) = [lImpedance(lNumberOfPoints) lImpedance(lNumberOfPoints-1) 4-(lImpedance(lNumberOfPoints)+lImpedance(lNumberOfPoints-1))]; %-(lImpedance(lNumberOfPoints)+lImpedance(lNumberOfPoints-1))

       % Normalize the diffusion matrix by making it row-stochastic
       %cDiffusionMatrix = cDiffusionMatrix * diag(sum(cDiffusionMatrix,2).^(-1),0);

       % Symmetrize the matrix
       %cDiffusionMatrix = cDiffusionMatrix*cDiffusionMatrix';

       Diffusion = sparse(GraphNormalize(cDiffusionMatrix,1e-10));
       Basis = speye(lNumberOfPoints);
       Thetas = linspace(0,2*pi, N+1);
       Thetas = Thetas(1:N)';
       Points    = [cos(Thetas) sin(Thetas)];

       if DebugPlots
          figure; scatter(Points(:,1), Points(:,2)); title('Anisotropic Circle: Points');
         figure; imagesc(Diffusion); title('Anisotropic Circle: image');
         if EigPlot
            figure; plot(flipud(sort(abs(eigs(Diffusion, N-2))))); title('Anisotropic Circle: Eigs');
         end

         [V, D] = eigs(Diffusion, 10);
         figure; scatter(V(:,2), V(:,3)); title('Anisotropic Circle: Coifman-Lafon embedding');
      end

      Tree = [];
        Tree = DiffusionWaveletTreeF('Full', Options, Basis, Diffusion, ...
        Levels, Precision);

        save 'Anisotropic.mat' Points Basis Diffusion Tree N Precision Levels lImpedance;
    else
        load 'Anisotropic.mat';
    end

elseif strcmpi(ExampleName, 'Sphere')

   if ~exist('Sphere.mat') | Force

      t=cputime;

      N          = 1000;
      Delta      = 20;
      TPrecision = .25;
      Levels     = 20;
      Precision  = 1e-12;

      fprintf('%d %d %g', N, Levels, Precision);
      fprintf('[-] Generating sphere data (this will take a while) ...\n\n');

      % make some points
      Points = randn(N,3);
      for j=1:N
         Points(j,:) = Points(j,:) / norm(Points(j,:));
      end

      Basis     = speye(N);

      DOptions.NPoints = 5;
%      DOptions.Precision = .20;
%      DOptions.Delta = Delta;
      Diffusion = MakeDiffusion2(Points, 'Chi', DOptions);

%     Diffusion = MakeDiffusion(Points, Delta, TPrecision);

       if DebugPlots
         figure; scatter3(Points(:,1), Points(:,2), Points(:,3)); title('Sphere: Points');
         figure; imagesc(Diffusion); title('Sphere: image');
         if EigPlot
            figure; plot(flipud(sort(abs(eigs(Diffusion,N-2))))); title('Sphere: Eigs');
         end
         [V, D] = eigs(Diffusion, 4);
         figure; scatter3(V(:,2), V(:,3), V(:,4)); title('Sphere: Coifman-Lafon embedding');
      end

      Tree = [];
      % generate the tree

      Tree = DiffusionWaveletTreeF('Full', Options, Basis, Diffusion, ...
         Levels, Precision);

      % save the data to a mat file
      t=cputime-t;
%     save 'Sphere.mat' Points Basis Diffusion Tree N Precision Levels t;

      fprintf('Time = %g\n', t);
   else
%     load 'Sphere.mat';
   end
else
   fprintf('I do not know how to make "%s.".\n', ExampleName);
   Points = [];
   Basis = [];
   Diffusion = [];
   Tree = {};
end


function [vW,vDInvSqrt] = GraphNormalize(cW,cPrecision);

% Allocate memory
vW = cW;

% Compute the row sum
lD = sum( cW,2 );

lDInvSqrt = zeros(1,length(lD));
% Compute 'inverse' sqrt of lD
for lk = 1:length(lD)
    if abs(lD(lk)) > cPrecision,
        lDInvSqrt(lk) = 1/sqrt(lD(lk));
    else
        lDInvSqrt(lk) = 0;
    end;
end;

lDInvSqrt = diag(lDInvSqrt);

vW = lDInvSqrt*vW*lDInvSqrt;

%for lk = 1:size(vW,1)
%    vW(lk,lk) = 1-vW(lk,lk);
%end;

vDInvSqrt = lDInvSqrt;

return;