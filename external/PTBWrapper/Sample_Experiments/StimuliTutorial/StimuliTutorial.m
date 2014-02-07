%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: Sample_Experiment.m
%
% This is an attempt to show the basics of how to use these wrappers. If you don't see
%	a function used in this script, chances are, it's mainly an internal function, and you
%	shouldn't call it unless you know exactly what you're doing. (E.g. PTBWaitForKey.m
%	is internal and will not simply wait for a key. It's part of the PTBPresentStimulus.m
%	functionality).
%
% The file is divided into two sections. The first shows the versatility of the PTBDisplay
%	functions (i.e. what can be accomplished by the different arguments - duration,
%	response collection, MEG triggering, timeouts, etc.). The second section runs through
%	the different stimulus types that are available through these display functions.
%
% Usage: Sample_Experiment
%
% Author: Doug Bemis
% Date: 7/24/10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SampleExperiment

% This call will make sure that the script can always
% be rerun properly, even if PTBWrapper is updated
% to a future version. Set this to whatever version
% works with the final script. You can find the
% current version with PTBWrapperVersion. The main
% point of this is that especially at the beginning, backwards
% compatibility is not always assured. This function will 
% let you know what command to run if your script is
% broken by an update.
PTBVersionCheck(1,1,12,'at least');

% If this is set to 1, the display will not take up the whole
% screen. This is useful if you crash something or get
% stuck in an infinite loop, as you can then just click
% in the Matlab window. To get out of the experiment, 
% then hit ctrl-c, to stop it running. Then, type
% PTBCleanupExperiment, to close the screen. 
% If this doesn't work, type Screen('CloseAll'), and this
% should close the display.
is_debugging = 1;
PTBSetIsDebugging(is_debugging);

% This prevents erroring from a slow startup during debugging.
if is_debugging
    Screen('Preference', 'SkipSyncTests', 1);
end

% NOTE: For now, only one input option (the worst one) 
% seems to work for the MEG right now and Mac combination.
% We're looking into this. So, if you're using the MEG button
% box, comment this in.
% NOTE: This collection response only records alphanumeric
% keys.
% NOTE: To change which input device you're listening from,
% use, PTBSetInputDevice.

% collection_type = 'Char';
% PTBSetInputCollection(collection_type);

% This option allows you to exit the program
% at any response by hitting the specified key.
PTBSetExitKey('ESCAPE');

% Where to write out the logs. This should give
% you all the information about what was displayed (log.txt)
% and what the responses were (data.txt).
PTBSetLogFiles('log_file.txt', 'data_file.txt');

% This is a useful set function.
% In general, if you would like to set an option (e.g.
% text size or color, etc.) check the PTBWrapper folder.
% Various Set functions are transparently enclosed in 
% functions there.
PTBSetBackgroundColor([128 128 128]);


% These are global variables set by the
% program. If we want to use them below
% MATLAB requires (or in later versions,
% requests) that they be declared at the
% top level.
% NOTE: A list of most of the important global
% variables can be found at the top of PTBSetupExperiment.

global PTBLastPresentationTime;			% When the last display was presented.
global PTBLastKeyPressTime;				  % When the last response was given.
global PTBLastKeyPress;						   % The last response given.
global PTBScreenRes;							% Has 'width' and 'height' of current display in pixels


% Let's try our experiment. This try block
% is necessary in order to gracefully exit
% when psychtoolbox crashes. Make sure
% you keep this (and the paired catch block
% below) when you make your experiment.
try

    % First, prepare everything to go. 
	% This call sets all the relevant parameters
	% for PTBWrapper and needs to be called
	% before any Display functions. You cannot
	% do without this.
    PTBSetupExperiment('SampleExperiment');
	PTBDisplayPictures({'Sample.jpg'}, {[100 100]}, {1}, {'any'}, 'Test picture');

	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Section 1: The different display options (i.e. duration, position,
	%	triggering, display conditions) are available for all PTBDisplay options.
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% Start the triggers. In order to trigger using the button box in 
	% Mac, this is necessary to call first. It will give a warning if something
	% goes wrong, but allow the script to continue.
	% NOTE: You must call this before trying to send any triggers.
	%PTBInitUSBBox;
	
	% Show a simple stimulus.
	% * The first argument is the string to display.
	% * The second argument is the position. This can also
	%		be a simple [x y] position. Also, an [x y] offset can
	%		be added to the special 'center' argument (e.g. {'center', [0 100]}
	%		will show the text 100 pixels below the center.
	% * The third argument is the duration of the screen. This
	%		can also be an exact time (i.e. as retrieved from GetSecs).
	%		This latter method is more exact, but, you need to be
	%		able to figure out the right duration to give.
 	PTBDisplayText('First screen',{'center'},{1});
    
	% Show a quick blank screen.
	% * The first argument is the duration.
	% * The second argument is a tag that
	%		identifies this screen in the log file.
	PTBDisplayBlank({.3},'Blank');
	
	% Collect a response.
	% The duration can also be set to any keycode, including
	% the special 'any', which works as you would expect.
	% Also, any response is written to the data file. This
	% automatically includes the pressed key and the
	% response time. You can also add arbitrary entries
	% to this output using PTBSetLogAppend. To change
	% these values, simply call the function again.
	PTBSetLogAppend(1,'clear',{'Condition','Item Num'});
	PTBDisplayText('Press any key',{'center'},{'any'});
	
	% Show that we got it. Unfortunately, this is a little tricky.
	% The program is designed to show a screen (e.g. the
	% text 'Press any key' above, and then perform all of the
	% code necessary to get the next display ready to go (in this case
	% a simple blank screen). Only then does the program
	% hang waiting for the duration of the stimulus currently
	% being shown (i.e. the text) to end. In this way, the
	% next display is shown immediately following the 
	% end of the previous display, minimizing timing
	% delays. Unfortunately, this means that the key pressed
	% during the response is not available (in the code) until
	% after the next 'Display' call. There are some ways around
	% this (shown below), but for right now, this is how it goes.
	
	% Get the time of the text display. The time of 
	% the last display is always stored in this global variable.
	text_display_time = PTBLastPresentationTime;
	
	% Show a blank screen, to allow us to collect the response.
	PTBDisplayBlank({.3},'Response catcher.');
	
	% Now, we can get the response from the text display.
	response_key = PTBLastKeyPress;
	
	% And, recover the response time.
	response_time = PTBLastKeyPressTime - text_display_time;
	
	% And show the results
	PTBDisplayText(['Pressed ' response_key ' after ' num2str(response_time) ' seconds.'],{'center'},{1});
	
	% To implement a timeout, the easiest way is to just give
	% the duration as a key and a time. If the time is reached
	% before the key is pressed, then the display will end.
	char = ['' ceil(rand*26) + 96 ''];
	PTBDisplayText('Guess the character...',{'center'},{char,1.5});
	
	% Again, catch the response
	PTBDisplayBlank({.3},'Response catcher');
	
	% See if we got it, or we timed out, in which
	% case the PTBLastKeyPress will be set to TIMEOUT. Also,
	% PTBLastKeyPressTime will be set to -1.
	if strcmp(PTBLastKeyPress,'TIMEOUT')
		PTBDisplayText(['Sorry, it was ' char '.'],{'center'},{1});
	else
		PTBDisplayText(['Nice job. It was ' char '.'],{'center'},{1});
	end
	
	% Here is the alternate way, with no blank screen.
	char = ['' ceil(rand*26) + 96 ''];
	PTBDisplayText('Guess the character...',{'center'},{char,1.5});

	% The last additional argument sets the condition on 
	% which the display will run. This can be set to any keycode,
	% including the special 'TIMEOUT'.
	PTBDisplayText(['Sorry, it was ' char '.'],{'center'},{1},'TIMEOUT');
	PTBDisplayText(['Nice job. It was ' char '.'],{'center'},{1},char);
	PTBDisplayBlank({.5},'Blank');
	
	% The other useful optional argument is for MEG triggering.
	% Just add the trigger value after the duration, and it will
	% be set at the presentation of the stimulus. The second 
	% argument is a delay for the trigger, if needed to sync timing.
	% The trigger can be any number between 1 and 255 - the 
	% powers of 2 below are only for illustration. Only
	% positive delays have any effect.
	% NOTE: Triggers are set to last 10ms. This can be changed
	% with PTBSetTriggerLength.
	PTBDisplayText('This sends the trigger 1.',{'center'},{1},1);
	PTBDisplayBlank({.5},'Trigger blank');
	PTBDisplayText('This sends the trigger 2, with a 100ms delay.',{'center'},{1},2,.100);
	PTBDisplayBlank({.5},'Trigger blank');
    
    % You can send multiple triggers with a delay for each event too.
    %   Just continue to add trigger value / delay pairs. The delay is 
    %   from the end of the previous trigger.
	PTBDisplayText('This sends the trigger 1 and trigger 2 100ms later',{'center'},{1},[1,0,2,.100]);
	PTBDisplayBlank({.5},'Trigger blank');
	
	% Triggers can also be sent at the completion of a duration, either a 
	% time or a response key. This can be done by augmenting the 
	% duration argument. Note that the trigger delay (i.e. third delay
	% argument) is mandatory here.
	PTBDisplayText('This sends the trigger 4 at display, and 8 at a key press.',{'center'},{{'any',8,0}},4);
	PTBDisplayBlank({.5},'Trigger blank');
	PTBDisplayText('Press q to send 16, p to send 32, or wait to send 64.',{'center'},{{'q',16,0},{'p',32,0},{4,64,0}});
	PTBDisplayBlank({.5},'Trigger blank');

	% Another special duration is -1. This will display the stimulus
	% along with a second stimulus, if you want to make the display 
	% in two parts (e.g. for both sound and text).
	PTBDisplayText('This line is from one call',{'center', [0 -100]},{-1});
	PTBDisplayText('This line is from the next call',{'center', [0 100]},{2});
 	PTBDisplayBlank({.5},'Prepare blank');
	
	% Test the exit key.
	PTBDisplayText('Test the exit key, if you want (probably escape).',{'center'},{'any',5});
 	PTBDisplayBlank({.5},'Exit blank');
	PTBDisplayText('You did not hit the exit key.',{'center'},{2});
 	PTBDisplayBlank({.5},'Exit blank');
	

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Section 2: The different stimlus types that can be displayed.
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	% Many text options can be changed pretty easily.
	PTBSetTextColor([127 127 127]);		% This defaults to white = (255, 255, 255).
	PTBSetTextFont('Times');		% This defaults to Courier.
	PTBSetTextSize(50);				   % This defaults to 30.
	PTBSetBackgroundColor([0,0,0]);		% This defaults to gray - (127, 127, 127).
	
	% NOTE: For now, the background color takes an extra
	% display to take effect. We're looking into it...
	PTBDisplayBlank({.1},'Getting ready.');
	
	% Many lines of text can be displayed as a paragraph.
	% NOTE: The second part of the position argument is the line spacing.
	% This is required.
	PTBDisplayParagraph({'You can display many different types of stimli.','Such as paragraphs'},{'center',30},{5});
	
	% Display some random circles. The color and size arguments can
	% also be just a single constant, instea of one per circle.
	num_circles = 15;
	diameters = zeros(1,0);
	positions = zeros(2,0);
	colors = zeros(3,0);
	for i = 1:num_circles
		positions(:,i) = [ceil(rand*PTBScreenRes.width) ceil(rand*PTBScreenRes.height)];
		colors(:,i) = [ceil(rand(1,3)*256-1)];
		diameters(:,i) = ceil(rand*40) + 10;
	end
	PTBDisplayCircles(positions, diameters, colors, {2});
	PTBDisplayBlank({.5},'Circle blank');
	
	% And some lines. Again, the color and width arguments can
	% be a single constant value.
	num_lines = 15;
	widths = zeros(1,0);
	positions = zeros(2,0);
	colors = zeros(3,0);
	for i = 1:num_lines

		% Need both a start and an end.
		positions(:,2*i-1) = [ceil(rand*PTBScreenRes.width) ceil(rand*PTBScreenRes.height)];
		positions(:,2*i) = [ceil(rand*PTBScreenRes.width) ceil(rand*PTBScreenRes.height)];

		% Same for colors
		colors(:,2*i-1) = [ceil(rand(1,3)*256-1)];
		colors(:,2*i) = [ceil(rand(1,3)*256-1)];
		
		widths(:,i) = ceil(rand*15);
	end
	PTBDisplayLines(positions, widths, colors, {2});
	PTBDisplayBlank({.5},'Line blank');

	% Gabors are always popular. The arguments here are size,
	% position, the tilt of the gabor and the contrast. In this case,
	% one values has to be given for each gabor. Also, the
	% final tag argument is printed in the log.
	% NOTE: These are very slow on some machines.
	num_gabors = 15;
	sizes = zeros(1,0);
	positions = zeros(2,0);
	contrasts = zeros(1,0);
	tilts = zeros(1,0);
	for i = 1:num_gabors
		positions(:,i) = [ceil(rand*PTBScreenRes.width) ceil(rand*PTBScreenRes.height)];
		contrasts(:,i) = ceil(rand*50)+50;
		sizes(:,i) = ceil(rand*200) + 100;
		tilts(:,i) = ceil(rand*45);
	end
	PTBDisplayGabors(sizes, positions, tilts, contrasts, {2}, 'Test Gabors');
	PTBDisplayBlank({.5},'Line blank');

	% Pictures. You can display more than one at a time, if you want.
	% Note that the position argument is in a cell again, to allow the
	% special 'center' argument. The third argument is a scale argument.
	% It can be either a single value, or an x,y pair.
	% The tag at the end, again prints out in the log file. 
	% NOTE: This calls a more general PTBDisplayMatrices function
	% that will display any given matrix of pixels, if you want to 
	% hand-make any stimuli.
	PTBDisplayPictures({'Sample.jpg'}, {'center'}, {1}, {2}, 'Test picture');
 	PTBDisplayBlank({.5},'Picture blank');

	% Sounds. This call initializes the sound driver automatically.
	% This may skip a little in debugging. Only loads .wav files
	% for now.
	PTBDisplayText('Hit a button to play a sound.',{'center'},{'any'});
	PTBDisplayText('This is a sound.',{'center'},{-1});
	PTBPlaySoundFile('Sample.wav',{3});
 	PTBDisplayBlank({.5},'Sound blank');
	
	% Have to have a final screen, to catch any last responses.
	PTBDisplayText('The end.',{'center'},{2});
	PTBDisplayBlank({.1},'Final Screen');
	
	% And finish up. This should always be the last call.
	% It closes the screen and sets everything back to how it was.
    PTBCleanupExperiment;

% This catch, plus PTBHandleError call allows matlab
% to recover when psychtoolbo crashes. Keep this
% in, with the try call above.
catch
	PTBHandleError;
end


