function params = setRetinotopyDevices(params)
% params = setRetinotopyDevices(params)
%
% Set internal / external devices for retinotopy experiment
%
% April, 2009, JW : Broken off from doRetinotopy scan
%
% note: this function doesn't have to be specific to retinotopy. could now
% be renamed and moved to, say, vistadisp/exptTools2/experimentControl

allDevices = getDevices;

devices.str = params.devices;
devices.keyInputExternal = str2num(params.devices(end));
if isempty(allDevices.keyInputInternal)
    devices.keyInputInternal = devices.keyInputExternal;
else
    devices.keyInputInternal = allDevices.keyInputInternal(1);
end

params.devices = devices;

return

if isempty(params.devices.keyInputExternal),
    params.devices.keyInputExternal = params.devices.keyInputInternal(1);
    
else
    % there is a bug if there is more than one input devices attached via
    % USB: KbCheck will fail. In this case, take the first one. (There is
    % no guarantee which device this will be, but often it is the computer
    % keyboard...?)  (ras, 05/2009)
    
    
    % (06/2015, jz) Test: which external device is subject's input coming
    %                     from
ntest = length(params.devices.keyInputExternal);

for itest = 1: length(params.devices.keyInputExternal)
    disp('Press any key to start testing: ')
    WaitSecs(0.2);  KbWait(-1);
    fprintf('Press any key on the external device %d \n', params.devices.keyInputExternal(itest))
    
    t = 0; tic;
    while t < 1
        KbQueueCreate(devices.keyInputExternal(itest));
        KbQueueStart(devices.keyInputExternal(itest)); 
        WaitSecs(0.5);
        external_pressed = KbQueueCheck(devices.keyInputExternal(itest));
        
        if external_pressed ~= 0
            fprintf('External Device IS number : %d \n',  params.devices.keyInputExternal(itest))
            break
        end  
        if toc > 1
            fprintf('External Device is not number : %d \n',  params.devices.keyInputExternal(itest))
            t = 1;
            continue
        end
    end
end

    params.devices.keyInputExternal = params.devices.keyInputExternal(itest);
end;

fprintf('[%s]:Getting subjects responses from device #%d\n',mfilename,params.devices.keyInputExternal);
fprintf('[%s]:Getting experimentor''s responses from device #%d\n',mfilename,params.devices.keyInputInternal);

return
