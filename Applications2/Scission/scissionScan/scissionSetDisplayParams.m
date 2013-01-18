function [params] = scissionSetDisplayParams(params)

% Get the screen calibration
try
    params.display = loadDisplayParams('displayName',params.calibration);
    disp(sprintf('[%s]:loading calibration from: %s.',mfilename,params.calibration));
catch
    params.display = scissionSetDefaultDisplayParams;
end;

%Check the screen number
if max(Screen('screens')) < params.display.screenNumber,
    disp(sprintf('[%s]:resetting screenNumber %d -> %d.',mfilename,...
        params.display.screenNumber,max(Screen('screens'))));
    params.display.screenNumber   = max(Screen('screens'));
end;

% Set the display size
if ischar(params.stimSize),
    params.display.radius = pix2angle(params.display,floor(min(params.display.numPixels)/2));
else
    params.display.radius = params.stimSize;			
end;

radius = params.display.radius;
params.display.destRect = [0 0 1 1].*angle2pix(params.display,radius)*2;
disp(sprintf('[%s]: Stimulus size: %.1f degrees / %d pixels.',...
    mfilename,radius,angle2pix(params.display,2*radius)));

params.display.stereoFlag = 0;
params.display.quitProgKey = params.quitProgKey;
params.dispString = [params.type '.  Please watch the fixation square.'];

return