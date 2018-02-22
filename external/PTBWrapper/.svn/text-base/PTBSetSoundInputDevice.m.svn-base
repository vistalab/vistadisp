%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBSetSoundInputDevice.m
%
% Sets the sound input device.
%
% Args:
%	- device_num: The device to read from.
%
% Usage: PTBSetSoundInputDevice(1);
%
% Author: Doug Bemis
% Date: 4/26/11
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBSetSoundInputDevice(device_num)

% Grab the devices
a_dev = PsychPortAudio('GetDevices');

% Find the inputs
input_dev = [];
for i = 1:length(a_dev)
	if a_dev(i).NrInputChannels > 0
		input_dev(end+1) = a_dev(i).DeviceIndex; %#ok<AGROW>
	end
end
	
% Get the appropriate one
if isempty(find(input_dev == device_num, 1))
	disp('WARNING: Requested device not an input. Defaulting...');
	value = [];

else
	value = device_num;
end

% Set
global PTBSoundInputDevice;
PTBSoundInputDevice = value;
