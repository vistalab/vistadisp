function [resp, rt, flipStart, audStart] = cmlRunTrial(display,stimParams)

% Initialize variables
resp = [];
rt = [];
audStart = [];

% Get USB keypad if one is plugged in
device = getBestDevice(display);
prepTime = display.flipInterval/2;

% Prepare auditory stimulus
sound = cmlGenerateAudStim(display, stimParams);
PsychPortAudio('FillBuffer', display.audPtr, sound);

if stimParams.audOnset<stimParams.visOnset
    aud=1;
elseif (stimParams.audOnset>=stimParams.visOnset) && (stimParams.audOnset<(stimParams.visOnset + stimParams.visDur))
    aud=2;
elseif (stimParams.audOnset>=(stimParams.visOnset+stimParams.visDur))
    aud=3;
end

% Initialize keyboard cache
KeyList = zeros(1,256);
KeyList(stimParams.respKey) = 1;
KbQueueRelease;
KbQueueCreate(device, KeyList);
KbQueueStart;

% FLIP BLANK SCREEN TO BEGIN TIMER FOR FLIPS (REFRESH RATE TIMER BASELINE)
[flipStart(1)] = Screen('Flip',display.windowPtr);

% GENERATE VISUAL STIMULUS
cmlGenerateVisStim(display,stimParams);

% Audio Stimulus Onset (audio needs to start before visual starts)
if aud==1
        [audStart(1)] = PsychPortAudio('Start', display.audPtr, 1, flipStart(1)+(stimParams.audOnset*display.flipInterval), 1);
end

% Visual Stimulus Onset
[flipStart(2)] = Screen('Flip',display.windowPtr,(flipStart(1)+((stimParams.visOnset*display.flipInterval)-prepTime)));

% Audio Stimulus Onset (audio needs to start in sync with visual, or before offset of visual)
if aud==2
    [audStart(1)] = PsychPortAudio('Start', display.audPtr, 1, flipStart(1)+(stimParams.audOnset*display.flipInterval), 1);
end

% Visual Stimulus Offset
[flipStart(3)] = Screen('Flip',display.windowPtr,(flipStart(2)+((stimParams.visDur*display.flipInterval)-prepTime)));

% Audio Stimulus Onset (audio needs to start after or in sync with visual offset)
if aud==3
    [audStart(1)] = PsychPortAudio('Start', display.audPtr, 1, flipStart(1)+(stimParams.audOnset*display.flipInterval), 1);
end

% Get and process key presses
%{
[pressed firstPress] = KbQueueWaitCheck;
KbQueueStop;

presses=firstPress~=0;
secs=min(firstPress(presses));
resp=find(firstPress==secs);
resp=KbName(resp);
rt=secs-stimInitTime;
%}