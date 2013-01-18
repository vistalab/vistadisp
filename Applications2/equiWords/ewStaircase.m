function ewStaircase

sca;

[stimParams, stairParams]       = ewInitParams;
[stimParams.dataDir]            = ewInitDataDir;
[stairParams.etFlag]            = ewETCheck;
[subj]                          = ewGetSubjParams(stimParams.dataDir); if subj.num==0, return; end
[display]                       = ewInitDisplay;

if stairParams.etFlag
    stairParams.et.xform = [];
end

% Set names of files to be used during staircase
stimParams.letterImages         = fullfile(stimParams.dataDir,'trunk','letters.mat'); % Letter images
stimParams.listFile             = fullfile(stimParams.dataDir,'trunk',stairParmams.stimList); % Word lists for stim generation
stimParams.indHistory           = fullfile(stimParams.dataDir,sprintf('S%02dhistory.mat',subj.num)); % Words already run

for lap=1:stairParams.laps
    if stairParams.etFlag
        [stairParams.et, display] = calibrate(display, stairParams.et.xform);
    end
    stairParams.initTrialCount  = lap==1;
    stairParams.ind             = lap;
    [logFID]                    = ewInitLogFID(stimParams,stairParams,subj);
    newDataSum                  = doStaircase(display, stairParams, stimParams, stairParams.trialGenFuncName, [], logFID, 'precomputeFirstTrial');
    newDataSum(1).stairParams   = stairParams;
    newDataSum(1).stimParams    = stimParams;
    startInd                    = (stairParams.nStairs*(lap-1))+1;
    endInd                      = startInd + (stairParams.nStairs-1);
    dataSum(startInd:endInd)    = newDataSum;
    if newDataSum(1).abort, break; end
end

tcName = fullfile(stimParams.dataDir,'tctemp.mat');
if exist(tcName,'file')
    delete(tcName); % get rid of temp file created by trial counter
end
ewSaveData(subj.dataSumName, dataSum, newDataSum(1).abort);

fclose(logFID(1));
closeScreen(display);
for i=1:100, ShowCursor; end