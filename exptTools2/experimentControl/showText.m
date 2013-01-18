function [response, timing] = showText(display,stimulus,runPriority,showTiming)
% HAVEN'T YET GONE THROUGH AND THOROUGHLY COMMENTED THIS YET...
% RFB - 07/01/09

if nargin==0
	help(mfilename);
end

if ~exist('runPriority')
	runPriority = 0;  %use the nicest priority by default
end
if ~exist('showTiming')
	showTiming = 0;
end

% If you have a field called inputDevice, it will allow you to choose other
% input devices to record response
if isfield(stimulus,'inputDevice')
    custKbCheck = sprintf('KbCheck(%d);',stimulus.inputDevice);
else
    custKbCheck = 'KbCheck;';
end

HideCursor;
response.keyCode = [];
response.secs = [];
Screen('Preference', 'TextAntiAliasing', 0); %0 = Disable, 1 = Enable, 2 = EnableHighQuality]);
% Set text parameters
offWindow=Screen('OpenOffscreenWindow',display.windowPtr);
Screen('TextSize', display.windowPtr, stimulus.fontSize);
Screen('TextFont', display.windowPtr, stimulus.fontFace);
Screen('TextSize', offWindow, stimulus.fontSize);
Screen('TextFont', offWindow, stimulus.fontFace);

% Prepare for position computations
width = RectWidth(Screen('TextBounds', display.windowPtr, stimulus.curStr));

bounds = TextBounds(offWindow,'o');
height = bounds(4)-bounds(2);

if stimulus.angle==90
    heightCorrect = -pix2angle(display,(height/2)); %-((height/2)/display.pixHeight)*display.degHeight;
elseif stimulus.angle==270
    heightCorrect = pix2angle(display,(height/2));  %((height/2)/display.pixHeight)*display.degHeight;
end

% Calculate position parameter
stimLoc = computePosition(display,stimulus.centerLoc,stimulus.angle,(stimulus.distance+heightCorrect));


% Draw text in offscreen window
Screen('DrawText', display.windowPtr, stimulus.curStr, ... 
    stimLoc(3) - width/2, ... 
    stimLoc(4) + heightCorrect, stimulus.wordRGB, [], 1);

% For testing positions of presented words
%{
stimLoc2 = computePosition(display,stimulus.centerLoc,stimulus.angle,(stimulus.distance));
radius = abs((display.pixHeight/2)-stimLoc2(4));
circFrameX = (display.pixWidth/2)-radius;
circFrameXext = circFrameX+(radius*2);
circFrameY = (display.pixHeight/2)-radius;
circFrameYext = circFrameY+(radius*2);
Screen('DrawLine', display.windowPtr, [255 0 0], stimLoc(3)-100, stimLoc2(4), stimLoc(3)+100, stimLoc2(4), 2);
DrawFixation(display);
Screen('FrameOval', display.windowPtr, [255 0 0], [circFrameX circFrameY circFrameXext circFrameYext],1,1,1);
%}

% Set priority
Priority(runPriority);
% Begin timer for trial
s = GetSecs;
Screen('Flip', display.windowPtr);

% Leave stimulus up for designated amount of time
startTimer = getSecs;
while (getSecs-startTimer)<stimulus.trialDur/1000
    % Scan the keyboard
    [keyIsDown,secs,keyCode] = eval(custKbCheck);
    if(keyIsDown)
        response.keyCode = keyCode;
        response.secs = secs;
    end
end

timing = GetSecs-s;
DrawFixation(display);
Screen('Flip', display.windowPtr);

if showTiming
	disp(['Stimulus run time: ',num2str(timing),' seconds.']);
end
Priority(0);
Screen('Close',offWindow);