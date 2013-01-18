function  [paramsA, paramsB] = initWordParams(expType,stimFile)

% Initializes the stairParams and stimParams used for the psychophysical or
% MR word experiments
%    
%    Psychophysical Case:
%    [stimParams, stairParams] = initWordParams(expType,stimFile)
%    MR Case:
%    [fontParams, movieParams] = initWordParams(expType,stimFile)
%
% Example:
%    [stimParams, stairParams] = initWordParams('psychophysics');
%    fontParams = initWordParams('mr');
%
% Author: amr 5/30/08


%% Check parameters
if notDefined('expType'), expType = 'psychophysics'; end


% Was stimFile defined?
if notDefined('stimFile')
    % Set cache to empty if undefined
    fontParams.stimFileCache = [];
else
    % Check for the existence of a stimFile itself
    if exist(stimFile,'file')
        % Set cache to stimFile
        fontParams.stimFileCache = stimFile;
        load(stimFile);
    else
        % Set cache to empty, user indicated a nonexistent stimFile
        fprintf('ERROR: stimFile does not exist @ %s\n',stimFile);
        fontParams.stimFileCache = [];
    end
end

%fontParams.stimFileCache = [];

%% Common Stimulus Parameters
% Font Properties
fontParams.fontName = 'Monospaced'; %'SansSerif';
fontParams.fontSize = 14; %10;  %regular value 10
fontParams.sampsPerPt = 8; %regular value 8
fontParams.antiAlias = 0;
fontParams.fractionalMetrics = 0;
fontParams.boldFlag = true;
fontParams.stimSizePix = [180 600]; % in pixels, [y,x]  [180 600]
fontParams.spread = fontParams.stimSizePix/5; %4.5

% Moving Dot Properties
movieParams.conditionType = 'motion';  %'luminance' or 'motion' or 'polar'  % if you choose polar here, it will overwrite motCoherence and lumCoherence
movieParams.duration = 1;	% in seconds, default 1 or 2
movieParams.motCoherence = 1.0;
movieParams.lumCoherence = 0;
movieParams.dotDensity = 0.3;  %0.3
movieParams.dotLife = 4;  % dotLife<=0 means infinite
movieParams.dotDisplacement = 1; % in pixels, def = 1

% The noise directions are one of 16 directions given by numDir.
movieParams.numDir = 2; % def = 16
movieParams.dotDir = [270 90]; % direction for each form ind [form=0 form=1 ... form=n], def = [270 (left) 90 (right)]

assumedRefresh = 60;  % was 75 before
fprintf('\n\nCurrent frameDuration assumes monitor refresh of %0.1f\n',assumedRefresh);
fprintf('This value is set in initWordParams.m if you need to change it.\n\n');
movieParams.frameDuration = 1/assumedRefresh*2; % in seconds; as far as I can tell, 2 is arbitrary (slows down the stimulus)-- 3 works, too

%movieParams.wordType = 'W';

movieParams.eccentricity = 2;

movieParams.inFormRGB = [0 0 0];   %[255 255 255]
movieParams.backRGB = [128 128 128];   %[128 128 128] for gray background
movieParams.outFormRGB = [255 255 255];

% Make some RGB values for noise dots (for luminance condition)
% noiseValues = (0:16:256)';
% movieParams.noiseRGB = repmat(noiseValues,1,3);
movieParams.noiseRGB = [0 0 0; 255 255 255];

% Replaced with dotDir above
% movieParams.inFormDir =  90;  %  0 = up, 90 right, 180 down  %%% set directions manually here if not using random directions
% movieParams.outFormDir =  [];  % In this case (using []), backDir is always 180 deg opposite formDir

%% Test Vars
%movieParams.polarDistance = 1; % coded as a proportion
%movieParams.polarAngle = 45; % coded in degrees from 0 to 90
%%

if strcmp('psychophysics',expType) % Code unique to psychophysics
    %% Combine Parameters
    masterStruct = struct('fontParams',fontParams, ...
                          'movieParams',movieParams);
    stimParams = structCompile(masterStruct);
    
    %% Staircase Parameters 
    stairParams.trialGenFuncName = 'WordTrial';
    stairParams.alternativeVarName = 'wordType';
    stairParams.alternativeVarValues = ['W' 'N']; %['W' 'W' 'N' 'N'];
    stairParams.curStairVars = {};  % put things in here to run the staircase separately for a given condition e.g. {'formDir',[0 90 180 270]}
%% More test vars
    stairParams.adjustableVarName = 'polarDistance';
    % stairParams.adjustableVarValues = sort(.01:.01:1,'descend');%(10.^(0:-.05:-1));
    stairParams.adjustableVarValues = [10.^(0:-.04:-0.8)];
    stairParams.curStairVars = {'polarAngle',[0 90]};  %[0 22.5 45 67.5 90]; {'polarAngle',[0 10 25 35 65 90]}
%%
    % Here are various coherence values that one can choose %
    % stairParams.adjustableVarValues = [10.^[0:-.05:-0.3010]];
    % stairParams.adjustableVarValues = [10.^[0:-.01:-0.3010]];  %log scale of coherence values (1 to 0.5)
    % stairParams.adjustableVarValues = (10.^(0:-.2:-3));  %log scale of coherence values (1 to 0)
    % stairParams.adjustableVarValues = (10.^(0:-.03:-0.4));  % tighter range of log values
    % stairParams.adjustableVarValues = [repmat(1,1,16)]; % no change in coherence values (all 1s)
    % stairParams.adjustableVarValues = [0 0 0 0 0]; % no change in coherence values (all 0s)
    % stairParams.adjustableVarValues = [repmat(0.8,1,16)]; %choose this one for constant noise
    stairParams.numCorrectForStep = 2;
    stairParams.numIncorrectForStep = 1;
    stairParams.maxNumTrials = 150;
    stairParams.maxNumReversals = 8;
     %stairParams.correctStepSize =   [15 10 8 5 3];    %[40 30 20 10 3];
     %stairParams.incorrectStepSize = [15 10 8 5 3]*-1; %[40 30 20 10 3]*-1;
    stairParams.correctStepSize =   [4 3 3 2 1];
    stairParams.incorrectStepSize = [4 3 3 2 1]*-1;
    %stairParams.correctStepSize =   [8 5 5 4 3];
    %stairParams.incorrectStepSize = [8 5 5 4 3]*-1;
    
    stairParams.feedback = 'auditory';
    stairParams.responseSet = {'1','2'};
    stairParams.randomVars = {};  % put things here to randomly vary the value e.g. {'formDir',[0 90 180 270]}
    stairParams.conditionName = {'semantic judgment'};
    stairParams.useGlobalData = true;
    stairParams.saveDataVars            = {'wordType', 'd'; 'word', 's'};
    if(~isempty(stairParams.curStairVars))
        stairParams.adjustableVarStart = repmat(2, size(stairParams.curStairVars{2}));
    else
        stairParams.adjustableVarStart = 2;
    end
    stairParams.iti = .1;
    
    % Properly Assign Names for Output
    paramsA = stimParams;
    paramsB = stairParams;
elseif strcmp('mr',expType) % Code unique to mr
    % Enter code/overwrite parameters unique to mr experiment
    
    % Properly Assign Names for Output
    paramsA = fontParams;
    paramsB = movieParams;
else
    % Wrong exp type??
end