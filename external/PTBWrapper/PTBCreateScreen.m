%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBCreateScreen.m
%
% NOTE: Internal function. DO NOT CALL.
%
% Creates a screen (i.e. buffer) to write to.
%
% Args:
%	- screen_number: Screen number to create
%	- is_offscreen: 1 if this is an onscreen window
%
% Usage: PTBCreateScreen(1, 1)
%
% Author: Doug Bemis
% Date: 3/2/10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ptr = PTBCreateScreen(screen_number, is_onscreen)

global PTBIsDebugging;
global PTBScreenRes;
global PTBBackgroundColor;
global PTBOnScreenRect;

% For now, keep double-buffered and default pixel depth, and 
% open with black color.
% Also, make a smaller screen for debugging, and always a
% full screen for running.
if is_onscreen
	if (PTBIsDebugging)
		PTBScreenRes.width = PTBScreenRes.width*.75;
		PTBScreenRes.height = PTBScreenRes.height*.75;
		[ptr PTBOnScreenRect] = Screen('OpenWindow', screen_number, PTBBackgroundColor, [0 0  PTBScreenRes.width PTBScreenRes.height]);
	else
		[ptr PTBOnScreenRect]  = Screen('OpenWindow', screen_number, PTBBackgroundColor);
	end
else
	ptr = Screen('OpenOffscreenWindow', screen_number, PTBBackgroundColor, PTBOnScreenRect);
end

% Set alpha blending on, just in case we want it
% TODO: Does this break anything?
Screen(ptr,'BlendFunction',GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
