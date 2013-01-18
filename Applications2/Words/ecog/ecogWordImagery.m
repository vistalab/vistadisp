function ecogWordImagery
%
% This script runs an event-related words experiment, showing stimuli
% regularly.  The idea here is to show stimuli (pictures of objects) for a
% short period of time (~200ms), followed by a cue that tells the subject
% to either 1) think of the name of that object, imagine that word, and
% spell it backwards, or 2) imagine the image and describe it.  (2) is the
% control condition, so it can occur less often (~30% of the time) in order
% to get more trials of (1).
%
%       ecogWordImagery
%
%   Set loadParfileFlag to 1 below if you are making an experiment that you
%   want to read in from a pregenerated parfile (e.g. through optseq2).
%   Otherwise, if loadParfileFlag is 0, you will need a stimOrder.txt file
%   in the stim folder which specifies the stimuli and condition numbers
%   for each trial (in 2 columns, with each row corresponding to a trial).
%
% written: amr 2010-07-27 (based on PhaseScrambleEventRelated)
%


params.ScanName = 'WordImagery';  % Enter the name of your functional block scan here (used in saving data)
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
    params.savedTrialsDir = ecogWordMakeWordImagery(params,loadParfileFlag);
    %savedTrialsDir = makeWordScanFromParfile(baseDir,stimDir,exptCode)
    
else % run the experiment

    % 1st, load in the parameters and directory with trial information
    paramInfoFile = fullfile(params.savedTrialsDir,'paramInfoFile.mat');
    load(paramInfoFile);
    
    % Then, run the experiment
    noFixFlag = 1;  % no fixation dot
    [ssResponses, ssRTs, savedResponsesFile, quitProg, tenKeyFlag] = ecogRunEventRelated(params.ScanName,params,params.savedTrialsDir,noFixFlag);
    
%     if ~quitProg
%     % Calculate performance and save them out
%         [PC,meanRT] = calcPerformanceMW(ssResponses,ssRTs,params,tenKeyFlag);  %PC and meanRT are structs
%         save(savedResponsesFile,'PC','meanRT','-append');
%     end
end

return