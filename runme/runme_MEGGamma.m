%% Uses image matrices generated in 'gammaCreateStimuli.m'
% Contains the parameters to display these images on an MEG display

%% Initiliaze stimtracker 
PTBInitStimTracker;
global PTBTriggerLength 
PTBTriggerLength = 0.001;

% debug mode?
PsychDebugWindowConfiguration
Screen('Preference', 'SkipSyncTests', 1);


% screen
cal = 'meg_lcd';
d   = loadDisplayParams(cal);
%hz  = FrameRate(d.screenNumber);
hz = 60;
tr  = 1/hz*60;

%% Use Eyetracker?

use_eyetracker = false;
stop_eyetracker = false;

if use_eyetracker
    d = openScreen(d);
    global PTBTheWindowPtr
    PTBTheWindowPtr = d.windowPtr;


    %Open the screen
    PTBInitEyeTracker;
    PTBCalibrateEyeTracker;
    PTBStartEyeTrackerRecording('eyelink');

    Screen('CloseAll');
end

%% MEG Parameters


params = retCreateDefaultGUIParams;

params.modality         = 'MEG';
params.prescanDuration  = 0;
params.interleaves      = NaN;
params.tr               = 1/hz*60;
params.calibration      = cal;
params.framePeriod      = tr;
params.startScan        = 0;
params.motionSteps      = 2;
params.tempFreq         = 2/tr;
params.repetitions      = 1;
params.experiment       = 'Experiment From File';
params.period           = 1;
params.numCycles        = 1;
params.skipSyncTests    = true;
%% ********************
%  ***** GO ***********
%  *********************

% debug mode?
PsychDebugWindowConfiguration
Screen('Preference', 'SkipSyncTests', 1);


stimfile = 'gammaStimuli_params';
params.loadMatrix = sprintf('%s%d.mat', stimfile, 1);
ret(params);


%% Stop Eyetracking?

if stop_eyetracker

    PTBStopEyeTrackerRecording; % <----------- (can take a while)

    % move the file to the logs directory
    destination = [pwd '_eyelink_'];
    i = 0;
    while exist([destination num2str(i) '.edf'], 'file')
        i = i + 1;
    end
    movefile('eyelink.edf', [destination num2str(i) '.edf'])

end








