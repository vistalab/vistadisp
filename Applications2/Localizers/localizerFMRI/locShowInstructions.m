function locShowInstructions(Window)
% Shows instructions to subject before start of scan

% We should allow the user to set this
str = 'Please press button when fixation dot changes color.';

% Set fonts
Screen('TextFont',Window,'Times');
Screen('TextSize',Window,25);
Screen('FillRect', Window, 0);  % 0 = black background

DrawFormattedText(Window, str,'center','center',255);
Screen('Flip',Window);

%pause;
pause(4)
return
