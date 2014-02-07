%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBStartEyeTrackerRecording.m
%
% Start the eyelink eye tracker recording
%
% Usage: PTBStartEyeTrackerRecording
%
% Author: Doug Bemis
% Date: 10/12/11
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBStartEyeTrackerRecording(edf_file_name)

global PTBEyeTrackerInitialized;
global PTBEyeTrackerRecording;
global PTBEyeTrackerCalibrated;
global PTBEyeTrackerFileName;

% Should have already sent a message before, so just return now...
if ~PTBEyeTrackerInitialized
	PTBEyeTrackerRecording = 0;
	return;
end

% Probably should let them know it's not calibrated...
if ~PTBEyeTrackerCalibrated
	disp('WARNINGWARNINGWARNINGWARNINGWARNING');
	disp('WARNING: Eye tracker not calibrated.');
	disp('WARNINGWARNINGWARNINGWARNINGWARNING');

	% And to the screen
	PTBDisplayParagraph({'WARNING! WARNING! WARNING! WARNING! WARNING! WARNING!',...
		'Eye tracker not calibreated','WARNING! WARNING! WARNING! WARNING! WARNING! WARNING!'},{'center',30},{'any'})	
	PTBDisplayBlank({.1},'Calibration warning');
end


% Check the edf filename
% Has to be less than 8 characters
if length(edf_file_name) > 8
	error('EDF filename too long. Exiting...');
end
PTBEyeTrackerFileName = [edf_file_name '.edf'];

% Check to see if we're overwriting
if exist([edf_file_name '.edf'],'file')
	disp('WARNINGWARNINGWARNINGWARNINGWARNING');
	disp(['WARNING: Will overwrite file: ' PTBEyeTrackerFileName '.']);
	disp('WARNINGWARNINGWARNINGWARNINGWARNING');

	% And to the screen
	PTBDisplayParagraph({'WARNING! WARNING! WARNING! WARNING! WARNING! WARNING!',...
		['Will overwrite file: ' PTBEyeTrackerFileName '.'],'WARNING! WARNING! WARNING! WARNING! WARNING! WARNING!'},{'center',30},{'any'})	
	PTBDisplayBlank({.1},'EDF warning');
end


% Open the file to record from.
% NOTE: file name has to be <= 8 characters
status = Eyelink('openfile', PTBEyeTrackerFileName); 
disp(['Got status ' num2str(status) ' for command for open file.']);
if status ~= 0
    error(['Could not open eye tracker file. Gave status :' num2str(status) '.']);
end

% Start the recording
status = Eyelink('StartRecording');
disp(['Got status ' num2str(status) ' for command for start recording.']);
if status ~= 0
    error('Could not start recording eyetracker.');
end
PTBEyeTrackerRecording = 1;


