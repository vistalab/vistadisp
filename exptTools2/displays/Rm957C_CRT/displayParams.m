function params = displayParams

% Critical parameters
params.numPixels    = [1600 1200];   % Native resolution
params.dimensions   = [39 29];       % cm; Standard image area = 388 x 291mm
params.distance     = 45;            % cm; approximate distance from eyes to surface of monitor
params.frameRate    = 75;            % in Hz
params.cmapDepth    = 8;             % Bit depth; Check with Prof. Winawer!
params.screenNumber = 1;             % Mirrored or non-mirror; Check with Prof. Winawer!
  
% Descriptive parameters
params.position    = 'head rested on chin rest and eyes fixed on fixation cross '; 
params.stereoFlag  = 0; 
 
