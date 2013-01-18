function ShowMessage(msg, screenNum, speak);
% Show a simple text message to the user, prompting them to press the
% button to continue.
%
%    ShowMessage(msg, [screenNum=max( Screen('Screens') )], [speak=1]);
%
% This code was created for the purpose of prompting a subject in the
% middle of a series of runs as to whether there are more runs to perform,
% or whether the subject is finished with the experiment. It is designed to
% open a screen, display a message, wait for a user input, then proceed.
%
% It is not optimal; it would be better to have the screen up until the
% next experiment loads. But because my experiments are coded as
% self-contained runs, this is tricky. Trying to open multiple windows
% without closing them can cause memory problems, so I avoid that by having
% the user press a key and closing the screen.
%
% ras, 07/30/2009.
if notDefined('speak'),    speak = 1;           end
if notDefined('screenNum')
    % max available screen -- if there's an external screen, use that;
    % otherwise use the default one (0):
    screenNum = max( Screen('Screens') );
end

display = loadDisplayParams(prefsDisplayName);
display = openScreen(display);
% pressKey2Begin(display, 0, speak, msg);

Screen('FillRect', display.windowPtr, 0);
% drawFixation(display);
if ~iscell(msg)
    msg = {msg};
end

% draw the message
% allow multi-line input: present each line separately
nLines = length(msg);
vRange = min(.7, .06 * nLines/2);  % vertical axis range of message
vLoc = 0.4 + linspace(-vRange, vRange, nLines); % vertical location of each line
textSize = 40;
oldTextSize = Screen('TextSize', display.windowPtr, textSize);
charWidth = textSize/4.5; % character width
for n = 1:nLines
    loc(1) = display.rect(3)/2 - charWidth*length(msg{n});
    loc(2) = display.rect(4) * vLoc(n);
    Screen('DrawText', display.windowPtr, msg{n}, loc(1), loc(2), 255);
end
% drawFixation(display);
Screen('Flip',display.windowPtr);
Screen('TextSize', display.windowPtr, oldTextSize);

if(speak)
    % this will only work on mac and is put here for cases where the screens
    % are mirrored and you may not see the 'go ahead' message.
    for ii = 1:length(msg)
        eval('system(sprintf(''say %s'',msg{ii}));',''); 
    end
end

% wait for user press
while ~KbCheck
    WaitSecs(0.01); 
end

% close the screen
closeScreen(display);

return
