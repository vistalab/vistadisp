function [quitProg,timeStartTrial,pulseTime] = TMSshowTrial(stimulus, display, quitProgKey, TMSdelay, doublePulseTime, quitProg)
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
%   TMS delay specifies how long after stimulus onset the TMS pulse should
%   be delivered.  The TMS coil should be already ready to go before
%   entering this function (see TMSrunEventRelated.m).  If you have a
%   negative TMSdelay, the pulse should occur outside this function also.
%
%   doublePulseTime specifies when the 2nd TMS pulse arrives in relation to
%   the first pulse, for paired-pulse stimulation.  If doublePulseTime = 0, 
%   there is no 2nd pulse.  Note that with current hardware limitations (12/15/09),
%   we need at least 60ms between pulses to give the stimulator time to
%   recharge.
%
%   pulseTime returns the time from the first screen flip that the TMS
%   pulse occurred.  If there are two pulses, pulseTime(2) returns the time
%   in relation to the first pulse (i.e. should be close to doublePulseTime).
%
%    [quitProg,timeStartTrial,pulseTime] = TMSshowTrial(stimulus, display, quitProgKey, TMSdelay, [doublePulseTime=0], [quitProg=0])
%
%  ported from showScanTrial (for fMRI) by amr Dec 15, 2009 and added TMS
%  pulse timing control using tmr (see also TMSrunEventRelated)
%

%% Show the first frame as soon as possible

pulseTime = [];
% put in an image
% imgNum = mod(stimulus.seq(1)-1,nImages)+1;
timeStartTrial = GetSecs; % "time 0" to know when trial should end
%start(tmr)  % start counting time for TMS pulse offset; theoretically this should happen at the flip, but the timing was off
Screen('DrawTexture', display.windowPtr, stimulus.textures(1), stimulus.srcRect, stimulus.destRect);
drawFixation(display,stimulus.fixSeq(1));

% VBLstamps(1) will be a time stamp that the first frame was put on (acts as a reference)
VBLstamps(1) = Screen('Flip',display.windowPtr);
tic

% TMS pulses are in relation to the time the first frame is shown
%doublePulseTime = 0.060;  % for testing
%TMSdelay = 0.120;  % for testing
if notDefined('doublePulseTime')
    doublePulseTime = 0; % no 2nd pulse
end
whenToTMS(1) = VBLstamps(1) + TMSdelay;
whenToTMS(2) = VBLstamps(1) + TMSdelay + doublePulseTime;

if TMSdelay>=0
    TMSisOver(1) = 0;
    TMSisOver(2) = 0;
else  % negative delay means pulses happened before the trial
    TMSisOver(1) = 1;
    TMSisOver(2) = 1;
end

% whether to send TMS pulse 1 now
if GetSecs >= whenToTMS(1) && ~TMSisOver(1)
    err=DaqDConfigPort(1,0,0); %err=DaqDConfigPort(device,port,direction) % port = 0 direction = 0
    PsychHID('SetReport', 1, 2, 4, uint8([0 0 253]));  % triggers pulse
    pulseTime(1) = toc;
    tic
    TMSisOver(1)=1;  % flag to say we've used up our first pulse, so don't do it again
    %keyboard
end
% whether to send TMS pulse 2 now
if GetSecs >= whenToTMS(2) && ~TMSisOver(2)
    err=DaqDConfigPort(1,0,0); %err=DaqDConfigPort(device,port,direction) % port = 0 direction = 0
    PsychHID('SetReport', 1, 2, 4, uint8([0 0 253]));  % triggers pulse
    pulseTime(2) = toc;
    TMSisOver(2)=1;  % means we've used up our second pulse, so don't do it again
end

if notDefined('quitProg')
    quitProg = 0; % don't quit unless this changes to 1
end

        
%% Then show the rest of the frames
for frame = 2:length(stimulus.seq)
    %toc
    % whether to send TMS pulse 1 now
    if GetSecs >= whenToTMS(1) && ~TMSisOver(1)
        err=DaqDConfigPort(1,0,0); %err=DaqDConfigPort(device,port,direction) % port = 0 direction = 0
        PsychHID('SetReport', 1, 2, 4, uint8([0 0 253]));  % triggers pulse
        pulseTime(1) = toc;
        tic
        TMSisOver(1)=1;  % means we've used up our first pulse, so don't do it again
        %keyboard
    end
    % whether to send TMS pulse 2 now
    if GetSecs >= whenToTMS(2) && ~TMSisOver(2)
        err=DaqDConfigPort(1,0,0); %err=DaqDConfigPort(device,port,direction) % port = 0 direction = 0
        PsychHID('SetReport', 1, 2, 4, uint8([0 0 253]));  % triggers pulse
        pulseTime(2) = toc;
        TMSisOver(2)=1;  % means we've used up our second pulse, so don't do it again
    end
    
    %--- timing- we will wait for the previous frame's display time to end
    waitTime = (GetSecs-VBLstamps(1)) - stimulus.seqtiming(frame-1);
    allWaitTimes(frame) = waitTime;

    % When to flip will make sure we are waiting until we are actually
    % supposed to flip screens
    whenToFlipOn(frame) = VBLstamps(1)+stimulus.seqtiming(frame-1);
    %--- update display
    imgNum = stimulus.seq(frame);
    Screen('DrawTexture', display.windowPtr, stimulus.textures(imgNum), stimulus.srcRect, stimulus.destRect);
    drawFixation(display,stimulus.fixSeq(frame));

    %--- get inputs (subject or experimentor)
    %KbCheck(display.devices.keyInputExternal);

    while(waitTime<-0.005),
        
        % whether to send TMS pulse 1 now
        if GetSecs >= whenToTMS(1) && ~TMSisOver(1)
            err=DaqDConfigPort(1,0,0); %err=DaqDConfigPort(device,port,direction) % port = 0 direction = 0
            PsychHID('SetReport', 1, 2, 4, uint8([0 0 253]));  % triggers pulse
            pulseTime(1) = toc;
            tic
            TMSisOver(1)=1;  % means we've used up our first pulse, so don't do it again
            %keyboard
        end
        % whether to send TMS pulse 2 now
        if GetSecs >= whenToTMS(2) && ~TMSisOver(2)
            err=DaqDConfigPort(1,0,0); %err=DaqDConfigPort(device,port,direction) % port = 0 direction = 0
            PsychHID('SetReport', 1, 2, 4, uint8([0 0 253]));  % triggers pulse
            pulseTime(2) = toc;
            TMSisOver(2)=1;  % means we've used up our second pulse, so don't do it again
        end

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
     while (GetSecs-VBLstamps(1)) < (stimulus.seqtiming(end))  % keep checking whether to send TMS pulses after last frame is up

        % whether to send TMS pulse 1 now
        if GetSecs >= whenToTMS(1) && ~TMSisOver(1)
            err=DaqDConfigPort(1,0,0); %err=DaqDConfigPort(device,port,direction) % port = 0 direction = 0; device could be passed in-- can be found automatically
            PsychHID('SetReport', 1, 2, 4, uint8([0 0 255-2]));  % triggers pulse; 1 is for device number, 255-2 is for coil ID
            pulseTime(1) = toc;
            tic
            TMSisOver(1)=1;  % means we've used up our first pulse, so don't do it again
            WaitSecs(doublePulseTime);
            %keyboard
        end

        % whether to send TMS pulse 2 now
        if GetSecs >= whenToTMS(2) && ~TMSisOver(2)
            err=DaqDConfigPort(1,0,0); %err=DaqDConfigPort(device,port,direction) % port = 0 direction = 0
            PsychHID('SetReport', 1, 2, 4, uint8([0 0 255-2]));  % triggers pulse; 1 is for device number, 255-2 is for coil ID
            TMSisOver(2)=1;  % means we've used up our second pulse, so don't do it again
            pulseTime(2) = toc;
        end
       WaitSecs(0.003);  % release CPU
     end
    
    %WaitSecs('UntilTime',timeStartTrial+stimulus.seqtiming(end));
end
%stop(tmr)
%keyboard

return
