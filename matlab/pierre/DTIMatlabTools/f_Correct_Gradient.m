function f_Correct_Gradient

%F_REFRESHGRADIENT Summary of this function goes here
%   
% This code is to correct the gradient-field direction from the
% scanner default coordinate system to the FOV-volume-based 
% coordinate system.
%
% Author:   Gaolang Gong ( gaolang@ualberta.ca )
%           Biomedical Engneering Department
%           University of Alberta
%           Canada

PP = spm_select(1,'any','Select one dicom file');
Info = dicominfo(PP);
Column_1=Info.ImageOrientationPatient(1:3);
Column_2=Info.ImageOrientationPatient(4:6);
Column_3=cross(Column_1,Column_2);
Orient_Matrix=[Column_1,Column_2,Column_3];
if det(Orient_Matrix)<0, Orient_Matrix(:,3) = -Orient_Matrix(:,3); end;

% Orientation information
    %-------------------------------------------------------------------
    % Axial Analyze voxel co-ordinate system:
    % x increases     right to left
    % y increases posterior to anterior
    % z increases  inferior to superior

    % DICOM patient co-ordinate system:
    % x increases     right to left
    % y increases  anterior to posterior
    % z increases  inferior to superior
  
    % T&T co-ordinate system:
    % x increases      left to right
    % y increases posterior to anterior
    % z increases  inferior to superior
    
    % For more details, please refer to spm_dicom_convert.m in SPM
    % package   
    %-------------------------------------------------------------------   
    
analyze_to_dicom = diag([1 -1 1]);
dicom_to_patient = Orient_Matrix;
patient_to_tal   = diag([-1 -1 1]);
Rotation_Matrix = patient_to_tal*dicom_to_patient*analyze_to_dicom;

% Gradient table in Scanner Coordinate system
Original_Gradient6 = [ 0.7071,0,0.7071;...
                                 -0.7071, 0, 0.7071;...
                                  0,0.7071, 0.7071;...
                                  0,0.7071,-0.7071;...
                                  0.7071,0.7071,0;...
                                 -0.7071, 0.7071, 0];      
                             
                             
% rotating the gradient Direction according to the rotation matrix
Corrected_gradient=((Rotation_Matrix)*Original_Gradient6')'; 
% Normalization
Norm_Vector=(sqrt(Corrected_gradient(:,1).^2+Corrected_gradient(:,2).^2+Corrected_gradient(:,3).^2)); 
Corrected_gradient(:,1)=Corrected_gradient(:,1)./Norm_Vector;
Corrected_gradient(:,2)=Corrected_gradient(:,2)./Norm_Vector;
Corrected_gradient(:,3)=Corrected_gradient(:,3)./Norm_Vector;
Corrected_gradient=[0,0,0;Corrected_gradient];
assignin('base', 'Corrected_gradient', Corrected_gradient )

%--------------------------------------------------------------------------
% Show the results in Command Windows of Matlab
%--------------------------------------------------------------------------
clc;
%%% Part I-------------------------------------------------------------
%%%--------------------------------------------------------------------
fprintf('----------------------------------------------------------------------------------------\n');
% Show the exact angle around left-right axis
Phi = atan2(Rotation_Matrix(2,3), Rotation_Matrix(3,3));
if abs(Phi*180/pi)~=0
    fprintf('1:  The rotation angle around left-right axis is %g degree.\n',abs(Phi*180/pi));
else
    fprintf('1:  No rotation around left-right axis.\n');
end
% Show the exact angle around anterior-posterior axis
Theta = asin(-Rotation_Matrix(1,3)); 
if abs(Theta*180/pi)~=0
fprintf('2:  The rotation angle around anterior-posterior axis is %g degree.\n',abs(Theta*180/pi));
else
fprintf('2:  No rotation around anterior-posterior axis.\n');
end
% In transverse scanning, no rotation around inferior-posterior axis
fprintf('3:  No rotation around inferior-posterior axis.\n');

%%% Part II-------------------------------------------------------------
%%%---------------------------------------------------------------------
fprintf('----------------------------------------------------------------------------------------\n\n');
fprintf('The corrected gradient table for DTI-studio: \n');
fprintf('***********************************************************\n');
fprintf( '%g: %8.5f, %8.5f, %8.5f\n', [[0:6]', Corrected_gradient]');
fprintf('***********************************************************\n\n');

%%% %%% %%%%%%%%%% %%% %%% %%% 
%%%                                                                  %%%
%%%                                                                  %%%
%%%                End of the Correction                 %%%
%%%                                                                 %%%
%%%                                                                 %%%
%%%%%% %%% %%% %%% %%% %%%%%%% 


%=======================================================================
% The following is the simple interface function bought from SPM
%=======================================================================

function [t,sts] = spm_select(varargin)
% File selector
% FORMAT [t,sts] = spm_select(n,typ,mesg,sel,wd,filt,frames)
%     n    - Number of files
%            A single value or a range.  e.g.
%            1       - Select one file
%            Inf     - Select any number of files
%            [1 Inf] - Select 1 to Inf files
%            [0 1]   - select 0 or 1 files
%            [10 12] - select from 10 to 12 files
%     typ  - file type
%           'any'   - all files
%           'image' - Image files (".img" and ".nii")
%                     Note that it gives the option to select
%                     individual volumes of the images.
%           'xml'   - XML files
%           'mat'   - Matlab .mat files
%           'batch' - SPM batch files (.mat and XML)
%           'dir'   - select a directory
%           Other strings act as a filter to regexp.  This means
%           that e.g. DCM*.mat files should have a typ of '^DCM.*\.mat$'
%      mesg - a prompt (default 'Select files...')
%      sel  - list of already selected files
%      wd   - Directory to start off in
%      filt - value for user-editable filter (default '.*')
%      frames - Image frame numbers to include (default '1')
%
%      t    - selected files
%      sts  - status (1 means OK, 0 means window quit)
%
% Files can be selected from disk, but "virtual" files can also be selected.
% Virtual filenames are passed by
%     spm_select('addvfiles',list)
%         where list is a cell array of filenames
% The list can be cleared by
%     spm_select('clearvfiles')
%
% FORMAT [t,sts] = spm_select('Filter',files,typ,filt,frames)
% filter the list of files (cell or char array) in the same way as the GUI would do.
% There is an additional typ 'extimage' which will match images with
% frame specifications, too. Also, there is a typ 'extdir', which will
% match canonicalised directory names.
%
% FORMAT cpath = spm_select('CPath',path,cwd)
% function to canonicalise paths: Prepends cwd to relative paths, processes
% '..' & '.' directories embedded in path.
% path     - string matrix containing path name
% cwd      - current working directory [defaut '.']
% cpath    - conditioned paths, in same format as input path argument
%
% FORMAT [files,dirs]=spm_select('List',direc,filt,frames)
% Returns files matching the filter (filt) and directories within dire
% direc    - directory to search
% filt     - filter to select files with (see regexp) e.g. '^w.*\.img$'
% frames   - vector of frames to select (defaults to [], if not specified)
% files    - files matching 'filt' in directory 'direc'
% dirs     - subdirectories of 'direc'
%____________________________________________________________________________
% Copyright (C) 2005 Wellcome Department of Imaging Neuroscience

% John Ashburner
% $Id: spm_select.m 735 2007-02-12 15:07:42Z volkmar $

if nargin > 0 && ischar(varargin{1})
    switch lower(varargin{1})
        case 'addvfiles'
            error(nargchk(2,Inf,nargin));
            vfiles('add',varargin{2:end});
        case 'clearvfiles'
            error(nargchk(1,1,nargin));
            vfiles('clear');
        case 'vfiles'
            error(nargchk(1,1,nargin));
            t = vfiles('all');
        case 'cpath'
            error(nargchk(2,Inf,nargin));
            t = cpath(varargin{2:end});
        case 'filter'
            filt    = mk_filter(varargin{3:end});
            cs      = iscell(varargin{2});
            if ~cs 
                t = cellstr(varargin{2});
            else
                t = varargin{2};
            end;
            [t,sts] = do_filter(t,filt.ext);
            [t,sts] = do_filter(t,filt.filt);
            if ~cs
                t = strvcat(t);
            end;
        case 'list'
	    if nargin > 3
		frames = varargin{4};
	    else
		frames = [];
	    end;
            filt    = mk_filter('any',varargin{3},frames);
            [t,sts] = listfiles(varargin{2},filt);
        otherwise 
            error('Inappropriate usage.');
    end
else
    [t,sts] = selector(varargin{:});
end
%=======================================================================

%=======================================================================
function [t,ok] = selector(n,typ,mesg,already,wd,filt,frames,varargin)
if nargin<7, frames  = '1';     end;
if nargin<6, filt    = '.*';    end;
if nargin<5, wd      = pwd;     end;
if nargin<4, already = {''};    end;
if nargin<3, mesg    = 'Select files...'; end;
if nargin<2, typ     = 'any';   end;
if nargin<1, n       = [0 Inf]; end;
ok  = 0;
if numel(n)==1,   n    = [n n];    end;
if n(1)>n(2),     n    = n([2 1]); end;
if ~finite(n(1)), n(1) = 0;        end;
already = strvcat(already);

t = '';
sfilt = mk_filter(typ,filt,frames);

[col1,col2,col3,fs] = colours;

fg = figure('IntegerHandle','off',...
        'Tag','Select',...
        'Name',strvcat(mesg),...
        'NumberTitle','off',...
        'Units','Pixels',...
        'MenuBar','none',...
        'DefaultTextInterpreter','none',...
        'DefaultUicontrolInterruptible','on',...
        'ResizeFcn',@resize_fun,...
        'KeyPressFcn',@hitkey);

% Code from Brian Lenoski for dealing with multiple monitors
if spm_matlab_version_chk('7') >=0
    S    = get(0, 'MonitorPosition');
    Rect = get(fg,'Position');
    pointer_loc = get(0,'PointerLocation');

    for i = 1:size(S,1), % Loop over monitors
        h_min   = S(i,1);
        h_width = S(i,3);
        h_max   = h_width + h_min - 1;
        v_min   = S(i,2);
        v_len   = S(i,4);
        v_max   = v_min + v_len;

        % Use the monitor containing the pointer
        if pointer_loc(1) >= h_min && pointer_loc(1) < h_max && ...
           pointer_loc(2) >= v_min && pointer_loc(2) < v_max,
            hor_min   = h_min;
            hor_width = h_width;
            hor_max   = h_max;
            ver_min   = v_min;
            ver_len   = v_len;
            ver_max   = v_max;
        end
    end
    Rect(1) = (hor_max - 0.5*hor_width) - 0.5*Rect(3); % Horizontal
    Rect(2) = (ver_max - 0.5*ver_len)   - 0.5*Rect(4); % Vertical
    set(fg,'Position',Rect);
end


fh = 0.05;
%fs = 10;

sbh = 0.03; % Scroll-bar height.  This should be worked out properly
h1 = (0.96-4*fh-5*0.01)/2;
if n(2)*fh+sbh<h1,
    h1 = min([max([n(2) size(already,1)+.2])*fh+sbh, h1]);
end;
h2 = 0.96-4*fh-5*0.01-h1;

SPMdir = fileparts(which(mfilename));
if ( spm_matlab_version_chk('7') >= 0 ) && isdeployed,
    ind = findstr(SPMdir,'_mcr')-1;
    [SPMdir,junk] = fileparts(SPMdir(1:ind(1)));
end;
prevdirs([SPMdir filesep]);
[pd,vl] = prevdirs([wd filesep]);

% Selected Files
hp = 0.02;
sel = uicontrol(fg,...
    'style','listbox',...
    'units','normalized',...
    'Position',[0.02 hp 0.96 h1],...
    'FontSize',fs,...
    'Callback',@unselect,...
    'tag','selected',...
    'BackgroundColor',col1,...
    'ForegroundColor',col3,...
    'Max',10000,...
    'Min',0,...
    'String',already,...
    'Value',1);
c0 = uicontextmenu('Parent',fg);
set(sel,'uicontextmenu',c0);
uimenu('Label','Unselect All', 'Parent',c0,'Callback',@unselect_all);

% Messages
hp = hp+h1+0.01;
uicontrol(fg,...
    'style','text',...
    'units','normalized',...
    'Position',[0.02 hp 0.96 fh],...
    'FontSize',fs,...
    'BackgroundColor',get(fg,'Color'),...
    'ForegroundColor',col3,...
    'HorizontalAlignment','left',...
    'Tag','msg',...
    'String',mesg);

if strcmpi(typ,'image'),
    uicontrol(fg,...
        'style','edit',...
        'units','normalized',...
        'Position',[0.61 hp 0.37 fh],...
        'Callback',@update_frames,...
        'tag','frame',...
        'FontSize',fs,...
        'BackgroundColor',col1,...
        'String',frames,'UserData',eval(frames));
% 'ForegroundGolor',col3,...
end;

% Help
hp = hp+fh+0.01;
uicontrol(fg,...
    'Style','pushbutton',...
    'units','normalized',...
    'Position',[0.02 hp fh fh],...
    'FontSize',fs,...
    'Callback',@heelp,...
    'tag','?',...
    'ForegroundColor',col3,...
    'BackgroundColor',col1,...
    'String','?',...
    'FontWeight','bold',...
    'ToolTipString','Show Help',...
    'FontSize',fs);

uicontrol(fg,...
    'Style','pushbutton',...
    'units','normalized',...
    'Position',[0.03+fh hp fh fh],...
    'FontSize',fs,...
    'Callback',@editwin,...
    'tag','Ed',...
    'ForegroundColor',col3,...
    'BackgroundColor',col1,...
    'String','Ed',...
    'FontWeight','bold',...
    'ToolTipString','Edit Selected Files',...
    'FontSize',fs);

uicontrol(fg,...
   'Style','pushbutton',...
   'units','normalized',...
   'Position',[0.04+2*fh hp fh fh],...
   'FontSize',fs,...
   'Callback',@select_rec,...
   'tag','Rec',...
   'ForegroundColor',col3,...
   'BackgroundColor',col1,...
   'String','Rec',...
   'FontWeight','bold',...
   'ToolTipString','Recursively Select Files with Current Filter',...
   'FontSize',fs);

% Done
dne = uicontrol(fg,...
    'Style','pushbutton',...
    'units','normalized',...
    'Position',[0.05+3*fh hp 0.45-3*fh fh],...
    'FontSize',fs,...
    'Callback',@delete,...
    'tag','D',...
    'ForegroundColor',col3,...
    'BackgroundColor',col1,...
    'String','Done',...
    'FontWeight','bold',...
    'FontSize',fs,...
    'Enable','off',...
    'DeleteFcn',@null);

if size(already,1)>=n(1) && size(already,1)<=n(2),
    set(dne,'Enable','on');
end;

% Filter Button
uicontrol(fg,...
    'Style','pushbutton',...
    'units','normalized',...
    'Position',[0.51 hp 0.1 fh],...
    'FontSize',fs,...
    'ForegroundColor',col3,...
    'BackgroundColor',col1,...
    'Callback',@clearfilt,...
    'String','Filt',...
    'FontSize',fs);

% Filter
uicontrol(fg,...
    'style','edit',...
    'units','normalized',...
    'Position',[0.61 hp 0.37 fh],...
    'ForegroundColor',col3,...
    'BackgroundColor',col1,...
    'FontSize',fs,...
    'Callback',@update,...
    'tag','regexp',...
    'String',filt,...
    'UserData',sfilt);

% Directories
hp = hp + fh+0.01;
db = uicontrol(fg,...
    'style','listbox',...
    'units','normalized',...
    'Position',[0.02 hp 0.47 h2],...
    'FontSize',fs,...
    'Callback',@click_dir_box,...
    'tag','dirs',...
    'BackgroundColor',col1,...
    'ForegroundColor',col3,...
    'Max',1,...
    'Min',0,...
    'String','',...
    'UserData',wd,...
    'Value',1);

% Files
tmp = uicontrol(fg,...
    'style','listbox',...
    'units','normalized',...
    'Position',[0.51 hp 0.47 h2],...
    'FontSize',fs,...
    'Callback',@click_file_box,...
    'tag','files',...
    'BackgroundColor',col1,...
    'ForegroundColor',col3,...
    'UserData',n,...
    'Max',10240,...
    'Min',0,...
    'String','',...
    'Value',1);
c0 = uicontextmenu('Parent',fg);
set(tmp,'uicontextmenu',c0);
uimenu('Label','Select All', 'Parent',c0,'Callback',@select_all);

% Drives
if strcmpi(computer,'PCWIN') || strcmpi(computer,'PCWIN64'),
    dr  = spm_platform('drives');
    drivestr = cell(1,numel(dr));
    for i=1:numel(dr),
        drivestr{i} = [dr(i) ':'];
    end;
    %drivestr = {'A:','B:','C:','D:'};
    sz = get(db,'Position');
    sz(4) = sz(4)-fh-2*0.01;
    set(db,'Position',sz);
    uicontrol(fg,...
        'style','text',...
        'units','normalized',...
        'Position',[0.02 hp+h2-fh-0.01 0.10 fh],...
        'FontSize',fs,...
        'BackgroundColor',get(fg,'Color'),...
        'ForegroundColor',col3,...
        'String','Drive');
    uicontrol(fg,...
        'style','popupmenu',...
        'units','normalized',...
        'Position',[0.12 hp+h2-fh-0.01 0.37 fh],...
        'FontSize',fs,...
        'Callback',@setdrive,...
        'tag','drive',...
        'BackgroundColor',col1,...
        'ForegroundColor',col3,...
        'String',drivestr,...
        'Value',1);
end;

% Previous dirs
hp = hp+h2+0.01;
uicontrol(fg,...
    'style','popupmenu',...
    'units','normalized',...
    'Position',[0.12 hp 0.86 fh],...
    'FontSize',fs,...
    'Callback',@click_dir_list,...
    'tag','previous',...
    'BackgroundColor',col1,...
    'ForegroundColor',col3,...
    'String',pd,...
    'Value',vl);
uicontrol(fg,...
    'style','text',...
    'units','normalized',...
    'Position',[0.02 hp 0.10 fh],...
    'FontSize',fs,...
    'BackgroundColor',get(fg,'Color'),...
    'ForegroundColor',col3,...
    'String','Prev');

% Directory
hp = hp + fh+0.01;
uicontrol(fg,...
    'style','edit',...
    'units','normalized',...
    'Position',[0.12 hp 0.86 fh],...
    'FontSize',fs,...
    'Callback',@edit_dir,...
    'tag','edit',...
    'BackgroundColor',col1,...
    'ForegroundColor',col3,...
    'String','');
uicontrol(fg,...
    'style','text',...
    'units','normalized',...
    'Position',[0.02 hp 0.10 fh],...
    'FontSize',fs,...
    'BackgroundColor',get(fg,'Color'),...
    'ForegroundColor',col3,...
    'String','Dir');

resize_fun(fg);
update(sel,wd)

waitfor(dne);
drawnow;
if ishandle(sel),
    t  = get(sel,'String');
    if sfilt.code == -1
        t = cellstr(t);
        for k = 1:numel(t);
            t{k} = cpath(t{k},pwd);
        end;
        t = char(t);
    end;
    ok = 1;
end;
if ishandle(fg),  delete(fg); end;
drawnow;
return;
%=======================================================================

%=======================================================================
function null(varargin)
%=======================================================================

%=======================================================================
function msg(ob,str)
ob = sib(ob,'msg');
set(ob,'String',str);
if nargin>=3,
    set(ob,'ForegroundColor',[1 0 0],'FontWeight','bold');
else
    set(ob,'ForegroundColor',[0 0 0],'FontWeight','normal');
end;
drawnow;
return;
%=======================================================================

%=======================================================================
function setdrive(ob,varargin)
st = get(ob,'String');
vl = get(ob,'Value');
update(ob,st{vl});
return;
%=======================================================================

%=======================================================================
function resize_fun(fg,varargin)
ob = findobj(fg,'String','Filt','Style','pushbutton');
if ~isempty(ob),
    ofs = get(ob,'FontSize');
    ex = get(ob,'Extent');
    ps = get(ob,'Position');
    fs = floor(ofs*min(ps(4)./ex(4))+1);
    fs = max(min(fs,30),4);
    ob = findobj(fg,'Fontsize',ofs);
    set(ob,'FontSize',fs);
end;
return;
%=======================================================================

%=======================================================================
function [d,mch] = prevdirs(d)
persistent pd
if ~iscell(pd), pd = {}; end;
d   = deblank(d);
mch = find(strcmp(d,pd));
if isempty(mch),
    pd  = {pd{:},d};
    mch = length(pd);
end;
d = pd;
return;
%=======================================================================

%=======================================================================
function clearfilt(ob,varargin)
set(sib(ob,'regexp'),'String','.*');
update(ob);
return;
%=======================================================================

%=======================================================================
function click_dir_list(ob,varargin)
vl = get(ob,'Value');
ls = get(ob,'String');
update(ob,deblank(ls{vl}));
return;
%=======================================================================

%=======================================================================
function edit_dir(ob,varargin)
update(ob,get(ob,'String'));
return;
%=======================================================================

%=======================================================================
function click_dir_box(lb,varargin)
update(lb,current_dir(lb));
return;
%=======================================================================

%=======================================================================
function dr = current_dir(lb,varargin)
vl  = get(lb,'Value');
str = get(lb,'String');
pd  = get(sib(lb,'edit'),'String');
while ~isempty(pd) & strcmp(pd(end),filesep) 
    pd=pd(1:end-1);      % Remove any trailing fileseps
end 
sel = deblank(str(vl,:));
if strcmp(sel,'..'),     % Parent directory 
    dr = fileparts(pd);
elseif strcmp(sel,'.'),  % Current directory 
    dr = pd;
else
    dr = fullfile(pd,sel);    
end;
return;
%=======================================================================

%=======================================================================
function re = getfilt(ob)
ob  = sib(ob,'regexp');
ud  = get(ob,'UserData');
re  = struct('code',ud.code,...
             'frames',get(sib(ob,'frame'),'UserData'),...
             'ext',{ud.ext},...
             'filt',{{get(sib(ob,'regexp'),'String')}});
return;
%=======================================================================

%=======================================================================
function update(lb,dr)
lb = sib(lb,'dirs');
if nargin<2 || isempty(dr),
    dr = get(lb,'UserData');
end;
if ~(strcmpi(computer,'PCWIN') || strcmpi(computer,'PCWIN64'))
    dr    = [filesep dr filesep];
else
    dr    = [dr filesep];
end;
dr(findstr([filesep filesep],dr)) = [];
[f,d] = listfiles(dr,getfilt(lb));
if isempty(d),
    dr    = get(lb,'UserData');
    [f,d] = listfiles(dr,getfilt(lb));
else
    set(lb,'UserData',dr);
end;
set(lb,'Value',1,'String',d);
set(sib(lb,'files'),'Value',1,'String',f);
[ls,mch] = prevdirs(dr);
set(sib(lb,'previous'),'String',ls,'Value',mch);
set(sib(lb,'edit'),'String',dr);

if numel(dr)>1 && dr(2)==':',
    str = get(sib(lb,'drive'),'String');
    str = cat(1,char(str));
    mch = find(lower(str(:,1))==lower(dr(1)));
    if ~isempty(mch),
        set(sib(lb,'drive'),'Value',mch);
    end;
end;
return;
%=======================================================================

%=======================================================================
function update_frames(lb,varargin)
str = get(lb,'String');
%r   = get(lb,'UserData');
try
    r = eval(['[',str,']']);
catch
    msg(lb,['Failed to evaluate "' str '".'],'r');
    beep;
    return;
end;
if ~isnumeric(r),
    msg(lb,['Expression non-numeric "' str '".'],'r');
    beep;
else
    set(lb,'UserData',r);
    msg(lb,'');
    update(lb);
end;
%=======================================================================

%=======================================================================
function select_all(ob,varargin)
lb = findobj(get(get(ob,'Parent'),'Parent'),'Tag','files');
str  = get(lb,'String');
set(lb,'Value',1:size(str,1));
drawnow;
click_file_box(lb);
return;
%=======================================================================

%=======================================================================
function click_file_box(lb,varargin)
lim  = get(lb,'UserData');
ob   = sib(lb,'selected');
str3 = get(ob,'String');

str  = get(lb,'String');
vlo  = get(lb,'Value');
lim1  = min(max(lim(2)-size(str3,1),0),length(vlo));
if isempty(vlo),
    msg(lb,'Nothing selected');
    return;
end;
if lim1==0,
    msg(lb,['Selected ' num2str(size(str3,1)) '/' num2str(lim(2)) ' already.']);
    beep;
    set(sib(lb,'D'),'Enable','on');
    return;
end;

vl   = vlo(1:lim1);
msk  = false(size(str,1),1);
if vl>0, msk(vl) = true; else msk = []; end;
str1 = str( msk,:);
str2 = str(~msk,:);
dr   = [current_dir(sib(lb,'dirs')) filesep];
str1 = [repmat(dr,size(str1,1),1) str1];

set(lb,'Value',min(vl(1),size(str2,1)),'String',str2);
r    = (1:size(str1,1))+size(str3,1);
str3 = deblank(strvcat(str3,str1));
set(ob,'String',str3,'Value',r);
if length(vlo)>lim1,
    msg(lb,['Retained ' num2str(lim1) '/' num2str(length(vlo))...
        ' of selection.']);
    beep;
elseif finite(lim(2))
    if lim(1)==lim(2),
        msg(lb,['Selected ' num2str(size(str3,1)) '/' num2str(lim(2)) ' files.']);
    else
        msg(lb,['Selected ' num2str(size(str3,1)) '/' num2str(lim(1)) '-' num2str(lim(2)) ' files.']);
    end;
else
    if size(str3,1) == 1, ss = ''; else ss = 's'; end;
    msg(lb,['Selected ' num2str(size(str3,1)) ' file' ss '.']);
end;
if ~finite(lim(1)) || size(str3,1)>=lim(1),
    set(sib(lb,'D'),'Enable','on');
end;

return;
%=======================================================================

%=======================================================================
function obj = sib(ob,tag)
obj = findobj(get(ob,'Parent'),'Tag',tag);
return;
%if isempty(obj),
%    error(['Can''t find object with tag "' tag '".']);
%elseif length(obj)>1,
%    error(['Found ' num2str(length(obj)) ' objects with tag "' tag '".']);
%end;
%return;
%=======================================================================

%=======================================================================
function unselect(lb,varargin)
vl      = get(lb,'Value');
if isempty(vl), return; end;
str     = get(lb,'String');
msk     = ones(size(str,1),1);
if vl~=0, msk(vl) = 0; end;
str2    = str(logical(msk),:);
set(lb,'Value',min(vl(1),size(str2,1)),'String',str2);
lim = get(sib(lb,'files'),'UserData');
if size(str2,1)>= lim(1) && size(str2,1)<= lim(2),
    set(sib(lb,'D'),'Enable','on');
else 
    set(sib(lb,'D'),'Enable','off');
end;

if size(str2,1) == 1, ss1 = ''; else ss1 = 's'; end;
%msg(lb,[num2str(size(str2,1)) ' file' ss ' remaining.']);
if numel(vl) == 1, ss = ''; else ss = 's'; end;
msg(lb,['Unselected ' num2str(numel(vl)) ' file' ss '. ' ...
        num2str(size(str2,1)) ' file' ss1 ' remaining.']);
return;
%=======================================================================

%=======================================================================
function unselect_all(ob,varargin)
lb = findobj(get(get(ob,'Parent'),'Parent'),'Tag','selected');
set(lb,'Value',[],'String','','ListBoxTop',1);
msg(lb,'Unselected all files.');
lim = get(sib(lb,'files'),'UserData');
if lim(1)>0, set(sib(lb,'D'),'Enable','off'); end;
return;
%=======================================================================

%=======================================================================
function varargout = vfiles(option,varargin)
persistent vfs
if isempty(vfs),
    vfs = newvfs;
end;

switch option,
case {'clear'}
    vfs = newvfs;
case {'add'}
    for j=1:numel(varargin),
        pth = {};
        fle = {};
        if ischar(varargin{j}),
            for i=1:size(varargin{j},1),
                [pth{i} n e v] = spm_fileparts(deblank(varargin{j}(i,:)));
                fle{i} = [n e v];
            end;
        elseif iscell(varargin{j}),
            for i=1:numel(varargin{j}),
                [pth{i} n e v] = spm_fileparts(deblank(varargin{j}{i}));
                fle{i} = [n e v];
            end;
        end;
        [pu pi pj] = unique(pth);
        for k = 1:numel(pu)
            vfs = addvfile(vfs,pu{k},fle(pj==k));
        end;
    end;
case {'list'}
    [varargout{1:3}] = listvfiles(vfs,varargin{:});
case {'all'}
    varargout{1} = vfs;
otherwise
    error('Unknown option.');
end;
return;
%=======================================================================

%=======================================================================
function vfs = newvfs(nam)
if nargin==0, nam = ''; end;
vfs = struct('name',nam,'dirs',struct('name',{},'dirs',{},'files',{}),'files',struct('name',{},'ind',{}));
return;
%=======================================================================

%=======================================================================
function vfs = addvfile(vfs,pth,fle)
if isempty(pth),
    for k = 1:numel(fle)
    [unused,nam,ext,num] = spm_fileparts(fle{k});
    if ~isempty(num),
        ind = [str2num(num) 1 1];
        ind = ind(1);
    else
        ind = [];
    end;
    fname = [nam ext];
    mch   = strcmp(fname,{vfs.files.name});
    if any(mch),
        mch                = find(mch);
        vfs.files(mch).ind = [vfs.files(mch).ind ind];
    else
        vfs.files(end+1).name = fname;
        vfs.files(end).ind    = ind;
    end;
    end;
else
    ind = find(pth==filesep);
    if isempty(ind)
        dr  = pth;
        pth = '';
    else
        if any(ind==1),
            ind = ind(2:end)-1;
            pth = pth(2:end);
        end;
        if isempty(ind)
            dr  = pth;
            pth = '';
        else
            dr   = pth(1:(ind(1)-1));
            pth  = pth((ind(1)+1):end);
        end;
    end;
    mch  = strcmp(dr,{vfs.dirs.name});
    if any(mch),
        mch           = find(mch);
    else
        mch           = numel(vfs.dirs)+1;
        vfs.dirs(mch) = newvfs(dr);
    end;
    vfs.dirs(mch)     = addvfile(vfs.dirs(mch),pth,fle);
end;
return;
%=======================================================================

%=======================================================================
function [f,d] = listfiles(dr,filt)
ob = gco;
msg(ob,'Listing directory...');
if nargin<2, filt = '';  end;
if nargin<1, dr   = '.'; end;
de      = dir(dr);
if ~isempty(de),
    d     = {de([de.isdir]).name};
    if ~any(strcmp(d, '.'))
        d = {'.', d{:}};
    end;
    if filt.code~=-1,
        f = {de(~[de.isdir]).name};
    else
        % f = d(3:end);
        f = d;
    end;
else
    d = {'.','..'};
    f = {};
end;

msg(ob,['Filtering ' num2str(numel(f)) ' files...']);
f  = do_filter(f,filt.ext);
f  = do_filter(f,filt.filt);
ii = cell(1,numel(f));
if filt.code==1 && (numel(filt.frames)~=1 || filt.frames(1)~=1),
    msg(ob,['Reading headers of ' num2str(numel(f)) ' images...']);
    for i=1:numel(f),
        try
            ni = nifti(fullfile(dr,f{i}));
            dm = [ni.dat.dim 1 1 1 1 1];
            d4 = (1:dm(4))';
        catch
            d4 = 1;
        end;
        msk = false(size(filt.frames));
        for j=1:numel(msk), msk(j) = any(d4==filt.frames(j)); end;
        ii{i} = filt.frames(msk);
    end;
elseif filt.code==1 && (numel(filt.frames)==1 && filt.frames(1)==1),
    for i=1:numel(f),
        ii{i} = 1;
    end;
end;

msg(ob,'Listing virtual files...');
[fv,dv,iv] = vfiles('list',dr);
if filt.code==-1,
    fv = dv;
    iv = cell(size(fv));
end;
msg(ob,['Filtering ' num2str(numel(fv)) ' virtual files...']);
[fv,ind]   = do_filter(fv,filt.ext);
iv         = iv(ind);
[fv,ind]   = do_filter(fv,filt.filt);
iv         = iv(ind);
if filt.code==1,
    for i=1:numel(iv),
        msk   = false(size(filt.frames));
        for j=1:numel(msk), msk(j) = any(iv{i}==filt.frames(j)); end;
        iv{i} = filt.frames(msk);
    end;
end;

d       = { d{:},dv{:}};
f       = { f{:},fv{:}};
ii      = {ii{:},iv{:}};

msg(ob,['Listing ' num2str(numel(f)) ' files...']);

[f,ind] = sortrows(f(:));
ii      = ii(ind);
msk     = true(1,numel(f));
if ~isempty(f), f{1} = deblank(f{1}); end;
for i=2:numel(f),
    f{i} = deblank(f{i});
    if strcmp(f{i-1},f{i}),
        if filt.code==1,
            tmp      = sort([ii{i}(:) ; ii{i-1}(:)]);
            tmp(~diff(tmp,1)) = [];
            ii{i}    = tmp;
        end;
        msk(i-1) = false;
    end;
end;
f        = f(msk);
if filt.code==1,
    ii       = ii(msk);
    c        = cell(size(f));
    for i=1:numel(f),
        c{i} = [repmat([f{i} ','],numel(ii{i}),1) num2str(ii{i}(:)) ];
    end;
    f        = c;
elseif filt.code==-1,
    fs = filesep;
    for i=1:numel(f),
        f{i} = [f{i} fs];
    end;
end;
f        = strvcat(f{:});

d        = sortrows(d(:));
d        = strvcat(d);
sam      = find(~any(diff(d+0,1),2));
d(sam,:) = [];

msg(ob,'');
return;
%=======================================================================

%=======================================================================
function [f,ind] = do_filter(f,filt)
t2 = false(numel(f),1);
% This would be a speedup, but does not work on MATLAB < R14SP3 due to
% changes in regexp handling
% filt_or = sprintf('(%s)|',filt{:});
% t1 = regexp(f,filt_or(1:end-1));
% if numel(f)==1 && ~iscell(t1), t1 = {t1}; end;
% for i=1:numel(t1),
%     t2(i) = ~isempty(t1{i});
% end;
for j=1:numel(filt),
    t1 = regexp(f,filt{j});
    if numel(f)==1 && ~iscell(t1), t1 = {t1}; end;
    for i=1:numel(t1),
        t2(i) = t2(i) || ~isempty(t1{i});
    end;
end;
ind = find(t2);
f   = f(ind);
return;
%=======================================================================

%=======================================================================
function [f,d,ii] = listvfiles(vfs,dr)
f  = {};
d  = {};
ii = {};
if isempty(dr),
    f  = {vfs.files.name};
    ii = {vfs.files.ind};
    d  = {vfs.dirs.name};
else
    if dr(1)==filesep, dr = dr(2:end); end;
    ind = find(dr==filesep);
    if isempty(ind),
        d1 = dr;
        d2 = '';
    else
        d1 = dr(1:(ind(1)-1));
        d2 = dr((ind(1)+1):end);
    end;
    for i=1:length(vfs.dirs),
        if strcmp(d1,vfs.dirs(i).name),
            [f,d,ii] = listvfiles(vfs.dirs(i),d2);
            break;
        end;
    end;
end;
return;
%=======================================================================

%=======================================================================
function heelp(ob,varargin)
[col1,col2,col3,fs] = colours;
fg = get(ob,'Parent');
t  = uicontrol(fg,...
    'style','listbox',...
    'units','normalized',...
    'Position',[0.01 0.01 0.98 0.98],...
    'FontSize',fs,...
    'FontName','FixedWidthFont',...
    'BackgroundColor',col2,...
    'ForegroundColor',col3,...
    'Max',0,...
    'Min',0,...
    'tag','HelpWin',...
    'String','                   ');
c0 = uicontextmenu('Parent',fg);
set(t,'uicontextmenu',c0);
uimenu('Label','Done', 'Parent',c0,'Callback',@helpclear);

ext = get(t,'Extent');
pw  = floor(0.98/ext(3)*20-4);
str  = spm_justify(pw,{[...
'File Selection help. You can return to selecting files via the right mouse button (the "Done" option). ',...
'Because of a bug in Matlab (on some machines), don''t resize this window when viewing the help.'],...
'',[...
'The panel at the bottom shows files that are already selected. ',...
'Clicking a selected file will un-select it. To un-select several, you can ',...
'drag the cursor over the files, and they will be gone on release. ',...
'You can use the right mouse button to un-select everything.'],...
'',[...
'Directories are navigated by editing the name of the current directory (where it says "Dir"), ',...
'by going to one of the previously entered directories ("Prev"), or by navigating around ',...
'the parent or subdirectories listed in the left side panel.'],...
'',[...
'Files matching the filter ("Filt") are shown in the panel on the right. ',...
'These can be selected by clicking or dragging.  Use the right mouse button if ',...
'you would like to select all files.  Note that when selected, the files disappear ',...
'from this panel.  They can be made to reappear by re-specifying the directory ',...
'or the filter. ',...
'Note that the syntax of the filter differs from that used by previous versions of ',...
'SPM.  The following is a list of symbols with special meaning for filtering the filenames:'],...
'    ^     start of string',...
'    $     end of string',...
'    .     any character',...
'    \     quote next character',...
'    *     match zero or more',...
'    +     match one or more',...
'    ?     match zero or one, or match minimally',...
'    {}    match a range of occurrances',...
'    []    set of characters',...
'    [^]   exclude a set of characters',...
'    ()    group subexpression',...
'    \w    match word [a-z_A-Z0-9]',...
'    \W    not a word [^a-z_A-Z0-9]',...
'    \d    match digit [0-9]',...
'    \D    not a digit [^0-9]',...
'    \s    match white space [ \t\r\n\f]',...
'    \S    not a white space [^ \t\r\n\f]',...
'    \<WORD\>    exact word match',...
'',[...
'Individual time frames of image files can also be selected.  The frame filter ',...
'allows specified frames to be shown, which is useful for image files that ',...
'contain multiple time points.  If your images are only single time point, then ',...
'reading all the image headers can be avoided by specifying a frame filter of "1". ',...
'The filter should contain a list of integers indicating the frames to be used. ',...
'This can be generated by e.g. "1:100", or "1:2:100".'],...
'',[...
'The recursive selection button (Rec) allows files matching the regular expression to ',...
'be recursively selected.  If there are many directories to search, then this can take ',...
'a while to run.'],...
'',[...
'There is also an edit button (Ed), which allows you to edit your selection of files. ',...
'When you are done, then use the menu-button of your mouse to either cancel or accept your changes'],''});
pad = cellstr(char(zeros(max(0,floor(1.2/ext(4) - numel(str))),1)));
str = {str{:}, pad{:}};
set(t,'String',str);
return;
%=======================================================================

%=======================================================================
function helpclear(ob,varargin)
ob = get(ob,'Parent');
ob = get(ob,'Parent');
ob = findobj(ob,'Tag','HelpWin');
delete(ob);
%=======================================================================

%=======================================================================
function hitkey(fg,varargin)
ch = get(fg,'CurrentCharacter');
if isempty(ch), return; end;

ob = findobj(fg,'Tag','files');
if ~isempty(ob),
    f = get(ob,'String');
    f = f(:,1);
    fset = find(f>=ch);
    if ~isempty(fset),
        fset = fset(1);
        %cb = get(ob,'Callback');
        %set(ob,'Callback',[]);
        set(ob,'ListboxTop',fset);
        %set(ob,'Callback',cb);
    else
        set(ob,'ListboxTop',length(f));
    end;
end;
return;
%=======================================================================

%=======================================================================
function t = cpath(t,d)
switch spm_platform('filesys'),
case 'unx',
    mch = '^/';
    fs  = '/';
    fs1 = '/';
case 'win',
    mch = '^.:\\';
    fs  = '\';
    fs1 = '\\';
otherwise;
    error('What is this filesystem?');
end

if isempty(regexp(t,mch,'once')),
    if nargin<2, d = pwd; end;
    t = [d fs t];
end;

% Replace occurences of '/./' by '/' (problems with e.g. /././././././')
re = [fs1 '\.' fs1];
while ~isempty(regexp(t,re)),
    t  = regexprep(t,re,fs);
end;
t  = regexprep(t,[fs1 '\.' '$'], fs);

% Replace occurences of '/abc/../' by '/'
re = [fs1 '[^' fs1 ']+' fs1 '\.\.' fs1];
while ~isempty(regexp(t,re)),
    t  = regexprep(t,re,fs,'once');
end;
t  = regexprep(t,[fs1 '[^' fs1 ']+' fs1 '\.\.' '$'],fs,'once');

% Replace '//'
t  = regexprep(t,[fs1 '+'], fs);
%=======================================================================

%=======================================================================
function editwin(ob,varargin)
[col1,col2,col3,fs] = colours;
fg   = get(ob,'Parent');
lb   = findobj(fg,'Tag','selected');
str  = get(lb,'String');
str  = cellstr(str);
h    = uicontrol(fg,'Style','Edit',...
        'units','normalized',...
        'String',str,...
        'FontSize',16,...
        'Max',2,...
        'Tag','EditWindow',...
        'HorizontalAlignment','Left',...
        'ForegroundColor',col3,...
        'BackgroundColor',col1,...
        'Position',[0.01 0.01 0.98 0.98]);
c0 = uicontextmenu('Parent',fg);
set(h,'uicontextmenu',c0);
uimenu('Label','Cancel', 'Parent',c0,'Callback',@editclear);
uimenu('Label','Accept', 'Parent',c0,'Callback',@editdone);
%=======================================================================

%=======================================================================
function editdone(ob,varargin)
ob  = get(ob,'Parent');
ob  = sib(ob,'EditWindow');
str = get(ob,'String');
str = deblank(cellstr(strvcat(str)));
if isempty(str{1}), str = {}; end;

lim = get(sib(ob,'files'),'UserData');
if numel(str)>lim(2),
    msg(ob,['Retained ' num2str(lim(2)) ' of the ' num2str(numel(str)) ' files.']);
    beep;
    str = str(1:lim(2));
elseif finite(lim(2)),
    if lim(1)==lim(2),
        msg(ob,['Specified ' num2str(numel(str)) '/' num2str(lim(2)) ' files.']);
    else
        msg(ob,['Selected ' num2str(numel(str)) '/' num2str(lim(1)) '-' num2str(lim(2)) ' files.']);
    end;
else
    if numel(str) == 1, ss = ''; else ss = 's'; end;
    msg(ob,['Specified ' num2str(numel(str)) ' file' ss '.']);
end;
if ~finite(lim(1)) || numel(str)>=lim(1),
    set(sib(ob,'D'),'Enable','on');
else
    set(sib(ob,'D'),'Enable','off');
end;
set(sib(ob,'selected'),'String',strvcat(str),'Value',[]);
delete(ob);
%=======================================================================

%=======================================================================
function editclear(ob,varargin)
ob = get(ob,'Parent');
ob = get(ob,'Parent');
ob = findobj(ob,'Tag','EditWindow');
delete(ob);
%=======================================================================

%=======================================================================
function [c1,c2,c3,fs] = colours
global defaults
c1 = [1 1 1];
c2 = [1 1 1];
c3 = [0 0 0];
fs = 14;
if isfield(defaults,'ui'),
    ui = defaults.ui;
    if isfield(ui,'colour1'), c1 = ui.colour1; end;
    if isfield(ui,'colour2'), c2 = ui.colour2; end;
    if isfield(ui,'colour3'), c3 = ui.colour3; end;
    if isfield(ui,'fs'),      fs = ui.fs;      end;
end;
%=======================================================================

%=======================================================================
function select_rec(ob, varargin)
sel   = [];
top   = get(ob,'Parent');
start = get(findobj(top,'Tag','edit'),'String');
filt  = get(findobj(top,'Tag','regexp'),'Userdata');
filt.filt = {get(findobj(top,'Tag','regexp'), 'String')};
fob = findobj(top,'Tag','frame');
if ~isempty(fob)
    filt.frames = get(fob,'Userdata');
else
    filt.frames = [];
end;
ptr    = get(top,'Pointer');
try,
    set(top,'Pointer','watch');
    sel    = select_rec1(start,filt);
catch,
    set(top,'Pointer',ptr);
    sel = '';
end;
set(top,'Pointer',ptr);
already= get(findobj(top,'Tag','selected'),'String');
fb     = sib(ob,'files');
lim    = get(fb,'Userdata');
limsel = min(lim(2)-size(already,1),size(sel,1));
set(findobj(top,'Tag','selected'),'String',strvcat(already,sel(1:limsel,:)),'Value',[]);
msg(ob,sprintf('Added %d/%d matching files to selection.', limsel, size(sel,1)));
if ~finite(lim(1)) || size(sel,1)>=lim(1),
    set(sib(ob,'D'),'Enable','on');
else
    set(sib(ob,'D'),'Enable','off');
end;
%=======================================================================

%=======================================================================
function sel=select_rec1(cdir,filt)
sel='';
[t,d] = listfiles(cdir,filt);
if ~isempty(t)
    sel = [repmat([cdir,filesep],size(t,1),1),t];
end;
for k = 1:size(d,1)
    if ~strcmp(deblank(d(k,:)),'.') && ~strcmp(deblank(d(k,:)),'..')
        sel1 = select_rec1(fullfile(cdir,deblank(d(k,:))),filt);
        if ~isempty(sel1) && ~isempty(sel),
            sel  = strvcat(sel, sel1);
        elseif ~isempty(sel1),
            sel = sel1;
        end;
    end;
end;
%=======================================================================

%=======================================================================
function sfilt=mk_filter(typ,filt,frames)
if nargin<3, frames  = '1';     end;
if nargin<2, filt    = '.*';    end;
if nargin<1, typ     = 'any';   end;
switch lower(typ),
case {'any','*'}, code = 0; ext = {'.*'};
case {'image'},   code = 1; ext = {'.*\.nii$','.*\.img$','.*\.NII$','.*\.IMG$'};
case {'nifti'},   code = 0; ext = {'.*\.nii$','.*\.img$','.*\.NII$','.*\.IMG$'};
case {'extimage'},   code = 1; ext = {'.*\.nii(,[0-9]*){0,1}$',...
                            '.*\.img(,[0-9]*){0,1}$',...
                            '.*\.NII(,[0-9]*){0,1}$',...
                            '.*\.IMG(,[0-9]*){0,1}$'};
case {'xml'},     code = 0; ext = {'.*\.xml$','.*\.XML$'};
case {'mat'},     code = 0; ext = {'.*\.mat$','.*\.MAT$'};
case {'batch'},   code = 0; ext = {'.*\.mat$','.*\.MAT$','.*\.m$','.*\.M$','.*\.xml$','.*\.XML$'};
case {'dir'},     code =-1; ext = {'.*'};
case {'extdir'},     code =-1; ext = {['.*' filesep '$']};
otherwise,        code = 0; ext = {typ};
end;
sfilt = struct('code',code,'frames',frames,'ext',{ext},...
                             'filt',{{filt}});
%=======================================================================

%=======================================================================


function [status, fieldsUsed] = spm_matlab_version_chk(chk,tbx)
% SPM_MATLAB_VERSION_CHK Check a version number against a Toolbox version.
%    FORMAT [STATUS FIELDSUSED] = SPM_MATLAB_VERSION(CHK,TBX)
%
%    This function checks if a user supplied version number is less than, 
%    equal to or greater than the version number of specified toolbox. If no
%    toolbox is specified the function checks the version of Matlab. User
%    defined toolboxes can be checked but the Contents.m file must conform
%    to the specification defined in ver.m
%
%    This function assumes that the version number is really a text string
%    with fields major.minor.revision.build. Other formats are not supported.
%    Checking is done to the level specified by the input version. Thus an
%    input of '7' will be rated as the same version as 7.1, but 7.0 would be
%    rated as earlier than 7.1.
%
%    INPUTS
%       chk         Version number to be checked [string].
%       tbx         Name of toolbox to check. Defaults to 'Matlab'.
%
%    OUPUTS
%       This is based on the fields the user supplies in the input.
%
%       status      Defines the outcome of the comparison
%            -1       Toolbox version is earlier than the user supplied version.
%             0       Toolbox and user versions are the same
%             1       Toolbox version is later than the user supplied version.
%                   Think of it this way, the sign of status is determined by
%                   MATLAB_TOOLBOX_VERSION - USER_VERSION (i.e., THE VERSION YOU
%                   INPUT).
%       fieldsUsed  Returns the version fields that were actually compared.
%
%    EXAMPLES
%       If the Matlab version is 7.1.0.83, and the user supplied version is '7':
%       status = spm_matlab_version_chk('7');
%       returns status == 0   : major revision numbers are the same.
%
%       If the Matlab version is 7.1.0.0, and the user supplied version is '7.1':
%       status = spm_matlab_version_chk('7');
%       returns status == 0   : major and minor revision numbers are the same.
%
%       If the Matlab version is 7.1.0.83, and the user supplied version is '7.2':
%       status = spm_matlab_version_chk('7.2');
%       returns status == -1   : major + minor revision is earlier for Matlab.
%
%       If the Matlab version is 6.5.1, and the user supplied version is '6.5.0'.
%       status = spm_matlab_version_chk('6.5.0');
%       returns status == 1     : major + minor + release revision is later
%                                 for matlab
%       The statement ( spm_matlab_version_chk('6.5.0') > 0 ) is true for
%       all Matlab Toolbox versions after 6.5.0.
%
%    See also  VERSION, VER.

%__________________________________________________________________________
% Copyright (C) 2006 Wellcome Department of Imaging Neuroscience
%
% Darren Gitelman
% $Id: spm_matlab_version_chk.m 539 2006-05-19 17:59:30Z Darren $

% output variable
%--------------------------------------------------------------------------
status = [];
fieldsUsed = [];

%  Check inputs
%--------------------------------------------------------------------------
% If no inputs then error; if 1 then set tbx to Matlab
%-------------------------------------------------------
switch nargin
    case 0
        error('Please provide a version number to be checked.');
    case 1
        tbx = 'Matlab';
end

% If a number is supplied then convert to text
%-------------------------------------------------------
if isnumeric(chk)
    chk = num2str(chk);
end

% If too many fields in input then error
%-------------------------------------------------------
if numel(findstr(chk,'.')) > 3
    error('Input string has too many fields. Only major.minor.release.build fields are supported.');
end

% parse the input string into a cell array of strings
%--------------------------------------------------------------------------
try
    vCHK           = textscan(chk,'%s %s %s %s','delimiter','.');
catch
    % version 6.5 does not have textscan function.
    % This code will be deprecated eventually.
    [ vCHK{1:4} ]  = strread(chk,'%s %s %s %s','delimiter','.');
end

% find empty cells. These will be set to 0 in both cell arrays so that the
% same revision fields are compared
%--------------------------------------------------------------------------
emptyCHK = cellfun('isempty',vCHK);

% Get the requested toolbox version
%--------------------------------------------------------------------------
if strcmpi(tbx,'Matlab')
    % Matlab is a special case. The ver command does not report the
    % entire version string.
    [ tbxVer tmp ] = strtok(version);
else
    tbxStruct = ver(tbx);
    if numel(tbxStruct) >1
        error('Too many toolboxes found for given toolbox name.')
    end
    tbxVer = tbxStruct.Version;
end

% parse the requested toolbox version string into a cell array of strings.
%--------------------------------------------------------------------------
try
    vTBX           = textscan(tbxVer,'%s %s %s %s','delimiter','.');
catch
    % This code will be deprecated eventually.
    [ vTBX{1:4} ]  = strread(tbxVer,'%s %s %s %s','delimiter','.');
end

% find empty cells. These will be removed from the cell array so that the
% same revision fields are compared
%--------------------------------------------------------------------------
emptyTBX = cellfun('isempty',vTBX);


% combine empty cell indices. notEmptyCells tell us which version
% fields are compared.
%--------------------------------------------------------------------------
emptyCellLogical = emptyCHK | emptyTBX;
emptyCells       = find(emptyCellLogical);
notEmptyCells    = find(~emptyCellLogical);

% and remove them. 
%--------------------------------------------------------------------------
 vCHK(emptyCells) = [];
 vTBX(emptyCells) = [];
 
 
% final version fields to compare are converted to numbers
%--------------------------------------------------------------------------
vCHKMat = str2num(strvcat([vCHK{:}]))';
vTBXMat = str2num(strvcat([vTBX{:}]))';


% compare versions
%--------------------------------------------------------------------------
% This array will be used to decide which version is the later one. The
% differences between versions are computed on each element of the version
% number: major.minor.release.build and then multiplied by the base2array
% and summed. This is equivalent to logically combining the base 2 place
% values and ensures that the fields are evaluated by their significance.
% The sign of the summed values gives the result. Positive values mean the
% toolbox version is later, negative values mean the user supplied version,
% is later, and 0 means they are equal.
%--------------------------------------------------------------------------
base2array             = [8 4 2 1];
base2array(emptyCells) = [];

% take the difference between version elements.
%--------------------------------------------------------------------------
vDiff = vTBXMat - vCHKMat;

% get the sign of the differences
%--------------------------------------------------------------------------
signDiff = sign(vDiff);

% multiply by the base2array
%--------------------------------------------------------------------------
vVal = signDiff.*base2array;

% If the sign of the sum is positive then toolbox version is later; if 0
% they are the same, and if negative the user supplied version is later.
% Think of it this way: MATLAB_TOOLBOX_VERSION - USER_VERSION.
% Remember the comparison is made with respect to the FIELDS SUPPLED IN THE
% INPUT
%--------------------------------------------------------------------------
switch sign(sum(vVal))
    case -1     % MATLB_TOOLBOX_VERSION is EARLIER than USER_VERSION
        status = -1;
    case 0      % MATLB_TOOLBOX_VERSION = EQUALS = USER_VERSION
        status =  0;
    case 1      % MATLB_TOOLBOX_VERSION is LATER than USER_VERSION
        status =  1;
end

% also return the fields that were compared.
%--------------------------------------------------------------------------
fieldsUsed             = {'major','minor','revision','build'}';
fieldsUsed(emptyCells) = [];
return

%=======================================================================

%=======================================================================
%=======================================================================

%=======================================================================

function varargout=spm_platform(varargin)
% Platform specific configuration parameters for SPM
%
% FORMAT ans = spm_platform(arg)
% arg  - optional string argument, can be
%        - 'bigend'  - return whether this architecture is bigendian
%                      - Inf - is not IEEE floating point
%                      - 0   - is little end
%                      - 1   - big end
%        - 'filesys' - type of filesystem
%                      - 'unx' - UNIX
%                      - 'win' - DOS
%                      - 'mac' - Macintosh
%                      - 'vms' - VMS
%        - 'sepchar' - returns directory separator
%        - 'rootlen' - returns number of chars in root directory name
%        - 'user'    - returns username
%        - 'tempdir' - returns name of temp directory
%        - 'drives'  - returns string containing valid drive letters
%
% FORMAT PlatFontNames = spm_platform('fonts')
% Returns structure with fields named after the generic (UNIX) fonts, the
% field containing the name of the platform specific font.
%
% FORMAT PlatFontName = spm_platform('font',GenFontName)
% Maps generic (UNIX) FontNames to platform specific FontNames
%
% FORMAT PLATFORM = spm_platform('init',comp)
% Initialises platform specific parameters in persistent PLATFORM
% (External gateway to init_platform(comp) subfunction)
% comp         - computer to use [defaults to MatLab's `computer`]
% PLATFORM - copy of persistent PLATFORM
%
% FORMAT spm_platform
% Initialises platform specific parameters in persistent PLATFORM
% (External gateway to init_platform(computer) subfunction)
%
%                           ----------------
% SUBFUNCTIONS:
%
% FORMAT init_platform(comp)
% Initialise platform specific parameters in persistent PLATFORM
% comp         - computer to use [defaults to MatLab's `computer`]
%
%-----------------------------------------------------------------------
%
% Since calls to spm_platform will be made frequently, most platform
% specific parameters are stored as a structure in the persistent variable
% PLATFORM. Subsequent calls use the information from this persistent
% variable, if it exists.
%
% Platform specific difinitions are contained in the data structures at
% the beginning of the init_platform subfunction at the end of this
% file.
%_______________________________________________________________________
% Copyright (C) 2005 Wellcome Department of Imaging Neuroscience

% Matthew Brett
% $Id: spm_platform.m 651 2006-10-17 10:32:23Z john $



%-Initialise
%-----------------------------------------------------------------------
persistent PLATFORM
if isempty(PLATFORM), PLATFORM = init_platform; end

if nargin==0, return, end


switch lower(varargin{1}), case 'init'                  %-(re)initialise
%=======================================================================
init_platform(varargin{2:end})
varargout = {PLATFORM};
   
case 'bigend'                      %-Return endian for this architecture
%=======================================================================
varargout = {PLATFORM.bigend};
if ~finite(PLATFORM.bigend),
	if isnan(PLATFORM.bigend)
		error(['I don''t know if "',computer,'" is big-endian.'])
	else
		error(['I don''t think that "',computer,...
			'" uses IEEE floating point ops.'])
	end
end

case 'filesys'                                      %-Return file system
%=======================================================================
varargout = {PLATFORM.filesys};

case 'sepchar'                         %-Return file separator character
%=======================================================================
warning('use filesep instead (supported by MathWorks)')
varargout = {PLATFORM.sepchar};

case 'rootlen'           %-Return length in chars of root directory name 
%=======================================================================
varargout = {PLATFORM.rootlen};

case 'user'                                         %-Return user string
%=======================================================================
varargout = {PLATFORM.user};

case 'drives'                                            %-Return drives
%=======================================================================
varargout = {PLATFORM.drives};

case 'tempdir'                              %-Return temporary directory
%=======================================================================
twd = getenv('SPMTMP');
if isempty(twd)
	twd = tempdir;
end 
varargout = {twd};


case {'font','fonts'}    %-Map default font names to platform font names
%=======================================================================
if nargin<2, varargout={PLATFORM.font}; return, end
switch lower(varargin{2})
case 'times'
	varargout = {PLATFORM.font.times};
case 'courier'
	varargout = {PLATFORM.font.courier};
case 'helvetica'
	varargout = {PLATFORM.font.helvetica};
case 'symbol'
	varargout = {PLATFORM.font.symbol};
otherwise
	warning(['Unknown font ',varargin{2},', using default'])
	varargout = {PLATFORM.font.helvetica};
end

otherwise                                        %-Unknown Action string
%=======================================================================
error('Unknown Action string')

%=======================================================================
end



%=======================================================================
%- S U B - F U N C T I O N S
%=======================================================================


function PLATFORM = init_platform(comp)             %-Initialise platform variables
%=======================================================================
if nargin<1, comp=computer; end

%-Platform definitions
%-----------------------------------------------------------------------
PDefs = {	'PCWIN',	'win',	0;...
		'PCWIN64',	'win',  0;...
		'MAC',		'unx',	1;...
		'MACI',		'unx',	0;...
		'SUN4',		'unx',	1;...
		'SOL2',		'unx',	1;...
		'HP700',	'unx',	1;...
		'SGI',		'unx',	1;...
		'SGI64',	'unx',	1;...
		'IBM_RS',	'unx',	1;...
		'ALPHA',	'unx',	0;...
		'AXP_VMSG',	'vms',	Inf;...
		'AXP_VMSIEEE',	'vms',	0;...
		'LNX86',	'unx',	0;...
		'GLNX86',	'unx',  0;...
		'GLNXA64',      'unx',  0;...
		'VAX_VMSG',	'vms',	Inf;...
		'VAX_VMSD',	'vms',	Inf	};

PDefs = cell2struct(PDefs,{'computer','filesys','endian'},2);


%-Which computer?
%-----------------------------------------------------------------------
ci = find(strcmp({PDefs.computer},comp));
if isempty(ci), error([comp,' not supported architecture for SPM']), end


%-Set bigend
%-----------------------------------------------------------------------
PLATFORM.bigend = PDefs(ci).endian;


%-Set filesys
%-----------------------------------------------------------------------
PLATFORM.filesys = PDefs(ci).filesys;


%-Set filesystem dependent stuff
%-----------------------------------------------------------------------
%-File separators character
%-Length of root directory strings
%-User name finding
%-(mouse button labels?)
switch (PLATFORM.filesys)
case 'unx'
	PLATFORM.sepchar = '/';
	PLATFORM.rootlen = 1;
	PLATFORM.user    = getenv('USER');
case 'win'
	PLATFORM.sepchar = '\';
	PLATFORM.rootlen = 3;
	PLATFORM.user    = getenv('USERNAME');
	if isempty(PLATFORM.user)
		PLATFORM.user = 'anon';
	end
otherwise
	error(['Don''t know filesystem ',PLATFORM.filesys])
end

%-Drives
%-----------------------------------------------------------------------
PLATFORM.drives = '';
if strcmp(comp,'PCWIN') || strcmp(comp,'PCWIN64'),
    driveLett = cellstr(char(('C':'Z')'));
    for i=1:numel(driveLett),
        if exist([driveLett{i} ':\']) == 7,
            PLATFORM.drives = [PLATFORM.drives driveLett{i}];
        end
    end
end

%-Fonts
%-----------------------------------------------------------------------
switch comp
case {'SOL2'}	%-Some Sol2 platforms give segmentation violations with Helvetica
	PLATFORM.font.helvetica = 'Lucida';
	PLATFORM.font.times     = 'Times';
	PLATFORM.font.courier   = 'Courier';
	PLATFORM.font.symbol    = 'Symbol';
case {'SUN4','SOL2','HP700','SGI','SGI64','IBM_RS','ALPHA','LNX86','GLNX86','GLNXA64','MAC','MACI'}
	PLATFORM.font.helvetica = 'Helvetica';
	PLATFORM.font.times     = 'Times';
	PLATFORM.font.courier   = 'Courier';
	PLATFORM.font.symbol    = 'Symbol';
case {'PCWIN','PCWIN64'}
	PLATFORM.font.helvetica = 'Arial Narrow';
	PLATFORM.font.times     = 'Times New Roman';
	PLATFORM.font.courier   = 'Courier New';
	PLATFORM.font.symbol    = 'Symbol';
end
%=======================================================================

%=======================================================================





