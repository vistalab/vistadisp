function [resp,rt] = wkRunTrial(params,display,whichStim)

curStrImg           = wordGenerateImage(display,params.letters,params.stimList{whichStim},'xHeight',params.xHeight);
stim                = ewGenerateStim(display,params,curStrImg);
trial               = addTrialEvent(display,[],'stimulusEvent', 'stimulus', stim);
startTrial          = GetSecs;
response            = doTrial(display, trial, priority, 1);
word                = params.lexicon(whichStim);

while (isempty(response.keyCode) || getSecs-startTrial<params.ITI)
    [keyDown,keySecs,keyCode] = KbCheck(params.device);
    if(keyDown)
        response.keyCode = keyCode;
        response.secs = keySecs;
        response = getKeyLabel(response);
    end
    if word
        if response.keyLabel==params.respKeys{1}
            resp = 1;
        elseif response.keyLabel==params.respKeys{2}
            resp = 0;
        elseif response.keyLabel==params.quitKey{1}
            resp = 3;
        else
            response.keyCode = [];
        end
    else
        if response.keyLabel==params.respKeys{2}
            resp = 1;
        elseif response.keyLabel==params.respKeys{1}
            resp = 0;
        elseif response.keyCode==params.quitKey{1}
            resp = 3;
        else
            response.keyCode = [];
        end  
    end
    WaitSecs(.01); % Free up processor time
end

rt = response.secs - startTrial;
WaitSecs(.3);