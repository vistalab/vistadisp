%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBSetInputDevice.m
%
% Sets the input device.
%
% Args:
%	- device_num: The device to read from.
%
% Usage: PTBSetInputDevice(1);
%
% Author: Doug Bemis
% Date: 7/6/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBSetInputDevice(device_num)

% Not it windows yet
global PTBCurrComputerSpecs;
if ~PTBCurrComputerSpecs.osx
    disp('WARNING: No changing of input devices in Windows yet...');
    return;
end

% Grab them
kbs = GetKeyboardIndices;

% Get the appropriate one
if device_num > length(kbs)
	disp('WARNING: Fewer inputs than expected. Defaulting...');
	value = kbs(1);

% Allow special arguments
elseif device_num < 0
    value = device_num;
else
	value = kbs(device_num);
end

% Set
global PTBInputDevice;
PTBInputDevice = value;
