function [response, timing, quitProg] = showScanBlock_noTrialStruct(display,stimulus, t0)
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

% some more checks
if ~isfield(stimulus,'textures')
	% Generate textures for each image
	disp('WARNING: Creating textures before stimulus presentation.');
	disp(['         This should be done before calling ' mfilename ' for']);
	disp('         accurate timing.  See "makeTextures" for help.');
	stimulus = makeTextures(display,stimulus);
end;

% quit key
if(isfield(display,'quitProgKey'))
    quitProgKey = display.quitProgKey;
else
    quitProgKey = KbName('q');
end

% some variables
nFrames = length(stimulus.seq);
HideCursor;
nGamma = size(stimulus.cmap,3);
nImages = length(stimulus.textures);
response.keyCode = zeros(length(stimulus.seq),1); % get 1 buttons max
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

%% Start collecting key presses
%keyList = zeros(1,256);
%keyList([quitProgKey KbName()]) = 1;
%KbQueueCreate(display.devices.keyInputExternal, keyList);
keylist = ones(1,256);  %keys to record
keylist(KbName('/')) = 0;  % ignore backslashes sent by Lucas 3T#2
keylist(KbName('/?')) = 0;
KbQueueCreate(display.devices.keyInputExternal,keylist);
%keyRTstart = GetSecs;
KbQueueStart();

%% Then show the rest of the frames
f    = cell(1, nFrames);
keys = zeros(1,nFrames);
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
            %KbCheck(display.devices.keyInputExternal);

    while(waitTime<-0.005),
        % Scan the keyboard for subject response -- we now use KbQueue so
        % code below is not necessary

%         [ssKeyIsDown,ssSecs,ssKeyCode] = KbCheck(display.devices.keyInputExternal);
        
%         if(ssKeyIsDown && ~strcmp(KbName(ssKeyCode),'/?') && ~strcmp(KbName(ssKeyCode),'/'))
% %            kc = find(ssKeyCode);
% %            response.keyCode(frame) = kc(1);
% 
%             if(ssKeyCode(quitProgKey)),
%                 quitProg = 1;
%                 break; % out of while loop
%             end;
% 
%             response.keyCode(frame) = 1; % binary response for now
%             response.secs(frame)    = ssSecs - t0;
%         end
        
        % scan the keyboard for experimentor input
        [exKeyIsDown,exSecs,exKeyCode] = KbCheck(display.devices.keyInputInternal); %#ok<ASGLU>
        %[exkeys RT kinfo] = qkeys(startTime,goTime,display.devices.keyInputInternal);
        
        if(exKeyIsDown)
            if(exKeyCode(quitProgKey)),
                quitProg = 1;
                break; % out of while loop
            end;
        end;

        % if there is time release cpu
        if(waitTime<-0.025),
            WaitSecs(0.005);
        end;
        
        % timing
        waitTime = (GetSecs-t0)-stimulus.seqtiming(frame-1);
%         keyloopcounter(frame) = keyloopcounter(frame)+1; %debugging
    end
    
    %--- stop?
    if quitProg,
        fprintf('[%s]:Quit signal recieved.\n',mfilename);
        break;
    end;

    
    %--- update screen (i.e. put up the next frame)
    % use whenToFlipOn to wait until the right time in case you're early.  
    % Note that it can take about one refresh to execute the screen flip.
    
%     VBLtimingstart(frame) = GetSecs;  % debugging
    VBLstamps(frame) = Screen('Flip',display.windowPtr,whenToFlipOn(frame));
    %VBLstamps(frame) = Screen('Flip',display.windowPtr);
    %     VBLtimingend(frame) = GetSecs;   % debugging
    
    % get the key presses and RTs for each frame shown
    [k.pressed, k.firstPress, k.firstRelease, k.lastPress, k.lastRelease]=...
        KbQueueCheck();
    f{frame} = find(k.firstPress);
    if k.pressed
        keys(frame) = str2double(KbName(k.firstPress));  % record the keys, if we want-- must be numbers!
        response.keyCode(frame)=1;  %binary response for now
        response.secs(frame) = k.firstPress(f{frame})-VBLstamps(1);
    else
        keys(frame)=NaN;
        response.keyCode(frame)=0;
        response.secs(frame) = 0;
    end
end
KbQueueStop();

% leave the last frame up until you're supposed to be done
if ~quitProg
    WaitSecs('UntilTime',VBLstamps(1)+stimulus.seqtiming(end));
end

% that's it for this block
timing = GetSecs-t0;
nLongFrames = sum(diff(VBLstamps)>diff(stimulus.seqtiming)+.001);
fprintf('[%s]:Block run time: %f seconds [should be: %f]. %d (of %d) frames ran long.\n',mfilename,timing,max(stimulus.seqtiming),nLongFrames,nFrames-1);

return;