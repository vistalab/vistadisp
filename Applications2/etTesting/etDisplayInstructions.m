function etDisplayInstructions(display,cond)

device = getBestDevice(display);
keyList = ones(1,256);
fontFace = 'Courier New';
Screen('Preference', 'TextAntiAliasing', 1); %0 = Disable, 1 = Enable, 2 = EnableHighQuality]);
Screen('TextFont', display.windowPtr, fontFace);

stimulus.color = [0 0 0];

stimulus.text       = 'Eye Tracking';
stimulus.size       = 50;
stimulus.height     = .1;
ewDrawText(display,stimulus);

stimulus.text       = 'INSTRUCTIONS';
stimulus.size       = 40;
stimulus.height     = .25;
ewDrawText(display,stimulus);

if cond==1
    stimulus.text       = 'Remain fixated.';
    stimulus.size       = 30;
    stimulus.height     = .30;
    ewDrawText(display,stimulus);
elseif cond==2
    stimulus.text       = 'Remain fixated.  Attempt to look at stimuli that appear.';
    stimulus.size       = 30;
    stimulus.height     = .30;
    ewDrawText(display,stimulus);
end

stimulus.text       = 'Large red dots will appear not only at, but around the fixation.';
stimulus.size       = 30;
stimulus.height     = .35;
ewDrawText(display,stimulus);

stimulus.text       = 'Press any key to acknowledge you perceived the stimulus.';
stimulus.size       = 30;
stimulus.height     = .40;
ewDrawText(display,stimulus);

stimulus.text       = 'Press any key to begin.';
stimulus.size       = 30;
stimulus.height     = .8;
stimulus.color      = [0 0 255];
ewDrawText(display,stimulus);

WaitSecs(1);
Screen('Flip',display.windowPtr);

KbQueueCreate(device,keyList);
KbQueueStart();
KbQueueWaitCheck();

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