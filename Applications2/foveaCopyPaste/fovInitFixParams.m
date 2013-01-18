function display = fovInitFixParams(display)


display.fixType        = 'dot';
display.fixSizePixels  = 1;

% a red fixation dot?
display.fixColorRgb    = [127 0 0 255; 0 127 0 255];

dim.x                  = display.numPixels(1);
dim.y                  = display.numPixels(2);

display.fixY           = round(dim.y./2);
display.fixX           = round(dim.x./2);
