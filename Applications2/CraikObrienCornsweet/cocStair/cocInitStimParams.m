function [stimParams] = cocInitStimParams(display)
% initialize stimulus parameters

% type of edge to measure
stimParams.testType = 'coc'; % {'coc', 'square', 'uniform', 'edgeonly'}

% type of test edge to compare against test
stimParams.matchType = 'uniform'; % {'coc', 'square', 'uniform', 'edgeonly'}

% initial value of testContrast (this will be reset during expt)
stimParams.testContrast = 0.1;

% initial val of matching edge (will be controlled by staircase)
stimParams.edgeAmplitdue = 0.1; %(% contrast)

% size of stimulus (can't be bigger than the display)
stimParams.radius = min(24, display.radius); %(deg)

% position of fixation cross
stimParams.fixationEcc = 3; %(deg)

% initial val for fixation side (-1, 0, 1 = L, Center, R)
stimParams.fixationSide = 1;

% degree to which edge curves (curvature is important for scan expt)
stimParams.curvatureAmp = 10; %(deg)

% initial val for sequence of square wave (1 = match/coc; 2 = coc/match)
stimParams.MatchFirstOrSecond = '1';

% number of refreshes to show each identical image
framesPerImage = 5;

% duration of a stimulus frame in seconds
stimParams.stimframe = framesPerImage / display.frameRate;

% duration of stimulus presentation
stimParams.duration = 1; % seconds

% temporal frequency of stimuli
stimParams.frequency  = 1; %Hz

% isi
stimParams.isi = 1; % seconds

return