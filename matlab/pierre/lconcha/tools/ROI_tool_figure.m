function varargout = WL_tool_figure(varargin)
% ROI_TOOL_FIGURE Application M-file for WL_tool_figure.fig
%    FIG = ROI_TOOL_FIGURE launch WL_tool_figure GUI.
%    ROI_TOOL_FIGURE('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.5 10-May-2003 15:41:49

if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);

	if nargout > 0
		varargout{1} = fig;
	end

elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

	try
		[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
	catch
		disp(lasterr);
	end

end


%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and 
%| sets objects' callback properties to call them through the FEVAL 
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the 
%| callback type separated by '_', e.g. 'slider2_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.slider2. This
%| structure is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
%| is passed to each callback.  You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the inspector. By default, GUIDE sets the property to:
%| <MFILENAME>('<SUBFUNCTION_NAME>', gcbo, ROI_tool_figure, guidata(gcbo))
%| Add any extra arguments after the last argument, before the final
%| closing parenthesis.



% --------------------------------------------------------------------
function varargout = edit6_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.edit6.
disp('edit6 Callback not implemented yet.')


% --------------------------------------------------------------------
function varargout = edit7_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.edit7.
disp('edit7 Callback not implemented yet.')


% --------------------------------------------------------------------
function varargout = edit8_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.edit8.
disp('edit8 Callback not implemented yet.')


% --------------------------------------------------------------------
function varargout = edit9_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.edit9.
disp('edit9 Callback not implemented yet.')


% --------------------------------------------------------------------
function varargout = Clear_ROI_popupmenu_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.Clear_ROI_popupmenu.
disp('Clear_ROI_popupmenu Callback not implemented yet.')


% --------------------------------------------------------------------
function varargout = radiobutton11_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.radiobutton11.
disp('radiobutton11 Callback not implemented yet.')


% --- Executes during object creation, after setting all properties.
function Create_ROI_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Create_ROI_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in Create_ROI_popupmenu.
function Create_ROI_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to Create_ROI_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Create_ROI_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Create_ROI_popupmenu


