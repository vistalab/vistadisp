function params = setRetinotopyDevices(params)
% params = setRetinotopyDevices(params)
%
% Set internal / external devices for retinotopy experiment
%
% April, 2009, JW : Broken off from doRetinotopy scan
%
% note: this function doesn't have to be specific to retinotopy. could now
% be renamed and moved to, say, vistadisp/exptTools2/experimentControl

params.devices = getDevices;

if isempty(params.devices.keyInputExternal),
    params.devices.keyInputExternal = params.devices.keyInputInternal(1);

elseif length(params.devices.keyInputExternal) > 1
    % there is a bug if there is more than one input devices attached via
    % USB: KbCheck will fail. In this case, take the first one. (There is
    % no guarantee which device this will be, but often it is the computer
    % keyboard...?)  (ras, 05/2009)
    params.devices.keyInputExternal = params.devices.keyInputExternal(1);
end;
 
fprintf('[%s]:Getting subjects responses from device #%d\n',mfilename,params.devices.keyInputExternal);
fprintf('[%s]:Getting experimentor''s responses from device #%d\n',mfilename,params.devices.keyInputInternal);

return
