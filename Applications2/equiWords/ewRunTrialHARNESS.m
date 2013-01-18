function ewRunTrialHARNESS
[stimParams, stairParams]       = ewInitParams;
[display]                       = ewInitDisplay;
[stimParams.dataDir]            = ewInitDataDir;
stimParams.stimFileCache        = fullfile(stimParams.dataDir,'stimCache.mat'); % Word images / lists for trial use
[cache,stimParams.stimFileCache] = ewCheckFile(stimParams.stimFileCache, 'Word Images', 1);
data = cache.data;
data.curWStr = 1;
data.curNStr = 1;
stimParams.wordRGB      = .9;
stimParams.width        = .5;
stimParams.angle        = 90; % degrees
stimParams.distance     = 0;  % degrees of visual angle
stimParams.duration     = 10; % seconds
curStrImg = data.wStrImg{100};

stim                = ewGenerateStim(display,stimParams,curStrImg);
precue              = ewGeneratePrecue(display,stimParams);
trial               = addTrialEvent(display,[],'stimulusEvent', 'stimulus', precue);
trial               = addTrialEvent(display,trial,'stimulusEvent', 'stimulus', stim);
WaitSecs(1.0);
doTrial(display,trial);

closeScreen(display);
ShowCursor;