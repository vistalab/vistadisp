%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBCloseEyeTracker.m
%
% Shutdown the eyelink eye tracker 
%
% Usage: PTBcloseEyeTracker
%
% Author: Doug Bemis
% Date: 10/12/11
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBCloseEyeTracker

global PTBEyeTrackerInitialized;
global PTBEyeTrackerFileName;
global PTBEyeTrackerRecording;
if isempty(PTBEyeTrackerInitialized) || ~PTBEyeTrackerInitialized
	return;
end

% Get the file, if we're still recording
if PTBEyeTrackerRecording
    PTBStopEyeTrackerRecording;
end

% Shut it down
Eyelink('ShutDown');
PTBEyeTrackerInitialized = 0;
PTBEyeTrackerFileName = '';