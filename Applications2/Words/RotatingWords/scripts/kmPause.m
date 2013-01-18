
function quitProg = kmPause(k,resumeKey,quitKey,Window)

Screen('FillRect',Window,0);
DrawFormattedText(Window, 'Experiment paused... Press R to resume (Q to quit)','center','center',255);
Screen('Flip',Window);
quitProg = 0;
while 1
    [keys RT] = recordKeys(GetSecs,1000,k,1);
    if strcmp(keys(1),resumeKey)
        break
    end
    if strcmp(keys(1),quitKey)
        quitProg = 1;
        break
    end
end
