function runme_MEG_spatiotemporal_ET(n, stimfile)
%RUNME runme_MEG_spatiotemporal_ET(n, stimfile)
%
% MEG BAIR spatiotemporal experiments
% ------
%   Run time per experiment = XX seconds
%
% INPUTS
%   n is the runnumber [1 24]
%   stimfile is the prefix for the stimulus fils containing images, and
%           should be
%               - spatiotemporal
%           
% The actual stim files have names like
%   spatiotemporal_MEG_1.mat
%   spatiotemporal_MEG_2.mat

% Example
%   runme_MEG_spatiotemporal_ET(1, 'spatiotemporal_MEG_');


%% 

if notDefined('n'), n = 1; end
if notDefined('stimfile'), stimfile = 'spatiotemporal_MEG_'; end

% initialize stim tracker for MEG
PTBInitStimTracker;
global PTBTriggerLength 
PTBTriggerLength = 0.001;

% debug mode?
% PsychDebugWindowConfiguration
Screen('Preference', 'SkipSyncTests', 1);

%% Calibration
cal = 'meg_lcd';
d   = loadDisplayParams(cal);

% Do we want to use the eyetracker?
use_eyetracker = false;


% if use_eyetracker
%     
%     %Open the screen    
%     d = openScreen(d);
%     global PTBTheWindowPtr
%     PTBTheWindowPtr = d.windowPtr;
%     
%         PTBInitEyeTracker;
%         PTBCalibrateEyeTracker;
%         PTBStartEyeTrackerRecording('eyelink');
% end
% Screen('CloseAll');

%% Default parameters
params = retCreateDefaultGUIParams;


%% Hemifield and ONOFF mixture
params.modality         = 'MEG'; 
params.prescanDuration  = 0;
params.calibration      = cal;
params.startScan        = 0;
params.repetitions      = 1;
params.experiment       = 'Experiment From File';

switch stimfile
    case 'spatiotemporal'
        params.fixation = 'dot with grid';
    case 'task'
        params.fixation = 'dot';
end



%% ********************
%  ***** GO ***********
%  *********************
params.loadMatrix = sprintf('%s%d.mat', stimfile, n);
ret(params);

% if use_eyetracker
% 
%  
%     PTBStopEyeTrackerRecording; % <----------- (can take a while)
%         
%     % move the file to the logs directory
%     destination = 'eyelink';
%     i = 0;
%     while exist([destination num2str(i) '.edf'], 'file')
%         i = i + 1;
%     end
%     movefile('eyelink.edf', [destination num2str(i) '.edf'])
% 
% end

%% Check timing results
f = dir('~/Desktop/201*.mat');
load(fullfile('~', 'Desktop', f(end).name));
figure(101); clf

% desired inter-stimulus duration
plot(stimulus.seqtiming(2:end), diff(stimulus.seqtiming));

% measured inter-stimulus duration
hold on; plot(stimulus.seqtiming(2:end), diff(response.flip), 'r-'); 

ylim(median(diff(response.flip)) + [-.001 .001])
% frames between stimuli
frames = round(diff(response.flip) / (1/60)); 

% how many interstimulus frames differed from the median?
disp(sum(frames ~= median(frames)))