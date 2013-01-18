function [check] = cmlRunTrialHARNESS

display = cmlInitDisplay;
InitializePsychSound;
% Open the default audio device [], with default mode [] (==Only playback),
% and a required latencyclass of zero 0 == no low-latency mode, as well as
% a frequency of freq and nrchannels sound channels.
% This returns a handle to the audio device:
display.audPtr = PsychPortAudio('Open', [], [], 0, 48000, 1);
PsychPortAudio('RunMode', display.audPtr, 1);

stimParams              = cmlInitParams;
disp(stimParams.visDur);
disp(display.flipInterval);

stimParams.visOnset     = round(stimParams.visOnset/display.flipInterval);
stimParams.visDur       = round(stimParams.visDur/display.flipInterval);
stimParams.audOnset     = round(stimParams.audOnset/display.flipInterval);
stimParams.audDur       = round(stimParams.audDur/display.flipInterval);

disp(stimParams.visDur);
disp(display.flipInterval);
% Need to change 
% ---->stimParams.shape
% To change the type of visual stimulus being presented
for i=1:10
    disp(stimParams.visDur*display.flipInterval);
    [resp, rt, flipStart, audStart] = cmlRunTrial(display,stimParams);
    check(i,1) = flipStart(3)-flipStart(2);
    check(i,2) = stimParams.visDur*display.flipInterval;
    check(i,3) = flipStart(2)-flipStart(1);
    check(i,4) = stimParams.visOnset*display.flipInterval;
    check(i,5) = audStart(1)-flipStart(1);
    check(i,6) = stimParams.audOnset*display.flipInterval;
end

% Close screen and audio port
PsychPortAudio('Close');
sca;

fprintf('resp %d rt %0.2d\n',resp,rt); % allows you to present output in a nice way
% sprintf allows one to present customized strings, %s represents a string,
% the variable afterwards is what it fills in