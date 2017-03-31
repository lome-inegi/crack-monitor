function varargout = CrackOrigin(varargin)
% CRACKORIGIN MATLAB code for CrackOrigin.fig
%      CRACKORIGIN, by itself, creates a new CRACKORIGIN or raises the existing
%      singleton*.
%
%      H = CRACKORIGIN returns the handle to a new CRACKORIGIN or the handle to
%      the existing singleton*.
%
%      CRACKORIGIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CRACKORIGIN.M with the given input arguments.
%
%      CRACKORIGIN('Property','Value',...) creates a new CRACKORIGIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CrackOrigin_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CrackOrigin_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CrackOrigin

% Last Modified by GUIDE v2.5 31-Mar-2017 14:59:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CrackOrigin_OpeningFcn, ...
                   'gui_OutputFcn',  @CrackOrigin_OutputFcn, ...
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


% --- Executes just before CrackOrigin is made visible.
function CrackOrigin_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CrackOrigin (see VARARGIN)
global DefaultsOrigin datastructure setupImg ImgOriginDataStructure rectCrackStartROI referenceCrackOrigin
% Choose default command line output for CrackOrigin
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
if (isempty(ImgOriginDataStructure))
   ImgOriginDataStructure.originRadius = 5;
   ImgOriginDataStructure.radius = 0.5;
   ImgOriginDataStructure.sigma = 1;
end

if (~isempty(referenceCrackOrigin))
   %If there is a previous result 
   
end
% --- Load image into graphics handle
getCrackOrigin(handles,setupImg);

DefaultsOrigin = ImgOriginDataStructure;

% originRadius
a=ImgOriginDataStructure.originRadius;
min=1;
max=20;
if (a<min), a=min; end; if(a>max), a=max; end;
set(handles.sld_originRadius,'Min',min, ...
                           'Max',max, ...
                           'SliderStep',[min/(max-min) 10/(max-min)], ...
                           'Value',a);
set(handles.edt_originRadius,'Value',a, ...
                           'String',num2str(a));

% SIGMA
a = ImgOriginDataStructure.sigma;
min=1;
max=10;
if (a<min), a=min; end; if(a>max), a=max; end;
set(handles.sld_Sigma,'Min',min, ...
                        'Max',max, ...
                        'SliderStep',[1/(max-min) 10/(max-min)], ...
                        'Value',a);
set(handles.edt_Sigma,'Value',a, ...
                        'String',num2str(a));

% RADIUS
a = ImgOriginDataStructure.radius;
min=0.5;
max=5;
if (a<min), a=min; end; if(a>max), a=max; end;
set(handles.sld_Radius,'Min',min, ...
                             'Max',max, ...
                             'SliderStep',[0.5/(max-min) 0.5/(max-min)], ...
                             'Value',a);
                         
set(handles.edt_Radius,'Value',a, ...
                             'String',num2str(a));


% --- Outputs from this function are returned to the command line.
function varargout = CrackOrigin_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% ---------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function edt_originRadius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edt_originRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function sld_originRadius_Callback(hObject, eventdata, handles)
% hObject    handle to sld_originRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global ImgOriginDataStructure setupImg
minRes = 1;
originRadius = get(handles.sld_originRadius,'Value');
originRadius = double(uint16(originRadius / minRes)) * minRes; % Only allow values multiple of 0.5
if (originRadius < minRes)
    originRadius = minRes;
end
set(handles.sld_originRadius,'Value',originRadius);
set(handles.edt_originRadius,'Value',originRadius);
set(handles.edt_originRadius,'String',num2str(originRadius));
ImgOriginDataStructure.originRadius = originRadius;
getCrackOrigin(handles,setupImg);

% --- Executes during object creation, after setting all properties.
function sld_originRadius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sld_originRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% ---------------------------------------------------------------------

% --- Executes during object creation, after setting all properties.
function edt_Sigma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edt_Sigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function sld_Sigma_Callback(hObject, eventdata, handles)
% hObject    handle to sld_Sigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global ImgOriginDataStructure setupImg
sigma = uint16(get(handles.sld_Sigma,'Value'));
set(handles.sld_Sigma,'Value',sigma);
set(handles.edt_Sigma,'Value',sigma);
set(handles.edt_Sigma,'String',num2str(sigma));
ImgOriginDataStructure.sigma = double(sigma);
getCrackOrigin(handles,setupImg);

% --- Executes during object creation, after setting all properties.
function sld_Sigma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sld_Sigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% ---------------------------------------------------------------------

% --- Executes during object creation, after setting all properties.
function edt_Radius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edt_Radius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function sld_Radius_Callback(hObject, eventdata, handles)
% hObject    handle to sld_Radius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global ImgOriginDataStructure setupImg  
minRes = 0.5;
radius = get(handles.sld_Radius,'Value');
radius = double(uint16(radius / minRes)) * minRes;
if (radius < minRes)
    radius = minRes;
end
set(handles.sld_Radius,'Value',radius);
set(handles.edt_Radius,'Value',radius);
set(handles.edt_Radius,'String',num2str(radius));
ImgOriginDataStructure.radius = radius;
getCrackOrigin(handles,setupImg);

% --- Executes during object creation, after setting all properties.
function sld_Radius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sld_Radius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

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
set(handles.(axesn), 'Units','normalized',...
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
global tempReferenceCrackOrigin referenceCrackOrigin
referenceCrackOrigin = tempReferenceCrackOrigin;
close;

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
global referenceCrackOrigin
referenceCrackOrigin = [];
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

function getCrackOrigin(handles, im)
global ImgOriginDataStructure rectCrackStartROI ImgOriginTempData referenceCrackOrigin tempReferenceCrackOrigin

ImgOriginDataStructure.deltaX = [];
ImgOriginDataStructure.deltaY = [];
set(handles.messages,'String','');
sigma = ImgOriginDataStructure.sigma;
radius = ImgOriginDataStructure.radius;
originRadius = ImgOriginDataStructure.originRadius;

im = im2double(im);
ImgOriginTempData.im = im;
[r,c] = harris(im,sigma,radius,originRadius,referenceCrackOrigin,rectCrackStartROI);
ShowImage(handles,1,im,[]);
hold on;
plot (c+rectCrackStartROI(1),r+rectCrackStartROI(2),'r+');
if (~isempty(referenceCrackOrigin))
    plot (referenceCrackOrigin(2)+rectCrackStartROI(1), referenceCrackOrigin(1)+rectCrackStartROI(2),'bx');
end
if (~isempty(r) && ~isempty(c))
    set(handles.messages,'String','Result found.');
    set(handles.messages,'ForegroundColor','k');
    tempReferenceCrackOrigin = [r,c];
else
    set(handles.messages,'String','No result found.');
    set(handles.messages,'ForegroundColor','r');
    tempReferenceCrackOrigin = [];
end

% %Harris Corner Detection Method
% dx = [-1 0 1; -1 0 1; -1 0 1]; % Derivative masks
% dy = dx';
% Ix = conv2(im, dx, 'same');    % Image derivatives
% Iy = conv2(im, dy, 'same');    
% % Generate Gaussian filter of size 6*sigma (+/- 3sigma) and of
% % minimum size 1x1.
% g = fspecial('gaussian',max(1,fix(6*sigma)), sigma);
% 
% Ix2 = conv2(Ix.^2, g, 'same'); % Smoothed squared image derivatives
% Iy2 = conv2(Iy.^2, g, 'same');
% Ixy = conv2(Ix.*Iy, g, 'same');
% 
% cim = (Ix2.*Iy2 - Ixy.^2)./(Ix2 + Iy2 + eps); % My preferred  measure.
% sze = 2*radius+1;                   % Size of mask.
% mx = ordfilt2(cim,sze^2,ones(sze)); % Grey-scale dilate.
% cim = (cim==mx)&(cim>thresh);       % Find maxima.
% 
% [r,c] = find(cim);                   % Find row,col coords.
%     
% newr = r((r>crackOriginROI(2) & r<crackOriginROI(2)+crackOriginROI(4) & c>crackOriginROI(1) & c<crackOriginROI(1)+crackOriginROI(3)));
% newc = c((r>crackOriginROI(2) & r<crackOriginROI(2)+crackOriginROI(4) & c>crackOriginROI(1) & c<crackOriginROI(1)+crackOriginROI(3)));
% ImgOriginTempData.r = newr;
% ImgOriginTempData.c = newc;
% idx = 1;  
% if (length(newr) > 1)
%     ShowImage(handles,1,im,[]);
%     hold on;
%     plot (newc,newr,'bo');
%     set(handles.messages,'String','Multiple possible results found.');
%     set(handles.but_select_point,'Visible', 'on');
% elseif (isempty(newr))
%     ShowImage(handles,1,im,[]);
%     set(handles.messages,'String','No viable results found.');
%     set(handles.but_select_point,'Visible', 'off');
% else
%     set(handles.messages,'String','Result found.');
%     set(handles.but_select_point,'Visible', 'off');
%     processSelectedPoint(handles,idx);
% end





% --- Executes on button press in but_select_point.
function but_select_point_Callback(hObject, eventdata, handles)
% hObject    handle to but_select_point (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global referenceCrackOrigin rectCrackStartROI setupImg
[x, y] = ginput(1);
if (y<rectCrackStartROI(2)),y=rectCrackStartROI(2);end
if (y>rectCrackStartROI(2)+rectCrackStartROI(4)),y=rectCrackStartROI(2)+rectCrackStartROI(4);end
if (x<rectCrackStartROI(1)),x=rectCrackStartROI(1);end
if (x>rectCrackStartROI(1)+rectCrackStartROI(3)),x=rectCrackStartROI(1)+rectCrackStartROI(3);end
referenceCrackOrigin = [y-rectCrackStartROI(2) ,x-rectCrackStartROI(1)];
getCrackOrigin(handles,setupImg);


% function processSelectedPoint(handles,idx)
% global ImgOriginTempData crackOriginROI ImgOriginDataStructure
% 
% finalR = ImgOriginTempData.r(idx);
% finalC = ImgOriginTempData.c(idx);
% im = ImgOriginTempData.im;
% ShowImage(handles,1,im,[]);
% hold on;
% plot(finalC,finalR,'r+');
% rectangle('Position',crackOriginROI);
% hold off;
% 
% deltaX = finalC - crackOriginROI(1);
% deltaY = finalR - crackOriginROI(2);
% 
% ImgOriginDataStructure.deltaX = deltaX;
% ImgOriginDataStructure.deltaY = deltaY;


% --- Executes on button press in btn_Clear_Selection.
function btn_Clear_Selection_Callback(hObject, eventdata, handles)
% hObject    handle to btn_Clear_Selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global referenceCrackOrigin setupImg
referenceCrackOrigin = [];
getCrackOrigin(handles,setupImg);
