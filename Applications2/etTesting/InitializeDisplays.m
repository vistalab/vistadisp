function InitializeDisplays
% Display Initialization
% InitializeDisplays
%
% [SUMMARY]
% Opens the screen main window, as well as generates some screen
% measurements for stimulus placement to set as globals.
%
% [INPUT(S)]
% N/A
%
% [OUTPUT(S)]
% N/A
%
% [AUTHOR(S)]
% RFB 03/19/09
% CEW - General Structure (Ted Wright [cewright@uci.edu])

global w rect vec_center stimParams

%Screen Background Color        [3 column vector]
vec_bgColor =           [128 128 128];

screens=Screen('Screens');
screenNumber=max(screens);   
[w rect]=Screen('OpenWindow', screenNumber, vec_bgColor);
%%% %HORIZONTAL SCREEN SIZE
pix_horiz  =        rect(1,3); %PIXELS
%%% %VERTICAL SCREEN SIZE
pix_vert =          rect(1,4); %PIXELS
%%% %CENTER OF THE SCREEN COORDINATES
vec_center =        [pix_horiz/2; pix_vert/2];

[stimParams.xEye stimParams.yEye] = calibrate(w);
