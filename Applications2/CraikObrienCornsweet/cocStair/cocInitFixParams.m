function display = cocInitFixParams(display, stimParams);


display.fixType        = 'dot';
display.fixSizePixels  = 1;

% for isoluminant fixation
display.fixColorRgb    = [ 253 137 124 255;...
                           253 137 124 255;...
                           1  117 130 255;...
                          display.backColorRgb];

%display.fixColorRgb    = [127 0 0 255;...
%                           127 0 0 255;...
%                           display.backColorRgb];
dim.x                  = display.numPixels(1);
dim.y                  = display.numPixels(2);
ecc                    = angle2pix(display, stimParams.fixationEcc);

display.fixStim        = round([0 -1 1] * ecc + dim.x./2);
display.fixY           = round(dim.y./2);
display.fixX           = round(dim.x./2);
