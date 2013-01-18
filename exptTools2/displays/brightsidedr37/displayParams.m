function params = displayParams
%
% Critical parameters of the Brightside DR37 display in room 070
% This display has other parameters that we might code here as well, such
% as the number of LEDs and the correspondence between the LEDs and the
% LCDs, the number of gray levels for the LEDs, and so forth

params.numPixels    = [1920 1080];  
params.dimensions   = [82 46];  % (width and height) cm
params.distance     = 390;   % Units of cm
params.frameRate    = 60;
params.cmapDepth    = 8;
params.screenNumber = 0;
params.mmPerPix     = 0.4275;

% LED info
params.ledDim    = [45 31];
params.ledCenter = [23 16];

params.lcd2LedScale = params.ledDim ./ params.numPixels;

% Descriptive parameters
params.computerName = 'HDR PC';
params.monitor      = 'Brightside DR-37P';
params.card         = 'NVIDIA GeForce 7900GT';
params.position     = 'Packard 070';

return;
