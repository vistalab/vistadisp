%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBDisplayText.m
%
% Displays text to the screen.
% Args:
%	- text: The text to display as a simple text sting (e.g. 'text')
%	- position: Either 'center' to center the text or [x y].
%       * NOTE: This needs to be in a cell - e.g. {'center'} or {[100 100]}
%		- Center can also be followed by a [x_offset y_offset] pair.
%           - E.g. {'center',[0 100]}
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
%   - trigger (optional): Any integer 1-255 - will be sent as a trigger. (e.g. 8)
%   - trigger_delay (optional): Will delay the trigger this long (e.g. 0.006).
%
% NOTE: Position is the top of the text.
%
% Usage: PTBDisplayText('Hello world.',{'center'},{.2})
%
% Author: Doug Bemis
% Date: 7/4/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: Take variable args and parse.
% TODO: Error checking.
function PTBDisplayText(text, position, duration, varargin)

% Parse any optional arguments and get the correct window
[trigger trigger_delay key_condition wPtr] = PTBParseDisplayArguments(duration, varargin);

% Need the current window size for centering
global PTBScreenRes;
global PTBTextFont;
global PTBTextSize;
global PTBTextColor;

% Set text parameters
Screen('TextFont', wPtr, char(PTBTextFont));
Screen('TextSize', wPtr, PTBTextSize);

% For consistency, going to have everything as a cell
if iscell(position)
	if strcmpi(position{1},'center')
		
		% Get the bounds of the text
		bounds = Screen('TextBounds', wPtr, text);
		
		% Set the centered position
		p = [PTBScreenRes.width/2 - bounds(3)/2 PTBScreenRes.height/2 - bounds(4)/2];
		
		% Might want to offset
		% TODO: Add error checking...
        if length(position) == 2
			position = p + position{2}; 
        else
			position = p;
        end
    elseif isnumeric(position{1}) && length(position{1}) == 2
        position = position{1};
	else
		error(['Unknown position: ' position]);
	end
elseif ~isnumeric(position)
	error('Bad position argument.');
end
Screen('DrawText', wPtr, text, position(1), position(2), PTBTextColor);

% Set the type...
global PTBVisualStimulus;
PTBVisualStimulus = 1;

% And, ready to go
PTBPresentStimulus(duration, 'Text', text, trigger,  trigger_delay, key_condition);
