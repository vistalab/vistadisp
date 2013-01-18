% cocStaircase
%
%   Purpose:
%       main function for running psychophysical staircase to assess
%       matches between Craik-O'Brien-Cornsweet (COC) edges and square
%       edges
%
%   Uses generic doStaircase function (RFD) to operate the staircase. Uses
%   functions beginning with 'coc' to generate stimuli.
%
%   History
%      5/9/08: JW: adapted from wordStaircase (RFD)
%
%   Flow:
%     1. cocStaircase: set parameters for experiment
%     2.   => doStaircase(display,stairParams,stimParams,trialGenFuncName [='cocTrial'], ...);
%     3.       => cocTrial(display, stimParams, data); (prepare trial elements)
%     4.       => doTrial(display,trial,runPriority,showTimingFlag,returnHistory)
%     5.            => showStimulus(display, material.stimulus,runPriority, showTimingFlag);
%     6.                 => [show each frame; no external calls]
%     7.                 => drawFixation(display, colindex)     


AssertOpenGL;

%% initialize parameters for display, staircase, stimulus, and subject

display          = cocInitDisplay;
stimParams       = cocInitStimParams(display);
display          = cocInitFixParams(display, stimParams);
stairParams      = cocInitStaircaseParams;
dataDir          = cocInitDataDir;
subjectParams    = getSubjectParams(dataDir);
priorityLevel    = 0;  %whats's ths about??
trialGenFuncName = 'cocTrial'; %function called by doStaircase to make stimuli

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
try,
    cocPlotStaircase(stairParams, newDataSum)
    cocSaveData(subjectParams, newDataSum)
catch
    warning('might not have finished the experiment')
    rethrow(lasterror)
    for ii = 1:100; ShowCursor; end
end
fclose(logFID(1));



