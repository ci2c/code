function animate_kuramoto(trange,sol,coordinates, T)
% usage : animate_kuramoto(TRANGE, SOL, COORDINATES, [T])
%
% Animate the oscillators stored in SOL
%
% Inputs :
%    TRANGE        : Time range defining SOL. Example: 0:0.1:20
%    SOL           : Oscillator's phase returned by KuramotoG_delay_euler
%    COORDINATES   : Node's coordinates Nx3 matrix
%
% Options :
%    T             : Additional between iterations. Default : T = 0 sec
%
%
% Pierre Besson @ CHRU Lille, Jul. 2012

if (nargin ~= 3) && (nargin ~= 4)
    error('invalid usage');
end

if nargin == 3
    T = 0;
end

cm = [linspace(0,1,64)', zeros(64,1), linspace(1,0,64)'];
delta_t = trange(2) - trange(1);
N = size(sol, 1);
N1 = ones(N,1);

thetadisplay = 32 + 32*cos(sol(:,1)); % theta=0 is blue, theta=pi is red
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
scattertitle = title(['Oscillator Phases at t=', num2str(trange(1)) ' millisecs']);

subplot(1,2,2);
phaseplot = polar(sol(:,1),N1,'o');
title('Instantaneous Phase');

for i = 2 : length(trange)
    set(phaseplot,'Xdata',cos(sol(:,i)));
    set(phaseplot,'Ydata',sin(sol(:,i)));


    % update scatter plot
    thetadisplay = 32 + 32*cos(sol(:,i));
    set(scatterplot, 'Cdata', thetadisplay);
    set(scattertitle, 'String', ['Oscillator Phases at t=', num2str(trange(i)*1000) ' millisecs']);

    drawnow;
    pause(T + delta_t);
end