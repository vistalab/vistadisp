%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBDisplayLines.m
%
% Displays lines to the screen.
%
% Args:
%	- positions: Where to put the lines. This needs
%		two endpoints (x,y) for each line, so four
%		numbers per line.
%	- sizes: The width of the lines. This can be
%		a single constant.
%	- colors: The color of the lines. This can be
%		a single constant.
%	- duration: How long to show the the text.
%	- trigger: A trigger to send (optional)
%
% Usage: PTBDisplayText([0 0; 100 100]',2,[255 255 255],{.2})
%
% Author: Doug Bemis
% Date: 2/3/10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: Take variable args and parse.
% TODO: Error checking.
function PTBDisplayLines(positions, sizes, colors, duration, varargin)

% Parse any optional arguments and get the correct window
[trigger  trigger_delay key_condition wPtr] = PTBParseDisplayArguments(duration, varargin);

% TODO: Allow setting of font, size, color
%Screen('TextFont', PTBTheWindowPtr, 'Courier');
%Screen('TextSize', PTBTheWindowPtr, 30);
%tColor = WhiteIndex(PTBTheWindowPtr);

% Draw the circles
% TODO: High-quality breaks stuff without alpha blending on
% TODO: Maybe allow resetting of center?
% TODO: Handle positions more generally across different display functions.
quality = 0;
center = [0 0];
Screen('DrawLines', wPtr, positions, sizes, colors, center, quality);

% Set the type...
global PTBVisualStimulus;
PTBVisualStimulus = 1;

% And, ready to go
PTBPresentStimulus(duration, 'Lines', '\t', trigger,  trigger_delay, key_condition);
