function display = attInitFixParams(display)
%Set the fixation parameters for meg attention experiment
%
%  display = attInitFixParams(display)

display.fixType        = 'dot';
display.fixSizePixels  = 3;

display.fixColorRgb    = [127 0 0 255;...
                          0 127 0 255;...
                        ];

% Center the fixation in the middle of the screen
display.fixX           = round(display.numPixels(1)/2);
display.fixY           = round(display.numPixels(2)/2);
