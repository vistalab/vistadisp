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


texture_code = zeros(1, numel(matrices));

for ii = 1:length(matrices)

	% TODO: Allow setting of size, orientation, position, etc.

	% A texture is a GL texture that renders quickly
	% TODO: Check for pict bigger than screen. No checking in MakeTexture.
	% TODO: Check optimizations, i.e. for rotating.
	texture_code(ii) = Screen('MakeTexture', PTBTheWindowPtr, matrices{ii});
    

	% TODO: See how this works and how effective it is at 
	% saving time.
% 	Screen('PreloadTextures', wPtr, m_tex);
    

	% Get the position
	% TODO: Error checking...
    if ischar(positions{ii})
        if strcmp(positions{ii},'center')
            pos = [];
        else
            error('Unknown position. Exiting...');
        end
    else
        pos = [positions{ii}(1) - size(matrices{ii},2)/2 positions{ii}(2) - size(matrices{ii},1)/2 ...
            positions{ii}(1) + size(matrices{ii},2)/2 positions{ii}(2) + size(matrices{ii},1)/2];
    end
    
    Screen('DrawTexture', PTBTheWindowPtr, texture_code(ii), [], pos);
    
    
    
    % TODO: Look into reusing textures.
%  	Screen('Close',m_tex);

end

% Save some memory.
% TODO: Allow keeping in memory
clear matrices;

% Set the type...
global PTBVisualStimulus;
PTBVisualStimulus = 1;

% And, ready to go
PTBPresentStimulus(duration, 'Matrix', tag, trigger,  trigger_delay, key_condition);
