function [Window, Rect] = initializeScreen

screenNumber = 1; % 0 = main display
                           
[Window, Rect] = Screen('OpenWindow',screenNumber); % open the window

% Set fonts
Screen('TextFont',Window,'Times');
Screen('TextSize',Window,24);
Screen('FillRect', Window, 128);  % 0 = black background

HideCursor; % Remember to type ShowCursor later

