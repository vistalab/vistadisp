function [response, timing, quitProg] = showScanBlock_noTrialStruct(display,stimulus, t0, triggerKey)
% [response, timing, quitProg] = showScanBlock(display,stimulus, t0)
%
% This function shows all the frames within a scan block, without the use
% of any trial structure.  The main reason to use this function over
% showScanBlock probably has to do with subject responses.  When doing a
% fixation change detection task, it is more straightforward to use this
% code (see e.g. doWordLocalizer).  However, when responses should go with
% trials, it is better to use showScanBlock (see e.g. doWordScan).  This is
% mainly due to the format of responses that getFixationPerformance
% expects.
%


%% Input checks

if nargin < 2,
    help(mfilename);
    return;
end;

if notDefined('timeFromT0'), timeFromT0 = true; end

% some more checks
if ~isfield(stimulus,'textures')
    % Generate textures for each image
    disp('WARNING: Creating textures before stimulus presentation.');
    disp(['         This should be done before calling ' mfilename ' for']);
    disp('         accurate timing.  See "makeTextures" for help.');
    stimulus = makeTextures(display,stimulus);
end;

% quit key
if(isfield(display,'quitProgKey')), quitProgKey = display.quitProgKey;
else                                quitProgKey = KbName('q'); end

% trigger key
kb.all = KbName('KeyNames');
if exist('triggerKey', 'var')
    kb.keyCodes = cellfun(@isempty, strfind(kb.all, triggerKey));       
else
    kb.keyCodes = 1:256;
end

% some variables
nFrames = length(stimulus.seq);
HideCursor;
nGamma = size(stimulus.cmap,3);
nImages = length(stimulus.textures);
response.keyCode = zeros(1,length(stimulus.seq)); % get 1 buttons max
response.secs = zeros(size(stimulus.seq));        % timing
quitProg = 0;
whenToFlipOn = zeros(1,nFrames);

% % debugging
VBLstamps = zeros(1,nFrames);
allWaitTimes = zeros(1,nFrames);
% keyloopcounter = zeros(1,nFrames);
% VBLtimingstart = zeros(1,nFrames);
% VBLtimingend = zeros(1,nFrames);

%% Show the first frame as soon as possible
fprintf('[%s]:Running. Hit %s to quit.\n',mfilename,KbName(quitProgKey));
if stimulus.seq(1)>0
    % put in an image
    imgNum = mod(stimulus.seq(1)-1,nImages)+1;
    Screen('DrawTexture', display.windowPtr, stimulus.textures(imgNum), stimulus.srcRect, stimulus.destRect);
    
    % If we are doing eCOG, then flash photodiode if requested
    if isfield(stimulus, 'trigSeq')
        drawTrig(display,stimulus.trigSeq(1));
    end
    
    drawFixation(display,stimulus.fixSeq(1));
elseif stimulus.seq(1)<0
    % put in a color table
    gammaNum = mod(-stimulus.seq(1)-1,nGamma)+1;
    % The second argument is the color index.  This apparently changed
    % in recent times (07.14.2008). So, for now we set it to 1.  It may
    % be that this hsould be
    
    drawFixation(display,stimulus.fixSeq(1));
    Screen('LoadNormalizedGammaTable', display.windowPtr, stimulus.cmap(:,:,gammaNum));
    
end
VBLstamps(1) = Screen('Flip',display.windowPtr);
if nargin < 3 || isempty(t0),
    t0 = GetSecs; % "time 0" to keep timing going
end;



%% Then show the rest of the frames

for frame = 2:nFrames
    
    %--- timing- we will wait for the previous frame's display time to end
    waitTime = (GetSecs-t0)-stimulus.seqtiming(frame-1);
    allWaitTimes(frame) = waitTime;
    
    % When to flip will make sure we are waiting until we are actually
    % supposed to flip screens
    whenToFlipOn(frame) = VBLstamps(1)+stimulus.seqtiming(frame-1);
    %--- update display
    % If the sequence number is positive, draw the stimulus and the
    % fixation.  If the sequence number is negative, draw only the
    % fixation.
    if stimulus.seq(frame)>0
        % put in an image
        imgNum = mod(stimulus.seq(frame)-1,nImages)+1;
        Screen('DrawTexture', display.windowPtr, stimulus.textures(imgNum), stimulus.srcRect, stimulus.destRect);
        
        % If we are doing eCOG, then flash photodiode if requested
        if isfield(stimulus, 'trigSeq')
            drawTrig(display,stimulus.trigSeq(frame));
        end
        
        drawFixation(display,stimulus.fixSeq(frame));
        
    elseif stimulus.seq(frame)<0
        % put in a color table
        gammaNum = mod(-stimulus.seq(frame)-1,nGamma)+1;
        % The second argument is the color index.  This apparently changed
        % in recent times (07.14.2008). So, for now we set it to 1.  It may
        % be that this hsould be
        
        drawFixation(display,stimulus.fixSeq(frame));
        Screen('LoadNormalizedGammaTable', display.windowPtr, stimulus.cmap(:,:,gammaNum));
        
    end
    
    %--- get inputs (subject or experimentor)
<<<<<<< HEAD
            %KbCheck(display.devices.keyInputExternal);

      %--- get inputs (subject or experimentor)
    while(waitTime<0),
        
        % Scan the keyboard for subject response
        [ssKeyIsDown,ssSecs,ssKeyCode] = KbCheck(display.devices.keyInputExternal);        
        if(ssKeyIsDown)
            kc = find(ssKeyCode);
            if kb.keyCodes(kc(1)),
                response.keyCode(frame) = kc(1);            
                response.secs(frame)    = ssSecs - t0;
            end
        end;
        
=======
    %KbCheck(display.devices.keyInputExternal);
    
    while(waitTime<-0.005),
        % Scan the keyboard for subject response
        [ssKeyIsDown,ssSecs,ssKeyCode] = KbCheck(display.devices.keyInputExternal);
        if(ssKeyIsDown)
            %            kc = find(ssKeyCode);
            %            response.keyCode(frame) = kc(1);
            response.keyCode(frame) = 1; % binary response for now
            response.secs(frame)    = ssSecs - t0;
        end;
>>>>>>> master
        % scan the keyboard for experimentor input
        [exKeyIsDown,exSecs,exKeyCode] = KbCheck(display.devices.keyInputInternal);
        if(exKeyIsDown)
            if(exKeyCode(quitProgKey)),
                quitProg = 1;
                break; % out of while loop
            end;
        end;
        
        % if there is time release cpu
        if(waitTime<-0.02),
            WaitSecs(0.01);
        end;
        
        % timing
        % waitTime = getWaitTime(stimulus, response, frame, t0, timeFromT0);
        waitTime = (GetSecs-t0)-stimulus.seqtiming(frame-1);
<<<<<<< HEAD
        
    end;
=======
        %         keyloopcounter(frame) = keyloopcounter(frame)+1; %debugging
    end
>>>>>>> master
    
    %--- stop?
    if quitProg,
        fprintf('[%s]:Quit signal recieved.\n',mfilename);
        break;
    end;
<<<<<<< HEAD
        
    %--- update screen
    VBLTimestamp = Screen('Flip',display.windowPtr);
    %response.flip(end+1) = GetSecs;
    response.flip(frame) = VBLTimestamp;
    if isfield(stimulus, 'trigSeq'), response.LED(frame)  = colIndex; end
    
end
=======
    
    
    %--- update screen (i.e. put up the next frame)
    % use whenToFlipOn to wait until the right time in case you're early.
    % Note that it can take about one refresh to execute the screen flip.
    
    % %     VBLtimingstart(frame) = GetSecs;  % debugging
    VBLstamps(frame) = Screen('Flip',display.windowPtr,whenToFlipOn(frame));
    %     %VBLstamps(frame) = Screen('Flip',display.windowPtr);
    %     %     VBLtimingend(frame) = GetSecs;   % debugging
    %
    %     % get the key presses and RTs for each frame shown
    %     [k.pressed, k.firstPress, k.firstRelease, k.lastPress, k.lastRelease]=...
    %         KbQueueCheck();
    %     f{frame} = find(k.firstPress);
    %     if k.pressed
    %         keys(frame) = str2double(KbName(k.firstPress));  % record the keys, if we want-- must be numbers!
    %         response.keyCode(frame)=1;  %binary response for now
    %         response.secs(frame) = k.firstPress(f{frame})-VBLstamps(1);
    %     else
    %         keys(frame)=NaN;
    %         response.keyCode(frame)=0;
    %         response.secs(frame) = 0;
    %     end
end
% KbQueueStop();
>>>>>>> master

% leave the last frame up until you're supposed to be done
if ~quitProg
    WaitSecs('UntilTime',VBLstamps(1)+stimulus.seqtiming(end));
end

% that's it for this block
timing = GetSecs-t0;
nLongFrames = sum(diff(VBLstamps)>diff(stimulus.seqtiming)+.001);
fprintf('[%s]:Block run time: %f seconds [should be: %f]. %d (of %d) frames ran long.\n',mfilename,timing,max(stimulus.seqtiming),nLongFrames,nFrames-1);

return;



function waitTime = getWaitTime(stimulus, response, frame, t0, timeFromT0)
% waitTime = getWaitTime(stimulus, response, frame, t0, timeFromT0)
%
% If timeFromT0 we wait until the current time minus the initial time is
% equal to the desired presentation time, and then flip the screen. 
% If timeFromT0 is false, then we wait until the current time minus the
% last screen flip time is equal to the desired difference in the
% presentation time of the current flip and the prior flip.

if timeFromT0
    waitTime = (GetSecs-t0)-stimulus.seqtiming(frame);
else
    if frame > 1,
        lastFlip = response.flip(frame-1);
        desiredWaitTime = stimulus.seqtiming(frame) - stimulus.seqtiming(frame-1);
    else
        lastFlip = t0;
        desiredWaitTime = stimulus.seqtiming(frame);
    end
    % we add 10 ms of slop time, otherwise we might be a frame late.
    % This should NOT cause us to be 10 ms early, because PTB waits
    % until the next screen flip. However, if the refresh rate of the
    % monitor is greater than 100 Hz, this might make you a frame
    % early. [So consider going to down to 5 ms? What is the minimum we
    % need to ensure that we are not a frame late?]
    waitTime = (GetSecs-lastFlip)-desiredWaitTime + .010;
end

return
