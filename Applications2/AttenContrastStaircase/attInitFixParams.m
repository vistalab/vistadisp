function display = attInitFixParams(display, stimParams)
%Set the fixation parameters for meg attention experiment
%
%  display = attInitFixParams(display)

display.fixType        = 'largecross';
display.fixSizePixels  = [2 2];

display.fixColorRgb    = [127 0 0 255;... % red
                          0 0 0 0; ...    % white
                          0 127 0 255;...
                        ];

% Center the fixation in the middle of the screen
display.fixX           = round(display.numPixels(1)/2);
display.fixY           = round(display.numPixels(2)/2);

% Define fixation center
% display.fixCenter = [display.fixX display.fixY];

% Define number of points you want to draw for the vertical/horizontal
% lines
nr_points = -15:1:15;

% Define white stick for attention manipulation
if stimParams.LeftOrRight == 1; % 1 = left, 
   
    white_stick = -15:1:-1;
                              
elseif stimParams.LeftOrRight == 2; % 2 = right
    white_stick = 1:1:15;
                          
end


% For now, predefine location
give_left = true;

if give_left
    white_stick = -15:1:-2;
end

% Define [X;Y] coordinates 
display.fixCoords      = {[  display.fixX*ones(31,1)' display.fixX+nr_points; 
                              display.fixY+nr_points display.fixY*ones(31,1)']
                              
                          [  display.fixX+white_stick; display.fixY*ones(14,1)' ]  
                              
                              }; 

