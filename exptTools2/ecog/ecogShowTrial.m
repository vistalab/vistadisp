function [quitProg,timeStartTrial] = ecogShowTrial(stimulus, display, quitProgKey, quitProg)
%
%  This function will show a particular trial composed of a certain number
%  of frames (length(stimulus.seq)).  Stimulus.seq specifies the order in
%  which frames are played, while stimulus.seqtiming specifies the
%  timepoint at which that particular frame goes off.  Note that the function
%  collects key responses from only the internal (experimenter) and keyboards.  
%
%   For now, we just check for the quit key
%  (quitProgKey) on the internal keyboard.  Subject responses from the
%  external keyboard should be collected in a higher up function.  This is
%  for timing reasons having to do with using the post-trial RT to load up
%  a new stimulus.
%
%    [quitProg,timeStartTrial,pulseTime] = ecogShowTrial(stimulus, display, quitProgKey, TMSdelay, [doublePulseTime=0], [quitProg=0])
%
%  ported from showScanTrial (for fMRI) by amr Jan 5, 2010 and added ecog
%  event trigger (for photodiode)
%

%% Show the first frame as soon as possible

% put in an image
% imgNum = mod(stimulus.seq(1)-1,nImages)+1;
Screen('DrawTexture', display.windowPtr, stimulus.textures(1), stimulus.srcRect, stimulus.destRect);
ecogDrawFixation(display,stimulus.fixSeq(1));
Screen(display.windowPtr,'FillRect', 255, display.trigRect); %  ***** TRIGGER *******

% VBLstamps(1) will be a time stamp that the first frame was put on (acts as a reference)
VBLstamps(1) = Screen('Flip',display.windowPtr);
timeStartTrial = VBLstamps(1);
tic

if notDefined('quitProg')
    quitProg = 0; % don't quit unless this changes to 1
end

        
%% Then show the rest of the frames
for frame = 2:length(stimulus.seq)
    %toc
    
    %--- timing- we will wait for the previous frame's display time to end
    waitTime = (GetSecs-VBLstamps(1)) - stimulus.seqtiming(frame-1);
    allWaitTimes(frame) = waitTime;

    % When to flip will make sure we are waiting until we are actually
    % supposed to flip screens
    whenToFlipOn(frame) = VBLstamps(1)+stimulus.seqtiming(frame-1);
    %--- update display
    imgNum = stimulus.seq(frame);
    Screen('DrawTexture', display.windowPtr, stimulus.textures(imgNum), stimulus.srcRect, stimulus.destRect);
    ecogDrawFixation(display,stimulus.fixSeq(frame));
    Screen(display.windowPtr,'FillRect', 255, display.trigRect); %  ***** TRIGGER *******

    %--- get inputs (subject or experimentor)
    %KbCheck(display.devices.keyInputExternal);

    while(waitTime<-0.005),

        % scan the keyboard for experimenter input
        [exKeyIsDown,exSecs,exKeyCode] = KbCheck(display.devices.keyInputInternal);

        if(exKeyIsDown)
            if(exKeyCode(quitProgKey)),
                quitProg = 1;
                break % out of while loop
            end
        end

        % if there is time release cpu
        if(waitTime<-0.025),
            WaitSecs(0.003);
        end

        % timing
        waitTime = (GetSecs-VBLstamps(1))-stimulus.seqtiming(frame-1);
    end

    %--- stop?
    if quitProg,
        disp(sprintf('[%s]:Quit signal recieved.',mfilename));
        break
    end


    %--- update screen (i.e. put up the next frame)
    % use whenToFlipOn to wait until the right time in case you're early.
    % Note that it can take about one refresh to execute the screen flip.
    %     VBLtimingstart(frame) = GetSecs;  % debugging
    VBLstamps(frame) = Screen('Flip',display.windowPtr,whenToFlipOn(frame));
    %     VBLtimingend(frame) = GetSecs;   % debugging
    
end

% leave the last frame up until you're supposed to be done
if ~quitProg
    
    WaitSecs('UntilTime',timeStartTrial+stimulus.seqtiming(end));
end

ecogDrawFixation(display,stimulus.fixSeq(frame));
Screen('Flip',display.windowPtr);
%keyboard

return
