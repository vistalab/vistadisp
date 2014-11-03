function runme_EEG_OnOffLeftRight(n, stimfile)
%RUNME EEG_OnOffLeftRight(n, stimfile)
%
% EEG Full-field on-off, left/right flicker experiment (steady state)
% ------
%   Run time per experiment = 72 seconds
%   6 cycles at 12 s each
%   6 cycles are randomly orderd full-full-left-left-right-right, with
%       blanks between each
%
% INPUTS
%   n is the runnumber [1 15]
%   stimfile is the prefix for the stimulus fils containing images, and can
%            be either
%               - attention_onOffLeftRight_params 
%               - onOffLeftRight_params
% The actual stim files have names like
%   attention_onOffLeftRight_params1.mat
%   onOffLeftRight_params9.mat
%   etc
%
%
% Example
%   runme_EEG_OnOffLeftRight(1, 'onOffLeftRight_params');
%   runme_EEG_OnOffLeftRight(1, 'attention_onOffLeftRight_params');

%% 

% debug mode?
% PsychDebugWindowConfiguration
Screen('Preference', 'SkipSyncTests', 1);

%% Calibration

% TODO: calibrate the EEG display and then create an EEG calibration file
cal = 'meg_lcd';
d   = loadDisplayParams(cal);
hz  = FrameRate(d.screenNumber);

% hz = 60;
tr  = 1/hz*60;


%% Default parameters
params = retCreateDefaultGUIParams;


%% Hemifield and ONOFF mixture
params.modality         = 'EEG'; 
params.prescanDuration  = 0;
params.interleaves      = NaN;
params.tr               = 1/hz*60;
params.calibration      = cal;
params.framePeriod      = tr;
params.startScan        = 0;
params.motionSteps      = 2;
params.tempFreq         = 6/tr;
params.repetitions      = 1;
params.experiment       = 'Experiment From File';
params.period           = 12*params.tr;
params.numCycles        = 6;

%% ********************
%  ***** GO ***********
%  *********************
params.loadMatrix = sprintf('%s%d.mat', stimfile, n);
ret(params);

%% Check timing results
f = dir('~/Desktop/2014*.mat');
load(fullfile('~', 'Desktop', f(end).name));
figure(101); clf

% desired inter-stimulus duration
plot(diff(stimulus.seqtiming));

% measured inter-stimulus duration
hold on; plot(diff(response.flip), 'r-'); 

ylim(median(diff(response.flip)) + [-.001 .001])
% frames between stimuli
frames = round(diff(response.flip) / (1/60)); 

% how many interstimulus frames differed from the median?
disp(sum(frames ~= median(frames)))