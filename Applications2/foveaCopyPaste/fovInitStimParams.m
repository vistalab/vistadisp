function [stimParams] = fovInitStimParams(display, stairParams)
% initialize stimulus parameters

% ******************************
% ** Random Variables **********
% ******************************

% stimulus position of 'same' stimulus pair; (in deg) 
stimParams.stimulusPosition1 = 0;

% stimulus position of 'different' stimulus pair; (in deg) 
stimParams.stimulusPosition2 = 0;

% sequence of forced choice (1 = match/non-match; 2 = non-match/match)
stimParams.firstOrSecond    = '1';

% lure can be different from match in pos or neg dir (-1/+1) 
stimParams.offsetDir        = 1;

%  on same sub-trials, either use (1) the referent stimulus or (2) the offset stimulus
stimParams.matchReferenceOrOffset = 1;

% ******************************
% ** Independent variables ***** (each value gets separate staircase)
% ******************************

% distractor position: 0 = none, 1 = foveal, 2 = parafoveal
stimParams.distractorPosition = 0;

% shape class (we may test only one class, or may interleave several classes of stimuli)
stimParams.shapeClass         = 1;

% ******************************
% ** Dependent variable ******** 
% ******************************

% difference between match and foil in same/diff task
ind = round(length(stairParams.adjustableVarValues)/2);
stimParams.stimulusOffset = stairParams.adjustableVarValues(ind); % arbitrary units (assume stimuli range [0 1000]


% ******************************
% *** Fixed values *************
% ******************************

% shape classes - a lookup for the numeric stimParams.shapeClass
stimParams.shapeClasses = {'Circles' 'Squares' 'Silhouettes' 'Gratings'}; %etc

% a class can really be defined in two ways - by the dimension, or class
% number (1-16), and by the value on that dimension. to keep things simple,
% we will fix the value on the dimension to always be 500. the
% discriminandum will deviate from this value as the staircase dictates. in
% princple, we could choose a different value for each dimension. 
stimParams.stimulusValue = 100;

% position of stimulus (center of stimuli from fixation)
stimParams.radius   = display.radius * 2/3; %(deg)

% size of stimulus (diameter)
stimParams.stimsize = display.radius * 2/3; %(deg)

% duration of a stimulus frame in seconds
stimParams.stimframe = 3 / display.frameRate;

% target dur
stimParams.targetDur = .1; % seconds
stimParams.targetFrames = round(stimParams.targetDur / stimParams.stimframe);

% isi dur
stimParams.isi = 1; % seconds
stimParams.isiFrames = round(stimParams.isi / stimParams.stimframe);

stimParams.distractorSize = display.radius * 1/3; % deg

return
