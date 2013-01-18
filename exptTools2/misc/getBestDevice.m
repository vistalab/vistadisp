function device = getBestDevice(display)
% device = getBestDevice(devices)
% 
% Purpose
%   Determine if an external button box or other input device exists.  If
%   not, use the default input device (ex: internal keyboard on a laptop).
%
% Input
%   display - Generated with loadDisplayParams and openScreen.
%       Note: Unless you've assigned a field 'devices' to it using the
%       getDevices function, it won't be able to find your devices.
%           Ex: display.devices = getDevices;
%               Call this *before* openScreen, as it closes the screen.
%
% Output
%   device - Number of input device for use with KbCheck or KbQueue routines
%
% RFB 2009 [renobowen@gmail.com]

device = [];
if isfield(display,'devices')
    if ~isempty(display.devices.keyInputExternal)
        device = max(display.devices.keyInputExternal);
    end
end