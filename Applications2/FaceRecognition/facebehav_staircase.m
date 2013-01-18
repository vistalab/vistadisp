function stim = facebehav_staircase(task, subject, varargin);
% Noise staircase for face behavior experiment.
%
% stim = facebehav_staircase([task, subject, screenNum, task, minLevel, maxLevel, numLevels]);
%
%
% 07/13/09 ras: dug up this old code for the face behavior experiments.
if notDefined('task'),			task = 'inverted';				end
if notDefined('subject'),		subject = 'foo';				end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% parameters -- change here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% stimulus parameters
stim.task = task;
stim.subject = subject;
stim.date = datestr(now);
stim.runCode = mfilename;
stim.noiseType = -1;			% -1 for partial phase-scrambling;
								% >= 0 to specify order N of 1/(f^N) noise
stim.imageDur = 0.07;			% max time (in secs) to display each image
stim.trialDur = 1.5;			% time (in seconds, from start of trial) to accept keypresses
stim.ISI = 2;					% time to wait between trials
stim.nTrials = 150;				% max # of trials
stim.feedback = 0;				% 0 for no feedback, 1 for sound feedback
stim.faceSize = 58;             % size of stimulus (pixels diameter)
stim.faceAngle = 0;				% polar angle at which to show faces (radians)
stim.faceEcc = 0;			    % eccentricity at which to show faces (pixels)
stim.fixPos = [0 0];		    % [x y] pixels relative to screen center for fixation
stim.screenRes = [1680 1050]; 	% resolution to use for screen
stim.runPriority = 7;           % priority with which to run stim process
stim.bgColor = 127;				% value in lookup table for gray background color
stim.codeDir = fileparts(which(mfilename));  % directory containing code
stim.dataDir= pwd;				% folder in which to save data
stim.contrast = 0.20;			% contrast scaling to apply to each image before applying noise
stim.numDimFrames = 4;			% # of frames at beginning of trial to dim fixation (to signify new trial)
stim.reportResults = 1;			% flag to report on the user performance after the trial ends
stim.saveTemp = 1;			    % flag to save a temp data file after each trial
stim.displayName = prefsDisplayName;


% keys to press for match, nonmatch stimuli, respectively
stim.responseKeys = {KbName('1') KbName('2')};

%% staircase parameters
% noise levels to use for embedding images
stair.staircasedParameter = 'noise';
stair.levels = linspace(1, 0, 25);

% The first level for each staircase -- this determines # of staircases
% 7/27/09: for this setting, I am NOT staircasing: just trying an even # of
% trials per noise level. I'm checking if this is actually more efficient.
stair.startLevels = [1:25];

% these vectors specify the number consecutive (correct, incorrect) trials
% before adusting the noise level, and the step sizes to use when we do
% adjust. The step size vectors can specify a varying level of step sizes;
% e.g., [3 2 1] means first step by 3, then 2, then 1. All
% subsequent reversals will use the last step size (1 in this case).
stair.numCorrectForStep = 6;
stair.numIncorrectForStep = 6;
stair.correctStepSize = [3 2 1];
stair.incorrectStepSize = [3 2 1];

% # of reversals before each staircase is considered done
stair.maxReversals = 10;

%% parse options
for ii = 1:2:length(varargin)
	% certain parameters should be kept in the 'stair' struct
	stairParamNames = {'startlevels' 'maxnumtrials' 'maxreversals' 'noiselevels'};
	if ismember( lower(varargin{ii}), stairParamNames )
		if isnumeric(varargin{ii+1})
			eval( sprintf('stair.%s = %s', varargin{ii}, num2str(varargin{ii+1})) );
		else
			eval( sprintf('stair.%s = %s', varargin{ii}, varargin{ii+1}) );
		end
		
	else
		% put other parameters in stimulus params
		if isnumeric(varargin{ii+1})
			eval( sprintf('stim.%s = %s', varargin{ii}, num2str(varargin{ii+1})) );
		else
			eval( sprintf('stim.%s = %s', varargin{ii}, varargin{ii+1}) );
		end
		
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create stimulus struct with images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stim = facebehav_createStaircase(stim);


%% Initialize screen
stim = OpenDisplay(stim);

%% run the staircase experiment
try,
    [stim responses stair] = RunStaircase(stim, stair);
catch,
    % clean up if error occurred
    Screen('CloseAll');
    setGamma(0);
    Priority(0);
    ShowCursor;
    rethrow(lasterror);
end;

%% clean up screen, save data
stim = CloseDisplay(stim, stair, responses);


return
% /--------------------------------------------------------------/ %




% /--------------------------------------------------------------/ %
function [stim responses stair] = RunStaircase(stim, stair);
% Main function to run the staircase experiment.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize variables for staircase;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init responses struct
responses.task = ['staircase: ' stim.task];
responses.staircasedParameter = 'noise';

% initialize staircase params
stair.curStair = 1; 
stair.curLevel = stair.startLevels;
stair.noise = stair.levels(stair.curLevel(1));
stair.history = stair.startLevels;
stair.staircasedParameter = 'noise';
stair.numStaircases = length(stair.startLevels);
stair.numLevels = length(stair.levels);
stair.maxNumTrials = stim.nTrials / stair.numStaircases;
stair.done = zeros(1, stair.numStaircases);
stair.reversals = zeros(1, stair.numStaircases);
stair.numCorrect = zeros(1, stair.numStaircases);
stair.numConsecCorrect = zeros(1, stair.numStaircases);
stair.numConsecIncorrect = zeros(1, stair.numStaircases);
stair.trialCount = zeros(1, stair.numStaircases);
stair.runDirection = zeros(1, stair.numStaircases);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make sounds for feedback:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if stim.feedback==1
	stim.sounds.noResponseSound = soundFreqSweep(200, 300, .1);
	stim.sounds.validResponseSound = soundFreqSweep(300, 800, .1);
	stim.sounds.invalidResponseSound = soundFreqSweep(2000,200,.1);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize parameters for main loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% temp variables
exitFlag = 0;
trial = 1;
keycode = zeros(1,128);
elapsedTime = 0;

% shortcut variables: may clean this up, but it's eaiser to keep these
% around:
win = stim.display.windowPtr;
X = stim.display.numPixels(1);
Y = stim.display.numPixels(2);

% save the stimulus status before we start in the temp file
if stim.saveTemp==1
	save(stim.tempDataFile, 'stim', 'responses', 'stair');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For target detection task, show target for several seconds
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Front screen
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isequal(stim.task, 'identify')
	% (this is not yet coded 07/13/09)
	stim = facebehav_showTarget(stim);
else
    pressKey2Begin(stim.display, [], [], stim.taskStr);
end

% put up a blank screen
blank = Screen('MakeTexture', win, repmat(stim.bgColor, [Y X]));
Screen('DrawTexture', win, blank);
drawFixation(stim.display, 1);
Screen('Flip', win);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main loop -- do staircase
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
runStart = GetSecs;
for trial = 1:stim.nTrials

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Generate upcoming trial
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 	stair = ReadFromStaircase(stair, stim, trial);
	stim = facebehav_staircaseTrial(stim, stair, trial, win, X, Y);
	responses.level(trial) = stair.curLevel(stair.curStair);

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Trial loop
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	curFrame = 1;
	keyPressed = 0;
	elapsedTime = 0;
	stim.trialStart(trial) = GetSecs;
	while  (keyPressed==0) % (elapsedTime < stim.trialDur) &
		% if time for next frame, put frame up
		if elapsedTime >= stim.seqtiming(curFrame)
			Screen('DrawTexture', win, stim.textures(curFrame));
			drawFixation(stim.display, 1);
			Screen('Flip', win);
			curFrame = curFrame + 1;
        end

        if elapsedTime > .2
            % check for keypress
            [keyisdown secs keycode] = KbCheck;
            
            % if key is down, record keypress
            if keyisdown
                responses.when{trial} = GetSecs;
                keyPressed = 1;
                
                % exit gracefully if ESC key pressed
                if keycode(54)==1,
                    exitFlag = 1;
                    break;
                end
            end
        end
        
		elapsedTime = GetSecs - stim.trialStart(trial);
	end

	% clean up the textures from memory
    Screen('DrawTexture', win, blank);
    drawFixation(stim.display, 1);
    Screen('Flip', win);
    Screen('Close', stim.textures);

	%%% update responses and staircase
	responses = UpdateResponses(responses, stim, trial, stair,...
								keycode, keyPressed);
	stair = UpdateStaircase(stair, responses, trial);

	%%% provide feedback if selected
	if stim.feedback==1
		if responses.correct(trial)==1
			feedbackSound = stim.sounds.validResponseSound;
		elseif responses.keyPressed(trial)==1
			feedbackSound = stim.sounds.invalidResponseSound;
		else
			feedbackSound = stim.sounds.noResponseSound;
		end
		sound(feedbackSound);
	end

	if all(stair.done),	exitFlag = 1;	end

	% wait out the inter-stimulus interval for the next trial
	while elapsedTime < stim.ISI
		elapsedTime = GetSecs - stim.trialStart(trial);
	end
	
	if stim.saveTemp==1
		% update temp save file
		save(stim.tempDataFile, 'responses', 'stair', '-append');
	end
	
	if exitFlag, break;		end
	
end

% report timing
fprintf('Done. Total stimulus duration: %i min %2.1f sec. \n', ...
	floor((GetSecs-runStart)/60), mod((GetSecs-runStart), 60));

return
% /--------------------------------------------------------------/ %




% /--------------------------------------------------------------/ %
function stim = OpenDisplay(stim);
% initialize a screen for the staircase experiment.
% This both initializes the display struct, and opens a screen, getting
% ready to load the stimuli. It returns the window pointer in win (as well
% as in stim.display.windowPtr, win is just easier to hold in the main
% code), and the screen size in X and Y (as well as
% stim.display.numPixels).
stim.display = loadDisplayParams(stim.displayName);
stim.display.numPixels = stim.screenRes;
stim.display.backColorIndex = stim.bgColor;
stim.display.backColorRgb = [stim.bgColor stim.bgColor stim.bgColor 255];
stim.srcRect = [0 0 stim.display.numPixels];
stim.destRect = stim.srcRect;

% update the display params to match the actual display settings
stim.display.fixX = round(stim.display.numPixels(1)/2) + stim.fixPos(1);
stim.display.fixY = round(stim.display.numPixels(2)/2) + stim.fixPos(2);
stim.display.fixGrid = 0;
stim.display.fixSizePixels = 2;

% check for OpenGL
AssertOpenGL;

% to skip annoying warning message on display (but not terminal)
Screen('Preference', 'SkipSyncTests', 1);

% Open the screen
stim.display = openScreen(stim.display);

% Put up 'Loading' message
dispStringInCenter(stim.display, 'Loading next experiment...', .5, 24);

% HideCursor;

% set priority
Priority(stim.runPriority);

return
% /--------------------------------------------------------------/ %




% /--------------------------------------------------------------/ %
function responses = UpdateResponses(responses, stim, trial, stair, ...
							   	     keycode, keyPressed);
%% updates response struct with information on current trial.
if keyPressed 	
	% a response was made for the current trial
	responses.RT(trial) = responses.when{trial} - stim.trialStart(trial);
	whichKey = find(keycode);
    responses.whichKey(trial) = whichKey(1);
	responseIndex = cellfind(stim.responseKeys, whichKey(1));
    if isempty(responseIndex)
        % invalid keypress
        responses.correct(trial) = 0;
        responseIndex = -1;
        if stim.feedback==1
           % make invalid keypress sound
           sound(stim.sounds.invalidResponseSound);
        end
    elseif isequal(responseIndex, stim.isMatch(trial))
        % valid, correct keypress
		responses.correct(trial) = 1;
    else
        % valid, but incorrect, keypress
		responses.correct(trial) = 0;
    end
	responses.responseIndex(trial) = responseIndex;
else
	% no responses during the current trial
	responses.RT(trial) = NaN;
	responses.whichKey(trial) = NaN;
	responses.when{trial} = 'Didn''t';
	responses.correct(trial) = 0;
	responses.responseIndex(trial) = 0;
end

responses.keyPressed(trial) = keyPressed;
responses.noiseLevel(trial) = stair.noise;
responses.level(trial) = stair.curLevel(stair.curStair);
responses.curStair(trial) = stair.curStair;
responses.isMatch(trial) = stim.isMatch(trial);
responses.imgNum(trial) = stim.imgNum(trial);

return
% /--------------------------------------------------------------/ %




% /--------------------------------------------------------------/ %
function stair = UpdateStaircase(stair, responses, trial);
%%%%% Iterates staircase after a trial
% (based on newer doStaircase code, as of 07/2009)

% we're going to index a lot of vectors by the current stair index -- let's
% assign a short variable name to keep things hopefully more readable:
S = stair.curStair;  

% increment the trial count for this staircase
stair.trialCount(S) = stair.trialCount(S) + 1;

% adjust the adjustable
if responses.correct(trial)==1
    stair.numConsecCorrect(S) = stair.numConsecCorrect(S) + 1;
    stair.numConsecIncorrect(S) = 0;
 
    % has the user been correct enough trials in a row to make it harder?
    if mod(stair.numConsecCorrect(S), stair.numCorrectForStep) == 0
        % make the current level harder (lower level)
        if stair.reversals(S)+1 > length(stair.correctStepSize)
            delta = stair.correctStepSize(end);
        else
            delta = stair.correctStepSize(stair.reversals(S)+1);
        end
        stair.curLevel(S) = stair.curLevel(S) - delta;
        
        % check to see if this is a reversal
        % if the current run is negative (the 'incorrect' direction), then meeting
        % the numConsecCorrect criterion constitutes a reversal.
        if stair.runDirection(S) == -1
            stair.reversals(S) = stair.reversals(S) + 1;
            stair.reversalNoiseLevel(stair.reversals(S),S) = stair.noise;
            stair.runDirection(S) = +1;
            
        elseif stair.runDirection(S) == 0
            % first trial: initialize the run direction
            stair.runDirection(S) = +1;
            
        end
    end
else
    stair.numConsecIncorrect(S) = stair.numConsecIncorrect(S) + 1;
    stair.numConsecCorrect(S) = 0;
    
    % has the user been correct enough trials in a row to make it easier?
    if mod(stair.numConsecIncorrect(S), stair.numIncorrectForStep) == 0
        % make the current level easier (higher level)  
        if stair.reversals(S)+1 > length(stair.incorrectStepSize)
            delta = stair.incorrectStepSize(end);
        else
            delta = stair.incorrectStepSize(stair.reversals(S)+1);
        end        
        stair.curLevel(S) = stair.curLevel(S) + delta;
        
        % check to see if this is a reversal
        % if the current run is positive (the 'correct' direction), then meeting the
        % numConsecIncorrect criterion constitutes a reversal.
        if stair.runDirection(S) == +1
            stair.reversals(S) = stair.reversals(S) + 1;
            stair.reversalNoiseLevel(stair.reversals(S),S) = stair.noise;
            stair.runDirection(S) = -1;
            
        elseif stair.runDirection(S) == 0
            % first trial: initialize the run direction
            stair.runDirection(S) = +1;
                    
        end
    end
end

%% ensure adjustable isn't out of range
% Note that if we have gone out of range, then we should (and do) count this as a
% reversal because it means the observer has hit one of the boundaries.  If we don't
% do something like this, the observer may get stuck at one of the bounds and do many
% unnecessary trials there!
if stair.curLevel(S) > stair.numLevels
    % count this as a reversal
    stair.reversals(S) = stair.reversals(S) + 1;
    stair.reversalNoiseLevel(stair.reversals(S),S) = stair.noise;
    
    % constrain curLevel to the bounds
    stair.curLevel(S) = stair.numLevels;
    
elseif stair.curLevel(S) < 1
    % count this as a reversal
    stair.reversals(S) = stair.reversals(S) + 1;
    stair.reversalNoiseLevel(stair.reversals(S),S) = stair.noise;
    
    % constrain curAdjustIndex to the bounds
    stair.curLevel(S) = 1;
end

% update the history field for this staircase
stair.history(stair.trialCount(S),S) = stair.curLevel(S);

% check to see if we are done with this staircase
if (stair.trialCount(S) >= stair.maxNumTrials) ...
        || (stair.reversals(S) >= stair.maxReversals)
    stair.done(S) = 1;
end

% choose a staircase to use for the next trial (curStair):
% choose the next curStair pseudorandomly, giving preference
% to staircases that are less done.
% take only stairs in range that aren't done
availStairs = find(stair.done==0);

if isempty(availStairs)	
	stair.curStair = ceil(rand*stair.numStaircases);
else
	temp = stair.trialCount(availStairs) - 0.2 * randn(size(availStairs));
	[ignore ind] = sort(temp);
	stair.curStair = availStairs(ind(1));
end

%%%% set the noise level for the next trial
stair.noise = stair.levels( stair.curLevel(stair.curStair) );

return
% /---------------------------------------------------------------------/ %




% /---------------------------------------------------------------------/ %
function stim = CloseDisplay(stim, stair, responses);
%% close the PsychToolbox display and finish up.
%% This also concatenates all important data into the stim struct
closeScreen(stim.display);
Screen('CloseAll');
setGamma(0);
Priority(0);
ShowCursor;

% compute performance on the task
if stim.reportResults, 
    opts = {'doPlot'}; 
else, 
    opts = {};
end

try
    [analysis, stair] = facebehav_analyzeStaircase(stair, responses, opts);
catch
	fprintf('Couldn''t compute staircase performance.')
	disp(lasterr)
	tmp = lasterror;
	tmp.stack.file
	tmp.stack.line
	
	analysis = [];
end


% put everything into the stim struct
stim.stair = stair;
stim.responses = responses;
stim.analysis = analysis;

if ~isempty(stim.subject)
	%% save the performance data
	save(stim.dataFile, 'stim');
	fprintf('Saved scan parameters / subject performance in %s.\n', stim.dataFile);
end

return

