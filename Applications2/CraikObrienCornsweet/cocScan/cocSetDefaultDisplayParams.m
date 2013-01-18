function [display] = cocSetDefaultDisplayParams

display.screenNumber   = max(Screen('screens'));
[width, height]=Screen('WindowSize',display.screenNumber);
display.numPixels  = [width height];
display.dimensions = [40 30];
display.pixelSize  = min(display.dimensions./display.numPixels);
display.distance   = 40;
display.frameRate  = 75;
display.cmapDepth  =  8;
display.gammaTable = [0:255]'./255*[1 1 1];
display.gamma      = display.gammaTable;
display.backColorRgb   = [128 128 128 255];
display.textColorRgb   = [255 255 255 255];
display.backColorRgb   = 128;
display.backColorIndex = 128;
display.maxRgbValue    = 255;
display.stimRgbRange   = [0 255];
display.bitsPerPixel   = 32;
disp(sprintf('[%s]:no calibration.',mfilename));    

return