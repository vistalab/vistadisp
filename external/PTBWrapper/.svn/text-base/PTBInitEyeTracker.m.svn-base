%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBInitEyeTracker.m
%
% Initializes the eyelink eye tracker
%
% Usage: PTBInitEyeTracker(edf_file_name)
%
% * Inputs
%	- edf_file_name: The file to write the data too. 
%		* CANNOT BE LONGER THAN 8 CHARACTERS
%
% Author: Doug Bemis
% Date: 10/12/11
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBInitEyeTracker

global PTBEyeTrackerInitialized;
global PTBTheWindowPtr;
global PTBEyeTrackerHandle;

% See if it's installed at all
try
    Eyelink;

catch %#ok<CTCH>
	% Show to the console
    disp('WARNING! WARNING! WARNING! WARNING! WARNING! WARNING!');
	disp('Eyelink not installed. No data will be collected!');
    disp('WARNING! WARNING! WARNING! WARNING! WARNING! WARNING!');

	% And to the screen
	PTBDisplayParagraph({'WARNING! WARNING! WARNING! WARNING! WARNING! WARNING!',...
		'Eyelink not installed. No data will be collected.','WARNING! WARNING! WARNING! WARNING! WARNING! WARNING!'},{'center',30},{'any'})	
	PTBDisplayBlank({.1},'Trigger warning');
	PTBEyeTrackerInitialized = 0;
	return;	
end

% See if we can initialize
if Eyelink('Initialize','PsychEyelinkDispatchCallback')~= 0; 
    
	% Show to the console
    disp('WARNING! WARNING! WARNING! WARNING! WARNING! WARNING!');
	disp('Eyelink not detected. No data will be collected!');
    disp('WARNING! WARNING! WARNING! WARNING! WARNING! WARNING!');

	% And to the screen
	PTBDisplayParagraph({'WARNING! WARNING! WARNING! WARNING! WARNING! WARNING!',...
		'Eyelink not detected. No data will be collected.','WARNING! WARNING! WARNING! WARNING! WARNING! WARNING!'},{'center',30},{'any'})	
	PTBDisplayBlank({.1},'Trigger warning');
	PTBEyeTrackerInitialized = 0;
	return;	
end

% Provide Eyelink with details about the graphics environment
% and perform some initializations. The information is returned
% in a structure that also contains useful defaults
% and control codes (e.g. tracker state bit and Eyelink key values).
PTBEyeTrackerHandle = EyelinkInitDefaults(PTBTheWindowPtr);


% make sure that we get gaze data from the Eyelink
status = Eyelink('command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');
disp(['Got status ' num2str(status) ' for command for link_sample_data.']);

% Should be good
disp('Eyetracker found and ready to go!');
PTBEyeTrackerInitialized = 1;


