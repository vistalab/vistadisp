function responseSortParfiles(paramsFile,ssResponses,ssRTs,dataFile)
%
%   function responseSortParfiles([paramsFile,ssResponses,ssRTs,dataFile])
%
% This function will produce several new parfiles for a particular word
% experiment.  These parfiles are based on subject responses, so that
% conditions are coded not based on stimuli but based on response (or some
% interaction between response and stimuli).
%
% Right now we want to produce the following parfiles
% -- 2 conditions:  correct and incorrect
% -- 4 conditions:  correct words, incorrect words, correct nonwords,
% incorrect nonwords
% -- 2 conditions:  subject response = word, subject response = nonword
% -- 4 conditions:  hits (word that are words), false alarms (words that
% are nonwords), misses (nonwords that are words), correct rejections
% (nonwords that are nonwords)
%
% paramsFile is the file that holds all the parameters for the given
% experimental run.  The params include the parfilepath and the condition
% order (and therefore the expected or correct responses for each trial).
%
% dataFile is the file that holds all the subject's actual responses for a
% particular session.  If you're calling this script, you need to call it
% with this file.  If you're running it manually, it'll let you choose a
% file to use.
%
% Note the flag that you can set (tooLongFlag) to count trials where the
% user took too long to respond (or didn't respond?) as fixation trials.
% The default here is to have this flag on (i.e. exclude those trials).
%
% Much of this code was taken from calcPeformanceMW.m
%
% amr March 10, 2009
%


% If running manually, choose data file manually
if ~exist('paramsFile','var')
    dataFile = mrvSelectFile('r','mat','Select response data file to use.','/Users/Shared/AndreasWordsMatlab/EventRelatedCode/ResponseSorting/stim');
    load(dataFile);
    paramsFile = fullfile(fileparts(fileparts(dataFile)),'paramInfoFile.mat');  % we know the paramInfoFile is just a couple directories down from the response file
end

% Load params and parFilePath from paramsFile
params = [];
parFilePath = [];
load(paramsFile);

% Code the response as the following:
[responseCodes,ssRTs,ssResponses] = codeWordResponses(ssResponses,ssRTs,params);
% % Codes for responseCodes:
% %   1: word that subject thought was word (correct, hit)
% %   2: word that subject thought was not a word (incorrect, miss)
% %   3: nonword that subject thought was nonword (correct, correct reject)
% %   4: nonword that subject thought was a word (incorrect, false alarm)
% %   5: control trial that subject got right
% %   6: control trial that subject got wrong
% %   9: subject took too long to respond and response is counted as fixation (i.e. tooLongFlag = 1 & ssResponse='99')
    
% Read in original parfile, which is saved in paramsFile
if ~exist(parFilePath,'file')  % several parfilepaths were originally coded wrong, where they weren't real files
    parFilePath = mrvSelectFile('r','par','Select original parfile',fileparts(parFilePath));
    % save out correct parFilePath
    save(paramsFile,'parFilePath','-append')
end

[par.onset, par.cond, par.label, par.colors] = readParFile(parFilePath);


%% Assign response codes to each trial

noFixTrials = find(par.cond);  % don't include fixation condition (shouldn't have responses associated)

%% Make new parfiles

% Hits, misses, correct rejections, false alarms (response codes 1,2,3,4)
parSigDetect.cond = zeros(1,length(par.cond));  % initialize and get fixations
parSigDetect.cond(noFixTrials) = responseCodes;  % conditions directly correspond to responseCodes
labelingScheme = {'Hits';'Misses';'CorRejs';'FalseAlarms'};
labelingScheme{9}= 'Fix';  % label trials that took too long to respond as fixation
parSigDetect.label = repmat({'Fix'},1,length(par.label));
parSigDetect.label(noFixTrials) = labelingScheme(parSigDetect.cond(noFixTrials));
parSigDetect.onset = par.onset;  % onsets stay the same as original
numHits = length(cell2mat(strfind(labelingScheme(parSigDetect.cond(noFixTrials)),'Hits')))
numMisses = length(cell2mat(strfind(labelingScheme(parSigDetect.cond(noFixTrials)),'Misses')))
numCorRejs = length(cell2mat(strfind(labelingScheme(parSigDetect.cond(noFixTrials)),'CorRejs')))
numFalseAlarms = length(cell2mat(strfind(labelingScheme(parSigDetect.cond(noFixTrials)),'FalseAlarms')))
parSigDetect.cond(find(parSigDetect.cond==9))=0;  % replace condition 9 (too long) with condition 0 (fixation)
% New code added for RT measurements
hitTrials = find(parSigDetect.cond(noFixTrials)==1);  % couldn't figure out how to use "labelingScheme"
HitsRT = mean(ssRTs(hitTrials));
missTrials = find(parSigDetect.cond(noFixTrials)==2);
MissesRT = mean(ssRTs(missTrials));
corRejTrials = find(parSigDetect.cond(noFixTrials)==3);
CorRejsRT = mean(ssRTs(corRejTrials));
falseAlarmTrials = find(parSigDetect.cond(noFixTrials)==4);
FalseAlarmsRT = mean(ssRTs(falseAlarmTrials));


% Correct and incorrect (2 conditions)-- response codes 1,3 vs. 2,4
condsScheme = [1 2 1 2]; % responseCodes 1 and 3 and correct (new condition 1)
labelingScheme = {'Correct';'Incorrect'};
labelingScheme{9}= 'Fix';
condsScheme(9)= 9;  % just temporarily label it as something (this is kind of a hack)
parCorIncor.cond = zeros(1,length(par.cond));
parCorIncor.cond(noFixTrials) = condsScheme(responseCodes);  % replace response codes with new conditions
parCorIncor.label = repmat({'Fix'},1,length(par.label));
parCorIncor.label(noFixTrials) = labelingScheme(parCorIncor.cond(noFixTrials));
parCorIncor.onset = par.onset;
numCorrectResp = length(cell2mat(strfind(labelingScheme(parCorIncor.cond(noFixTrials)),'Correct')))
numIncorrectResp = length(cell2mat(strfind(labelingScheme(parCorIncor.cond(noFixTrials)),'Incorrect')))
parCorIncor.cond(find(parCorIncor.cond==9))=0;  % replace condition 9 (too long) with condition 0 (fixation)
% RT measurements by conditions (new code)
corTrials = find(parCorIncor.cond(noFixTrials)==1);
CorrectRespRT = mean(ssRTs(corTrials));
incorTrials = find(parCorIncor.cond(noFixTrials)==2);
IncorrectRespRT = mean(ssRTs(incorTrials));


% Word and nonword responses (regardless of stimulus)-- response codes 1,4 vs. 2,3
condsScheme = [1 2 2 1]; % responseCodes 1 and 4 were perceived as words (new condition 1)
labelingScheme = {'WordResponse';'NWResponse'};
labelingScheme{9}= 'Fix';
condsScheme(9) = 9;
parWordNW.cond = zeros(1,length(par.cond));
parWordNW.cond(noFixTrials) = condsScheme(responseCodes);
parWordNW.label = repmat({'Fix'},1,length(par.label));
parWordNW.label(noFixTrials) = labelingScheme(parWordNW.cond(noFixTrials));
parWordNW.onset = par.onset;
numResponse1 = length(cell2mat(strfind(labelingScheme(parWordNW.cond(noFixTrials)),'WordResponse')))
numResponse2 = length(cell2mat(strfind(labelingScheme(parWordNW.cond(noFixTrials)),'NWResponse')))
parWordNW.cond(find(parWordNW.cond==9))=0;  % replace condition 9 (too long) with condition 0 (fixation)
% RT measurements by conditions (new code)
resp1Trials = find(parWordNW.cond(noFixTrials)==1);
Response1RT = mean(ssRTs(resp1Trials));
resp2Trials = find(parWordNW.cond(noFixTrials)==2);
Response2RT = mean(ssRTs(resp2Trials));



%% Write out new parfiles

[d,f] = fileparts(dataFile);
writeParfile(par,fullfile(d,[f '_unsorted.par']));
writeParfile(parSigDetect,fullfile(d,[f '_parSigDetect.par']));
writeParfile(parCorIncor,fullfile(d,[f '_parCorIncor.par']));
writeParfile(parWordNW,fullfile(d,[f '_parWordNW.par']));
numTrialsFile = [f 'TrialsPerCond.mat'];  % where to save info about number of trials per condition
save(fullfile(d,numTrialsFile),'numHits','numMisses','numCorRejs','numFalseAlarms','numCorrectResp',...
    'numIncorrectResp','numResponse1','numResponse2');
save(fullfile(d,numTrialsFile),'HitsRT','MissesRT','CorRejsRT','FalseAlarmsRT','CorrectRespRT',...
    'IncorrectRespRT','Response1RT','Response2RT','-append');
fprintf('Saved number of trials and RTs per new condition in:  %s\n',fullfile(d,numTrialsFile));


return


