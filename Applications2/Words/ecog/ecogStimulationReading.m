function ecogStimulationReading
%
% This script runs an event-related words experiment, showing stimuli
% regularly.  This is meant to be run during electrical stimulation in ECoG
% patients.
%
%       ecogStimulationReading
%
%   Set loadParfileFlag to 1 below if you are making an experiment that you
%   want to read in from a pregenerated parfile (e.g. through optseq2).
%   Otherwise, if loadParfileFlag is 0, you will need a stimOrder.txt file
%   in the stim folder which specifies the stimuli and condition numbers
%   for each trial (in 2 columns, with each row corresponding to a trial).
%
% written: amr 2010-01-06 (based on PhaseScrambleEventRelated)
%


params.ScanName = 'StimulationReading';  % Enter the name of your functional block scan here (used in saving data)
params.baseDir = ['/Users/Shared/ecogData/' params.ScanName]; % directory that contains stim folder with stimuli
params.subjName = input('Subject name? ','s');
params.scanNumber = input('Scan number? ');
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
    % create and save out all the experiment information
    loadParfileFlag = 0;  % if set to 1, you have a pre-generated parfile (e.g. from optseq2) that specifies onset times (i.e. ITIs),
                                    % ... conds, labels, and trial lengths
    params.savedTrialsDir = ecogWordMakeStimulationReading(params,loadParfileFlag);
    %savedTrialsDir = makeWordScanFromParfile(baseDir,stimDir,exptCode)
    
else % run the experiment

    % 1st, load in the parameters and directory with trial information
    paramInfoFile = fullfile(params.savedTrialsDir,'paramInfoFile.mat');
    load(paramInfoFile);
    
    % Then, run the experiment
    [ssResponses, ssRTs, savedResponsesFile,quitProg,tenKeyFlag] = ecogRunEventRelated(params.ScanName,params,params.savedTrialsDir);
    
    if ~quitProg
    % Calculate performance and save them out
        [PC,meanRT] = calcPerformanceMW(ssResponses,ssRTs,params,tenKeyFlag);  %PC and meanRT are structs
        save(savedResponsesFile,'PC','meanRT','-append');
    end
end

return