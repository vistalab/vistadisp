function ewDisplayInstructions(display,ind)

% If you have a field called inputDevice, it will allow you to choose other
% input devices to record response
device = getBestDevice(display);
keyList = ones(1,256);

fontFace = 'Courier New';

Screen('Preference', 'TextAntiAliasing', 0); %0 = Disable, 1 = Enable, 2 = EnableHighQuality]);
% Set text parameters
Screen('TextFont', display.windowPtr, fontFace);

stimulus.color = [0 0 0];
% TITLE

stimulus.text       = 'Lexical Decision Task';
stimulus.size       = 50;
stimulus.height     = .1;
ewDrawText(display,stimulus);

stimulus.text       = sprintf('Round %d of %d',ind(1),ind(2));
stimulus.size       = 30;
stimulus.height     = .15;
ewDrawText(display,stimulus);

stimulus.text       = 'INSTRUCTIONS';
stimulus.size       = 40;
stimulus.height     = .25;
ewDrawText(display,stimulus);

stimulus.text       = 'Remain fixated at the center of the screen.';
stimulus.size       = 30;
stimulus.height     = .30;
ewDrawText(display,stimulus);

stimulus.text       = 'Words and non-words will appear above, below, and at the fixation.';
stimulus.size       = 30;
stimulus.height     = .35;
ewDrawText(display,stimulus);

stimulus.text       = 'Decide whether it was a word or non-word.';
stimulus.size       = 30;
stimulus.height     = .40;
ewDrawText(display,stimulus);

stimulus.text       = 'RESPONSES';
stimulus.size       = 40;
stimulus.height     = .50;
ewDrawText(display,stimulus);

stimulus.text       = 'Press 1 on the button box for ''word,'' and 3 for ''non-word.''';
stimulus.size       = 30;
stimulus.height     = .55;
ewDrawText(display,stimulus);

stimulus.text       = 'If you have no idea, guessing is acceptable and encouraged.';
stimulus.size       = 30;
stimulus.height     = .60;
ewDrawText(display,stimulus);

stimulus.text       = 'Press any key to begin.';
stimulus.size       = 30;
stimulus.height     = .8;
stimulus.color      = [0 0 255];
ewDrawText(display,stimulus);

WaitSecs(1);
Screen('Flip',display.windowPtr);
% Wait for an indicated keypress

KbQueueRelease();
KbQueueCreate(device,keyList);
KbQueueStart();
KbQueueWaitCheck();

stimulus.size       = 50;
stimulus.height     = .51;
stimulus.color      = [255 0 0];

% Countdown Procedure
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
drawFixation(display);
Screen('Flip',display.windowPtr);
WaitSecs(1);