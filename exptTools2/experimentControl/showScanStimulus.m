function [response, timing, quitProg] = showScanStimulus(display, stimulus, t0)
% [response, timing, quitProg] = showStimulus(display,stimulus, ...
%           [time0 = GetSecs], [timeFromT0 = true])
%
% Inputs
%   display:    vistadisp display structure
%   stimulus:   vistadisp stimulus structure (e.g., see doRetinotopyScan.m)
%   t0:         time the scan started in seconds acc to PsychtoolBox
%               GetSecs function. By default stimulus timing is relative to
%               t0. If t0 does not exist it is created at the start of this
%               program.
% Outputs:
%   response:   struct containing fields
%                   keyCode: keyboard response at each frame, if any; if
%                           no response record a 0);
%                   secs: time of each response in seconds ?? verify
%                   flip:   time of each screen flip measured by PTB
%   timing:     float indicating total time of experiment
%   quitProg:   Boolean to indicate if experiment ended by hitting quit key
%
%
% HISTORY:
% 2005.02.23 RFD: ported from showStimulus.
% 2005.06.15 SOD: modified for OSX. Use internal clock for timing rather
%                 than framesyncing because getting framerate does not
%                 always work. Using the internal clock will also allow
%                 some "catching up" if stimulus is delayed for whatever
%                 reason. Loading mex functions is slow, so this should be
%                 done before callling this program.
% 2011.09.15  JW: added optional input flag, timeFromT0 (default = true).
%                 true, we time each screen flip from initial time (t0). If
%                 false, we time each screen flip from the last screen
%                 flip. Ideally the results are the same.


% input checks
if nargin < 2, help(mfilename); return; end;

if nargin < 3 || isempty(t0),
    t0 = GetSecs; % "time 0" to keep timing going
end;

if ~isfield(stimulus, 'saveMovie'), saveMovie = 0; 
else                                saveMovie = stimulus.saveMovie; end
    
if saveMovie   
   imageArray = zeros(display.rect(4),display.rect(3), length(stimulus.seq),3);    
end

% timeFromT0: If true (default), then time each screen flip from
%             t0. If false, then time each screen flip from last screen
%             flip. The former is typically used for fMRI, where we want
%             to avoid accumulation of timing errors. The latter may be
%             more useful for ECoG/EEG/MEG where we care about the precise
%             temporal frequency of the stimulus.
if ~isfield(display, 'timeFromT0'), timeFromT0 = true; 
else                                timeFromT0 = display.timeFromT0; end

% some more checks
if ~isfield(stimulus,'textures')
    % Generate textures for each image
    disp('WARNING: Creating textures before stimulus presentation.');
    disp(['         This should be done before calling ' mfilename ' for']);
    disp('         accurate timing.  See "makeTextures" for help.');
    stimulus = makeTextures(display,stimulus);
end;

% quit key
if checkfields(display, 'quitProgKey')
    quitProgKey = display.quitProgKey;
else
    quitProgKey = KbName('q');
end;

% initialize KbQueue
okkeys = ones(1,256); okkeys(53) = 0;
KbQueueCreate(display.devices.keyInputExternal, okkeys); % display.devices.keyInputExternal); 

% some variables
nFrames = length(stimulus.seq);
HideCursor;
nGamma = size(stimulus.cmap,3);
nImages = length(stimulus.textures);
response.keyCode = zeros(length(stimulus.seq),1); % get 1 buttons max
response.secs = zeros(size(stimulus.seq));        % timing
quitProg = 0;
response.flip = [];

% go
fprintf('[%s]:Running. Hit %s to quit.\n',mfilename,KbName(quitProgKey));

% If we are doing ECoG/MEG/EEG, then start with black photodiode
if isfield(stimulus, 'diodeSeq') && ~isempty(stimulus.diodeSeq)
    drawTrig(display,0);
end

for frame = 1:nFrames
    
    KbQueueStart(display.devices.keyInputExternal);

    %--- update display
    % If the sequence number is positive, draw the stimulus and the
    % fixation.  If the sequence number is negative, draw only the
    % fixation.
    if stimulus.seq(frame)>0
        % put in an image
        imgNum = mod(stimulus.seq(frame)-1,nImages)+1;
        Screen('DrawTexture', display.windowPtr, stimulus.textures(imgNum), stimulus.srcRect, stimulus.destRect);
                
        drawFixation(display,stimulus.fixSeq(frame));
        
        % If requested, flash photodiode (for ECoG/EEG/MEG)
        if isfield(stimulus, 'diodeSeq') && ~isempty(stimulus.diodeSeq)
            colIndex = drawTrig(display,stimulus.diodeSeq(frame));
        end
        
    elseif stimulus.seq(frame)<0
        % put in a color table
        gammaNum = mod(-stimulus.seq(frame)-1,nGamma)+1;
        % The second argument is the color index.  This apparently changed
        % in recent times (07.14.2008). So, for now we set it to 1.  It may
        % be that this hsould be
        drawFixation(display,stimulus.fixSeq(frame));
        Screen('LoadNormalizedGammaTable', display.windowPtr, stimulus.cmap(:,:,gammaNum));
    end;
    
    %--- timing
    [waitTime, nextFlipTime] = getWaitTime(stimulus, response, frame,  t0, timeFromT0);
    

    % if there is time release cpu
    if(waitTime<-0.03), WaitSecs(0.01); end;
            
    %--- stop?
    if quitProg,
        fprintf('[%s]:Quit signal recieved.\n',mfilename);
        break;
    end;
    
    %--- update screen
    VBLTimestamp = Screen('Flip',display.windowPtr, nextFlipTime);
    
    if saveMovie,
        imageArray(:,:,frame,:) = Screen('GetImage', display.windowPtr,display.rect);
    end
    
    % send trigger for MEG, if requested, and record the color of the PD
    % cue
    if isfield(stimulus, 'trigSeq') && ~isempty(stimulus.trigSeq) && ...
            stimulus.trigSeq(frame) > 0
        switch lower(display.modality)
            case 'meg'
                PTBSendTrigger(stimulus.trigSeq(frame), 0);        
            case 'eeg'
                thisCode = sprintf('%4.0d', stimulus.trigSeq(frame));
                NetStation('Event', thisCode,VBLTimestamp);
        end
        % Print out message indicating trigger was sent
        fprintf('Trigger sent (%d), %s, \n', stimulus.trigSeq(frame), datestr(now)); drawnow
        response.trig(frame) = stimulus.trigSeq(frame);
    end
    
    if isfield(stimulus, 'diodeSeq') && ~isempty(stimulus.diodeSeq)
        response.LED(frame)  = colIndex;
    end
    
    % record the flip time
    response.flip(frame)         = VBLTimestamp;
    response.nextFlipTime(frame) = nextFlipTime;


    % Scan the keyboard for subject response    
    [pressed, firstPress]=KbQueueCheck(display.devices.keyInputExternal);
       
    if pressed
        
        % which key was pressed first?
        whichKeys = find(firstPress);
        whichTimes = firstPress(whichKeys)-t0;
        [~, firstKey] = min(whichTimes);
        
        response.keyCode(frame) = whichKeys(firstKey); 
        response.secs(frame)    = whichTimes(firstKey) - t0;
        
        
        fprintf('Frame: %d\tPressed: %d\n', frame, pressed)
        disp(whichKeys)
        disp(whichTimes)
        disp(whichKeys(firstKey))
        fprintf('End of frame \n\n')
        
        if firstPress(quitProgKey)
            quitProg = 1;
            break; % out of while loop
        end;
    end;
    
    KbQueueFlush(display.devices.keyInputExternal);
    KbQueueStop(display.devices.keyInputExternal);
    
end;

% that's it
ShowCursor;
timing = GetSecs-t0;
fprintf('[%s]:Stimulus run time: %f seconds [should be: %f].\n',mfilename,timing,max(stimulus.seqtiming));

if saveMovie
    stimulus.movie = imageArray;
    save('~/Desktop/myVistadispMovie.mat', 'stimulus');
end

return;
