function [xEye,yEye,xform] = calibrate(stimParams,w)

% [CALIBRATE]
% [xEye,yEye,xform] = calibrate(testMode,w)
%
% [SUMMARY]
% Presents a series of crosshairs for participants to fixate on, followed
% by the presentation of all nine in addition to one representing the
% participant's predicted gaze location.  The procedure can either be
% repeated, or the calibration accepted and values output.
%
% [INPUT(S)]
% w
% Window
%
% [OUTPUT(S)]
% xform
%
% xEye
% Eye positions at each of the screen coordinates.  xEye(5) represents the
% participant's gaze location while looking at the center of the screen.
%
% yEye
% Eye positions at each of the screen coordinates.  yEye(5) represents the
% participant's gaze location while looking at the center of the screen.
%
% [AUTHOR(S)]
% rfb 04/02/09

if(~exist('w','var') || isempty(w))
    w = Screen('OpenWindow',1);
end
if(~exist('stimParams','var'))
    stimParams = [];
end
rect = Screen('Rect',w);
width = rect(3);
height = rect(4);

xInc = width/4;
yInc = height/4;

xScreen = [xInc xInc*2 xInc*3 xInc xInc*2 xInc*3 xInc xInc*2 xInc*3];
yScreen = [yInc yInc yInc yInc*2 yInc*2 yInc*2 yInc*3 yInc*3 yInc*3];
% Adding in some prespecified values for this to test it out

bgColor = [128 128 128];
Screen('FillRect', w, bgColor);
xEye = [];
yEye = [];
%Cross Leg Length
cL = 10;
%Cross Leg Line Width
cLw = 2;
%Cross Leg Color
cLcPrep = [255 255 255];
cLcReady = [255 255 0];
textColor = [255 255 255];
calibrate = 1;

if(~isfield(stimParams,'xform'))
    computeXForm = 1;
else
    computeXForm = 0;
    xEye = stimParams.xEye;
    yEye = stimParams.yEye;
    xform = stimParams.xform;
end

% Loop to present crosses one at a time
while calibrate
    checkCalib = 1;
    if(computeXForm)
        WaitSecs(1.5);
        pressKey = sprintf('Press any key to begin calibration.');
        makeText(w,pressKey,50,50,1,20,textColor);
        Screen('Flip',w);
        while ~KbCheck(4)
        end
        for calibLoc = 1:9 % Loop to go through each of the 9 crosses
                Screen('FillRect', w, bgColor);
                Screen('Flip',w);
                WaitSecs(1); % Time to rest eyes before next
                % Draw horizontal and vertical cross legs
                Screen('DrawLine', w, cLcPrep, xScreen(calibLoc) - cL, yScreen(calibLoc), xScreen(calibLoc) + cL, yScreen(calibLoc), cLw);
                Screen('DrawLine', w, cLcPrep, xScreen(calibLoc), yScreen(calibLoc) - cL, xScreen(calibLoc), yScreen(calibLoc) + cL + (cLw/2), cLw);
                Screen('Flip',w);
                % Wait 1 s to give them time to orient to the new cross
                % before checking tracker, and build up values
                WaitSecs(1); 
                % Draw the cross in a new color when it begins to take
                % measurements
                Screen('DrawLine', w, cLcReady, xScreen(calibLoc) - cL, yScreen(calibLoc), xScreen(calibLoc) + cL, yScreen(calibLoc), cLw);
                Screen('DrawLine', w, cLcReady, xScreen(calibLoc), yScreen(calibLoc) - cL, xScreen(calibLoc), yScreen(calibLoc) + cL + (cLw/2), cLw);
                Screen('Flip',w);
                WaitSecs(3);
                [status, pupil, horiz, vert, time] = getEyePos();
                horiz = median(horiz(31:60));
                vert = median(vert(31:60));
                % Take the mean of the five values and store it for that point
                xEye(calibLoc) = horiz;
                yEye(calibLoc) = vert;
        end
        %% Regress x and y locations for eyes and screen
        % [residual,residualMeanSq,b,a] = calibRegress(xEye,yEye,xScreen,yScreen);
        % Compute the affine transform that converts eye coords to screen
        % coords (pre-multiply convention with homogeneous coordinates). 
        % E.g., predictedScreenCoord = xform*[eyeCoord 1]';
        xform = [xScreen; yScreen; ones(1,9)]/[xEye; yEye; ones(1,9)];
    end
    % Loop to verify successful calibration
    while checkCalib
        % Draw all nine crosses
        for calibLoc = 1:9
            % Horizontal and vertical cross legs
            Screen('DrawLine', w, cLcPrep, xScreen(calibLoc) - cL, yScreen(calibLoc), xScreen(calibLoc) + cL, yScreen(calibLoc), cLw);
            Screen('DrawLine', w, cLcPrep, xScreen(calibLoc), yScreen(calibLoc) - cL, xScreen(calibLoc), yScreen(calibLoc) + cL + (cLw/2), cLw);
        end
        % Measure eye position and plot it to verify where subject is
        % looking
        [status, pupil, horiz, vert] = getEyePos();
        screenCoords = xform * [horiz(60) vert(60) 1]';
        x = screenCoords(1);
        y = screenCoords(2); 
        Screen('DrawLine', w, cLcReady, x - cL, y, x + cL, y, cLw);
        Screen('DrawLine', w, cLcReady, x, y - cL, x, y + cL + (cLw/2), cLw);
        Screen('Flip',w);

        % Press a key to either redo calibration or continue
        [keyIsDown, time1, keyCode] = KbCheck(3);
        resp = find(keyCode);
        if resp == KbName('uparrow');
            checkCalib=0;
            calibrate=0;
        elseif resp == KbName('downarrow');
            checkCalib=0;
            computeXForm=1;
        end
    end
end