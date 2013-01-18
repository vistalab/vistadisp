function TMSmotionWordsEventRelated
%
% This script runs the TMS version of the event-related motion words experiment.
%
% We hypothesize that TMS to hMT+ will interfere with the processing of
% motion-defined words.  It may or may not also interfere with the
% processing of countour-defined words (depending on what you believe about
% the causal role of the magnocellular pathways deficits in dyslexics).
%
%       TMSmotionWordsEventRelated
%
%   This code either runs the experiment or it will build a new experiment, depending on if it already exists
%   So, if you haven't yet made the experiment, you
%   need to run this script twice, first to build the experiment, then to
%   run it.
%
%   Set loadParfileFlag to 1 below if you are making an experiment that you
%   want to read in from a pregenerated parfile (e.g. through optseq2).
%   Otherwise, if loadParfileFlag is 0, you will need a stimOrder.txt file
%   in the stim folder which specifies the stimuli and condition numbers
%   for each trial (in 2 columns, with each row corresponding to a trial).
%
% ported from MotionWordsEventRelated by amr Dec 9, 2009
%
% May 20, 2010:  added ability to load in psychophysics thresholds (saved out from
%   TMSwordStaircase)
%


%% PARAMETERS

params.ScanName = 'MotionWords';  % Enter the name of your functional block scan here (used in saving data)
params.baseDir = '/Users/Shared/TMSData/MotionWords/'; % ScanName ]; % directory that contains stim folder with stimuli
params.subjName = input('Subject name? ','s');
params.scanNumber = input('Run number? ');
params.stimDir = fullfile(params.baseDir,'stim');  % where pictures of normal word stimuli are located
params.savedTrialsDir = fullfile(params.baseDir,'stim',params.subjName,['Scan_' num2str(params.scanNumber)]);  % where the saved trial information/images are

if exist(params.savedTrialsDir,'dir')
    fprintf('Saved trial directory %s\n',params.savedTrialsDir)
    fprintf('exists! Will run existing experiment. \n\n')
    makeNewExperimentFlag = 0;
else
    fprintf('Saved trial directory %s\n',params.savedTrialsDir)
    fprintf('does not exist! Will create new experiment. \n\n')
    makeNewExperimentFlag = 1;
end

%% Decide whether to make a new experiment or load in a saved one (based on exptCode)
if makeNewExperimentFlag % create a new experiment
    
    % Get thresholds from psychophysics
    thresh = loadPsychophysThreshs;
    
    % create and save out all the experiment information
    loadParfileFlag = 0;  % if set to 1, you have a pre-generated parfile (e.g. from optseq2) that specifies onset times (i.e. ITIs),
    % ... conds, labels, and trial lengths
    params.savedTrialsDir = TMSmakeMotionWordsRun(params,loadParfileFlag,thresh);
    %savedTrialsDir = makeWordScanFromParfile(baseDir,stimDir,exptCode)
    
else % run the experiment
    
    % 1st, load in the parameters and directory with trial information
    paramInfoFile = fullfile(params.savedTrialsDir,'paramInfoFile.mat');
    load(paramInfoFile);
    
    % Then, run the experiment
    [ssResponses, ssRTs, savedResponsesFile] = TMSrunEventRelated(params.ScanName,params,params.savedTrialsDir);
    
    % Calculate performance and save them out
    tenKeyFlag = 1;
    
    % General way of getting performance for each condition separately from subject responses
    params.tooLongFlag = 0; % if 1, does not count trials where subject took too long to respond
    [PC,meanRT] = calcPerformanceMW(ssResponses,ssRTs,params,tenKeyFlag);  %PC and meanRT are structs
    
    % Analyze data specifically for this TMS experiment
    [PC,meanRT] = TMSmotionWordsAnalyzeBehavior(PC,meanRT);
    
    save(savedResponsesFile,'PC','meanRT','-append');
end

return



function thresh = loadPsychophysThreshs

analysisFile = mrvSelectFile('r','mat','Select saved psychophys analysis for phase-scramble','/Users/Shared/PsychophysData/TMSstaircase/contour/');

if ~isempty(analysisFile)
    load(analysisFile)
    thresh.PS = round(100*(1-analysis.thresh));  % must be an integer between 0 and 100
    
    analysisFile = mrvSelectFile('r','mat','Select saved psychophys analysis for dots','/Users/Shared/PsychophysData/TMSstaircase/dots/');
    load(analysisFile)
    thresh.mot = round(100*(analysis{1}.thresh));
    thresh.lum = round(100*(analysis{2}.thresh));  % can use .thresh or .thresh85Perc -- .thresh is 82% correct threshold
    
else   % if user cancels choosing first file, allow user to enter thresholds manually
    thresh.PS = input('Threshold for phase scramble stimuli (scramble level, 0-100):  ');
    thresh.mot = input('Threshold for motion defined (motion coherence, 0-100):  ');
    thresh.lum = input('Threshold for luminance defined (luminance coherence, 0-100):  ');
end

return

