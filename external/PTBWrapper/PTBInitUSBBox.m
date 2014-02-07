%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBInitUSBBox.m
%
% Initializes the IOLab USB ButtonBox
%
% Usage: PTBInitUSBBox
%
% Author: Doug Bemis
% Date: 1/21/10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBInitUSBBox

global PTBUSBBoxInitialized;
global PTBStimTrackerInitialized;
global PTBUSBBoxDeviceID;
global PTBTriggerPortInitialized;

% Make sure we're not trying to use too many trigger devices
if PTBStimTrackerInitialized == 1 || PTBTriggerPortInitialized == 1
    error('Only one trigger device can be used at one time.');
end

% Attempt to find the device number for the
% IOLab USB Box
% Don't try this in windows
global PTBCurrComputerSpecs;
if PTBCurrComputerSpecs.osx
    devices = squeeze(struct2cell(PsychHID('devices')));
    devices_id = cell2mat(devices(6,:));
    results = find(devices_id == 6588);
else
    results = [];
end
if isempty(results)
	PTBUSBBoxDeviceID = -1;
	PTBUSBBoxInitialized = 0;
	
	% Show to the console
    disp('WARNING! WARNING! WARNING! WARNING! WARNING! WARNING!');
	disp('BBox not found. No triggers will be sent.');
    disp('WARNING! WARNING! WARNING! WARNING! WARNING! WARNING!');

	% And to the screen
	PTBDisplayParagraph({'WARNING! WARNING! WARNING! WARNING! WARNING! WARNING!',...
		'BBox not found. No triggers will be sent.','WARNING! WARNING! WARNING! WARNING! WARNING! WARNING!'},{'center',30},{'any'})	
	PTBDisplayBlank({.1},'Trigger warning');
	return;
end;

% Set all the triggers to 0
PTBUSBBoxDeviceID = results(1);
PsychHID('SetReport', PTBUSBBoxDeviceID, 2, hex2dec('32'), uint8([0 0]));
disp('BBox found and ready to go.');
PTBUSBBoxInitialized = 1;