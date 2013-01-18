function  params = retSetDerivedParams(params)
% params = retSetDerivedParams(params)
%
% April, 2010, JW: Split off from setRetinotopyParameters

% ************************
% Stimulus appearance
% ************************
params.ringWidth        = params.ringDeg;

% Polar angle of wedge in radians
params.wedgeWidth       = params.wedgeDeg * (pi/180);

% Number of rings in each wedge
%params.numSubRings = (params.radius-params.innerRad)/(2*params.subRingDeg);
%params.numSubRings = (params.radius-params.innerRad)/(params.radius);
%params.numSubRings = (params.radius)/(2*params.subRingDeg);

% Number of wedges in each ring
params.numSubWedges     = params.wedgeDeg/(2*params.subWedgeDeg);

% ************************
% Timing
% ************************
% Duration of each image (seconds) 
params.imageDuration    = params.period / params.numImages; 

% Duration of whole scan, including prescan
params.scanDuration     = params.period * params.numCycles + params.prescanDuration;

% ***HACK!  We'll let makeRetinotopy add the prescan stuff
params.ncycles          = params.numCycles;
params.prescanDuration  = params.prescanDuration;  % why do we have this line?
params.period           = params.period;           % why do we have this line?


% ************************
% Fixation dimensions
% ************************
params.fix.task               = 'Detect fixation change';
params.fix.colorRgb           = params.display.fixColorRgb;
params.fix.responseTime       = [.01 3]; % seconds
% Flickering fixation point parameters
%
%   This controls the duration of the fix flicks, in frames.
%   Set it to 0 to turn get no flicks.
params.fixFlickFrames = 5;
%   This controls the density of the flicks, per frame.
%   Thus, .01 will, on average, flick once every 100 frames.
params.fixFlickFreq = .01;




return