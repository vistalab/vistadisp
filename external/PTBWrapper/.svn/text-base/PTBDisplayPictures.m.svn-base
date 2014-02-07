%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBDisplayPicture.m
%
% Displays a picture to the screen.
%
% Args:
%	- pictures: The picture files to display in a cell. (e.g. {'pic.wav'})
%	- positions: Either 'center' to center the picture or [x y] for each
%       picture, in a cell. E.g. {'center'} or {[100 100]}.
%       * NOTE: You CANNOT follow 'center' with an offset here, you have to
%           calculate the position. It is where the center of the picture
%           will be.
%	- scales: The scales to show the pictures at. E.g. {1} will show it
%		original size, while {2} will double the size.
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
%   - tag: A label to print out with the picture.
%   - trigger (optional): Any integer 1-255 - will be sent as a trigger. (e.g. 8)
%   - trigger_delay (optional): Will delay the trigger this long (e.g. 0.006).
%
% Usage: PTBDisplayPictures({'Test.jpg'}, {'center'}, {1}, {.3},'Stim')
%
% Author: Doug Bemis
% Date: 7/4/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: Take variable args and parse.
% TODO: Error checking.
function PTBDisplayPictures(pictures, positions, scales, duration, tag, varargin)

% Parse any optional arguments and get the correct window
[trigger trigger_delay key_condition] = PTBParseDisplayArguments(duration, varargin);

% TODO: Allow setting of size, orientation, position, etc.

% Need to load the picture
% TODO: Look into preloading, for time.
% TODO: Is imread the best thing to use here?
% TODO: Can also explicitly add format to this function, if needed.
imdata = {};
for i = 1:length(pictures)
	
	% Load the data
	[data map alpha] = imread(pictures{i});

	% Add the alpha if necessary
	if isempty(alpha)
		imdata{i} = data;
	else
		imdata{i} = zeros(size(data,1),size(data,2),4);
		imdata{i}(:,:,1:3) = data;
		imdata{i}(:,:,4) = alpha;
	end
	
	% Might not have it (it's in a toolbox)
	if length(scales{i}) ~= 1 || scales{i} ~= 1
		try
			imdata{i} = imresize(imdata{i}, scales{i});
		catch
			err = lasterror;
			disp(['WARNING: Resizing not possible: ' err.message]);
		end		
	end
end

% Lean on the matrices routine
PTBDisplayMatrices(imdata, positions, duration, tag, trigger, trigger_delay, key_condition);

