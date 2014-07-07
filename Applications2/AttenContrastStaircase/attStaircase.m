% attention Staircase
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

PsychDebugWindowConfiguration(0, .7); 
AssertOpenGL;

%% Initialize Stimtracker
cal = 'meg_lcd';
d   = loadDisplayParams(cal);
% hz  = FrameRate(d.screenNumber);
hz = 60;
tr  = 1/hz*60;

% Initialize Stimtracker to send triggers
PTBInitStimTracker;
global PTBTriggerLength 
PTBTriggerLength = 0.001;

%% Eyetracker and Calibration: Do we want to use the eyetracker?  
use_eyetracker = true;
stop_eyetracker = false;

% Open a screen so we can get a WindowPointer (Needed for PTBWrapper code)
d = openScreen(d);
global PTBTheWindowPtr
PTBTheWindowPtr = d.windowPtr;

if use_eyetracker

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


%% initialize parameters for display, staircase, stimulus, and subject
display_name     = 'meg_lcd';
display          = attInitDisplay(display_name);
stimParams       = attInitStimParams(display);
display          = attInitFixParams(display);
stairParams      = attInitStaircaseParams(stimParams);
dataDir          = attInitDataDir;
subjectParams    = getSubjectParams(dataDir);
priorityLevel    = 0;  %whats's this about??
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

display = openScreen(display,hideCursor);
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
if use_eyetracker

    PTBStopEyeTrackerRecording; % Saving the file takes a while

    % move the file to the logs directory
    destination = '~/Desktop/Experiments/Winawer/Eyelink_files/';
    i = 0;
    while exist([destination num2str(i) '.edf'], 'file')
        i = i + 1;
    end
    movefile('eyelink.edf', [destination num2str(i) '.edf'])

end


