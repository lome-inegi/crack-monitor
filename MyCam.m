function varargout = MyCam(varargin)
% MYCAM MATLAB code for MyCam.fig
%      MYCAM, by itself, creates a new MYCAM or raises the existing
%      singleton*.
%
%      H = MYCAM returns the handle to a new MYCAM or the handle to
%      the existing singleton*.
%
%      MYCAM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MYCAM.M with the given input arguments.
%
%      MYCAM('Property','Value',...) creates a new MYCAM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MyCam_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MyCam_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MyCam

% Last Modified by GUIDE v2.5 05-Apr-2013 12:14:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MyCam_OpeningFcn, ...
                   'gui_OutputFcn',  @MyCam_OutputFcn, ...
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


% --- Executes just before MyCam is made visible.
function MyCam_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MyCam (see VARARGIN)

% Choose default command line output for MyCam
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
global imaqhw adapt devinfo numdev format
imaqhw=imaqhwinfo;

% 'WinVideo' adaptor has to come in front, otherwise MyCam crashes
if strcmp(imaqhw.InstalledAdaptors(1),'matrox')
    imaqhw.InstalledAdaptors=circshift(imaqhw.InstalledAdaptors,[0 1]);
end
set(handles.adaptors,'String',imaqhw.InstalledAdaptors);
adap=get(handles.adaptors,'String');
adapt= adap(get(handles.adaptors,'Value'));
devinfo=imaqhwinfo(char(adapt));
numdev=length(devinfo.DeviceIDs);
if numdev ~= 0
    for i=1:numdev
        devname(i).name=devinfo.DeviceInfo(i).DeviceName;
    end    
else 
    return
end

set(handles.devices,'String',devname(1).name);
devid=get(handles.devices,'Value');
set(handles.formats,'String',devinfo.DeviceInfo(devid).SupportedFormats);

set(handles.btn_StartPreview,'Enable','off');
set(handles.btn_StopPreview,'Enable','off');
set(handles.btn_SelectROI,'Enable','off');
set(handles.btn_ResetROI,'Enable','off');
set(handles.chkbx_AutoFocus,'Enable','off');
set(handles.txt_Focus,'Enable','off');
set(handles.edt_Focus,'Enable','off');
set(handles.sld_Focus,'Enable','off');
set(handles.chkbx_AutoGain,'Enable','off');
set(handles.txt_Gain,'Enable','off');
set(handles.edt_Gain,'Enable','off');
set(handles.sld_Gain,'Enable','off');
set(handles.chkbx_AutoExposure,'Enable','off');
set(handles.txt_Exposure,'Enable','off');
set(handles.edt_Exposure,'Enable','off');
set(handles.sld_Exposure,'Enable','off');
set(handles.chkbx_AutoContrast,'Enable','off');
set(handles.txt_Contrast,'Enable','off');
set(handles.edt_Contrast,'Enable','off');
set(handles.sld_Contrast,'Enable','off');
set(handles.txt_Brightness,'Enable','off');
set(handles.edt_Brightness,'Enable','off');
set(handles.sld_Brightness,'Enable','off');
set(handles.chkbx_Backlight,'Enable','off');
set(handles.chkbx_HFlip,'Enable','off');
set(handles.chkbx_VFlip,'Enable','off');
set(handles.btn_CamDefaults,'Enable','off');
set(handles.txt_ROIZoom,'Enable','off');
set(handles.edt_ROIZoom,'Enable','off');

% This will only be reached if there is a device
format=char(devinfo.DeviceInfo(1).SupportedFormats(1));
set(handles.btn_StartPreview,'Enable','on');




% --- Outputs from this function are returned to the command line.
function varargout = MyCam_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in adaptors.
function adaptors_Callback(hObject, eventdata, handles)
% hObject    handle to adaptors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns adaptors contents as cell array
%        contents{get(hObject,'Value')} returns selected item from adaptors

global imaqhwadapt devinfo adapt
adap=get(handles.adaptors,'String');
adapt= adap(get(handles.adaptors,'Value'));
devinfo=imaqhwinfo(char(adapt));
numdev=length(devinfo.DeviceIDs);
% dev = '';
if numdev ~= 0
    for i=1:numdev
        devname(i).name= devinfo.DeviceInfo(i).DeviceName;
    end
    set(handles.devices,'String', {devname(:).name});
    else if numdev==0;
     set(handles.devices,'String',' ' );
     set(handles.formats,'String',' ');
    end
end

% --- Executes during object creation, after setting all properties.
function adaptors_CreateFcn(hObject, eventdata, handles)
% hObject    handle to adaptors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in devices.
function devices_Callback(hObject, eventdata, handles)
% hObject    handle to devices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global devinfo devid vid
if (isempty(devinfo.DeviceInfo))
   return; 
end
devid=get(handles.devices,'Value');
set(handles.formats,'String',devinfo.DeviceInfo(devid).SupportedFormats);


% Hints: contents = cellstr(get(hObject,'String')) returns devices contents as cell array
%        contents{get(hObject,'Value')} returns selected item from devices


% --- Executes during object creation, after setting all properties.
function devices_CreateFcn(hObject, eventdata, handles)
% hObject    handle to devices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global devid

% default devid
devid=1;

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in formats.
function formats_Callback(hObject, eventdata, handles)
% hObject    handle to formats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns formats contents as cell array
%        contents{get(hObject,'Value')} returns selected item from formats
global devinfo devid format
if(isempty(devinfo.DeviceInfo))
   return; 
end
format=char(devinfo.DeviceInfo(devid).SupportedFormats(get(handles.formats,'Value')));
set(handles.btn_StartPreview,'Enable','on');

% --- Executes during object creation, after setting all properties.
function formats_CreateFcn(hObject, eventdata, handles)
% hObject    handle to formats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_StartPreview.
function btn_StartPreview_Callback(hObject, eventdata, handles)
% hObject    handle to btn_StartPreview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global vid devid devinfo adapt src format sourcedefaults

delete(vid);
vid = videoinput(char(adapt),devid,format);   
vid.ReturnedColorspace = 'grayscale';
src = getselectedsource(vid);

% Structure to keep "default" camera settings. It can be used to reset the camera.

sourcedefaults = get(src);

vidRes = get(vid, 'VideoResolution'); 
% handles.axes1.Position(3) = vidRes(1);
% handles.axes1.Position(4) = vidRes(2);
nBands = get(vid, 'NumberOfBands'); 
% hImg = image(zeros(vidRes(2),vidRes(1), nBands),'Parent',handles.axes1,'ButtonDownFcn',@startDragFcn);
hImg = image(zeros(vidRes(2),vidRes(1), nBands),'Parent',handles.axes1);
% set(handles.axes1,'DataAspectRatioMode', 'auto','PlotBoxAspectRatioMode', 'auto','CameraViewAngleMode', 'auto');
axis equal;
preview(vid,hImg);
set(handles.btn_StopPreview,'Enable','on');



% --- Populate uicontrols ---
% ZOOM and ROI
try
    src.zoom = 1;
catch
% 	h = warndlg(sprintf('This camera model does not support zooming! \n ROI Selection can''t be enabled but Image ROI can.'));
%     uiwait(h)
end

set(handles.btn_SelectROI,'Enable','on');

% EXPOSURE
a=propinfo(src,'Exposure');
min=a.ConstraintValue(1);
max=a.ConstraintValue(2);
set(handles.sld_Exposure,'Min',min, ...
                         'Max',max, ...
                         'SliderStep',[1/(max-min) 10/(max-min)], ...
                         'Value',a.DefaultValue);
set(handles.edt_Exposure,'Value',a.DefaultValue, ...
                         'String',num2str(a.DefaultValue));
set(handles.txt_Exposure,'Enable','on');
set(handles.edt_Exposure,'Enable','on');
set(handles.sld_Exposure,'Enable','on');
try
    src.ExposureMode='auto';
    set(handles.chkbx_AutoExposure,'Enable','on', ...
                                   'Value',1);
catch
    set(handles.chkbx_AutoExposure,'Enable','off');
end

% GAIN
a=propinfo(src,'Gain');
min=a.ConstraintValue(1);
max=a.ConstraintValue(2);
set(handles.sld_Gain,'Min',min, ...
                     'Max',max, ...
                     'SliderStep',[1/(max-min) 10/(max-min)], ...
                     'Value',a.DefaultValue);
set(handles.edt_Gain,'Value',a.DefaultValue, ...
                     'String',num2str(a.DefaultValue));
set(handles.txt_Gain,'Enable','on');
set(handles.edt_Gain,'Enable','on');
set(handles.sld_Gain,'Enable','on');
try
    src.GainMode='auto';
    set(handles.chkbx_AutoGain,'Enable','on', ...
                                   'Value',1);
catch
    set(handles.chkbx_AutoGain,'Enable','off');
end

% CONTRAST
a=propinfo(src,'Contrast');
min=a.ConstraintValue(1);
max=a.ConstraintValue(2);
set(handles.sld_Contrast,'Min',min, ...
                     'Max',max, ...
                     'SliderStep',[1/(max-min) 10/(max-min)], ...
                     'Value',a.DefaultValue);
set(handles.edt_Contrast,'Value',a.DefaultValue, ...
                     'String',num2str(a.DefaultValue));
set(handles.txt_Contrast,'Enable','on');
set(handles.edt_Contrast,'Enable','on');
set(handles.sld_Contrast,'Enable','on');
try
    src.ContrastMode='auto';
    set(handles.chkbx_AutoContrast,'Enable','on', ...
                                   'Value',1);
catch
    set(handles.chkbx_AutoContrast,'Enable','off');
end
% BRIGHTNESS
a=propinfo(src,'Brightness');
min=a.ConstraintValue(1);
max=a.ConstraintValue(2);
set(handles.sld_Brightness,'Min',min, ...
                     'Max',max, ...
                     'SliderStep',[1/(max-min) 10/(max-min)], ...
                     'Value',a.DefaultValue);
set(handles.edt_Brightness,'Value',a.DefaultValue, ...
                     'String',num2str(a.DefaultValue));
set(handles.txt_Brightness,'Enable','on');
set(handles.edt_Brightness,'Enable','on');
set(handles.sld_Brightness,'Enable','on');

% BACKLIGHT COMPENSATION
try
    src.BacklightCompensation = 'on';
    set(handles.chkbx_Backlight,'Enable','on', ...
                                'Value',1);
catch
    set(handles.chkbx_Backlight,'Enable','off');
end
% HORIZONTAL FLIP
try
    src.HorizontalFlip = 'off';
    set(handles.chkbx_HFlip,'Enable','on', ...
                                'Value',0);
catch
    set(handles.chkbx_HFlip,'Enable','off');
end
% VERTICAL FLIP
try
    src.VerticalFlip = 'off';
    set(handles.chkbx_VFlip,'Enable','on', ...
                                'Value',0);
catch
    set(handles.chkbx_VFlip,'Enable','off');
end

% FOCUS
try
    a=propinfo(src,'Focus');
    min=a.ConstraintValue(1);
    max=a.ConstraintValue(2);
    set(handles.sld_Focus,'Min',min, ...
                          'Max',max, ...
                          'SliderStep',[1/(max-min) 10/(max-min)], ...
                          'Value',a.DefaultValue);
    set(handles.edt_Focus,'Value',a.DefaultValue, ...
                          'String',num2str(a.DefaultValue));
    set(handles.txt_Focus,'Enable','on');
    set(handles.edt_Focus,'Enable','on');
    set(handles.sld_Focus,'Enable','on');
    src.FocusMode='auto';
    set(handles.chkbx_AutoFocus,'Enable','on', ...
                                    'Value',1);
catch
	set(handles.sld_Focus,'Enable','off');
    set(handles.edt_Focus,'Enable','off');
	set(handles.chkbx_AutoFocus,'Enable','off');
end

set(handles.btn_CamDefaults,'Enable','on');
set(handles.txt_ROIZoom,'Enable','on');
set(handles.btn_StartPreview,'Enable','off');


% --- Executes on button press in btn_Close.
function btn_Close_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global vid devid adapt format src ROI
index=get(handles.formats,'Value');
list=get(handles.formats,'String');
format=list{index};
if strcmp(get(vid,'Running'),'off') stoppreview(vid); end
% vid=videoinput(char(adapt),devid, format);
% src = getselectedsource(vid);
% src.FocusMode='manual';
% src.Focus=get(handles.edt_Focus,'Value');
% vid.ROIPosition=ROI;

close


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
global vid
delete(hObject);


% --- Executes on button press in btn_StopPreview.
function btn_StopPreview_Callback(hObject, eventdata, handles)
% hObject    handle to btn_StopPreview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global vid childImg
set(handles.btn_Close,'Enable','on');
set(handles.btn_StartPreview,'Enable','on');
set(handles.btn_StopPreview,'Enable','off');
stoppreview(vid);
% Change the cursor back to 'pointer'
 iptSetPointerBehavior(handles.axes1, []);
 iptPointerManager(gcf);



% --- Executes on button press in btn_SelectROI.
function btn_SelectROI_Callback(hObject, eventdata, handles)
% hObject    handle to btn_SelectROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global vid src vidRes ZoomXX ROI childImg

vidRes=vid.VideoResolution;
nBands = get(vid, 'NumberOfBands'); 
% zoom on;

% pan = propinfo(src,'Pan');
% panlimit_l = pan.ConstraintValue(1);
% panlimit_u = pan.ConstraintValue(2);
% 
% tilt = propinfo(src,'Tilt');
% tiltlimit_l = tilt.ConstraintValue(1);
% tiltlimit_u = tilt.ConstraintValue(2);

try
    zoominfo = propinfo(src,'Zoom');
	zoominfo.ConstraintValue(1) = max(zoominfo.ConstraintValue(1),...
                                  zoominfo.ConstraintValue(2));
	zoominfo.ConstraintValue(2) = max(zoominfo.ConstraintValue(1),...
                                  zoominfo.ConstraintValue(2));
    zoomlimit_x = zoominfo.ConstraintValue(1);
    zoomlimit_y = zoominfo.ConstraintValue(2);
catch
end

ROI = getrect(handles.axes1);
% OrPos = get(handles.axes1,'Position');
ZoomXX = round(1+(log(vidRes(1)/ROI(3))/log(2)));
ZoomYY = round(1+(log(vidRes(2)/ROI(4))/log(2)));
%Maximum value constraint for zooming limit (v.d.  propinfo(src,'Zoom')
% if ZoomXX > zoomlimit_x ZoomXX = zoomlimit_x; end
% if ZoomYY > zoomlimit_y ZoomYY = zoomlimit_y; end

stoppreview(vid);
try
    src.Zoom=ZoomXX;
catch
end
childImg = image(zeros(floor(ROI(4)),floor(ROI(3)), nBands),'Parent',handles.axes1);
axis equal;
vid.ROIPosition=ROI;
preview(vid,childImg);
set(handles.edt_ROIZoom,'String',num2str(ZoomXX));
set(handles.btn_ResetROI,'Enable','on');
set(handles.btn_SelectROI,'Enable','off');
% Change the cursor to 'fleur'
 enterFcn = @(figHandle, currentPoint)...
       set(figHandle, 'Pointer', 'fleur');
 iptSetPointerBehavior(handles.axes1, enterFcn);
 iptPointerManager(gcf);
 
%  hpanel = imscrollpanel(handles.figure1,childImg);
%  set(hpanel,'Units','normalized','Position',[0 .1 1 .9]);
 
% set(gca,'ButtonDownFcn','selectmoveresize');
% set(gcf,'WindowButtonDownFcn','selectmoveresize');
set(childImg,'ButtonDownFcn',{@startDragFcn,handles});
set(gcf,'WindowButtonUpFcn',{@stopDragFcn,handles});


% --- Executes during object creation, after setting all properties.
function btn_SelectROI_CreateFcn(hObject, eventdata, handles)
% hObject    handle to btn_SelectROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in btn_ResetROI.
function btn_ResetROI_Callback(hObject, eventdata, handles)
% hObject    handle to btn_ResetROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global vid devid adapt format

stoppreview(vid);
vid = videoinput(char(adapt),devid,format);   
vid.ReturnedColorspace = 'grayscale';
vidRes = get(vid, 'VideoResolution'); 
nBands = get(vid, 'NumberOfBands'); 
hImage = image(zeros(vidRes(2),vidRes(1), nBands),'Parent',handles.axes1);
axis equal;
preview(vid,hImage);
set(handles.edt_ROIZoom,'String',0);
set(handles.btn_ResetROI,'Enable','off');
set(handles.btn_SelectROI,'Enable','on');
% Change the cursor back to 'pointer'
 iptSetPointerBehavior(handles.axes1, []);
 iptPointerManager(gcf);


% --- Executes during object creation, after setting all properties.
function btn_ResetROI_CreateFcn(hObject, eventdata, handles)
% hObject    handle to btn_ResetROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


function edt_Focus_Callback(hObject, eventdata, handles)
% hObject    handle to edt_Focus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edt_Focus as text
%        str2double(get(hObject,'String')) returns contents of edt_Focus as a double
global vid src
src.FocusMode = 'manual';
focusvalue = floor(str2num(get(handles.edt_Focus,'String')));
set(handles.sld_Focus,'Value',focusvalue);
stoppreview(vid);
src.Focus = focusvalue;
preview(vid);


% --- Executes during object creation, after setting all properties.
function edt_Focus_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edt_Focus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sld_Focus_Callback(hObject, eventdata, handles)
% hObject    handle to sld_Focus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global vid src
src.FocusMode = 'manual';
set(handles.chkbx_AutoFocus,'Value',0);
focusvalue = uint8(floor(get(handles.sld_Focus,'Value')));
% set(handles.sld_Focus,'Value',focusvalue);
set(handles.edt_Focus,'Value',focusvalue);
set(handles.edt_Focus,'String',num2str(focusvalue));
stoppreview(vid);
src.Focus = focusvalue;
preview(vid);


% --- Executes during object creation, after setting all properties.
function sld_Focus_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sld_Focus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in chkbx_AutoFocus.
function chkbx_AutoFocus_Callback(hObject, eventdata, handles)
% hObject    handle to chkbx_AutoFocus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkbx_AutoFocus
global vid src
checkboxStatus = get(hObject,'Value');
if checkboxStatus==1
    src.FocusMode = 'auto';
else
    src.FocusMode = 'manual';
end
stoppreview(vid);
preview(vid);
focusvalue = src.Focus;
set(handles.edt_Focus,'Value',focusvalue);
set(handles.sld_Focus,'Value',focusvalue);
set(handles.edt_Focus,'String',num2str(focusvalue));

% --- Executes during object creation, after setting all properties.
function chkbx_AutoFocus_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chkbx_AutoFocus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes on button press in chkbx_AutoGain.
function chkbx_AutoGain_Callback(hObject, eventdata, handles)
% hObject    handle to chkbx_AutoGain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkbx_AutoGain
global vid src
checkboxStatus = get(hObject,'Value');
if checkboxStatus==1
    src.GainMode = 'auto';
else
    src.GainMode = 'manual';
end
stoppreview(vid);
preview(vid);
gainvalue = src.Gain;
set(handles.edt_Gain,'Value',gainvalue);
set(handles.sld_Gain,'Value',gainvalue);
set(handles.edt_Gain,'String',num2str(gainvalue));


% --- Executes during object creation, after setting all properties.
function chkbx_AutoGain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chkbx_AutoGain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


function edt_Gain_Callback(hObject, eventdata, handles)
% hObject    handle to edt_Gain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edt_Gain as text
%        str2double(get(hObject,'String')) returns contents of edt_Gain as a double
global vid src
gainvalue = round(str2num(get(handles.edt_Gain,'String')));
set(handles.sld_Gain,'Value',gainvalue);
stoppreview(vid);
src.Gain = gainvalue;
preview(vid);


% --- Executes during object creation, after setting all properties.
function edt_Gain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edt_Gain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sld_Gain_Callback(hObject, eventdata, handles)
% hObject    handle to sld_Gain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global vid src
src.GainMode = 'manual';
set(handles.chkbx_AutoGain,'Value',0);
gainvalue = round(get(handles.sld_Gain,'Value'));
% set(handles.sld_Gain,'Value',gainvalue);
set(handles.edt_Gain,'Value',gainvalue);
set(handles.edt_Gain,'String',num2str(gainvalue));
stoppreview(vid);
src.Gain = gainvalue;
preview(vid);

% --- Executes during object creation, after setting all properties.
function sld_Gain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sld_Gain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in chkbx_AutoExposure.
function chkbx_AutoExposure_Callback(hObject, eventdata, handles)
% hObject    handle to chkbx_AutoExposure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkbx_AutoExposure
global vid src
checkboxStatus = get(hObject,'Value');
if checkboxStatus==1
    src.ExposureMode = 'auto';
else
    src.ExposureMode = 'manual';
end
stoppreview(vid);
preview(vid);
exposurevalue = src.Exposure;
set(handles.edt_Exposure,'Value',exposurevalue);
set(handles.sld_Exposure,'Value',exposurevalue);
set(handles.edt_Exposure,'String',num2str(exposurevalue));

% --- Executes during object creation, after setting all properties.
function chkbx_AutoExposure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chkbx_AutoExposure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function txt_Exposure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_Exposure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function edt_Exposure_Callback(hObject, eventdata, handles)
% hObject    handle to edt_Exposure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edt_Exposure as text
%        str2double(get(hObject,'String')) returns contents of edt_Exposure as a double
global vid src
src.ExposureMode = 'manual';
exposurevalue = round(str2num(get(handles.edt_Exposure,'String')));
set(handles.sld_Exposure,'Value',exposurevalue);
stoppreview(vid);
src.Exposure = exposurevalue;
preview(vid);

% --- Executes during object creation, after setting all properties.
function edt_Exposure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edt_Exposure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function sld_Exposure_Callback(hObject, eventdata, handles)
% hObject    handle to sld_Exposure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global vid src
src.ExposureMode = 'manual';
set(handles.chkbx_AutoExposure,'Value',0);
exposurevalue = round(get(handles.sld_Exposure,'Value'));
% set(handles.sld_Exposure,'Value',exposurevalue);
set(handles.edt_Exposure,'Value',exposurevalue);
set(handles.edt_Exposure,'String',num2str(exposurevalue));
stoppreview(vid);
src.Exposure = exposurevalue;
preview(vid);

% --- Executes during object creation, after setting all properties.
function sld_Exposure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sld_Exposure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in chkbx_AutoContrast.
function chkbx_AutoContrast_Callback(hObject, eventdata, handles)
% hObject    handle to chkbx_AutoContrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkbx_AutoContrast
global vid src
checkboxStatus = get(hObject,'Value');
if checkboxStatus==1
    src.ContrastMode = 'auto';
else
    src.ContrastMode = 'manual';
end
stoppreview(vid);
preview(vid);
contrastvalue = src.Contrast;
set(handles.edt_Contrast,'Value',contrastvalue);
set(handles.sld_Contrast,'Value',contrastvalue);
set(handles.edt_Contrast,'String',num2str(contrastvalue));

% --- Executes during object creation, after setting all properties.
function chkbx_AutoContrast_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chkbx_AutoContrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function txt_Contrast_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_Contrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function edt_Contrast_Callback(hObject, eventdata, handles)
% hObject    handle to edt_Contrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edt_Contrast as text
%        str2double(get(hObject,'String')) returns contents of edt_Contrast as a double
global vid src
src.ContrastMode = 'manual';
contrastvalue = round(str2num(get(handles.edt_Contrast,'String')));
set(handles.sld_Contrast,'Value',contrastvalue);
stoppreview(vid);
src.Contrast = contrastvalue;
preview(vid);

% --- Executes during object creation, after setting all properties.
function edt_Contrast_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edt_Contrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function sld_Contrast_Callback(hObject, eventdata, handles)
% hObject    handle to sld_Contrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global vid src
src.ContrastMode = 'manual';
set(handles.chkbx_AutoContrast,'Value',0);
contrastvalue = round(get(handles.sld_Contrast,'Value'));
set(handles.edt_Contrast,'Value',contrastvalue);
set(handles.edt_Contrast,'String',num2str(contrastvalue));
stoppreview(vid);
src.Contrast = contrastvalue;
preview(vid);


% --- Executes during object creation, after setting all properties.
function sld_Contrast_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sld_Contrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes during object creation, after setting all properties.
function txt_Brightness_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_Brightness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


function edt_Brightness_Callback(hObject, eventdata, handles)
% hObject    handle to edt_Brightness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edt_Brightness as text
%        str2double(get(hObject,'String')) returns contents of edt_Brightness as a double
global vid src
src.BrightnessMode = 'manual';
brightnessvalue = round(str2num(get(handles.edt_Brightness,'String')));
set(handles.sld_Brightness,'Value',brightnessvalue);
stoppreview(vid);
src.Brightness = brightnessvalue;
preview(vid);

% --- Executes during object creation, after setting all properties.
function edt_Brightness_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edt_Brightness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function sld_Brightness_Callback(hObject, eventdata, handles)
% hObject    handle to sld_Brightness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global vid src
% src.BrightnessMode = 'manual';
% set(handles.chkbx_AutoContrast,'Value',0);
brightnessvalue = round(get(handles.sld_Brightness,'Value'));
set(handles.edt_Brightness,'Value',brightnessvalue);
set(handles.edt_Brightness,'String',num2str(brightnessvalue));
stoppreview(vid);
src.Brightness = brightnessvalue;
preview(vid);

% --- Executes during object creation, after setting all properties.
function sld_Brightness_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sld_Brightness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in chkbx_Backlight.
function chkbx_Backlight_Callback(hObject, eventdata, handles)
% hObject    handle to chkbx_Backlight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chkbx_Backlight
global vid src
checkboxStatus = get(hObject,'Value');
if checkboxStatus==1
    src.BacklightCompensation = 'on';
else
    src.BacklightCompensation = 'off';
end
stoppreview(vid);
preview(vid);

% --- Executes during object creation, after setting all properties.
function chkbx_Backlight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chkbx_Backlight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes on button press in chkbx_HFlip.
function chkbx_HFlip_Callback(hObject, eventdata, handles)
% hObject    handle to chkbx_HFlip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chkbx_HFlip
global vid src

stoppreview(vid);
checkboxStatus = get(hObject,'Value');
if checkboxStatus==1
    src.HorizontalFlip = 'on';
else
    src.HorizontalFlip = 'off';
end
preview(vid);

% --- Executes during object creation, after setting all properties.
function chkbx_HFlip_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chkbx_HFlip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: get(hObject,'Value') returns toggle state of chkbx_VFlip

% --- Executes on button press in chkbx_VFlip.
function chkbx_VFlip_Callback(hObject, eventdata, handles)
% hObject    handle to chkbx_VFlip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chkbx_VFlip
global vid src

stoppreview(vid);
checkboxStatus = get(hObject,'Value');
if checkboxStatus==1
    src.VerticalFlip = 'on';
else
    src.VerticalFlip = 'off';
end
preview(vid);

% --- Executes during object creation, after setting all properties.
function chkbx_VFlip_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chkbx_VFlip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes on button press in btn_CamDefaults.
function btn_CamDefaults_Callback(hObject, eventdata, handles)
% hObject    handle to btn_CamDefaults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global vid src sourcedefaults
stoppreview(vid);

% EXPOSURE
set(handles.sld_Exposure,'Value',sourcedefaults.Exposure);
set(handles.edt_Exposure,'Value',sourcedefaults.Exposure, ...
                         'String',num2str(sourcedefaults.Exposure));
set(src,'Exposure',sourcedefaults.Exposure);
set(handles.chkbx_AutoExposure,'Value',strcmp(sourcedefaults.ExposureMode,'auto'));
set(src,'ExposureMode',sourcedefaults.ExposureMode);

% FOCUS
try
set(handles.sld_Focus,'Value',sourcedefaults.Focus);
set(handles.edt_Focus,'Value',sourcedefaults.Focus, ...
                      'String',num2str(sourcedefaults.Focus));
set(src,'Focus',sourcedefaults.Focus);
set(handles.chkbx_AutoFocus,'Value',strcmp(sourcedefaults.FocusMode,'auto'));
set(src,'FocusMode',sourcedefaults.FocusMode);
catch
end

% GAIN
set(handles.sld_Gain,'Value',sourcedefaults.Gain);
set(handles.edt_Gain,'Value',sourcedefaults.Gain, ...
                     'String',num2str(sourcedefaults.Gain));
set(handles.chkbx_AutoGain,'Value',strcmp(sourcedefaults.GainMode,'auto'));
set(src,'Gain',sourcedefaults.Gain);

% CONTRAST
set(handles.sld_Contrast,'Value',sourcedefaults.Contrast);
set(handles.edt_Contrast,'Value',sourcedefaults.Contrast, ...
                     'String',num2str(sourcedefaults.Contrast));
set(handles.chkbx_AutoContrast,'Value',strcmp(sourcedefaults.ContrastMode,'auto'));
set(src,'Contrast',sourcedefaults.Contrast);

% BRIGHTNESS
set(handles.sld_Brightness,'Value',sourcedefaults.Brightness);
set(handles.edt_Brightness,'Value',sourcedefaults.Brightness, ...
                     'String',num2str(sourcedefaults.Brightness));
% set(handles.chkbx_Contrast,'Value',strcmp(sourcedefaults.ContrastMode,'auto'));
set(src,'Brightness',sourcedefaults.Brightness);

% BACKLIGHT
set(handles.chkbx_Backlight,'Value',strcmp(sourcedefaults.BacklightCompensation,'on'));
set(src,'BacklightCompensation',sourcedefaults.BacklightCompensation);

% HORIZONTAL FLIP
set(handles.chkbx_HFlip,'Value',strcmp(sourcedefaults.HorizontalFlip,'on'));
set(src,'HorizontalFlip',sourcedefaults.HorizontalFlip);

% VERTICAL FLIP
set(handles.chkbx_VFlip,'Value',strcmp(sourcedefaults.VerticalFlip,'on'));
set(src,'VerticalFlip',sourcedefaults.VerticalFlip);

set(handles.btn_ResetROI,'Enable','off');
preview(vid);

% --- Executes during object creation, after setting all properties.
function btn_CamDefaults_CreateFcn(hObject, eventdata, handles)
% hObject    handle to btn_CamDefaults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function edt_ROIZoom_Callback(hObject, eventdata, handles)
% hObject    handle to edt_ROIZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edt_ROIZoom as text
%        str2double(get(hObject,'String')) returns contents of edt_ROIZoom as a double



% --- Executes during object creation, after setting all properties.
function edt_ROIZoom_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edt_ROIZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on mouse press over axes background.
function dragROI(endpt)
global vid vidRes ROI startpt
movXX=-(endpt(1,1)-startpt(1,1));
movYY=-(endpt(1,2)-startpt(1,2));
% fprintf('%d\n',movXX, movYY);
if ROI(1)+movXX>0 && ROI(2)+movYY>0 
    newROI = [ROI(1)+movXX,ROI(2)+movYY,ROI(3),ROI(4)];
else
    newROI=ROI;
end
if newROI(1)+newROI(3)<=vidRes(1) && newROI(2)+newROI(4)<=vidRes(2)
    vid.ROIPosition=newROI;
    ROI = newROI;
else
    vid.ROIPosition=ROI;
end
startpt=endpt;

% Dragging window functions
function startDragFcn(varargin)
global startpt
    startpt = get(gca, 'CurrentPoint');
    set(gcf,'WindowButtonMotionFcn', @draggingFcn);

function draggingFcn(varargin)
% global startpt
endpt = get(gca, 'CurrentPoint');
%     startDrag=varargin(3);
    dragROI(endpt);


function stopDragFcn(varargin)
    set(gcf,'WindowButtonMotionFcn', '');

