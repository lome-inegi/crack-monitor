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

% Last Modified by GUIDE v2.5 06-Apr-2017 08:31:26

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

global listbx ImgProcDataStructure ImgOriginDataStructure triggerPhase...
    triggerDelay saveOriginFigures continuousRefOriginUpdate myFolder


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

% Set ImgProcDataStructure defaults
ImgProcDataStructure.ClipLimit = 0.005;
ImgProcDataStructure.THRect = [30 2];
ImgProcDataStructure.GrayThresh = 1.00;
ImgProcDataStructure.StrelLR = 3;
ImgProcDataStructure.CloseActions = 2;
ImgProcDataStructure.SORemov = 80;

saveOriginFigures = false;
set(handles.outputOriginFigs, 'Checked', 'off');

continuousRefOriginUpdate = false;
set(handles.continuousRefOrigin, 'Checked', 'off');

if (isempty(triggerPhase))    
    triggerPhase = pi/2; % rad
end

if (isempty(triggerDelay))
    triggerDelay = 0.1; % s
end

if (isempty(ImgOriginDataStructure))
   ImgOriginDataStructure.originRadius = 5;
   ImgOriginDataStructure.radius = 0.5;
   ImgOriginDataStructure.sigma = 1;
end

% Get the name of the user who logged in to the computer.
userProfile = getenv('USERPROFILE');
% Create a string to the "My Documents" folder of this Windows user:
myFolder = sprintf('%s\\Documents\\CrackMonitor\\', userProfile);
if (exist(myFolder,'dir') ~= 7)
    mkdir(myFolder);
end


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

% --------------------------------------------------------------------
function File_Load_Callback(hObject, eventdata, handles)
global ValueSlice datastructure setupImg

%% Get files
[filenames, pathname] = uigetfile({'*.jpg';'*.tif';'*.gif';'*.*'},'MultiSelect', 'on');
if isequal(filenames, 0)
    return
end

%% Setup waitbar
h = waitbar(0,'Loading...');

%% Pre-allocate variables
filenames = cellstr(filenames);  
names=zeros(1,length(filenames));
firstFileInfo = imfinfo(fullfile(pathname, filenames{1}));
img = zeros(firstFileInfo(1).Height,firstFileInfo(1).Width,length(filenames),'uint8');

%% Main loop
lastUpdate = 0; % Limit the number of waitbar updates
for n = 1:length(filenames)
    %% Update waitbar
    try
        toUpdate = n/(length(filenames));
        if (toUpdate > lastUpdate + 0.1) % Never update with a change smaller than 10% -> speed-up
            waitbar(toUpdate,h,['Loading... [',num2str(n),'/',num2str(length(filenames)),']' ]);
            lastUpdate = toUpdate;
        end
    catch
        h = waitbar(n/(length(filenames)),'Loading...');
    end
    %% Read new file
    afile = fullfile(pathname, filenames{n});
    [~, name, ~] = fileparts(afile);
    tempImg = imread(afile);
    %% Save. If RGB, convert to grayscale.
    if (size(tempImg,3)==1)
        img(:,:,n) = tempImg;
    else
        disp('RGB image loaded, converting to grayscale.');
        img(:,:,n) = rgb2gray(tempImg);
    end
    %% Add name to list. Parsing non-numeric names
    if (isnan(str2double(name)))
        if (n > 1)
            names(n) = names(n-1) + 1;
        else
            names(n) = n;
        end
    else
        names(n)=str2double(name);
    end
end
%% Store read information
datastructure.names = names;
datastructure.img = img;
datastructure.captureimg = [];

%% Update UI
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

string = horzcat('Original Images:', ' ', num2str(ValueSlice));
set(handles.tOI,'Visible','on','String',string);
setupImg = datastructure.img(:,:,ValueSlice);
ShowImage(handles,1,datastructure.img(:,:,ValueSlice),[]);
close(h);

% --------------------------------------------------------------------
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

% --------------------------------------------------------------------
function File_Close_Callback(hObject, eventdata, handles)
% hObject    handle to File_Close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ValueSlice datastructure 

img=datastructure.img;
sz=size(img,3);
if sz>1
    img(:,:,ValueSlice:sz-1) = img(:,:,ValueSlice+1:sz);
    img=img(:,:,1:sz-1);
    if ValueSlice>1; ValueSlice=ValueSlice-1; else ValueSlice=1; end
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

% --------------------------------------------------------------------
function File_Close_All_Callback(hObject, eventdata, handles)
% hObject    handle to File_Close_All (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global datastructure referenceCrackOrigin tempReferenceCrackOrigin setupImg ValueSlice  

datastructure.img=[];

% ======= Reset Slider, file set and axes ========
cla(handles.axes1,'reset');
set(handles.axes1,'Visible','off');
set(handles.tOI,'Visible','off');
set(handles.slider1,'Visible','off');

referenceCrackOrigin = [];
tempReferenceCrackOrigin = [];
setupImg = [];
ValueSlice = 1;

% --------------------------------------------------------------------
function slider1_Callback(hObject, eventdata, handles)
% Executes on Slider Movement
global ValueSlice datastructure 

ValueSlice = get(handles.slider1,'Value');
ShowImage(handles,1,datastructure.img(:,:,floor(ValueSlice)),[]);
string = horzcat('Original Images:', ' ', num2str(floor(ValueSlice)));
set(handles.tOI,'Visible','on','String',string);

% --------------------------------------------------------------------
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --------------------------------------------------------------------
function listbox1_CreateFcn(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------
function listbox1_Callback(hObject, eventdata, handles)
% --- Executes on selection change in listbox1.
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1

% --------------------------------------------------------------------
function listbox1_KeyPressFcn(hObject, eventdata, handles)
% --- Executes on key press with focus on listbox1 and none of its controls.
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
    mat2clip(data);                                 %Clipboard() does not copy cell arrays
end

% --------------------------------------------------------------------
function File_data_export_Callback(hObject, eventdata, handles)
% hObject    handle to File_data_export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global datastructure

if isempty(datastructure)
    msgbox('No data to export.');
    return
end

[filenames, pathname] = uiputfile( {'*.xlsx';'*.xls';'*.txt';'*.*'},'Export crack data');
if isequal(filenames, 0)
   return
end
afile = fullfile(pathname, filenames);

h = waitbar(.1,'Exporting...');
A=[datastructure.names; datastructure.data];
status = xlswrite(afile, A', 1,  'A1');
close(h);
if status
    msgbox('Export completed');
else
    msgbox('Export failed');
end


% --------------------------------------------------------------------
function pbExit_Callback(hObject, eventdata, handles)
% --- Executes on button press in pbExit.
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
close all;

% --------------------------------------------------------------------
function figure1_DeleteFcn(hObject, eventdata, handles)
% --- Executes during object deletion, before destroying properties.
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Exit_Callback(hObject, eventdata, handles)
global vid
delete(hObject);
delete (vid);

% --------------------------------------------------------------------
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% --- Executes when user attempts to close figure1.
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

% --------------------------------------------------------------------
function Settings_Distance_Calibation_Callback(hObject, eventdata, handles)
% hObject    handle to Settings_Distance_Calibation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global dist datastructure

%% Checks
if isempty(datastructure)
   msgbox('No camera configured. Please configure it in the Camera Setup.','Error'); 
   return; 
end

%% Show image
if datastructure.captureimg
    img=datastructure.captureimg;
else
    img=datastructure.img(:,:,1);
end
figure; imshow(img);hold on;

%% Calculate Frequency parameters for the image
% Y direction parameters are not used
[~, Sx]=size(img);
fft=abs(fftshift(fft2(img))); 
[~, xx] = find(fft==max(max(fft)));
[szy, szx]=size(fft); r = [szx/2+20 szy/2-20 200 200];
Imax = imcrop(fft,r);
[I]=max(max(Imax));
[~,xc]=find(I==Imax,1,'first');
r=floor(r);xi=r(1);
xci=xi+xc;
DX = xci - xx;

%% Acquire and show first point
msgbox('Choose 2 points from the figure for distance calibration','Point Selection');
uiwait(gcf);
try
    [x1,y1] = ginput(1);
catch
    return; % In case the user closes the figure
end
if (isempty(x1) && isempty(y1)) % If user pressed return, exit
   close;
   return;
end
plot(x1, y1,'r+');
%% Calculate and show a suggestion for the next point
multiplier = 48;
dir = 1;
xSuggestion = x1 + dir * multiplier*Sx/DX;

while (xSuggestion > Sx || xSuggestion < 1)
    % Attempt to find a suggestion inside the image
%    dir = -dir; % Uncomment if we want suggestions in both directions
    if (dir == 1)
        multiplier = multiplier/2;
    end
    xSuggestion = x1 + dir*multiplier*Sx/DX;
end

SPoint = [xSuggestion y1];
plot(SPoint(1), SPoint(2),'r+'); hold off;
%% Acquire second point and calculate distance
try
    [x2,y2] = ginput(1);
catch
    return; % In case the user closes the figure
end
if (isempty(x2) && isempty(y2)) % If user pressed return, consider the suggestion
   x2 = SPoint(1); 
   y2 = SPoint(2);
end
close;
dist=sqrt((x1-x2)^2+(y1-y2)^2);
%% Show DistanceCalibration form for further input
DistanceCalibration

% --------------------------------------------------------------------
function Settings_Select_NI_Device_Callback(hObject, eventdata, handles)
% hObject    handle to Settings_Tester_Setup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global devId
devId = selectNIdevice(); % search for the NI device only when the user opens tester settings

% --------------------------------------------------------------------
function Settings_Tester_Setup_Callback(hObject, eventdata, handles)
% hObject    handle to Settings_Tester_Setup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiwait(Tester_Settings) % input DAQ settings and image capture frequency

% --------------------------------------------------------------------
function Settings_Camera_Setup_Callback(hObject, eventdata, handles)
% hObject    handle to Settings_Camera_Setup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% global vid adaptor mycam
global vid datastructure setupImg
uiwait (MyCam);

if isempty(vid)
    return
end
setupImg = getsnapshot(vid);
datastructure.captureimg=setupImg;
datastructure.img=setupImg;
ShowImage(handles,1,setupImg,[]);

% --------------------------------------------------------------------
function Settings_Select_ROI_Callback(hObject, eventdata, handles)
% hObject    handle to Settings_Select_ROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Settings_Select_ROI_crackROI_Callback(hObject, eventdata, handles)
% hObject    handle to Settings_Select_ROI_crackROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rectCrackROI datastructure rectCrackStartROI
%% Startup checks
if isempty(datastructure)
   msgbox('Not enough information for ROI selection.', 'Error' );
   return;
end

if datastructure.captureimg
    img=datastructure.captureimg;
else
    img=datastructure.img(:,:,1);
end

%% Input rectCrackROI
figure('Name','Crack Region of Interest');imshow(img);
msgbox('Choose the ROI for the entire crack region','Input region');
uiwait(gcf);
rectCrackROI = getrect; close;
%% Check selected ROI, force it to be inside the image
if (rectCrackROI(1) < 1)
    rectCrackROI(3) = rectCrackROI(3) + rectCrackROI(1); % (1) will be negative
    rectCrackROI(1) = 1;
end
if (rectCrackROI(2) < 1)
    rectCrackROI(4) = rectCrackROI(4) + rectCrackROI(2); % (2) will be negative
    rectCrackROI(2) = 1;
end
if (rectCrackROI(1)+rectCrackROI(3) > size(img,2))
    rectCrackROI(3) = size(img,2) - rectCrackROI(1);
end
if (rectCrackROI(2)+rectCrackROI(4) > size(img,1))
    rectCrackROI(4) = size(img,1) - rectCrackROI(2);
end
rectCrackStartROI = [];

% --------------------------------------------------------------------
function Settings_Select_ROI_crackStartROI_Callback(hObject, eventdata, handles)
% hObject    handle to Settings_Select_ROI_crackStartROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global rectCrackStartROI templateImg datastructure yPeakOriginal xPeakOriginal rectCrackROI referenceCrackOrigin
%% Startup checks
if isempty(datastructure)
   msgbox('Not enough information for ROI selection', 'Error' );
   return;
elseif isempty(rectCrackROI)
   msgbox('Please select the Crack ROI first', 'Error' );
   return; 
end

if datastructure.captureimg
    img=datastructure.captureimg;
else
    img=datastructure.img(:,:,1);
end
%% Input rectCrackStartROI
figure('Name','Crack Start Region of Interest');imshow(img);
msgbox('Choose the ROI for the beginning of the crack','Input region');
uiwait(gcf);
rectCrackStartROI = getrect; close;

%% Check selected ROI, force it to be inside the image
if (rectCrackStartROI(1) < 1)
    rectCrackStartROI(3) = rectCrackStartROI(3) + rectCrackStartROI(1); % (1) will be negative
    rectCrackStartROI(1) = 1;
end
if (rectCrackStartROI(2) < 1)
    rectCrackStartROI(4) = rectCrackStartROI(4) + rectCrackStartROI(2); % (2) will be negative
    rectCrackStartROI(2) = 1;
end
if (rectCrackStartROI(1)+rectCrackStartROI(3) > size(img,2))
    rectCrackStartROI(3) = size(img,2) - rectCrackStartROI(1);
end
if (rectCrackStartROI(2)+rectCrackStartROI(4) > size(img,1))
    rectCrackStartROI(4) = size(img,1) - rectCrackStartROI(2);
end
%% Generate template image
templateImg=imcrop(img, rectCrackStartROI);
%% Calculate X Y correlation peaks for the original image
imgROI = im2double(imcrop(img, rectCrackROI));
nimg = imgROI-mean(mean(imgROI));
templateImg = im2double(templateImg) - mean(mean(imgROI)); 
cc2 = xcorr2(nimg,templateImg);
cc2 = cc2(size(templateImg,1):(size(cc2,1)),size(templateImg,2):size(cc2,2)); %remove the padding
[~, imax] = max((cc2(:)));
[yPeakOriginal, xPeakOriginal] = ind2sub(size(cc2),imax(1));

referenceCrackOrigin = [];

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

ShowImage(handles,1,setupImg,[]);

% --------------------------------------------------------------------
function Settings_Analyse_pre_crack_Callback(hObject, eventdata, handles)
% hObject    handle to Settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function Settings_Analyse_pre_crack_Morpho_settings_Callback(hObject, eventdata, handles)
% hObject    handle to Settings_Analyse_pre_crack_Morpho_settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SEImg referenceCrackOrigin
if isempty(SEImg)
    msgbox('No strutural element defined, please go to Determine Structure.', 'Error'); 
    return;
end

if isempty(referenceCrackOrigin)
    answer = questdlg({'The reference Crack Origin will be automatically calculated, please consider performing its previous calculation.','Do you want to proceed?'},'','Yes','No','Yes');
    if (~strcmp(answer,'Yes'))
        return;
    end
end
CrkOpt;

% --------------------------------------------------------------------
function Settings_Analyse_pre_crack_Images_PCAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to Settings_Analyse_pre_crack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global datastructure rectCrackROI
%% Verify if the needed information is available
if isempty(datastructure)
   msgbox('Not enough information for pre-crack processing', 'Error');
   return;
end
if isempty(rectCrackROI)
    msgbox('Crack ROI not defined', 'Error');
    return;
end

%% Start the waitbar
hWaitbar = waitbar(0,'Calculating...');
%% Import and show the last image from the structure
imgC = im2double(datastructure.img(:,:,end)); 
waitbar(.1,hWaitbar); % Update the waitbar
figure('Name','Determine structure','NumberTitle','off'); imshow(imgC), hold on
waitbar(.2,hWaitbar); % Update the waitbar
%% Create a draggable rectangle
h = imrect(gca, rectCrackROI);
waitbar(.3,hWaitbar); % Update the waitbar
%% Perform the calculations for the start rectangle
crackAnalysis(imgC,rectCrackROI);
waitbar(.7,hWaitbar); % Update the waitbar
%% Add callbacks and constrains to the rectangle
addNewPositionCallback(h,@(p) crackAnalysis(imgC, p));
fcn = makeConstrainToRectFcn('imrect',get(gca,'XLim'),get(gca,'YLim'));
waitbar(.9,hWaitbar);  % Update the waitbar
setPositionConstraintFcn(h,fcn);
waitbar(1,hWaitbar);  % Update the waitbar
%% Process completed, close the waitbar
close(hWaitbar);

% --------------------------------------------------------------------
function Images_Analysis_Callback(hObject, eventdata, handles)
% hObject    handle to Images_Analysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global datastructure rectCrackROI rectCrackStartROI pix2mm templateImg ...
    SEImg referenceCrackOrigin ImgOriginDataStructure saveOriginFigures ...
    continuousRefOriginUpdate breakCycle

%% Data verification
if (isempty(datastructure))
    msgbox('No images to analyse.','Error');
    return; 
end
if isempty(pix2mm)
    msgbox('Distance calibration not performed. Please go to the Distance Calibration dialog.','Error');
    return; 
end
if (isempty(rectCrackStartROI) || isempty(rectCrackROI))
    msgbox('Region of Interest not set. Please go to the ROI Settings dialogs.','Error');
    return; 
end
if isempty(SEImg)
    msgbox('No strutural element defined, please go to Determine Structure.','Error');
    return;
end
if isempty(referenceCrackOrigin)
    answer = questdlg({'If you proceed, the reference Crack Origin will be automatically calculated for each step.','Do you want to proceed?'},'','Yes','No','Yes');
    if (~strcmp(answer,'Yes'))
        return;
    end
end

%% Setup
% Images
img=datastructure.img;
MaxSlices=size(img,3);
crackdata=zeros(1,MaxSlices);
names=datastructure.names;

% Control variable for the 'export_fig' requirement warning
exportFigWarning = false;

%% UI setup
cla(handles.axes2,'reset');
set(handles.axes2,'Visible','on',...
                'Color',[0 0 0],...
                'xtick',[],'ytick',[]);
set(handles.listbox1,'Visible','on');
set(handles.tPROI,'Visible','on');
set(handles.tMeasurement,'Visible','on');
nowStr = ['Analysis run on: ' char(datetime('now'))];
fill_listbox(nowStr);
fill_listbox('--------------------------------'); 


%% Output figures setup
if (saveOriginFigures)
    fig1 = figure('Name','Output preview','NumberTitle','off');
    fig1axes = axes;
    hold on;
    if (exist('output','dir') ~= 7)
        mkdir('output');
    end
end

%% Waitbar
h = waitbar(0,'Calculating...','CreateCancelBtn','setappdata(gcbf,''breakCycle'',true)');
setappdata(h,'breakCycle',false);
breakCycle = false;

%% Main Cycle
for i=1:MaxSlices
    try
        waitbar(i/MaxSlices,h,['Calculating... [',num2str(names(i)),'/',num2str(names(MaxSlices)),']']);
        if (getappdata(h,'breakCycle'))
            breakCycle = true;
            break;
        end
    catch
        breakCycle = true;
        break;
    end
    imgC = im2double(img(:,:,i)); 
    
    %% HARRIS
    % Find the 'correctedCrackStartROI' within the 'rectCrackROI' ROI  
    correctedCrackStartROI = locateOrigin(imgC,rectCrackROI,rectCrackStartROI,templateImg);
    
    % Find crack start inside 'correctedCrackStartROI'
    [r, c]=harris(im2double(imgC), ImgOriginDataStructure.sigma, ImgOriginDataStructure.radius, ImgOriginDataStructure.originRadius, referenceCrackOrigin, correctedCrackStartROI);
    
    if (isempty(c) || isempty(r))
       deltaX = referenceCrackOrigin(2); deltaY = referenceCrackOrigin(1);
    else
        deltaX = c; deltaY = r;
        if (continuousRefOriginUpdate)
            referenceCrackOrigin(2) = deltaX;
            referenceCrackOrigin(1) = deltaY;
        end
    end
    crackOrigin = [ deltaY+correctedCrackStartROI(2) deltaX+correctedCrackStartROI(1)];
    %% Save Harris' output figure
    if (saveOriginFigures)
        cla(fig1axes);
        imshow(imgC,'Parent',fig1axes); hold(fig1axes,'on'); plot(fig1axes,crackOrigin(2),crackOrigin(1),'r+');rectangle('Parent',fig1axes,'Position',rectCrackStartROI,'EdgeColor','r');rectangle('Parent',fig1axes,'Position',correctedCrackStartROI,'EdgeColor','b');
        try
            export_fig(['output/', num2str(i), '_origin.jpg'],fig1,'-native');
        catch
            if (~exportFigWarning)
                fprintf(2,'''<a href="https://github.com/altmany/export_fig">export_fig</a>'' is required for figure exporting functionality\n');
                exportFigWarning = true;
            end
        end
    end
    %% Calculate length
        
	[~, lengthmm] = crackLength(imgC, rectCrackROI, crackOrigin, pix2mm, false);
    crackdata(i)=lengthmm;
    plot(handles.axes2,names, crackdata,'-.k');

    % Write in ListBox
    fill_listbox (['Distance in X axis     = ' num2str(lengthmm) ' mm']);
    fill_listbox ('--------------------------------');  
end
%% Close Waitbar
try
    delete(h);
catch
    
end
%% Reset crack origin if iterative
if (continuousRefOriginUpdate)
    referenceCrackOrigin = [];
end
if (saveOriginFigures)
    close(fig1);
end
%% Closing message
datastructure.data=crackdata;
if (~breakCycle)
    msgbox('Analysis complete','');
else
    msgbox('Analysis cancelled','');
end


% --------------------------------------------------------------------
function Test_Callback(hObject, eventdata, handles)
% hObject    handle to Test (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function Start_Test_Callback(hObject, eventdata, handles)
% hObject    handle to Start_Test (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global testerfreq testermag cyclesperimage vid halt Img datastructure...
       rectCrackROI rectCrackStartROI pix2mm templateImg SEImg devId ...
       triggerPhase triggerDelay ImgOriginDataStructure referenceCrackOrigin ...
       continuousRefOriginUpdate

%% Startup verifications
if  isempty(testerfreq) || isempty(cyclesperimage)
    msgbox('Tester parameters not set. Please go to the Tester Settings dialog.','Error');
    return; 
end

if  isempty(rectCrackStartROI)
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

%% Start video
setVideo;

%% Initial setup
halt=0;
% Sample rate for DAQ. The global "testerfreq" is updated in "CountCycles"
DAQsamplerate = 100*testerfreq;
% Number of samples necessary to count the required # cycles
numberofsamples = floor(DAQsamplerate*cyclesperimage/testerfreq);
set(handles.axes2,'DataAspectRatioMode','manual');
set(handles.listbox1,'String','');
set(handles.listbox1,'Visible','on');

i = 0;
j = 0;
k=1;
TotalTime=0;
TotalCycles=0;
newnumberofsamples = numberofsamples;

%% Verify NI DAQ
debug=false;
if isempty(devId)
    debugAns=questdlg('No NI DAQ selected, do you want to do a debug session?','NI DAQ','Yes','No','Configure','Yes');
    if (strcmp(debugAns,'Yes'))
       debug=true;
    elseif (strcmp(debugAns,'Configure'))
        Settings_Select_NI_Device_Callback([],[],[]);
        return;
    else
        return;
    end
end

%% Main cycle
tic
while halt==0
    %% Count Cycles
    if ~debug
        [~,lastPeakTime,lastPeakMag] = CountCycles(true,DAQsamplerate,newnumberofsamples);
    else
        pause(cyclesperimage/testerfreq);
    end
    j=j+cyclesperimage;
    %% Wait for the right moment to trigger
    if (~debug)
        if (lastPeakMag >= 0)
            lastPeakPhase = pi/2;
        else
            lastPeakPhase = 3*pi/2;
            % This will never happen unless the code is changed. (findpeaks
            % only searches for maxima, not minima.
        end
        % Aprox to 100ms. If instead of an image we grab samples from NI's 
        % DAQ, it works with around 100 ms margin. I measured the time 
        % startForeground() took to complete, and it took around 100 ms
        % more than the configured runtime. The camera takes around 0.5 for
        % all 5 images, 0.2 if only 1 image. 
        triggerPhaseDelay = (triggerPhase - lastPeakPhase)/(2*pi*testerfreq) - triggerDelay;
        nCyclesDelay = ceil((24*60*60*(now-lastPeakTime) - triggerPhaseDelay) * testerfreq);
        % Wait for the right time to trigger, according to the intended
        % trigger Phase
        pause(triggerPhaseDelay - 24*60*60*(now-lastPeakTime) + nCyclesDelay/testerfreq);
    end
    %% Acquire image
    GrabImage(handles,j);
    imgC = im2double(Img); 
    
    %% Harris & Find ROI
    % Find the crack start ROI within 'rect1' ROI  
    correctedCrackStartROI = locateOrigin(imgC,rectCrackROI,rectCrackStartROI,templateImg);

    % Find crack start inside 'correctedCrackStartROI'
    [r, c]=harris(imgC, ImgOriginDataStructure.sigma, ImgOriginDataStructure.radius, ImgOriginDataStructure.originRadius, referenceCrackOrigin, correctedCrackStartROI);   
    if (isempty(c) || isempty(r))
       deltaX = referenceCrackOrigin(2); deltaY = referenceCrackOrigin(1);
    else
        deltaX = c; deltaY = r;
        if (continuousRefOriginUpdate)
            referenceCrackOrigin(2) = deltaX;
            referenceCrackOrigin(1) = deltaY;
        end
    end
    
    crackOrigin = [ deltaY+correctedCrackStartROI(2) deltaX+correctedCrackStartROI(1)];

    %% Show crack origin
    if k<25                                          % Show detected corner on the first 5 takes
        plot(crackOrigin(2), crackOrigin(1),'r+'), title('Crack origin detected');
    end
    
    %% Calculate crack length
	[~, lengthmm] = crackLength(Img, rectCrackROI, crackOrigin, pix2mm, true);
    hold off;
    
    %% Elapsed time calculations
    crackdata(k)=lengthmm;
    names(k)=k*cyclesperimage;
    plot(handles.axes2,names, crackdata,'-+k');
    k=k+1;

    ET=toc;
    tic
    % Use the time elapsed in calculations to start counting cycles ahead so
    % the #cycles remains constant 
    elapsedcycles = ET*testerfreq - cyclesperimage;
    TotalTime = TotalTime + ET;
    TotalCycles = TotalCycles + floor(ET*testerfreq);
    if (elapsedcycles > 0) && (i > 1)
        newnumberofsamples = floor(DAQsamplerate*(cyclesperimage - elapsedcycles)/testerfreq);
    else
        newnumberofsamples = numberofsamples;
        elapsedcycles=0;
    end
    %% Update listbox
    fill_listbox ('clc');
    fill_listbox (['         Frequency = ' num2str(testerfreq,'%4.2f') ' Hz']);
    fill_listbox (['         Magnitude = ' num2str(testermag,'%4.2f') ' V']);
    fill_listbox (['Elapsed #cycles = ' num2str(elapsedcycles,'%6.0f')]);
    fill_listbox (['  New #samples = ' num2str(newnumberofsamples,'%6.0f')]);
    fill_listbox (['        Total time = ' num2str(TotalTime,'%6.0f')]);
    fill_listbox (['           #cycles = ' num2str(TotalCycles,'%6.0f')]);
	fill_listbox (['Distance in X axis = ' num2str(lengthmm) ' mm']);
end
%% Complete
datastructure.data=crackdata;
datastructure.names=names;
msgbox('Test completed.');


% --------------------------------------------------------------------
function Stop_Test_Callback(hObject, eventdata, handles)
% hObject    handle to Stop_Test (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global halt
halt=1;

% --------------------------------------------------------------------
function GrabImage(handletofigure,j)
global vid Img datastructure rectCrackROI myFolder
if isempty(vid)
    return;
end
trigger(vid);
def= getdata(vid,5,'single');
[Index, F] = BestFocusedImage(def);
%disp(['Selected image ', num2str(Index)]);
if (F < 1.13 && false)   % If the best focused image is not very good, try to sharpen it
                        % Maybe let the user define the limit value?
                        % TODO: This is disabled! Select a good limit value.
    H = padarray(2,[1 1]) - fspecial('gaussian'); % Generate unsharpen filter
    tempImg = imfilter(def(:,:,Index),H); % Apply filter
    newF = fmeasure(tempImg,rectCrackROI); % Calculate new Focus measurement
    if  newF > F % If it is an improvement
        def(:,:,Index) = tempImg; % Replace
    end
end
datastructure.captureimg=def(:,:,Index);
Img=def(:,:,Index);
ShowImage(handletofigure,1,def(:,:,Index),[]); hold on;
try
    imwrite(def(:,:,Index),[myFolder, num2str(j),'.jpg']);
catch
end

   
% --------------------------------------------------------------------
function [datachunk, lastPeakTime, lastPeakMag] = CountCycles(flag,DAQsamplerate,numberofsamples)
global testerfreq testermag cyclesperimage minimumpeakheight halt devId
if isempty(devId)
   return; 
end
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

[data, timestamps, triggerTime] = startForeground(s);

[peaks, locs] = findpeaks(data,'MINPEAKHEIGHT',minimumpeakheight,'NPEAKS',cyclesperimage);

% Stop the test if there's no data on the DAQ
if isempty(peaks)
    halt=1;
end

lastPeakLoc = locs(length(locs));
% TimeStamp of the last peak is the TriggerTime + the time that passed from
% trigger to acquisition of that sample (converted from seconds to fraction
% of a day: therefore x/24/60/60)
lastPeakTime = triggerTime + timestamps(lastPeakLoc)/24/60/60;
lastPeakMag = data(lastPeakLoc);

if flag
    % Zero-pad to increase #bins and frequency resolution
    data1=wextend('1D','zpd',data,32*numberofsamples,'r');
    [f,mag] = daqdocfft(data1,DAQsamplerate,33*numberofsamples);
    [~,maxindex]= max(mag);

    % Updates the global variable "testerfreq"
    testerfreq=f(maxindex);
	testermag=mean(peaks);
    minimumpeakheight=0.95*testermag;
end

datachunk=data;
release(s);
delete(s);

% --------------------------------------------------------------------
function [f,mag] = daqdocfft(data,Fs,blocksize)
%	[F,MAG]=DAQDOCFFT(X,FS,BLOCKSIZE) calculates the FFT of X
%	using sampling frequency FS and the SamplesPerTrigger provided in BLOCKSIZE
xfft = abs(fft(data));
%	Avoid taking the log of 0.
xfft(xfft == 0) = 1e-17; % Change to logical indexing

mag = 20*log10(xfft);
mag = mag(1:floor(blocksize/2));
f = (0:length(mag)-1)*Fs/blocksize;
f = f(:);

% --------------------------------------------------------------------
function setVideo
global vid

set(vid, 'ReturnedColorSpace', 'grayscale');
set(vid,'FramesPerTrigger',5,'TriggerRepeat',inf);
if ~isrunning(vid)
    triggerconfig(vid,'Manual');
end
if isrunning(vid)
   stop(vid); 
end
start(vid);

% --------------------------------------------------------------------
function ShowImage(handles,AxesType,Img,map)
axesn=strcat('axes',num2str(AxesType));
[SizeY, SizeX]=size(Img);
Figpos = get(handles.figure1,'Position');
pos=get(handles.(axesn),'Position');
switch (AxesType)
	case 1
        pos(4) = pos(3)*SizeY/SizeX;
        pos(2) = Figpos(4)-pos(4)-25;
    case 2
        % Se SizeY �mpar, diminui 1 px
        if mod(SizeY,2)~=0, SizeY = SizeY-1; end
        % Cria nova imagem com a largura de "Img" e 256px de altura
        imgBorder=zeros(128-SizeY/2, SizeX); 
        % Copia "img" para o centro da nova imagem
        Img = vertcat(imgBorder, Img, imgBorder);
end
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
imshow(Img,'Parent',handles.(axesn));
if isempty(map)
	colormap gray;
else
	colormap map;   
end         
         
% --------------------------------------------------------------------
function fill_listbox (string2write)
global listbx
if strcmp(string2write,'clc') 
    listbx.str = [];
    set(listbx.handle,'String',listbx.str);
    return
end
listbx.str{end+1} = string2write;
set(listbx.handle,'String',listbx.str);

% --------------------------------------------------------------------
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

% --------------------------------------------------------------------
function crackAnalysis(crckimg, cracROI)
global SEImg areaRect SEImgShow myFolder
% Used for the SEImg calculation
%% If there is a detected area rectangle, delete it
if(~isempty(areaRect))
    try
        delete(areaRect);
    catch
    end
end
if (~isempty(SEImgShow))
    try
        delete(SEImgShow);
    catch
    end
end

%% Structuring elements for morphological file processing tasks below
SESBallOverMLab = strel('ball', 2, -2, 0);

seh = [0 0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0 0;...
       0 0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0 0;...
       0 0 0 0 0 0 0 0 0 0 0 0 0; 1 1 1 1 1 1 1 1 1 1 1 1 1;...
       1 1 1 1 1 1 1 1 1 1 1 1 1; 1 1 1 1 1 1 1 1 1 1 1 1 1;...
       0 0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0 0;...
       0 0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0 0;...
       0 0 0 0 0 0 0 0 0 0 0 0 0];

%% Morphological processing
imgC = im2double(imcrop(crckimg, cracROI));

imCl = imclose(imgC,SESBallOverMLab);
imOp = imopen(imCl,SESBallOverMLab);
T = imgC - min(imOp,imgC);

imAT = adapthisteq(T,'ClipLimit',0.01);

Th=1.0;
level = Th*graythresh(imAT);
bw = im2bw(imAT,level);

se = strel(seh);
bw=imclose(bw,se);
crckbin=bwareaopen(bw,100);

%% Crack calculation
% Area Statistics: find the largest connected components area -
% the crack. Next, find the bounding box of this area.
stats = regionprops(crckbin, 'Area','BoundingBox','Extrema');
AreaArray=zeros(1,length(stats));
for j=1:length(stats), AreaArray(j) = stats(j).Area; end

[~,idxMax] = max(AreaArray);

%% Extract a structuring element, SEImg
BB = stats(idxMax).BoundingBox;
BBox = imcrop(crckbin,BB);
thin=bwmorph(BBox,'thin', Inf);
[y,x]=find(thin);y=max(y)-y;
sy=size(thin,1);
sx=size(x,1);
warning('off','stats:statrobustfit:IterationLimit');
r=robustfit(x,y);

SEImg=zeros(sy,sx);line=zeros(1,sx);
for i=1:sx
   line(i)=ceil(r(1)+r(2)*i);
   if sy-line(i)<=0, line(i)=sy-1; end
   SEImg(sy-line(i),i)=1;
end

l=19; h=l;
rect=[sx/2-l/2 sy/2-h/2 l h];
SEImg=imcrop(SEImg, rect);
try
    imwrite(SEImg,[myFolder 'ROI.tif'],'WriteMode','append');
catch
end
%% Show the structural element
SEImgShow = imagesc(1:100,1:100,SEImg);
%% Try not to overlay the output image with the ROI
% The image of the structural element is expected to take 100 px
% Check which sides are free from the cracROI
xLeftOccupied = false;
xRightOccupied = false;
yTopOccupied = false;
yBottomOccupied = false;
if (cracROI(1) <= 100)
    xLeftOccupied = true;
end    
if (cracROI(1)+cracROI(3) >= size(crckimg,2) - 100)    
    xRightOccupied = true;
end
if (cracROI(2) <= 100)
    yTopOccupied = true;
end
if (cracROI(2)+cracROI(4) >= size(crckimg,1) - 100)
    yBottomOccupied = true;
end
% Check available corners for the image
cornerNW = ~(xLeftOccupied && yTopOccupied);
cornerSW = ~(xLeftOccupied && yBottomOccupied);
cornerNE = ~(xRightOccupied && yTopOccupied);
cornerSE = ~(xRightOccupied && yBottomOccupied);
% Choose a corner. Priority given in the order: NW, NE, SW, SE.
% If none is available, use NW.
if (cornerNW)
    %Don't change
elseif (cornerNE)
    SEImgShow.XData = SEImgShow.XData + size(crckimg,2) - 100;
elseif (cornerSW)
    SEImgShow.YData = SEImgShow.YData + size(crckimg,1) - 100;
elseif (cornerSE)
    SEImgShow.XData = SEImgShow.XData + size(crckimg,2) - 100;
    SEImgShow.YData = SEImgShow.YData + size(crckimg,1) - 100;
else
    %Don't change either
end

%% Show the detected crack's BoundingBox
areaRect = rectangle('Position',[BB(1)+cracROI(1), BB(2)+ cracROI(2), BB(3), BB(4)],'LineWidth',1, 'EdgeColor','b','LineStyle','-.');
uistack(areaRect,'down',2);

% --------------------------------------------------------------------
function [Index, F] = BestFocusedImage(Imgset)
global rectCrackROI
% Nr of image files in Imageset
filesperset =  size(Imgset, ndims(Imgset));
F = 0;
FM=zeros(filesperset,1);

for f = 1:filesperset
    Img = Imgset(:,:,f);
    FM(f) = fmeasure(Img, rectCrackROI);
    if FM(f) > F
        F = FM(f);
        Index = f;
    end
end

% --------------------------------------------------------------------
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

% --------------------------------------------------------------------
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
clear;
clear global;
delete(gcf)


% --------------------------------------------------------------------
function crackOriginCalculation_Callback(hObject, eventdata, handles)
% hObject    handle to crackOriginCalculation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global datastructure rectCrackROI
if isempty(datastructure)
   msgbox('Not enough information for calculation', 'Error' );
   return;
end
if isempty(rectCrackROI)
   msgbox('Please select the Crack Start ROI first', 'Error' );
   return; 
end

CrackOrigin;


% --------------------------------------------------------------------
function outputOriginFigs_Callback(hObject, eventdata, handles)
% hObject    handle to outputOriginFigs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global saveOriginFigures
if strcmp(get(hObject, 'Checked'),'on')
    saveOriginFigures = false;
    set(hObject, 'Checked', 'off');
else
    saveOriginFigures = true;
    set(hObject, 'Checked', 'on');
end


% --------------------------------------------------------------------
function extraSettings_Callback(hObject, eventdata, handles)
% hObject    handle to extraSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function continuousRefOrigin_Callback(hObject, eventdata, handles)
% hObject    handle to continuousRefOrigin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global continuousRefOriginUpdate
if strcmp(get(hObject, 'Checked'),'on')
    continuousRefOriginUpdate = false;
    set(hObject, 'Checked', 'off');
else
    continuousRefOriginUpdate = true;
    set(hObject, 'Checked', 'on');
end