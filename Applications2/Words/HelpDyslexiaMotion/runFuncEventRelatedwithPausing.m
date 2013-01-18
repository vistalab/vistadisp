function [ssResponses,ssRTs,savedResponsesFile] = runFuncEventRelatedwithPausing(ScanName,params,savedTrialsDir)

% General script to run an event-related fMRI experiment.
%
% This variation of runFuncEventRelated was made to allow users to go on to
% the next stimulus using the space bar (or after waiting a specified
% period of time)
%
% Eventually it would be nice to have a GUI that shows your experiment
% parameters and conditions (maybe with example stimuli?).  You will be
% able to load experiments, save experiments, change parameters, save out
% .par files, etc.  And I want a big button that says "Scan" (and maybe one
% that says "Test Run" (for testing outside the scanner).
%
% Press 's' on internal keyboard to skip the rest of a trial.  Press 'q' to
% quit.
%
% Also see runFuncBlockScan for related code.
%
%       runFuncEventRelatedwithPausing(ScanName,params,condNames)
%
% ssResponses and ssRTs give the responses and reaction time for each trial
% (in a cell array), taken from the external keyboard (or USB button box).
%
% written: amr 2008-12-09
%

%% PARAMETERS

fixationPixelSize = 5;  % set size of fixation dot here (1-5)
stableFixationFlag = 1;

% Get subject info (for saving)
if ~isfield(params,'subjName') && ~isfield(params,'subjID')
    fprintf('\n');
    subjID = input('Subject Initials:  ','s');
elseif isfield(params,'subjName')
    subjID = params.subjName;
else
    subjID = params.subjID;
end

if ~isfield(params,'maxTrialTime')
    params.maxTrialTime = 5;  % when trial is over if you haven't received a keyboard signal
end

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
    
    
    screens=Screen('Screens'); % find the number of screens
    whichScreen = max(screens);
    
    if whichScreen == 0  % internal monitor
        scanparams.display = loadDisplayParams('displayName', 'bluemoon1');
    else
        scanparams.display = loadDisplayParams('displayName', 'NEC485words.mat');%('builtin');%'tenbit');
    end
    clear whichScreen
    
    scanparams.display.fixColorRgb = [128 128 128 255; 0 0 75 255; 255 255 255 0];
    scanparams.display.screenNumber = max(screens); % put this on the highest number screen
    % (0 is the 1st screen)
    scanparams.runPriority = 9;
    scanparams.startScan = 0;
    scanparams.display.devices = getDevices;  % in display so we can pass it along with that strucs
    
    % check for OpenGL
    AssertOpenGL;
    
    % Open the screen
    scanparams.display = openScreen(scanparams.display);
    
    scanparams.display.fixType = 'small dot';
    scanparams.display.fixSizePixels = fixationPixelSize;
    
    % Establish the code for the quit key
    % Note that checkfields is in mrLoadRet-3.0
    if checkfields(scanparams,'display','quitProgKey')
        quitProgKey = scanparams.display.quitProgKey;
    else quitProgKey = KbName('q');
    end
    
    
    %% INITIALIZATION
    KbCheck;GetSecs;WaitSecs(0.001);
    
    % set priority
    Priority(scanparams.runPriority);
    
    % external keyboard (or MRI button box) responses
    keylist = ones(1,256);  %keys to record
    keylist(KbName('/')) = 0;  % ignore backslashes sent by Lucas 3T#2
    keylist(KbName('/?')) = 0;
    %keylist(KbName('\|')) = 0;
    KbQueueCreate(scanparams.display.devices.keyInputExternal,keylist);
    
    % wait for go signal
    pressKey2Begin(scanparams.display);
    
    % countdown + get start time (time0)
    [startExptTime] = countDown(scanparams.display,scanparams.startScan+2,scanparams.startScan);
    
    
    %% SHOW TRIALS
    try
        numTrials = length(params.conditionOrder);
    catch  % sometimes params.conditionOrder may not exist, hopefully params.ITIs does
        numTrials = length(params.ITIs);
    end
    disp(sprintf('[%s]:Running. Hit %s to quit.',mfilename,KbName(quitProgKey)));
    startExptTime = GetSecs;
    
    % Put on fixation
    drawFixation(scanparams.display,1);
    Screen('Flip', scanparams.display.windowPtr);
    Screen('Close');
    
    timeposttrial = GetSecs;
    for trialNum = 1:numTrials
        
        % gotime will determine when to move on to the next trial.  In the meantime, we load up that next trial.
        % gotime = start time + time before stims + length of previous stims + length of previous ITIs
        gotime = GetSecs + params.ITIs(trialNum); %(trialNum-1)*(params.stimLength+params.RT) + sum(params.ITIs(1:trialNum-1));
        %trialgotime = gotime - startExptTime
        
        % Load in trialInfo, which has .seq and .seqtiming
        curTrialPath = fullfile(savedTrialsDir,['trial_' num2str(trialNum) '.mat']);
        %tic
        load(curTrialPath);  % loads in trialInfo for this particular trial
        
        % complete hack to get static frames to show multiple frames
        if length(trialInfo.images) == 1
            for frameNum = 1:6
                trialInfo.images{frameNum} = trialInfo.images{1};
                trialInfo.seq = 1:length(trialInfo.images);
                trialInfo.seqtiming = 1:params.stimLength;
            end
        end
        
        % If there is no images field (i.e. saved images), then load your
        % image from file or create image from scratch
        if ~isfield(trialInfo,'images')
            if isfield(trialInfo,'imagePath')  % imagePath should specify location of an image
                trialInfo.images{1} = imread(trialInfo.imagePath);   % read an image from file
%             elseif isfield(trialInfo,'trialGenFuncName')  % this option currently DOES NOT WORK
%                 trialGenFuncCmd = strcat(trialInfo.trialGenFuncName, '(display, params, data)');
%                 trialInfo.images = trialGenFuncCmd;
            else  % don't have images saved or location of stimulus image
                fprintf('\n%s%0.0f\n','Error: No stimulus image or image location saved for trial: ',trialNum);
            end
        end
        % Fixation sequence; ones just to keep gray (i.e. no) fixation
        if stableFixationFlag
            trialInfo.fixSeq = ones(size(trialInfo.seq));
        else
            % Other color of fixation for fixation task
            %nn = floor(4/(params.stimLength+mean(params.ITIs))); % on average every 1 seconds [max response time = 3 seconds]
            nn = 2;  % 4 switches per stimulus
            trialInfo.fixSeq = ones(nn,1)*round(rand(1,ceil(length(trialInfo.seq)/nn)));
            trialInfo.fixSeq = trialInfo.fixSeq(:)+1;
            trialInfo.fixSeq = trialInfo.fixSeq(1:length(trialInfo.seq));
            % force binary
            trialInfo.fixSeq(trialInfo.fixSeq>2)=2;
            trialInfo.fixSeq(trialInfo.fixSeq<1)=1;
        end
        
        % Some other parameters we need to specify the size of the image
        trialInfo.imSize = size(trialInfo.images{1});  % this might need to change to ensure size consistency across trials i.e. store imSize ahead of time and then force each trial to that size
        trialInfo.imSize = trialInfo.imSize([2 1]);
        
        % Convert images to textures for that trial
        trialInfo = makeTextures(scanparams.display,trialInfo);  % trialInfo has a field named images
        
        % Not sure what this is about.
        trialInfo.srcRect = [];
        trialInfo.cmap = [];
        
        % Center the output display rectangle
        c = scanparams.display.numPixels/2;
        tl = round([c(1)-trialInfo.imSize(1)/2 c(2)-trialInfo.imSize(2)/2]);
        trialInfo.destRect = [tl tl+trialInfo.imSize(1:2)];
        
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
                ssRTs{trialNum-1} = k.firstPress(f)-timeStartTrial;   % ssRT = k.firstPress(f{frame})-VBLstamps(1);
            else ssRTs{trialNum-1} = 0; end
            if strcmp(ssResponses{trialNum-1},'q')
                quitProg = 1;
            end
            KbQueueFlush();
        end
        
        %% Start collecting key presses for next trial
        KbQueueStart();
        
        %% Line that actually shows the trial
        %toc
        %tic
        timepretrial = GetSecs;
        intertrialtime = timepretrial-timeposttrial;  %remove semicolon to output
        [quitProg,timeStartTrial,skipProg] = showScanTrial(trialInfo,scanparams.display,quitProgKey,quitProg);
        timeposttrial = GetSecs;
        savedTrialTimes(trialNum) = timeposttrial-startExptTime;
        trialtime = timeposttrial-timepretrial  %remove semicolon to output
        
        %% Switch to fixation, then wait for RT, which is the extra time given for a subject response after stimulus is off.
        % It is also the minimum ITI.
        drawFixation(scanparams.display,1);
        Screen('Flip', scanparams.display.windowPtr);
        drawFixation(scanparams.display,1);
        Screen('Flip', scanparams.display.windowPtr);
        
        Screen('Close');
        
        
        %% Clear the current textures to free up memory
        trialInfo.textures = [];
        
        if quitProg, break, end
    end
    
    if ~quitProg && ~skipProg  % don't want to wait if user just quit or decided to skip trial
        % Flip to fixation for post-stimulus baseline
        drawFixation(scanparams.display,1);
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
        ssRTs{trialNum} = k.firstPress(f)-timeStartTrial;   % ssRT = k.firstPress(f{frame})-VBLstamps(1);
    else ssRTs{trialNum} = 0; end
    KbQueueFlush();
    KbQueueRelease();
    
catch
    %% RESET PRIORITY AND SCREEN
    Screen('CloseAll');
    Priority(0);
    ShowCursor;
    rethrow(lasterror)
end

try  % if running from a different user, saving may not work due to permissions
    % Save out the response data
    savedDataDir = [fileparts(savedTrialsDir) '/Data'];
    if ~exist(savedDataDir,'dir'), mkdir(savedDataDir), end;
    if ~isfield(params,'scanNumber'), params.scanNumber = 'NA'; end
    savedResponsesFile = fullfile(savedDataDir,[subjID '_' datestr(now,'dd.mm.yyyy-HH.MM') '_' params.listType '_' params.stimType '_savedResponses.mat']);
    save(savedResponsesFile,'ssResponses','ssRTs');  % this is the raw data, will make calculations below
    fprintf('\n%s\n%s\n','Saved subject responses (as matlab variables) to:  ', savedResponsesFile);
catch
    rethrow(lasterror)
end

%% RESET PRIORITY AND SCREEN
Screen('CloseAll');
Priority(0);
ShowCursor;

return
