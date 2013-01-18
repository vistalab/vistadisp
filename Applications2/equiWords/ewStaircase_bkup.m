function ewStaircase_bkup

sca;

[stimParams, stairParams]       = ewInitParams_bkup;
[stimParams.dataDir]            = ewInitDataDir;
[subj]                          = ewGetSubjParams(stimParams.dataDir); if subj.num==0, return; end
[display]                       = ewInitDisplay;

% Set names of files to be used during staircase
stimParams.stimFileCache        = fullfile(stimParams.dataDir,'trunk','stimCache.mat'); % Word images / lists for trial use
stimParams.listFile             = fullfile(stimParams.dataDir,'trunk',stairParams.stimList); % Word lists for stim generation
stimParams.indHistory           = fullfile(stimParams.dataDir,sprintf('S%02dhistory.mat',subj.num)); % Words already run

for lap=1:stairParams.laps
    for i=1:stairParams.measuredSizes
        if i==1 && lap==1
            stairParams.initTrialCount=1;
        else
            stairParams.initTrialCount=0;
        end
        stairParams.ind             = ((lap-1)*stairParams.measuredSizes)+i;
        [stairParams n]             = ewBalanceOrder(stairParams,subj,lap);
        [logFID]                    = ewInitLogFID(stimParams,stairParams,subj);
        newDataSum                  = doStaircase(display, stairParams, stimParams, stairParams.trialGenFuncName, [], logFID, 'precomputeFirstTrial');
        newDataSum(1).stairParams   = stairParams;
        newDataSum(1).stimParams    = stimParams;
        startInd                    = (stairParams.nStairs*(lap-1))+(((n-1)*stairParams.measuredEcc)+1);
        dataSum(startInd:(startInd+(stairParams.measuredEcc-1))) = newDataSum;
        if newDataSum(1).abort, break; end
    end
    if newDataSum(1).abort, break; end
end

delete('tctemp.mat'); % get rid of temp file created by trial counter
ewSaveData(subj.dataSumName, dataSum, newDataSum(1).abort);

fclose(logFID(1));
closeScreen(display);
for i=1:100, ShowCursor; end