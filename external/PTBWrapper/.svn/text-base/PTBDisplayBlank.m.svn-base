%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBDisplayBlank.m
%
% Just display a blank screen.
%
% Args:
%	- duration: How long to show the the text. This should also be in a
%           cell, and can be any one or a mixture of a couple of options:
%       - Relative time (e.g. {.5}) will display for that amount of seconds
%       - Absolute time (e.g. {3.6517e+005}) will display until that system
%           time is reached. This number can come from either GetSecs or
%           PTBLastKeyPRessTime. Be warned, if you try to use this and the
%           calculation is not correct, your program will just hang.
%               NOTE: Any time greater than 1000 is assumed to be an
%               absolute time.
%       - Key press: (e.g. {'a'}) will wait until that key is pressed.
%           - Can also use {'any'} for any key.
%       - Sound trigger: {'sound'} will wait for a sound. The volume is
%           controlled by PTBSetSoundKeyLevel.
%       * NOTE: If you combine these, the display will wait until the first
%       is reach. So, {'any',2} will wait 2 seconds for any key to be
%       pressed.
%	- tag: The label to put in the log file to tell what this is. 
%       - Just a string (e.g. 'Blank', or 'Response Catcher').
%   - trigger (optional): Any integer 1-255 - will be sent as a trigger. (e.g. 8)
%   - trigger_delay (optional): Will delay the trigger this long (e.g. 0.006).
%
% Usage: PTBDisplayBlank({.3},'ITI')
%
% Author: Doug Bemis
% Date: 7/4/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBDisplayBlank(duration, tag, varargin)

% Parse any optional arguments and get the correct window
[trigger trigger_delay key_condition wPtr] = PTBParseDisplayArguments(duration, varargin);

% Clear it
global PTBBackgroundColor;
Screen('FillRect', wPtr, PTBBackgroundColor);

% Set the type...
global PTBVisualStimulus;
PTBVisualStimulus = 1;

% TODO: Maybe provide color option.
% TODO: Check to see if back buffer is actually empty.
PTBPresentStimulus(duration, 'Blank', tag, trigger, trigger_delay, key_condition);
