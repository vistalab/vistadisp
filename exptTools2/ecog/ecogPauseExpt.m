
function [quitProg,pauseTime] = ecogPauseExpt(k,resumeKey,quitKey,windowPtr,backColor)

pauseStart = GetSecs;

if notDefined('backColor')
    backColor = 0;  % black
end

Screen('FillRect',windowPtr,backColor);
DrawFormattedText(windowPtr, 'Experiment paused... Press R to resume (Q to quit)','center','center',255);
Screen('Flip',windowPtr);
quitProg = 0;

while 1
    [RT,keys] = KbWait(k);
    if strcmp(KbName(keys),resumeKey) || strcmp(KbName(keys),quitKey)
        break
    end
end

if strcmp(KbName(keys),quitKey)
    quitProg = 1;
end

pauseTime = GetSecs-pauseStart;