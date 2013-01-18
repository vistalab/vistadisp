function savedResponsesFile = TMSmotionWordsExcludeTrials(trialsToExclude)
% Function to add exclusion of certain trials to a file
% Appends the vector trialsToExclude to the savedResponsesFile (which user
% chooses), and reruns calcPerformanceMW to get new stats without those
% trials.  Leaves ssResponses and ssRTs untouched, so that original data is
% unchanged.  PC and meanRT are updated with new performance after
% excluding trials.
%
% Running the function will prompt the user for a subject name and run
% number.
%
%     savedResponsesFile = TMSmotionWordsExcludeTrials([trialsToExclude])
%
% trialsToExclude is a vector of trial numbers that you don't want included
% in your analysis
%

if notDefined('trialsToExclude')
    trialsToExclude = input('Trials to exclude:  ');
end


params.ScanName = 'MotionWords';  % Enter the name of your functional block scan here (used in saving data)
params.baseDir = '/Users/Shared/TMSData/MotionWords/'; % ScanName ]; % directory that contains stim folder with stimuli
params.subjName = input('Subject name? ','s');
params.stimDir = fullfile(params.baseDir,'stim');
params.scanNumber = input('Run number? ');
params.savedResponsesDir = fullfile(params.baseDir,'stim',params.subjName,'Data');  % where the saved responses are
params.savedTrialsDir = fullfile(params.baseDir,'stim',params.subjName,['Scan_' num2str(params.scanNumber)]);  % where the saved trial information/images are
params.tooLongFlag = 0;

savedResponsesFile = mrvSelectFile('r','mat','Select saved responses file',params.savedResponsesDir);

save(savedResponsesFile,'trialsToExclude','-append')

load(savedResponsesFile)

paramInfoFile = fullfile(params.savedTrialsDir,'paramInfoFile.mat');
load(paramInfoFile);

params.trialsToExclude = trialsToExclude;

tenKeyFlag = 1;

% General way of getting performance for each condition separately from subject responses
[PC,meanRT] = calcPerformanceMW(ssResponses,ssRTs,params,tenKeyFlag);  %PC and meanRT are structs

save(savedResponsesFile,'PC','meanRT','-append');


end


