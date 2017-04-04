function varargout = Calibration(varargin)
% CALIBRATION MATLAB code for Calibration.fig
%      CALIBRATION, by itself, creates a new CALIBRATION or raises the existing
%      singleton*.
%
%      H = CALIBRATION returns the handle to a new CALIBRATION or the handle to
%      the existing singleton*.
%
%      CALIBRATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CALIBRATION.M with the given input arguments.
%
%      CALIBRATION('Property','Value',...) creates a new CALIBRATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Calibration_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Calibration_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Calibration

% Last Modified by GUIDE v2.5 28-Mar-2017 17:15:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Calibration_OpeningFcn, ...
                   'gui_OutputFcn',  @Calibration_OutputFcn, ...
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


% --- Executes just before Calibration is made visible.
function Calibration_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Calibration (see VARARGIN)
global dist pix2mm temp_pix2mm

% Default pix2mm in case it is []

% Choose default command line output for Calibration
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

temp_pix2mm = pix2mm;
if isequal(pix2mm,[])
    return
else
    set(handles.edt_mm, 'String',num2str(dist/str2num(pix2mm),'%.2f'));
    set(handles.edt_Pixelxmm,'String', num2str(str2num(pix2mm), '%.2f'));
end

% UIWAIT makes Calibration wait for user response (see UIRESUME)
% uiwait(handles.fg_Calibration);


% --- Outputs from this function are returned to the command line.
function varargout = Calibration_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
% Set default object focus
uicontrol(handles.edt_mm);



function edt_mm_Callback(hObject, eventdata, handles)
% hObject    handle to edt_mm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edt_mm as text
%        str2double(get(hObject,'String')) returns contents of edt_mm as a double
global dist temp_pix2mm %pix2mm

Vstr = get(handles.edt_mm, 'String');
if (~isempty(Vstr))
    set(handles.edt_Pixelxmm,'String', num2str(dist/str2double(Vstr), '%.2f'));
    temp_pix2mm = num2str(dist/str2double(Vstr));
else
    set(handles.edt_Pixelxmm,'String', '');
    temp_pix2mm = [];
end

% --- Executes during object creation, after setting all properties.
function edt_mm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edt_mm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edt_Pixelxmm_Callback(hObject, eventdata, handles)
% hObject    handle to edt_Pixelxmm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edt_Pixelxmm as text
%        str2double(get(hObject,'String')) returns contents of edt_Pixelxmm as a double
global dist temp_pix2mm %pix2mm

temp_pix2mm = get(handles.edt_Pixelxmm, 'String');
if (~isempty(temp_pix2mm))
    set(handles.edt_mm,'String', num2str(dist/str2double(temp_pix2mm), '%.2f'));
else
    set(handles.edt_mm,'String', '');
    temp_pix2mm = [];
end


% --- Executes during object creation, after setting all properties.
function edt_Pixelxmm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edt_Pixelxmm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_Close.
function btn_Close_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close();


% --- Executes on button press in btn_OK.
function btn_OK_Callback(hObject, eventdata, handles)
% hObject    handle to btn_OK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global pix2mm temp_pix2mm

%Vstr = get(handles.edt_mm, 'String');
%set(handles.edt_Pixelxmm,'String', num2str(dist/str2num(Vstr), '%.2f'));
%pix2mm = num2str(dist/str2num(Vstr));
if (~isempty(temp_pix2mm))
    pix2mm = temp_pix2mm;
end
close();


% --- Executes on key press with focus on edt_mm and none of its controls.
function edt_mm_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to edt_mm (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
if (~strcmp(eventdata.Key, 'return'))
    import java.awt.Robot; import java.awt.event.*; SimKey=Robot; SimKey.keyPress(java.awt.event.KeyEvent.VK_ENTER); SimKey.keyRelease(java.awt.event.KeyEvent.VK_ENTER);
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over edt_mm.
function edt_mm_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to edt_mm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over edt_Pixelxmm.
function edt_Pixelxmm_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to edt_Pixelxmm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on edt_Pixelxmm and none of its controls.
function edt_Pixelxmm_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to edt_Pixelxmm (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
if (~strcmp(eventdata.Key, 'return'))
    import java.awt.Robot; import java.awt.event.*; SimKey=Robot; SimKey.keyPress(java.awt.event.KeyEvent.VK_ENTER); SimKey.keyRelease(java.awt.event.KeyEvent.VK_ENTER);
end