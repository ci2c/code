function f = GraphHeatDiffusion(M, f, Time, Dist, velocity)
% Usage : H = GraphHeatDiffusion(M, f, Time, [Dist, velocity])
%
% Performs heat diffusion of f along the connectivity matrix M wrt Time
%
% Inputs :
%      M        : N x N Connectivity matrix
%      f        : N x 1 Initial signal mapped on the nodes
%
% Options :
%      Dist     : N x N pairwise distance between ROIs in mm.
%      velocity : Signal diffusion velocity along connections in m/s.
%                  Default : 19 m/s
%
% Pierre Besson @ CHRU Lille, Oct. 2012

if nargin ~= 3 && nargin ~= 4 && nargin ~= 5
    error('invalid usage');
end

if nargin == 4
    velocity = 19;
end

N = size(M, 1);

L = Laplacian(M, 1);
f = f';

dt = Time(2) - Time(1);
niter = length(Time);

tic;
if nargin < 4
    for i=1:niter
        disp(['Iter : ', num2str(i)]);
        f = f - dt*f*L';
    %     SurfStatWriteData(['/home/pierre/NAS/pierre/louise-10/DTI/movie_heat/f_', num2str(i, '%.5d')], f, 'b');
    end

    f = single(f');
else
    velocity = 1000 * velocity;
    Time = Dist ./ velocity;
    Time = quant(Time, dt);
    max_lag = max(Time(:)) ./ dt;
    History = repmat(f, max_lag+1, 1);
    lag = Time ./ dt;
    
    index = round(repmat((1:N)', 1, N) + N * lag);
    dt = single(dt);
    L = single(L);
    
    for i = 1 : niter
        disp(['Iter : ', num2str(i) ' Elapsed time : ', num2str(toc)]);
        Temp = History';
        signal = single((Temp(index))');
        signal = signal - dt * signal * L';
        History = circshift(History, 1);
        History(1,:) = diag(signal);
    end
    
    f = History(1,:)';
end