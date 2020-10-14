function theta = KuramotoG_delay_euler(trange,theta,omega,K,matrix,delays,sigma_n,coordinates,display)
% usage : SOL = KuramotoG_delay_euler(TRANGE, THETA, OMEGA, K, ...
%                               C_MATRIX, DELAYS, SIGMA_N, ...
%                               [COORDINATES, DISPLAY])
%
% Simulate the oscillations of a N nodes and E edges network.
%
% Inputs :
%    TRANGE        : Time range. Example: 0:0.1:20
%    THETA         : Nx1 Initial nodes' phase (between 0 and 2*pi)
%    OMEGA         : Nx1 Nodes frequency (in Hz)
%    K             : Global coupling parameter. Default = 10
%    C_MATRIX      : NxN Connectivity matrix
%    DELAYS        : NxN Delays matrix
%    SIGMA_N       : Random noise parameter. Default = 5
%
% Options :
%    COORDINATES   : Nx3 Nodes coordinates. For display purposes only.
%    DISPLAY       : Boolean true | false. Default = false
%
% Output :
%    SOL           : Structure of the solution
%
% Pierre Besson @ CHRU Lille, Jul. 2012

global Coord_i Coord_j Coord N cm delta_t theta_index

cm = [linspace(0,1,64)', zeros(64,1), linspace(1,0,64)'];

if (nargin ~= 7) && (nargin ~= 9)
    error('invalid usage');
end

% get & check sizes
N = size(theta, 1);
if size(omega, 1) ~= N
    error('THETA and OMEGA must be N x 1 vectors');
end

if K < 0
    error('K must be > 0');
end

if (size(matrix, 1) ~= N) || (size(matrix, 2) ~= N)
    error('C_MATRIX must be N x N matrix');
end

if (size(delays, 1) ~= N) || (size(delays, 2) ~= N)
    error('DELAYS must be N x N matrix');
end

if sigma_n < 0
    error('SIGMA_N must be > 0');
end

if nargin == 9
    if (size(coordinates, 1) ~= N) || (size(coordinates, 2) ~= 3)
        error('COORDINATES must be N x 3 matrix');
    end
else
    display = false;
end

% Convert continuous delays to step delays
delta_t = trange(2) - trange(1);
delays = quant(delays, delta_t);
delays = delays ./ delta_t;

delay_max = max(delays(:));
theta = [repmat(theta, 1, delay_max + 1) zeros(N, length(trange))];
theta_index = delay_max + 1;

% Construct Coord_i matrix which is always the same
Coord_i = repmat(1:N, N, 1);
Coord_j = (delay_max + 1) * ones(N) - delays;
Coord = int64(Coord_i + N * (Coord_j - 1));
dtheta = derivs(theta(:,theta_index-delay_max:theta_index), delays);

if display
    thetadisplay = 32 + 32*cos(theta(:,theta_index)); % theta=0 is blue, theta=pi is red
    % construct figure and plot axes 
    figure('name','Kuramoto Oscillators (Graph)', 'numbertitle','off', 'position',[100 100 800 400])
    subplot(1,2,1);    % initiate display panel
    if size(coordinates, 2) == 3
        scatterplot = scatter3(coordinates(:,1), coordinates(:,2), coordinates(:,3), 200, thetadisplay, 'filled');
    else
        scatterplot = scatter(coordinates(:,1), coordinates(:,2), 200, thetadisplay, 'filled');
    end
    axis equal;
    colormap(cm);
    caxis([0, 64]);
    scattertitle = title(['Oscillator Phases at t=', num2str(0) ' millisecs']);

    subplot(1,2,2);
    phaseplot = polar(theta(:,theta_index),ones(N,1),'o');
    title('Instantaneous Phase');
else
    progress('init');
    Steps = round(length(trange) ./ 1000);
end

Ltrange = length(trange);

tic;
% loop on time
for i = 1 : Ltrange
    if display
        theta_new = RKdelstep(theta(:,theta_index-delay_max:theta_index), dtheta, delta_t, delays, trange(i), scatterplot, scattertitle, phaseplot);
    else
%         toc1 = toc;
        theta_new = RKdelstep(theta(:,theta_index-delay_max:theta_index), dtheta, delta_t, delays, trange(i));
%         toc2 = toc;
        if mod(i, Steps) == 0
            progress(i/Ltrange, sprintf('Done %.2f', 100*i/Ltrange));
%             disp(['Done : ' num2str(100*i/Ltrange) ' in ' num2str(toc)]);
%             disp(['Toc2 - Toc1 = ', num2str(toc2-toc1)]);
        end
    end
    theta(:,theta_index+1) = theta_new;
    theta_index = theta_index + 1;
    dtheta = derivs(theta(:,theta_index-delay_max:theta_index), delays);
end

%********************************************************
function theta_new = RKdelstep(theta, dtheta, h, delays, T, scatterplot, scattertitle, phaseplot)
    k1  = h * dtheta;
    temp1 = theta(:,1:end-1);
    temp2 = theta(:,end);
    k2 = h * derivs([temp1, temp2+(k1/2)], delays);
    k3  = h * derivs([temp1, temp2+(k2/2)], delays);
    k4  = h * derivs([temp1, temp2+k3], delays);
    theta_new = temp2 + (k1 + 2*k2 + 2*k3 + k4) / 6;
    
    if display
        % update phaseplot
        set(phaseplot,'Xdata',cos(theta_new));
        set(phaseplot,'Ydata',sin(theta_new));


        % update scatter plot
        thetadisplay = 32 + 32*cos(theta_new);
        set(scatterplot, 'Cdata', thetadisplay);
        set(scattertitle, 'String', ['Oscillator Phases at t=', num2str(T*1000) ' millisecs']);

        drawnow;                          
    end
end


%********************************************************
function dtheta=derivs(theta, delays)
    T1 = repmat(theta(:,end), 1, N);
    T2 = theta(Coord);
    
    dtheta = omega + K * sum( matrix .* sin(T2 - T1), 2) + sigma_n * randn(N, 1);
end


end