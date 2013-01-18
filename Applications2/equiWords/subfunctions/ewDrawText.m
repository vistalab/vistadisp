function ewDrawText(display,stimulus)

Screen('TextSize', display.windowPtr, stimulus.size);
width = RectWidth(Screen('TextBounds', display.windowPtr, stimulus.text));
Screen('DrawText', display.windowPtr, stimulus.text, ... 
    display.numPixels(1)/2 - width/2, ... 
    display.numPixels(2)*stimulus.height, stimulus.color, [], 1);
