%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBShutDownSound.m
%
% NOTE: Internal function. DO NOT CALL.
%
% Closes all the open sound ports
%
% Args: 
%
% Usage: PTBShutDownSound
%
% Author: Doug Bemis
% Date: 3/6/12
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBShutDownSound

% Don't try to close if not open
global PTBSoundInitialized;
if ~PTBSoundInitialized
    return;
end

% This will actually close them all, I think
PsychPortAudio('Close');
PTBSoundInitialized = 0;

% And reset the variables
global PTBSoundPortParameters;
global PTBSoundPorts;
global PTBOpenSoundPorts;
PTBSoundPortParameters = [];
PTBSoundPorts = [];
PTBOpenSoundPorts = [];
