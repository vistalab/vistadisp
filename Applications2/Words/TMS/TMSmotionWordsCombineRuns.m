function [PCavg,meanRTavg] = TMSmotionWordsCombineRuns(datapath,runsToProcess,suppressFigures)
%
% Function for getting percent correct and reaction time in each condition averaged across runs
% for TMSmotionWordsER scans.
%
%    [PCavg,meanRTavg] = TMSmotionWordsCombineRuns([datapath=pwd],[runsToProcess=all],[suppressFigures=0])
%
% If datapath is not defined, then datapath = pwd.  datapath should have the
% saved out savedResponses.mat files.
%
% runsToProcess specifies which runs to take in the directory (in order of
% dir, which is typically the order in which they were run).  If unset, all
% runs in the directory are used.
%
% if suppressFigures = 1, then it won't graph the results
%
% e.g. 
%  datapath = '/Users/Shared/TMSData/MotionWords/stim/amr/Data/';
% [PCavg,meanRTavg] = TMSmotionWordsCombineRuns(datapath)
%

curDir = pwd;
if notDefined('datapath'), datapath = pwd; end
cd(datapath)

if ~exist('suppressFigures','var'), suppressFigures = 0; end


% Initialize counters
PCavg.numTotalTrials = zeros(1,36);
PCavg.numCorrectTrials = zeros(1,36);
meanRTsum.byCond = zeros(1,36);
meanRTsum.correctTrialCount = zeros(1,36);


count = 0;

% fid = fopen('PC-byConditionAveraged.txt','wt');

allMatFiles = dir('*savedResponses.mat');

if isempty(allMatFiles)
    fprintf('\n\nNo savedResponses.mat files found.  Pick manually.')
    % Have the user keep picking files to add up trials per cond
    while 1
        behFile = mrvSelectFile('r','mat','Please select a behavior file. (Saved responses per condition)');
        if isempty(behFile)
            break
        end
        count = count+1;
        load(behFile)

        PCsum.byCond = PCsum.byCond + PC.byCond;
        % fprintf(fid,'%3.3f\t',PC.byCond);
        % fprintf(fid,'%s\n',' ');
    end
    
else   % you did find the files in the current directory, so process them
    meanRTavg.allTrials = [];
    meanRTavg.correctTrials = [];
    if ~exist('runsToProcess','var')
        runsToProcess = 1:length(allMatFiles);
    else
        %numRuns = numRunsToProcess;
        if length(allMatFiles) < max(runsToProcess)
            warning('Warning:  numRunsToProcess is greater than number of runs in datapath. Using all the runs I can find.')
            runsToProcess = 1:length(allMatFiles);
        end
    end
    for counter = 1:length(runsToProcess)
        curFile = runsToProcess(counter);
        behFile = allMatFiles(curFile).name;
        count = count+1;
        load(behFile)

        % Percent Correct
        PCavg.perRun(curFile,:) = PC.byCond;          % First just store all the PCs for each run-- to get STD later across runs
        PCavg.numTotalTrials = PCavg.numTotalTrials + PC.numTotalTrials; %(sum(~isnan(meanRT.allTrials),1));  % NaNs in meanRT.allTrials are excluded trials or trials where subject took too long
        PCavg.numCorrectTrials = PCavg.numCorrectTrials + PC.numCorrectTrials; %(sum(~isnan(meanRT.correctTrials),1));
        % fprintf(fid,'%3.3f\t',PC.byCond);
        % fprintf(fid,'%s\n',' ');
        

        % Reaction time -- let's make a big matrix of all the reaction
        % times for each trial in each run, and then later we'll take the
        % mean and STD
        meanRTavg.allTrials(end+1:end+2,:) = meanRT.allTrials;
        meanRTavg.correctTrials(end+1:end+2,:) = meanRT.correctTrials;
        

    end

end
    

% Average across runs
PCavg.byCond = PCavg.numCorrectTrials./PCavg.numTotalTrials;
% fprintf(fid,'%s\n',' ');
% fprintf(fid,'%s\n',' ');
% fprintf(fid,'%s\n','PC averaged across runs:')
% fprintf(fid,'%3.3f\t',PCavg.byCond);
% fprintf(fid,'%s\n',' ');
% fprintf(fid,'%s\n',' ');


% Average RT across runs
meanRTavg.byCond = nanmean(meanRTavg.correctTrials);  % only for correct trials within that condition
meanRTavg.STD = nanstd(meanRTavg.correctTrials);
% fprintf(fid,'%s\n','RT averaged across runs:');
% fprintf(fid,'%3.3f\t',meanRTavg.byCond);
% fprintf(fid,'%s\n',' ');
% fprintf(fid,'%s\n',' ');


%fprintf(fid,'%s%0.0f\n','Total number files counted:  ',count);

%fclose(fid);

[PCavg,meanRTavg] = TMSmotionWordsAnalyzeBehavior(PCavg,meanRTavg,suppressFigures);


cd(curDir)
end

% % Useful code for saving out trials to exclude
% trialsToExclude = [1:4];
% runNum = 1;  % doesn't refer to scan number but instead to order in which you ran them on that subject
% behFile = allMatFiles(runNum).name;
% save(behFile,trialsToExclude,'-append')
