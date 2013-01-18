function display = GaborInitFixParams(display, stimParams)


display.fixType        = 'largecross';
display.fixSizePixels  = 15;


display.fixColorRgb    = [127 0 0 255;...
    127 0 0 255;...
    display.backColorRgb];
dim.x                  = display.numPixels(1);
dim.y                  = display.numPixels(2);
ecc                    = angle2pix(display, stimParams.fixationEcc);

%display.fixStim        = round([0 -1 1] * ecc + dim.x./2);

display.fixY           = round(dim.y./2 - ecc);
display.fixX           = round(dim.x./2);

switch display.fixType
    case {'large cross' , 'largecross'},
        display.fixColorRgb    = [255 255 0 255;...
            255 255 0 255];
        display.fixSizePixels  = 18;
        dim.x = display.numPixels(1);
        dim.y = display.numPixels(2);
        dim.ycoord = [1:dim.y dim.y:-1:1] ; % assume ydim is smallest
        dim.xcoord = [1:dim.y 1:dim.y] + round(-dim.y/2+dim.x/2);
        display.fixCoords = [dim.xcoord;dim.ycoord];
        
    case {'disk'},
        display.fixSizePixels  = 15;
                
        display.fixColorRgb    = [127 0 0 255;...
            127 0 0 255;...
            display.backColorRgb];
        dim.x                  = display.numPixels(1);
        dim.y                  = display.numPixels(2);
        ecc                    = angle2pix(display, stimParams.fixationEcc);
               
        display.fixY           = round(dim.y./2 - ecc);
        display.fixX           = round(dim.x./2);
        
    case {'double large cross' , 'doublelargecross'},
        display.fixColorRgb    = [255 255 0 255;...
            255 255 0 255];
        display.fixSizePixels{1}= 12;
        dim.x = display.numPixels(1);
        dim.y = display.numPixels(2);
        dim.ycoord = [1:dim.y dim.y:-1:1] ; % assume ydim is smallest
        dim.xcoord = [1:dim.y 1:dim.y] + round(-dim.y/2+dim.x/2);
        display.fixCoords{1} = [dim.xcoord;dim.ycoord];
        
end