function display = cmlInitDisplay

display = loadDisplayParams('displayName', 'NEC485words.mat');%('builtin');%'tenbit');
display.devices = getDevices;
display = openScreen(display);

[display.flipInterval] = Screen('GetFlipInterval', display.windowPtr, 1000);
%rigParams.cmHeight =   17.78; % my laptop
%rigParams.cmWidth =    28.575; % my laptop
%rigParams.cmHeight =   30.48; % andreas' monitor
%rigParams.cmWidth =    40.64; % andreas' monitor
%display.cmHeight =      29.21; % my monitor
%display.cmWidth =       47.56; % my monitor
display.cmHeight        = 30.48;
display.cmWidth         = 40.64;
display.cmViewDist      = 76.2;
display.pixHeight       = display.rect(1,4); %PIXELS
display.pixWidth        = display.rect(1,3); %PIXELS
display.cm2deg          = (atan(.5/display.cmViewDist))*(180/pi)*2;
display.degHeight       = display.cm2deg*display.cmHeight;
display.degWidth        = display.cm2deg*display.cmWidth;
display.backgroundColor = round(ones(1,3)*.5*display.maxRgbValue);