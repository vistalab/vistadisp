function runme_GAMMA_BR(n, stimfile)
%RUNME runme_GAMMA_BR(n, stimfile)
%
% MEG Binocular rivalry experiment with left side an inward moving grating
% and right side a moving brownian noise image
% ------
%   Run time per experiment = 240 seconds
%   
%
% INPUTS
%   n is the runnumber [1]
%   stimfile is the prefix for the stimulus fils containing images:
%               - gammaBRstim 
% The actual stim files have names like
%   gammaBRstim1.mat
%   etc.
%
%
% Example
%   runme_GAMMA_BR(1, 'gammaBRstim');

%% 
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
hz  = FrameRate(d.screenNumber);
tr  = 1/hz*60;

% Do we want to use the eyetracker?
% use_eyetracker = false;
% 
%     d = openScreen(d);
%     global PTBTheWindowPtr
%     PTBTheWindowPtr = d.windowPtr;

% if use_eyetracker
%     
%     %Open the screen
% 
%     
%         PTBInitEyeTracker;
% %         paragraph = {'Eyetracker initialized.','Get ready to calibrate.'};
% %         PTBDisplayParagraph(paragraph, {'center',30}, {'a'});
%         PTBCalibrateEyeTracker;
%         
%         % actually starts the recording
%         % name correponding to MEG file (can only be 8 characters!!, no extension)
%         PTBStartEyeTrackerRecording('eyelink');
% end

%% Default parameters
params = retCreateDefaultGUIParams;


%% Hemifield and ONOFF mixture
params.modality         = 'meg';
params.prescanDuration  = 0;
params.interleaves      = NaN;
params.tr               = 1/60; %1/hz*60;
params.calibration      = cal;
params.framePeriod      = tr;
params.startScan        = 0;
params.motionSteps      = 2;
params.tempFreq         = 2/tr;
params.repetitions      = 1;
params.experiment       = 'Experiment From File';
params.period           = 1;
params.numCycles        = 1;
params.skipSyncTests    = false;
params.fixation         = 'left and right';




%% ********************
%  ***** GO ***********
%  *********************
params.loadMatrix = sprintf('%s%d.mat', stimfile, n);
ret(params);

% if use_eyetracker

    % retrieve the file
%     PTBDisplayParagraph({'The experiment is now over.','Please lie still while we save the data.'}, {'center', 30}, {.1});

% Not for now
%     PTBStopEyeTrackerRecording; % <----------- (can take a while)
% 
%     % move the file to the logs directory
%     destination = [pwd '_eyelink_'];
%     i = 0;
%     while exist([destination num2str(i) '.edf'], 'file')
%         i = i + 1;
%     end
%     movefile('eyelink.edf', [destination num2str(i) '.edf'])

% end

% %% Check timing results
% f = dir('~/Desktop/2014*.mat');
% load(fullfile('~', 'Desktop', f(end).name));
% figure(101); clf
% 
% % desired inter-stimulus duration
% plot(diff(stimulus.seqtiming));
% 
% % measured inter-stimulus duration
% hold on; plot(diff(response.flip), 'r-'); 
% 
% ylim(median(diff(response.flip)) + [-.001 .001])
% % frames between stimuli
% frames = round(diff(response.flip) / (1/60)); 
% 
% % how many interstimulus frames differed from the median?
% disp(sum(frames ~= median(frames)))