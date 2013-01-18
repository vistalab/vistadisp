function [thresh,subjectParams] = TMSwordStaircase()
% Runs a staircase on words with defined by motion, luminance, and contours (but partially phase-scrambled).
% The idea is to run this staircase before TMS
% to define a threshold (thresh) for the individual before
% running TMSmotionWordsEventRelated (or something similar).
%
%
% amr December 18, 2009
%

AssertOpenGL;

%% initialize parameters for display, staircase, stimulus, and subject

display          = PSinitDisplay;

%priorityLevel = MaxPriority(display.windowPtr);
priorityLevel = 0;

if notDefined('exptType')
    exptChoice = input('\nStaircase for (1) dots or (2) phase scramble contours?  ');
    if exptChoice == 1, exptType = 'dots'; elseif exptChoice == 2, exptType = 'contour'; else exptType = 'NA'; end
end

switch exptType
    case {'dots','contour'}
        [stimParams, stairParams] = TMSinitStaircaseParams(exptType);
    otherwise
        fprintf('No valid experiment type given (detect or lexical).\n\n')
        return
end


display          = PSinitFixParams(display, stimParams);
dataDir          = TMSinitDataDir(exptType);
stimParams.stimFileCache = fullfile(dataDir, 'TMSstimCache.mat');
subjectParams    = getSubjectParams(dataDir);
trialGenFuncName = 'TMSWordTrialPsychophys'; %function called by doStaircase to make stimuli

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
stimParams.subjName = subjectParams.name;

%% Do the staircase

display = openScreen(display,hideCursor);

newDataSum = doStaircase(display, stairParams, stimParams, trialGenFuncName, priorityLevel, logFID, 'precomputeFirstTrial');

display = closeScreen(display);

%% plot, save, and close
try
    PSsaveData(subjectParams, newDataSum)
    desiredPerf = 0.85;  % set desired level of performance here
    
    % Reload latest dataSum (combined across sessions)
    tmp = load(subjectParams.dataSumName);
    newDataSum = tmp.dataSum;  clear tmp;
    
    
    if strcmp(exptType,'contour')  % combine all the staircases
        % Combine data across all interleaved staircases (usually 2)
        combDataSum.history = cat(2,newDataSum(1:end).history);
        combDataSum.stimLevels = newDataSum(1).stimLevels;
        combDataSum.numTrials = sum( cat(1,newDataSum(1:end).numTrials) , 1);  % sum across staircases
        combDataSum.numCorrect = sum( cat(1,newDataSum(1:end).numCorrect) , 1);
        analysis = analyzeStaircase(combDataSum,'doPlot','threshErr',200);  % analyze the staircase you just ran
        
        % get a certain threshold for performance
        thresh = 1-getWeibullPerfThresh(analysis,desiredPerf);
        analysis.thresh85Perc = 1-thresh;  % to make it analagous to analysis.thresh, in that 1-thresh is the real threshold;
        
        % An easier way to do the above is to use the 82% performance threshold automatically calculated for you by analyzeStaircase
        %thresh = analysis.thresh;  % get threshold for use in next step of expt
        
    elseif strcmp(exptType,'dots')  % separate staircases for luminance and for motion
        
        
        combDataSum(1).history = cat(2,newDataSum(1:2:end).history);
        combDataSum(1).stimLevels = newDataSum(1).stimLevels;
        combDataSum(1).numTrials = sum( cat(1,newDataSum(1:2:end).numTrials) , 1);  % sum across staircases
        combDataSum(1).numCorrect = sum( cat(1,newDataSum(1:2:end).numCorrect) , 1);
        
        % combine even staircases separately, since these are a different "polar angle"
        combDataSum(2).history = cat(2,newDataSum(2:2:end).history);
        combDataSum(2).stimLevels = newDataSum(2).stimLevels;
        combDataSum(2).numTrials = sum( cat(1,newDataSum(2:2:end).numTrials) , 1);  % sum across staircases
        combDataSum(2).numCorrect = sum( cat(1,newDataSum(2:2:end).numCorrect) , 1);
        
        
        % analyze new dataSum, separately for each of 2 polar angles
        analysis{1} = analyzeStaircase(combDataSum(1),'doPlot','threshErr',200);  % analyze the staircase for first type of stimulus
        thresh{1} = 1-getWeibullPerfThresh(analysis{1},desiredPerf);
        analysis{1}.thresh85Perc = 1-thresh{1};  % to make it analagous to analysis.thresh, in that 1-thresh is the real threshold;
        
        
        analysis{2} = analyzeStaircase(combDataSum(2),'doPlot','threshErr',200);  % analyze the staircase for second type of stimulus
        thresh{2} = 1-getWeibullPerfThresh(analysis{2},desiredPerf);
        analysis{2}.thresh85Perc = 1-thresh{2};  % to make it analagous to analysis.thresh, in that 1-thresh is the real threshold;
    end
    
    % save analysis
    analysisFile = fullfile(dataDir,[subjectParams.name '_' date 'analysis.mat']);
    save(analysisFile,'analysis');
catch
    warning('might not have finished the experiment')
    for ii = 1:100
        ShowCursor;
    end
    rethrow(lasterror)
end
fclose(logFID(1));

ShowCursor;

return



function [display] = PSinitDisplay
% function [display] = PSInitDisplay
%   initialize the monitor display settings for phase scramble staircase

try
    display = loadDisplayParams('NEC485.mat');
catch
    display = loadDisplayParams;
end

% get any external devices
display.devices = getDevices;

%set the display to the biggest square that fits on the monitor
display.radius = pix2angle(display,floor(min(display.numPixels)/2));
return

function display = PSinitFixParams(display, stimParams)


display.fixType        = 'dot';
display.fixSizePixels  = 3;

% % for isoluminant fixation
% display.fixColorRgb    = [ 253 137 124 255;...
%     253 137 124 255;...
%     1  117 130 255;...
%     display.backColorRgb];

display.fixColorRgb    = [127 0 0 255;...
    127 0 0 255;...
    display.backColorRgb];
dim.x                  = display.numPixels(1);
dim.y                  = display.numPixels(2);
%ecc                    = angle2pix(display, stimParams.fixationEcc);

%display.fixStim        = round([0 -1 1] * ecc + dim.x./2);
display.fixY           = round(dim.y./2);
display.fixX           = round(dim.x./2);

function [dataDir] = TMSinitDataDir(exptType)
% function [dataDir] = TMSInitDataDir(exptType)
% choose the directory to store data for TMS Staircase

dataDir = ['/Users/Shared/PsychophysData/TMSStaircase/' exptType];

if(~exist(dataDir,'dir')),
    mkdir(dataDir);
end

return

function thresh = getWeibullPerfThresh(analysis,perfThreshy)
% perfThreshy is the desired performance level threshold based on the
% Weibull gotten from analyzeStaircase.
arg = -log((analysis.flake-perfThreshy)/(analysis.flake-analysis.guess));
threshy = 1-(1-analysis.guess)*exp(-1);	% 0.8161 for 0.5 guess rate
k = (-log( (1-threshy)/(1-analysis.guess) ))^(1/analysis.slope);
thresh = (analysis.thresh/k)*nthroot(arg,analysis.slope);

return