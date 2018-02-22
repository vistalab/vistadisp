%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBInitTriggerPort.m
%
% Initializes the parrallel trigger port.
%
% Usage: PTBInitTriggerPort
%
% Author: Doug Bemis
% Date: 12/4/12
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBInitTriggerPort

global PTBUSBBoxInitialized;
global PTBStimTrackerInitialized;
global PTBTriggerPortInitialized;

% Make sure we're not trying to use too many trigger devices
if PTBStimTrackerInitialized == 1 || PTBUSBBoxInitialized == 1
    error('Only one trigger device can be used at one time.');
end

% Try to initialize the port
try
    
    % Zero it out
    lptwrite(888,0);
    disp('Trigger port zeroed and ready to go.');
    PTBTriggerPortInitialized = 1;
    
% Make sure we know no triggers are sent...
catch %#ok<CTCH>

	PTBTriggerPortInitialized = 0;
	
	% Show to the console
    disp('WARNING! WARNING! WARNING! WARNING! WARNING! WARNING!');
	disp('Parallel trigger port not initialized. No triggers will be sent.');
    disp('WARNING! WARNING! WARNING! WARNING! WARNING! WARNING!');

	% And to the screen
	PTBDisplayParagraph({'WARNING! WARNING! WARNING! WARNING! WARNING! WARNING!',...
		'Parallel trigger port not initialized. No triggers will be sent.',...
        'WARNING! WARNING! WARNING! WARNING! WARNING! WARNING!'},{'center',30},{'any'})	
	PTBDisplayBlank({.1},'Trigger warning');
	return;
end


