%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBStopEyeTrackerRecording.m
%
% Stop the eyelink eye tracker recording
%
% Usage: PTBStopEyeTrackerRecording
%
% Author: Doug Bemis
% Date: 10/12/11
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBStopEyeTrackerRecording

global PTBEyeTrackerRecording;
global PTBEyeTrackerInitialized;
global PTBEyeTrackerFileName;

% Should have already sent a message before, so just return now...
if ~PTBEyeTrackerInitialized
	return;
end

% Check to see if we're overwriting
if ~PTBEyeTrackerRecording
    return;
	disp('WARNINGWARNINGWARNINGWARNINGWARNING');
	disp('WARNING: Recording did not start before stop.');
	disp('WARNINGWARNINGWARNINGWARNINGWARNING');

	% And to the screen
	PTBDisplayParagraph({'WARNING! WARNING! WARNING! WARNING! WARNING! WARNING!',...
		'WARNING: Recording did not start before stop.','WARNING! WARNING! WARNING! WARNING! WARNING! WARNING!'},{'center',30},{'any'})	
	PTBDisplayBlank({.1},'EDF warning');
end
Eyelink('Stoprecording');
PTBEyeTrackerRecording = 0;

% Close down the file
status = Eyelink('CloseFile');
disp(['Got status ' num2str(status) ' for command for close file.']);
if status ~= 0
    error('Eyetracker file not closed.');
end

% NOTE: Until we fix the crashing, just return here
return;

status = Eyelink('ReceiveFile',PTBEyeTrackerFileName, PTBEyeTrackerFileName);
disp(['Got status ' num2str(status) ' for command for receive file.']);
if status < 0
    error('Eyetracker file not received.');
end
if ~exist(PTBEyeTrackerFileName, 'file')
    error('Eyetracker file not found.');
end



