function params = wkInitParams

% need to have current string flipping
params.wordRGB          = .9;
params.centerLoc        = [.5 .5];
params.distance         = 0;
params.angle            = 0;
params.duration         = .3;
params.devices          = getDevices;
params.device           = getBestDevice(params);
params.dataDir          = '/Users/Shared/PsychophysData/wordKnowledge';
params.wordList         = 'list712.mat';
params.repeatList       = 2;
params.xHeight          = 2;
assumedRefresh          = 75;
params.frameDuration    = 1/assumedRefresh;
params.ITI              = .5;
params.respKeys         = {'1' '3'};
params.respNames        = {'W' 'N'};
params.respCodes        = KbName(params.respKeys);
params.quitKey          = {'q'};
params.quitCode         = KbName(params.quitKey);