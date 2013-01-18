function [PCacrossSubj,meanRTacrossSubj,stats] = TMSmotionWordsCombineSubjects(subjectPaths,numrunsPerSubject)
% Function to combine behavioral TMS data from multiple subjects
%
% subjectPaths is a cell array of paths to subject data (which contain .mat
% savedResponses files with individual PC and meanRT saved for each run,
% over which you can run TMSmotionWordsCombineRuns.m
%
%   [PCacrossSubj,meanRTacrossSubj,stats] = TMSmotionWordsCombineSubjects(subjectPaths,numrunsPerSubject)
%

%Set subjectPaths if not passed in
% if notDefined('subjectPaths')
%     basepath = '/Users/Shared/TMSData/MotionWords/stim';
%     subjects = {'amr','rfd','al','sd','jt','bw','bl','nl'};
%     subjectPaths = {...
%         fullfile(basepath,subjects{1},'Data'),...
%         fullfile(basepath,subjects{2},'Data'),...
%         fullfile(basepath,subjects{3},'Data'),...
%         fullfile(basepath,subjects{4},'Data'),...
%         fullfile(basepath,subjects{5},'Data'),...
%         fullfile(basepath,subjects{6},'Data'),...
%         fullfile(basepath,subjects{7},'Data'),...
%         fullfile(basepath,subjects{8},'Data'),...
%         };
% end

if notDefined('subjectPaths')
    basepath = '/Users/Shared/TMSData/MotionWords/stim';
    subjects = {'amrVWFA','dkVWFA','alVWFA'};
    subjectPaths = {...
        fullfile(basepath,subjects{1},'Data'),...
        fullfile(basepath,subjects{2},'Data'),...
        fullfile(basepath,subjects{3},'Data'),...
        };
end

if ~exist('numrunsPerSubject','var')
    numrunsPerSubject = 3;
end

% Get all the individual PC and meanRT (1 row for each subject)
suppressFigures = 1;
for subjectNum = 1:length(subjectPaths)
    % Combine runs for each subject
    [PC,meanRT] = TMSmotionWordsCombineRuns(subjectPaths{subjectNum},[1:numrunsPerSubject],suppressFigures);
    
    % Now each row of everything will be a subject; columns stay the same
    PCavg.numCorrectTrials(subjectNum,:) = PC.numCorrectTrials;
    PCavg.numTotalTrials(subjectNum,:) = PC.numTotalTrials;
    
    RTavg.byCond(subjectNum,:) = meanRT.byCond;
    RTavg.correctTrials(subjectNum,:) = nanmean(meanRT.correctTrials);
    RTavg.allTrials(subjectNum,:) = nanmean(meanRT.allTrials);
    
end

% Combine across subjects for meanRT.byCond
RTavg.byCond = nanmean(RTavg.byCond);

[PCacrossSubj,meanRTacrossSubj] = TMSmotionWordsAnalyzeBehavior(PCavg,RTavg);




%% Calculate stats using ANOVA
% For PC, we have factors of 1) cue type and 2) latency
% Other potential factors are subject or word/NW (lexicality)
%
% Each cue type and latency has an entry for each subject (but also
% potentially for each run)

motConds = [1 2 7 8 13 14 19 20 25 26 31 32];  % all conditions with words defined by motion
lumConds = [3 4 9 10 15 16 21 22 27 28 33 34]; % all conditions with words defined by luminance
PSconds =  [5 6 11 12 17 18 23 24 29 30 35 36];% all conditions with words defined by contours (phase-scrambling)

wordConds = [1:2:36];  % all the odd conditions are words
NWconds = [2:2:36];  % all the even conditions are nonwords

latencies = [-95 5 87 165 264 885];
PCacrossSubj.percCor = PCacrossSubj.numCorrectTrials ./ PCacrossSubj.numTotalTrials;

% Collapse across words and nonwords
for latencyCount = 1:length(latencies)
    
    % Motion
    curConds = motConds((latencyCount-1)*2+1 : (latencyCount-1)*2+2);
    curVals = PCacrossSubj.percCor(:,curConds);  % all the subjects, current conditions
    x(1:length(subjects),latencyCount) = mean(curVals,2);  % mean of word and nonwords conditions
    
    % Luminance
    curConds = lumConds((latencyCount-1)*2+1 : (latencyCount-1)*2+2);
    curVals = PCacrossSubj.percCor(:,curConds);
    x((length(subjects)+1):(2*length(subjects)),latencyCount) = mean(curVals,2);
    
    % Phase-Scramble
    curConds = PSconds((latencyCount-1)*2+1 : (latencyCount-1)*2+2);
    curVals = PCacrossSubj.percCor(:,curConds);
    x((2*length(subjects))+1:(3*length(subjects)),latencyCount) = mean(curVals,2);
    
end

% x columns are latencies (in order)
% x rows are each subject's observations and each condition type.  The
% order of the condition types is:  motion, luminance, phase-scramble
[p, table, stats] = anova2(x,length(subjects));  % this would be a separate entry for each subject at each cue type (rows, in sets of numSubjects) and latency (columns)

% Also do a 1-way anova on each condition with latency as a factor
motVals = x(1:length(subjects),:);
lumVals = x((length(subjects))+1:(2*length(subjects)),:);
PSvals = x((2*length(subjects))+1:(3*length(subjects)),:);

[pMot,tableMot,statsMot] = anova1(motVals);
[pLum,tableLum,statsLum] = anova1(lumVals);
[pPS,tablePS,statsPS] = anova1(PSvals);
