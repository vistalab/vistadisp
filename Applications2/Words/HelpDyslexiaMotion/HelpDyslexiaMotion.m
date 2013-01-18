%% This function will control the HelpDyslexiaMotion psychophysics.  It
%% will function similarly to any of the Scan Apps made by amr:  Since we
%% require movies with multiple frames, those movies will need to be made
%% and saved ahead of time for quicker loading.  Static stimuli can just
%% use one frame of the movies (because the movies should have both
%% luminance and motion cues).  Specifically, the hypothesis is that adding
%% motion cues should help dyslexics read better, either because we are
%% just adding an additional cue or because we are specifically helping
%% communication between MT and VWFA.
%
%


%% PARAMETERS

params.ScanName = 'HelpDyslexiaMotion';  % Enter the name of your functional scan here (used in saving data)
params.baseDir = '/Users/Shared/PsychophysData/HelpDyslexiaMotion/'; % ScanName ]; % directory that contains stim folder with stimuli
params.subjName = input('Subject name? ','s');
params.listType = lower(input('List Type? LetterWordID  WordAttack  C&C  :  ','s'));
params.form = lower(input('Form (A) or (B):  ','s'));
params.stimType = input('''Motion'' or ''Static''   :   ','s');
params.stimDir = fullfile(params.baseDir,'stim');  % where saved stimuli are located
params.savedTrialsDir = fullfile(params.baseDir,'stim',params.listType,params.form,params.stimType);  % where the saved trial information/images are

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
    numFramesPerContrastImage = []; %10; [] means don't change  % means there will be this many frames for movies that are usually made from 1 frame (allows fixation dot color to change)                               
    params.savedTrialsDir = makeHelpDyslexiaMotionPsychophys(params,loadParfileFlag,numFramesPerContrastImage);
    %savedTrialsDir = makeWordScanFromParfile(baseDir,stimDir,exptCode)
    
else % run the experiment

    % 1st, load in the parameters and directory with trial information
    paramInfoFile = fullfile(params.savedTrialsDir,'paramInfoFile.mat');
    load(paramInfoFile);
    
    % Then, run the experiment
    tic
    [ssResponses, ssRTs, savedResponsesFile] = runFuncEventRelatedMovies(params.ScanName,params,params.savedTrialsDir);
    toc
    
end

return