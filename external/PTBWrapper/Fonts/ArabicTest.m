% Quick test to make sure that Arabic works

function ArabicTest

% For testing
is_debugging = 0;

% Make sure we're compatible
PTBVersionCheck(1,1,8,'at least');

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


% Let's try our experiment
try

    % First, prepare everything to go
    PTBSetupExperiment('ArabicTest');
	
    % This gives time to get the program up and going
	init_blank_time = 1;
	PTBDisplayBlank({init_blank_time},'');
	
	% Start it up
	english_font = 'Courier';
	PTBSetTextFont(english_font);
	PTBDisplayText('Press any key to begin.', {'center'},{'any'});
	
	% All we have to do is set a good font.
	% These can be found using FontFinder:
	%	e.g. FontFinder({'FC0B','0685'}).
	arabic_font_name = 'Courier New (146)';
	arabic_font = 'Courier New';

	% Apparently, some fonts contain some characters, and 
	%	others, others. For instance, Courier New has most of
	%	them, but not FC0B or FDFA, apparently. Al Bayan does
	%	have these, but you have to call it by number, not name.
	%	Good luck!
	arabic_font_name_2 = 'Al Bayan Plain (76)';
	arabic_font_2 = 76;		% Al Bayan Plain...
	
	% These also work. There are probably more too...
% 	arabic_font = 'Geeza Pro Bold';
% 	arabic_font = 'Geeza Pro';
% 	arabic_font = 'Al Bayan Plain';
% 	arabic_font = 'Al Bayan Bold';
% 	arabic_font = 'Bagdad';
% 	arabic_font = 'Courier New Bold';
	
	% So, it's unclear how to save Arabic characters
	%	to a file that can then be read in, so for now,
	%	we have to manually convert Arabic characters
	%	to unicode and then save these values in
	%	a file. 
	%
	% This site can help: http://jrgraphix.net/research/unicode_blocks.php?block=12
	%
	% PTBDisplayText needs to be given decimal numbers. These can be
	%	saved directly, or the hex can be converted as below:
	fid = fopen('Arabic_Test.txt');
	while 1
		line = fgetl(fid);
		if ~ischar(line)
			break;
		end
		
		% Convert from hex one at a time.
		characters = [];
		hex_string = '';
		while ~isempty(line)
			[hex_char line] = strtok(line); %#ok<STTOK>
			characters(end+1) = hex2dec(hex_char); %#ok<AGROW>

			% NOTE: Seemes to display right to left...
			hex_string = [hex_char ' ' hex_string]; %#ok<AGROW>
		end

		% For testing.
		PTBSetTextFont(english_font);
		PTBDisplayText([arabic_font_name ': ' hex_string], {'center', [0 100]},{-1});		
		
		% And, show it.
		PTBSetTextFont(arabic_font);
		PTBDisplayText(characters, {'center'},{'any'});
		
		% Just to show
		if ~isempty(findstr(hex_string, 'FDFA'))
			PTBSetTextFont(english_font);
			PTBDisplayText([arabic_font_name_2 ': ' hex_string], {'center', [0 100]},{-1});		
			PTBSetTextFont(arabic_font_2);
			PTBDisplayText(characters, {'center'},{'any'});			
		end
	end
	
	% And we're done.
	PTBSetTextFont('Courier');
	PTBDisplayText('Press any key to end.', {'center'},{'any'});
	
	% Quick blank to make sure the last screen stays on
	PTBDisplayBlank({.1},'');
    
	% And finish up
    PTBCleanupExperiment;

catch %#ok<CTCH>
	PTBHandleError;
end

