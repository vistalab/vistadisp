%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBDisplayCircles.m
%
% Displays circles to the screen.
%
% Args:
%	- positions: Where to put the circles
%	- sizes: The size of the circles (diameter). This can
%		be a single constant.
%	- colors: The color of the circles. This can be a
%		single constant.
%	- duration: How long to show the the text.
%
% Usage: PTBDisplayCircles([100 100; 200 200]', 20, [255 255 255], {.3})
%
% Author: Doug Bemis
% Date: 2/3/10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: Take variable args and parse.
% TODO: Error checking.
function PTBDisplayCircles(positions, size, colors, duration, varargin)

% Parse any optional arguments and get the correct window
[trigger  trigger_delay key_condition wPtr] = PTBParseDisplayArguments(duration, varargin);

% TODO: Allow setting of font, size, color
%Screen('TextFont', PTBTheWindowPtr, 'Courier');
%Screen('TextSize', PTBTheWindowPtr, 30);
%tColor = WhiteIndex(PTBTheWindowPtr);

% Draw the circles
% TODO: If high-quality circles break stuff, change last argument to 1.
% TODO: Maybe allow resetting of center?
% TODO: Handle positions more generally across different display functions.
quality = 2;
center = [0 0];
Screen('DrawDots', wPtr, positions, size, colors, center, quality);

% Set the type...
global PTBVisualStimulus;
PTBVisualStimulus = 1;

% And, ready to go
PTBPresentStimulus(duration, 'Circles', '\t', trigger, trigger_delay, key_condition);
