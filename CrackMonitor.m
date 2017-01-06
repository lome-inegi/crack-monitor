function varargout = CrackMonitor(varargin)
% CrackMonitor MATLAB code for CrackMonitor.fig
%      CrackMonitor, by itself, creates a new CrackMonitor or raises the existing
%      singleton*.
%
%      H = CrackMonitor returns the handle to a new CrackMonitor or the handle to
%      the existing singleton*.
%
%      CrackMonitor('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CrackMonitor.M with the given input arguments.
%
%      CrackMonitor('Property','Value',...) creates a new CrackMonitor or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CrackMonitor_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CrackMonitor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CrackMonitor

% Last Modified by GUIDE v2.5 10-May-2013 19:26:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CrackMonitor_OpeningFcn, ...
                   'gui_OutputFcn',  @CrackMonitor_OutputFcn, ...
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


% --- Executes just before CrackMonitor is made visible.
function CrackMonitor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CrackMonitor (see VARARGIN)

global listbx ctrl ImgProcDataStructure devId %ni_usb_device


set(hObject,'closerequestfcn',@CrackMonitor_CloseReq);

% Choose default command line output for CrackMonitor
handles.output = hObject;

% Centre the main screen
scrSize = get(0,'ScreenSize');
posUnits=get(hObject,'Units');
set(hObject,'Units','pixels');
figPos=get(hObject,'Position');
pos=[(scrSize(3)-figPos(3))/2 (scrSize(4)-figPos(4))/2 figPos(3) figPos(4)];
set(hObject,'Position',pos);
set(hObject,'Units',posUnits);


% Update handles structure
guidata(hObject, handles);
set(handles.axes2,'Visible','off');
set(handles.listbox1,'Visible','off');
set(handles.tPROI,'Visible','off');
set(handles.tOI,'Visible','off');
set(handles.slider1,'Visible','off');
set(handles.tMeasurement,'Visible','off');
listbx.handle = handles.listbox1;
listbx.str = {''};
fill_listbox ('Values');  
fill_listbox ('-------------------------------------'); 
ctrl = 1;

% Set ImgProcDataStructure defaults
ImgProcDataStructure.ClipLimit = 0.005;
ImgProcDataStructure.THRect = [30 2];
ImgProcDataStructure.GrayThresh = 1.00;
ImgProcDataStructure.StrelLR = 3;
ImgProcDataStructure.CloseActions = 2;
ImgProcDataStructure.SORemov = 80;

%ni_usb_device = '6008'; %Default USB DAQ
devId = '';
% set(gcf,'CloseRequestFcn',@my_closefcn);
% set(0,'DefaultFigureCloseRequestFcn',@my_closereq)
% 
% function my_closereq(src,evnt)
% % User-defined close request function 
% % delete(handles.figure1)
% clc; clear all; close all;
% delete vid;
% clear vid;




% UIWAIT makes CrackMonitor wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CrackMonitor_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --------------------------------------------------------------------

function File_Callback(hObject, eventdata, handles)
% hObject    handle to File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function File_Load_Callback(hObject, eventdata, handles)
global ValueSlice datastructure setupImg ctrl

 [filenames, pathname] = uigetfile({'*.jpg';'*.tif';'*.gif';'*.*'},'MultiSelect', 'on');
  if isequal(filenames, 0)
    return
 end
 
 filenames = cellstr(filenames);  
 names=zeros(1,length(filenames));
 for n = 1:length(filenames)
   afile = fullfile(pathname, filenames{n});
   [pathstr, name, ext] = fileparts(afile);
   img(:,:,n)= imread(afile);
   names(n)=str2num(name);
 end
 
    datastructure.names = names;
    datastructure.img = img;
    datastructure.captureimg = [];
   
ValueSlice = 1;
MaxSlices = length(filenames);

% ======= Activate Slider (if nr of files > 1) ========
if (MaxSlices==1)
set(handles.slider1,'Value',1,'Min',1,'Max',1,'SliderStep',...
[0 0]);
set(handles.slider1,'Visible','off');
else
set(handles.slider1,'Value',1,'Min',1,'Max',MaxSlices,...
'SliderStep', [1/(MaxSlices-1) 5/(MaxSlices-1)]);
set(handles.slider1,'Visible','on');
end

% 'ctrl' is a control variable. While equal to '1', no measurements can be
% performed. Only after 'Distance Calibration' will it turn '0'.
ctrl = 1;
string = horzcat('Original Images:', ' ', num2str(ValueSlice));
% set(handles.axes1,'Visible','on');
set(handles.tOI,'Visible','on','String',string);
% set(handles.slider1,'Visible','on');
setupImg = datastructure.img(:,:,ValueSlice);
ShowImage(handles,1,datastructure.img(:,:,ValueSlice),[]);

function File_Save_Callback(hObject, eventdata, handles)
% hObject    handle to File_Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ValueSlice datastructure 

[filename, pathname] = uiputfile({'*.jpg';'*.tif';'*.gif';'*.*'},'Save as');
if isequal(filename, 0)
	return
end
if datastructure.captureimg
	imwrite(datastructure.captureimg,fullfile(pathname, filename));
else
    imwrite(datastructure.img(:,:,ValueSlice),fullfile(pathname, filename));
end

function File_Close_Callback(hObject, eventdata, handles)
% hObject    handle to File_Close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ValueSlice datastructure 

img=datastructure.img;
sz=size(img,3);
if sz>1
    %img(:,:,min(ValueSlice,end):end) = img(:,:,min(ValueSlice+1,end):end);
    img(:,:,ValueSlice:sz-1) = img(:,:,ValueSlice+1:sz);
    img=img(:,:,1:sz-1);
    if ValueSlice>1 ValueSlice=ValueSlice-1; else ValueSlice=1; end
    datastructure.img=img;
else
    datastructure.img=zeros(size(img),'uint8');
end

% ======= Reset Slider, file set and axes ========
sz=sz-1;
if sz==0
    cla(handles.axes1,'reset');
	set(handles.axes1,'Visible','off');
    set(handles.tOI,'Visible','off');
elseif (sz==1)
    set(handles.slider1,'Value',1,'Min',1,'Max',1,'SliderStep',[0 0]);
    set(handles.slider1,'Visible','off');
    ShowImage(handles,1,datastructure.img(:,:,ValueSlice),[]);
else
    set(handles.slider1,'Value',ValueSlice,'Min',1,'Max',sz,...
    'SliderStep', [1/(sz-1) 1/(sz-1)]);
    set(handles.slider1,'Visible','on');
    ShowImage(handles,1,datastructure.img(:,:,ValueSlice),[]);
end

function File_Close_All_Callback(hObject, eventdata, handles)
% hObject    handle to File_Close_All (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global datastructure 

img=datastructure.img;
datastructure.img=zeros(size(img),'uint8');

% ======= Reset Slider, file set and axes ========
cla(handles.axes1,'reset');
set(handles.axes1,'Visible','off');
set(handles.tOI,'Visible','off');
set(handles.slider1,'Visible','off');

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)

global ValueSlice datastructure 

% ValueSlice = round(get(handles.slider1,'Value'));
ValueSlice = get(handles.slider1,'Value');
%  file(datastructure(ValueSlice).file,'Parent',handles.axes1,'CDataMapping','scaled');
%  set(handles.axes1, 'Visible', 'off', 'Units', 'pixels');
ShowImage(handles,1,datastructure.img(:,:,ValueSlice),[]);
string = horzcat('Original Images:', ' ', num2str(ValueSlice));
set(handles.tOI,'Visible','on','String',string);

function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1

% --- Executes on key press with focus on listbox1 and none of its controls.
function listbox1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

list_entries = get(handles.listbox1,'String');
index_selected = get(handles.listbox1,'Value');
data = list_entries(index_selected);
data(2:2:length(data))=[];                          %Eliminate separation lines

if  strcmp(eventdata.Key,'c') && strcmp(eventdata.Modifier,'control')
%     clipboard('copy', data);
    mat2clip(data);                                 %Clipboard() does not copy cell arrays
end
% a=4;

% --------------------------------------------------------------------
function File_data_export_Callback(hObject, eventdata, handles)
% hObject    handle to File_data_export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global crackLength datastructure crackdata

if isempty(datastructure)
    msgbox('No data to export.');
    return
end

[filenames, pathname] = uiputfile( {'*.xlsx';'*.xls';'*.txt';'*.*'},'Export crack data');
if isequal(filenames, 0)
   return
end
% filenames = cellstr(filenames);  % EDITED
afile = fullfile(pathname, filenames);

prompt = {'Enter data slot:'};
dlg_title = 'Spreadsheet definition';
num_lines = 1;
def = {'Slot 1'};
answer = inputdlg(prompt,dlg_title,num_lines,def);
A=[datastructure.names; datastructure.data];
% xlswrite(afile, A', char(answer),  'A1')
warning('off', 'MATLAB:xlswrite:AddSheet');
status = xlswrite(afile, A', char(answer),  'A1');
if status
    msgbox('Export completed');
else
    msgbox('Export failed');
end


% --- Executes on button press in pbExit.
function pbExit_Callback(hObject, eventdata, handles)
% hObject    handle to pbExit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

File_Exit_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function File_Exit_Callback(hObject, eventdata, handles)
% hObject    handle to File_Exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global halt
if (halt==0)
   msgbox('Test is running!');
   return;
end

selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return; 
end
% if ai 
%     stop(ai); 
%     delete(ai);
% end
% delete(handles.figure1)
% delete vid;
% clear vid;
 close all;%clear all; %inside closerequest

% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% % hObject    handle to figure1 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% Exit_Callback(hObject, eventdata, handles)
global vid
delete(hObject);
delete (vid);
% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
global vid
delete(hObject);
delete (vid);


% --------------------------------------------------------------------

function Settings_Callback(hObject, eventdata, handles)
% hObject    handle to Settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function Settings_Distance_Calibation_Callback(hObject, eventdata, handles)
% hObject    handle to Settings_Distance_Calibation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dist ctrl datastructure

if isempty(datastructure)
   msgbox('No camera configured. Please configure it in the Camera Setup.','Error'); 
   return; 
end

if datastructure.captureimg
    img=datastructure.captureimg;
else
    img=datastructure.img(:,:,1);
end
figure; imshow(img);hold on;

[Sy Sx]=size(img);
fft=abs(fftshift(fft2(img))); 
[yy xx] = find(fft==max(max(fft)));
% figure; imshow(log(fft),[]);hold on; plot(xx, yy,'r+'); %hold off;
[szy szx]=size(fft); r = [szx/2+20 szy/2-20 200 200];
Imax = imcrop(fft,r); %figure; imshow(log(Imax),[]);
[I]=max(max(Imax));
[yc,xc]=find(I==Imax,1,'first');
r=floor(r);xi=r(1);yi=r(2);%jsx=r(3);jsy=r(4);
xci=xi+xc;yci=yi+yc; plot(xci, yci,'r+');
DX = xci - xx;

msgbox('Choose 2 points from the figure for distance calibration','Point Selection');
uiwait(gcf);
% axes(gcf);
h = gca; 
% axes(handles.axes1);
% [x,y] = ginput(2);
% x1=x(1); x2=x(2);
% y1=y(1); y2=y(2);close;
[x1,y1] = ginput(1);
plot(x1, y1,'r+');
% x1=x(1); x2=x(2);
% y1=y(1); y2=y(2);
SPoint = [x1+48*Sx/DX y1];
plot(SPoint(1), SPoint(2),'r+'); hold off;
[x2,y2] = ginput(1);
close;
dist=sqrt((x1-x2)^2+(y1-y2)^2);
DistanceCalibration
ctrl = 0;


function Settings_Tester_Setup_Callback(hObject, eventdata, handles)
% hObject    handle to Settings_Tester_Setup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiwait(Tester_Settings)                             % input DAQ settings and image capture frequency

function Settings_Camera_Setup_Callback(hObject, eventdata, handles)
% hObject    handle to Settings_Camera_Setup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% global vid adaptor mycam
global vid datastructure setupImg
uiwait (MyCam);

% setVideo;
% GrabImage(handles,1);
if isempty(vid)
    return
end
setupImg = getsnapshot(vid);
datastructure.captureimg=setupImg;
datastructure.img=setupImg;
ShowImage(handles,1,setupImg,[]);


function Settings_Select_ROI_Callback(hObject, eventdata, handles)
% hObject    handle to Settings_Select_ROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Settings_Select_ROI_crackROI_Callback(hObject, eventdata, handles)
% hObject    handle to Settings_Select_ROI_crackROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rect datastructure
% img=datastructure.img;
if isempty(datastructure)
   msgbox('Not enough information for ROI selection.', 'Error' );
   return;
end

if datastructure.captureimg
    img=datastructure.captureimg;
else
    img=datastructure.img(:,:,1);
end

% MaxSlices=size(img,3);
% Img=im2double(img(:,:,MaxSlices)); 
% figure;imshow(img(:,:,1));
figure;imshow(img);
msgbox('Choose the ROI for the entire crack region','Input region');
uiwait(gcf);
rect = getrect; close;
% msgbox('Choose the ROI for the entire crack region','Input region','modal')
% rect = getrect(handles.axes1);


% --------------------------------------------------------------------
function Settings_Select_ROI_crackStartROI_Callback(hObject, eventdata, handles)
% hObject    handle to Settings_Select_ROI_crackStartROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)% --------------------------------------------------------------------
global rect2 setupImg templateImg datastructure

if isempty(datastructure)
   msgbox('Not enough information for ROI selection', 'Error' );
   return;
end

if datastructure.captureimg
    img=datastructure.captureimg;
else
    img=datastructure.img(:,:,1);
end

% img=datastructure.img;
% MaxSlices=size(img,3);
% Img=im2double(img(:,:,MaxSlices)); 
% figure;imshow(img(:,:,1));
figure;imshow(img);
msgbox('Choose the ROI for the beginning of the crack','Input region');
uiwait(gcf);
rect2 = getrect; close; %(handles.axes1);
templateImg=imcrop(setupImg, rect2);



% --------------------------------------------------------------------
function Images_Callback(hObject, eventdata, handles)
% hObject    handle to Images (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function Images_GrabImage_Callback(hObject, eventdata, handles)
% hObject    handle to Images_GrabImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global vid datastructure setupImg

% setVideo;
% GrabImage(handles,1);
if isempty(vid)
    msgbox('No video source selected');
   return; 
end
try
    setupImg = getsnapshot(vid);
catch
    msgbox('Video capture failed.');
   delete(vid);
   %clear vid;
   return;
end
datastructure.captureimg=setupImg;
datastructure.img=setupImg;
% setupImg=datastructure.captureimg;

ShowImage(handles,1,setupImg,[]);
% imwrite(setupImg,'ROI.tif','WriteMode','append');
% delete(vid);
% clear vid;

function Settings_Analyse_pre_crack_Callback(hObject, eventdata, handles)
% hObject    handle to Settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function Settings_Analyse_pre_crack_Morpho_settings_Callback(hObject, eventdata, handles)
% hObject    handle to Settings_Analyse_pre_crack_Morpho_settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ImgProcDataStructure SEImg
if isempty(SEImg)
    msgbox('No strutural element defined, please go to Determine Structure.', 'Error'); 
    return;
end
uiwait (CrkOpt);
% DS=ImgProcDataStructure;
% i=5;

% --------------------------------------------------------------------
function Settings_Analyse_pre_crack_Images_PCAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to Settings_Analyse_pre_crack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global datastructure ctrl rect rect2 pix2mm templateImg 

if isempty(datastructure)
   msgbox('Not enough information for pre-crack processing', 'Error');
   return;
end

img=datastructure.img;
MaxImg=size(img,3);
imgC = im2double(img(:,:,MaxImg)); 
figure; imshow(imgC), hold on

% hr = rectangle('Position',rect, 'LineWidth',1, 'EdgeColor','r');
h = imrect(gca, rect);
addNewPositionCallback(h,@(p) crackAnalysis(imgC, p));
fcn = makeConstrainToRectFcn('imrect',get(gca,'XLim'),get(gca,'YLim'));
setPositionConstraintFcn(h,fcn);

% crackAnalysis(imgC, rect);


% --------------------------------------------------------------------
function Images_Analysis_Callback(hObject, eventdata, handles)
% hObject    handle to Images_Analysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global datastructure ctrl rect rect2 pix2mm templateImg crackOrigin SEImg

if (isempty(datastructure))
    msgbox('No images to analyse.','Error');
    return; 
end
if isempty(pix2mm)
    msgbox('Distance calibration not performed. Please go to the Distance Calibration dialog.','Error');
    return; 
end
if (isempty(rect2) || isempty(rect))
    msgbox('Region of Interest not set. Please go to the ROI Settings dialogs.','Error');
    return; 
end
if isempty(SEImg)
    msgbox('No strutural element defined, please go to Determine Structure.','Error');
    return;
end


%Execution control
ctrl=0;
%Images
img=datastructure.img;
MaxSlices=size(img,3);
crackdata=zeros(1,MaxSlices);
% names=zeros(1,MaxSlices);
names=datastructure.names;

%Crack start algorithm constants for the Harris attribute search 
% sigma = 2;
% thresh = 0.05;
% radius = 1;
% disp = 1;
% I=0;

%Structuring elements for morphological file processing tasks below
% seh=[0 0 0; 1 1 1; 0 0 0];
% sev=[0 1 0; 0 1 0; 0 1 0];
% seSBallUnderMLab = strel('ball', 3, 3, 0);
% seLBallUnderMLab = strel('ball', 10, 5, 0);
% seLBallOverMLab = strel('ball', 10, -5, 0);
% SESBallOverMLab = strel('ball', 3, -3, 0);

if isequal(ctrl,0)  
    cla(handles.axes2,'reset');
    set(handles.axes2,'Visible','on',...
                    'Color',[0 0 0],...
                    'xtick',[],'ytick',[]);
    set(handles.listbox1,'Visible','on');
    set(handles.tPROI,'Visible','on');
    set(handles.tMeasurement,'Visible','on');
    nowStr = ['Analysis run on: ' char(datetime('now'))];
    fill_listbox([nowStr]);
    fill_listbox('--------------------------------'); 
else    %if isequal(pix2mm,[])    %== []isequal(pix2mm,'')    
    h = warndlg('You have to set Distance Calibration first!');
    uiwait(h)
%else
    return;
end

for i=1:MaxSlices
    imgC = im2double(img(:,:,i)); 
    
    % The cracks can run to either side, hence...
    sz=size(imgC);
    if rect2(1)>sz(2)/2
        % Crack to the left side
        difXX = rect(1) + rect(3) - (rect2(1) + rect2(3));
        rect1 = [rect2(1)-rect2(3) rect(2) 2*rect2(3)+difXX rect2(2)+2*rect2(4)-rect(2)];
    else
        %Crack to the right side
        rect1 = [rect(1) rect(2) rect2(1)-rect(1)+2*rect2(3) rect2(2)-rect(2)+2*rect2(4)];
    end
    
    % Find the crack start within 'rect1' ROI
    imgROI = imcrop(img(:,:,i), rect1); 
% 	[cim, RC, I] = harris(im2double(imgC), sigma, thresh, radius, disp, rect2);
%   A = RC(I,:);
    cc = normxcorr2(templateImg,imgROI); 
    [max_cc, imax] = max(abs(cc(:)));
    [ypeak, xpeak] = ind2sub(size(cc),imax(1));
    corr_offset = [ (ypeak-size(templateImg,1)) (xpeak-size(templateImg,2)) ];

    XX=rect1(1)+corr_offset(2);                  
    YY=rect1(2)+corr_offset(1)+rect2(4);
    
    crackOrigin=[YY XX];
%     figure; imshow(imgC), hold on
%     plot(XX, YY,'r+'), title('corners detected');
%     rectangle('Position',rect1, 'LineWidth',1, 'EdgeColor','r');

    
	[crckbin, lengthmm] = crackLength(imgC, rect, crackOrigin, pix2mm, false);
    crackdata(i)=lengthmm;
%     ShowImage(handles,2,crckbin,[]);
%     names(i)=datastructure.names(i);
    plot(handles.axes2,names, crackdata,'-.k');

%      ShowImage(handles,2,bw,[]);
   % imgCrack = imgC<101;
    % imgCrackMedian = medfilt2(imgCrack, [3 3]);
    % imgLabel = bwlabel(imgCrackMedian);
    % stats = regionprops(imgLabel, 'all');
    % for i=1:length(stats), AreaArray(i) = stats(i).Area; end
    % idxMax = find(max(AreaArray)==AreaArray);
    % [y x]= find(imgLabel==idxMax);
    % axes(handles.axes2);
    % hold on
    % plot(x,y,'b')
    % plot([x(1) x(length(x))],[y(1) y(1)],'r*');
    % plot(x(1):x(length(x)),y(1),'r');
    % hold off
    % Write in ListBox
    fill_listbox (['Distance in X axis     = ' num2str(lengthmm) ' mm']);
    % fill_listbox (['Perimeter     = ' num2str(stats(idxMax).Perimeter) ' px']);
    % fill_listbox (['Area            = ' num2str(stats(idxMax).Area) ' px2']);
    % fill_listbox (['Projection  angle in XX Axis = ' num2str(angle) ' degrees']);
    fill_listbox ('--------------------------------');  
end
datastructure.data=crackdata;
% datacursormode(handles);
% ctrl =1;




% --------------------------------------------------------------------
function Test_Callback(hObject, eventdata, handles)
% hObject    handle to Test (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function Start_Test_Callback(hObject, eventdata, handles)
% hObject    handle to Start_Test (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global testerfreq testermag cyclesperimage vid halt Img datastructure...
       rect rect2 pix2mm templateImg SEImg devId %ni_usb_device

% img=datastructure.img;
% MaxSlices=size(img,3);
% crackdata=zeros(1,MaxSlices);
% sigma = 2;
% thresh = 0.05;
% radius = 1;
% disp = 1;

%%%%%Here we should have a verification. If some variable is not set, warn
%%%%%the user and exit
if  isempty(testerfreq) || isempty(cyclesperimage)
    msgbox('Tester parameters not set. Please go to the Tester Settings dialog.','Error');
    return; 
end

if  isempty(rect2)
    msgbox('Region of Interest not set. Please go to the ROI Settings dialogs.','Error');
    return; 
end

if isempty(pix2mm)
    msgbox('Distance calibration not performed. Please go to the Distance Calibration dialog.','Error');
    return; 
end

if isempty(SEImg)
    msgbox('No strutural element defined, please go to Determine Structure.','Error');
    return;
end

if isempty(vid) || ~isvalid(vid)
    msgbox('Video not available. Please go to the Camera Settings dialog.','Error');
   return; 
end
%%%%%
%%%%%
setVideo;

halt=0;
nrdispcycles = 5;
% Sample rate for DAQ. The global "testerfreq" is updated in "CountCycles"
DAQsamplerate = 100*testerfreq;
% Number of samples necessary to count the required # cycles
numberofsamples = floor(DAQsamplerate*cyclesperimage/testerfreq);
% Data array to display. nrdispcycles data chunks
data=zeros(1,nrdispcycles*numberofsamples);
% Data chunk array for each cycle
datachunk=zeros(1,numberofsamples);
l=length(datachunk);
set(handles.axes2,'DataAspectRatioMode','manual');
set(handles.listbox1,'String','');
set(handles.listbox1,'Visible','on');

i = 0;
j = 0;
k=1;
TotalTime=0;
TotalCycles=0;
newnumberofsamples = numberofsamples;
elapseddatapoints = 0;

debug=false;
%devId = find_ni_usb(ni_usb_device);
devId = selectNIdevice();
if strcmp(devId,'')
    debugAns=questdlg('No NI DAQ selected, do you want to do a debug session?');
    if (~strcmp(debugAns,'Yes'))
       return; 
    else
        debug=true;
    end
end

tic
% prevA=[rect2(2)+rect2(4) rect2(1)];
while halt==0
% 	if i == 0 tic; end
    if ~debug
        datachunk = CountCycles(true,DAQsamplerate,newnumberofsamples);
        data(i*l+1:(i+1)*l)=0;
        data(i*l+1+elapseddatapoints:(i+1)*l) = datachunk;
    else
        pause(cyclesperimage/testerfreq);
    end
%     plot(handles.axes2,data);
    j=j+cyclesperimage;
    GrabImage(handles,j);
% ET2=toc
    if i<nrdispcycles i=i+1; end
    if i==nrdispcycles 
        data(1:(nrdispcycles-1)*l) = data(l+1:nrdispcycles*l);
        i=i-1;
    end
% 	[cim, RC, I] = harris(im2double(Img), sigma, thresh, radius, disp, rect2);
% 	A = harris(im2double(Img), sigma, thresh, radius, rect2);

%     cc = normxcorr2(templateImg,Img); 
%     [max_cc, imax] = max(abs(cc(:)));
%     [ypeak, xpeak] = ind2sub(size(cc),imax(1));
%     corr_offset = [ (ypeak-size(templateImg,1)) (xpeak-size(templateImg,2)) ];
%     XX=corr_offset(2); YY=rect2(4)+corr_offset(1);

    imgC = im2double(Img); 
    
% The cracks can run to either side, hence...
sz=size(imgC);
if rect2(1)>sz(2)/2
    % Crack to the left side
    difXX = rect(1) + rect(3) - (rect2(1) + rect2(3));
    rect1 = [rect2(1)-rect2(3) rect(2) 2*rect2(3)+difXX rect2(2)+2*rect2(4)-rect(2)];
else
    %Crack to the right side
    rect1 = [rect(1) rect(2) rect2(1)-rect(1)+2*rect2(3) rect2(2)-rect(2)+2*rect2(4)];
end
    
    % Find the crack start within 'rect1' ROI
    imgROI = imcrop(Img, rect1); 
    cc = normxcorr2(templateImg,imgROI); 
    [max_cc, imax] = max(abs(cc(:)));
    [ypeak, xpeak] = ind2sub(size(cc),imax(1));
    corr_offset = [ (ypeak-size(templateImg,1)) (xpeak-size(templateImg,2)) ];
    XX=rect1(1)+corr_offset(2);                  
    YY=rect1(2)+corr_offset(1)+rect2(4);
    A=[YY XX];
    if k<25                                          % Show detected corner on the first 5 takes
%         figure; imshow(Img), hold on
        plot(XX, YY,'r+'), title('corners detected'); %hold off;
    end
%     A = RC(I,:)
	[crckbin, lengthmm] = crackLength(Img, rect, A, pix2mm, true);
    hold off;
%     ShowImage(handles,2,crckbin,[]);

    crackdata(k)=lengthmm;
    names(k)=k*cyclesperimage;
    plot(handles.axes2,names, crackdata,'-+k');
    k=k+1;

    ET=toc;
    tic
%   Use the time elapsed in calculations to start counting cycles ahead so
%   the #cycles remains constant 
    elapsedcycles = ET*testerfreq - cyclesperimage;
    TotalTime = TotalTime + ET;
    TotalCycles = TotalCycles + floor(ET*testerfreq);
    if (elapsedcycles > 0) && (i > 1)
        newnumberofsamples = floor(DAQsamplerate*(cyclesperimage - elapsedcycles)/testerfreq);
        elapseddatapoints = numberofsamples - newnumberofsamples;
    else
        newnumberofsamples = numberofsamples;
        elapseddatapoints = 0;
        elapsedcycles=0;
    end
    fill_listbox ('clc');
%     fill_listbox (['      Elapsed time = ' num2str(ET,'%4.2f') ' s']);
    fill_listbox (['         Frequency = ' num2str(testerfreq,'%4.2f') ' Hz']);
    fill_listbox (['         Magnitude = ' num2str(testermag,'%4.2f') ' V']);
    fill_listbox (['Elapsed #cycles = ' num2str(elapsedcycles,'%6.0f')]);
    fill_listbox (['  New #samples = ' num2str(newnumberofsamples,'%6.0f')]);
    fill_listbox (['        Total time = ' num2str(TotalTime,'%6.0f')]);
    fill_listbox (['           #cycles = ' num2str(TotalCycles,'%6.0f')]);
	fill_listbox (['Distance in X axis = ' num2str(lengthmm) ' mm']);
end

datastructure.data=crackdata;
datastructure.names=names;
msgbox('Test completed.');


% --------------------------------------------------------------------
function Stop_Test_Callback(hObject, eventdata, handles)
% hObject    handle to Stop_Test (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global halt vid
% closedevice(vid);

halt=1;

function GrabImage(handletofigure,j)
global vid Img datastructure cyclesperimage rect
% tic
% snapshot = getsnapshot(vid);
% imwrite(snapshot,['TestImages\File',num2str(j),'.jpg']);
if isempty(vid)
    return;
end
trigger(vid);
def= getdata(vid,5,'single');
[Index, F] = BestFocusedImage(def);
if (F < 1.13)   % If the best focused image is not very good, try to sharpen it
                % Maybe let the user define the limit value?
                % TODO: Select a good limit value.
    H = padarray(2,[1 1]) - fspecial('gaussian'); % Generate unsharpen filter
    tempImg = imfilter(def(:,:,Index),H); % Apply filter
    newF = fmeasure(tempImg,rect); % Calculate new Focus measurement
    if  newF > F % If it is an improvement
        def(:,:,Index) = tempImg; % Replace
        %disp(['New value: ',num2str(newF)]);
    end
end
datastructure.captureimg=def(:,:,Index);
% for i=1:5
% imwrite(def(:,:,i),['TestImages\',num2str(j+i),'.jpg']);
% end
imwrite(def(:,:,Index),[num2str(j),'.jpg']);
Img=def(:,:,Index);
ShowImage(handletofigure,1,def(:,:,Index),[]); hold on;
% imwrite(Img,['TestImages\',num2str(j),'.jpg']);
% ET2=toc
   
function datachunk = CountCycles(flag,DAQsamplerate,numberofsamples)
global testerfreq testermag cyclesperimage minimumpeakheight halt devId %ni_usb_device
% tic
if strcmp(devId,'')
   return; 
end
s = [];
try
   s = daq.createSession('ni');
catch
   disp('Unable to use NI interface. Support may require installation of the driver via the Support Package Installer.');
   return;
end

ch = addAnalogInputChannel(s,devId,'ai0','Voltage');
ch(1).TerminalConfig = 'Differential';
ch(1).Range = [-10.0 10.0];
s.Rate = DAQsamplerate;
s.DurationInSeconds = numberofsamples/DAQsamplerate;
%addchannel(ai,0);                                   % add analog input channel 0
%set(ai, 'InputType', 'Differential'); 
%set(ai, 'SampleRate', DAQsamplerate);               % in Hertz
%set(ai, 'SamplesPerTrigger', numberofsamples);  

[data, timestamps] = startForeground(s);
%start(ai);
%data = getdata(ai);
peaks = findpeaks(data,'MINPEAKHEIGHT',minimumpeakheight,'NPEAKS',cyclesperimage);

% Stop the test if there's no data on the DAQ
if isempty(peaks)
    halt=1;
end

if flag
%	Zero-pad to increase #bins and frequency resolution
    data1=wextend('1D','zpd',data,32*numberofsamples,'r');
%	data1=data1.*flattopwin(length(data1));
%	data1=data1.*hann(numberofsamples+2*512);
    [f,mag] = daqdocfft(data1,DAQsamplerate,33*numberofsamples);
    [ymax,maxindex]= max(mag);

%   Em alternativa... 
%   Y = fft(data1);
%   [~,index] = max(abs(Y(1:numberofsamples/2+1)));
%   freq = 0:(DAQsamplerate/numberofsamples):DAQsamplerate/2;
    
%   Updates the global variable "testerfreq"
    testerfreq=f(maxindex);    %freq(index)
	testermag=mean(peaks);   %mag(maxindex);    %magnitude(index)
    minimumpeakheight=0.95*testermag;
end

datachunk=data;
% if halt
    %stop(ai);
    %delete(ai);
    release(s);
    delete(s);
% end
% ET2=toc

% ________________________________________________
function [f,mag] = daqdocfft(data,Fs,blocksize)
%	[F,MAG]=DAQDOCFFT(X,FS,BLOCKSIZE) calculates the FFT of X
%	using sampling frequency FS and the SamplesPerTrigger provided in BLOCKSIZE
xfft = abs(fft(data));
%	Avoid taking the log of 0.
index = find(xfft == 0);
xfft(index) = 1e-17;

mag = 20*log10(xfft);
mag = mag(1:floor(blocksize/2));
f = (0:length(mag)-1)*Fs/blocksize;
f = f(:);

function setVideo
global vid src
%if isempty(vid)
%   return; 
%end
set(vid, 'ReturnedColorSpace', 'grayscale');
set(vid,'FramesPerTrigger',5,'TriggerRepeat',inf);
if ~isrunning(vid)
triggerconfig(vid,'Manual');
end
% Access the device's video source.
% src = getselectedsource(vid);
% Set the focus value established at the camera setup
% set(src,'FocusMode','Manual');
% src.Focus=focusvalue;
% Determine the device specific frame rates (frames per second) available.
% frameRates = get(src, 'FrameRate');
% Configure the device's frame rate to the highest available setting.
% src.FrameRate = frameRates{1};
%actualRate = str2num( frameRates{1} )
if isrunning(vid)
   stop(vid); 
end
start(vid);
%trigger(vid);

function ShowImage(handles,AxesType,Img,map)
axesn=strcat('axes',num2str(AxesType));
[SizeY SizeX]=size(Img);
Figpos = get(handles.figure1,'Position');
pos=get(handles.(axesn),'Position');
% Outpos=get(handles.(axesn),'OuterPosition');
switch (AxesType)
	case 1
        pos(4) = pos(3)*SizeY/SizeX;
        pos(2) = Figpos(4)-pos(4)-25;
    case 2
    % Se SizeY ímpar, diminui 1 px
    if mod(SizeY,2)~=0 SizeY=SizeY-1; end
    % Cria nova imagem com a largura de "Img" e 256px de altura
    imgBorder=zeros(128-SizeY/2, SizeX); 
    % Copia "img" para o centro da nova imagem
%     imgBorder((256-SizeY)/2+1:(256+SizeY)/2,:)=Img(1:SizeY,:);
    Img = vertcat(imgBorder, Img, imgBorder);
%     Img = [imgBorder; Img];
%     Img = [Img; imgBorder];
end
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
         
function fill_listbox (string2write)
global listbx
if strcmp(string2write,'clc') 
    listbx.str = [];
    set(listbx.handle,'String',listbx.str);
    result = 0 ;
    return
end
listbx.str{end+1} = string2write;
set(listbx.handle,'String',listbx.str);

function [crckbin, lengthmm] = crackLength(crckimg, cracROI, crackoriginlocation, pix2mm, showBoundingBox)

if (~islogical(showBoundingBox))
    showBoundingBox = false;
end
    
[crckbin, lengthpix, BoundingBox] = processCrack(crckimg, cracROI, crackoriginlocation, true);
    
lengthmm = lengthpix/str2double(pix2mm); 
if (showBoundingBox)
    BoundingBox(1) = BoundingBox(1)+ cracROI(1);
    BoundingBox(2) = BoundingBox(2)+ cracROI(2);
    rectangle('Position',BoundingBox, 'LineWidth',1, 'EdgeColor','r');
end
hold off;

% function crackAnalysis(crckimg, cracROI, crackOrigin, pix2mm)
% global SEImg
% 
% %Structuring elements for morphological file processing tasks below
% SESBallOverMLab = strel('ball', 2, -2, 0);
% 
% seh = [0 0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0 0;...
%        0 0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0 0;...
%        0 0 0 0 0 0 0 0 0 0 0 0 0; 1 1 1 1 1 1 1 1 1 1 1 1 1;...
%        1 1 1 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1 1 1 1;...
%        0 0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0 0;...
%        0 0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0 0;...
%        0 0 0 0 0 0 0 0 0 0 0 0 0];
% 
% X=crackOrigin(2); 
% Y=crackOrigin(1);
% sz=size(crckimg);
% % Again, the cracks can run to either side...
% if X>sz(2)/2
%     cracROI(3)=X-cracROI(1);                        %Crack to the left side
%     toRight=0;
% else
%     cracROI(3)=cracROI(1)+cracROI(3)-X;             %Crack to the right side
%     cracROI(1)=X;
%     toRight=1;
% end    
% 
% imgC = im2double(imcrop(crckimg, cracROI));
% imwrite(crckimg,'ROI.tif','WriteMode','append');
% imwrite(imgC,'ROI.tif','WriteMode','append');
% 
% imCl = imclose(imgC,SESBallOverMLab);
% imOp = imopen(imCl,SESBallOverMLab);
% T = imgC - min(imOp,imgC);
% % imwrite(T,'ROI.tif','WriteMode','append');
% imAT = adapthisteq(T,'ClipLimit',0.01);
% % imwrite(imAT,'ROI.tif','WriteMode','append');
% % imTopH=imtophat(imAT,se);
% % imwrite(imTopH,'ROI.tif','WriteMode','append');
% %     
% Th=1.0;
% level = Th*graythresh(imAT);
% bw = im2bw(imAT,level);
% % imwrite(bw,'ROI.tif','WriteMode','append');
% % se = strel('line',12,0);
% se = strel(seh);
% bw=imclose(bw,se);
% crckbin=bwareaopen(bw,100);
% imwrite(crckbin,'ROI.tif','WriteMode','append');
% 
% %Crack length calculation
% %Area Statistics: find the largest connected components area -
% %represents the crack. Next, find the bounding box of this area and
% %return its length - the crack projection on the xx axis
% stats = regionprops(crckbin, 'Area','BoundingBox','Extrema');
% AreaArray=zeros(1,length(stats));
% for j=1:length(stats), AreaArray(j) = stats(j).Area; end
% idxMax = find(max(AreaArray)==AreaArray);
% 
% if toRight
%     TipXX = stats(idxMax).Extrema(3); TipYY = stats(idxMax).Extrema(11);
%     RootXX = X - cracROI(1); RootYY = Y - cracROI(2);
%     lengthpix = TipXX - RootXX; heightpix = abs(RootYY - TipYY);
%     BB = [RootXX RootYY-heightpix lengthpix heightpix];
% else
%     TipXX = stats(idxMax).Extrema(8); TipYY = stats(idxMax).Extrema(16);
%     RootXX = X - cracROI(1); RootYY = Y - cracROI(2);
%     lengthpix = RootXX - TipXX; heightpix = RootYY - TipYY;
%     BB = [RootXX-lengthpix RootYY-heightpix lengthpix heightpix];
% end
% 
% % Extract a structuring element, SEImg, from the initial crack.
% % heightpix=stats(idxMax).BoundingBox(4)+stats(idxMax).BoundingBox(2)-(Y-cracROI(2));
% % BB=[(X-cracROI(1)) (Y-cracROI(2)) lengthpix heightpix];
% % BB=[stats(idxMax).BoundingBox(1) stats(idxMax).BoundingBox(2) lengthpix heightpix];
% thin=imcrop(crckbin, BB);
% imwrite(thin,'ROI.tif','WriteMode','append');
% thin=bwmorph(thin,'thin', Inf);
% imwrite(thin,'ROI.tif','WriteMode','append');
% [y,x]=find(thin);y=max(y)-y;sy=size(thin,1);sx=size(x,1);
% % plot(x,y);%hold on;
% r=robustfit(x,y);
% % r = regress(y,[ones(size(x),1) x]);
% SEImg=zeros(sy,sx);line=zeros(1,sx);
% for i=1:sx
%    line(i)=ceil(r(1)+r(2)*i); if sy-line(i)<=0 line(i)=sy-1; end
%    SEImg(sy-line(i),i)=1;
% end
% % l=11; h=l; rect=[sx-l+1 sy-h+1 l h];
% l=19; h=l; % min(sy,l) 
% rect=[sx/2-l/2 sy/2-h/2 l h];
% SEImg=imcrop(SEImg, rect);
% figure; imshow(SEImg);
    
function crackAnalysis(crckimg, cracROI)
global SEImg

%Structuring elements for morphological file processing tasks below
SESBallOverMLab = strel('ball', 2, -2, 0);

seh = [0 0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0 0;...
       0 0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0 0;...
       0 0 0 0 0 0 0 0 0 0 0 0 0; 1 1 1 1 1 1 1 1 1 1 1 1 1;...
       1 1 1 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1 1 1 1;...
       0 0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0 0;...
       0 0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0 0;...
       0 0 0 0 0 0 0 0 0 0 0 0 0];

% X=crackOrigin(2); 
% Y=crackOrigin(1);
% sz=size(crckimg);
% % Again, the cracks can run to either side...
% if X>sz(2)/2
%     cracROI(3)=X-cracROI(1);                        %Crack to the left side
%     toRight=0;
% else
%     cracROI(3)=cracROI(1)+cracROI(3)-X;             %Crack to the right side
%     cracROI(1)=X;
%     toRight=1;
% end    

imgC = im2double(imcrop(crckimg, cracROI));
% imwrite(imgC,'ROI.tif','WriteMode','append');

imCl = imclose(imgC,SESBallOverMLab);
imOp = imopen(imCl,SESBallOverMLab);
T = imgC - min(imOp,imgC);
% imwrite(T,'ROI.tif','WriteMode','append');
imAT = adapthisteq(T,'ClipLimit',0.01);
% imwrite(imAT,'ROI.tif','WriteMode','append');
% imTopH=imtophat(imAT,se);
% imwrite(imTopH,'ROI.tif','WriteMode','append');
%     
Th=1.0;
level = Th*graythresh(imAT);
bw = im2bw(imAT,level);
% imwrite(bw,'ROI.tif','WriteMode','append');
% se = strel('line',12,0);
se = strel(seh);
bw=imclose(bw,se);
crckbin=bwareaopen(bw,100);
% imwrite(crckbin,'ROI.tif','WriteMode','append');

%Crack length calculation
%Area Statistics: find the largest connected components area -
%represents the crack. Next, find the bounding box of this area and
%return its length - the crack projection on the xx axis
stats = regionprops(crckbin, 'Area','BoundingBox','Extrema');
AreaArray=zeros(1,length(stats));
for j=1:length(stats), AreaArray(j) = stats(j).Area; end
idxMax = find(max(AreaArray)==AreaArray);

% if toRight
%     TipXX = stats(idxMax).Extrema(3); TipYY = stats(idxMax).Extrema(11);
%     RootXX = X - cracROI(1); RootYY = Y - cracROI(2);
%     lengthpix = TipXX - RootXX; heightpix = abs(RootYY - TipYY);
%     BB = [RootXX RootYY-heightpix lengthpix heightpix];
% else
%     TipXX = stats(idxMax).Extrema(8); TipYY = stats(idxMax).Extrema(16);
%     RootXX = X - cracROI(1); RootYY = Y - cracROI(2);
%     lengthpix = RootXX - TipXX; heightpix = RootYY - TipYY;
%     BB = [RootXX-lengthpix RootYY-heightpix lengthpix heightpix];
% end

% Extract a structuring element, SEImg, from the initial crack.
% heightpix=stats(idxMax).BoundingBox(4)+stats(idxMax).BoundingBox(2)-(Y-cracROI(2));
% BB=[(X-cracROI(1)) (Y-cracROI(2)) lengthpix heightpix];
% BB=[stats(idxMax).BoundingBox(1) stats(idxMax).BoundingBox(2) lengthpix heightpix];
% thin=imcrop(crckbin, BB);
% imwrite(thin,'ROI.tif','WriteMode','append');
% thin=bwmorph(thin,'thin', Inf);
BB = stats(idxMax).BoundingBox;
BBox = imcrop(crckbin,BB);
% imwrite(BB,'ROI.tif','WriteMode','append');
thin=bwmorph(BBox,'thin', Inf);
% imwrite(thin,'ROI.tif','WriteMode','append');
[y,x]=find(thin);y=max(y)-y;
sy=size(thin,1);
sx=size(x,1);
r=robustfit(x,y);
% r = regress(y,[ones(size(x),1) x]);
SEImg=zeros(sy,sx);line=zeros(1,sx);
for i=1:sx
   line(i)=ceil(r(1)+r(2)*i); if sy-line(i)<=0 line(i)=sy-1; end
   SEImg(sy-line(i),i)=1;
end
% l=11; h=l; rect=[sx-l+1 sy-h+1 l h];
l=19; h=l; % min(sy,l) 
rect=[sx/2-l/2 sy/2-h/2 l h];
SEImg=imcrop(SEImg, rect);
imwrite(SEImg,'ROI.tif','WriteMode','append');
% figure; 
% imshow(SEImg);
imagesc(1:100,1:100,SEImg);

function RC = harris(im, sigma, thresh, radius, rect)
    dx = [-1 0 1; -1 0 1; -1 0 1]; % Derivative masks
    dy = dx';
    Ix = conv2(im, dx, 'same');    % Image derivatives
    Iy = conv2(im, dy, 'same');    
    % Generate Gaussian filter of size 6*sigma (+/- 3sigma) and of
    % minimum size 1x1.
    g = fspecial('gaussian',max(1,fix(6*sigma)), sigma);
    
    Ix2 = conv2(Ix.^2, g, 'same'); % Smoothed squared image derivatives
    Iy2 = conv2(Iy.^2, g, 'same');
    Ixy = conv2(Ix.*Iy, g, 'same');

    cim = (Ix2.*Iy2 - Ixy.^2)./(Ix2 + Iy2 + eps); % My preferred  measure.
    sze = 2*radius+1;                   % Size of mask.
    mx = ordfilt2(cim,sze^2,ones(sze)); % Grey-scale dilate.
    cim = (cim==mx)&(cim>thresh);       % Find maxima.

    [r,c] = find(cim);                   % Find row,col coords.
    r=(r>rect(2) & r<rect(2)+rect(4)).*r;                  % ROI limits.
    c=(c>rect(1) & c<rect(1)+rect(3)).*c;
    RC=zeros(length(r),2); %I=1;J=1;
    for i=1:size(r)
        if (r(i)>0 && c(i)>0) 
           RC(i,:)=[r(i) c(i)];
       end
    end
    I=find(RC(:,1))
	xy=[RC(I,1) RC(I,2)]
	Ixmax=find(xy==max(xy(:,1)))
	RC=xy(Ixmax,:)
%     figure; imshow(im), hold on
%     plot(RC(1,2),RC(1,1),'r+'), title('corners detected');

function [Index, F] = BestFocusedImage(Imgset)
global rect
% Nr of image files in Imageset
filesperset =  size(Imgset, ndims(Imgset));
F = 0;
FM=zeros(filesperset,1);

for f = 1:filesperset
    Img = Imgset(:,:,f);
    FM(f) = fmeasure(Img, rect);
    if FM(f) > F
        F = FM(f);
        Index = f;
    end
end
%disp(['Best focused image: ', num2str(F)]);

 function FM = fmeasure(Image, ROI)
% HELM - Helmli's mean method (Helmli2001) 

if ~isempty(ROI)
    Image = imcrop(Image, ROI);
end

WSize = 15; % Size of local window

MEANF = fspecial('average',[WSize WSize]);
U = imfilter(Image, MEANF, 'replicate');
R1 = U./Image;
R1(Image==0)=1;
index = (U>Image);
FM = 1./R1;
FM(index) = R1(index);
FM = mean2(FM);


function CrackMonitor_CloseReq(src,callbackdata)
global halt vid
if (halt==0)
   msgbox('Test is running!');
   return;
end

% Once the video input object is no longer needed, delete
% it and clear it from the workspace.
if (~isempty(vid))
stop(vid);
stoppreview(vid);
end
delete(vid);
clear vid;
clear all;
delete(gcf)