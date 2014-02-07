%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBDisplayMatrices.m
%
% Displays pixel arrays (matrices) to the screen. Allows 
%	arbitarily created images to be displayed.
%
% Args:
%	- matrices: The matrices to display
%		* nxmx4 arrays of 0-255 color values. [RGBA]
%	- positions: The position to display them
%		* Either 'center' or x,y coordinates of the center.
%	- duration: The length to display
%	- tag: A label to tag this display with in the log file.
%	- trigger: A trigger to send (optional)
%
% Usage: PTBDisplayMatrices(matrices, {[100 100],'center'},{'any'})
%
% Author: Doug Bemis
% Date: 7/4/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: Take variable args and parse.
% TODO: Error checking.
function PTBDisplayMatrices(matrices, positions, duration, tag, varargin)

% Parse any optional arguments and get the correct window
[trigger trigger_delay key_condition wPtr] = PTBParseDisplayArguments(duration, varargin);

% Place each matrix
global PTBTheWindowPtr;
for i = 1:length(matrices)

	% TODO: Allow setting of size, orientation, position, etc.

	% A texture is a GL texture that renders quickly
	% TODO: Check for pict bigger than screen. No checking in MakeTexture.
	% TODO: Check optimizations, i.e. for rotating.
	m_tex = Screen('MakeTexture', PTBTheWindowPtr, matrices{i});

	% TODO: See how this works and how effective it is at 
	% saving time.
	% [resident [texidresident]] = Screen('PreloadTextures', windowPtr [, texids]);

	% Get the position
	% TODO: Error checking...
	if ischar(positions{i})
		if strcmp(positions{i},'center')
			pos = [];
		else
			error('Unknown position. Exiting...');
		end
	else
		pos = [positions{i}(1) - size(matrices{i},2)/2 positions{i}(2) - size(matrices{i},1)/2 ...
			positions{i}(1) + size(matrices{i},2)/2 positions{i}(2) + size(matrices{i},1)/2];
	end
	
	% And draw to the buffer
	Screen('DrawTexture', wPtr, m_tex, [], pos);

	% TODO: Look into reusing textures.
	Screen('Close',m_tex);
	
end

% Save some memory.
% TODO: Allow keeping in memory
clear matrices;

% Set the type...
global PTBVisualStimulus;
PTBVisualStimulus = 1;

% And, ready to go
PTBPresentStimulus(duration, 'Matrix', tag, trigger,  trigger_delay, key_condition);
