function roi_handler = roitool(arg1, arg2, arg3)

% ROITOOL enables to define different type of rois on intensity images
% by mouse. The supported types are 'polygon', 'circle' and  'rectangle'
% using the ROITOOL('circle'), ROITOOL('rectangle') and ROITOOL('polygon'),
% respectively.  ROIPOLY returns the handler of the line object relating
% to the roi. The created roi can be dragged and moved to any position of 
% the image with the help of DRAGGABE function (developed by Francois 
% Bouffard, see the help of draggable).  
%
% Definition rules (displayed always in the Matlab command window):
%   circle: Select the center of the circle by normal button click then 
%           define the desired radius moving the mouse and finally 
%           double click to finish the ROI. 
%   rectangle: Use the mouse to click and drag the desired rectangle. To 
%           constrain the rectangle to be a square, use a shift- or 
%           right-click to begin the drag.
%   polygon: Use normal button clicks to add vertices to the polygon and 
%           right-click close the vertex.
%    
% ROITOOL generates a context menu to the roi making possible the 
% selection of the following commands:(MATLAB displays the context
% menu whenever you right-click over the object)
%       - change the roi color
%       - change the size of the line width
%       - switch on/off the "statistical bar", which displays
%         the main stat. results of the roi (mean, std, min, max, roi area)
%       - switch on/off the "histogram figure", which shows the intensity 
%         histogram of the pixels belonging to the roi
%       - switch on/off the "detailed rectangle" figure, which plots the 
%         zoomed image segment defined by the rectangle roi
%       - resize the roi (in case of circle or rectangle roi)
%       - delete the roi    
%
% roihandler = ROITOOL('roitype') command returns the handler of the 
% roi (the line object). The handler has an associate data structure 
% containing the parameters of the roi. This structure can be evaluated 
% issuing the 
%               roidata = get(roihandler,'userdata'); 
% command. The roidata structure includes the following fields (among
% others) - roimean, roistd, roimax, roimin, pixelrange (image pixel 
% indexes relating to the roi), roiarea, handlers of the joint 
% object (histogram figure, stat. bar, ...).
%
% ROITOOL('circledemo'), ROITOOL('rectangledemo') or ROITOOL('polygondemo')
% start the roi definition using the MATLAB 'MRI' data set.

if nargin == 0
    roitype = 'circle';
else
    roitype = arg1;
end

if ischar(roitype) % execute a roi-definition callback
    % test the roitype input
    if ~strcmp(roitype,'circle') & ~strcmp(roitype,'rectangle') & ~strcmp(roitype,'polygon') & ...
            ~strcmp(roitype,'circledemo') & ~strcmp(roitype,'rectangledemo') & ~strcmp(roitype,'polygondemo')
        error('RoiError:inputtest',['Roitype ',upper(roitype),' is not supported. \n ', ...
            'Only CIRCLE, RECTANGLE and POLYGON type is currently enabled.']);
        return;
    end
    % test whether the roitype contains a 'DEMO' string
    if ~isempty(strfind(roitype,'demo'))
        mridata = load('mri');
        imaVOL = squeeze(mridata.D);
        figure('name','MRI data for ROItool test','numbertitle','off');
        imagesc(imaVOL(:,:,17));
        map  = colormap(bone(256));
        axis square;
    end
    % test the current figure existence
    currentfigure_handle = get(0,'CurrentFigure');
    if isempty(currentfigure_handle)
        msg = sprintf('%s expects a current figure containing an image.', ...
            upper(mfilename));
        error(msg);
        return;
    end
    % test the imagetype. Only intensity image is supported.
    imModel = getimagemodel(imhandles(currentfigure_handle));
    if (~(isequal(getImageType(imModel), 'intensity') || ...
            isequal(getImageType(imModel), 'truecolor')))
       error('Only intensity and truecolor images are supported.')
       return;
    end
elseif ishandle(roitype) % execute a context menu defined callback
    %test the roi_handler
    roi_handler = roitype;
    if ~strcmp(get(roi_handler,'tag'),'roi_handler');
        msg = sprintf('%s expects arg1 only as real roi_handler.', ...
            upper(mfilename));
        error(msg);
        return;
    end
    % if the roi_handle OK
    switch lower(arg2)
    case 'roi_delete'
        roi_delete(roi_handler);
    case 'roi_resize'
        roi_resize(roi_handler);
    case 'roi_drag'
        roi_drag(roi_handler);
    case 'roi_showstat'
        onoff = arg3;
        roi_showstat(roi_handler, onoff);
    case 'roi_showhist'
        onoff = arg3;
        roi_showhist(roi_handler, onoff);
    case 'roi_showdetrect' 
        onoff = arg3;
        roi_showdetrect(roi_handler, onoff);
    end
    return;
end
%
% start the ROI definition
%
set(gca,'units','pixels'); 
image_h = findobj(gca,'type','image');  
userdata.currentimage = get(image_h,'cdata');
mainfigure = gcf;
if ~isempty(strfind(roitype,'circle'))
    roitype = 'circle';
    disp(' '); disp('Select the center of the circle!');
    drawnow;
    [xcenter, ycenter] = ginput(1); 
    x0 = xcenter; y0 = ycenter; R0 = 5; 
    t = 0:pi/20:2*pi; 
    xi = R0*cos(t)+xcenter; 
    yi = R0*sin(t)+ycenter; 
    roi_handler = line(xi,yi,'LineWidth',2,'Color','red'); 
    userdata.t = t; userdata.xcenter = xcenter; userdata.ycenter = ycenter; userdata.R0 = R0;
    set(roi_handler,'userdata',userdata);
    % set the roisize
    disp(' '); disp('Define the desired radius moving the mouse.'); 
    disp('Double click to finalize the ROI!');disp(' '); 
    set(gcf,'WindowButtonMotionFcn',['change_radius(',num2str(roi_handler,20),')']);
    set(gcf,'WindowButtonDownFcn','complete_radius'); 
    waitfor(gcf,'WindowButtonMotionFcn');
    drawnow;   
elseif ~isempty(strfind(roitype,'polygon'))
    roitype = 'polygon';
    disp('Use the mouse to select the vertices of polygon.');
    disp('Double-click adds a final vertex and draws the roi');disp(' ');
    roi_x=[]; roi_y=[];
    ButtonPressed = 1; i = 1;
    drawnow; pause(1);
    while ButtonPressed == 1 
        [xtmp, ytmp, ButtonPressed] = ginput(1);
        roi_x = [roi_x; xtmp]; 
        roi_y = [roi_y; ytmp];
        line_h(i) = line(roi_x,roi_y,'color','red','LineWidth',2);
        i = i + 1;
    end;
    % delete the temporary lines and create the final polyroi
    delete(line_h);
    roi_x(length(roi_x)+1)=roi_x(1);
    roi_y(length(roi_y)+1)=roi_y(1);
    roi_handler = line(roi_x,roi_y,'color','red','linewidth',2);
elseif ~isempty(strfind(roitype,'rectangle'))
    roitype = 'rectangle';
    disp(' '); disp('Use the mouse to click and DRAG the desired rectangle.');disp(' ');
    rectpos = [0 0 0 0];
    while rectpos(3) == 0;
        rectpos = round(getrect(gca));
        if rectpos(3) == 0;
            mbh = msgbox('Use the mouse to click and DRAG the desired rectangle.','Roi Info');
            uiwait(mbh);
        end
    end
    % define the coordinate range and data for detailed rectangle
    dry = round(rectpos(1)):round(rectpos(1)) + round(rectpos(3)-1);
	drx = round(rectpos(2)):round(rectpos(2)) + round(rectpos(4)-1);
    cimg = userdata.currentimage(drx,dry);
    userdata.cimgsize = size(cimg);
    userdata.cmap = colormap;
    ScreenSize = get(0,'ScreenSize');
    Pos = [0.6*ScreenSize(3)    0.1*ScreenSize(4)    0.4*ScreenSize(3)    0.35*ScreenSize(4)];
    DetailRectangleFig = figure('name','Detail Rectangle', ...
        'NumberTitle','off','menubar','none','Position',Pos);
    colormap(userdata.cmap);
    set(DetailRectangleFig,'doubleBuffer','on');
    userdata.DetailRectangleFig = DetailRectangleFig;
    imh = imagesc(cimg);
    axis image; set(gca,'tag','DetailRectangleAx');
    set(imh,'tag','DetailRectangleImg');
    set(imh,'EraseMode','none');
    axis off;
    set(DetailRectangleFig,'visible','off');
    figure(mainfigure);
    % define the points for the line to be drawn 
    roi_x = [rectpos(1), rectpos(1)+rectpos(3), rectpos(1)+rectpos(3), ...
        rectpos(1), rectpos(1)];
    roi_y = [rectpos(2), rectpos(2), rectpos(2)+rectpos(4), ...
        rectpos(2)+rectpos(4), rectpos(2)] ;
    roi_handler = line(roi_x,roi_y,'color','red','linewidth',2);
end
userdata.roitype = roitype;
set(roi_handler,'tag','roi_handler');
%
% Define the context menu
%
cmenu = uicontextmenu;
menuitem1 = uimenu(cmenu, 'Label', 'Color', 'Callback', ...
    ['set(',num2str(roi_handler,20),',''color'',uisetcolor )']);

menuitem2 =  uimenu(cmenu, 'Label', 'LineWidth', 'Callback', ...
    ['set(',num2str(roi_handler,20), ...
    ',''LineWidth'', str2num(cell2mat(inputdlg(''Enter the line width'',''ROI setup'',1,{''3''}))))']);

menuitem3 = uimenu(cmenu, 'Label', 'Show Statistics: +', 'Callback', ...
    ['roitool(',num2str(roi_handler,20),',''roi_showstat'',''on'');'], ...
    'tag','ShowStatMenu');
   
menuitem4 = uimenu(cmenu, 'Label', 'Show Histogram: -', 'Callback', ...
    ['roitool(',num2str(roi_handler,20),',''roi_showhist'',''on'');'], ...
    'tag','ShowHistMenu');

if  strcmp(roitype,'rectangle')
    menuitem6 = uimenu(cmenu, 'Label', 'Show DetailedRect: -', 'Callback', ...
        ['roitool(',num2str(roi_handler,20),',''roi_showdetrect'',''on'');'], ...
    'tag','ShowDetRectMenu');
end

if ~strcmp(roitype,'polygon')
    menuitem5 = uimenu(cmenu, 'Label', 'Resize', 'Callback', ...
        ['roitool(',num2str(roi_handler,20),',''roi_resize'');']);
end

menuitem7 = uimenu(cmenu, 'Label', 'Delete', 'Callback', ...
    ['roitool(',num2str(roi_handler,20),',''roi_delete'');']);

set(roi_handler,'UIContextMenu',cmenu);
%
% create the StatValue display bar 
%
StatFigure = findobj('name','Roi Stat. Figure');
if isempty(StatFigure)
    ScreenSize = get(0,'ScreenSize');
    Pos = [0.5*ScreenSize(3)    0.8*ScreenSize(4)    0.4*ScreenSize(3)    0.1*ScreenSize(4)];
    StatFigure = figure('name','Roi Stat. Figure','NumberTitle', 'off','MenuBar','none', ...
        'visible','on','Position',Pos);
    visible_on = 'off';
    FigPos = get(gcf,'position');
%     StatValuesBar0 = uicontrol(gcf, 'Style','text', ...
%                           'Units','pixels', ...
%                           'Position',[0 FigPos(4)-20 FigPos(3) 15], ...
%                           'Foreground', [1 1 .5], ...
%                           'Background', [0 0 0], ...
%                           'Horiz','left', ...
%                           'Tag', 'RoiStatValuesBar1', ...
%                           'String','', ...
%                           'fontname', 'Helvetica', ...
%                           'FontSize', 8, ...
%                           'BusyAction', 'queue', ...
%                           'enable', 'inactive', ...
%                           'Interruptible', 'off');
    StatValuesBar1 = uicontrol(gcf, 'Style','text', ...
                          'Units','pixels', ...
                          'Position',[0 FigPos(4)-20 FigPos(3) 15], ...
                          'Foreground', [1 1 .5], ...
                          'Background', [0 0 0], ...
                          'Horiz','left', ...
                          'Tag', 'RoiStatValuesBar1', ...
                          'String','', ...
                          'fontname', 'Helvetica', ...
                          'FontSize', 8, ...
                          'BusyAction', 'queue', ...
                          'enable', 'inactive', ...
                          'Interruptible', 'off');
    StatValuesBar2 = uicontrol(gcf, 'Style','text', ...
                          'Units','pixels', ...
                          'Position',[0 FigPos(4)-40 FigPos(3) 15], ...
                          'Foreground', [1 1 .5], ...
                          'Background', [0 0 0], ...
                          'Horiz','left', ...
                          'Tag', 'RoiStatValuesBar2', ...
                          'String','', ...
                          'fontname', 'Helvetica', ...
                          'FontSize', 8, ...
                          'BusyAction', 'queue', ...
                          'enable', 'inactive', ...
                          'Interruptible', 'off');
   set(StatFigure,'visible','on');
end
%userdata.StatValuesBar1 = StatValuesBar;
userdata.cmenu = cmenu;
%
% create histogram figure
%
imagesize = size(userdata.currentimage);
RoiHistogram = findobj('name','Roi Histogram');
if isempty(RoiHistogram)
    ScreenSize = get(0,'ScreenSize');
    Pos = [0.6*ScreenSize(3)    0.3*ScreenSize(4)    0.4*ScreenSize(3)    0.35*ScreenSize(4)];
    RoiHistogram = figure('name','Roi Histogram','NumberTitle', ...
        'off','visible','on','Position',Pos,'doubleBuffer','on');
    visible_on = 'off';
else
    visible_on = get(RoiHistogram,'visible');
end
set(RoiHistogram,'visible','on');
figure(RoiHistogram);
colors = {'r-','g-','b-'};
histnames = {'roiHistogramR','roiHistogramG','roiHistogramB'};
hold on;
if size(imagesize) == [1 2]
    [n, xbin] = hist(double(userdata.currentimage(:)),256);
    userdata.pixelmax = max(userdata.currentimage(:));
    hist_h = plot(xbin, n, 'k-');
    set(hist_h,'tag','roiHistogram');
    for i=1:3
        hist_h = plot(0, 0, colors{i});
        set(hist_h,'tag',histnames{i});
    end
else
    for i=1:3
        imagetmp = userdata.currentimage(:,:,i);
        if max(imagetmp(:)) ~= 0
            [n, xbin] = hist(double(imagetmp(:)),256);
            hist_h = plot(xbin, n, colors{i});
            set(hist_h,'tag',histnames{i});
        else
            hist_h = plot(0, 0, colors{i});
            set(hist_h,'tag',histnames{i});
        end
    end
    hist_h = plot(0, 0, 'k-');
    set(hist_h,'tag','roiHistogram');
end
userdata.hist_axsish = gca;
userdata.pixelmax = max(userdata.currentimage(:));
xlabel('Pixel intensity'); ylabel('Number of events');
set(RoiHistogram,'visible',visible_on);
figure(mainfigure);
userdata.RoiHistogram = RoiHistogram;
set(roi_handler,'userdata',userdata); 
%
% calc. roi stat. 
%
xi = get(roi_handler,'Xdata'); yi = get(roi_handler,'Ydata'); 
roimask = poly2mask(xi,yi, imagesize(1),imagesize(2)); 
pixel_range = find(roimask);
imagesize_ = size(imagesize);
if size(imagesize) == [1 2]
    % intensity image case
    roimean = sprintf('%0.5g',mean(userdata.currentimage(pixel_range))); 
    roistd = sprintf('%0.5g',std(double(userdata.currentimage(pixel_range))));
    roimin = num2str(min(userdata.currentimage(pixel_range)));
    roimax = num2str(max(userdata.currentimage(pixel_range)));
else
    % truecolor (RGB) image case
    roimean = []; roistd=[]; roimin=[]; roimax=[];
    for i=1:3
        if i==1;sepchar='';else sepchar = ',';end
        imagetmp= userdata.currentimage(:,:,i);
        roimean = [roimean,sepchar, sprintf('%0.5g',mean(imagetmp(pixel_range)))]; 
        roistd = [roistd,sepchar,sprintf('%0.5g',std(double(imagetmp(pixel_range))))];
        roimin = [roimin,sepchar, num2str(min(imagetmp(pixel_range)))];
        roimax = [roimax,sepchar, num2str(max(imagetmp(pixel_range)))];
    end
end
%
% set the buttowndown event to "draggable"
%
userdata = get(roi_handler,'userdata'); 
userdata.roimean = roimean;
userdata.roistd = roistd;
userdata.roimin = roimin;
userdata.roimax = roimax; 
userdata.roipixel_range = pixel_range;
userdata.roiarea = length(userdata.roipixel_range);
userdata.lastclickedpoint = [1, 1];
set(roi_handler,'userdata',userdata);
fun_h = @(x)roitool(x,'roi_drag');
draggable(roi_handler, fun_h);

%
% Sub-function - change_radius
% -----------------------------------------------------------------------
function change_radius(roi_handler) 
     
userdata = get(roi_handler,'userdata'); 
t = userdata.t; xcenter = userdata.xcenter; ycenter = userdata.ycenter; 
 
current_pts = get(gca,'CurrentPoint'); 
current_pt = current_pts(1,1:2); 
R0 = sqrt((current_pt(1)-xcenter)^2+(current_pt(2)-ycenter)^2); 
xi = R0*cos(t)+ xcenter; 
yi = R0*sin(t)+ ycenter;
userdata.R0 = R0;
set(roi_handler,'Xdata',xi,'Ydata',yi);
set(roi_handler,'userdata',userdata); 
drawnow;
mouseclick = get(gcf,'SelectionType'); 
   
%
% Sub-function - complete_radius
% -----------------------------------------------------------------------
function complete_radius
mouseclick = get(gcf,'SelectionType'); 
if strcmp(mouseclick,'open') 
    set(gcf,'WindowButtonMotionFcn','');
    set(gcf,'WindowButtonDownFcn',''); 
end

%
% Sub-function - roi_delete
% -----------------------------------------------------------------------
function roi_delete(roi_handler)

draggable(roi_handler,'off');
userdata = get(roi_handler,'userdata');
delete(userdata.cmenu);
roi_handlers = findobj('tag','roi_handler');
% if no additional rois, delete the 
% StatValuesBar and the RoiHistogram also
if length(roi_handlers) == 1 
%     if ishandle(userdata.StatValuesBar)
%         delete(userdata.StatValuesBar);
%     end
%     if ishandle(userdata.RoiHistogram)
%         delete(userdata.RoiHistogram);
%     end
    DetailRectangleFig = findobj('name','Detail Rectangle');
    if ishandle(DetailRectangleFig)
        delete(DetailRectangleFig);
    end
end
delete(roi_handler);

%
% Sub-function - roi_drag
% -----------------------------------------------------------------------
function roi_drag(roi_handler) 
 
userdata = get(roi_handler,'userdata'); 
imagesize = size(userdata.currentimage);
xi = get(roi_handler,'Xdata'); yi = get(roi_handler,'Ydata'); 
roimask = poly2mask(xi,yi, imagesize(1),imagesize(2)); 
pixel_range = find(roimask); 
if size(imagesize) == [1 2]
    % intensity image case
    roimean = sprintf('%0.5g',mean(userdata.currentimage(pixel_range))); 
    roistd = sprintf('%0.5g',std(double(userdata.currentimage(pixel_range))));
    roimin = num2str(min(userdata.currentimage(pixel_range)));
    roimax = num2str(max(userdata.currentimage(pixel_range)));
else
    % truecolor (RGB) image case
    roimean = []; roistd=[]; roimin=[]; roimax=[];
    for i=1:3
        if i==1;sepchar='';else sepchar=',';end
        imagetmp= userdata.currentimage(:,:,i);
        roimean = [roimean,sepchar, sprintf('%0.5g',mean(imagetmp(pixel_range)))]; 
        roistd = [roistd,sepchar,sprintf('%0.5g',std(double(imagetmp(pixel_range))))];
        roimin = [roimin,sepchar, num2str(min(imagetmp(pixel_range)))];
        roimax = [roimax,sepchar, num2str(max(imagetmp(pixel_range)))];
    end
end
userdata.roimean = roimean;
userdata.roistd = roistd;
userdata.roimin = roimin;
userdata.roimax = roimax; 
userdata.roipixel_range = pixel_range;
userdata.lastclickedpoint = get(0,'PointerLocation');
set(roi_handler,'userdata',userdata); 

histFigure = findobj('name','Roi Histogram');
StatFigure = findobj('name','Roi Stat. Figure');
StatValuesBar1 = findobj('Tag', 'RoiStatValuesBar1');
StatValuesBar2 = findobj('Tag', 'RoiStatValuesBar2');
if strcmp(get(StatFigure,'visible'),'on')
    StatString1 = [' avg= ',userdata.roimean,' std= ',userdata.roistd];
    StatString2 = [' max= ',userdata.roimax,' min=',userdata.roimin, ...
        ' area= ',num2str(userdata.roiarea)];
    set(StatValuesBar1,'String',StatString1);
    set(StatValuesBar2,'String',StatString2);
end
if strcmp(get(histFigure,'visible'),'on')
    histnames = {'roiHistogramR','roiHistogramG','roiHistogramB'};
    if size(imagesize) == [1 2]
        % intensity image case
        hist_h = findobj('tag','roiHistogram');
        [n,x] = hist(double(userdata.currentimage(pixel_range)),256);
        set(hist_h,'YData',n,'Xdata',x);
        for i=1:3
            hist_h = findobj('tag',histnames{i});
            set(hist_h,'YData',0,'Xdata',0);
        end
        
    else
        % truecolor (RGB) image case
        for i=1:3
            imagetmp = userdata.currentimage(:,:,i);
            if max(imagetmp(:)) ~= 0
                [n, x] = hist(double(imagetmp(pixel_range)),256);
                hist_h = findobj('tag',histnames{i});
                set(hist_h,'YData',n,'Xdata',x);
            end
        end
        hist_h = findobj('tag','roiHistogram');
        set(hist_h,'YData',0,'Xdata',0);
    end
    set(userdata.hist_axsish,'xlim',[0 userdata.pixelmax]);
end
if strcmp(userdata.roitype,'rectangle')
    DetailRectangleFig = findobj('name','Detail Rectangle');
    if strcmp(get(DetailRectangleFig,'visible'),'on')
        drih = findobj('tag','DetailRectangleImg');
        cimg = userdata.currentimage(pixel_range);
        set(drih,'CData',reshape(cimg,userdata.cimgsize));
    end
end

%
% Sub-function - roi_resize
% -----------------------------------------------------------------------
function roi_resize(roi_handler)

userdata = get(roi_handler,'userdata');
lastclickedpoint = userdata.lastclickedpoint;
draggable(roi_handler,'off');
userdata = get(roi_handler,'userdata');
mainfigure = gcf;
if strcmp(userdata.roitype,'circle')
    disp(' ');
    % calculating the center of the circle based on 
    % R0 and 2 arbitrary points on the current circle 
    userdata = get(roi_handler,'userdata');
    xi = get(roi_handler,'Xdata'); yi = get(roi_handler,'Ydata');  
    x1 = xi(4); x2 = xi(9); % select the 4th and the 9th points (arbitrary selection)
    y1 = yi(4); y2 = yi(9);
    p = ( (x1-x2)^2 + y2^2-y1^2)/(2*(y1-y2));
    q = (x1-x2)/(y1-y2);
    a = (1+q^2);
    b = 2*(p-q^2*y1);
    c = p^2 - q^2*userdata.R0^2+q^2*y1^2;
    userdata.ycenter = (-b - sqrt(b^2-4*a*c))/(2*a);
    userdata.xcenter = x2 - sqrt(userdata.R0^2  - (y2-userdata.ycenter)^2);
    userdata.isstartresize = 1;
    userdata.lastclickedpoint = lastclickedpoint;
    set(0,'PointerLocation',userdata.lastclickedpoint);
    set(roi_handler,'userdata',userdata);

    disp('Double click to finalize the ROI!');
    set(gcf,'WindowButtonMotionFcn',['change_radius_onresize(',num2str(roi_handler,20),')']);
    set(gcf,'WindowButtonDownFcn','complete_radius'); 
    waitfor(gcf,'WindowButtonMotionFcn');
    drawnow;
elseif strcmp(userdata.roitype,'rectangle')
    disp(' ');disp('Use the mouse to click and DRAG the desired rectangle.');disp(' ');
    rectpos = [0 0 0 0];
    while rectpos(3) == 0;
        rectpos = round(getrect(gca));
        if rectpos(3) == 0;
            mbh = msgbox('Use the mouse to click and DRAG the desired rectangle.','Roi Info');
            uiwait(mbh);
        end
    end
    % refresh the coordinate range and data for detailed rectangle
    dry = round(rectpos(1)):round(rectpos(1)) + round(rectpos(3)-1);
	drx = round(rectpos(2)):round(rectpos(2)) + round(rectpos(4)-1);
    cimg = userdata.currentimage(drx,dry);
    userdata.cimgsize = size(cimg);
    DetailRectangleFig = findobj('name','Detail Rectangle');
    visible_onoff = get(DetailRectangleFig,'visible');
    drih = findobj('tag','DetailRectangleImg');
    set(drih,'CData',cimg);
    AxHandler = findobj('tag','DetailRectangleAx');
    axes(AxHandler); axis image;
    DetailRectangleFig = findobj('name','Detail Rectangle');
    if strcmp(visible_onoff,'off')
        set(DetailRectangleFig,'visible','off');
    end
    figure(mainfigure);
    % define the points for the line to be drawn 
    roi_x = [rectpos(1), rectpos(1)+rectpos(3), rectpos(1)+rectpos(3), ...
        rectpos(1), rectpos(1)];
    roi_y = [rectpos(2), rectpos(2), rectpos(2)+rectpos(4), ...
        rectpos(2)+rectpos(4), rectpos(2)] ;
    set(roi_handler,'Xdata',roi_x,'Ydata',roi_y);
    set(roi_handler,'userdata',userdata);
end

% calc. roi stat. 
userdata = get(roi_handler,'userdata');
imagesize = size(userdata.currentimage);
xi = get(roi_handler,'Xdata'); yi = get(roi_handler,'Ydata'); 
roimask = poly2mask(xi,yi, imagesize(1),imagesize(2)); 
pixel_range = find(roimask); 
if size(imagesize) == [1 2]
    % intensity image case
    roimean = sprintf('%0.5g',mean(userdata.currentimage(pixel_range))); 
    roistd = sprintf('%0.5g',std(double(userdata.currentimage(pixel_range))));
    roimin = num2str(min(userdata.currentimage(pixel_range)));
    roimax = num2str(max(userdata.currentimage(pixel_range)));
else
    % truecolor (RGB) image case
    roimean = []; roistd=[]; roimin=[]; roimax=[];
    for i=1:3
        if i==1;sepchar='';else sepchar=',';end
        imagetmp= userdata.currentimage(:,:,i);
        roimean = [roimean,sepchar, sprintf('%0.5g',mean(imagetmp(pixel_range)))]; 
        roistd = [roistd,sepchar,sprintf('%0.5g',std(double(imagetmp(pixel_range))))];
        roimin = [roimin,sepchar, num2str(min(imagetmp(pixel_range)))];
        roimax = [roimax,sepchar, num2str(max(imagetmp(pixel_range)))];
    end
end

% set the buttowndown event to "draggable"
userdata.roimean = roimean;
userdata.roistd = roistd;
userdata.roimin = roimin;
userdata.roimax = roimax; 
userdata.roipixel_range = pixel_range;
userdata.lastclickedpoint = get(0,'PointerLocation');
set(roi_handler,'userdata',userdata);
fun_h = @(x)roitool(x,'roi_drag');
draggable(roi_handler, fun_h);



%
% Sub-function - change_radius_onresize
% -----------------------------------------------------------------------
function change_radius_onresize(roi_handler) 
     
userdata = get(roi_handler,'userdata'); 
t = userdata.t; xcenter = userdata.xcenter; ycenter = userdata.ycenter; 
 
if userdata.isstartresize
    R0 = userdata.R0;
    userdata.isstartresize = 0;
    set(roi_handler,'userdata',userdata); 
else
    current_pts = get(gca,'CurrentPoint'); 
    current_pt = current_pts(1,1:2);
    R0 = sqrt((current_pt(1)-xcenter)^2+(current_pt(2)-ycenter)^2);
end
xi = R0*cos(t) + xcenter; 
yi = R0*sin(t) + ycenter; 
set(roi_handler,'Xdata',xi,'Ydata',yi);

StatValuesBar1 = findobj('Tag', 'RoiStatValuesBar1');
StatValuesBar2 = findobj('Tag', 'RoiStatValuesBar2');
StatFigure = findobj('name','Roi Stat. Figure');
if strcmp(get(StatFigure,'visible'),'on')
    roimask = poly2mask(xi,yi, size(userdata.currentimage,1), size(userdata.currentimage,2)); 
    imagesize = size(userdata.currentimage);
    xi = get(roi_handler,'Xdata'); yi = get(roi_handler,'Ydata'); 
    pixel_range = find(roimask); 
    if size(imagesize) == [1 2]
        % intensity image case
        roimean = sprintf('%0.5g',mean(userdata.currentimage(pixel_range))); 
        roistd = sprintf('%0.5g',std(double(userdata.currentimage(pixel_range))));
        roimin = num2str(min(userdata.currentimage(pixel_range)));
        roimax = num2str(max(userdata.currentimage(pixel_range)));
    else
        % truecolor (RGB) image case
        roimean = []; roistd=[]; roimin=[]; roimax=[];
        for i=1:3
            if i==1;sepchar='';else sepchar=',';end
            imagetmp= userdata.currentimage(:,:,i);
            roimean = [roimean,sepchar, sprintf('%0.5g',mean(imagetmp(pixel_range)))]; 
            roistd = [roistd,sepchar,sprintf('%0.5g',std(double(imagetmp(pixel_range))))];
            roimin = [roimin,sepchar, num2str(min(imagetmp(pixel_range)))];
            roimax = [roimax,sepchar, num2str(max(imagetmp(pixel_range)))];
        end
    end
    userdata.roimean = roimean;
    userdata.roistd = roistd;
    userdata.roipixel_range = pixel_range;
    userdata.roiarea = length(userdata.roipixel_range);
    set(roi_handler,'userdata',userdata);
    StatString1 = [' avg= ',userdata.roimean,' std= ',userdata.roistd];
    StatString2 = [' max= ',userdata.roimax,' min=',userdata.roimin, ...
        ' area= ',num2str(userdata.roiarea)];
    set(StatValuesBar1,'String',StatString1);
    set(StatValuesBar2,'String',StatString2);
end
drawnow;
mouseclick = get(gcf,'SelectionType'); 

%
% Sub-function - roi_showstat
% -----------------------------------------------------------------------
function roi_showstat(roi_handler, onoff)

StatFigure = findobj('name','Roi Stat. Figure');
if strcmp(onoff,'on')    
    StatValuesBar1 = findobj('Tag', 'RoiStatValuesBar1');
    StatValuesBar2 = findobj('Tag', 'RoiStatValuesBar2');
    set(StatFigure,'visible','on');
    ShowStatMenu = findobj(get(roi_handler,'UIContextMenu'),'tag','ShowStatMenu');
    set(ShowStatMenu,'Label', 'Show Statistics: +', 'Callback', ... 
        ['roitool(',num2str(roi_handler,20),',''roi_showstat'',''off'');']);     
    % put the current stats. values to the StatValBar
    userdata = get(roi_handler,'userdata'); 
    StatString1 = [' avg= ',userdata.roimean,' std= ',userdata.roistd];
    StatString2 = [' max= ',userdata.roimax,' min=',userdata.roimin, ...
        ' area= ',num2str(userdata.roiarea)];
    set(StatValuesBar1,'String',StatString1);
    set(StatValuesBar2,'String',StatString2);
else
    set(StatFigure,'visible','off');
    
    ShowStatMenu = findobj(get(roi_handler,'UIContextMenu'),'tag','ShowStatMenu');
    set(ShowStatMenu,'Label', 'Show Statistics: -', 'Callback', ... 
        ['roitool(',num2str(roi_handler,20),',''roi_showstat'',''on'');']);
end

%
% Sub-function - roi_showhist
% -----------------------------------------------------------------------
function roi_showhist(roi_handler, onoff)

if strcmp(onoff,'on')
    histFigure = findobj('name','Roi Histogram');
    set(histFigure,'visible','on');
    ShowHistMenu = findobj(get(roi_handler,'UIContextMenu'),'tag','ShowHistMenu');
    set(ShowHistMenu,'Label', 'Show Histogram: +', 'Callback', ...
        ['roitool(',num2str(roi_handler,20),',''roi_showhist'',''off'');']);
else
    histFigure = findobj('name','Roi Histogram');
    set(histFigure,'visible','off');
    ShowHistMenu = findobj(get(roi_handler,'UIContextMenu'),'tag','ShowHistMenu');
    set(ShowHistMenu,'Label', 'Show Histogram: -', 'Callback', ...
        ['roitool(',num2str(roi_handler,20),',''roi_showhist'',''on'');']);
end

%
% Sub-function - roi_showdetrect
% -----------------------------------------------------------------------
function roi_showdetrect(roi_handler, onoff)

if strcmp(onoff,'on')
    DetailRectangleFig = findobj('name','Detail Rectangle');
    set(DetailRectangleFig,'visible','on');
    ShowDetRectMenu = findobj(get(roi_handler,'UIContextMenu'),'tag','ShowDetRectMenu');
    set(ShowDetRectMenu,'Label', 'Show DetailedRect: +', 'Callback', ...
        ['roitool(',num2str(roi_handler,20),',''roi_showdetrect'',''off'');']);
else
    DetailRectangleFig = findobj('name','Detail Rectangle');
    set(DetailRectangleFig,'visible','off');
    ShowDetRectMenu = findobj(get(roi_handler,'UIContextMenu'),'tag','ShowDetRectMenu');
    set(ShowDetRectMenu,'Label', 'Show DetailedRect: -', 'Callback', ...
        ['roitool(',num2str(roi_handler,20),',''roi_showdetrect'',''on'');']);
end