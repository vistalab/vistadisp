function PhaseScrambleEventRelated(exptCode)
%
% This script runs the event-related motion words experiment.
%
%       PhaseScrambleEventRelated([exptCode])
%
%   exptCode can either be the code (number) of a previously saved
%   experiment, or it can be the code for a new experimental design that
%   will be created. This code either runs the experiment (if the exptCode
%   already exists) or it will build a new experiment (if the exptCode
%   doesn't yet exist).  So, if you haven't yet made the experiment, you
%   need to run this script twice, first to build the experiment, then to
%   run it.
%
%   Set loadParfileFlag to 1 below if you are making an experiment that you
%   want to read in from a pregenerated parfile (e.g. through optseq2).
%   Otherwise, if loadParfileFlag is 0, you will need a stimOrder.txt file
%   in the stim folder which specifies the stimuli and condition numbers
%   for each trial (in 2 columns, with each row corresponding to a trial).
%
% written: amr 2009-02-27 (based on MotionWordsEventRelated)
%


% comments for possible GUI
%   -- allow user to load in an existing experiment (i.e. saved movies) and
%   run it
%   -- allow user to create a new experiment (based on stimOrder text file
%   or parfile?)
%   -- allow setting of parameters if creating a new experiment, or if you
%   load in an experiment, load in the appropriate parameters with it


%% PARAMETERS

ScanName = 'PhaseScrambleER';  % Enter the name of your functional scan here (used in saving data)

baseDir = ['/Users/Shared/AndreasWordsMatlab/EventRelatedCode/' ScanName]; % directory that contains stim folder with stimuli
stimDir = fullfile(baseDir,'stim');  % where pictures of normal word stimuli are located
        
%% Get experiment code
if notDefined('exptCode')
    exptCode = input('Experiment code/number to run or create:  ');
end

savedTrialsDir = fullfile(stimDir,['TrialMovies_' num2str(exptCode)]);  % where the saved trial information/images are
if exist(savedTrialsDir,'dir')
    fprintf('Saved trial directory %s\n',savedTrialsDir)
    fprintf('exists! Will run existing experiment. \n\n')
    makeNewExperimentFlag = 0;
else
    fprintf('Saved trial directory %s\n',savedTrialsDir)
    fprintf('does not exist! Will create new experiment. \n\n')
    makeNewExperimentFlag = 1;
end

%% Decide whether to make a new experiment or load in a saved one (based on exptCode)
if makeNewExperimentFlag % create a new experiment
    % create and save out all the experiment information
    loadParfileFlag = 1;  % if set to 1, you have a pre-generated parfile (e.g. from optseq2) that specifies onset times (i.e. ITIs),
                                    % ... conds, labels, and trial lengths
    savedTrialsDir = makePhaseScrambleERScan(baseDir,stimDir,exptCode,loadParfileFlag)
    %savedTrialsDir = makeWordScanFromParfile(baseDir,stimDir,exptCode)
    
else % run the experiment

    % 1st, load in the parameters and directory with trial information
    paramInfoFile = fullfile(savedTrialsDir,'paramInfoFile.mat');
    load(paramInfoFile);
    
    % Then, run the experiment
    [ssResponses, ssRTs, savedResponsesFile] = runFuncEventRelated(ScanName,params,savedTrialsDir);
    
    % Calculate performance and save them out
    [PC,meanRT] = calcPerformanceMW(ssResponses,ssRTs,params);  %PC and meanRT are structs
    fprintf('\nPerformance combined across conditions:  %0.2f percent\n',PC.tot*100);
    save(savedResponsesFile,'PC','meanRT','-append');
    
    % Response sort parfiles into different condition types
    responseSortParfiles(paramInfoFile,ssResponses,ssRTs,savedResponsesFile);
end

return