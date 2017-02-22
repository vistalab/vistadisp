%% Uses image matrices generated in 'gammaCreateStimuli.m'
% Contains the parameters to display these images on an MEG display

%% Initiliaze stimtracker 
PTBInitStimTracker;
global PTBTriggerLength 
PTBTriggerLength = 0.005;

% debug mode?
% PsychDebugWindowConfiguration
Screen('Preference', 'SkipSyncTests', 1);


% screen
cal = 'meg_lcd';
d   = loadDisplayParams(cal);
hz  = FrameRate(d.screenNumber);
% hz  = 60;
tr  = 1/hz*60;

% Run number?
runnr = 1;

%% Use Eyetracker?
if runnr == 1
    use_eyetracker = true;
    stop_eyetracker = false;
elseif runnr > 1 && runnr < 12
    use_eyetracker = false;
    stop_eyetracker = false;
else
    use_eyetracker = false;
    stop_eyetracker = true;
end

if use_eyetracker
    
    d = openScreen(d);
    global PTBTheWindowPtr
    PTBTheWindowPtr = d.windowPtr;
    
    %Open the screen
    PTBInitEyeTracker;
    % paragraph = {'Eyetracker initialized.','Get ready to calibrate.'};
    % PTBDisplayParagraph(paragraph, {'center',30}, {'a'});
    PTBCalibrateEyeTracker;
    
    % actually starts the recording
    % name correponding to MEG file (can only be 8 characters!!, no extension)
    PTBStartEyeTrackerRecording('eyelink');
    
end
Screen('CloseAll');
%% MEG Parameters


params = retCreateDefaultGUIParams;

params.modality         = 'meg';
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
params.skipSyncTests    = false;
%% ********************
%  ***** GO ***********
%  *********************

Screen('Preference', 'SkipSyncTests', 1);


stimfile = 'gammaStimuli_params';
params.loadMatrix = sprintf('%s%d.mat', stimfile, runnr);
ret(params);


%% Stop Eyetracking?

if stop_eyetracker

    PTBStopEyeTrackerRecording; % <----------- (can take a while)

    % move the file to the logs directory
    destination = 'eyelink';
    i = 0;
    while exist([destination num2str(i) '.edf'], 'file')
        i = i + 1;
    end
    movefile('eyelink.edf', [destination num2str(i) '.edf'])

end






%%

