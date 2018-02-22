%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: FontFinder.m
%
% A quick test to find fonts that will 
%	display unicode characters. This
%	simply loops through the fonts and
%	displays their name and number
%	along with their attempt to display
%	the characters given. 
%
% Inputs:
%	* characters: This is expected
%		to be a list of unicode character
%		values. This can be either an 
%		array of decimal numbers or
%		a cell array of hex numbers, 
%		given as characters.
%	* fonts: Either a list of names or
%		numbers to try out. (Optional.
%		defaults to all.)
%
% Usage: FontFinder({'06AE','FB7F'})
%	or FontFinder([1710 64383])
%	
% Author: Doug Bemis
% Date: 4/16/11
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function FontFinder(characters, fonts_to_try, font_size)

% Convert to decimal if necessary.
unicode = zeros(1,length(characters));
if isnumeric(characters)
	unicode = characters; %#ok<NASGU>
else
	for i = 1:length(unicode)
		unicode(i) = hex2dec(characters{i});
	end
end

% Set the fonts to try
if nargin < 2 || isempty(fonts_to_try)
	fonts_to_try = 1:FontInfo('NumFonts');
end

% And the size
if nargin < 3
	font_size = 40;
end

% Get all the info
f_info = FontInfo('Fonts');

% For testing
is_debugging = 0;

% Make sure we're compatible
PTBVersionCheck(1,1,10,'at least');

% Set to debug, if we want to.
PTBSetIsDebugging(is_debugging);

% Set the exit key.
PTBSetExitKey('ESCAPE');

% Use gray
PTBSetBackgroundColor([128 128 128]);

% NOTE: Might need this, if you run from the
% debugger (i.e. Fn+F5)
if is_debugging
	Screen('Preference', 'SkipSyncTests', 1);
end

% Let's try our "experiment"
global PTBLastKeyPress;
try

    % First, prepare everything to go
    PTBSetupExperiment('Font_Finder');
	PTBSetTextSize(font_size);
	
    % This gives time to get the program up and going
	init_blank_time = 1;
	PTBDisplayBlank({init_blank_time},'');
	
	% Some directions
	PTBSetTextFont('Courier');
	PTBDisplayParagraph({'Press n to advance the fonts.','Press p to go back',...
		'Press s to save a font name to file.','Press q to quit.','Press any key to begin'}, {'center', 30}, {'any'});
	
	% Try out all the fonts
	fid = fopen('FontResults.txt','w');
	i = 0;
	while i < length(fonts_to_try)
		i = i + 1;
		PTBSetTextFont('Courier');
		if isnumeric(fonts_to_try)
			PTBDisplayText([f_info(fonts_to_try(i)).name ' (' num2str(fonts_to_try(i)) ')'], {'center',[0 100]},{-1});
			PTBSetTextFont(fonts_to_try(i));
		else
			PTBDisplayText(fonts_to_try{i}, {'center',[0 100]},{-1});
			PTBSetTextFont(fonts_to_try{i});			
		end
		PTBDisplayText(unicode, {'center'},{'s','q','n','p'});

		% Quick screen to get the response time
		PTBDisplayBlank({.1},'Response_Catcher');
		
		% See if we need to do something
		if strcmp(PTBLastKeyPress, 's')
			if isnumeric(fonts_to_try)
				fprintf(fid,[f_info(fonts_to_try(i)).name ' (' num2str(fonts_to_try(i)) ')\n']);
			else
				fprintf(fid,[fonts_to_try{i} '\n']);
			end
		end
		if strcmp(PTBLastKeyPress, 'q')
			break;
		end
		if strcmp(PTBLastKeyPress, 'p')
			if i == 1
				i = i-1;
			else
				i = i-2;
			end
		end
	end
	fclose(fid);
	
	% Might have failed
	if ~strcmp(PTBLastKeyPress,'q')
		PTBSetTextFont('Courier');
		PTBDisplayParagraph({'No more fonts.','Press any key to end.'}, {'center',30},{'any'});
	end
	
	% Quick blank to make sure the last screen stays on
	PTBDisplayBlank({.1},'');
    
	% And finish up
    PTBCleanupExperiment;

catch %#ok<CTCH>
	PTBHandleError;
end

