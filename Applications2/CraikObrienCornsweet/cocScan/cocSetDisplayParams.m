function [params] = cocSetDisplayParams(params)

% Get the screen calibration
try
    params.display = loadDisplayParams('displayName',params.calibration);
    fprintf('[%s]:loading calibration from: %s.\n',mfilename,params.calibration);
catch ME
    warning(ME.identifier, ME.message);
    params.display = cocSetDefaultDisplayParams;
end;

%Check the screen number
if max(Screen('screens')) < params.display.screenNumber,
    fprintf('[%s]:resetting screenNumber %d -> %d.\n',mfilename,...
        params.display.screenNumber,max(Screen('screens')));
    
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
fprintf('[%s]: Stimulus size: %.1f degrees / %d pixels.\n',...
    mfilename,radius,angle2pix(params.display,2*radius));

params.display.stereoFlag = 0;
params.display.quitProgKey = params.quitProgKey;
params.dispString = [params.type '.  Please watch the fixation square.'];

return
