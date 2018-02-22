%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBDisplayParagraph.m
%
% Displays many lines to the screen.
%
% Args:
%	- lines: The lines to display, in a cell, separated by commas.
%       E.g. {'This is line one','And line too'}
%	- positions: Two options. The easiest is just to center each line and
%       then space them by a given amount. To do this, use {'center',30},
%       which will insert space of 30 pixels.
%       * If the first argument is 'center', an optional
%           third argument can specify the vertical offset from the screen 
%           center.
%       * Otherwise, you can enter one pair for each line such that the
%           the line is drawn starting at that coordinate (e.g. {[100
%           100],[100 150]}.
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
%   - trigger_delay (optional): Will delay the trigger this long (e.g. 0.006).%
% Usage: PTBDisplayParagraph({'Hello.','line 2'},{'center',30},{.3})
%
% Author: Doug Bemis
% Date: 7/5/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: Take variable args and parse.
% TODO: Error checking.
function PTBDisplayParagraph(lines, positions, duration, varargin)

% Parse any optional arguments and get the correct window
[trigger  trigger_delay key_condition wPtr] = PTBParseDisplayArguments(duration, varargin);

% Need the current window
global PTBScreenRes;
global PTBTextFont;
global PTBTextSize;
global PTBTextColor;

% Set text parameters
Screen('TextFont', wPtr, PTBTextFont);
Screen('TextSize', wPtr, PTBTextSize);

% Support centering
if ischar(positions{1})
	if strcmp(positions{1}, 'center')
		
 		% Read the positions parameters
        if length(positions) >= 3
            vertical_offset = positions{3};
        else
            vertical_offset = 0;
        end

        % find the actual positions 
		spacing = positions{2};
		positions = {};
		heights = [];
		for i = 1:length(lines)

			% Get the bounds
			bounds = Screen('TextBounds', wPtr, lines{i});

			% Set the first position
			positions{i}(1) = PTBScreenRes.width/2 - bounds(3)/2;
			
			% And keep a record of the heights
			heights(i) = bounds(4);
		end
		
		% Add in the line spacing
		totalHeight = sum(heights) + (length(lines)-1)*spacing;
		
		% Set the first one
		positions{1}(2) = PTBScreenRes.height/2 - totalHeight/2 ...
            + vertical_offset;
		
		% Set the heights accordingly
		for i = 2:length(lines)
			positions{i}(2) = positions{i-1}(2) + heights(i-1) + spacing;
		end
		
	else
		error('Bad positions option.');
	end
end

% Make sure we're ok.
if length(positions) ~= length(lines)
	error('Bad position argument.');
end

% Draw each line
for i = 1:length(lines)
	Screen('DrawText', wPtr, lines{i}, positions{i}(1), positions{i}(2), PTBTextColor);
end

% Set the type...
global PTBVisualStimulus;
PTBVisualStimulus = 1;

% And, ready to go
PTBPresentStimulus(duration, 'Paragraph', lines{i}, trigger,  trigger_delay, key_condition);
