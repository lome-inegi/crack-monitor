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
        end
    else
        disp 'No NI device found';
        return;
    end

    if(strcmp(devId,''))
        disp 'No NI device selected';
        return;
    end
    
    %% Test device
    try
        s = daq.createSession('ni');
    catch
        devId = '';
        msgbox('Driver error');
        release(s);delete(s);
        return;
    end
    try
        ch = addAnalogInputChannel(s,'Dev2','ai0','Voltage');
    catch
        devId = '';
        msgbox('Error configuring AI0 channel.');
        release(s);delete(s);
        return;
    end
    try
        ch(1).TerminalConfig = 'Differential';
    catch
        devId = '';
        msgbox('Differential configuration not supported.');
        release(s);delete(s);
        return;
    end
    release(s);delete(s);
    
    %% Device accepted
    
    usingMsgbox = msgbox(['Using NI ', devices(selection).get('Model'), '.']);
    edithandle = findobj(usingMsgbox,'Style','pushbutton');
    set(edithandle,'Visible','off');
    pause(1);
    if (ishandle(usingMsgbox))
        close(usingMsgbox);
    end
end

