% sol = KuramotoG(trange,theta,omega,matrix,K,display,coordinates)
%
% Pierre Besson @ CHRU Lille, April 2012

% TO DO
% Ajouter la dependance pour tau=0 mais matrix~=0
function sol = KuramotoG(trange,theta,omega,matrix,K,display,coordinates)
    
    global NFIG;
    NFIG=0;

    % get dimensions of incoming matrices
    N = length(theta);    
        
    % initiate axis handles required by odedisplay function 
    cm = [linspace(0,1,64)', zeros(64,1), linspace(1,0,64)'];
    scatterplot = [];
    scattertitle = [];
    phaseplot = [];
    
    % enable our custom real-time ODE plotting function if requested
    if display
        % enable plotting
        odeoption = odeset('OutputFcn',@odedisplay);
    else
        % disable plotting
        odeoption = [];        
    end

    % integrate
    sol = ode45(@odefun,trange,theta,odeoption);
    
    
    % Kuramoto ODE function
    function dtheta = odefun(t,theta)
        thetamat = repmat(theta', N, 1) - repmat(theta, 1, N);
        
        % The Kuramoto Equation 
        dtheta = omega + K .* sum( matrix .* sin(thetamat), 2 );
    end

       
         
    % Custom ODE plot function
    function status = odedisplay(t,y,mode)
        switch mode
            case 'init'   
                theta = y(:, 1);
                thetadisplay = 32 + 32*cos(theta); % theta=0 is blue, theta=pi is red
                % construct figure and plot axes 
                figure('name','Kuramoto Oscillators (Graph)', 'numbertitle','off', 'position',[100 100 400 400])
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
                
                saveas(gcf, ['capture_', num2str(NFIG, '%.8d'), '.png']);
                NFIG=NFIG+1;
                
                
            case []
                for ii= 1:numel(t)
                    % pause(0.01);
                    theta = y(:,ii);
                    
                    % update phaseplot
                    set(phaseplot,'Xdata',cos(theta));
                    set(phaseplot,'Ydata',sin(theta));
                    
                    
                    % update scatter plot
                    thetadisplay = 32 + 32*cos(theta);
                    set(scatterplot, 'Cdata', thetadisplay);
                    set(scattertitle, 'String', ['Oscillator Phases at t=', num2str(t(ii)*1000) ' millisecs']);
                    
                    drawnow;      
                    saveas(gcf, ['capture_', num2str(NFIG, '%.8d'), '.png']);
                    NFIG=NFIG+1;
                    
                end
                
            case 'done'
        end
        status=0;
    end

disp('truc');

end