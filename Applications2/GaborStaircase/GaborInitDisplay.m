function [display] = GaborInitDisplay
% function [display] = GaborInitDisplay
%   initialize the monitor display settings for Gabor staircase expt

%[displayName ok] = selectDisplay;


display = loadDisplayParams('gunjou.mat');

% Override the display setting? 
display.screenNumber = 0;

%set the display to the biggest square that fits on the monitor
display.radius = pix2angle(display,floor(min(display.numPixels)/2));
