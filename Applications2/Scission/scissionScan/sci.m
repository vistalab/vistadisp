function sci(params)
% sci - program to start Scission scans (under OSX)
%
% These codes are everlasting <beta> version, unfortunately...
%   
% 06/2005 SOD Ported to OSX. If the mouse is invisible,
%             moving it to the Dock usually makes it reappear.
% 10/2005 SOD Several changes, including adding gui.
% 04/2006 SOD Converted from ret to loc
% 05/2008 JW  Converted from loc to coc
% 12/2008 HH  Converted from coc to sci
% 02/2009 HH  Added Annulus condition and new GUI

% get some parameters from graphical interface

if ~exist('params', 'var')
          params = scissionMenu2; drawnow;
else      params = scissionMenu2(params); drawnow;
end

% now set rest of the params
params = scissionSetParams(params);

% set response device
params.devices = getDevices;
if isempty(params.devices.keyInputExternal),
    params.devices.keyInputExternal = params.devices.keyInputInternal;
end;
disp(sprintf('[%s]:Getting subjects responses from device #%d',mfilename,params.devices.keyInputExternal));
disp(sprintf('[%s]:Getting experimentor''s responses from device #%d',mfilename,params.devices.keyInputInternal));

% go
scissionDoScan(params);