%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBCalibrateEyeTracker.m
%
% Calibrate the eyelink eye tracker
%
% Usage: PTBCalibrateEyeTracker
%
% Author: Doug Bemis
% Date: 10/12/11
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBCalibrateEyeTracker

global PTBEyeTrackerInitialized;
global PTBEyeTrackerCalibrated;
global PTBEyeTrackerHandle;

% Should have already sent a message before, so just return now...
if ~PTBEyeTrackerInitialized
	PTBEyeTrackerCalibrated = 0;
	return;
end


% Calibrate the eye tracker
EyelinkDoTrackerSetup(PTBEyeTrackerHandle);

% No drift correction for now
%EyelinkDoDriftCorrect(PTBEyeTrackerHandle);

disp('Eyetracker calibrated!');
PTBEyeTrackerCalibrated = 1;

