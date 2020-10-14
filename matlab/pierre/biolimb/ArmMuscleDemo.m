function varargout = ArmMuscleDemo(varargin)
% ARMMUSCLEDEMO is an interactive demo of a three-link biomechanical limb.
%   The user controls the limb in real-time by manipulating the activation
%   levels of muscles that flank each limb joint in antagonist pairs.
%   The user may also tweak the various model parameters in real-time.
%
% Reference:
%      Heitmann, Ferns and Breakspear (2012) Muscle co-contraction modulates damping
%      and joint stability in a three-link biomechanical limb. Front Neurorob. 5:5.
%
% Copyright (C) 2012 Stewart Heitmann <heitmann@ego.id.au>
%     This program is distributed freely under the terms of the GNU General 
%     Public License (version 3). See http://www.gnu.org/licenses/

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ArmMuscleDemo_OpeningFcn, ...
                   'gui_OutputFcn',  @ArmMuscleDemo_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

end


% --- Outputs from this function are returned to the command line.
function varargout = ArmMuscleDemo_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;
end


% --- Executes just before ArmMuscleDemo is made visible.
function ArmMuscleDemo_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ArmMuscleDemo (see VARARGIN)

    % Choose default command line output for ArmMuscleDemo
    handles.output = hObject;

    % arm constants
    handles.parm.L = [1 1 1];                        % length of each segment
    handles.parm.M = [1 1 1];                        % mass of each segment
    handles.parm.I = handles.parm.M .* handles.parm.L.^2/12;         % moment of inertia of each segment
    handles.parm.Gx = [0 0 0];                       % gravitational force applied on each segment (x-component)
    handles.parm.Gy = -9.81 * handles.parm.M;        % gravitational force applied on each segment (y-component)
    handles.parm.Te = [0 0 0];                       % external torque applied on each segment
    handles.parm.FQx = 0;                            % External linear force applied at tip (Q) of arm
    handles.parm.FQy = 0;                            % External linear force applied at tip (Q) of arm
    handles.parm.Ox = 0;                             % X-position of arm anchor point
    handles.parm.Oy = 0;                             % Y-position of arm anchor point
    handles.parm.Otheta = pi;                        % Angular orientation of arm anchor point
    handles.parm.Kf = [0 0 0];                       % Linear damping constant applied to each each segment
    handles.parm.Kt = [0 0 0];                       % Angular damping constant applied to each each segment
    handles.parm.actA = [0 0 0];                     % activation level (0..1) of muscles A (flexors)
    handles.parm.actB = [0 0 0];                     % activation level (0..1) of muscles B (extensors)
    handles.parm.FmaxA = [0,0,0];                    % maximal force of muscles A
    handles.parm.FmaxB = [0,0,0];                    % maximal force of muscles B
    handles.parm.KpeA = [5,5,5];                     % PE Force-Length parameters of muscles A
    handles.parm.KpeB = [5,5,5];                     % PE Force-Length parameters of muscles B
    handles.parm.KlA = -ones(1,3)*pi^2/log(0.1);     % CE Force-Length parameters of muscles A
    handles.parm.KlB = -ones(1,3)*pi^2/log(0.1);     % CE Force-Length parameters of muscles B
    handles.parm.KvA = [1,1,1];                      % CE Force-Velocity parameters of muscles A
    handles.parm.KvB = [1,1,1];                      % CE Force-Velocity parameters of muscles B
    handles.parm.phiA = [-0.2,-0.2,-0.2];            % angles of muscle insertion a (proximal muscle A, typically phiA<0)
    handles.parm.phiB = [ 0.2, 0.2, 0.2];            % angles of muscle insertion b (proximal muscle B, typically phiB>0)
    handles.parm.phiC = [ 0.2, 0.2, 0.2];            % angles of muscle insertion c (distal muscle A, typically phiC>0)
    handles.parm.phiD = [-0.2,-0.2,-0.2];            % angles of muscle insertion d (distal muscle B, typically phiD<0)
    handles.parm.psiminA = [0,      0,   0];         % joint angle lower limits wrt muscles A (eg psimin=0)
    handles.parm.psimaxA = [2*pi,2*pi,2*pi];         % joint angle upper limits wrt muscles B (eg psimax=2*pi)
    handles.parm.psiminB = 2*pi-handles.parm.psimaxA;  % joint angle lower limits wrt muscle B
    handles.parm.psimaxB = 2*pi-handles.parm.psiminA;  % joint angle upper limits wrt muscle B
    handles.parm.psimidA = (handles.parm.psiminA + handles.parm.psimaxA)/2;   % resting joint angle (length) of muscle A
    handles.parm.psimidB = (handles.parm.psiminB + handles.parm.psimaxB)/2;   % resting joint angle (length) of muscle B

    % initial values for integration
    handles.t = 0;                                      % time
    handles.Vx = [0 0 0];                               % linear velocity of centre of mass (x-component)
    handles.Vy = [0 0 0];                               % linear velocity of centre of mass (y-component)
    handles.omega = [0 0 0];                            % angular velocity of centre of mass (in radians per sec)
    handles.theta = [pi pi pi];                         % angular position of centre of mass (in radians)
    [handles.Sx,handles.Sy] = midpoints(handles.parm.L,handles.theta);       % positions of centres of mass
    [handles.Px,handles.Py] = endpoints(handles.Sx,handles.Sy,handles.parm.L,handles.theta); % positions of segment endpoints
    guidata(hObject, handles);       % Update handles structure 

    % update handles.parm values according to GUI edit box values
    handles = update_parm(hObject, eventdata, handles);

    % compute the geometry of the joint spurs (ie the lower/upper joint ranges)
    [handles.spurAx, handles.spurAy, ...
     handles.spurBx, handles.spurBy] = jointspurs(handles.Sx, handles.Sy, handles.parm.L,...
                                                  handles.theta, handles.parm.psiminA, handles.parm.psimaxA);

    %construct the runtimer object
    handles.runtimer = timer('TimerFcn',{@runtimer_callback, hObject}, 'Period', 0.1, 'ExecutionMode','fixedRate');

    % construct segment 1 line object
    handles.seg1 = line( handles.Px(1,:), handles.Py(1,:) );  
    set(handles.seg1, 'Marker','o', 'LineStyle', '-');

    % construct segment 2 line object
    handles.seg2 = line( handles.Px(2,:), handles.Py(2,:) );
    set(handles.seg2, 'Marker','o', 'LineStyle', '-');

    % construct segment 3 line object
    handles.seg3 = line( handles.Px(3,:), handles.Py(3,:) );  
    set(handles.seg3, 'Marker','o','LineStyle', '-');
    
                                 
    % construct line objects for the lower-limit joint spurs                             
    handles.spurA = line( handles.spurAx, handles.spurAy );  
    set(handles.spurA,'LineStyle','-', 'Color','r'); 

    % construct line objects for the upper-limit joint spurs
    handles.spurB = line( handles.spurBx, handles.spurBy );  
    set(handles.spurB,'LineStyle','-', 'Color','r');    

    
    % construct line objects for the force-length graphs
    axes(handles.axes_seg1);
    title('muscle force-length');
    xlabel('joint angle');
    handles.ForceLength(1) = line(0,0 );  
    redraw_forcelength(handles,1);
    
    axes(handles.axes_seg2);
    title('muscle force-length');
    xlabel('joint angle');
    handles.ForceLength(2) = line(0,0 );  
    redraw_forcelength(handles,2);
    
    axes(handles.axes_seg3);
    title('muscle force-length');
    xlabel('joint angle');
    handles.ForceLength(3) = line(0,0 );
    redraw_forcelength(handles,3);
  
    % Update handles structure
    guidata(hObject, handles);
    
    % UIWAIT makes ArmMuscleDemo wait for user response (see UIRESUME)
    % uiwait(handles.figure1);    
end


function [Sx,Sy] = midpoints(L,theta)
% returns the midpoints of the three arm segments having the given
% lengths (L) and orientations (theta) when the endpoint of the first segment 
% is anchored at {0,0}.
    Sx(1) = -L(1)/2 * cos(theta(1));
    Sy(1) = -L(1)/2 * sin(theta(1));
    Sx(2) = -L(1) * cos(theta(1)) - L(2)/2 * cos(theta(2));
    Sy(2) = -L(1) * sin(theta(1)) - L(2)/2 * sin(theta(2));
    Sx(3) = -L(1) * cos(theta(1)) - L(2) * cos(theta(2)) - L(3)/2 * cos(theta(3));
    Sy(3) = -L(1) * sin(theta(1)) - L(2) * sin(theta(2)) - L(3)/2 * sin(theta(3));
end


function [Px,Py] = endpoints(Sx,Sy,L,theta)
% returns the endpoints of the three arm segments
    Px = [ Sx + ( L/2 .* cos(theta) ) ; Sx - ( L/2 .* cos(theta) ) ]';
    Py = [ Sy + ( L/2 .* sin(theta) ) ; Sy - ( L/2 .* sin(theta) ) ]';
end


function [PAx,PAy, PBx,PBy] = jointspurs(Sx,Sy,L,theta,psimin,psimax)
% returns lines representing the joint angle limits
    Px = Sx + ( L/2 .* cos(theta) );
    Py = Sy + ( L/2 .* sin(theta) );
    PAx = [ Px; Px + 0.2*cos([pi theta(1) theta(2)]-psimin) ];
    PAy = [ Py; Py + 0.2*sin([pi theta(1) theta(2)]-psimin) ];
    PBx = [ Px; Px + 0.2*cos([pi theta(1) theta(2)]-psimax) ];
    PBy = [ Py; Py + 0.2*sin([pi theta(1) theta(2)]-psimax) ];
end


function redraw_arm(handles)
% redraw the arm plot

    % update the endpoints of the plotted segments
    set(handles.seg1,'XData', handles.Px(1,:));
    set(handles.seg1,'YData', handles.Py(1,:));
    set(handles.seg2,'XData', handles.Px(2,:));
    set(handles.seg2,'YData', handles.Py(2,:));
    set(handles.seg3,'XData', handles.Px(3,:));
    set(handles.seg3,'YData', handles.Py(3,:)); 
    
    % update the joint spur line objects
    set(handles.spurA(1),'XData', handles.spurAx(:,1));
    set(handles.spurA(2),'XData', handles.spurAx(:,2));
    set(handles.spurA(3),'XData', handles.spurAx(:,3));
    set(handles.spurA(1),'YData', handles.spurAy(:,1));
    set(handles.spurA(2),'YData', handles.spurAy(:,2));
    set(handles.spurA(3),'YData', handles.spurAy(:,3));
    set(handles.spurB(1),'XData', handles.spurBx(:,1));
    set(handles.spurB(2),'XData', handles.spurBx(:,2));
    set(handles.spurB(3),'XData', handles.spurBx(:,3));
    set(handles.spurB(1),'YData', handles.spurBy(:,1));
    set(handles.spurB(2),'YData', handles.spurBy(:,2));
    set(handles.spurB(3),'YData', handles.spurBy(:,3));

    drawnow;
end

function redraw_forcelength(handles,i)
    % redraw muscle force curves for segment i
    psiA = handles.parm.psiminA(i)+0.01 : 0.02 :  handles.parm.psimaxA(i)-0.01;
    psiB = 2*pi-psiA;
    
    % Combined force-length relationship of agonist and antagonist muscles
    Fl = handles.parm.actA(i) .* handles.parm.FmaxA(i) .* marmFl(psiA, handles.parm.psimidA(i), handles.parm.KlA(i)) ...
       - handles.parm.actB(i) .* handles.parm.FmaxB(i) .* marmFl(psiB, handles.parm.psimidB(i), handles.parm.KlB(i)) ...
       + handles.parm.FmaxA(i) .* marmFpe(psiA, handles.parm.psiminA(i), handles.parm.psimaxA(i), handles.parm.KpeA(i)) ...
       - handles.parm.FmaxB(i) .* marmFpe(psiB, handles.parm.psiminB(i), handles.parm.psimaxB(i), handles.parm.KpeB(i)); 
  
    set(handles.ForceLength(i), 'Xdata',psiA);
    set(handles.ForceLength(i), 'Ydata',Fl);
end


% --- Executes on timer tick
function runtimer_callback(obj,event,hFigure1)

    %get GUI handles
    handles = guidata(hFigure1);
    
    tMM = floor(handles.t/60);
    tSS = mod(handles.t,60);
    set(handles.timertext, 'String', [ num2str(tMM,'%02d'), ':' ,num2str(tSS,'%04.1f') ]);
    
    % integrate the equations of motion for the arm
    tstep = get(handles.runtimer, 'Period');
    trange = [handles.t handles.t+tstep];    
    [t,Sx,Sy,Vx,Vy,theta,omega]=marm3ode(trange, ...
                                         handles.Sx, handles.Sy, ...
                                         handles.Vx, handles.Vy, ...
                                         handles.theta, handles.omega, ...
                                         handles.parm);
    handles.t = t(end);
    handles.Sx=Sx(end,:);
    handles.Sy=Sy(end,:);
    handles.Vx=Vx(end,:);
    handles.Vy=Vy(end,:);
    handles.theta=theta(end,:);
    handles.omega=omega(end,:);   
    
    % update the endpoints of the plotted segments
    [handles.Px,handles.Py] = endpoints(handles.Sx,handles.Sy,handles.parm.L,handles.theta);  

    % update the geometry of the joint spurs
    [handles.spurAx, handles.spurAy, ...
     handles.spurBx, handles.spurBy] = jointspurs(handles.Sx, handles.Sy, handles.parm.L,...
                                                  handles.theta, handles.parm.psiminA, handles.parm.psimaxA);
    
    % Update handles structure
    guidata(hFigure1, handles);

    % replot the arm
    redraw_arm(handles);   
end



function newhandles = update_parm(hObject, eventdata, handles)

    % extract all editbox values regardless of which ones actually changed
    handles.parm.M(1) = editbox_str2double(handles.editmass1, handles.parm.M(1));
    handles.parm.M(2) = editbox_str2double(handles.editmass2, handles.parm.M(2));
    handles.parm.M(3) = editbox_str2double(handles.editmass3, handles.parm.M(3));

    handles.parm.L(1) = editbox_str2double(handles.editlength1, handles.parm.L(1));
    handles.parm.L(2) = editbox_str2double(handles.editlength2, handles.parm.L(2));
    handles.parm.L(3) = editbox_str2double(handles.editlength3, handles.parm.L(3));
   
    % psi = joint angle 
    handles.parm.psiminA(1) = editbox_str2double(handles.editpsimin1, handles.parm.psiminA(1));
    handles.parm.psiminA(2) = editbox_str2double(handles.editpsimin2, handles.parm.psiminA(2));
    handles.parm.psiminA(3) = editbox_str2double(handles.editpsimin3, handles.parm.psiminA(3));

    handles.parm.psimaxA(1) = editbox_str2double(handles.editpsimax1, handles.parm.psimaxA(1));
    handles.parm.psimaxA(2) = editbox_str2double(handles.editpsimax2, handles.parm.psimaxA(2));
    handles.parm.psimaxA(3) = editbox_str2double(handles.editpsimax3, handles.parm.psimaxA(3));
    
    handles.parm.psiminB = 2*pi-handles.parm.psimaxA;
    handles.parm.psimaxB = 2*pi-handles.parm.psiminA;

    handles.parm.psimidA(1) = editbox_str2double(handles.editpsimid1, handles.parm.psimidA(1));
    handles.parm.psimidA(2) = editbox_str2double(handles.editpsimid2, handles.parm.psimidA(2));
    handles.parm.psimidA(3) = editbox_str2double(handles.editpsimid3, handles.parm.psimidA(3));
    
    handles.parm.psimidB = handles.parm.psimidA;
    
    handles.parm.Kf(1) = editbox_str2double(handles.editKf1, handles.parm.Kf(1));
    handles.parm.Kf(2) = editbox_str2double(handles.editKf2, handles.parm.Kf(2));
    handles.parm.Kf(3) = editbox_str2double(handles.editKf3, handles.parm.Kf(3));

    handles.parm.Kt(1) = editbox_str2double(handles.editKt1, handles.parm.Kt(1));
    handles.parm.Kt(2) = editbox_str2double(handles.editKt2, handles.parm.Kt(2));
    handles.parm.Kt(3) = editbox_str2double(handles.editKt3, handles.parm.Kt(3));
    
    handles.parm.Ks = mean(handles.parm.M);
    handles.parm.Kd = mean(handles.parm.M);

    handles.parm.KpeA(1) = editbox_str2double(handles.editKpe1, handles.parm.KpeA(1));
    handles.parm.KpeA(2) = editbox_str2double(handles.editKpe2, handles.parm.KpeA(2));
    handles.parm.KpeA(3) = editbox_str2double(handles.editKpe3, handles.parm.KpeA(3));

    handles.parm.KpeB(1) = handles.parm.KpeA(1);
    handles.parm.KpeB(2) = handles.parm.KpeA(2);
    handles.parm.KpeB(3) = handles.parm.KpeA(3);

    handles.parm.KlA(1) = editbox_str2double(handles.editKl1, handles.parm.KlA(1));
    handles.parm.KlA(2) = editbox_str2double(handles.editKl2, handles.parm.KlA(2));
    handles.parm.KlA(3) = editbox_str2double(handles.editKl3, handles.parm.KlA(3));

    handles.parm.KlB(1) = handles.parm.KlA(1);
    handles.parm.KlB(2) = handles.parm.KlA(2);
    handles.parm.KlB(3) = handles.parm.KlA(3);

    handles.parm.KvA(1)  = editbox_str2double(handles.editKv1, handles.parm.KvA(1));
    handles.parm.KvA(2)  = editbox_str2double(handles.editKv2, handles.parm.KvA(2));
    handles.parm.KvA(3)  = editbox_str2double(handles.editKv3, handles.parm.KvA(3));

    handles.parm.KvB(1)  = handles.parm.KvA(1);
    handles.parm.KvB(2)  = handles.parm.KvA(2);
    handles.parm.KvB(3)  = handles.parm.KvA(3);

    % phi = angle of muscle insertion
    handles.parm.phiA(1) = editbox_str2double(handles.editphiA1, handles.parm.phiA(1));
    handles.parm.phiA(2) = editbox_str2double(handles.editphiA2, handles.parm.phiA(2));
    handles.parm.phiA(3) = editbox_str2double(handles.editphiA3, handles.parm.phiA(3));

    handles.parm.phiB(1) = editbox_str2double(handles.editphiB1, handles.parm.phiB(1));
    handles.parm.phiB(2) = editbox_str2double(handles.editphiB2, handles.parm.phiB(2));
    handles.parm.phiB(3) = editbox_str2double(handles.editphiB3, handles.parm.phiB(3));

    handles.parm.phiC(1) = editbox_str2double(handles.editphiC1, handles.parm.phiC(1));
    handles.parm.phiC(2) = editbox_str2double(handles.editphiC2, handles.parm.phiC(2));

    handles.parm.phiD(1) = editbox_str2double(handles.editphiD1, handles.parm.phiD(1));
    handles.parm.phiD(2) = editbox_str2double(handles.editphiD2, handles.parm.phiD(2));

    
    handles.parm.FmaxA(1) = editbox_str2double(handles.editFmaxA1, handles.parm.FmaxA(1));
    handles.parm.FmaxA(2) = editbox_str2double(handles.editFmaxA2, handles.parm.FmaxA(2));
    handles.parm.FmaxA(3) = editbox_str2double(handles.editFmaxA3, handles.parm.FmaxA(3));

    handles.parm.FmaxB(1) = handles.parm.FmaxA(1);
    handles.parm.FmaxB(2) = handles.parm.FmaxA(2);
    handles.parm.FmaxB(3) = handles.parm.FmaxA(3);
           
    % recalculate inertia and gravitational forces
    handles.parm.I = handles.parm.M .* handles.parm.L.^2/12; 
    handles.parm.Gy = -9.81 * handles.parm.M; 

    % recalculate the arm geometry
    [handles.Sx, handles.Sy] = midpoints(handles.parm.L, handles.theta);
    [handles.Px, handles.Py] = endpoints(handles.Sx, handles.Sy, handles.parm.L, handles.theta);  

    % update the geometry of the joint spurs
    [handles.spurAx, handles.spurAy, ...
     handles.spurBx, handles.spurBy] = jointspurs(handles.Sx, handles.Sy, handles.parm.L,...
                                                  handles.theta, handles.parm.psiminA, handles.parm.psimaxA);
    
    % Update handles structure
    guidata(hObject, handles);       
    
    % return updated handles structure
    newhandles = handles;
end


function editbox_Callback(hObject, eventdata, handles)
% hObject    handle to edit box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % extract all editbox values regardless of which ones actually changed
    handles = update_parm(hObject, eventdata, handles);

    % Update handles structure
    %guidata(hObject, handles);       
    
    % redraw the arm
    redraw_arm(handles);
    
    % redraw the force-length plots
    redraw_forcelength(handles,1);
    redraw_forcelength(handles,2);
    redraw_forcelength(handles,3);
    
end

function val = editbox_str2double(hObject, default)
    val = str2double(get(hObject,'String'));
    if isnan(val)
        beep;
        val = default;
    end
end


% --- Executes on slider movement.
function slider_Callback(hObject, eventdata, handles)
% hObject    handle to slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % extract all slider values regardless of which ones actually changed
    handles.parm.actA(1) = get(handles.sliderActA1, 'Value');
    handles.parm.actA(2) = get(handles.sliderActA2, 'Value');
    handles.parm.actA(3) = get(handles.sliderActA3, 'Value');
    handles.parm.actB(1) = get(handles.sliderActB1, 'Value');
    handles.parm.actB(2) = get(handles.sliderActB2, 'Value');
    handles.parm.actB(3) = get(handles.sliderActB3, 'Value');    
    
    % Update handles structure
    guidata(hObject, handles);   
    
    % redraw the force-length plots
    redraw_forcelength(handles,1);
    redraw_forcelength(handles,2);
    redraw_forcelength(handles,3);

end


% --- Executes on button press in runbutton.
function runbutton_Callback(hObject, eventdata, handles)
% hObject    handle to runbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA) 
    
    timerstate = get(handles.runtimer,'Running');
    runbutton_value = get(hObject,'Value');

    % if run button is DOWN and the timer is OFF then start the timer
    if ( runbutton_value==1 && strcmp(timerstate,'off') )
        start(handles.runtimer)
    end
        
    % if run button is UP and the timer is ON then stop the timer
    if ( runbutton_value==0 && strcmp(timerstate,'on') )
        stop(handles.runtimer);
    end
end


% --- Executes on button press in resetbutton.
function resetbutton_Callback(hObject, eventdata, handles)
% hObject    handle to runbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA) 
    
    % reset initial values
    handles.t = 0;                              % time
    handles.Vx = [0 0 0];                       % linear velocity of centre of mass (x-component)
    handles.Vy = [0 0 0];                       % linear velocity of centre of mass (y-component)
    handles.omega = [0 0 0];                    % angular velocity of centre of mass (in radians per sec)
    %handles.theta = [pi pi pi];                 % angular position of centre of mass (in radians)
    
    % randomise joint 1 angle
    thetamin1 = pi + pi - handles.parm.psiminA(1);       
    thetamax1 = pi + pi - handles.parm.psimaxA(1);
    handles.theta(1) = (thetamax1-thetamin1)*rand + thetamin1;

    % randomise joint 2 angle
    thetamin2 = pi + handles.theta(1) - handles.parm.psiminA(2);
    thetamax2 = pi + handles.theta(1) - handles.parm.psimaxA(2);
    handles.theta(2) = (thetamax2-thetamin2)*rand + thetamin2;

    % randomise joint 3 angle
    thetamin3 = pi + handles.theta(2) - handles.parm.psiminA(3);
    thetamax3 = pi + handles.theta(2) - handles.parm.psimaxA(3);
    handles.theta(3) = (thetamax3-thetamin3)*rand + thetamin3;
    
    % recalculate Sx and Sy    
    [handles.Sx,handles.Sy] = midpoints(handles.parm.L,handles.theta);       % positions of centres of mass
    [handles.Px,handles.Py] = endpoints(handles.Sx,handles.Sy,handles.parm.L,handles.theta); % positions of segment endpoints
    
    % recalculate joint spurs
    [handles.spurAx, handles.spurAy, handles.spurBx, handles.spurBy] = jointspurs(handles.Sx, handles.Sy, handles.parm.L,...
                                                                                  handles.theta, handles.parm.psiminA, handles.parm.psimaxA);

    % Update handles structure
    guidata(hObject, handles);

    % replot the arm
    redraw_arm(handles);   
end



% --- Executes on button press in splatbutton.
function splatbutton_Callback(hObject, eventdata, handles)
% hObject    handle to runbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA) 
    
    %randomise arm positions
    handles.Sx = 4*rand(1,3) - 2;
    handles.Sy = 4*rand(1,3) - 2;
    
    %make velocities proportional to positions (ie expanding like an explosion)
    handles.Vx = handles.Sx;
    handles.Vy = handles.Sy;

    % Update handles structure
    guidata(hObject, handles);

    % replot the arm
    redraw_arm(handles);   
    drawnow;
end


% --- Executes during object creation, after setting all properties.
function edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editmass1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
end


% --- Executes during object creation, after setting all properties.
function slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slidertorque1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
    
    % Hint: slider controls usually have a light gray background.
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end

end


