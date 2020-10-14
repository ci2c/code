function sol = KuramotoG_delay(trange,theta,omega,K,matrix,delays,sigma_n,coordinates,display)
% usage : SOL = KuramotoG_delay(TRANGE, THETA, OMEGA, K, ...
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
%    C_MATRIX      : NxN Connectivity matrix with E non-zero elements
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
% Pierre Besson @ CHRU Lille, April 2012

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


% Clean delays matrix
delays(delays <  0) = 0;
delays(matrix == 0) = 0;
delays_vec = delays';
delays_vec = delays_vec(:)';
delays_vec(delays_vec==0) = [];
zncol = length(delays_vec);
delays_index = find(delays');
delays_index_fs = delays'~=0;
[delays_index_i, delays_index_j] = find(delays');
z_index = delays_index_i + N * (0 : zncol-1)';

% get connection with delays == 0
delays_null = double(matrix ~= 0) .* double(delays == 0);


% initiate axis handles required by odedisplay function 
cm = [linspace(0,1,64)', zeros(64,1), linspace(1,0,64)'];
scatterplot = [];
scattertitle = [];
phaseplot = [];

% enable our custom real-time DDE plotting function if requested
if display
    % enable plotting
    ddeoption = ddeset('OutputFcn',@ddedisplay);
else
    % disable plotting
    ddeoption = [];        
end

% integrate
sol = dde23(@ddefun,delays_vec,@ddehist, trange, ddeoption);


% Kuramoto DDE function
function dtheta = ddefun(t, theta, Z)
    thetamat = zeros(N);
    thetamat(delays_index_fs) = Z(z_index);
    thetamat_nodelay = repmat(theta', N, 1) .* delays_null;
    thetamat = thetamat' + thetamat_nodelay - repmat(theta, 1, N) .* double(thetamat + thetamat_nodelay ~= 0);

    % The Kuramoto Equation 
    dtheta = omega + K .* sum( matrix .* sin(thetamat), 2 ) + sigma_n * randn(N, 1);
end

% Kuramoto DDE history
function s = ddehist(t)
    s = theta;
end



% Custom DDE plot function
function status = ddedisplay(t,y,mode)
    switch mode
        case 'init'   
            theta = y(:, 1);
            thetadisplay = 32 + 32*cos(theta); % theta=0 is blue, theta=pi is red
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
            scattertitle = title(['Oscillator Phases at t=', num2str(t(1)*1000) ' millisecs']);

            subplot(1,2,2);
            phaseplot = polar(theta,ones(N,1),'o');
            title('Instantaneous Phase');


        case []
            for ii= 1:numel(t)
                % pause(0.1);
                theta = y(:,ii);

                % update phaseplot
                set(phaseplot,'Xdata',cos(theta));
                set(phaseplot,'Ydata',sin(theta));


                % update scatter plot
                thetadisplay = 32 + 32*cos(theta);
                set(scatterplot, 'Cdata', thetadisplay);
                set(scattertitle, 'String', ['Oscillator Phases at t=', num2str(t(ii)*1000) ' millisecs']);

                drawnow;                                       
            end

        case 'done'
    end
    status=0;
end

end