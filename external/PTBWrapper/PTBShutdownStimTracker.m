%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBShutdownStimTracker.m
%
% Shuts down the port to the Cedrus StimTracker
%
% Usage: PTBShutdownStimTracker
%
% Author: Doug Bemis
% Date: 6/25/12
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBShutdownStimTracker

% Make sure to close the port
% Use the general command to avoid errors.
%   There's a real problem that erroring in IOPort closes the screen...
% NOTE: This will of course close all other open IOPorts...
IOPort('CloseAll');

% And reset these
global PTBStimTrackerInitialized;
global PTBStimTrackerHandle;
PTBStimTrackerHandle = -1;
PTBStimTrackerInitialized = 0;
