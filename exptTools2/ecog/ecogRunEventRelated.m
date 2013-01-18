function [ssResponses,ssRTs,savedResponsesFile,quitProg,tenKeyFlag] = ecogRunEventRelated(ScanName,params,savedTrialsDir,noFixFlag)

% General script to run an event-related ecog experiment.
% Allows you to adjust the run length and stimulus length by
% adjusting the first few parameters.  The stimuli should be saved as a
% separate mat file for each trial.
%
% Also see runFuncBlockScan and runFuncEventRelated for related code.
%
%       [ssResponses,ssRTs,savedResponsesFile,tenKeyFlag] = ecogRunEventRelated(ScanName,params,savedTrialsDir)
%
% ssResponses and ssRTs give the responses and reaction time for each trial
% (in a cell array), taken from the external keyboard (or USB button box).
%
% ported from runFuncEventRelated by amr on Jan 5, 2010
%

%% PARAMETERS

fixationPixelSize = 5;  % set size of fixation dot here (1-5)

if notDefined('noFixFlag')
    noFixFlag = 0;
end

% Get subject info (for saving)
if ~isfield(params,'subjName') && ~isfield(params,'subjID')
    fprintf('\n');
    subjID = input('Subject Initials:  ','s');
elseif isfield(params,'subjName')
    subjID = params.subjName;
else
    subjID = params.subjID;
end

% Where to save
savedDataDir = [fileparts(savedTrialsDir) '/Data'];
if ~exist(savedDataDir,'dir'), mkdir(savedDataDir), end;
if ~isfield(params,'scanNumber'), params.scanNumber = 'NA'; end
savedResponsesFile = fullfile(savedDataDir,[subjID '_' datestr(now,'dd-mm-yyyy-HH-MM') '_scan' num2str(params.scanNumber') '_savedResponses.mat']);
savedTrialInfoFile = fullfile(fileparts(savedResponsesFile),[subjID '_' datestr(now,'dd-mm-yyyy-HH-MM') '_scan' num2str(params.scanNumber') '_savedTrialInfo.mat']);

% If we want the condition names, they are saved in the paramInfoFile (variable is condNames)
%     paramInfoFile = fullfile(savedTrialsDir,'paramInfoFile.mat');


%% MAKE PARFILE VARIABLE
%parFileName = [ScanName '_' subjID '_' datestr(now,'ddmmyyyy_HH-MM') '.par'];
%parFilePath = fullfile(params.baseDir,'parfiles',parFileName);


%%
quitProg = 0;
try
    %% SCREEN AND KEYBOARD STUFF
    
    % PTB says to do this for timing accuracy and reliability
    Screen('Preference','SkipSyncTests',0);
    
    % %To run on an external monitor for testing, although the projector params seem to work fine too.
    %scanparams.display = loadDisplayParams('displayName', 'NEC485words.mat');%('builtin');%'tenbit');
    scanparams.display = loadDisplayParams('displayName', 'gunjou.mat');
    
    scanparams.display.fixColorRgb = [255 0 0 255; 0 0 255 255; 255 255 255 0];
    
    screens=Screen('Screens'); % find the number of screens
    scanparams.display.screenNumber = max(screens); % put this on the highest number screen
    % (0 is the 1st screen)
    scanparams.runPriority = 9;
    scanparams.startScan = 0;
    scanparams.display.devices = getDevices;  % in display so we can pass it along with that structs
    [scanparams.display.devices.keyInputDeviceNum pauseKey quitProgKey resumeKey tenKeyFlag] = getKeyboardAuto;
    
    % check for OpenGL
    AssertOpenGL;
    
    % Open the screen
    scanparams.display = openScreen(scanparams.display);
    
    scanparams.display.fixSizePixels = fixationPixelSize;
    
    if noFixFlag
        scanparams.display.fixType = 'none';
    end
    
    
    %% INITIALIZATION
    KbCheck;GetSecs;WaitSecs(0.001);
    
    % set priority
    Priority(scanparams.runPriority);
    
    % external keyboard (or MRI button box) responses
    keylist = ones(1,256);  %keys to record
    KbQueueCreate(scanparams.display.devices.keyInputDeviceNum,keylist);
    
    % Print a ready screen and wait for a keypress to start photodiode
    Screen('TextFont',scanparams.display.windowPtr,'Times');
    Screen('TextSize',scanparams.display.windowPtr,48);
    DrawFormattedText(scanparams.display.windowPtr, 'Ready! Press R to begin','center','center',255);
    Screen('Flip',scanparams.display.windowPtr);
    getKey(resumeKey,scanparams.display.devices.keyInputDeviceNum);
    
    % Set trigger square rect and dur
    Rect = scanparams.display.rect;
    scanparams.display.trigRect = [Rect(3)*0.93 Rect(4)*0.90 Rect(3) Rect(4)];
    scanparams.display.trigDur = 0.010;
    %boundBox = [Rect(3)*0.15 Rect(4)*0.15 Rect(3)*0.85 Rect(4)*0.85];
    
    % Flashing start sequence
    flinit = ecogInitPhotodiode(scanparams.display.windowPtr,scanparams.display.trigRect);
    WaitSecs(0.5)
    pauseTimes = 0; % no time spent pausing yet
    
    %% SHOW TRIALS
    try
        numTrials = length(params.conditionOrder);
    catch  % sometimes params.conditionOrder may not exist, hopefully params.ITIs does
        numTrials = length(params.ITIs);
    end
    disp(sprintf('[%s]:Running. Hit %s to quit.',mfilename,KbName(quitProgKey)));
    startExptTime = GetSecs;
    
    % Put on fixation
    ecogDrawFixation(scanparams.display,3);
    Screen('Flip', scanparams.display.windowPtr);
    Screen('Close');
    
    timeposttrial = GetSecs;
    for trialNum = 1:numTrials
        
        % gotime will determine when to move on to the next trial.  In the meantime, we load up that next trial.
        % gotime = start time + time before stims + length of previous stims + length of previous ITIs
        gotime = startExptTime + params.preStimBase + (trialNum-1)*(params.stimLength+params.RT) + sum(params.ITIs(1:trialNum-1)) + sum(pauseTimes);
        %trialgotime = gotime - startExptTime
        
        % Load in trialInfo, which has .seq and .seqtiming
        curTrialPath = fullfile(savedTrialsDir,['trial_' num2str(trialNum) '.mat']);
        %tic
        load(curTrialPath);  % loads in trialInfo for this particular trial
        
        % If there is no images field (i.e. saved images), then load your
        % image from file or create image from scratch
        if ~isfield(trialInfo,'images')
            if isfield(trialInfo,'imagePath')  % imagePath should specify location of an image
                if ~iscell(trialInfo.imagePath)  % only 1 image
                    trialInfo.images{1} = imread(trialInfo.imagePath);   % read an image from file
                else  % if a cell, then read in all the images
                    for imnum = 1:length(trialInfo.imagePath)
                        trialInfo.images{imnum} = imread(trialInfo.imagePath{imnum});
                    end
                end
                %             elseif isfield(trialInfo,'trialGenFuncName')
                %             % this option currently DOES NOT WORK
                %                 trialGenFuncCmd = strcat(trialInfo.trialGenFuncName, '(display, params, data)');
                %                 trialInfo.images = trialGenFuncCmd;
            else  % don't have images saved or location of stimulus image
                fprintf('\n%s%0.0f\n','Error: No stimulus image or image location saved for trial: ',trialNum);
            end
        end
        % Fixation sequence; ones just to keep red fixation, for now
        trialInfo.fixSeq = ones(size(trialInfo.seq));
        
        % Other color of fixation for fixation task-- fixation color goes along with each frame, so 1 frame trials are either blue or red fixation
        nn = floor(4/(params.stimLength+params.ITIs(trialNum))); % on average every 4 seconds [max response time = 3 seconds]
        trialInfo.fixSeq = ones(nn,1)*round(rand(1,ceil(length(trialInfo.seq)/nn)));
        trialInfo.fixSeq = trialInfo.fixSeq(:)+1;
        trialInfo.fixSeq = trialInfo.fixSeq(1:length(trialInfo.seq));
        % force binary
        trialInfo.fixSeq(trialInfo.fixSeq>2)=2;
        trialInfo.fixSeq(trialInfo.fixSeq<1)=1;
        fixSeq{trialNum} = trialInfo.fixSeq;  % this is only used for saving
        save(savedTrialInfoFile,'fixSeq')  % overwrite on every trial with updated vector
        
        % Some other parameters we need to specify the size of the image
        trialInfo.imSize = size(trialInfo.images{1});  % this might need to change to ensure size consistency across trials i.e. store imSize ahead of time and then force each trial to that size
        trialInfo.imSize = trialInfo.imSize([2 1]);
        
        % Convert images to textures for that trial
        trialInfo = makeTextures(scanparams.display,trialInfo);  % trialInfo has a field named images
        
        % Not sure what this is about.
        trialInfo.srcRect = [];
        trialInfo.cmap = [];
        
        % Re-position the stimulus if specified
        if isfield(trialInfo,'angle') || isfield(trialInfo,'distance')
            c   = computePosition(scanparams.display,[0.5 0.5],trialInfo.angle,trialInfo.distance);
            tl  = round([c(3)-trialInfo.imSize(1)/2 c(4)-trialInfo.imSize(2)/2]);
            trialInfo.destRect = [tl tl+trialInfo.imSize(1:2)];
        else
        % Center the output display rectangle
            c = scanparams.display.numPixels/2;
            tl = round([c(1)-trialInfo.imSize(1)/2 c(2)-trialInfo.imSize(2)/2]);
            trialInfo.destRect = [tl tl+trialInfo.imSize(1:2)];
        end
        
        %trialInfo.RT = params.RT; %the response time (beyond stimulus time) is the same for each trial, and it is set by params.RT
        
        % Leave fixation on until time to show next trial
        WaitSecs('UntilTime',gotime);
        
        %% Get key presses and RTs from last trial (unless trial #1)
        if ~(trialNum==1)
            KbQueueStop();  % stops collection of responses but can still check with KbQueueCheck
            [k.pressed, k.firstPress, k.firstRelease, k.lastPress, k.lastRelease]=...
                KbQueueCheck();
            ssResponses{trialNum-1} = KbName(k.firstPress);  % [] if no response
            f = find(k.firstPress);
            if k.pressed
                ssRTs{trialNum-1} = k.firstPress(f)-timeStartTrial(trialNum-1);   % ssRT = k.firstPress(f{frame})-VBLstamps(1);
            else ssRTs{trialNum-1} = 0; end
            
            if strcmp(ssResponses{trialNum-1},pauseKey) % PAUSE EXPT
                [quitProg,pauseTimes(end+1)] = ecogPauseExpt(scanparams.display.devices.keyInputDeviceNum,resumeKey,quitProgKey,scanparams.display.windowPtr,128);
            end
            
            if strcmp(ssResponses{trialNum-1},quitProgKey)
                quitProg = 1;
            end
            
            if quitProg, break, end
            KbQueueFlush();
            % Save responses on each trial
            save(savedResponsesFile,'ssResponses','ssRTs','timeStartTrial');
        end
        
        %% Start collecting key presses for next trial
        KbQueueStart();
        
        %% Line that actually shows the trial
        %toc
        %tic
        timepretrial = GetSecs;
        intertrialtime = timepretrial-timeposttrial;  %remove semicolon to output
        [quitProg,timeStartTrial(trialNum)] = ecogShowTrial(trialInfo, scanparams.display, quitProgKey, quitProg);
        timeposttrial = GetSecs;
        trialtime = timeposttrial-timepretrial;  %remove semicolon to output
        
        %% Switch to fixation, then wait for RT, which is the extra time given for a subject response after stimulus is off.
        % It is also the minimum ITI.
        ecogDrawFixation(scanparams.display,3);
        Screen('Flip', scanparams.display.windowPtr);
        Screen('Close'); 
        
        %% Clear the current textures to free up memory
        trialInfo.textures = [];
        
        if quitProg, break, end
    end
    
    if ~quitProg  % don't want to wait if user just quit
        % Flip to fixation for post-stimulus baseline
        ecogDrawFixation(scanparams.display,1);
        Screen('Flip', scanparams.display.windowPtr);
        Screen('Close');
        % Wait until the time when everything should be over (including post-stim baseline period)
        gotime = startExptTime + params.preStimBase + (numTrials)*(params.stimLength+params.RT) + sum(params.ITIs(1:numTrials)) + params.postStimBase;
        WaitSecs('UntilTime',gotime);
        endExptTime = GetSecs;
        totExptTime = endExptTime - startExptTime
    end
    
    % Key response for last trial
    KbQueueStop();  % stops collection of responses but can still check with KbQueueCheck
    [k.pressed, k.firstPress, k.firstRelease, k.lastPress, k.lastRelease]=...
        KbQueueCheck();
    ssResponses{trialNum} = KbName(k.firstPress);  % [] if no response
    f = find(k.firstPress);
    if k.pressed
        ssRTs{trialNum} = k.firstPress(f)-timeStartTrial(trialNum);   % ssRT = k.firstPress(f{frame})-VBLstamps(1);
    else ssRTs{trialNum} = 0; end
    KbQueueFlush();
    KbQueueRelease();
    
catch
    %% RESET PRIORITY AND SCREEN
    Screen('CloseAll');
    Priority(0);
    ShowCursor;
    %    delete(tmr);
    rethrow(lasterror)
end

try  % if running from a different user, saving may not work due to permissions
    % Save out the response data
    save(savedResponsesFile,'ssResponses','ssRTs','timeStartTrial','startExptTime');  % this is the raw data, will make calculations below
    fprintf('\n%s\n%s\n','Saved subject responses (as matlab variables) to:  ', savedResponsesFile);
catch
    rethrow(lasterror)
end

%% RESET PRIORITY AND SCREEN
Screen('CloseAll');
Priority(0);
ShowCursor;
%delete(tmr);

return
