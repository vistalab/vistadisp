% To create the appropriate par files that are read in here, run
% ShuffleWordsAndConditions for each subject.  Then run the code below,
% making sure to change the subjName field.
%

clear
params.subjName = input('Subject Initials?  ','s');
ecogWordMixtureMakeStimOrderFiles(params.subjName)  %

%params.subjName = 'sr';

params.ScanName = 'WordMixture';  % Enter the name of your functional block scan here (used in saving data)
params.baseDir = ['/Users/Shared/ecogData/' params.ScanName]; % directory that contains stim folder with stimuli
params.stimDir = fullfile(params.baseDir,'stim');  % where pictures of normal word stimuli are located

% Create incidental reading trials (scans 1-10)
for sn = 1:10
    params.scanNumber = sn;
    params.savedTrialsDir = fullfile(params.baseDir,'stim',params.subjName,['Scan_' num2str(params.scanNumber)]);  % where the saved trial information/images are
    params.taskType = 2;  % 2 is fixation task
    params.nouserinput = 1; % if you have this field in params, then matlab won't stop to ask you things, so it should just run
    ecogWordMixture(params)
end

% Create a test/practice run (needs a stimOrder.txt file in SS directory)
for sn = 99
    params.scanNumber = sn;
    params.savedTrialsDir = fullfile(params.baseDir,'stim',params.subjName,['Scan_' num2str(params.scanNumber)]);  % where the saved trial information/images are
    params.taskType = 2; % 1 is lexical decision
    params.nouserinput = 1; % if you have this field in params, then matlab won't stop to ask you things, so it should just run
    ecogWordMixture(params)
end

% Create lexical decision runs (scans 11-20)
for sn = 11:20
    params.scanNumber = sn;
    params.savedTrialsDir = fullfile(params.baseDir,'stim',params.subjName,['Scan_' num2str(params.scanNumber)]);  % where the saved trial information/images are
    params.taskType = 1; % 1 is lexical decision
    params.nouserinput = 1; % if you have this field in params, then matlab won't stop to ask you things, so it should just run
    ecogWordMixture(params)
end

% Create a test/practice run for lexical decision (needs a stimOrder.txt file in SS directory)
for sn = 101
    params.scanNumber = sn;
    params.savedTrialsDir = fullfile(params.baseDir,'stim',params.subjName,['Scan_' num2str(params.scanNumber)]);  % where the saved trial information/images are
    params.taskType = 1; % 1 is lexical decision
    params.nouserinput = 1; % if you have this field in params, then matlab won't stop to ask you things, so it should just run
    ecogWordMixture(params)
end

% In case you need to re-create stuff after changing some stim params, you
% can do it here.
% for sn = 14:15
%     params.scanNumber = sn;
%     params.savedTrialsDir = fullfile(params.baseDir,'stim',params.subjName,['Scan_' num2str(params.scanNumber)]);  % where the saved trial information/images are
%     params.taskType = 1; % 1 is lexical decision
%     params.nouserinput = 1; % if you have this field in params, then matlab won't stop to ask you things, so it should just run
%     ecogWordMixture(params)
% end