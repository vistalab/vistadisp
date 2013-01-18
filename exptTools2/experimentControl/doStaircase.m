function [dataSum] = doStaircase(display, stairParams, stimParams, trialGenFuncName, priority, logFID, varargin)
%
% [dataSum] = doStaircase(display, stairParams, stimParams, trialGenFuncName, [priority], [logFID],
%															['optionFlag1'], ['optionFlag2'], ...)
% display:           (struct) display parameters
%
% stairParams:       (struct) staircase parameters (see below)
%
% stimParams:        (struct) stimulus parameters
%
% trialGenFuncName:  (string) specifies the function called to generate the stimuli.
%                             This function must exist in the current matlab path and
%                             must assume the following form (replacing trialGenFuncName
%                             with the correct function name):
%                               [trial, data] = trialGenFuncName(display, stimParams, data)
%                             Use 'data' for whatever you would like to be preserved from
%                             trial to trial (pre-computed images, colormaps, etc.). Note 
%                             that 'data' will be independent across interleaved staircases
%                             unless stairParams.useGlobalData==true, in which case all
%                             interleaved staircases will share the same data structure.
%                             If stairParams.useGlobalData==true, the field 'stairNum' will
%                             be automatically appended to the shared data struct so that
%                             trialGenFuncName can tell which staircase is currently running.
%                             
%
% priority:          (int)    optional- specifies run priority (0-7, 0 is default)
%
% logFID:            (int)    optional- specifies where log data go- default is the screen.
%                             if logFID is a vector, each of the files specified will be
%                             written to.  All files written as text files.
%
% optionFlags:       (string) Specify any number of the following options:
%                             precomputeFirstTrial: this option is really only useful
%                                                   if your trialGenFunction saves
%                                                   stuff in the 'data' structure that
%                                                   will save time when building
%                                                   subsequent trials.
%                             precomputeAllTrials:  this option builds all the trials
%                                                   ahead of time.  It may take a while
%                                                   to do this, especially if you have
%                                                   alot of adjustableVarValues!  Also
%                                                   note that randomization will be
%                                                   systematic- trials in a staircase
%                                                   with the same adjustableVarValue
%                                                   will have the same randVarValues
%                                                   and the same alternativeVarValue.
%                                                   You can make things seem more random
%                                                   by doing several staircases.  Or, you
%                                                   may want to do the precomputing in
%                                                   your trialGenFunction and leave this
%                                                   option off.
%
%
%
% stairParams structure:
%
%   stairParams.alternativeVarName = 'testPosition';
%   stairParams.alternativeVarValues = ['L' 'R'];
%		This must be a fieldname of stimParams.  The values are selected from the
%		list at random and a trial is counted as 'correct' if the alternative
%		index and the response index are the same.  (e.g., if the second
%		alternative was presented and the second response of the response set
%		was entered, then the trial will be counted as correct.)
%
%   stairParams.adjustableVarName = 'varName';
%		This must be a fieldname of stimParams.  The values are selected
%		systematicallly from stairParams.stimLevels according to the rules
%		defined by the parameters below.
%
%   stairParams.adjustableVarStart = [1 1];
%		The length of this vector determines the number of interleaved staircases
%		(referred to as numStairs in this file).
% 		Each value in this vector is an index into stairParams.adjustableVarStart
%		which determines where each of the staircases start.
%
%   stairParams.adjustableVarValues = [10.^[0:-.1:-2]];
%		An 1 x N vector or numStairs x N matrix specifying the N different stimulus
%		levels (N can be any value).  If the number of rows is < numStairs, then the
%		adjustableVarValues for all subsequent staircases are taken from the levels
%		of the last staircase specified (e.g., if it is 1 x N, then all staircases
%		will use the same levels).
%
%   stairParams.randomVars = {'varName' [0:3:9]};
%		This is a cell array that may contain any number of rows, where each row is
%		a stimParams field name (the variable you want randomized) and a vector listing
%		the possible values.  DoStaircase will randomly assign a value from the list
%		to the variable(s) before each trial.
%
%   stairParams.curStairVars = {'varName', [1 2 3]};
%		This is a cell array that may contain any number of rows, where each row is
%		a stimParams field name (the variable you want varied) and a vector listing
%		the possible values.  DoStaircase will assign a value from the list
%		to the variable(s) before each trial, based on the current staircase.
%		That is, the first value will be used when doing a trial for the first
%		interleaved staircase, the second value used for the second staircase, etc.
%
%   stairParams.numCorrectForStep = 2;
%   stairParams.numIncorrectForStep = 1;
%		These two determine how many consecutive correct and how many consecutive
%		incorrect responses are needed before adjusting the adjustableVarValue.
%
%   stairParams.correctStepSize = 2;
%   stairParams.incorrectStepSize = 1;
%		These two determine how many index units (of stairParams.stimLevels) to
%		jump with a correct (or incorrect) response sequence that meets the
%		criteria defined by stairParams.numCorrectForStep/.numIncorrectForStep.
%
%   stairParams.maxNumTrials = 100;
%   stairParams.maxNumReversals = 10;
%		The staircase ends when either of these conditions are met.
%
%   stairParams.feedback = 'click';
%		feedback options: 'none', 'click', 'auditory'.  ('click' clicks when a
%		valid response is registered, but does not indicate correct/incorrect.)
%		You can also provide feedback through the trial structure, including more
%		elaborate visual feedback.
%
%   stairParams.responseSet = '13';
%		This is a string listing acceptable responses (no spaces!)
%		Alternative 1 is the first character in this sting, alternative 2
%		the second, and so on.  Do not use q or Q- these characters are
%		special and cause the experient to abort. If this field is a cell
%		array, then each element of the cell array is considers a valid set
%		of responses for the corresponding alternative. E.g., for a
%		2-alternative case where you want either 1 or 2 to be a correct
%		response for alt 1 and either 3 or 4 to be a correct response for
%		alt 2, use: stairParams.responseSet = {'12','34'};
%       If this field is omitted, then doStaircase will expect the trial to
%       return a response.
%
%	stairParams.conditionName = {'cond1'; 'cond2'};
%		This is a cell array where each row is the condition name for a staircase.
%		For example, the first row should contain the condition name for the first
%		staircase, the second row the name for the second staircase, and so on.
%		If there are fewer rows than staircases, the the staircases without
%		specified naems get the name of the last named staircase.  If this field
%		is omitted, all staircases get the name of the adjustableVar.
%
%   stairParams.iti = 0.1;
%       Inter-trial interval, in seconds. (defaults to 0)
%
%   stairParams.useGlobalData = false;
%       Flag to determine whether staircase 'data' will be independent across 
%       interleaved staircases or shared by all staircases. If true, the field 
%       'stairNum' will be automatically appended to the shared data struct so
%       trialGenFuncName can tell which staircase is currently running.
%       (Defaults to false; form mor einfo, see trialGenFuncName above.)
%       
%   stairParams.saveDataVars = {'string var 1', 's'; 'digit var 2', 'd'};
%       Flag variables that you would like saved from the data structure on
%       a trial by trial basis.  Column one of the cell array should
%       contain the variable names as a string, and column two should
%       indicate, for each respective row, whether the data contained in it
%       is a string or a number (digits). 
%
%   stairParams.customInstructions = 'command to be run';
%       Write in the command you'd like to run instead of the default.  For
%       example: showInstructions(5,8,22); will execute that line.  Inputs
%       must be strings.
%
%   stairParams.prFlag = 1;
%       Setting this to 1 starts the inter-trial interval timer after the
%       response has been made.  Setting it to 0, or not setting it at
%       all, will start the inter-trial interval as soon as the stimulus is
%       no longer present.
%
% stimParams structure:
%
%   I added some things to this structure, though they might seem unrelated
%   to the stimuli.  I chose to do this because stimParams gets passed in
%   to each trial, and some of the things I needed control of occurred at
%   that level. - RFB
%
%   stimParams.quitKey = 'g';
%       Set the quit key to whatever you'd like with a string.
%
%   stimParams.inputDevice = 5;
%       Set the input device index for cases in which you're using an
%       external controller.
%   
% 98/10/08 coded by Bob Dougherty (aka RFD)
% 98/10/14 got into a working form by Bob Dougherty (lots of advice from WAP and BTB)
% 98/10/20 RFD: added varargin option flags to precompute trials.  Modified 'data' to be
%				a cell array so that each interleaved staircases can have their own
%				data.  Also, added reversalStimLevel to dataSum.
% 98/10/26 RFD: added history field to dataSum (keeps a history of the adjustableVarValue
%				presented on each trial).  Also added "save('dataSumTemp', 'dataSum');"
%				so that the summary data are not lost in the event of an error or crash.
% 98/10/26 RFD: added stairParams.conditionName.
% 98/11/02 RFD: fixed precomputeFurstTrial so that it sets the first adjustableVarValue
%				before building the trial.
% 98/11/04 RFD: Added code to clear the keyboard queue before each trial so that any
%				inadvertant keypresses will not count as responses.
% 98/11/06 RFD: Fixed the reversal-checking code so that it works properly now!
% 98/11/13 RFD: Fixed the reversal-checking code so that it does the right thing
%				without bombing when there are more than one interleaved staircases.
% 98/11/24 RFD: Fixed the code which checks to see if all the staircases have finished.
%				(The error was only evident with multiple staircases- it was ending
%				when at least one of the staircases had reached it's stop criteia- now it
%				ends only when _all_ the staircases have reached their stop criteria.)
% 98/12/04 RFD  Modified the adjustable var algorithm so that it counts as a reversal
%               a trial that must be constrained to the adjustable var boundaries.
%               (e.g., if the observer hits the minimum adjustable var value and the
%               algorithm tries to go even lower, it will count as a reversal.)
%               This avoids excessively long runs where the observer has hit the
%               upper or lower boundary (because without this fix, no true reversals
%               will be tallied).
% 2008/05/14 JW     Added a check to check whether user wants to display timing
%                   for each trial (default is to show timing). Flag can be set
%                   in stairParams.showTiming.
% 2009.01.20 RFD:   added code to allow multiple response keys per alternative.
% 2009.02.04 RFD:   cleaned up some formatting and added the option to share staircase 
%                   data across all interleaved staircases (useGlobalData flag).
% 2009.07.01 RFB:   Added option to change instructions screen
%                   (stairParams.customInstructions), add a custom input
%                   device (stimParams.inputDevice), change the quit key
%                   (stimParams.quitKey), or save variables within the data
%                   structure on a trial by trial basis
%                   (stairParams.saveDataVars).
%                   
%                   I also changed the function of ITI - it now begins the
%                   timer after the trial has actually completed.  Thus,
%                   you can set a space between otherwise rapid trials to
%                   allow subjects breathing room.  Previously this just
%                   didn't seem to be working as I'd like.
%
% 2009.08.04 RFB:   Added stairParams.initTrialCount option.  This gives
%                   you the order in which your trials occurred, across staircases.
%                   Set to 1 to initialize the temp file 'tctemp.mat' which will
%                   keep track across multiple initializations of
%                   doStaircase, should you be running it in a loop as I do
%                   depending on the experiment.  Subsequent runs through
%                   should be then set to 0 to indicate you've already
%                   initialized the file, and to simply load your progress.
%                   
%                   Set to 2 to indicate you want to keep track of trials
%                   across staircases, but don't want to save out a temp
%                   file since you're only calling doStaircase once.  In a
%                   higher level function at the end of the program, it's
%                   probably useful or good behavior in general to delete
%                   the temp file since it's of no use between
%                   experimental sessions.  In any case, it will be
%                   written over by the next initialization.
% 2009.09.18 RFB:   Be careful using the internal keyboard with numbers for
%                   responses, for some reason KbQueueCheck has a bit of a hissy fit with
%                   this and doesn't register them accurately (as far as I
%                   can tell).
% 2010.07.08 JW:    Added optional input arg 'plotEachTrialFlag' to plot 
%                   results after every trial, if requested. Useful for debugging. 

% Seed random number generator
ClockRandSeed;

% Set up flags/set defaults where necessary
if nargin < 4
    error('not enough input arguments- type help doStaircase');
end
if ~isfield(stairParams,'etFlag') % Eye tracking??
    stairParams.etFlag = 0;
end
if ~exist('priority', 'var')
    priority = 0;
end
if ~exist('logFID', 'var')
    logFID = 1;
end
% Allow display of trial stimulus duration
if isfield(stairParams, 'showTiming')
    showTimingFlag = stairParams.showTiming;
else
    showTimingFlag = true;
end
% Allow custom instructions script
if isfield(stairParams,'customInstructions')
    instructions = stairParams.customInstructions;
else
    instructions = 'pressKey2Begin(display,0);';
end
% Allow custom quit key
if isfield(stimParams,'quitKey')
    quitKey = stimParams.quitKey;
else
    quitKey = 'q';
end
% Allow different start points for inter-trial interval
if isfield(stairParams,'prFlag')
    prFlag = stairParams.prFlag;
else
    prFlag = 0;
end
% Determine if we need to keep track of the trial count
if isfield(stairParams,'initTrialCount')
    tcName = fullfile(stimParams.dataDir,'tctemp.mat');
    if stairParams.initTrialCount==1 || stairParams.initTrialCount==2
        trialCounts = 0;
    elseif stairParams.initTrialCount==0
        load(tcName);
    end
else
    stairParams.initTrialCount = 2;
    trialCounts = 0;
end
% Initialize all of the variables we'll be saving from the trial program
if isfield(stairParams,'saveDataVars')
    for i=1:size(stairParams.saveDataVars,1)
        if strcmp(stairParams.saveDataVars{i,2},'d') % Saving digits
            saveData{i,1} = sprintf('dataSum(curStair).%s = [];',stairParams.saveDataVars{i,1});
            saveData{i,2} = sprintf('dataSum(curStair).%s(stairHistory.numTrials(curStair)) = data.%s;',stairParams.saveDataVars{i,1},stairParams.saveDataVars{i,1});
        elseif strcmp(stairParams.saveDataVars{i,2},'s') % Saving strings
            saveData{i,1} = sprintf('dataSum(curStair).%s = {};',stairParams.saveDataVars{i,1});
            saveData{i,2} = sprintf('dataSum(curStair).%s{stairHistory.numTrials(curStair)} = data.%s;',stairParams.saveDataVars{i,1},stairParams.saveDataVars{i,1});
        else
            error('Please indicate whether the variable to be saved consists of digits or strings using the proper syntax.');
        end
    end
end
% Get keyboard input device (see help file for specifics)
device = getBestDevice(display);
% Generate keyList for checking responses after the trial
keyList = zeros(1,256);
includeKeys = [];
for i=1:size(stairParams.responseSet,2)
    if(iscell(stairParams.responseSet))
        for ii=1:size(stairParams.responseSet{i},2)
            includeKeys = [includeKeys KbName(stairParams.responseSet{i}(ii))];
        end
    else
        includeKeys = [includeKeys KbName(stairParams.responseSet(i))];
    end
end
includeKeys = [includeKeys KbName(quitKey)];
includeKeys = unique(includeKeys);
keyList(includeKeys) = 1; 
% Set some more defaults
if ~isfield(stairParams, 'numIncorrectBeforeStep')
    stairParams.numIncorrectBeforeStep = 1;
end
if ~isfield(stairParams, 'randomVars')
    stairParams.randomVars = {};
end
if ~isfield(stairParams, 'feedback')
    stairParams.feedback = 'auditory';
end
if ~isfield(stairParams, 'curStairVars')
    stairParams.curStairVars = {};
end
if ~isfield(stairParams, 'conditionName')
    if size(stairParams.curStairVars,1)<1
        stairParams.conditionName = stairParams.adjustableVarName;
    else
        for ii=1:length(stairParams.adjustableVarStart)
            for jj=1:size(stairParams.curStairVars,1)
                stairParams.conditionName{ii,jj*2-1} = stairParams.curStairVars{jj,1};
                stairParams.conditionName{ii,jj*2} = ...
                    stairParams.curStairVars{jj,2}(min(length(stairParams.curStairVars{jj,2}),ii));
            end
        end
    end
end
if ~isfield(stairParams, 'iti')
    stairparams.iti = 0.0;
end
if ~isfield(stairParams, 'useGlobalData')
    stairParams.useGlobalData = false;
end

numStairs = length(stairParams.adjustableVarStart); % We have as many stairs as we have starting points for staircases
numLevels = size(stairParams.adjustableVarValues, 2); % Count the number of levels we were given

% Generate auditory feedback
if isfield(stairParams, 'feedback')
    if strcmp(stairParams.feedback,'auditory')
        correctSnd = soundFreqSweep(200, 500, .1);
        incorrectSnd = soundFreqSweep(500, 200, .1);
    elseif  strcmp(stairParams.feedback,'click')
        % make them both the same- a click to acknowledge the response
        correctSnd = soundFreqSweep(500, 1000, .01);
        incorrectSnd = soundFreqSweep(500, 1000, .01);
    else
        correctSnd = [];
        incorrectSnd = [];
    end
else
    correctSnd = [];
    incorrectSnd = [];
end

% ensure the starting values are in range
if any(stairParams.adjustableVarStart>numLevels) || any(stairParams.adjustableVarStart<1)
    error('Starting values are out of range (range = 1 to number of stim levels).\n');
end

% initialize all the bookkeeping stuff
if(stairParams.useGlobalData)
    data.curStairNum = 0;
else
    data = cell(numStairs,1);
end

% Initialize structure to keep track of staircase parameters
stairHistory.numTrials = zeros(1,numStairs); % Number of trials run at 
stairHistory.numConsecCorrect = zeros(1,numStairs);
stairHistory.numConsecIncorrect = zeros(1,numStairs);
stairHistory.runDirection = ones(1,numStairs);
stairHistory.curAdjustIndex = stairParams.adjustableVarStart; % At what level each staircase will begin its trials
stairHistory.numReversals = zeros(1,numStairs); % Tally of the number of reversals within each staircase
stairHistory.done = zeros(1,numStairs); % Keeps track of which staircases have been completed

numAlternatives = length(stairParams.alternativeVarValues);
numLevelVectors = size(stairParams.adjustableVarValues, 1);

% initialize the dataSum stuff
for curStair=1:numStairs
    dataSum(curStair).history = [];
    dataSum(curStair).response = [];
    dataSum(curStair).correct = [];
    dataSum(curStair).trialCounts = [];
    dataSum(curStair).condName = stairParams.conditionName(min(size(stairParams.conditionName,1),curStair),:);
    dataSum(curStair).stimLevels = stairParams.adjustableVarValues(min(curStair,numLevelVectors),:);
    dataSum(curStair).numTrials = zeros(1,numLevels);
    dataSum(curStair).numCorrect = zeros(1,numLevels);
    dataSum(curStair).reversalStimLevel = ones(1,stairParams.maxNumReversals)*NaN;
    if stairParams.etFlag
        dataSum(curStair).etxForm = {};
        dataSum(curStair).etData = {};
    end
    if exist('saveData','var')
        for i=1:size(saveData,1)
            eval(saveData{i,1});
        end
    end
end

% build the appropriate trialGenFuncName
if(stairParams.useGlobalData)
    trialGenFuncName = strcat(trialGenFuncName, '(display, stimParams, data)');
else
    trialGenFuncName = strcat(trialGenFuncName, '(display, stimParams, data{curStair})');
end

% parse the option flags
for ii=1:length(varargin)
    switch varargin{ii}
        case 'precomputeFirstTrial',
            % build the trial
            fprintf('Building the first trial for each staircase.\n');
            if stairParams.useGlobalData % if data file is shared, we don't need to precompute multiple staircases
                stairCount = 1;
            else  % if separate data file for each staircase, need to precompute first trial of each staircase
                stairCount = 1:numStairs;
            end
            for curStair = stairCount % 1:numstairs
                adjustValue = stairParams.adjustableVarValues(min(curStair,numLevelVectors), 1);
                stimParams.(stairParams.adjustableVarName) = adjustValue;
                stimParams.(stairParams.alternativeVarName) = stairParams.alternativeVarValues(1);
                % set the curStair variable values in the appropriate stimParams fields
                for i=1:size(stairParams.curStairVars, 1)
                    curStairVal(i) = stairParams.curStairVars{i,2}(min(curStair,length(stairParams.curStairVars{i,2})));
                    stimParams.(stairParams.curStairVars{i,1}) = curStairVal(i);
                end
                if(stairParams.useGlobalData)
                    data.curStairNum = curStair;
                    [trial, data] = eval(trialGenFuncName);
                else
                    [trial, data{curStair}] = eval(trialGenFuncName);
                end
            end
        case 'precomputeAllTrials',
            for curStair = 1:numStairs
                fprintf('Building trials for staircase %d\n', curStair);
                for adjustIndex = 1:numLevels
                    adjustValue = stairParams.adjustableVarValues(min(curStair,numLevelVectors), adjustIndex);
                    % set the adjustable variable value
                    stimParams.(stairParams.adjustableVarName) = adjustValue;
                    % set the random variable values in the appropriate stimParams fields
                    for i=1:size(stairParams.randomVars, 1)
                        randVal(i) = stairParams.randomVars{i,2}(ceil(rand*length(stairParams.randomVars{i,2})));
                        stimParams.(stairParams.randomVars{i,1}) = randVal(i);
                    end
                    % set the curStair variable values in the appropriate stimParams fields
                    for i=1:size(stairParams.curStairVars, 1)
                        curStairVal(i) = stairParams.curStairVars{i,2}(min(curStair,length(stairParams.curStairVars{i,2})));
                        stimParams.(stairParams.curStairVars{i,1}) = curStairVal(i);
                    end
                    % randomly choose and then set the alternative variable
                    altIndex = round(rand*(numAlternatives-1))+1;
                    altValue = stairParams.alternativeVarValues(altIndex);
                    stimParams.(stairParams.alternativeVarName) = altValue;
                    % build the trial
                    if(stairparams.useGlobalData)
                        [trial{curStair, adjustIndex}, data] = eval(trialGenFuncName);
                    else
                        [trial{curStair, adjustIndex}, data{curStair}] = eval(trialGenFuncName);
                    end
                end
            end
        case 'plotEachTrial'
            plotEachTrialFlag = true;
        otherwise,
            fprintf('\nWARNING: doStaircase unrecognized option flag "%s".\n', varargin(i));
    end
end

fprintf('Ready to begin the trials...\n');
if ~isfield(display, 'fixColorRgb'),
    display.fixColorRgb = [0 display.maxRgbValue 0 display.maxRgbValue];
end

% prepare the log
for i=1:length(logFID)
    fprintf(logFID(i), '\ncurStair\ttrial\tadjustValue(%s)\tcorrect\taltValue(%s)\tresponseKey\t', ...
        stairParams.adjustableVarName, stairParams.alternativeVarName);
    for j=1:size(stairParams.randomVars, 1)
        fprintf(logFID(i), '%s\t', stairParams.randomVars{j,1});
    end
    for j=1:size(stairParams.curStairVars, 1)
        fprintf(logFID(i), '%s\t', stairParams.curStairVars{j,1});
    end
    fprintf(logFID(i), '\n');
end

curStair = round(rand*(numStairs-1))+1; % Randomly select a staircase to begin on
abort = 0; % Default abort to 0 so we can begin running
dataSum(1).abort = 0;

% CUSTOMIZABLE INTRO SCREEN
% do a switch and this will be the default, but we can allow customized
% input so you aren't forced to have the same press key to begin stuff
eval(instructions);

% Main staircase loop
while (~all(stairHistory.done) && ~abort) % While there are trials to be completed, and user hasn't aborted
    if exist('trialArray', 'var') % Can't figure this out - the variable isn't defined anywhere else 
        % Clear the keyboard queue
        % FlushEvents('keyDown');
        preTrialSecs = 0;
        % Run pre-built trial
        response = doTrial(display, trialArray{curStair, stairHistory.curAdjustIndex(curStair)}, priority);
        
    else % Given the comment on the if above, this seems to be the only instance that is executed.
        preTrialSecs = GetSecs;
        % We need to build the trial
        adjustValue = stairParams.adjustableVarValues(min(curStair,numLevelVectors), ...
            stairHistory.curAdjustIndex(curStair));
        
        % 
        correctStepIndex = min(length(stairParams.correctStepSize), stairHistory.numReversals(curStair)+1);
        incorrectStepIndex =  min(length(stairParams.incorrectStepSize), stairHistory.numReversals(curStair)+1);

        % Set the adjustable variable value
        stimParams.(stairParams.adjustableVarName) = adjustValue;
        % Set the random variable values in the appropriate stimParams fields
        for i=1:size(stairParams.randomVars, 1)
            randVal(i) = stairParams.randomVars{i,2}(ceil(rand*length(stairParams.randomVars{i,2})));
            stimParams.(stairParams.randomVars{i,1}) = randVal(i);
        end
        % Set the curStair variable values in the appropriate stimParams fields
        for i=1:size(stairParams.curStairVars, 1)
            curStairVal(i) = stairParams.curStairVars{i,2}(min(curStair,length(stairParams.curStairVars{i,2})));
            stimParams.(stairParams.curStairVars{i,1}) = curStairVal(i);
        end

        % Randomly choose and then set the alternative variable
        altIndex = round(rand*(numAlternatives-1))+1;
        altValue = stairParams.alternativeVarValues(altIndex);
        stimParams.(stairParams.alternativeVarName) = altValue;

        % build the trial
        if(stairParams.useGlobalData)
            [trial, data] = eval(trialGenFuncName);
        else
            [trial, data{curStair}] = eval(trialGenFuncName);
        end
        
        % clear the keyboard queue
        % FlushEvents('keyDown');
        preTrialSecs = GetSecs-preTrialSecs;
        % run the trial
        response = doTrial(display, trial, priority, showTimingFlag);
        if stairParams.etFlag
            etData = etCheckEyes(stimParams.duration);
        end     
    end
    postTrialSecs = GetSecs;

    if isfield(stairParams, 'responseSet')
        % If we already have a keyLabel, process it into a respCode;
        if ~isempty(response.keyLabel)
            if(~isempty(strfind(lower(response.keyLabel),quitKey))) % Set custom quit key
                respCode = -1;
                abort = 1;
            else
            % 2009.01.20 RFD: added the following conditional to allow
            % multiple response keys per alternative.
                if(iscell(stairParams.responseSet))
                    respCode = find(~cellfun('isempty',strfind(stairParams.responseSet,response.keyLabel)));
                else
                    respCode = strfind(stairParams.responseSet, response.keyLabel);
                end
            end
        else
            respCode = [];
        end
        
        if isempty(respCode) % If respCode is still empty at this point, get one
            % Wait for the response
            
            KbQueueCreate(device,keyList);
            KbQueueStart();
            [k.pressed k.firstPress k.firstRelease k.lastPress k.lastRelease] = KbQueueWaitCheck();
            response.secs = min(k.firstPress(k.firstPress~=0));
            response.keyCode = find(k.firstPress==response.secs);
            response = getKeyLabel(response);

            % Process the keyCode into a respCode
            if(~isempty(strfind(lower(response.keyLabel),quitKey))) % Check for quit key
                respCode = -1;
                abort = 1;
            else
                % 2009.01.20 RFD: added the following conditional to allow
                % multiple response keys per alternative.
                if(iscell(stairParams.responseSet))
                    respCode = find(~cellfun('isempty',strfind(stairParams.responseSet,response.keyLabel)));
                else
                    respCode = strfind(stairParams.responseSet, response.keyLabel);
                end
            end
        end
    end
    correct = (respCode == altIndex);
    postRespSecs = GetSecs; % changed the position of postTrialSecs
    % update dataSum with relevant trial and response information
    if ~abort
        trialCounts = trialCounts + 1;
        stairHistory.numTrials(curStair) = 	stairHistory.numTrials(curStair) + 1;
        dataSum(curStair).history(stairHistory.numTrials(curStair)) = adjustValue;
        dataSum(curStair).response(stairHistory.numTrials(curStair)) = response.keyLabel;
        dataSum(curStair).correct(stairHistory.numTrials(curStair)) = correct; % RFB - added trial by trial correct/incorrect info
        dataSum(curStair).trialCounts(stairHistory.numTrials(curStair)) = trialCounts; % RFB - added trial by trial count info (useful with many staircases)
        % If we're performing eye tracking, store the data
        if stairParams.etFlag
            dataSum(curStair).etData{1,stairHistory.numTrials(curStair)} = etData.horiz;
            dataSum(curStair).etData{2,stairHistory.numTrials(curStair)} = etData.vert;
            dataSum(curStair).etxForm{stairHistory.numTrials(curStair)} = stairParams.et.xform;
        end
        % If using code which records the start of the trial GetSecs, then
        % compute the RT
        if isfield(response,'secsStart')
            dataSum(curStair).responseTime(stairHistory.numTrials(curStair)) = response.secs - response.secsStart;
        end
        
        % If user indicates the need to save stuff out from the actual
        % trials themselves, do so with the eval function.
        if exist('saveData','var')
            for i=1:1:size(saveData,1)
                eval(saveData{i,2});
            end
        end
        
        i = find(dataSum(curStair).stimLevels == adjustValue);
        if isempty(i)
            error('doStaircase: missing stimLevel in dataSum- data may not be valid!');
        end
        dataSum(curStair).numTrials(i) = dataSum(curStair).numTrials(i) + 1;
        if correct
            % auditory feedback
            if ~isempty(correctSnd) sound(correctSnd); end
            dataSum(curStair).numCorrect(i) = dataSum(curStair).numCorrect(i) + 1;
        else
            if ~isempty(incorrectSnd) sound(incorrectSnd); end
        end
    else
        dataSum(1).abort = 1; % set a flag to allow users to alter their behavior outside of doStaircase should someone abort a trial
        return;
    end

    % print out the log
    for i=1:length(logFID)
        % incase altValues are characters: num2str(altValue) will work with characters, ints and floats
        fprintf(logFID(i), '%d\t%d\t%.4f\t%d\t%s\t%s\t', curStair, stairHistory.numTrials(curStair), ...
            adjustValue, correct, num2str(altValue),response.keyLabel);
        for j=1:size(stairParams.randomVars, 1)
            fprintf(logFID(i), '%.4f\t',  randVal(j));
        end
        for j=1:size(stairParams.curStairVars, 1)
            fprintf(logFID(i), '%.4f\t',  curStairVal(j));
        end
        fprintf(logFID(i), '\n');
    end
    % save the dataSum file in case of a crash or error
    save('dataSumTemp', 'dataSum');

    % if requested, update plot on each trial. useful for debugging.
    if exist('plotEachTrialFlag', 'var'), plotStaircase(stairParams, dataSum, 1); end
    
    % adjust the adjustable
    if correct
        stairHistory.numConsecCorrect(curStair) = stairHistory.numConsecCorrect(curStair) + 1;
        stairHistory.numConsecIncorrect(curStair) = 0;
        if mod(stairHistory.numConsecCorrect(curStair), stairParams.numCorrectForStep) == 0
            stairHistory.curAdjustIndex(curStair) = stairHistory.curAdjustIndex(curStair) ...
                + stairParams.correctStepSize(correctStepIndex);
            % check to see if this is a reversal
            % if the current run is negative (the 'incorrect' direction), then meeting the
            % numConsecCorrect criterion constitutes a reversal.
            if stairHistory.runDirection(curStair) == -1
                stairHistory.numReversals(curStair) = stairHistory.numReversals(curStair) + 1;
                dataSum(curStair).reversalStimLevel(stairHistory.numReversals(curStair)) = adjustValue;
                stairHistory.runDirection(curStair) = +1;
            end
        end
    else
        stairHistory.numConsecIncorrect(curStair) = stairHistory.numConsecIncorrect(curStair) + 1;
        stairHistory.numConsecCorrect(curStair) = 0;
        if mod(stairHistory.numConsecIncorrect(curStair), stairParams.numIncorrectForStep) == 0
            stairHistory.curAdjustIndex(curStair) = stairHistory.curAdjustIndex(curStair) ...
                + stairParams.incorrectStepSize(incorrectStepIndex);
            % check to see if this is a reversal
            % if the current run is positive (the 'correct' direction), then meeting the
            % numConsecIncorrect criterion constitutes a reversal.
            if stairHistory.runDirection(curStair) == +1
                stairHistory.numReversals(curStair) = stairHistory.numReversals(curStair) + 1;
                dataSum(curStair).reversalStimLevel(stairHistory.numReversals(curStair)) = adjustValue;
                stairHistory.runDirection(curStair) = -1;
            end
        end
    end
	
    % ensure adjustable isn't out of range
    % Note that if we have gone out of range, then we should (and do) count this as a
    % reversal because it means the observer has hit one of the boundaries.  If we don't
    % do something like this, the observer may get stuck at one of the bounds and do many
    % unnecessary trials there!
    if stairHistory.curAdjustIndex(curStair) > numLevels
        % count this as a reversal
        stairHistory.numReversals(curStair) = stairHistory.numReversals(curStair) + 1;
        dataSum(curStair).reversalStimLevel(stairHistory.numReversals(curStair)) = adjustValue;
        % constrain curAdjustIndex to the bounds
        stairHistory.curAdjustIndex(curStair) = numLevels;
    elseif stairHistory.curAdjustIndex(curStair) < 1
        % count this as a reversal
        stairHistory.numReversals(curStair) = stairHistory.numReversals(curStair) + 1;
        dataSum(curStair).reversalStimLevel(stairHistory.numReversals(curStair)) = adjustValue;
        % constrain curAdjustIndex to the bounds
        stairHistory.curAdjustIndex(curStair) = 1;
    end
    % check to see if we are done with this staircase
    if stairHistory.numTrials(curStair) >= stairParams.maxNumTrials ...
            || stairHistory.numReversals(curStair) >= stairParams.maxNumReversals
        stairHistory.done(curStair) = 1;
    end

    % choose the curStair pseudorandomly, giving preference to staircases that are less done.
    completeIndex = stairHistory.numTrials./stairParams.maxNumTrials - randn(size(stairHistory.numTrials))*.2;
    curStair = find(completeIndex == min(completeIndex));
    curStair = curStair(round(rand*(length(curStair)-1))+1);

    % wait for an ITI, if needed
    postTrialSecs = GetSecs-postTrialSecs;
    postRespSecs = GetSecs-postRespSecs;
    % we use the previous pre-trial time as a guess for how long the next
    % pre-trial prep time will take.
    if(prFlag), interval = postRespSecs; else interval = postTrialSecs; end
    if(~all(stairHistory.done) && ~abort && interval<stairParams.iti)
        waitTill(stairParams.iti-interval);
    end
    
    %if(~all(stairHistory.done) && ~abort && preTrialSecs+postTrialSecs<stairParams.iti)
    %    waitTill(stairParams.iti-preTrialSecs+postTrialSecs);
    %end
end

if stairParams.initTrialCount==1 || stairParams.initTrialCount==0
    save(tcName,'trialCounts');
end
    
%ListenChar(false);
return;
