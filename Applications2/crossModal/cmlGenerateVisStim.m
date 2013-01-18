function cmlGenerateVisStim(display,stimParams)
% 2 Inputs, display, stimParams
% 
switch stimParams.shape
    case 'circle'
        stimLoc = computePosition(display,[.5 .5],stimParams.angle,stimParams.distance);
        pixWidth = angle2pix(display,stimParams.width);
        pixHeight = angle2pix(display,stimParams.width);
        xPos = stimLoc(3)-(pixWidth/2);
        yPos = stimLoc(4)-(pixHeight/2);
        rect = round([xPos yPos xPos+pixWidth yPos+pixWidth]);
        Screen('FillOval', display.windowPtr, stimParams.color, rect);
    case 'triangle'
        %Screen('FillPoly', windowPtr [,color], pointList);
    case 'rectangle'
        %Screen('FillRect', windowPtr [,color] [,rect] );
    case 'line'
        %Screen('DrawLine', windowPtr [,color], fromH, fromV, toH, toV
        %[,penWidth]);
end