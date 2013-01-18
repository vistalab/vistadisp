% fovStaircase
%
%   Purpose:
%       main function for running psychophysical staircase to assess
%       effect of foveal stimulus on peripheal discimination (fov)
%
%   Uses generic doStaircase function (RFD) to operate the staircase. Uses
%   functions beginning with 'fov' to generate stimuli.
%
%   History
%      5/9/08: JW: adapted from cocStaircase
%
%   Flow:
%     1. fovStaircase: set parameters for experiment
%     2.   => doStaircase(display,stairParams,stimParams,trialGenFuncName [='fovTrial'], ...);
%     3.       => fovTrial(display, stimParams, data); (prepare trial elements)
%     4.       => doTrial(display,trial,runPriority,showTimingFlag,returnHistory)
%     5.            => showStimulus(display, material.stimulus,runPriority, showTimingFlag);
%     6.                 => [show each frame; no external calls]
%     7.                 => drawFixation(display, colindex)


AssertOpenGL;

%% initialize file and parameters for display, staircase, stimulus, and subject

display          = fovInitDisplay;
stairParams      = fovInitStaircaseParams;
stimParams       = fovInitStimParams(display, stairParams);
display          = fovInitFixParams(display);
dataDir          = fovInitDataDir;
subjectParams    = getSubjectParams(dataDir);
priorityLevel    = 0;  %whats's this about??
trialGenFuncName = 'fovTrial'; %function called by doStaircase to make stimuli

% inintialize file to store data
logFID           = prepStaircaseFile(dataDir, subjectParams, stairParams);

%% Staircase

% open display
hideCursor = true;
display = openScreen(display,hideCursor);

% do the staircase!!
newDataSum = doStaircase(display, stairParams, stimParams, trialGenFuncName, ...
    priorityLevel, logFID);%, 'precomputeFirstTrial');

display = closeScreen(display);

%% Plot, save, and close
try
    fovPlotStaircase(stairParams, newDataSum)
    fovSaveData(subjectParams, newDataSum)
catch ME
    warning(ME.identifier, [ME.message '\nMight not have finished the experiment'])
    for ii = 1:100; ShowCursor; end
end


fclose(logFID(1));



