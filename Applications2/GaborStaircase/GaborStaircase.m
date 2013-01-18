function GaborStaircase(stimParams)
% GaborStaircase
%
%   Purpose:
%       Wrapper function for running psychophysical staircase to assess
%       contrast sensitivty function
%
%   Uses generic doStaircase function (RFD) to operate the staircase. Uses
%   functions beginning with 'csf' to generate stimuli.
%
%   History
%      10/14/09: JW: adapted from GaborDetectStair (RFD)
%
%   Flow:
%     1. gaborStaircase: set parameters for experiment
%     2.   => doStaircase(display,stairParams,stimParams,trialGenFuncName [='GaborTrial'], ...);
%     3.       => GaborTrial(display, stimParams, data); (prepare trial elements)
%     4.       => doTrial(display,trial,runPriority,showTimingFlag,returnHistory)
%     5.            => showStimulus(display, material.stimulus,runPriority, showTimingFlag);
%     6.                 => [show each frame; no external calls]
%     7.                 => drawFixation(display, colindex)     


AssertOpenGL;

%% initialize parameters for display, staircase, stimulus, and subject

display          = GaborInitDisplay;
stimParams       = GaborInitStimParams(display, stimParams);
stairParams      = GaborInitStaircaseParams(display);
display          = GaborInitFixParams(display, stimParams);
subjectParams    = GaborGetSubjectParams;
priorityLevel    = 0; 
trialGenFuncName = 'GaborTrial'; %function called by doStaircase to make stimuli

%% Subject data and log file

logFID(1) = fopen([subjectParams.name '.log'], 'at');
fprintf(logFID(1), '%s\n', datestr(now));
fprintf(logFID(1), '%s\n', subjectParams.comment);

if(~isempty(stairParams.curStairVars))
    fprintf(logFID(1), '%s = [ %s ]', stairParams.curStairVars{1}, num2str(stairParams.curStairVars{2}));
end
fprintf(logFID(1), '\n');
logFID(2) = 1;
hideCursor = false;

%% Do it!
display = openScreen(display);
newDataSum = doStaircase(display, stairParams, stimParams, trialGenFuncName, ...
    priorityLevel, logFID, 'precomputeFirstTrial');
display = closeScreen(display);

%% plot, save, and close
try
    GaborPlotStaircase(stairParams, newDataSum)
    GaborSaveData(subjectParams, newDataSum)
catch ME
    warning(ME.identifier, [ME.message 'might not have finished the experiment'])
end
fclose(logFID(1));

for ii = 1:10000; ShowCursor; end
