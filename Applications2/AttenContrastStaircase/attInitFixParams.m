function display = attInitFixParams(display)
%Set the fixation parameters for meg attention experiment
%
%  display = attInitFixParams(display)

display.fixType        = 'largecross';
display.fixSizePixels  = 2;

display.fixColorRgb    = [0     0    0    255; ... % black 
                          255   255  255  255; ... % white 
                        ];

% Center the fixation in the middle of the screen
display.fixX           = round(display.numPixels(1)/2);
display.fixY           = round(display.numPixels(2)/2);

% Define fixation center
% display.fixCenter = [display.fixX display.fixY];

% Define number of points you want to draw for the vertical/horizontal
% lines
fix_radius = 15;
nr_points = -fix_radius:1:fix_radius;

% Define stick for attention manipulation
stick.left  = -fix_radius:1:-3;
stick.right =   3:1:fix_radius;
                          

% Define [X;Y] coordinates 
%   Cross
display.fixCoords{1} = [  display.fixX*ones(2*fix_radius+1,1)' display.fixX+nr_points; 
                              display.fixY+nr_points display.fixY*ones(2*fix_radius+1,1)'];                          
%   Stick on the left
display.fixCoords{2} = [  display.fixX+stick.left; display.fixY*ones(fix_radius-2,1)' ] ; 
                          
%   Stick on the right                          
display.fixCoords{3} = [  display.fixX+stick.right; display.fixY*ones(fix_radius-2,1)' ] ; 
                              


