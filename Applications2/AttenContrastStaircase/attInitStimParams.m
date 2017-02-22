function stimParams = attInitStimParams(display)
% Initialize stimulus parameters for attention MEG experiment
%
% stimParams = attInitStimParams(display)

% **** FIXED PARAMETERS *****************

% specify which device for inputs
display.devices = getDevices;
stimParams.inputDevice = getBestDevice(display);

% screen diameter in pixels
screensize = min(display.numPixels);

% duration of stimulus presentation
stimParams.duration = 6; % seconds

% temporal frequency of stimuli
stimParams.frequency  = 12; %Hz

% derive number of frames per trial
stimParams.numFrames = stimParams.duration * stimParams.frequency;

% Number of frames used for contrast decrement envelope (for now we use
% stimulus.frequency, which results in one second
stimParams.nTimePoints = stimParams.frequency;

% target size (sd of gaussian)
stimParams.gaussianSigma = screensize/40;

% isi
stimParams.isi = 1; % seconds


% **** STAIRCASE PARAMETER **************
% These are the values of probe contrast decrement, which is the variable
% controlled by the staircase. Space them from 1% to 100% with a power law
% spacing so that contrasts are densely sampled near 1 and sparesely near
% 100.
gamma = 2;
stimParams.TestContrasts = linspace(.001^(1/gamma),1,30).^gamma;
%% debug
% stimParams.TestContrasts = ones(size(stimParams.TestContrasts));
%% debug

% **** RANDOM VARIABLES **************
% Attentional cue
%   0 = attend both; 1 = attend left; 2 = attend right
stimParams.LeftOrRight = [0 1 2]; 

% When attending both, we need to choose a side for the probe at random
stimParams.LeftOrRightAttendBoth = [1 2]; % 1 is left, 2 is right

% Interval where constrast decrement can be presented
earliest_onset = stimParams.nTimePoints/2;
latest_onset   = stimParams.numFrames - earliest_onset - stimParams.nTimePoints;
stimParams.StartFrames = earliest_onset:latest_onset;

% **** DERIVED FROM RANDOM VARIABLES ***
stimParams.ColCoords     = [0.35, 0.65]; % LEFT OR RIGHT

% **** DERIVED FROM STAIRCASE ALTERNATIVE VARIABLE ***
stimParams.RowCoords  = [0.57 0.43];  % UPPER OR LOWER


% *** Pause Event parameters ***
stimParams.fontSize = 18;
stimParams.fontFace = 'Arial';
stimParams.curStr = 'Take a break';
stimParams.centerLoc = screensize/2;
stimParams.angle = 0;

return