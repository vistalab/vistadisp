function [display] = initDisplay(display_name)
% function [display] = attInitDisplay(display_name)
%   initialize the monitor display settings for attention meg staircase expt

if ~exist('display_name', 'var') || isempty(display_name)
    display_name = selectDisplay;
end
       
display = loadDisplayParams(display_name);

% check that the specified screennumber exists. 
if max(Screen('screens')) < display.screenNumber,
    fprintf('[%s]:resetting screenNumber %d -> %d.\n',mfilename,...
        display.screenNumber,max(Screen('screens')));
    display.screenNumber   = max(Screen('screens'));
end;
    
    
%set the display to the biggest square that fits on the monitor
display.radius = pix2angle(display,floor(min(display.numPixels)/2));
