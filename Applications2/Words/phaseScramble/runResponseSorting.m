function runResponseSorting(exptDir)
%
% This script runs the event-related response sorting experiment.  There
% can be 2 tasks:  detection or lexical decision.
%
% This is generally called by responseSorting.m
%

% 
ScanName = 'ResponseSorting';  % Enter the name of your functional scan here (used in saving data)

% 1st, load in the parameters and directory with trial information
paramInfoFile = fullfile(exptDir,'paramInfoFile.mat');
load(paramInfoFile);

% Then, run the experiment
[ssResponses, ssRTs, savedResponsesFile] = runFuncEventRelated(ScanName,params,exptDir);

% Calculate performance and save them out
[PC,meanRT] = calcPerformanceMW(ssResponses,ssRTs,params);  %PC and meanRT are structs
fprintf('\nPerformance combined across conditions:  %0.2f percent\n',PC.tot*100);
save(savedResponsesFile,'PC','meanRT','-append');

% Response sort parfiles into different condition types
responseSortParfiles(paramInfoFile,ssResponses,ssRTs,savedResponsesFile);

return