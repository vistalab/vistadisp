function params = locSetDisplay(params)
% Load display calibration file and set various display-spefific settings
% for fMRI localizer experiment. 
% 
%
% params = locSetDisplay(params)
%
% JW, 1/2012

% Load the display from a file
params.scan.display = loadDisplayParams(params.scan.dispName);

% Fixation colors. This is ugly and gives the user no options. Maybe we
% should use the ret code for setting all fixation-related paramters?
params.scan.display.fixColorRgb = [ 255   0   0 255; ...
                                      0   0 255 255; ...
                                    255 255 255   0];


% Background color is assumed to be a gray scale value ([0 255]). Maybe we
% should allow for color quadruplets (RGB gamma)                                
bg = params.stim.blankColor;                                
params.scan.display.backColorRgb = [bg bg bg 255];

% Find the number of detectable screens. We will have an error if we try to
% use a screen number that PTB doesn't know about. This is NOT the correct
% way to handle this.  Better would be to read the screen number from the
% calibration file, and over-ride this only if the screen-number doesn't
% exist. In that case, we should outoput a warning to the user. As is, we
% simply assume that the highest number screen is always the desired one.
% This is in fact usually true, but perhaps there are exceptions. We should
% follow the example of the ret code on this.
screens=Screen('Screens'); 
% put this on the highest number screen
params.scan.display.screenNumber = max(screens); 

% (0 is the 1st screen)

% OK - devices are not really display parameters. There is probably some
% reason we attach devices to the display field. See ret code. It may have
% an explanation.
params.scan.display.devices = getDevices; 

% check for OpenGL
AssertOpenGL;

% Open the screen
params.scan.display = openScreen(params.scan.display);
retScreenReverse(params.scan, [], round(params.scan.display.numPixels/2));

return
