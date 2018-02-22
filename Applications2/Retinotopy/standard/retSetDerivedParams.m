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

% ************************
% Fixation dimensions
% ************************
params.fix.task               = 'Detect fixation change';
params.fix.colorRgb           = params.display.fixColorRgb;
params.fix.responseTime       = [.01 3]; % seconds

return