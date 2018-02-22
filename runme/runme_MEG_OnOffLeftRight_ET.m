function runme_MEG_OnOffLeftRight_ET(n, stimfile)
%RUNME MEG2_OnOffLeftRight(n, stimfile)
%
% MEG Full-field on-off, left/right flicker experiment (steady state)
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
%   runme_MEG_OnOffLeftRight_ET(1, 'attention_onOffLeftRight_params');
%   runme_MEG_OnOffLeftRight_ET(1, 'onOffLeftRight_params');

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
use_eyetracker = true;

    d = openScreen(d);
    global PTBTheWindowPtr
    PTBTheWindowPtr = d.windowPtr;

if use_eyetracker
    
    %Open the screen

    
        PTBInitEyeTracker;
%         paragraph = {'Eyetracker initialized.','Get ready to calibrate.'};
%         PTBDisplayParagraph(paragraph, {'center',30}, {'a'});
        PTBCalibrateEyeTracker;
        
        % actually starts the recording
        % name correponding to MEG file (can only be 8 characters!!, no extension)
        PTBStartEyeTrackerRecording('eyelink');
end

%% Default parameters
params = retCreateDefaultGUIParams;


%% Hemifield and ONOFF mixture
params.modality         = 'MEG'; 
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

if use_eyetracker

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

end

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