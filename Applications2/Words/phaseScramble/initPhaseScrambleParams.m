function [stimParams, stairParams] = initPhaseScrambleParams(exptType)
% Initialize all parameters
% exptType can be 'detect' or 'lexical'

%% Stimulus Parameters
% Specific to exptType
if strcmp(exptType,'detect')
    stimParams.exptType = 'detect';
elseif strcmp(exptType,'lexical')
    stimParams.exptType = 'lexical';
end

%stimParams.stimFileCache = [];

% Font Properties
% note that these are only used in scrambleWord-- if
% letters are already cached, these values will make no difference until
% you delete the cache
stimParams.fontName = 'Monospaced'; %'SansSerif';
stimParams.fontSize = 8;  %regular value 10
stimParams.sampsPerPt = 8; %regular value 8
stimParams.antiAlias = 0;
stimParams.fractionalMetrics = 0;
stimParams.boldFlag = true;
%stimParams.stimSizePix = [300 800]; %[108 244];  %[180 600]; % in pixels, [y,x]
%stimParams.spread = stimParams.stimSizePix/5; %4.5

stimParams.duration = 2;	% in seconds, default 1 or 2
stimParams.ISI = 0.05;      % minimum time between stimuli (i.e. length of blank following stimulus)

%% Staircase Parameters

% Specific to exptType
if strcmp(exptType,'detect')
    stairParams.conditionName = {'detection task'};
    stairParams.adjustableVarValues = 1-(.7:.02:0.98);
elseif strcmp(exptType,'lexical')
    stairParams.conditionName = {'lexical decision'};
    stairParams.adjustableVarValues = 1-(.5:.02:0.9);
end

stairParams.alternativeVarName = 'wordType';
stairParams.alternativeVarValues = ['W' 'N']; % Word, Nonword/Noise
stairParams.curStairVars = {};  % put things in here to run the staircase separately for a given condition e.g. {'formDir',[0 90 180 270]}
%% More test vars
stairParams.adjustableVarName = 'scrambleLevel';
%stairParams.adjustableVarValues = .6:.05:1;    %(10.^(0:-.05:-1));
%stairParams.adjustableVarValues = [10.^(0:-.04:-0.8)];
%stairParams.curStairVars = {'scrambleLevel',[0 10 25 35 65 90]};

stairParams.numCorrectForStep = 2;
stairParams.numIncorrectForStep = 1;
stairParams.maxNumTrials = 100;
stairParams.maxNumReversals = 12;
%stairParams.correctStepSize =   [15 10 8 5 3];    %[40 30 20 10 3];
%stairParams.incorrectStepSize = [15 10 8 5 3]*-1; %[40 30 20 10 3]*-1;
stairParams.correctStepSize =   [4 3 3 2 1];
stairParams.incorrectStepSize = [4 3 3 2 1]*-1;
%stairParams.correctStepSize =   [8 5 5 4 3];
%stairParams.incorrectStepSize = [8 5 5 4 3]*-1;

stairParams.feedback = 'auditory';

% for testing on laptop
%stairParams.responseSet = '12';
% for scanner, not sure if this will work
stairParams.responseSet = {'1!','2@'};

stairParams.randomVars = {};  % put things here to randomly vary the value e.g. {'formDir',[0 90 180 270]}

stairParams.useGlobalData = true;  % see doStaircase.m for explanation

if(~isempty(stairParams.curStairVars))
    stairParams.adjustableVarStart = repmat(2, size(stairParams.curStairVars{2}));
else
    stairParams.adjustableVarStart = [2 2];  % the length of this vector determines how many interleaved staircases are run and where they start
end
stairParams.iti = .1;  % not sure if this is being used anywhere

return