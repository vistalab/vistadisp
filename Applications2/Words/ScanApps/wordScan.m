% loc - program to start various localizers (under OSX)
%       
%
% 06/2005 SOD Ported to OSX. If the mouse is invisible,
%             moving it to the Dock usually makes it reappear.
% 10/2005 SOD Several changes, including adding gui.
% 04/2006 SOD Converted from ret to loc

% clean up - it's good to clean up but mex files are extremely slow to be
% loaded for the first time in MacOSX, so I chose not to do this to speed
% things up.
%close all;close hidden;
%clear mex;clear all;
%pack;

% ask parameters with user interface
params = locMenu;
drawnow;

% now set rest of the params
params = setLocParams(params.experiment, params);

% set response device
params.devices = getDevices;
if isempty(params.devices.keyInputExternal),
    params.devices.keyInputExternal = params.devices.keyInputInternal;
end;
disp(sprintf('[%s]:Getting subjects responses from device #%d',mfilename,params.devices.keyInputExternal));
disp(sprintf('[%s]:Getting experimentor''s responses from device #%d',mfilename,params.devices.keyInputInternal));

% go
doLocScan(params);
