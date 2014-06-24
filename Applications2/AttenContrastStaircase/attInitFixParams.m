function display = attInitFixParams(display, stimParams)
%Set the fixation parameters for meg attention experiment
%
%  display = attInitFixParams(display)

display.fixType        = 'largecross';
display.fixSizePixels  = 2;

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
fix_radius = 15;
nr_points = -fix_radius:1:fix_radius;

% Define white stick for attention manipulation
   
white_stick.left  = -fix_radius:1:-1;
white_stick.right =   1:1: fix_radius;
                          

% Define [X;Y] coordinates 
display.fixCoords{1,1} = [  display.fixX*ones(2*fix_radius+1,1)' display.fixX+nr_points; 
                              display.fixY+nr_points display.fixY*ones(2*fix_radius+1,1)'];
display.fixCoords{1,2} = [  display.fixX+white_stick.left; display.fixY*ones(fix_radius,1)' ] ;
                          
display.fixCoords{2,1} = [  display.fixX*ones(2*fix_radius+1,1)' display.fixX+nr_points; 
                              display.fixY+nr_points display.fixY*ones(2*fix_radius+1,1)'];
display.fixCoords{2,2} = [  display.fixX+white_stick.right; display.fixY*ones(fix_radius,1)' ] ;
                              
display.fixCoords{3,1} = display.fixCoords{1,1};
display.fixCoords{3,2} = display.fixCoords{1,1};
                          
                              


