function params = coc(params)
% coc - program to start Craik-O'Brien-Cornsweet scans (under OSX)
%       
%
% 06/2005 SOD Ported to OSX. If the mouse is invisible,
%             moving it to the Dock usually makes it reappear.
% 10/2005 SOD Several changes, including adding gui.
% 04/2006 SOD Converted from ret to loc
% 05/2008 JW  Converted from loc to coc

% get some parameters from graphical interface
if ~exist('params', 'var')
    params = cocMenu;
    drawnow;
end

% now set rest of the params
 params = cocSetParams(params);

% set response device
params.devices = getDevices;
if isempty(params.devices.keyInputExternal),
    params.devices.keyInputExternal = params.devices.keyInputInternal;
end;
fprintf('[%s]:Getting subjects responses from device #%d\n',mfilename,params.devices.keyInputExternal);
fprintf('[%s]:Getting experimentor''s responses from device #%d\n',mfilename,params.devices.keyInputInternal);

% go
cocDoScan(params);
