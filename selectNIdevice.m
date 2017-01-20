function [ devId ] = selectNIdevice(  )
    devId = '';
    searchMsgbox = msgbox('Searching for NI devices...');
    edithandle = findobj(searchMsgbox,'Style','pushbutton');
    set(edithandle,'Visible','off');
    pause(0.02);%20ms to redraw
    daqreset; %Refresh list
    devices = daq.getDevices;
    if (ishandle(searchMsgbox))
        close(searchMsgbox);
    end
    
    if(~isempty(devices))
        if length(devices)>1
            deviceModelList = devices.get('Model');
            [selection, ok] = listdlg('PromptString','Select a NI device:',...
                            'SelectionMode','single',...
                            'ListString',deviceModelList);
            if(ok)
                devId = devices(selection).get('ID');
                %disp(['Using ',deviceModelList(s),''s AI0.']);
                %selectedModel = deviceModelList(s);
            else
                disp 'No NI device selected';
                return;
            end
        else
            devId = devices(1).get('ID');
            selection = 1;
            uiwait(msgbox(['NI ', devices(selection).get('Model'), ' found'])); 
        end
    else
        uiwait(msgbox('No NI device found.','Warning')); 
        return;
    end

    if(strcmp(devId,''))
        uiwait(msgbox('No NI device selected.','Warning')); 
        return;
    end
    
    %% Test device
    try
        s = daq.createSession('ni');
    catch
        devId = '';
        release(s);delete(s);
        uiwait(msgbox('Driver error'));
        return;
    end
    try
        ch = addAnalogInputChannel(s,devId,'ai0','Voltage');
    catch
        devId = '';
        release(s);delete(s);
        uiwait(msgbox('Error configuring AI0 channel.'));
        return;
    end
    try
        ch(1).TerminalConfig = 'Differential';
    catch
        devId = '';
        release(s);delete(s);
        uiwait(msgbox('Differential configuration not supported.'));
        return;
    end
    release(s);delete(s);
    
    %% Device accepted
    
    %usingMsgbox = msgbox(['Using NI ', devices(selection).get('Model'), '.']);
    usingMsgbox = msgbox(['NI ', devices(selection).get('Model'), ' is compatible and will be used.']);
    edithandle = findobj(usingMsgbox,'Style','pushbutton');
    set(edithandle,'Visible','off');
    pause(1);
    if (ishandle(usingMsgbox))
        close(usingMsgbox);
    end
    %uiwait(msgbox([devices(selection).get('Model'), ' ']));
end

