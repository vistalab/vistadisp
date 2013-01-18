function precue = ewGeneratePrecue(display,stimParams)

offDisplay = display;
offDisplay.windowPtr = Screen('OpenOffscreenWindow',display.windowPtr);
offDisplay.fixType = 'disk';
offDisplay.fixSizePixels = angle2pix(display,.1);
Screen('FillRect',offDisplay.windowPtr,offDisplay.backColorRgb);
drawFixation(offDisplay);

precue.textures     = offDisplay.windowPtr;
precue.seq          = [1 2 3 4 0];
precue.srcRect      = [offDisplay.numPixels(1)/2-20 offDisplay.numPixels(2)/2-20 offDisplay.numPixels(1)/2+20 offDisplay.numPixels(2)/2+20];
precue.cmap         = [];
center              = computePosition(display,stimParams.centerLoc,stimParams.angle,(stimParams.distance));
topLeft             = [center(3)-20 center(4)-20];
precue.destRect     = round([topLeft topLeft+40]);
