function EEG_OnOffLeftRight(n, stimfile)
%EEG_OnOffLeftRight(n, stimfile)
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
%
% To run on Dell Trinitron, resolution should be 800 x 600, 60 Hz refresh rate


% debug mode?
% PsychDebugWindowConfiguration
Screen('Preference', 'SkipSyncTests', 0);

%% Calibration

cal = 'eeg_crt';
nominal_refresh_rate = 60; % 
d   = loadDisplayParams(cal);
hz  = FrameRate(d.screenNumber);
tr  = 1/hz*nominal_refresh_rate;


%% Default parameters
params = retCreateDefaultGUIParams;


%% Hemifield and ONOFF mixture
params.modality         = 'EEG'; 
params.prescanDuration  = 0;
params.interleaves      = NaN;
params.tr               = tr;
params.calibration      = cal;
params.framePeriod      = tr;
params.startScan        = 0;
params.motionSteps      = 2;
params.tempFreq         = 1/tr;
params.repetitions      = 1;
params.experiment       = 'Experiment From File';
params.period           = 3600*params.tr;
params.numCycles        = 1;
params.fixation         = 'dot';
params.skipSyncTests    = 0;

%% ********************
%  ***** GO ***********
%  *********************
params.loadMatrix = sprintf('%s%d.mat', stimfile, n);
ret(params);

%% Check timing results
f = dir('~/Desktop/2015*.mat');
load(fullfile('~', 'Desktop', f(end).name));
figure(101); clf

% desired inter-stimulus duration
plot(diff(stimulus.seqtiming)*Hz);

% measured inter-stimulus duration
hold on; plot(diff(response.flip)*Hz, 'r-');
plot(diff(response.nextFlipTime)*Hz, 'g-');

ylim(median(diff(response.flip)*Hz) + [-1 1])

% frames between stimuli
frames = round(diff(response.flip) / (1/nominal_refresh_rate)); 

% how many interstimulus frames differed from the median?
disp(sum(frames ~= median(frames)))