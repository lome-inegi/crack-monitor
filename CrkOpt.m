function varargout = CrkOpt(varargin)
% CRKOPT MATLAB code for CrkOpt.fig
%      CRKOPT, by itself, creates a new CRKOPT or raises the existing
%      singleton*.
%
%      H = CRKOPT returns the handle to a new CRKOPT or the handle to
%      the existing singleton*.
%
%      CRKOPT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CRKOPT.M with the given input arguments.
%
%      CRKOPT('Property','Value',...) creates a new CRKOPT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CrkOpt_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CrkOpt_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CrkOpt

% Last Modified by GUIDE v2.5 13-May-2013 15:58:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CrkOpt_OpeningFcn, ...
                   'gui_OutputFcn',  @CrkOpt_OutputFcn, ...
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


% --- Executes just before CrkOpt is made visible.
function CrkOpt_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CrkOpt (see VARARGIN)
global ImgProcDataStructure Defaults datastructure setupImg
% Choose default command line output for CrkOpt
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CrkOpt wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Load image into graphics handle
img=datastructure.img;
MaxImg=size(img,3);
setupImg = im2double(img(:,:,MaxImg)); 
% setupImg = datastructure.img;
% ShowImage(handles,1,setupImg,[]);
Analyse_crack(handles);
% --- Populate uicontrols ---
% ImgProcDataStructure.ClipLimit = 0.005;
% ImgProcDataStructure.THRect = [30 2];
% ImgProcDataStructure.GrayThresh = 1.00;
% ImgProcDataStructure.StrelLR = 3;
% ImgProcDataStructure.CloseActions = 2;
% ImgProcDataStructure.SORemov = 80;

Defaults = ImgProcDataStructure;

% Clip Limit 
a=ImgProcDataStructure.ClipLimit;
min=0;
max=1;
set(handles.sld_ClipLimit,'Min',min, ...
                          'Max',max, ...
                          'SliderStep',[0.005/(max-min) 0.1/(max-min)], ...
                          'Value',a);
set(handles.edt_ClipLimit,'Value',a, ...
                          'String',num2str(a));
set(handles.txt_ClipLimit,'Enable','on');
set(handles.edt_ClipLimit,'Enable','off');
set(handles.sld_ClipLimit,'Enable','off');
set(handles.chkbx_ClipLimit,'Enable','on');

% THRect 
a=ImgProcDataStructure.THRect(1);%b=ImgProcDataStructure.THRect(2);
min=2;
max=50;
set(handles.sld_THRect,'Min',min, ...
                       'Max',max, ...
                       'SliderStep',[1/(max-min) 10/(max-min)], ...
                       'Value',a);
set(handles.edt_THRect,'Value',a, ...
                       'String',num2str(a));
set(handles.txt_THRect,'Enable','on');
set(handles.edt_THRect,'Enable','off');
set(handles.sld_THRect,'Enable','off');
set(handles.chkbx_THRect,'Enable','on');

% Gray Threshold
a=ImgProcDataStructure.GrayThresh;
min=0.5;
max=2.5;
set(handles.sld_GrayThresh,'Min',min, ...
                           'Max',max, ...
                           'SliderStep',[0.1/(max-min) 0.5/(max-min)], ...
                           'Value',a);
set(handles.edt_GrayThresh,'Value',a, ...
                           'String',num2str(a));
set(handles.txt_GrayThresh,'Enable','on');
set(handles.edt_GrayThresh,'Enable','off');
set(handles.sld_GrayThresh,'Enable','off');
set(handles.chkbx_GrayThresh,'Enable','on');

% Strel for vertical Line Removal horizontal size
a=ImgProcDataStructure.StrelLR;
min=1;
max=10;
set(handles.sld_StrelLR,'Min',min, ...
                        'Max',max, ...
                        'SliderStep',[1/(max-min) 10/(max-min)], ...
                        'Value',a);
set(handles.edt_StrelLR,'Value',a, ...
                        'String',num2str(a));
set(handles.txt_StrelLR,'Enable','on');
set(handles.edt_StrelLR,'Enable','off');
set(handles.sld_StrelLR,'Enable','off');
set(handles.chkbx_StrelLR,'Enable','on');

% # closing actions after crack analysis Strel enhancement
a=ImgProcDataStructure.CloseActions;
min=1;
max=5;
set(handles.sld_CloseActions,'Min',min, ...
                             'Max',max, ...
                             'SliderStep',[1/(max-min) 2/(max-min)], ...
                             'Value',a);
set(handles.edt_CloseActions,'Value',a, ...
                             'String',num2str(a));
set(handles.txt_CloseActions,'Enable','on');
set(handles.edt_CloseActions,'Enable','off');
set(handles.sld_CloseActions,'Enable','off');
set(handles.chkbx_CloseActions,'Enable','on');

% Small Objects Removal threshold
a=ImgProcDataStructure.SORemov;
min=50;
max=500;
set(handles.sld_SORemov,'Min',min, ...
                        'Max',max, ...
                        'SliderStep',[10/(max-min) 50/(max-min)], ...
                        'Value',a);
set(handles.edt_SORemov,'Value',a, ...
                        'String',num2str(a));
set(handles.txt_SORemov,'Enable','on');
set(handles.edt_SORemov,'Enable','off');
set(handles.sld_SORemov,'Enable','off');
set(handles.chkbx_SORemov,'Enable','on');


% --- Outputs from this function are returned to the command line.
function varargout = CrkOpt_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% ---------------------------------------------------------------------
function Analyse_crack(handles)
% hObject    handle to Settings_Analyse_pre_crack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rect rect2 templateImg crackOrigin setupImg

% imgC=setupImg;
% MaxImg=size(img,3);
% imgC = im2double(img(:,:,MaxImg)); 

% The cracks can run to either side, hence...
sz=size(setupImg);
if rect2(1)>sz(2)/2
    % Crack to the left side
    difXX = rect(1) + rect(3) - (rect2(1) + rect2(3));
    rect1 = [rect2(1)-rect2(3) rect(2) 2*rect2(3)+difXX rect2(2)+2*rect2(4)-rect(2)];
else
    %Crack to the right side
    rect1 = [rect(1) rect(2) rect2(1)-rect(1)+2*rect2(3) rect2(2)-rect(2)+2*rect2(4)];
end

% Find the crack start within 'rect1' ROI
imgROI = imcrop(setupImg, rect1); 
cc = normxcorr2(templateImg,imgROI); 
[max_cc, imax] = max(abs(cc(:)));
[ypeak, xpeak] = ind2sub(size(cc),imax(1));
corr_offset = [ (ypeak-size(templateImg,1)) (xpeak-size(templateImg,2)) ];

XX=rect1(1)+corr_offset(2);                  
YY=rect1(2)+corr_offset(1)+rect2(4);

crackOrigin=[YY XX];
ShowImage(handles,1,setupImg,[]), hold on;
plot(XX, YY,'r+'), title('corners detected');
rectangle('Position',rect1, 'LineWidth',1, 'EdgeColor','r'); hold off;

% crackAnalysis(imgC, rect, A, pix2mm);
% ---------------------------------------------------------------------

function edt_ClipLimit_Callback(~, eventdata, handles)
% hObject    handle to edt_ClipLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edt_ClipLimit as text
%        str2double(get(hObject,'String')) returns contents of edt_ClipLimit as a double
global ImgProcDataStructure crackOrigin setupImg rect
ClipLimit = floor(str2num(get(handles.edt_ClipLimit,'String')));
set(handles.sld_ClipLimit,'Value',ClipLimit);
ImgProcDataStructure.ClipLimit = ClipLimit;
crckbin(handles,setupImg,rect,crackOrigin);

% --- Executes during object creation, after setting all properties.
function edt_ClipLimit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edt_ClipLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function sld_ClipLimit_Callback(hObject, eventdata, handles)
% hObject    handle to sld_ClipLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global ImgProcDataStructure crackOrigin setupImg rect
ClipLimit = get(handles.sld_ClipLimit,'Value');
set(handles.edt_ClipLimit,'Value',ClipLimit);
set(handles.edt_ClipLimit,'String',num2str(ClipLimit));
ImgProcDataStructure.ClipLimit = ClipLimit;
crckbin(handles,setupImg,rect,crackOrigin);

% --- Executes during object creation, after setting all properties.
function sld_ClipLimit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sld_ClipLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in chkbx_ClipLimit.
function chkbx_ClipLimit_Callback(hObject, eventdata, handles)
% hObject    handle to chkbx_ClipLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chkbx_ClipLimit
global ImgProcDataStructure Defaults crackOrigin setupImg rect

checkboxStatus = get(hObject,'Value');
if checkboxStatus==1
%     set(handles.txt_ClipLimit,'Enable','on');
    ClipLimit=ImgProcDataStructure.ClipLimit;
    set(handles.edt_ClipLimit,'Enable','on', 'Value',ClipLimit,'String',num2str(ClipLimit));
    set(handles.sld_ClipLimit,'Enable','on', 'Value',ClipLimit);
else
%     set(handles.txt_ClipLimit,'Enable','off');
    ClipLimit=Defaults.ClipLimit;
    set(handles.edt_ClipLimit,'Enable','off', 'Value',ClipLimit,'String',num2str(ClipLimit));
    set(handles.sld_ClipLimit,'Enable','off', 'Value',ClipLimit);
end
crckbin(handles,setupImg,rect,crackOrigin);

% ---------------------------------------------------------------------

function edt_THRect_Callback(hObject, eventdata, handles)
% hObject    handle to edt_THRect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edt_THRect as text
%        str2double(get(hObject,'String')) returns contents of edt_THRect as a double
global ImgProcDataStructure crackOrigin setupImg rect
THRect(1) = uint16(floor(str2num(get(handles.edt_THRect,'String'))));
set(handles.sld_THRect,'Value',THRect(1));
ImgProcDataStructure.THRect(1) = THRect(1);
crckbin(handles,setupImg,rect,crackOrigin);

% --- Executes during object creation, after setting all properties.
function edt_THRect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edt_THRect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function sld_THRect_Callback(hObject, eventdata, handles)
% hObject    handle to sld_THRect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global ImgProcDataStructure crackOrigin setupImg rect
THRect(1) = uint16(get(handles.sld_THRect,'Value'));
set(handles.edt_THRect,'Value',THRect(1));
set(handles.edt_THRect,'String',num2str(THRect(1)));
ImgProcDataStructure.THRect(1) = THRect(1);
crckbin(handles,setupImg,rect,crackOrigin);

% --- Executes during object creation, after setting all properties.
function sld_THRect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sld_THRect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in chkbx_THRect.
function chkbx_THRect_Callback(hObject, eventdata, handles)
% hObject    handle to chkbx_THRect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chkbx_THRect
global ImgProcDataStructure crackOrigin setupImg rect Defaults
checkboxStatus = get(hObject,'Value');
if checkboxStatus==1
    THRect=ImgProcDataStructure.THRect(1);
    set(handles.edt_THRect,'Enable','on', 'Value',THRect,'String',num2str(THRect));
    set(handles.sld_THRect,'Enable','on', 'Value',THRect);
else
    THRect=Defaults.THRect(1);
    set(handles.edt_THRect,'Enable','off', 'Value',THRect,'String',num2str(THRect));
    set(handles.sld_THRect,'Enable','off', 'Value',THRect);
end
crckbin(handles,setupImg,rect,crackOrigin);

% ---------------------------------------------------------------------

function edt_GrayThresh_Callback(hObject, eventdata, handles)
% hObject    handle to edt_GrayThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edt_GrayThresh as text
%        str2double(get(hObject,'String')) returns contents of edt_GrayThresh as a double
global ImgProcDataStructure crackOrigin setupImg rect
GrayThresh = floor(str2num(get(handles.edt_GrayThresh,'String')));
set(handles.sld_GrayThresh,'Value',GrayThresh);
ImgProcDataStructure.GrayThresh = GrayThresh;
crckbin(handles,setupImg,rect,crackOrigin);

% --- Executes during object creation, after setting all properties.
function edt_GrayThresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edt_GrayThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function sld_GrayThresh_Callback(hObject, eventdata, handles)
% hObject    handle to sld_GrayThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global ImgProcDataStructure crackOrigin setupImg rect
GrayThresh = get(handles.sld_GrayThresh,'Value');
set(handles.edt_GrayThresh,'Value',GrayThresh);
set(handles.edt_GrayThresh,'String',num2str(GrayThresh));
ImgProcDataStructure.GrayThresh = GrayThresh;
crckbin(handles,setupImg,rect,crackOrigin);

% --- Executes during object creation, after setting all properties.
function sld_GrayThresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sld_GrayThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in chkbx_GrayThresh.
function chkbx_GrayThresh_Callback(hObject, eventdata, handles)
% hObject    handle to chkbx_GrayThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chkbx_GrayThresh
global ImgProcDataStructure crackOrigin setupImg rect Defaults
checkboxStatus = get(hObject,'Value');
if checkboxStatus==1
    GrayThresh=ImgProcDataStructure.GrayThresh;
    set(handles.edt_GrayThresh,'Enable','on', 'Value',GrayThresh,'String',num2str(GrayThresh));
    set(handles.sld_GrayThresh,'Enable','on', 'Value',GrayThresh);
else
    GrayThresh=Defaults.GrayThresh;
    set(handles.edt_GrayThresh,'Enable','off', 'Value',GrayThresh,'String',num2str(GrayThresh));
    set(handles.sld_GrayThresh,'Enable','off', 'Value',GrayThresh);
end
crckbin(handles,setupImg,rect,crackOrigin);

% ---------------------------------------------------------------------

function edt_StrelLR_Callback(hObject, eventdata, handles)
% hObject    handle to edt_StrelLR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edt_StrelLR as text
%        str2double(get(hObject,'String')) returns contents of edt_StrelLR as a double
global ImgProcDataStructure crackOrigin setupImg rect
StrelLR = uint16(floor(str2num(get(handles.edt_StrelLR,'String'))));
set(handles.sld_StrelLR,'Value',StrelLR);
ImgProcDataStructure.StrelLR = double(StrelLR);
crckbin(handles,setupImg,rect,crackOrigin);

% --- Executes during object creation, after setting all properties.
function edt_StrelLR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edt_StrelLR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function sld_StrelLR_Callback(hObject, eventdata, handles)
% hObject    handle to sld_StrelLR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global ImgProcDataStructure crackOrigin setupImg rect
StrelLR = uint16(get(handles.sld_StrelLR,'Value'));
set(handles.edt_StrelLR,'Value',StrelLR);
set(handles.edt_StrelLR,'String',num2str(StrelLR));
ImgProcDataStructure.StrelLR = double(StrelLR);
crckbin(handles,setupImg,rect,crackOrigin);

% --- Executes during object creation, after setting all properties.
function sld_StrelLR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sld_StrelLR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in chkbx_StrelLR.
function chkbx_StrelLR_Callback(hObject, eventdata, handles)
% hObject    handle to chkbx_StrelLR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chkbx_StrelLR
global ImgProcDataStructure crackOrigin setupImg rect Defaults
checkboxStatus = get(hObject,'Value');
if checkboxStatus==1
    StrelLR=ImgProcDataStructure.StrelLR;
    set(handles.edt_StrelLR,'Enable','on', 'Value',StrelLR,'String',num2str(StrelLR));
    set(handles.sld_StrelLR,'Enable','on', 'Value',StrelLR);
else
    StrelLR=Defaults.StrelLR;
    set(handles.edt_StrelLR,'Enable','off', 'Value',StrelLR,'String',num2str(StrelLR));
    set(handles.sld_StrelLR,'Enable','off', 'Value',StrelLR);
end
crckbin(handles,setupImg,rect,crackOrigin);

% ---------------------------------------------------------------------

function edt_CloseActions_Callback(hObject, eventdata, handles)
% hObject    handle to edt_CloseActions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edt_CloseActions as text
%        str2double(get(hObject,'String')) returns contents of edt_CloseActions as a double
global ImgProcDataStructure crackOrigin setupImg rect
CloseActions = uint16(floor(str2num(get(handles.edt_CloseActions,'String'))));
set(handles.sld_CloseActions,'Value',CloseActions);
ImgProcDataStructure.CloseActions = CloseActions;
crckbin(handles,setupImg,rect,crackOrigin);

% --- Executes during object creation, after setting all properties.
function edt_CloseActions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edt_CloseActions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function sld_CloseActions_Callback(hObject, eventdata, handles)
% hObject    handle to sld_CloseActions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global ImgProcDataStructure crackOrigin setupImg rect
CloseActions = uint16(get(handles.sld_CloseActions,'Value'));
set(handles.edt_CloseActions,'Value',CloseActions);
set(handles.edt_CloseActions,'String',num2str(CloseActions));
ImgProcDataStructure.CloseActions = CloseActions;
crckbin(handles,setupImg,rect,crackOrigin);

% --- Executes during object creation, after setting all properties.
function sld_CloseActions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sld_CloseActions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in chkbx_CloseActions.
function chkbx_CloseActions_Callback(hObject, eventdata, handles)
% hObject    handle to chkbx_CloseActions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chkbx_CloseActions
global ImgProcDataStructure crackOrigin setupImg rect Defaults
checkboxStatus = get(hObject,'Value');
if checkboxStatus==1
    CloseActions=ImgProcDataStructure.CloseActions;
    set(handles.edt_CloseActions,'Enable','on', 'Value',CloseActions,'String',num2str(CloseActions));
    set(handles.sld_CloseActions,'Enable','on', 'Value',CloseActions);
else
    CloseActions=Defaults.CloseActions;
    set(handles.edt_CloseActions,'Enable','off', 'Value',CloseActions,'String',num2str(CloseActions));
    set(handles.sld_CloseActions,'Enable','off', 'Value',CloseActions);
end
crckbin(handles,setupImg,rect,crackOrigin);

% ---------------------------------------------------------------------

function edt_SORemov_Callback(hObject, eventdata, handles)
% hObject    handle to edt_SORemov (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of edt_SORemov as text
%        str2double(get(hObject,'String')) returns contents of edt_SORemov as a double
global ImgProcDataStructure crackOrigin setupImg rect
SORemov = uint16(floor(str2num(get(handles.edt_SORemov,'String'))));
set(handles.sld_SORemov,'Value',SORemov);
ImgProcDataStructure.SORemov = double(SORemov);
crckbin(handles,setupImg,rect,crackOrigin);

% --- Executes during object creation, after setting all properties.
function edt_SORemov_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edt_SORemov (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function sld_SORemov_Callback(hObject, eventdata, handles)
% hObject    handle to sld_SORemov (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global ImgProcDataStructure crackOrigin setupImg rect
SORemov = uint16(get(handles.sld_SORemov,'Value'));
set(handles.edt_SORemov,'Value',SORemov);
set(handles.edt_SORemov,'String',num2str(SORemov));
ImgProcDataStructure.SORemov = double(SORemov);
crckbin(handles,setupImg,rect,crackOrigin);

% --- Executes during object creation, after setting all properties.
function sld_SORemov_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sld_SORemov (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in chkbx_SORemov.
function chkbx_SORemov_Callback(hObject, eventdata, handles)
% hObject    handle to chkbx_SORemov (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chkbx_SORemov
global ImgProcDataStructure crackOrigin setupImg rect Defaults
checkboxStatus = get(hObject,'Value');
if checkboxStatus==1
    SORemov=ImgProcDataStructure.SORemov;
    set(handles.edt_SORemov,'Enable','on', 'Value',SORemov,'String',num2str(SORemov));
    set(handles.sld_SORemov,'Enable','on', 'Value',SORemov);
else
    SORemov=Defaults.SORemov;
    set(handles.edt_SORemov,'Enable','off', 'Value',SORemov,'String',num2str(SORemov));
    set(handles.sld_SORemov,'Enable','off', 'Value',SORemov);
end
crckbin(handles,setupImg,rect,crackOrigin);

% ---------------------------------------------------------------------

function ShowImage(handles,AxesType,Img,map)
axesn=strcat('axes',num2str(AxesType));
[SizeY SizeX]=size(Img);
Figpos = get(handles.figure1,'Position');
pos=get(handles.(axesn),'Position');
% Outpos=get(handles.(axesn),'OuterPosition');
% pos(4) = pos(3)*SizeY/SizeX;
% pos(1) = Figpos(3)-pos(3)-25;
% pos(2) = Figpos(4)-pos(4)-25;
% cla(handles.(axesn),'reset');
axes(handles.(axesn));
set(handles.(axesn), 'Units','pixels',...
                    'PlotBoxAspectRatioMode','manual',...
                    'DataAspectRatioMode','manual',...
                    'XLimMode','manual',...
                    'YLimMode','manual',...
                    'Position',pos,...
                    'Visible', 'off',...
                    'Color',[0 0 0],...
                    'xtick',[],'ytick',[]);
%                     'box','on','handlevisibility','off');
imshow(Img,'Parent',handles.(axesn));
if isempty(map)
	colormap gray;
else
	colormap map;   
end         

% 
% % --- Executes when user attempts to close figure1.
% function figure1_CloseRequestFcn(hObject, eventdata, handles)
% % hObject    handle to figure1 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hint: delete(hObject) closes the figure
% global vid
% delete(hObject);


% --- Executes during object creation, after setting all properties.
function btn_OK_CreateFcn(hObject, eventdata, handles)
% hObject    handle to btn_OK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes on button press in btn_OK.
function btn_OK_Callback(hObject, eventdata, handles)
% hObject    handle to btn_OK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close

% ---------------------------------------------------------------------

% --- Executes during object creation, after setting all properties.
function btn_Cancel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to btn_Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes on button press in btn_Cancel.
function btn_Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ImgProcDataStructure Defaults
ImgProcDataStructure = Defaults;
close

% % --- Executes when user attempts to close figure1.
% function figure1_CloseRequestFcn(hObject, eventdata, handles)
% % hObject    handle to figure1 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hint: delete(hObject) closes the figure
% delete(hObject);

% Process -------------------------------------------------------------

function crckbin(handles, crckimg, cracROI, crackOrigin)

[crckbin, lengthpix, BoundingBox] = processCrack(crckimg, cracROI, crackOrigin, false);

relativeOrigin = [crackOrigin(2)-cracROI(1) crackOrigin(1)-cracROI(2)];

set(handles.txt_out,'String',lengthpix);
ShowImage(handles,1,crckbin,[]);
ruler=[];
for k=1:size(crckbin,2)
    if mod(k,50)==0
        ruler(size(ruler,1)+1,1)=k;
    end
end
hold on;
rectangle('Position',BoundingBox, 'LineWidth',1, 'EdgeColor','r');
plot(ruler,zeros(size(ruler,1))+size(crckbin,1),'w+');
%plot(X-cracROI(1)+1,size(crckbin,1),'r+');
plot(relativeOrigin(1), relativeOrigin(2),'r+');
hold off;
