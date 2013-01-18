function [stimParams, stairParams] = TMSinitStaircaseParams(exptType)
% Initialize all parameters
% exptType can be 'motion' or 'contour'

%% Stimulus Parameters

%stimParams.stimFileCache = [];

% Font Properties
% note that these are only used in scrambleWord-- if
% letters are already cached, these values will make no difference until
% you delete the cache
stimParams.fontName = 'Monospaced'; %'SansSerif';
stimParams.fontSize = 14;  %regular value 10
stimParams.sampsPerPt = 8; %regular value 8
stimParams.antiAlias = 0;
stimParams.fractionalMetrics = 0;
stimParams.boldFlag = true;
stimParams.stimSizePix = [180 600];%[300 800]; %[108 244];  % % in pixels, [y,x]
stimParams.spread = stimParams.stimSizePix/5; %4.5

stimParams.duration = 1;	% in seconds, default 1 or 2
stimParams.ISI = 0.05;      % minimum time between stimuli (i.e. length of blank following stimulus)

% Movie parameters (also stimulus parameters)
% Moving Dot Properties
stimParams.conditionType = 'polar';  %'luminance' or 'motion' or 'polar'  % if you choose polar here, it will overwrite motCoherence and lumCoherence
stimParams.motCoherence = 1.0;
stimParams.lumCoherence = 0;
stimParams.dotDensity = 0.3;  %0.3
stimParams.dotLife = 4;  % dotLife<=0 means infinite
stimParams.dotDisplacement = 1; % in pixels, def = 1

% The noise directions are one of 16 directions given by numDir.
stimParams.numDir = 2; % def = 16
stimParams.dotDir = [270 90]; % direction for each form ind [form=0 form=1 ... form=n], def = [270 (left) 90 (right)]

assumedRefresh = 60;  % was 75 before
fprintf('\n\nCurrent frameDuration assumes monitor refresh of %0.1f\n',assumedRefresh);
fprintf('This value is set in initWordParams.m if you need to change it.\n\n');
stimParams.frameDuration = 1/assumedRefresh*2; % in seconds; as far as I can tell, 2 is arbitrary (slows down the stimulus)-- 3 works, too

%stimParams.wordType = 'W';

stimParams.eccentricity = 2;

stimParams.inFormRGB = [0 0 0];   %[255 255 255]
stimParams.backRGB = [128 128 128];   %[128 128 128] for gray background
stimParams.outFormRGB = [255 255 255];

% Make some RGB values for noise dots (for luminance condition)
% noiseValues = (0:16:256)';
% stimParams.noiseRGB = repmat(noiseValues,1,3);
stimParams.noiseRGB = [0 0 0; 255 255 255];


%% Staircase Parameters

stairParams.trialGenFuncName = 'TMSWordTrialPsychophys';
stairParams.alternativeVarName = 'wordType';
stairParams.alternativeVarValues = ['W' 'N']; %['W' 'W' 'N' 'N'];
stairParams.scrambleLevel = 0;

if strcmp(exptType,'dots')
    stimParams.conditionType = 'polar';
    stairParams.adjustableVarName = 'polarDistance';
    % stairParams.adjustableVarValues = sort(.01:.01:1,'descend');%(10.^(0:-.05:-1));
    stairParams.adjustableVarValues = [10.^(0:-.06:-0.8)];
    stairParams.curStairVars = {'polarAngle',[0 90]};  %[0 22.5 45 67.5 90]; {'polarAngle',[0 10 25 35 65 90]}
    
elseif strcmp(exptType,'contour')
    stimParams.conditionType = 'contour';
    stairParams.adjustableVarName = 'scrambleLevel';
    %stairParams.adjustableVarValues = sort(.01:.01:1,'descend');%(10.^(0:-.05:-1));
    stairParams.adjustableVarValues = 1-(.55:.05:0.95);
    stairParams.curStairVars = {};  %[0 22.5 45 67.5 90]; {'polarAngle',[0 10 25 35 65 90]}
end
%%
stairParams.numCorrectForStep = 3;
stairParams.numIncorrectForStep = 1;
stairParams.maxNumTrials = 200;
stairParams.maxNumReversals = 10; %8;
%stairParams.correctStepSize =   [15 10 8 5 3];    %[40 30 20 10 3];
%stairParams.incorrectStepSize = [15 10 8 5 3]*-1; %[40 30 20 10 3]*-1;
stairParams.correctStepSize =   [4 3 3 2 1];
stairParams.incorrectStepSize = [4 3 3 2 1]*-1;
%stairParams.correctStepSize =   [8 5 5 4 3];
%stairParams.incorrectStepSize = [8 5 5 4 3]*-1;

stairParams.feedback = 'auditory';
stairParams.responseSet = {'1','2'};
stairParams.randomVars = {};  % put things here to randomly vary the value e.g. {'formDir',[0 90 180 270]}
stairParams.conditionName = {'lexical decision'};
stairParams.useGlobalData = true;
stairParams.saveDataVars            = {'wordType', 'd'; 'word', 's'};
if(~isempty(stairParams.curStairVars))
    stairParams.adjustableVarStart = repmat(2, size(stairParams.curStairVars{2}));
else
    stairParams.adjustableVarStart = [2 2 2];
end
stairParams.iti = .1;


return