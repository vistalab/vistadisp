function [data] = etRunTrial(display,params)

device = getBestDevice(display);
WaitSecs(.25);
stimLoc = computePosition(display,[.5 .5],params.angle,params.distance);
% Draw dot
Screen('FillRect', display.windowPtr, [128 128 128], display.rect); % Fill background in with designated color
Screen('gluDisk', display.windowPtr, [255 0 0], display.numPixels(1)/2, display.numPixels(2)/2, 3);
Screen('gluDisk', display.windowPtr, [255 0 0], stimLoc(3), stimLoc(4), 10);
Screen('Flip',display.windowPtr);
WaitSecs(params.duration/1000);
% Blank screen
Screen('FillRect', display.windowPtr, [128 128 128], display.rect); % Fill background in with designated color
Screen('gluDisk', display.windowPtr, [255 0 0], display.numPixels(1)/2, display.numPixels(2)/2, 3);
Screen('Flip',display.windowPtr);

% Check eyes
timeCutoff = params.duration/1000; % seconds
distCriterion = sqrt((params.xEye(5)-params.xEye(6))^2+(params.yEye(5)-params.yEye(6))^2);
[status, pupil, horiz, vert, time] = getEyePos();
presentTime = time(60);
timeStart = presentTime-(timeCutoff*1000); % convert cutoff to ms, subtract
keepTimes = find(time>=timeStart);
horiz = horiz(keepTimes); vert = vert(keepTimes); time = time(keepTimes); pupil = pupil(keepTimes);
count = 0;
for i = 1:length(keepTimes)
     fixDist(i) = sqrt((params.xEye(5)-horiz(i))^2+(params.yEye(5)-vert(i))^2);
     if fixDist(i)>distCriterion
         count = count + 1;
     else
         count = 0;
     end
     fixFail(i) = count;
end
data.eyeMovs = max(fixFail);
data.horiz = horiz;
data.vert = vert;

% Record response
respCheck=1;
while respCheck
    [keyIsDown, time2, keyCode] = kbCheck(device); % Check external USB device
    if keyIsDown
        respCheck = 0;
    end 
end

data.resp = keyCode;
data.resp = find(data.resp==1);