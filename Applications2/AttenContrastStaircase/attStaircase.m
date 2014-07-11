% Attention Staircase
%
%   Purpose:
%       main function for running psychophysical staircase
%
%   Uses generic doStaircase function (RFD) to operate the staircase. Uses
%   functions beginning with 'att' to generate stimuli.
%
%   You need VISTADISP and KNK code to run this code!
%
%

%  
%
%   Flow:
%     1. attStaircase: set parameters for experiment
%     2.   => doStaircase(display,stairParams,stimParams,trialGenFuncName [='attTrial'], ...);
%     3.       => attTrial(display, stimParams, data); (prepare trial elements)
%     4.       => doTrial(display,trial,runPriority,showTimingFlag,returnHistory)
%     5.            => showStimulus(display, material.stimulus,runPriority, showTimingFlag);
%     6.                 => [show each frame; no external calls]
%     7.                 => drawFixation(display, colindex)   



% Before you run a MEG experiment with this code.. CHECK:
% (a) Do you want to use the PsychDebugWindow?
% (b) Is Framerate correct?
% (c) Is stimtracker initiated?
% (d) Do you want to use the eyetracker or not? 
%     Use/Stop_eyetracker = True/False?
% (e)Are the keys for responses correct? (Inside attInitStaircaseParams)?
 

%% Open GL
AssertOpenGL;

%% Do you want the debug window?
% PsychDebugWindowConfiguration(0, .7); 

%% Initialize Stimtracker
cal = 'meg_lcd';
d   = loadDisplayParams(cal);
hz  = FrameRate(d.screenNumber);
% hz = 60;
tr  = 1/hz*60;

% Initialize Stimtracker to send triggers
PTBInitStimTracker;
global PTBTriggerLength 
PTBTriggerLength = 0.001; % ms

%% Eyetracker and Calibration: Do we want to use the eyetracker?  
use_eyetracker = true;
stop_eyetracker = false;

if use_eyetracker
    
    % Open a screen so we can get a WindowPointer (Needed for PTBWrapper code)
    d = openScreen(d);
    global PTBTheWindowPtr
    PTBTheWindowPtr = d.windowPtr;

    % Initialize Eyetracker
    PTBInitEyeTracker;
    
    % Start Calibration. Use C for calibration, then press enter when
    % participant fixates to start the calibration. Use V for Validation,
    % press enter when subjects fixates and you want to start validation.
    % Use escape to go back to the matlab console.
    PTBCalibrateEyeTracker;

    % Starts the recording
    % name correponding to MEG file (can only be 8 characters!!, no extension)
    PTBStartEyeTrackerRecording('eyelink');
end


Screen('CloseAll'); % Close the screen you opened for the eyetracker Initiation & Calibration


%% initialize parameters for display, staircase, stimulus, and subject
display_name     = 'meg_lcd';
display          = attInitDisplay(display_name);
stimParams       = attInitStimParams(display);
display          = attInitFixParams(display);
stairParams      = attInitStaircaseParams(stimParams);
dataDir          = attInitDataDir;
subjectParams    = getSubjectParams(dataDir);
priorityLevel    = 0;  %what's this about??
trialGenFuncName = 'attTrial'; %function called by doStaircase to make stimuli

%% Subject data and log file

logFID(1) = fopen(fullfile(dataDir,[subjectParams.name '.log']), 'at');
fprintf(logFID(1), '%s\n', datestr(now));
fprintf(logFID(1), '%s\n', subjectParams.comment);

if(~isempty(stairParams.curStairVars))
    fprintf(logFID(1), '%s = [ %s ]', stairParams.curStairVars{1}, num2str(stairParams.curStairVars{2}));
end
fprintf(logFID(1), '\n');
logFID(2) = 1;
hideCursor = false;

%% do the staircase
devices = getDevices;
display = openScreen(display,hideCursor);
display.devices = devices;

newDataSum = doStaircase(display, stairParams, stimParams, trialGenFuncName, ...
    priorityLevel, logFID); %, 'precomputeFirstTrial');
display = closeScreen(display);

%% plot, save, and close
try 
    attPlotStaircase(stairParams, newDataSum)
    attSaveData(subjectParams, newDataSum)
catch
    warning('might not have finished the experiment')
    rethrow(lasterror)
    for ii = 1:100; ShowCursor; end
end
fclose(logFID(1));

%% Stop recording with Eyetracker when done
if stop_eyetracker

    PTBStopEyeTrackerRecording; % Saving the file takes a while

    % move the file to the logs directory
    if ~exist('~/Desktop/Experiments/Winawer/Eyelink_files/', 'dir')
        mkdir('~/Desktop/Experiments/Winawer/Eyelink_files/')
    end
    destination = '~/Desktop/Experiments/Winawer/Eyelink_files/_eyelink_';
    i = 0;
    while exist([destination num2str(i) '.edf'], 'file')
        i = i + 1;
    end
    movefile('eyelink.edf', [destination num2str(i) '.edf'])

end


