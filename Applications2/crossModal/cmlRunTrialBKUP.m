function [resp, rt, flipStart, audStart] = cmlRunTrial(display,stimParams)

% Initialize variables
resp = [];
rt = [];
audFlag = [];
visFlag = [];
stimInitFlag = [];
stimInitTime = [];

% Get USB keypad if one is plugged in
device = getBestDevice(display);

% Compute beginning of trial
trialInitTime = GetSecs;

% Last stimulus to come on
maxOnset = max([stimParams.visOnset stimParams.audOnset])/1000;

% Buffer time to ensure timely presentation of visual stimuli
prepTime = display.flipInterval/2;

% Compute longest amount of time the trial will be lasting, so we can break
% after that
maxStimDur = max([stimParams.visOnset+stimParams.visDur stimParams.audOnset+stimParams.audDur]);
maxStimDur = maxStimDur*display.flipInterval;
% Prepare auditory stimulus
sound = cmlGenerateAudStim(display, stimParams);
PsychPortAudio('FillBuffer', display.audPtr, sound);

% Initialize keyboard cache
KeyList = zeros(1,256);
KeyList(stimParams.respKey) = 1;
KbQueueRelease;
KbQueueCreate(device, KeyList);
KbQueueStart;

% FLIP BLANK SCREEN TO BEGIN TIMER FOR FLIPS (REFRESH RATE TIMER BASELINE)
[flipStart(1)] = Screen('Flip',display.windowPtr);%,trialInitTime+.03);

% GENERATE VISUAL STIMULUS
cmlGenerateVisStim(display,stimParams);

% Main stimulus generation loop
while 1
    % Visual Stimulus Onset
    if isempty(visFlag) && (GetSecs-flipStart(1)+prepTime)>=(stimParams.visOnset*display.flipInterval)
        [flipStart(2)] = Screen('Flip',display.windowPtr,(flipStart(1)+(stimParams.visOnset*display.flipInterval-prepTime)));
        visFlag = 1;
    end
    % Visual Stimulus Offset
    if visFlag & size(flipStart,2)<3
        if (GetSecs-flipStart(2)+prepTime)>=(stimParams.visDur*display.flipInterval)
            [flipStart(3)] = Screen('Flip',display.windowPtr,(flipStart(2)+(stimParams.visDur*display.flipInterval-prepTime)));
        end
    end

    if (GetSecs-trialInitTime)>=maxOnset && isempty(stimInitFlag)
        stimInitTime = GetSecs;
        stimInitFlag = 1;
    end
    
    % Auditory Stimulus Onset
    if isempty(audFlag) && (GetSecs-flipStart(1)+prepTime)>=(stimParams.audOnset*display.flipInterval)
        % Create the sound using sound parameters
        audStart(1) = PsychPortAudio('Start', display.audPtr, 1, flipStart(1)+(stimParams.audOnset*display.flipInterval), 1); %, flipStart(1)+((stimParams.audOnset+stimParams.audDur)*display.flipInterval));
        audFlag = 1;
    end
    
    % Auditory Stimulus Offset
%     if audFlag==1 & size(audStart,2)<2
%         if (GetSecs-audStart(1)+prepTime)>=(stimParams.audDur*display.flipInterval)
%             [audStart(2) audStart(3) audStart(4) audStart(5)] = PsychPortAudio('Stop', display.audPtr, 3, 0, 0, flipStart(1)+((stimParams.audOnset+stimParams.audDur)*display.flipInterval));
%         end
%     end
    
    if GetSecs>(trialInitTime+maxStimDur+1)
        break;
    end
end 

% Get and process key presses
[pressed firstPress] = KbQueueWaitCheck;
KbQueueStop;

presses=firstPress~=0;
secs=min(firstPress(presses));
resp=find(firstPress==secs);
resp=KbName(resp);
rt=secs-stimInitTime;
