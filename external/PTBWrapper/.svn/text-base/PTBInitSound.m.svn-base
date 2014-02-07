%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBInitSound.m
%
% NOTE: Internal function. DO NOT CALL.
%
% Initializes the sound driver. Good luck...
%
% Args:
%	- latency: 0 for no low-latency, 1 for low-latency
%		- If 1 crashes, use 0...
%
% Usage: PTBPlaySoundFile(1)
%
% Author: Doug Bemis
% Date: 1/21/10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBInitSound(latency)

global PTBSoundInitialized;

% Over-calling this. Might need a check
%    to only call once
InitializePsychSound(latency);
PTBSoundInitialized = 1;

