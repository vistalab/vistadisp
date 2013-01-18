function display = fovInitDisplay
% display = fovInitDisplay
%   initialize the monitor display settings for fov staircase expt

% try
%     display = loadDisplayParams('NEC485.mat');
%     
% catch me
%     warning(me.identifier, me.message);
%     
%     try
%         %JW's office
%         display = loadDisplayParams('BenQ.mat');
%         
%     catch me
%         warning(me.identifier, me.message);
%         %default values
%         display = loadDisplayParams;
%         
%     end
%     
% end

display = selectDisplay;
display = loadDisplayParams(display);

%set the display to the biggest square that fits on the monitor
display.radius = pix2angle(display,floor(min(display.numPixels)/2));
