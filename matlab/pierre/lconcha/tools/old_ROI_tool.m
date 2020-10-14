function ROI_tool(varargin);
% function ROI_tool(varargin);
% Function to create ROIs and manipulate ROIs on a montage of images.
% Use with imagescn or iamgesc.
%
% Usage: ROI_tool;
%
% Author: Daniel Herzka  herzkad@nih.gov
% Laboratory of Cardiac Energetics 
% National Heart, Lung and Blood Institute, NIH, DHHS
% Bethesda, MD 20892
% and 
% Medical Imaging Laboratory
% Department of Biomedical Engineering
% Johns Hopkins University Schoold of Medicine
% Baltimore, MD 21205

if isempty(varargin) 
   Action = 'New';
   Image_handles = [];
else
    if ischar(varargin{1})   % sent in an action
        Action = varargin{1};  
    elseif isnumeric(varargin{1}) % sent in a matrix of handles  
        Action = 'New';
        Image_handles = varargin{1};
    else                     % sent in unidentified material
        Action = 'Exit';
    end
end

%disp(['Callback action is ',Action]);

switch Action
case 'New'
    Create_New_Button(Image_handles);

case 'Activate_ROI_Tool'
    Activate_ROI_Tool(varargin(2:end));
    
case 'Deactivate_ROI_Tool'
    Deactivate_ROI_Tool(varargin{2:end});
 
case 'Create_New_ROI'
    Create_New_ROI;

case 'Delete_ROI'
    Delete_ROI;
    
case 'Copy_Current_ROI'
    Copy_Current_ROI;

case 'Paste_Current_ROI'
    Paste_Current_ROI;

case 'Change_Current_Axes'
    Change_Current_Axes;

case 'Change_Current_ROI'
    Change_Current_ROI;

    
case 'ROI_Angle_Adjust_Entry'
    % Entry
    ROI_Angle_Adjust_Entry;
case 'ROI_Angle_Adjust'
    % Cycle
    ROI_Angle_Adjust;
case 'ROI_Angle_Adjust_Exit'
    % Exit
    set(gcf, 'WindowButtonMotionFcn', ' ','WindowButtonUpFcn', ' ');
    ROI_Angle_Adjust_Exit;    
    
case 'ROI_Size_Adjust_Entry'
    % Entry
    ROI_Size_Adjust_Entry;
case 'ROI_Size_Adjust'
    % Cycle
    ROI_Size_Adjust;
case 'ROI_Size_Adjust_Exit'
    % Exit
    set(gcf, 'WindowButtonMotionFcn', ' ','WindowButtonUpFcn', ' ');
    ROI_Size_Adjust_Exit;    
    
    
case 'ROI_Pos_Adjust_Entry'
    % Entry
    ROI_Pos_Adjust_Entry(varargin{2});
case 'ROI_Pos_Adjust'
    % Cycle
    ROI_Pos_Adjust(varargin{2});
case 'ROI_Pos_Adjust_Exit'
    % Exit
    set(gcf, 'WindowButtonMotionFcn', ' ','WindowButtonUpFcn', ' ');
    ROI_Pos_Adjust_Exit;  
  
case 'Resort_ROI_Info_Listbox'
    Resort_ROI_Info_Listbox(varargin{2});
case 'Listbox_Change_Current_ROI'
    Listbox_Change_Current_ROI;

case 'Save_ROI'
    Save_ROI(varargin{2:end});
    %Save_ROI;
    
case 'Load_ROI'
    Load_ROI(varargin{2:end});
    %Load_ROI;
case 'Close_Parent_Figure'
    Close_Parent_Figure;
    
case 'Menu_ROI_Tool'
	Menu_ROI_Tool;
	
case 'Exit';
    disp('Unknown Input Argument');
    
otherwise
    disp(['Unimplemented Functionality: ', Action]);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Create_New_Button(varargin)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
fig = gcf;

% Find handle for current image toolbar and menubar
hToolbar = findall(fig, 'type', 'uitoolbar');
hToolMenu = findall(fig, 'Label', '&Tools');
hToolbar_Children = get(hToolbar, 'Children');

if isempty(findobj(hToolbar_Children,'Tag', 'figROITool')) 
    
   % The default button size is 15 x 16 x 3. Create Button Image
   button_size_x= 16;
   button_image = NaN* zeros(15,button_size_x);
   f = [...
     6     7     8     9    10    19    27    33    36    37    38    39    40    43    47    51 ...
    53    59    62    66    67    69    70    74    91    96    97    98    99   100   105   106 ...
   111   115   120   121   126   130   135   136   141   142   143   144   145   150   167   171 ...
   175   179   182   186   187   188   189   190   194   198   201   205   208   214   222   231 ...
   232   233   234];
   button_image(f) = 0;
   button_image = repmat(button_image, [1,1,3]);

   separator = 'off';
   if isempty(findobj(hToolbar_Children, 'Tag', 'figWindowLevel')) | ...
           isempty(findobj(hToolbar_Children, 'Tag', 'figPanZoom'))
       separator = 'on';
   end;
      
   %temp_table = struct('ROI_Data',[], 'ROI_Exists', [], 'ROI_Info', []);
   
   hNewButton = uitoggletool(hToolbar);
   set(hNewButton, 'Cdata', button_image, ...
      'OnCallback', 'ROI_tool(''Activate_ROI_Tool'')',...
      'OffCallback', 'ROI_tool(''Deactivate_ROI_Tool'')',...
      'Tag', 'figROITool', ...
      'TooltipString', 'Create and Manipulate ROIs',...
      ...%'UserData', {temp_table, h_all_axes}, ...
      'Separator', separator, ...
      'Enable', 'on');   
   
  hWindowLevelMenu = findobj(hToolMenu, 'Tag', 'menuWindowLevel');
  hPanZoomMenu     = findobj(hToolMenu, 'Tag', 'menuPanZoom');
  %hROIToolMenu     = findobj(hToolMenu, 'Tag', 'menuROITool');
  hViewImageMenu   = findobj(hToolMenu, 'Tag', 'menuViewImages');
  hPointToolMenu   = findobj(hToolMenu, 'Tag', 'menuPointTool');
  hRotateToolMenu  = findobj(hToolMenu, 'Tag', 'menuRotateTool');
  
  position = 9;
  separator = 'On';
  hMenus = [ hWindowLevelMenu, hPanZoomMenu, hViewImageMenu, hPointToolMenu,hRotateToolMenu ];
  if length(hMenus>0) 
	  position = position + length(hMenus);
	  separator = 'Off';
  end;
  
  hNewMenu = uimenu(hToolMenu,'Position', position);
  set(hNewMenu, 'Tag', 'menuROITool','Label',...
      'ROI Tool',...
      'CallBack', 'ROI_tool(''Menu_ROI_Tool'')',...
      'Separator', separator,...
      'UserData', hNewButton...
  ); 
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Activate_ROI_Tool(varargin);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%disp('Calling: Activate_ROI_Tool');
%varargin{1}
%nargin

if nargin == 0 | isempty(varargin{1})
    set(0, 'ShowHiddenHandles', 'On');
    hNewButton = gcbo;
    set(findobj('Tag', 'menuROITool'),'checked', 'on');
else % sent in something (could be empty)
    %if  isempty(varargin{1}(1))
    t = varargin{1};
    hNewButton = t{1};
end;

% allows for calls from buttons other than those in toolbar
fig = get(hNewButton, 'Parent');
if ~strcmp(get(fig, 'Type'), 'figure')
    fig = get(fig, 'Parent');
end;


% Deactivate zoom and rotate buttons
hToolbar = findall(fig, 'type', 'uitoolbar');
if ~isempty(hToolbar)
	hToolbar_Children = get(hToolbar, 'Children');
	
	% disable MATLAB's own tools
	Rot3D = findobj(hToolbar_Children,'Tag', 'figToolRotate3D');
	ZoomO = findobj(hToolbar_Children,'Tag', 'figToolZoomOut');
	ZoomI = findobj(hToolbar_Children,'Tag', 'figToolZoomIn');

	% try to disable other tools buttons - if they exist
	WL = findobj(hToolbar_Children, 'Tag', 'figWindowLevel');
	PZ = findobj(hToolbar_Children, 'Tag', 'figPanZoom');
	RT = findobj(hToolbar_Children, 'Tag', 'figROITool');
	MV = findobj(hToolbar_Children, 'Tag', 'figViewImages');
	PM = findobj(hToolbar_Children, 'Tag', 'figPointTool');
	RotT = findobj(hToolbar_Children, 'Tag', 'figRotateTool');
	
	old_ToolHandles  =     [Rot3D, ZoomO, ZoomI,WL,PZ,MV,PM,RotT];
	old_ToolEnables  = get([Rot3D, ZoomO, ZoomI,WL,PZ,MV,PM,RotT], 'Enable');
	old_ToolStates   = get([Rot3D, ZoomO, ZoomI,WL,PZ,MV,PM,RotT], 'State');
	
	for i = 1:length(old_ToolHandles)
		if strcmp(old_ToolStates(i) , 'on')			
			set(old_ToolHandles(i), 'State', 'Off');
		end;
		set(old_ToolHandles(i), 'Enable', 'Off');
	end;
end;

% Start ROI Tool GUI
fig2_old = findobj('Tag', 'RT_figure');
% close the old RT figure to avoid conflicts
if ~isempty(fig2_old) 
    set(fig2_old, 'CloseRequestFcn', 'closereq');
	try close(fig2_old)
	catch delete(fig2_old)
	end;
end;
% close exisiting info figures to avoid conflicts
ifig_old = findobj('Tag', 'RTi_figure');
if ~isempty(ifig_old)
        set(ifig_old, 'CloseRequestFcn', 'closereq');
        try close(ifig_old);
		catch delete(ifig_old);  % TEMP??
		end;
end;
    
% open new figure
fig2 = openfig('ROI_tool_figure','reuse');

% Generate a structure of handles to pass to callbacks, and store it. 
handles = guihandles(fig2);
guidata(fig2,handles);

close_str = [ 'hNewButton = findobj(''Tag'', ''figROITool'');' ...
        ' if strcmp(get(hNewButton, ''Type''), ''uitoggletool''),'....
        ' set(hNewButton, ''State'', ''off'' );' ...
        ' else,  ' ...
        ' ROI_Tool(''Deactivate_ROI_Tool'' ,hNewButton);'...
        ' set(hNewButton, ''Value'', 0);',...
        ' end;' ];

set(fig2, 'Name', 'ROI Tool', ... 
    'CloseRequestfcn', close_str);

% Record and store previous WBDF etc to restore state after RT is done. 
old_WBDF = get(fig, 'WindowButtonDownFcn');
old_WBMF = get(fig, 'WindowButtonMotionFcn');
old_WBUF = get(fig, 'WindowButtonUpFcn');
old_UserData = get(fig, 'UserData');
old_CRF = get(fig, 'Closerequestfcn');

% Store initial state of all axes in current figure for reset
UserData = get(hNewButton,'Userdata');
if isempty(UserData)
    ROI_info_table = struct('ROI_Data',[], 'ROI_Exists', [], 'ROI_Info', []);
    h_all_axes = Find_All_Axes(fig);
else
    ROI_info_table = UserData{1};
    h_all_axes = UserData{2};
end;
%h_all_axes    
%h_all_axes(find(h_all_axes(:)))

h_axes = h_all_axes(1,1);
set(fig, 'CurrentAxes', h_axes);

h_all_axes=h_all_axes';
% store all the old nextplots and bdf's
for i = 1:length(find(h_all_axes(:)))
    if (h_all_axes(i))
        old_axes_BDF{i} = get(h_all_axes(i), 'ButtonDownFcn');
        old_axes_NextPlot{i} = get(h_all_axes(i),'NextPlot');
		h_image = findobj(h_all_axes(i), 'Type', 'Image');

		set(h_all_axes(i),'NextPlot', 'add');
		old_image_BDF{i} = get(h_image, 'ButtonDownFcn');
        set(h_image,'ButtonDownFcn', 'ROI_Tool(''Change_Current_Axes'')');
    end;
end;
h_all_axes = h_all_axes';
set(fig, 'CurrentAxes', h_axes);

% Draw faster and without flashes
set(fig, 'Closerequestfcn', [ old_CRF , ',ROI_Tool(''Close_Parent_Figure'')']);
set(fig, 'Renderer', 'zbuffer');
set(0, 'ShowHiddenHandles', 'On', 'CurrentFigure', fig);
set(gca,'Drawmode', 'Fast');

% store the figure's old infor within the fig's own userdata
set(fig, 'UserData', {fig2, old_WBDF, old_WBMF, old_WBUF, ... 
        old_UserData, old_axes_BDF, old_axes_NextPlot, old_CRF, old_image_BDF, ...
		old_ToolEnables,old_ToolHandles});


% Now check if previous use of ROI Tool left an ROI_info_table with handles to reset
if isempty([ROI_info_table.ROI_Exists])
    % disable all buttons until an ROI has been created
    Change_Object_Enable_State(handles, 'Off', 1);
    set(hNewButton, 'UserData', {ROI_info_table, h_all_axes});
    i_current_ROI = [];
    ifig = [];
else    
    
    % set all graphics related to each ROI to visible and
    % allot the appropiate callback to each one
    h_ROI_elements = [ROI_info_table(:).ROI_Data];
    h_ROI_elements = h_ROI_elements(1,:);
    h_ROI_elements = h_ROI_elements(find(h_ROI_elements));
    
    %give each element the correct callack function
    %h_circle, h_center, h_size, h_angle, h_number; 
    set(h_ROI_elements(1:5:end),'Visible', 'On', 'ButtonDownFcn', 'ROI_Tool(''Change_Current_ROI'')');    
    set(h_ROI_elements(2:5:end),'Visible', 'On', 'ButtonDownFcn', 'ROI_Tool(''ROI_Pos_Adjust_Entry'',1)');    
    set(h_ROI_elements(3:5:end),'Visible', 'On', 'ButtonDownFcn', 'ROI_Tool(''ROI_Size_Adjust_Entry'')');    
    set(h_ROI_elements(4:5:end),'Visible', 'On', 'ButtonDownFcn', 'ROI_Tool(''ROI_Angle_Adjust_Entry'')');    
    set(h_ROI_elements(5:5:end),'Visible', 'On', 'ButtonDownFcn', 'ROI_Tool(''ROI_Pos_Adjust_Entry'',2)');    

    % Enable Buttons since ROIs exists, but not the paste objects
    Change_Object_Enable_State(handles, 'Off', 1);
    Change_Object_Enable_State(handles, 'On', 0);
    
    % if this is a re-run, there exists a UserData{3}
    old_current_info = UserData{3};
    h_axes = old_current_info{4};          % current axes
    i_current_ROI = old_current_info{5};   % current ROI(s)
    
    % open new figure for ROI information
    % set info in holder temporarily so that the Create function can use it
    set(handles.ROI_Title_text, 'UserData', {fig, fig2, h_all_axes, h_axes, i_current_ROI, []});
    ifig = Create_ROI_Info_Figure(ROI_info_table, i_current_ROI);
    Resort_ROI_Info_Listbox;
        
    % now erase the stored data from reactivation from the userdata of the button
    set(hNewButton,'Userdata', {ROI_info_table,h_all_axes} );
end;

% store all relevant info for faster use during calls
set(handles.ROI_Title_text, 'UserData', {fig, fig2, h_all_axes, h_axes, i_current_ROI, ifig});


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Deactivate_ROI_Tool(varargin);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%disp('Calling: Deactive_ROI_Tool');

if nargin == 0     
    % called from button
    set(0, 'ShowHiddenHandles', 'On');    
    hNewButton = gcbo;
    set(findobj('Tag', 'menuROITool'),'checked', 'Off');
else
    % called from menu
    hNewButton = varargin{1};
end;
    
% Reactivate other buttons
fig = get(hNewButton, 'Parent');
if ~strcmp(get(fig, 'Type'), 'figure'),
    fig = get(fig, 'Parent');
end

hToolbar = findall(fig, 'type', 'uitoolbar');
if ~isempty(hToolbar)
    hToolbar_Children = get(hToolbar, 'Children');
    set(findobj(hToolbar_Children,'Tag', 'figToolRotate3D'),'Enable', 'On');
    set(findobj(hToolbar_Children,'Tag', 'figToolZoomOut'),'Enable', 'On');
    set(findobj(hToolbar_Children,'Tag', 'figToolZoomIn'),'Enable', 'On'); 
end;
   
% Restore old WBDFs and USer Data
old_info= get(fig,'UserData');
fig2 = old_info{1};
set(fig, 'WindowButtonDownFcn', old_info{2});
set(fig, 'WindowButtonUpFcn', old_info{3});
set(fig, 'WindowButtonMotionFcn', old_info{4});
set(fig, 'UserData', old_info{5});
set(fig, 'closerequestfcn', old_info{8});
old_ToolEnables  = old_info{10}; 
old_ToolHandles = old_info{11};

% restore axes BDF's and hide all objects by making invisible
% and clearing all object's bdf's

Userdata=get(hNewButton, 'UserData');
ROI_info_table = Userdata{1};
exist_flags = [Userdata{1}.ROI_Exists];

h_all_axes = Userdata{2};
ROI_info_table = Userdata{1};

%save temp_old_info old_info h_all_axes Userdata
h_all_axes = h_all_axes';   % TEMP
for i = 1:length(find(h_all_axes(:)))
	set(h_all_axes(i),'ButtonDownFcn', char(old_info{6}(i)), 'NextPlot', char(old_info{7}(i)));    
	h_image = findobj(h_all_axes(i), 'Type', 'Image');
	set(h_image, 'ButtonDownFcn', char(old_info{9}(i)));
end     

% in case an ROI was created...
if ~isempty(exist_flags)
    h_ROI_elements = [ROI_info_table(:).ROI_Data];
    h_ROI_elements = h_ROI_elements(1,:);    
    set(h_ROI_elements(find(h_ROI_elements)),'Visible', 'Off', 'ButtonDownFcn', '');    
end;

% store current state, that is, current axes, current ROI into memory to be used next
% start of the ROI Tool
current_info = get(findobj(fig2, 'Tag','ROI_Title_text'), 'Userdata');
set(hNewButton, 'Userdata', {Userdata{1}, Userdata{2}, current_info});

try
    ifig = current_info{6};
    if ~isempty(ifig)
        set(ifig, 'CloseRequestFcn', 'closereq');
		try
			close(ifig); 
		catch
			delete(ifig);
		end;
    end;
catch
end;    

fig2 = old_info{1};
try
	set(fig2, 'CloseRequestFcn', 'closereq');
	close(fig2); 
catch
	delete(fig2);
end;    

for i = 1:length(old_ToolHandles)
	try
		set(old_ToolHandles(i), 'Enable', old_ToolEnables{i});
	catch
	end;
end;


set(0, 'ShowHiddenHandles', 'Off');




%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Create_New_ROI(varargin);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function creates new ROI. If this is the first ROI at all, creates the table of 
% ROI info. If the table alreay exists, then adds a new row to the ROI info table
% ROI info table is ROIs x Num Images long;

% load data of interest
h_all_axes = get(findobj('Tag', 'ROI_Title_text'), 'UserData');
fig = h_all_axes{1};
fig2 = h_all_axes{2};
ifig = h_all_axes{6};
h_axes = h_all_axes{4};
i_current_ROI = h_all_axes{5};
h_all_axes = h_all_axes{3};

handles = guidata(fig2);
apply_all = get(handles.Create_ROI_checkbox,'Value');
create_polygon = get(handles.Create_Poly_checkbox, 'Value');


% get old ROI_info table
Userdata = get(findobj(fig, 'Tag', 'figROITool'), 'UserData');
ROI_table = Userdata{1};

% if all ROI exist fields are empty, then this is the first ROI
if isempty([ROI_table(:).ROI_Exists])
    % create ROI info table to correct size (rows = number of ROIs, columns = images) 
    % now make the invalid last in case grid is not complete
    temp_h_all_axes = find(h_all_axes);
    % cycle through to create 0's in the Exist field. marks the ROI table as initialized
    [ROI_info_table(1,1:length(temp_h_all_axes)).ROI_Exists] = deal(0);
    first_ROI_flag = 1;    
else
    % an ROI table exists, use it;
    ROI_info_table = ROI_table;    
    first_ROI_flag = 0;
end;
    
% find empty slots in ROI_info Table
Current_ROI_index = [];
for i = size(ROI_info_table,1):-1:1
    % found empty slot, use it; search in reverse to use the nearest one    
    if ~([ROI_info_table(i,:).ROI_Exists])
        Current_ROI_index = i;
    end;
end;
    
% if didn't find an empty slot, create a new row in ROI info table
if isempty(Current_ROI_index)
    Current_ROI_index = size(ROI_info_table,1) + 1;
    [ROI_info_table(Current_ROI_index,1:length(find(h_all_axes))).ROI_Exists] = deal(0);
end;
    
% make sure we don't over clutter the screen
if Current_ROI_index > 10
    msgbox('Too Many ROIs. Please delete some before creating new ones.');
    return;
end;

% colors: red, blue, green, yellow, magenta, cyan, white 
colororder = repmat('rbgymcw',1,4);

if apply_all % create ROI in all images
    % flipud to create ROI in reverse order... so that the current ROI index 
    % one on the first image  
    t_h_all_axes = h_all_axes';
    h_axes_interest = flipud(h_all_axes(find(h_all_axes)));

else
    h_axes_interest = h_axes;
end;


if ~create_polygon  
    % create an ellipse, default
    for i = 1:length(h_axes_interest(:))
        set(fig, 'CurrentAxes', h_axes_interest(i));
        h_axes_index = find(h_all_axes'==h_axes_interest(i));
        set(0, 'CurrentFigure', fig);
        xlim = get(gca, 'xlim');
        ylim = get(gca, 'ylim');
        
        center_x = mean(xlim);
        center_y = mean(ylim);
        
        percent_size_ROI = 0.1;
        size_x = diff(xlim)*percent_size_ROI;
        size_y = diff(xlim)*percent_size_ROI;
        
        basic_points = 32;
        theta = 0:(360/basic_points):360;
        [x,y] = pol2cart(theta*pi/180, repmat(size_x,size(theta,1), size(theta,2)));
        alpha = 0 ;
        
        % now plot circle with basic points, transformed by skew, rotation, and translation
        h_circle = plot(x+center_x,y+center_y,[colororder(Current_ROI_index),'-'],...
            'ButtonDownFcn', 'ROI_Tool(''Change_Current_ROI'')');
        
        h_center = plot(center_x, center_y , [colororder(Current_ROI_index),'+'], ...
            'ButtonDownFcn', 'ROI_Tool(''ROI_Pos_Adjust_Entry'',1)'); 
        
        h_size = plot(center_x - size_x, center_y - size_y, [colororder(Current_ROI_index),'s'],...
            'ButtonDownFcn', 'ROI_Tool(''ROI_Size_Adjust_Entry'')');    
        
        h_angle = plot(center_x+size_x, center_y, [colororder(Current_ROI_index),'o'],...
            'ButtonDownFcn', 'ROI_Tool(''ROI_Angle_Adjust_Entry'')');
        
        h_number = text(center_x + size_x, center_y - size_y, num2str(Current_ROI_index),'color', ...
            [colororder(Current_ROI_index)], 'HorizontalAlignment', 'center' , ...
            'ButtonDownFcn', 'ROI_Tool(''ROI_Pos_Adjust_Entry'',2)'); 
        
        handle_values = [h_circle, h_center, h_size, h_angle, h_number];
        ROI_values = [center_x, center_y, size_x, size_y, alpha];
        
        set(handle_values, 'UserData', ...
            [Current_ROI_index, h_axes_index, handle_values, ROI_values ]);
        ROI_info_table(Current_ROI_index,h_axes_index).ROI_Data = ...
            [handle_values; ...
                ROI_values];
        ROI_info_table(Current_ROI_index, h_axes_index).ROI_Exists = 1;
        
        update_list(i,:) = [Current_ROI_index, h_axes_index];
        
        i_current_ROI = [Current_ROI_index, h_axes_index];
        drawnow
    end;
else
    % user wants to create its own polygon
    % call ROI_poly top get coordinates of new 
    
    % set the current axes
    set(fig, 'CurrentAxes', h_axes);
    h_image = findobj(h_axes, 'Type','Image');
    image_values = get(h_image,'CData');
    axes_values = get(h_axes, {'xlim', 'ylim', 'clim'});
    ff=figure;
    set(ff, 'menubar', 'none', 'Name','Select Polygon ROI')
    imagesc(image_values);
    axis equal
    axis off
    set(gca,'xlim', axes_values{1},'ylim', axes_values{2}, 'clim', axes_values{3});
    
    % binary mask and x and y coordinates of ROI
    [BW,x,y] = roipoly;
    %plot(xi,yi, 'r-.');
    %pause
    close(ff);
    
    center_x = mean(x);
    center_y = mean(y);
    
    
    size_x1 = max(x) - center_x;
    size_x2 = abs(min(x)-center_x);
    size_y = abs(min(y) - center_y);
    
    angle_point_x = x(find(x==max(x)));
    angle_point_y = y(find(x==max(x)));
    
    v1 = [1 0];
    v2 = [angle_point_x, angle_point_y] - [center_x, center_y] ;
    d = cross([v1 0],[v2 0]);
    alpha = acos(  dot(v1,v2)   /(norm(v1) * norm(v2)) ) *sign(d(3));
    
    
    
    for i = 1:length(h_axes_interest(:))
        set(fig, 'CurrentAxes', h_axes_interest(i));
        h_axes_index = find(h_all_axes'==h_axes_interest(i));
        set(0, 'CurrentFigure', fig);

        % now plot circle with basic points, transformed by skew, rotation, and translation
        h_circle = plot(x,y,[colororder(Current_ROI_index),'-'],...
            'ButtonDownFcn', 'ROI_Tool(''Change_Current_ROI'')');
        
        h_center = plot(center_x, center_y , [colororder(Current_ROI_index),'+'], ...
            'ButtonDownFcn', 'ROI_Tool(''ROI_Pos_Adjust_Entry'',1)'); 
        
        h_size = plot(center_x - size_x2, center_y - size_y, [colororder(Current_ROI_index),'s'],...
            'ButtonDownFcn', 'ROI_Tool(''ROI_Size_Adjust_Entry'')');
            
        h_angle = plot(angle_point_x, angle_point_y, [colororder(Current_ROI_index),'o'],...
            'ButtonDownFcn', 'ROI_Tool(''ROI_Angle_Adjust_Entry'')');
        
        h_number = text(center_x + size_x1, center_y - size_y, num2str(Current_ROI_index),'color', ...
            [colororder(Current_ROI_index)], 'HorizontalAlignment', 'center' , ...
            'ButtonDownFcn', 'ROI_Tool(''ROI_Pos_Adjust_Entry'',2)'); 
        
        
        % handle_values = [h_circle, h_center, h_size, h_angle, h_number];
        handle_values = [h_circle, h_center, h_size, h_angle, h_number];
        
        ROI_values = [center_x, center_y, size_x2, size_y, alpha];
        
        set(handle_values, 'UserData', ...
            [Current_ROI_index, h_axes_index, handle_values, ROI_values ]);
        ROI_info_table(Current_ROI_index,h_axes_index).ROI_Data = ...
            [handle_values ; ...
                ROI_values];
        ROI_info_table(Current_ROI_index, h_axes_index).ROI_Exists = 1;
        
        update_list(i,:) = [Current_ROI_index, h_axes_index];
        
        i_current_ROI = [Current_ROI_index, h_axes_index];
    end
        
    
end
% Now Restore ROI_info_table to its hiding spot
Userdata{1} = ROI_info_table;
set(findobj(fig, 'Tag', 'figROITool'), 'UserData', Userdata);

% call the ROI_info update function: puts data into ROI_info_table
Update_ROI_Info(update_list);

if first_ROI_flag
    % creates figure the first time and creates the string table that is to be
    % used for "publishing" the ROI data
    ifig = Create_ROI_Info_Figure(ROI_info_table, update_list);
    % published the string into the listbox
    
    % turn on buttons, but turn off print objects
    Change_Object_Enable_State(handles,'Off',1);
    Change_Object_Enable_State(handles,'On',0);
else
    % call function that will take info string table and "publish" it
    
    Update_ROI_Info(update_list);
    Update_ROI_Info_String(update_list);
end;

Resort_ROI_Info_Listbox;
% update current ROI index
set(findobj('Tag', 'ROI_Title_text'), 'Userdata', { fig, fig2, h_all_axes, h_axes, i_current_ROI, ifig});
Highlight_Current_ROI(i_current_ROI);


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Copy_Current_ROI;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
h_all_axes = get(findobj('Tag', 'ROI_Title_text'), 'UserData');
fig = h_all_axes{1};
fig2 = h_all_axes{2};
i_current_ROI = h_all_axes{5};
UserData = get(findobj(fig, 'Tag', 'figROITool'), 'UserData');
handles = guidata(fig2);
set(handles.Copy_ROI_pushbutton, 'UserData', UserData{1}(i_current_ROI(1), i_current_ROI(2)));
set(handles.Paste_ROI_pushbutton, 'Enable', 'On');
set(handles.Paste_ROI_checkbox, 'Enable', 'On');

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Paste_Current_ROI;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
h_all_axes = get(findobj('Tag', 'ROI_Title_text'), 'UserData');
fig = h_all_axes{1};
fig2 = h_all_axes{2};
h_current_axes = h_all_axes{4};
i_current_ROI = h_all_axes{5};
h_all_axes = [h_all_axes{3}]';

handles = guidata(fig2);

UserData = get(findobj(fig, 'Tag', 'figROITool'), 'UserData');
ROI_info_table = UserData{1};
h_current_ROI_axes = get(ROI_info_table(i_current_ROI(1), i_current_ROI(2)).ROI_Data(1,1),'Parent');

%get the current ROI from the Copy Button's UserData
copy_ROI_info = get(handles.Copy_ROI_pushbutton, 'Userdata');
apply_all = get(handles.Paste_ROI_checkbox, 'Value');

indexes_of_interest = [];
if apply_all
    % paste current ROI parameters to all OTHER images
%    a=h_all_axes~=h_current_ROI_axes
%    b=h_all_axes~=0
%    c = a & b
    indexes_of_interest = find((h_all_axes~=h_current_ROI_axes) & (h_all_axes~=0));
else
    % paste current ROI parameters to selected h_axes unless it is the same axes
 %   a=h_all_axes==h_current_axes
 %   b=h_all_axes~=h_current_ROI_axes
 %   c=a & b    
    indexes_of_interest = find((h_all_axes==h_current_axes) & (h_all_axes~=h_current_ROI_axes));  
end;



update_list = [];
for i =1:length(indexes_of_interest)
    % for each new ROI created, create the ROI with the same parameters
    %    [h_circle, h_center, h_size, h_angle, h_number; ...
    %        center_x, center_y, size_x, size_y, angle];    
    
    h_circle = copyobj(copy_ROI_info.ROI_Data(1,1),...
        h_all_axes(indexes_of_interest(i)));    
    h_center = copyobj(copy_ROI_info.ROI_Data(1,2),...
        h_all_axes(indexes_of_interest(i)));
    h_size = copyobj(copy_ROI_info.ROI_Data(1,3),...
        h_all_axes(indexes_of_interest(i)));
    h_angle = copyobj(copy_ROI_info.ROI_Data(1,4),...
        h_all_axes(indexes_of_interest(i)));
    h_number = copyobj(copy_ROI_info.ROI_Data(1,5),...
        h_all_axes(indexes_of_interest(i)));
    
    val = get(h_number,'Userdata');
    
    exist_current_ROI = ROI_info_table(i_current_ROI(1), indexes_of_interest(i)).ROI_Exists;
    % if the ROI exists, erase it before writing a new one in its place!
    if exist_current_ROI==1
        old_handles = ROI_info_table(i_current_ROI(1), indexes_of_interest(i)).ROI_Data;
        delete(old_handles(1,:));
    end;
        
    ROI_info_table(i_current_ROI(1), indexes_of_interest(i) ).ROI_Data = ...
        [h_circle, h_center, h_size, h_angle, h_number; ...
            ROI_info_table(i_current_ROI(1),i_current_ROI(2)).ROI_Data(2,:)];
    ROI_info_table(i_current_ROI(1), indexes_of_interest(i)).ROI_Exists = 1;
    
    % make sure the objects composing the ROI have the correct indices in the Userdata 
    % for action identification
    set([h_circle, h_center, h_size, h_angle, h_number], 'UserData', ...
        [i_current_ROI(1), indexes_of_interest(i), ...
            h_circle, h_center, h_size, h_angle, h_number,...
            val(8:end)]);
    
    % now add the indexes of the created ROIs to the update list
    update_list(size(update_list,1)+1,:) = [i_current_ROI(1), indexes_of_interest(i)];      
    
end;    
% now restore the modified info table
set(findobj(fig, 'Tag', 'figROITool'), 'UserData', { ROI_info_table, UserData{2}} );
Update_ROI_Info(update_list);
Update_ROI_Info_String(update_list);
Resort_ROI_Info_Listbox;
Highlight_Current_ROI(update_list)

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Delete_ROI;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function to delete an ROI. Check scope of deletion:
%  current ROI
%  All ROIs in current Image
%  All ROIs with same number
%  All ROIs

% load data of interest
h_all_axes = get(findobj('Tag', 'ROI_Title_text'), 'UserData');
fig = h_all_axes{1};
fig2 = h_all_axes{2};
ifig = h_all_axes{6};
h_axes = h_all_axes{4};
i_current_ROI = h_all_axes{5};
h_all_axes = h_all_axes{3};

handles = guidata(fig2);
scope = get(handles.Delete_ROI_popupmenu, 'Value');

update_list = [];
ROIs_left = 0;
% don't want to try to erase if there is not current ROI 
% unless all ROIs are to be deleted
if (~isempty(i_current_ROI)) | (isempty(i_current_ROI) & (scope==4 | scope ==2) )
    UserData = get(findobj(fig, 'Tag', 'figROITool'), 'UserData');
    ROI_info_table = UserData{1};
    new_current_ROI = [];
    switch scope
    case 1 % Current ROI 
        delete(ROI_info_table(i_current_ROI(1), i_current_ROI(2)).ROI_Data(1,:));
        ROI_info_table(i_current_ROI(1), i_current_ROI(2)).ROI_Data = [];
        ROI_info_table(i_current_ROI(1), i_current_ROI(2)).ROI_Info = [];
        ROI_info_table(i_current_ROI(1), i_current_ROI(2)).ROI_Exists = 0;
        
        update_list = [i_current_ROI(1), i_current_ROI(2)];
                
    case 2 % Current Image
        % find current index of ROI
        i_current_axes= find(h_all_axes'==h_axes);
        % take all the data available for the current axes
        temp = ROI_info_table(:,i_current_axes );
        % concatenate it into a 2x[5*n] matrix
        temp = [temp.ROI_Data];
        
        for i = 1:5:size(temp,2)
            temp2 = get(temp(1,i),'Userdata');
            update_list(size(update_list,1)+1,:) = [ temp2(1,1:2)] ;
        end;
        
        delete(temp(1,:));
        [ROI_info_table(:, i_current_axes).ROI_Data]= deal([]);
        [ROI_info_table(:, i_current_axes).ROI_Info]= deal([]);        
        [ROI_info_table(:, i_current_axes).ROI_Exists] = deal(0);            
        % if the current axes and the parent of the current ROI are the same, 
        % then clear out the current ROI index as the ROI does not exist anymore
        if ~isempty(i_current_ROI) & (h_all_axes(i_current_ROI(2))~=h_axes)
            new_current_ROI = i_current_ROI;
        end;
        
    case 3 % Current ROIs
        % take all the ROIs with same number
        temp = ROI_info_table(i_current_ROI(1), :);
        % concatenate it into a 2x[5*n] matrix
        temp = [temp.ROI_Data];
        
        for i = 1:5:size(temp,2)
            temp2 = get(temp(1,i),'Userdata');
            update_list(size(update_list,1)+1,:) = [ temp2(1,1:2)] ;
        end;
        
        delete(temp(1,:));
        [ROI_info_table(i_current_ROI(1), :).ROI_Data] = deal([]);
        [ROI_info_table(i_current_ROI(1), :).ROI_Info] = deal([]);
        [ROI_info_table(i_current_ROI(1),:).ROI_Exists] = deal(0);
         
        
    case 4 % All ROIs
        for i = 1:size(ROI_info_table,1)
            [ROI_info_table(i,:).ROI_Exists] = deal(0); 
            [ROI_info_table(i, :).ROI_Info] = deal([]);                    
            temp = ROI_info_table(i, :);
            temp = [temp.ROI_Data];
            [ROI_info_table(i, :).ROI_Data] = deal([]);

            
            % do not attempt to delete if the whole row of ROIs is empty (been deleted)
            if ~isempty(temp)
                delete(temp(1,:));
            end;
        end;
        ROIs_left = 0;
       
    end;
    
    % restore the info back into its hiding place within the button's Userdata
    set(findobj(fig,  'Tag', 'figROITool'), 'Userdata', { ROI_info_table, UserData{2}});
    % note that there is no longer a current ROI as what was the current ROI was deleted
    set(findobj(fig2, 'Tag', 'ROI_Title_text'), 'Userdata', ...
        {fig, fig2, h_all_axes, h_axes, new_current_ROI, ifig}); 

    % check if there are any ROIs left
    for i = 1:size(ROI_info_table,1)
        temp = ROI_info_table(i, :);
        temp = [temp.ROI_Exists];
        % do not attempt to delete if the whole row of ROIs is empty (been deleted)
        if ~isempty(find(temp))
            ROIs_left = 1;
        end;
    end;
    
    if ROIs_left
        % if there are ROIs left
        Update_ROI_Info_String(update_list);
        Update_ROI_Info_String;  
        Resort_ROI_Info_Listbox;
        Highlight_Current_ROI(new_current_ROI);
    else
        % if there are no ROIs left, close the ROI info figure;
        % turn buttons off since you deleted all ROIs
        Change_Object_Enable_State(handles, 'Off',1);
        
        ROI_info_table = ROI_info_table(1,:);
        [ROI_info_table(1,:).ROI_Data] = deal([]);
        [ROI_info_table(1,:).ROI_Info] = deal([]);
        [ROI_info_table(1,:).ROI_Exists] = deal([]);
        
        % now close the ROI info window;
        set(ifig, 'closerequestfcn', 'closereq');
        close(ifig);
        ifig = [];
        
        % reupdate everything now that ROI info table has changed
        set(findobj(fig,  'Tag', 'figROITool'), 'Userdata', { ROI_info_table, UserData{2}});
        set(findobj(fig2, 'Tag', 'ROI_Title_text'), 'Userdata', ...
            {fig, fig2, h_all_axes, h_axes, new_current_ROI, ifig}); 
    end;    
    
    

end;



%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Change_Current_Axes
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Update the current axes when user clicks on an axes
h_axes= gca;
h_data_holder = findobj('Tag','ROI_Title_text');
data=  get(h_data_holder, 'Userdata');
data{4} = h_axes;
set(h_data_holder,'UserData',data);

% now highlight current axes in the information windows

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Change_Current_ROI(ROI_info)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Update the current ROI when user clicks on an active object
h_ROI_circle= gco;
h_data_holder = findobj('Tag','ROI_Title_text');
data=  get(h_data_holder, 'Userdata');
if nargin==0
    vals = get(h_ROI_circle, 'Userdata');
    data{5} = vals(1:2);
else
   data{5} = ROI_info;
end;
set(h_data_holder,'UserData',data);
Highlight_Current_ROI(data{5})



% now select the current ROI in the information windows

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function ROI_Angle_Adjust_Entry;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Execute once at the beggining of a drag cycle
fig = gcf;
set(fig, 'WindowButtonMotionFcn', 'ROI_Tool(''ROI_Angle_Adjust'');');
set(fig,'WindowButtonUpFcn', 'ROI_Tool(''ROI_Angle_Adjust_Exit'')');
Change_Current_Axes;
ROI_Angle_Adjust;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function ROI_Angle_Adjust
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
h_angle = gco;
h_axes = get(h_angle, 'Parent');
point = get(h_axes,'CurrentPoint');

val = get(h_angle, 'Userdata');
% 1,2  infor table indexes
% 3-7  handle_values = [h_circle, h_center, h_size, h_angle, h_number]
% 8-12 ROI_values = [center_x, center_y, size_x, size_y, angle]

v1 = [point(1,1) point(1,2)]  -[ val(8), val(9)] ;
v2 = [get(h_angle, 'xdata'), get(h_angle, 'ydata')] - [val(8), val(9)];
% get angle (positive only) and multiply it by direction
d = cross([v1 0],[v2 0]);
% calculate angle between the two...
alpha=  acos(  dot(v1,v2)   /(norm(v1) * norm(v2)) ) * -1*sign(d(3));
%alpha_deg = alpha*180/pi
rotmat = [cos(alpha) -sin(alpha); sin(alpha) cos(alpha)];

% now rotate everything by this amount
c = rotmat*[get(val(3),'xdata') - val(8); get(val(3),'ydata') - val(9)];
set(val(3), 'xdata', c(1,:) + val(8), 'ydata', c(2,:) + val(9));
c = rotmat*[get(val(5),'xdata') - val(8); get(val(5),'ydata') - val(9)];
set(val(5), 'xdata', c(1,:) + val(8), 'ydata', c(2,:) + val(9));
c = rotmat*[get(val(6),'xdata') - val(8); get(val(6),'ydata') -  val(9)];
set(val(6), 'xdata', c(1,:)+ val(8), 'ydata', c(2,:)+ val(9));
p = get(val(7),'Position')';
c = rotmat*( [p(1:2) - [val(8) val(9)]']) ;
set(val(7), 'Position', [ c' + [val(8),val(9)] ,p(3)]);

% update only the current object's userdata... 
%set(val(6),'UserData', [val(1:11), alpha]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function ROI_Angle_Adjust_Exit
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
h_angle = gco;
val = get(h_angle, 'Userdata');

% 1,2  infor table indexes
% 3-7  handle_values = [h_circle, h_center, h_size, h_angle, h_number]
% 8-12 ROI_values = [center_x, center_y, size_x, size_y, angle]

v1 = [1 0];
v2 = [get(h_angle, 'xdata'), get(h_angle, 'ydata')] - [val(8), val(9)] ;
d = cross([v1 0],[v2 0]);
alpha = acos(  dot(v1,v2)   /(norm(v1) * norm(v2)) ) *sign(d(3));
%alpha_deg_store = alpha*180/pi

% update all other objects part of this ROI with correct values
set(val(3:7), 'userdata', [val(1:11), alpha]);

h_all_axes = get(findobj('Tag', 'ROI_Title_text'), 'UserData');
fig = h_all_axes{1};
fig2 = h_all_axes{2};
ifig = h_all_axes{6};
h_all_axes = h_all_axes{3};
handles = guidata(fig2);
apply_all = get(handles.Link_ROI_togglebutton,'Value');
userdata = get(findobj(fig, 'Tag', 'figROITool'),'Userdata');
ROI_info_table = userdata{1};
update_list = [];

if apply_all
    for i = 1:length(h_all_axes(find(h_all_axes)))        
%        if ~isempty(ROI_info_table(val(1),i).ROI_Exists) & ROI_info_table(val(1),i).ROI_Exists
        if ROI_info_table(val(1),i).ROI_Exists
            set(ROI_info_table(val(1),i).ROI_Data(1,1), ...
                'xdata', get(val(3),'xdata') ,...
                'ydata', get(val(3),'ydata'))
            set(ROI_info_table(val(1),i).ROI_Data(1,2), ...
                'xdata', get(val(4),'xdata') ,...
                'ydata', get(val(4),'ydata'))
            set(ROI_info_table(val(1),i).ROI_Data(1,3), ...
                'xdata', get(val(5),'xdata') ,...
                'ydata', get(val(5),'ydata'))
            set(ROI_info_table(val(1),i).ROI_Data(1,4), ...
                'xdata', get(val(6),'xdata') ,...
                'ydata', get(val(6),'ydata'))
            set(ROI_info_table(val(1),i).ROI_Data(1,5), ...
                'position', get(val(7), 'Position'));
            for k = 1:5
                old_val  = get(ROI_info_table(val(1),i).ROI_Data(1,k), 'Userdata');
                set(ROI_info_table(val(1),i).ROI_Data(1,k),...
                    'Userdata', [old_val(1:7), val(8:end)]);  
            end;
            ROI_info_table(val(1),i).ROI_Data(2,1:5) =  val(8:end);
            update_list(size(update_list,1)+1,:) = [val(1), i]; 
        end;
    end;
else
    update_list = [val(1:2)];
end;

% set the current ROI in storage
Change_Current_ROI(val(1:2));
% update the ROI info in the ROI_info_Table
Update_ROI_Info(update_list);
% Update the info into the 3D string holder
Update_ROI_Info_String(update_list);
% manipulate 3D string into a page for display in listbox
Resort_ROI_Info_Listbox;
% bring the ROI info figures to the front
figure(fig2);
figure(ifig);




%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function ROI_Size_Adjust_Entry;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Execute once at the beggining of a drag cycle
fig = gcf;
set(fig, 'WindowButtonMotionFcn', 'ROI_Tool(''ROI_Size_Adjust'');');
set(fig,'WindowButtonUpFcn', 'ROI_Tool(''ROI_Size_Adjust_Exit'')');
Change_Current_Axes;
ROI_Size_Adjust;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function ROI_Size_Adjust
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
h_size = gco;
h_axes = get(h_size, 'Parent');
point = get(h_axes,'CurrentPoint');
val = get(h_size, 'Userdata');
% 1,2  infor table indexes
% 3-7  handle_values = [h_circle, h_center, h_size, h_angle, h_number]
% 8-12 ROI_values = [center_x, center_y, size_x, size_y, angle]

% get the new position
center_pt = [val(8) val(9)];
v1 = [point(1,1)           point(1,2)]           - center_pt;  % new position
v2 = [get(val(5),'xdata'), get(val(5),'ydata')]  - center_pt ; % old position
%alpha_deg = val(12)*180/pi
rotmat =[cos(val(12)), -sin(val(12)); sin(val(12)), cos(val(12))];
iv1 = rotmat'*v1';
d = cross([v2 0],[v1 0]);    % angle between old size marker and new size marker
theta=  acos(  dot(v1,v2)   /(norm(v1) * norm(v2)) ) *sign(d(3));
%theta_deg = theta*180/pi
sx2 = -(iv1(1)); sy2 = -(iv1(2));
skewmat = rotmat*[sx2/val(10) 0 ; 0 sy2/val(11)]*rotmat';

c = skewmat * [get(val(3),'xdata') - center_pt(1); get(val(3), 'ydata') - center_pt(2)];
set(val(3), 'xdata', c(1,:) + center_pt(1), 'ydata', c(2,:) + center_pt(2));
c = (skewmat*[ [get(val(5),'xdata'), get(val(5),'ydata')] - center_pt]')' + center_pt;
set(val(5), 'xdata', c(1), 'ydata', c(2), 'UserData', [val(1:9), sx2, sy2, val(12)]);
c = (skewmat*[  [ get(val(6),'xdata'),get(val(6), 'ydata') ] - center_pt]')'  + center_pt;
set(val(6), 'xdata', c(1), 'ydata', c(2));
p = get(val(7),'Position')';

c = skewmat* ( p(1:2) - center_pt') + center_pt';
set(val(7), 'Position',    [c ;p(3)]);

set(h_size,'Userdata', [val(1:9), sx2, sy2 ,val(12)]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function ROI_Size_Adjust_Exit
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
h_size = gco;
val = get(h_size, 'Userdata');
set(val(3:7), 'userdata', val);

h_all_axes = get(findobj('Tag', 'ROI_Title_text'), 'UserData');
fig = h_all_axes{1};
fig2 = h_all_axes{2};
ifig = h_all_axes{6};
h_all_axes = h_all_axes{3};
handles = guidata(fig2);
apply_all = get(handles.Link_ROI_togglebutton,'Value');

userdata = get(findobj(fig, 'Tag', 'figROITool'),'Userdata');
ROI_info_table = userdata{1};
update_list = [];

if apply_all
    for i = 1:length(h_all_axes(find(h_all_axes)))       
        if ~isempty(ROI_info_table(val(1),i).ROI_Exists) & ROI_info_table(val(1),i).ROI_Exists
            set(ROI_info_table(val(1),i).ROI_Data(1,1), ...
                'xdata', get(val(3),'xdata') ,...
                'ydata', get(val(3),'ydata'));
            set(ROI_info_table(val(1),i).ROI_Data(1,2), ...
                'xdata', get(val(4),'xdata') ,...
                'ydata', get(val(4),'ydata'));
            set(ROI_info_table(val(1),i).ROI_Data(1,3), ...
                'xdata', get(val(5),'xdata') ,...
                'ydata', get(val(5),'ydata'));
            set(ROI_info_table(val(1),i).ROI_Data(1,4), ...
                'xdata', get(val(6),'xdata') ,...
                'ydata', get(val(6),'ydata'));
            set(ROI_info_table(val(1),i).ROI_Data(1,5), ...
                'position', get(val(7), 'Position'));
            for k = 1:5
                old_val  = get(ROI_info_table(val(1),i).ROI_Data(1,k), 'Userdata');
                set(ROI_info_table(val(1),i).ROI_Data(1,k),...
                    'Userdata', [old_val(1:7), val(8:end)]); 
            end; 
            ROI_info_table(val(1),i).ROI_Data(2,1:5) =  val(8:end);
            update_list(size(update_list,1)+1,:) = [val(1), i];       
        end;
    end;
else
    update_list = [val(1:2)];
end;
Change_Current_ROI(val(1:2));
Update_ROI_Info(update_list);
Update_ROI_Info_String(update_list);
Resort_ROI_Info_Listbox;
figure(fig2);
figure(ifig);

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function ROI_Pos_Adjust_Entry(origin);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Execute once at the beggining of a drag cycle
fig = gcf;
set(fig, 'WindowButtonMotionFcn', ['ROI_Tool(''ROI_Pos_Adjust'',' num2str(origin) ');']);
set(fig,'WindowButtonUpFcn', 'ROI_Tool(''ROI_Pos_Adjust_Exit'')');
Change_Current_Axes;
ROI_Pos_Adjust(origin);

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function ROI_Pos_Adjust(origin)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
h_pos = gco;
h_axes = get(h_pos, 'Parent');
point = get(h_axes,'CurrentPoint');
val = get(h_pos, 'Userdata');


% 1,2  infor table indexes
% 3-7  handle_values = [h_circle, h_center, h_size, h_angle, h_number]
% 8-12 ROI_values = [center_x, center_y, size_x, size_y, angle]

p = get(val(7),'Position')';
% center transform  = new point - old _point
if origin ==1  % call from center plus
    new_center_pt = [point(1,1), point(1,2)] - [val(8) val(9)];
elseif origin ==2  % call from corner number
    new_center_pt= [point(1,1), point(1,2)] - [p(1) p(2)];
end;

d = [get(val(4),'xdata') , get(val(4), 'ydata')] + new_center_pt;
set(val(4), 'xdata',  d(1), 'ydata', d(2));

o = [get(val(3),'xdata')  ;  get(val(3), 'ydata')];
set(val(3), 'xdata', o(1,:) + new_center_pt(1), 'ydata', o(2,:) + new_center_pt(2));
c = [get(val(5),'xdata'), get(val(5),'ydata')] +  new_center_pt;
set(val(5), 'xdata', c(1), 'ydata', c(2));
c = [get(val(6),'xdata'),get(val(6), 'ydata')] + new_center_pt;
set(val(6), 'xdata', c(1), 'ydata', c(2));
c = p(1:2) + new_center_pt';
set(val(7), 'Position',  [c ;p(3)]);

% update info in both number and center
set([val(4), val(7)], 'Userdata', [val(1:7), d(1:2), val(10:12)]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function ROI_Pos_Adjust_Exit
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
h_pos = gco;

% 1,2  infor table indexes
% 3-7  handle_values = [h_circle, h_center, h_size, h_angle, h_number]
% 8-12 ROI_values = [center_x, center_y, size_x, size_y, angle]

% now use the center position as reference for everyone
val = get(h_pos, 'Userdata');
set(val(3:7), 'userdata', val);

h_all_axes = get(findobj('Tag', 'ROI_Title_text'), 'UserData');
fig = h_all_axes{1};
fig2 = h_all_axes{2};
ifig = h_all_axes{6};

h_all_axes = h_all_axes{3};
handles = guidata(fig2);
apply_all = get(handles.Link_ROI_togglebutton,'Value');
userdata = get(findobj(fig, 'Tag', 'figROITool'),'Userdata');
ROI_info_table = userdata{1};
update_list = [];
if apply_all
    for i = 1:length(h_all_axes(find(h_all_axes)))       
        if ~isempty(ROI_info_table(val(1),i).ROI_Exists) & ROI_info_table(val(1),i).ROI_Exists
            set(ROI_info_table(val(1),i).ROI_Data(1,1), ...
                'xdata', get(val(3),'xdata') ,...
                'ydata', get(val(3),'ydata'));
            set(ROI_info_table(val(1),i).ROI_Data(1,2), ...
                'xdata', get(val(4),'xdata') ,...
                'ydata', get(val(4),'ydata'));
            set(ROI_info_table(val(1),i).ROI_Data(1,3), ...
                'xdata', get(val(5),'xdata') ,...
                'ydata', get(val(5),'ydata'));
            set(ROI_info_table(val(1),i).ROI_Data(1,4), ...
                'xdata', get(val(6),'xdata') ,...
                'ydata', get(val(6),'ydata'));
            set(ROI_info_table(val(1),i).ROI_Data(1,5), ...
                'position', get(val(7), 'Position'));
            for k = 1:5
                old_val  = get(ROI_info_table(val(1),i).ROI_Data(1,k), 'Userdata');
                set(ROI_info_table(val(1),i).ROI_Data(1,k),...
                    'Userdata', [old_val(1:7), val(8:end)]);  
            end;
            ROI_info_table(val(1),i).ROI_Data(2,1:5) =  val(8:end);
            update_list(size(update_list,1)+1,:) = [val(1), i];    
        end;
    end;
else
    update_list = [val(1:2)];
end;

Change_Current_ROI(val(1:2));
Update_ROI_Info(update_list);
Update_ROI_Info_String(update_list);
Resort_ROI_Info_Listbox;
figure(fig2);
figure(ifig);

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Update_ROI_Info(update_list)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% updates the roi info (mean, std, pixs, etc) into the ROI table
%disp('Called Update_ROI_Info')

if ~isempty(update_list)
    h_all_axes = get(findobj('Tag', 'ROI_Title_text'), 'UserData');
    fig = h_all_axes{1};    
    fig2 = h_all_axes{2};   
    h_all_axes = h_all_axes{3};
    handles = guidata(fig2);
    userdata = get(findobj(fig, 'Tag', 'figROITool'),'Userdata');
    ROI_info_table = userdata{1};

    % create points matrix for inpolygon command
    max_im_size = 256;
    
    
    for i = 1:size(update_list,1)
        % get the handles of the image, and the ROI circle
        h_circle = ROI_info_table(update_list(i,1), update_list(i,2)).ROI_Data(1);
        xpts = get(h_circle, 'xdata');
        ypts = get(h_circle, 'ydata');
        im = get(findobj(get(h_circle, 'Parent'), 'Type', 'Image'), 'CData');

        % check boundary conditions
        %xpts(xpts<=1) = 1;  xpts(xpts>size(im,1)) = size(im,1);
        %ypts(ypts<=1) = 1;  ypts(ypts>size(im,2)) = size(im,2);
        
        % reduce the matrix size        
        min_xpts = min(xpts); max_xpts = max(xpts);
        min_ypts = min(ypts); max_ypts = max(ypts);
         
        % shift indexes
        xpts2 = xpts - floor(min_xpts) ;
        ypts2 = ypts - floor(min_ypts) ;
       
        %reduce image size too cover only points
        im2 = im(floor(min_ypts):ceil(max_ypts), floor(min_xpts):ceil(max_xpts));
        %figure; imagesc(im2)
        %hold on; plot(xpts2, ypts2, 'ro-');
        %axis image
        
        xx = repmat([1:size(im2,2)], size(im2,1),1);
        yy = repmat([1:size(im2,1)]',1, size(im2,2));
        
        % Do not use roipoly as it only uses integer vertex coordinates
        %BW = roipoly(im, xpts, ypts);
        % However, because in_polygon uses vector and cross products to determine
        % if point is within polygon, make matrix smaller.
        %tic
        rr = inpolygon(xx,yy,xpts2,ypts2);
        %toc
        [ii,jj] = find(rr);
        debug_mode = 0;
        if debug_mode
            plot(jj+floor(min_xpts),ii+floor(min_ypts),'r.');
            f = figure;
            imagesc(im2);
            axis equal; 
            hold on;
            plot(jj+1,ii+1,'r.');
            plot(xpts2+1,ypts2+1,'r-.')
            pause
            close(f)
        end;
        ii = ii + 1; jj = jj + 1;        
        ROI_vals = double(im2(sub2ind(size(im2),ii,jj)));
        
        
		
        mn  = mean(ROI_vals);
        stdev= std(ROI_vals);
        mins = min(ROI_vals);
        maxs = max(ROI_vals);
        pixels = length(ROI_vals);
            
        ROI_info_table(update_list(i,1), update_list(i,2)).ROI_Info = ...
            [mn, stdev, pixels, mins, maxs];    
    end;
    % restore the ROI_info_table with its new info
    userdata{1} = ROI_info_table;    
    set(findobj(fig, 'Tag','figROITool'), 'UserData', userdata);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Listbox_Change_Current_ROI;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%disp('Listbox_Switch_Current_ROI');
h_listbox = gcbo;

% now determine the index of the current ROI
str = get(h_listbox, {'Value', 'String'});
values = str{1}; str = str{2};

if  length(values) >1
    % too many things are highlighted, highlight only last one
    values = values(end);
    set(h_listbox,'Value', values);
end;
% avoid problems is string is empty as all ROIs are deleted 
% and there can't be a current ROI
if ~isempty(str)
    % take first 8 characters, and convert to two numbers 
    ROI_info = fliplr(str2num(str(values,1:8)));
    h_data_holder = findobj('Tag','ROI_Title_text');
    data=  get(h_data_holder, 'Userdata');
    data{5} = ROI_info;
    set(h_data_holder,'UserData',data);

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Resort_ROI_Info_Listbox(h_pushbutton);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to reassemble the String_info_table into a page 
% for display in the listbox; selects the current ROI;
% if called by the toggle button, handle is sent in, if 
% called after the addition of data to the _table,
% then no handle is sent in.
%disp('Called Resort_ROI_Info_Listbox');

if nargin == 0 
    h_pushbutton = findobj('Tag', 'Sort_Order_pushbutton');
end;
a = get(h_pushbutton, {'Value','Userdata', 'String', 'Parent'} );
sort_order = a{1}; new_str= a{2}; cur_str = a{3}; ifig = a{4};
% sort_order = 1 = sort by image, 2 = sort by ROI

% if call from button, toggle button string
if nargin ==1, set(h_pushbutton, 'String', new_str, 'UserData', cur_str); end;

handles = guidata(ifig);
String_info_table = get(handles.ROI_Info_listbox, 'Userdata');
userdata = get(findobj('Tag', 'figROITool'), 'Userdata'); 
ROI_info_table = userdata{1};

if strcmp('Image', new_str)
    String_info_table = permute(String_info_table, [2 1 3]);
end;

st = size(String_info_table);
String_info_table = reshape(String_info_table, st(1)*st(2), st(3));

% now deblank empty rows
% assumes last digit in row is not space in normal strings
if (size(String_info_table, 1)>1)
    g = find(String_info_table(:,size(String_info_table,2))'=='x');
    String_info_table = String_info_table(g,:);
end;
set(handles.ROI_Info_listbox,'String', String_info_table(:,1:end-1));


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Save_ROI(pname, fname);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Subfunction that saves the ROI_info_table and String_update_table
% into .mat file and/or saves the Page displayed in the listbox to a text file

h_all_axes = get(findobj('Tag', 'ROI_Title_text'), 'UserData');
fig = h_all_axes{1};    
fig2 = h_all_axes{2};   
handles = guidata(fig2);
userdata = get(findobj(fig, 'Tag', 'figROITool'),'Userdata');
ROI_info_table = userdata{1};

ROI_string_table = get(findobj('Tag', 'ROI_Info_listbox'), 'String');

save_mat  = get(handles.Save_MAT_checkbox, 'Value');
save_text = get(handles.Save_TXT_checkbox, 'Value');
 
if save_mat
    % get the filename
    
    if nargin < 2
        fname = []; pname = [];
        [fname,pname] = uiputfile('*.mat', 'Save .mat file');
    end;
    
    for i =1:size(ROI_info_table,1)
        for j = 1:size(ROI_info_table,2)
            if ROI_info_table(i,j).ROI_Exists
                ROI_info_table(i,j).ROI_x_coordinates = ...
                    get(ROI_info_table(i,j).ROI_Data(1), 'xdata');
                ROI_info_table(i,j).ROI_y_coordinates = ...
                    get(ROI_info_table(i,j).ROI_Data(1), 'ydata');
                P = get(ROI_info_table(i,j).ROI_Data(1,5),'Position');
                ROI_info_table(i,j).Other_coordinates = ...
                    [get(ROI_info_table(i,j).ROI_Data(1,2), 'xdata'),...
                        get(ROI_info_table(i,j).ROI_Data(1,2), 'ydata'),...
                        get(ROI_info_table(i,j).ROI_Data(1,3), 'xdata'),...
                        get(ROI_info_table(i,j).ROI_Data(1,3), 'ydata'),...
                        get(ROI_info_table(i,j).ROI_Data(1,4), 'xdata'),...
                        get(ROI_info_table(i,j).ROI_Data(1,4), 'ydata'),...
                        P(1:2),...
                    ];
                
                ROI_info_table(i,j).ROI_mean   = ROI_info_table(i,j).ROI_Info(1);
                ROI_info_table(i,j).ROI_stdev  = ROI_info_table(i,j).ROI_Info(2);
                ROI_info_table(i,j).ROI_pixels = ROI_info_table(i,j).ROI_Info(3);
                ROI_info_table(i,j).ROI_min    = ROI_info_table(i,j).ROI_Info(4);
                ROI_info_table(i,j).ROI_max    = ROI_info_table(i,j).ROI_Info(5);
                
                val = get(ROI_info_table(i,j).ROI_Data(1), 'Userdata');
                ROI_info_table(i,j).ROI_Data(2,1:5) =  val(8:end);
            
                    
            end;
        end;
    end;
    if ~isempty(fname)
        eval(['save ''',pname fname , ''' ROI_info_table  ROI_string_table;' ])
    end;
end;

if save_text
    if isempty(fname), [fname,pname] = uiputfile('*.txt', 'Save text file'); end;        
    fid = fopen([pname, [fname, '.txt']],'w');
    for i = 1:size(ROI_string_table,1)
        fprintf(fid, '%s\n', ROI_string_table(i,:)) ;
    end;
    fclose(fid);
end;    
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Load_ROI(pathname,filename);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function to load an old ROI.mat file


if nargin < 2
    [filename, pathname] = uigetfile('*.mat', 'Pick an Mat-file containing ROIs');
end;
    
if isequal(filename,0)|isequal(pathname,0)
    return
else
    ROI = load([pathname, filename]);
    if ~isfield(ROI, 'ROI_info_table')
        return
    else
        % found file and it contains ROIs
        
        %begin by restoring blank state
        % call delete funtion with erase all ROIs
        h_all_axes = get(findobj('Tag', 'ROI_Title_text'), 'UserData');
        fig = h_all_axes{1};    
        fig2 = h_all_axes{2};
        h_all_axes = h_all_axes{3};
        
        handles = guidata(fig2);
        g = get(handles.Delete_ROI_popupmenu, 'Value');
        set(handles.Delete_ROI_popupmenu, 'Value',4);
        Delete_ROI;
        set(handles.Delete_ROI_popupmenu, 'Value', g);
        
        
        userdata = get(findobj(fig, 'Tag', 'figROITool'),'Userdata');
        ROI_info_table = userdata{1};        
        
        
        if isempty([ROI_info_table(:).ROI_Exists])  & size(ROI_info_table,2)==1
            ROI_info_table = repmat(ROI_info_table, 1, length(h_all_axes(:)));
        end;
        
        new_ROI_info_table = ROI.ROI_info_table;
        %save RRR1a new_ROI_info_table ROI_info_table;
        
        
        
        
        if size(new_ROI_info_table,2)>= size(ROI_info_table,2)
            % there are more images in the new table, get rid of extras
            new_ROI_info_table = new_ROI_info_table(:,1:size(ROI_info_table,2));
        else
            % there are more images in current figure than in original figure,
            % extend by creating an empty ROI
            %b= size(new_ROI_info_table,2)+1:size(ROI_info_table,2)
            new_ROI_info_table(size(new_ROI_info_table,1),size(ROI_info_table,2)).ROI_Exists = [];    
        end;
        
        Refresh_ROIs(new_ROI_info_table);
        
    end;
    
end;




%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Close_Parent_Figure;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function to make sure that if parent figure is closed, 
% the ROI info and ROI Tool are closed too.
set(findobj('Tag', 'RT_Info_figure'), 'Closerequestfcn', 'closereq');
try 
    close(findobj('Tag','RT_Info_figure'));
end;


set(findobj('Tag', 'RT_figure'), 'Closerequestfcn', 'closereq');
try 
    close(findobj('Tag','RT_figure'));
end;
    
    



%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%Support Routines %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
% functions called only by internal function and not as callbacks

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function h_axes = Sort_Axes_handles(h_all_axes);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% receives a column vector of handles and 
% returns a matrix depending onthe position of 
% each image on the screen
%disp('Calling Sort Axes handles')

% assumes axes are in a grid pattern
% so sort them by position on the figure
for i = 1:length(h_all_axes);
    position(i,:) = get(h_all_axes(i),'Position');
end;

% calculate the different number of row values and the different number of column values to 
% set the matrix size
[hist_pos_y, bins_y] = hist(position(:,1));
[hist_pos_x, bins_x] = hist(position(:,2));
hy = sum(hist_pos_y>0);
hx = sum(hist_pos_x>0) ;
[hist_pos_y, bins_y] = hist(position(:,1), hy);
[hist_pos_x, bins_x] = hist(position(:,2), hx);

%hist_pos_x = fliplr(hist_pos_x);
h_axes = zeros(hx,hy);

sorted_positions = sortrows([position, h_all_axes], [2,1]); % sort x, then y
counter = 0;
for i =1:length(hist_pos_x)
    for j = 1:hist_pos_x(i)
        sorted_positions(j+counter,6) = hx - i + 1;
    end;
    counter = counter + hist_pos_x(i);  
end;

sorted_positions = sortrows(sorted_positions,[1,2]); % sort y, then x
counter = 0;
for i =1:length(hist_pos_y)
    for j = 1:hist_pos_y(i)
        sorted_positions(j+counter,7) = i;
    end;
    counter = counter + hist_pos_y(i);
end;

for i = 1:size(sorted_positions,1)
    h_axes(round(sorted_positions(i,6)),round(sorted_positions(i,7))) = sorted_positions(i,5);
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Change_Object_Enable_State(handles, State, Paste_Flag)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

set(handles.Save_ROI_pushbutton, 'Enable', State);
set(handles.Copy_ROI_pushbutton, 'Enable', State);
set(handles.Delete_ROI_pushbutton, 'Enable', State);

set(handles.Save_MAT_checkbox, 'Enable', State);
set(handles.Save_TXT_checkbox, 'Enable', State);
set(handles.Delete_ROI_popupmenu, 'Enable', State);

set(handles.Link_ROI_togglebutton, 'Enable', State);

if Paste_Flag
    set(handles.Paste_ROI_pushbutton, 'Enable', State);
    set(handles.Paste_ROI_checkbox, 'Enable', State);
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Menu_ROI_Tool;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

hNewMenu = gcbo;
checked=  umtoggle(hNewMenu);
hNewButton = get(hNewMenu, 'userdata');

if ~checked
    % turn off button
    %Deactivate_Pan_Zoom(hNewButton);
    set(hNewMenu, 'Checked', 'off');
    set(hNewButton, 'State', 'off' );
else
    %Activate_Pan_Zoom(hNewButton);
    set(hNewMenu, 'Checked', 'on');
    set(hNewButton, 'State', 'on' );
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function ifig = Create_ROI_Info_Figure(ROI_info_table, i_current_ROI)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% file to create and initialize the ROI info figurel
%disp('Called Create_ROI_Info_Figure');

close_str = [ 'hNewButton = findobj(''Tag'', ''figROITool'');' ...
        ' if strcmp(get(hNewButton, ''Type''), ''uitoggletool''),'....
        ' set(hNewButton, ''State'', ''off'' );' ...
        ' else,  ' ...
        ' ROI_Tool(''Deactivate_ROI_Tool'' ,hNewButton);'...
        ' set(hNewButton, ''Value'', 0);',...
        ' end;' ];

ifig = openfig('ROI_Info');
set(ifig, 'Name', 'ROI Information' ,...
    'Tag', 'RT_Info_figure' ,...
    'Resize' , 'On',...
     'CloseRequestfcn', close_str...
    );
handles = guihandles(ifig);
guidata(ifig, handles);

% add figure handle into the "storage" place
info_values = get(findobj('Tag', 'ROI_Title_text'), 'UserData');
userdata = get(findobj(info_values{1}, 'Tag', 'figROITool'),'Userdata');
ROI_info_table = userdata{1};
handles_RT_Tool = guidata(info_values{2});

for i = 1:size(ROI_info_table,1)
    for j = 1:size(ROI_info_table,2)
        if ROI_info_table(i,j).ROI_Exists
            current_values = ROI_info_table(i,j).ROI_Info;
            % note that MATLAB automatically pads the strings with empty spaces
            String_info_table(i,j, :)= Convert_ROI_Info([j,i,current_values]);
        end;
    end
end;
        
    % now store the table in the listbox
set(handles.ROI_Info_listbox,'Userdata', String_info_table);



%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Info_string = Convert_ROI_Info(Info_numbers)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function that converts the information from the ROI info table (numbers)
% into a string that can be ins14erted in a cell array for display in the
% list box.
% temp fixed spacings
a = [     sprintf('%2d', Info_numbers(1))];
a = [a,   sprintf('%4d', Info_numbers(2))];

total_use_digits = 9;
if Info_numbers(6) < 10^5 
    after_decimal_precision_digits = 2;
    total_precision_digits =  5;
else
    after_decimal_precision_digits = 0;
    total_precision_digits = total_use_digits;
end;

a = [a,  FixLengthFormat(Info_numbers(3),total_use_digits, after_decimal_precision_digits)];
a = [a,  FixLengthFormat(Info_numbers(4),total_use_digits-1, after_decimal_precision_digits)];

a = [a,  sprintf('%6s',  num2str(Info_numbers(5), total_precision_digits) )];

a = [a,  FixLengthFormat(Info_numbers(6),total_use_digits-2, after_decimal_precision_digits)];
a = [a,  FixLengthFormat(Info_numbers(7),total_use_digits, after_decimal_precision_digits)];
Info_string = [a, 'x'];



%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Update_ROI_Info_String(update_list)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inserts new data into the string array which is later "published"
% onto the listbox
%disp('Called Update_ROI_Info_String');

h_listbox = findobj('Tag','ROI_Info_listbox');
String_info_table = get(h_listbox, 'Userdata');

info_values = get(findobj('Tag', 'ROI_Title_text'), 'UserData');
userdata = get(findobj(info_values{1}, 'Tag', 'figROITool'),'Userdata');
ROI_info_table = userdata{1};

if nargin == 0
    update_list = [];
    % no update list sent, so update all values in the ROI_info_table
    for i = 1:size(ROI_info_table,1)
        for j = 1:size(ROI_info_table,2)
            update_list(size(update_list,1)+1,:) = [i,j];
        end;
    end;    
end

for i = 1:size(update_list,1)
    current_info = [update_list(i,[2,1]), ROI_info_table(update_list(i,1), update_list(i,2)).ROI_Info];
    % if ROI has been deleted, current info second hald will be empty will be empty; Fill with spaces
    if length(current_info)>2
        String_info_table(update_list(i,1), update_list(i,2),:) = Convert_ROI_Info(current_info);
    else
        String_info_table(update_list(i,1), update_list(i,2),:) =' ';
    end;
end;
set(h_listbox, 'Userdata', String_info_table);


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function value = FixLengthFormat(num,totalChars, precision)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   By Patrick 'fishing boy' Helm
%	FixLengthFormat(num,totalChars, precision)
%		num is the number to format.	
%		totalChars is number of characters in conversion.
%				The number if right justified if the number
%				of characters is greater than the length of
%				num2str(num)
%		precision is number of digits after decimal
%
tNum = num2str(num, 16);
% find the decimal point index, if it exists
iDecimal = find(tNum == '.');
if (isempty(iDecimal)) 
    % set decimal to end of number if none 
    iDecimal = length(tNum);
    precision = 0;
else
    % add on zeroes until precision requirement is met
    while((length(tNum) - iDecimal) < 16)
        tNum = [tNum,'0'];
    end
end
% insure that even if function fails, blanks are returned
value = blanks(totalChars);
% copy character version onto output, 
% maintaining right justification
if ((iDecimal + precision) <= totalChars)
   startPos = totalChars - (precision + iDecimal) + 1;
   value(startPos:totalChars) = tNum(1:(iDecimal+precision));
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Highlight_Current_ROI(i_current_ROI);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%disp('Called Highlight_Current_ROI');

h_listbox = findobj('Tag','ROI_Info_listbox');
String_info_table = get(h_listbox, 'Userdata');
current_page = get(h_listbox, 'String');

if ~isempty(i_current_ROI)
    current_string = squeeze(String_info_table(i_current_ROI(1,1), i_current_ROI(1,2),:))';
    for i = 1:size(current_page, 1)
        if strcmp(current_string(1,1:end-1), current_page(i,:))
            set(h_listbox, 'Value', i);
        end
    end;
else
    % want to set current ROI to blank (due to deletion of current ROI)
    set(h_listbox, 'Value', []);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function h_all_axes = Find_All_Axes(varargin);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function to find and sort axes in a figure - or - 
% get axes handles if array of image handles is sent in

if strcmp(get(varargin{1}(1), 'Type'),'figure')
    % sent in nothing; determine axes handles and sort them into the correct matrix
    h_all_axes = Sort_Axes_handles(findobj(varargin{1}(1),'Type', 'Axes'));  
else
    % sent in the image handles, already sorted into matrix; now find parent axes for each one
    % but don't include them if the image is a Colorbar
    h_images = varargin{1};
    for i =1:size(h_images,1)
        for j = 1:size(h_images,2)
            if h_images(i,j)~= 0
                if ~strcmp( get(h_images(i,j), 'Tag'), 'TMW_COLORBAR')
                    h_all_axes(i,j) = get(h_images(i,j),'Parent');
                end;
            end;
        end;
    end;
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function Refresh_ROIs(ROI_table);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Support function to redraw ROIs from the ROI info table
% assumes a start from the Delete_ROI, case 4 condition;
% Parallels Create_ROI code;
h_all_axes = get(findobj('Tag', 'ROI_Title_text'), 'UserData');
fig = h_all_axes{1};
fig2 = h_all_axes{2};
h_axes = h_all_axes{4};
i_current_ROI = h_all_axes{5};
h_all_axes = h_all_axes{3};

h_all_axes = h_all_axes';
h_all_axes = h_all_axes(find(h_all_axes));

handles = guidata(fig2);

% get old ROI_info table
Userdata = get(findobj(fig, 'Tag', 'figROITool'), 'UserData');

ROI_info_table = struct('ROI_Exists', []);
temp_h_all_axes = find(h_all_axes);
% cycle through to create 0's in the Exist field. marks the ROI table as initialized
[ROI_info_table(1:size(ROI_table,1),1:length(temp_h_all_axes)).ROI_Exists] = deal(0);
first_ROI_flag = 1;    
    

% find empty slots in ROI_info Table
Current_ROI_index = 1;

% colors: red, green, blue, yellow, magenta, cyan, white 
colororder = repmat('rgbymcw',1,4);

ROI_counter = 1;
% for every image

%save RRR ROI_table
if ~isfield(ROI_table, 'Other_coordinates')
    % the information necessary for all the other 
    ROI_table = Insert_Other_Coordinates(ROI_table);
end;
%save RRR2 ROI_table

update_list = [];
for i = 1:size(ROI_table,2)
    % for every ROI in the table

    for j = 1:size(ROI_table,1)


        if ROI_table(j,i).ROI_Exists

            Current_ROI_index = j;
            x = ROI_table(j,i).ROI_x_coordinates;
            y = ROI_table(j,i).ROI_y_coordinates;
                   
            h_axes_index = find(h_all_axes(i)==h_all_axes);
            set(fig, 'CurrentAxes', h_all_axes(i));
            set(0, 'CurrentFigure', fig);

            % if no other coordinates were available, they have already been reinserted.
            ocs =  ROI_table(j,i).Other_coordinates;
            x_center = ocs(1);
            y_center = ocs(2);
            
            x_size = ocs(3);
            y_size = ocs(4);
            
            x_angle = ocs(5);
            y_angle = ocs(6);
            
            x_number = ocs(7);
            y_number = ocs(8);
            
            ROI_Data = ROI_table(j,i).ROI_Data;
            
            h_circle = plot(x,y,[colororder(Current_ROI_index),'-'],...
                'ButtonDownFcn', 'ROI_Tool(''Change_Current_ROI'')');
            
            h_center = plot(ocs(1) ,ocs(2), [colororder(Current_ROI_index),'+'], ...
                'ButtonDownFcn', 'ROI_Tool(''ROI_Pos_Adjust_Entry'',1)'); 
            center_x = ocs(1);
            center_y = ocs(2);
            center_x = ROI_Data(2,1);
            center_y = ROI_Data(2,2);
            
            h_size = plot(ocs(3) ,ocs(4),...
                [colororder(Current_ROI_index),'s'] , ...
                'ButtonDownFcn', 'ROI_Tool(''ROI_Size_Adjust_Entry'')');    
            % calc ROI axes sizes by differences bewteen size square and numbmer
            % and angle circle and number.
            size_x = sqrt(  (ocs(3)-ocs(7))^2  + (ocs(4)-ocs(8))^2) /2 ;
            size_y = sqrt(  (ocs(5)-ocs(7))^2  + (ocs(6)-ocs(8))^2);
            size_x = ROI_Data(2,3);
            size_y = ROI_Data(2,4);
            
            
            h_angle = plot(ocs(5) ,ocs(6),...
                [colororder(Current_ROI_index),'o'],...
                'ButtonDownFcn', 'ROI_Tool(''ROI_Angle_Adjust_Entry'')');
            
            v1 = [1, 0];
            v2 = [ocs(5), ocs(6)] - [center_x, center_y];
            % get angle (positive only) and multiply it by direction
            d = cross([v1 0],[v2 0]);
            % calculate angle between the two...
            alpha=  acos(  dot(v1,v2)   /(norm(v1) * norm(v2)) ) * -1*sign(d(3));
            alpha = ROI_Data(2,5);
            
            h_number = text(ocs(7) ,ocs(8), num2str(Current_ROI_index),'color', ...
                [colororder(Current_ROI_index)], 'HorizontalAlignment', 'center' , ...
                'ButtonDownFcn', 'ROI_Tool(''ROI_Pos_Adjust_Entry'',2)');  
        
            update_list(size(update_list,1)+1,:) = [j,i]  ;          
            i_current_ROI = [Current_ROI_index, h_axes_index];
                    
            handle_values = [h_circle, h_center, h_size, h_angle, h_number];
            ROI_values = [center_x, center_y, size_x, size_y, alpha];
            
            set(handle_values, 'UserData', ...
                [Current_ROI_index, h_axes_index, handle_values, ROI_values ]);
            ROI_info_table(Current_ROI_index,h_axes_index).ROI_Data = ...
                [handle_values; ...
                    ROI_values];
            ROI_info_table(Current_ROI_index, h_axes_index).ROI_Exists = 1;
            
        end;
        
        
        
                
    end;
    
end;



% Now Restore ROI_info_table to its hiding spot
Userdata{1} = ROI_info_table;
set(findobj(fig, 'Tag', 'figROITool'), 'UserData', Userdata);

% call the ROI_info update function: puts data into ROI_info_table
Update_ROI_Info(update_list);

if first_ROI_flag
    % creates figure the first time and creates the string table that is to be
    % used for "publishing" the ROI data
    ifig = Create_ROI_Info_Figure(ROI_info_table, update_list);
    % published the string into the listbox
    
    % turn on buttons, but turn off print objects
    Change_Object_Enable_State(handles,'Off',1);
    Change_Object_Enable_State(handles,'On',0);
else
    % call function that will take info string table and "publish" it
    
    Update_ROI_Info(update_list);
    Update_ROI_Info_String(update_list);
end;

Resort_ROI_Info_Listbox;
% update current ROI index
set(findobj('Tag', 'ROI_Title_text'), 'Userdata', { fig, fig2, h_all_axes, h_axes, i_current_ROI, ifig});
Highlight_Current_ROI(i_current_ROI);



%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function ROI_table = Insert_Other_Coordinates(ROI_table);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Support function to insert "other coordinates" to elliptical ROIs that do not have them:
% need positions for the size, angle and number handles. 
% Places the results of the calculations into the ROI_Data field of each element
% in the ROI info table. Elliptical ROI must have even number of non-equal points. If ellipse is 
% closed, then there must be an odd number of points. Prefereably number of points divisible by 4.
disp('Entering Inert_Other_Coordinates');
debug = 0;
colororder = repmat('rgbymcw',1,4);

if isfield(ROI_table, 'Other_coordinates')
    disp('field exists; removing old other_coordinates');
    old_Table = ROI_table;
    ROI_table = rmfield(ROI_table, 'Other_coordinates');
end;

for i = 1:size(ROI_table,2)
    % for every ROI in the table
    if debug==1
        ff = figure;
    end;        
    for j = 1:size(ROI_table,1)
        
        if ROI_table(j,i).ROI_Exists
            
            Current_ROI_index = j;
            x = ROI_table(j,i).ROI_x_coordinates;
            y = ROI_table(j,i).ROI_y_coordinates;
            
            % clear out the field if it does exist
            
            % the information necessary for all the other 
            % objects was not stored. Make an attempt to recover it.
            if debug==1
                plot(1,1);
                hold on;
                set(gca, 'ydir','reverse'); 
                set(gca, 'xlim' ,[ 0 256], 'ylim', [ 0 256]);
                axis('equal');                
            end;
            
            % un-close the ellipse
            if (x(1) == x(end))
                x = x(1:end-1);
                y = y(1:end-1);
            end;
            length_x = length(x);
            
            % fit the ellipse
            %x2 = [x(1)+ 0.1*x(1), x(2:end)];
            aa = fit_ellipse(x,y);
            
            f = aa(6); e = aa(5); d = aa(4);
            c = aa(3); b = aa(2); a = aa(1);
            
            % determine position of center of ROI 
            x_center = mean(x);
            y_center = mean(y); 
                        
            % determine major and minor axes of ellipse
            xdiff = x(1:length_x/2) - x(length_x/2+1:end);
            ydiff = y(1:length_x/2) - y(length_x/2+1:end);
            xydiff = sqrt(xdiff.^2 + ydiff.^2);
            
            % if the coefficient of variation of the distances between opposing points
            % is close to zero (implies circular ROI), then use the standard visual places 
            % for the ROIs: upper left size, upper right number, right angle 
            cv = abs(std(xydiff)/mean(xydiff));
            
            if  cv > 0.01 
                max_xydiff = max(xydiff);
                major_axis = find(xydiff==max_xydiff );
            else
                major_axis = find(x== min(x));
            end;
            
            % the minor axis is 1/4 of the ellipse around
            % assume the minor axis is pi/2 away from major axis. This is not exacly true for 
            % ROIs with num_points/4 
            minor_axis = major_axis + floor(length_x/4);
            
            % take first if there are many equal diameters
            % wrap the minor_axis to the length of points
            major_axis = major_axis(1);
            minor_axis = mod(minor_axis(1),length(x));
            
            %plot([x(major_axis), x(mod(major_axis + length_x/2, length_x))],...
            %    [y(major_axis), y(mod(major_axis + length_x/2, length_x))], 'g-');
            %plot([x(minor_axis), x(mod(minor_axis + length_x/2, length_x))],...
            %    [y(minor_axis), y(mod(minor_axis + length_x/2, length_x))], 'g:');
            
            % determine angle positions the cheap way
            %x_angle1 =  x(mod(major_axis + length_x/2,length_x))
            %y_angle1 =  y(mod(major_axis + length_x/2,length_x))
            %plot(x_angle1, y_angle1, 'kx');
            
            major_slope = ( y(mod(major_axis + length_x/2 - 1, length_x)+1) - y(major_axis) )/ ...
                ( x(mod(major_axis + length_x/2 -1, length_x) +1) - x(major_axis));

            %minor_slope = ( y(mod(minor_axis + length_x/2 - 1, length_x)+1) - y(minor_axis) )/ ...
            %    ( x(mod(minor_axis + length_x/2 -1, length_x) +1) - x(minor_axis))
            R = [ cos(pi/2), sin(pi/2); -sin(pi/2), cos(pi/2)];
            minor_slope = R * [ 1 major_slope]' ;
            minor_slope = minor_slope(2)/ minor_slope(1);
            if isnan(minor_slope), minor_slope = 0; end;
            
            
            xmin = min(x);
            ymin = min(y);
            xmax = max(x);
            ymax = max(y);
            
            % use slope calc intersections of line and ellipse
            s = major_slope;
            if ~isinf(s)
                % intercept of lines crossing ellipse
                % with exactly real roots - i.e. single point intersections 
                t1_major = 1/2/(4*a*c-b^2)*(-2*e*s*b-4*a*e+4*c*s*d+2*d*b+4*(e^2*s*b*a-e*s^2*b*c*d-e*s*b^2*d+a^2*e^2-a*e*d*b+c^2*s^2*d^2+c*s*d^2*b+a*c*e^2*s^2+a*c*d^2-4*a*c*b*s*f-4*a^2*c*f-4*a*c^2*s^2*f+b^3*s*f+b^2*a*f+b^2*c*s^2*f)^(1/2));
                t2_major = 1/2/(4*a*c-b^2)*(-2*e*s*b-4*a*e+4*c*s*d+2*d*b-4*(e^2*s*b*a-e*s^2*b*c*d-e*s*b^2*d+a^2*e^2-a*e*d*b+c^2*s^2*d^2+c*s*d^2*b+a*c*e^2*s^2+a*c*d^2-4*a*c*b*s*f-4*a^2*c*f-4*a*c^2*s^2*f+b^3*s*f+b^2*a*f+b^2*c*s^2*f)^(1/2));
                %    plot([ xmin xmax ], [ xmin*s + t1_major ,xmax*s + t1_major], 'b-')
                %    plot([ xmin xmax ], [ xmin*s + t2_major ,xmax*s + t2_major], 'b-') 
            else
                t1_major = NaN;
                t2_major = NaN;
            end;
            
            
            s = minor_slope;
            % intercept of lines crossing ellipse, for minor slope
            if ~isinf(s)
                t1_minor = 1/2/(4*a*c-b^2)*(-2*e*s*b-4*a*e+4*c*s*d+2*d*b+4*(e^2*s*b*a-e*s^2*b*c*d-e*s*b^2*d+a^2*e^2-a*e*d*b+c^2*s^2*d^2+c*s*d^2*b+a*c*e^2*s^2+a*c*d^2-4*a*c*b*s*f-4*a^2*c*f-4*a*c^2*s^2*f+b^3*s*f+b^2*a*f+b^2*c*s^2*f)^(1/2));
                t2_minor = 1/2/(4*a*c-b^2)*(-2*e*s*b-4*a*e+4*c*s*d+2*d*b-4*(e^2*s*b*a-e*s^2*b*c*d-e*s*b^2*d+a^2*e^2-a*e*d*b+c^2*s^2*d^2+c*s*d^2*b+a*c*e^2*s^2+a*c*d^2-4*a*c*b*s*f-4*a^2*c*f-4*a*c^2*s^2*f+b^3*s*f+b^2*a*f+b^2*c*s^2*f)^(1/2));
                %    plot([ xmin xmax ], [ xmin*s + t1_minor ,xmax*s + t1_minor], 'm-')
                %    plot([ xmin xmax ], [ xmin*s + t2_minor ,xmax*s + t2_minor], 'm-') 
            else
                t1_minor = NaN;
                t2_minor = NaN;
            end;
            
            
            if ~isnan(t1_minor) & ~isnan(t1_major)
                
                x_t1_t1_intersect = (t1_major - t1_minor)  / (minor_slope - major_slope);
                y_t1_t1_intersect = major_slope*x_t1_t1_intersect + t1_major;
                
                x_t1_t2_intersect = (t1_major - t2_minor)  / (minor_slope - major_slope);
                y_t1_t2_intersect = major_slope*x_t1_t2_intersect + t1_major;
                
                x_t2_t1_intersect = (t2_major - t1_minor)  / (minor_slope - major_slope);
                y_t2_t1_intersect = major_slope*x_t2_t1_intersect + t2_major;
                
                x_t2_t2_intersect = (t2_major - t2_minor)  / (minor_slope - major_slope);
                y_t2_t2_intersect = major_slope*x_t2_t2_intersect + t2_major;
                
            else
                % one of the slopes is infinte, therefore the other is zero
                
                x_t1_t1_intersect = xmin;
                y_t1_t1_intersect = ymin;
                
                x_t1_t2_intersect = xmin;
                y_t1_t2_intersect = ymax;
                
                x_t2_t1_intersect = xmax;
                y_t2_t1_intersect = ymin;
                
                x_t2_t2_intersect = xmax;
                y_t2_t2_intersect = ymax;
                
            end;
            x_corners = [...
                    x_t1_t1_intersect,...
                    x_t1_t2_intersect,...
                    x_t2_t1_intersect,...
                    x_t2_t2_intersect ...
            ];
            y_corners = [...
                    y_t1_t1_intersect,...
                    y_t1_t2_intersect,...
                    y_t2_t1_intersect,...
                    y_t2_t2_intersect ...
            ];
            
            %plot(x_corners(1), y_corners(1), 'ms')
            %plot(x_corners(2), y_corners(2), 'mo')
            %plot(x_corners(3), y_corners(3), 'md')
            %plot(x_corners(4), y_corners(4), 'm*')
            
            corners = [x_corners' , y_corners'];
            
            
            % determine the position of the angle marker by finding the point
            % on the ellipse, where the line with slope major_slope crosses.
            s = major_slope;
            t = y_center - x_center*s;
            if isinf(s) , 
                s = minor_slope; 
                t = y_center - x_center*s;
                xxx_plus = x_center;
                yyy_plus = min(y);
                
                x_angle_plus_180 = xxx_plus;
                y_angle_plus_180 = yyy_plus;
                
            else
                xxx_plus = [ 1/2/(b*s+a+c*s^2)*(-2*c*t*s-d-e*s-b*t+(4*c*t*s*d+d^2+2*d*e*s+2*d*b*t+e^2*s^2-2*e*s*b*t+b^2*t^2-4*b*s*f-4*a*f-4*a*c*t^2-4*a*e*t-4*c*s^2*f)^(1/2))]      ;
                yyy_plus = s*xxx_plus + t;
                
                x_angle_plus_180 = xxx_plus;
                y_angle_plus_180 = yyy_plus ; 
                
                
            end;
            xxx_minus = [ 1/2/(b*s+a+c*s^2)*(-2*c*t*s-d-e*s-b*t-(4*c*t*s*d+d^2+2*d*e*s+2*d*b*t+e^2*s^2-2*e*s*b*t+b^2*t^2-4*b*s*f-4*a*f-4*a*c*t^2-4*a*e*t-4*c*s^2*f)^(1/2))]      ;
            yyy_minus = s*xxx_minus + t;
            
            x_angle = xxx_minus;
            y_angle = yyy_minus;
            
            
            % determine the order of the points
            vec1 = corners - repmat([x_center, y_center],4,1);
            vec1(5,:) =  [x_angle , y_angle] - [x_center, y_center];
            
            [theta, vec_size] = cart2pol(vec1(:,1), vec1(:,2));
            theta = theta*180/pi;
            
            sorted = sortrows([theta, vec1], 1);
            angle_position = find(sorted(:,1)'== theta(5));
            
            x_square = sorted( mod(angle_position - 3,5) +1 ,2) + x_center;
            y_square = sorted( mod(angle_position - 3,5) +1,3) + y_center;
            
            x_number = sorted( mod(angle_position - 2,5) +1,2) + x_center;
            y_number = sorted( mod(angle_position - 2,5) +1,3) + y_center;
            
            size_x = norm( [x_angle - x_center, y_angle - y_center] );
            size_y = norm( [x_angle - x_number, y_angle - y_number] );
            
            
            % calculate angle
            v1 = [1 0];  % basis
            v2 = [x_angle, y_angle] - [x_center, y_center] ;
            d = cross([v1 0],[v2 0]);
            % change this calculation to an atan2 calculation
            alpha = acos(  dot(v1,v2)   /(norm(v1) * norm(v2)) ) *sign(d(3));
            
            
            % close the polygon
            x = [x , x(1)];
            y = [y , y(1)];
            
            if debug==1
                % now plot circle with basic points, transformed by skew, rotation, and translation
                h_circle = plot(x,y,[colororder(Current_ROI_index),'-']);
                % 'ButtonDownFcn', 'ROI_Tool(''Change_Current_ROI'')');
            
                h_center = plot(x_center, y_center , [colororder(Current_ROI_index),'+']);
                % 'ButtonDownFcn', 'ROI_Tool(''ROI_Pos_Adjust_Entry'',1)'); 
                
                h_size = plot(x_square, y_square,...
                    [colororder(Current_ROI_index),'s'] );
                %  'ButtonDownFcn', 'ROI_Tool(''ROI_Size_Adjust_Entry'')');    
                
                h_angle = plot(x_angle, y_angle,...
                    [colororder(Current_ROI_index),'o']);
                % 'ButtonDownFcn', 'ROI_Tool(''ROI_Angle_Adjust_Entry'')');
                
                h_number = text(x_number, y_number, num2str(Current_ROI_index),'color', ...
                    [colororder(Current_ROI_index)], 'HorizontalAlignment', 'center' );
                % 'ButtonDownFcn', 'ROI_Tool(''ROI_Pos_Adjust_Entry'',2)'); 
                
            end;
            confirmation = [ROI_table(j,i).ROI_Data(2,:); ...
                    x_center, y_center, size_x, size_y, alpha];
    
            ROI_table(j,i).ROI_Data(2,:) =  [x_center, y_center, size_x, size_y, alpha]
            ROI_table(j,i).Other_coordinates= [x_center, y_center, x_square, y_square, ...
                x_angle, y_angle, x_number, y_number];
            
            
        end;
       
    end;
    
end;
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function a = fit_ellipse(x, y)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Support function to fit an ellipse from given x,y data points.
% Used to recalculate corner points for elliptical ROIs loaded. 
% a=> [ a1*x^2 + a2*x*y a3*y^2 + a4*x + a5*y + a6 = 0]
if size(x,1) == 1
    x = x';
    y = y';
end;
D1 = [x.^2, x.*y, y.^2];                  % quadratic part of the design matrix
D2 = [x, y, ones(size(x))];               % linear part of the design matrix
S1 = D1'*D1;                              % quadratic part of the scatter matrix
S2 = D1'*D2;                              % combined part of the scatter matrix
S3 = D2'*D2;                              % linear part of the scatter matrix
T = -inv(S3)*S2';                         % for getting a2 from a1
M = S1 + S2*T;                            % reduced scatter matrix
M = [M(3,:)./2; - M(2,:); M(1,:)./2;];    % premultiply by inv(C1)
[evec, eval] = eig(M);                    % solve eigensystem
cond = 4*evec(1,:).*evec(3,:) - evec(2,:).^2; % evaluate a'Ca
a1 = evec(:,find(cond > 0));              % eigenvector for min. pos. eigenvalue
a = [a1; T*a1];                           % ellipse coefficients
