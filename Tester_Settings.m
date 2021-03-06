function varargout = Tester_Settings(varargin)
%TESTER_SETTINGS M-file for Tester_Settings.fig
%      TESTER_SETTINGS, by itself, creates a new TESTER_SETTINGS or raises the existing
%      singleton*.
%
%      H = TESTER_SETTINGS returns the handle to a new TESTER_SETTINGS or the handle to
%      the existing singleton*.
%
%      TESTER_SETTINGS('Property','Value',...) creates a new TESTER_SETTINGS using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to Tester_Settings_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      TESTER_SETTINGS('CALLBACK') and TESTER_SETTINGS('CALLBACK',hObject,...) call the
%      local function named CALLBACK in TESTER_SETTINGS.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Tester_Settings

% Last Modified by GUIDE v2.5 31-Jan-2017 15:02:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Tester_Settings_OpeningFcn, ...
                   'gui_OutputFcn',  @Tester_Settings_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before Tester_Settings is made visible.
function Tester_Settings_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)
global testerfreq cyclesperimage minimumpeakheight triggerPhase triggerDelay

% Choose default command line output for Tester_Settings
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
set(handles.testerfreq,'String',num2str(testerfreq,'%.2f'));
set(handles.cyclesperimage,'String',cyclesperimage);
set(handles.minimumpeakheight,'String',num2str(minimumpeakheight,'%.2f'));
set(handles.triggerphase,'String',num2str(rad2deg(triggerPhase),'%.0f'));
set(handles.triggerdelay,'String',num2str(triggerDelay,'%.3f'));

% --- Outputs from this function are returned to the command line.
function varargout = Tester_Settings_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
% Set default object focus
uicontrol(handles.testerfreq);


function testerfreq_Callback(hObject, eventdata, handles)
% hObject    handle to testerfreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of testerfreq as text
%        str2double(get(hObject,'String')) returns contents of testerfreq as a double

% --- Executes during object creation, after setting all properties.
function testerfreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to testerfreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function cyclesperimage_Callback(hObject, eventdata, handles)
% hObject    handle to cyclesperimage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cyclesperimage as text
%        str2double(get(hObject,'String')) returns contents of cyclesperimage as a double


% --- Executes during object creation, after setting all properties.
function cyclesperimage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cyclesperimage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



%function DAQsamplerate_Callback(hObject, eventdata, handles)
% hObject    handle to DAQsamplerate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DAQsamplerate as text
%        str2double(get(hObject,'String')) returns contents of DAQsamplerate as a double


% --- Executes during object creation, after setting all properties.
%function DAQsamplerate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DAQsamplerate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    %set(hObject,'BackgroundColor','white');
%end



function minimumpeakheight_Callback(hObject, eventdata, handles)
% hObject    handle to minimumpeakheight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minimumpeakheight as text
%        str2double(get(hObject,'String')) returns contents of minimumpeakheight as a double


% --- Executes during object creation, after setting all properties.
function minimumpeakheight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minimumpeakheight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in btn_OK.
function btn_OK_Callback(hObject, eventdata, handles)
% hObject    handle to btn_OK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global testerfreq cyclesperimage minimumpeakheight triggerPhase triggerDelay

testerfreq = str2num(get(handles.testerfreq, 'String'));
cyclesperimage = str2num(get(handles.cyclesperimage, 'String'));
%DAQsamplerate = str2num(get(handles.DAQsamplerate, 'String'));
minimumpeakheight = str2num(get(handles.minimumpeakheight, 'String'));
triggerPhase = deg2rad(str2num(get(handles.triggerphase, 'String')));
triggerDelay = str2num(get(handles.triggerdelay, 'String'));

close();



function triggerphase_Callback(hObject, eventdata, handles)
% hObject    handle to triggerphase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of triggerphase as text
%        str2double(get(hObject,'String')) returns contents of triggerphase as a double


% --- Executes during object creation, after setting all properties.
function triggerphase_CreateFcn(hObject, eventdata, handles)
% hObject    handle to triggerphase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in maxButton.
function maxButton_Callback(hObject, eventdata, handles)
% hObject    handle to maxButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.triggerphase,'String','90');

% --- Executes on button press in minButton.
function minButton_Callback(hObject, eventdata, handles)
% hObject    handle to minButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.triggerphase,'String','270');



function triggerdelay_Callback(hObject, eventdata, handles)
% hObject    handle to triggerdelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of triggerdelay as text
%        str2double(get(hObject,'String')) returns contents of triggerdelay as a double


% --- Executes during object creation, after setting all properties.
function triggerdelay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to triggerdelay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function angleInRadians = deg2rad(angleInDegrees)
% DEG2RAD Convert angles from degrees to radians.
%   DEG2RAD(X) converts angle units from degrees to radians for each
%   element of X.
%
%   See also RAD2DEG.

% Copyright 2015 The MathWorks, Inc.

if isfloat(angleInDegrees)
    angleInRadians = (pi/180) * angleInDegrees;
else
    error(message('MATLAB:deg2rad:nonFloatInput'))
end

function angleInDegrees = rad2deg(angleInRadians)
% RAD2DEG Convert angles from radians to degrees.
%   RAD2DEG(X) converts angle units from radians to degrees for each
%   element of X.
%
%   See also DEG2RAD.

% Copyright 2015 The MathWorks, Inc.

if isfloat(angleInRadians)
    angleInDegrees = (180/pi) * angleInRadians;
else
    error(message('MATLAB:rad2deg:nonFloatInput'))
end