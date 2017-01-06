function [boardId, devices] = find_ni_usb(model)

if ~ischar(model)
   disp 'Model name should be a string.';
end

boardId = '';

devices = daq.getDevices;
if isempty(devices)
   disp('Unable to find any NI-DAQ devices (is the device driver installed?)');
   return;
end

for i=1:1:length(devices)
    if strcmp(devices(i).get('Model'), strcat('USB-',model))
        %disp strcat('Found USB-',model);
        boardId = devices(i).get('ID');
        break; 
    end
end

%try
%    boardId = daq.createSession('ni');
%catch
%    disp('Unable to use NI interface. Support may require installation of the driver via the Support Package Installer.');
%    return;
%end

%try
%    info = daqhwinfo('nidaq');
%catch 
%    disp('Unable to find any NI-DAQ devices (is the device driver installed?)');
%    return;    
%end

% 
% index = strmatch('USB-9162', info.BoardNames);
% if isempty(index)
%     disp('Unable to find NI USB-9162 (is it turned on and connected to the PC?)');
%     return;
% end

%boardSession = info.InstalledBoardIds{index(1)};
