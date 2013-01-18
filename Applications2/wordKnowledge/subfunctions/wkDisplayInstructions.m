function wkDisplayInstructions(params,display)

fontFace = 'Courier New';
Screen('Preference', 'TextAntiAliasing', 0); %0 = Disable, 1 = Enable, 2 = EnableHighQuality]);
Screen('TextFont', display.windowPtr, fontFace);

stimulus.color = [0 0 0];

stimulus.text       = 'Lexical Decision Task';
stimulus.size       = 50;
stimulus.height     = .1;
ewDrawText(display,stimulus);

stimulus.text       = 'INSTRUCTIONS';
stimulus.size       = 40;
stimulus.height     = .25;
ewDrawText(display,stimulus);

stimulus.text       = 'A word will appear at the center of the screen on each trial.';
stimulus.size       = 30;
stimulus.height     = .30;
ewDrawText(display,stimulus);

stimulus.text       = 'Decide if it was a real word, or a pseudoword.';
stimulus.height     = .35;
ewDrawText(display,stimulus);

stimulus.text       = 'Press ''1'' for word, and ''3'' for pseudoword.';
stimulus.height     = .40;
ewDrawText(display,stimulus);

stimulus.text       = 'Press any key to begin.';
stimulus.height     = .8;
stimulus.color      = [0 0 255];
ewDrawText(display,stimulus);

WaitSecs(1);
Screen('Flip',display.windowPtr);
scanKeyboard = [];
while isempty(scanKeyboard)
    [keyIsDown] = KbCheck(params.device);
    if(keyIsDown)
        scanKeyboard = 0;
    end
end

stimulus.size       = 50;
stimulus.height     = .51;
stimulus.color      = [255 0 0];

stimulus.text       = '3';
ewDrawText(display,stimulus);
Screen('Flip',display.windowPtr);
WaitSecs(1);
stimulus.text       = '2';
ewDrawText(display,stimulus);
Screen('Flip',display.windowPtr);
WaitSecs(1);
stimulus.text       = '1';
ewDrawText(display,stimulus);
Screen('Flip',display.windowPtr);
WaitSecs(1);
Screen('gluDisk', display.windowPtr, [255 0 0], display.numPixels(1)/2, display.numPixels(2)/2, 3);
Screen('Flip',display.windowPtr);
WaitSecs(1);