function [ssResponses,ssRTs,savedResponsesFile] = TMSrunEventRelated(ScanName,params,savedTrialsDir)

% General script to run an event-related TMS experiment.
% Allows you to adjust the run length and stimulus length by
% adjusting the first few parameters.  The stimuli should be saved as a
% separate mat file for each trial.
%
% Also see runFuncBlockScan and runFuncEventRelated for related code.
%
%       [ssResponses,ssRTs,savedResponsesFile] = TMSrunEventRelated(ScanName,params,savedTrialsDir)
%
% ssResponses and ssRTs give the responses and reaction time for each trial
% (in a cell array), taken from the external keyboard (or USB button box).
%
% ported from runFuncEventRelated by amr on Dec 9, 2009
%

%% PARAMETERS

% if notDefined('baseDir')
%     baseDir = ['/Users/Shared/AndreasWordsMatlab/' ScanName]; % directory that contains stim folder with stimuli
%     % stim folder inside baseDir contains the saved trials
% end

% Get subject info (for saving)
if ~isfield(params,'subjName') && ~isfield(params,'subjID')
    fprintf('\n');
    subjID = input('Subject Initials:  ','s');
elseif isfield(params,'subjName')
    subjID = params.subjName;
else
    subjID = params.subjID;
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
    
    % %To run on an external monitor for testing, although the projector params seem to work fine too.
    scanparams.display = loadDisplayParams('displayName', 'NEC485words.mat');%('builtin');%'tenbit');
    
    scanparams.display.fixColorRgb = [255 0 0 255; 0 0 255 255; 255 255 255 0];
    
    screens=Screen('Screens'); % find the number of screens
    scanparams.display.screenNumber = max(screens); % put this on the highest number screen
    % (0 is the 1st screen)
    scanparams.runPriority = 9;
    scanparams.startScan = 0;
    scanparams.display.devices = getDevices;  % in display so we can pass it along with that strucs
    
    % Set up TMS coil (Initalize PMD1208FS)
    %trial_coil_code = 2; %any multiple of 2 triggers both coils
    doublePulseTime = 0.040;  % 40ms between pulses
    devices=PsychHID('Devices');
    device=devices(1);
    if isnumeric(device) && device < 0,
        fprintf(1,'Not sending output; PMD1208FS Device not found\n');
        FastDaqDout = inline('','device', 'port', 'data');
   else
        fprintf(1,'Initalizing PMD1208FS for output\n');
        deviceInd = device.index;
        FastDaqDout = inline('PsychHID(''SetReport'', deviceInd, 2, hex2dec(''04''), uint8([0 port data]))','deviceInd', 'port', 'data');
    end
    
    % TMS timing (set up separate timer to keep track of TMS pulse timing)
%     tmr=timer;
%     trial_coil_code = 2;
%     FastDaqDout = inline('PsychHID(''SetReport'', deviceInd, 2, hex2dec(''04''), uint8([0 port data]))','deviceInd', 'port', 'data');
%     %set(tmr, 'TimerFcn', 'disp(''pulse''); err=DaqDConfigPort(1,0,0); PsychHID(''SetReport'', 1, 2, 4, uint8([0 0 253])); toc')  % configure and send a pulse
%     set(tmr, 'TimerFcn', 'err=DaqDConfigPort(1,0,0); PsychHID(''SetReport'', 1, 2, 4, uint8([0 0 253])); toc')  % configure and send a pulse
%     set(tmr, 'Period', doublePulseTime)  % time between executions
%     set(tmr, 'ExecutionMode','fixedRate','TasksToExecute',2)  % instead of singleShot, execute twice with a fixed spacing
%     set(tmr, 'StartFcn', 'tic')
%     set(tmr, 'BusyMode', 'queue')
    
    % check for OpenGL
    AssertOpenGL;
    
    % Open the screen
    scanparams.display = openScreen(scanparams.display);
    
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
    keylist(KbName('NumLockClear')) = 0;  % ignore this extra response that comes with some tenkeys
    %keylist(KbName('\|')) = 0;
    KbQueueCreate(scanparams.display.devices.keyInputExternal,keylist);
    
    % wait for go signal
    pressKey2Begin(scanparams.display,0);
    
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
        gotime = startExptTime + params.preStimBase + (trialNum-1)*(params.stimLength+params.RT) + sum(params.ITIs(1:trialNum-1));
        %trialgotime = gotime - startExptTime
        
        % Load in trialInfo, which has .seq and .seqtiming
        curTrialPath = fullfile(savedTrialsDir,['trial_' num2str(trialNum) '.mat']);
        %tic
        load(curTrialPath);  % loads in trialInfo for this particular trial
        
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
        % Fixation sequence; ones just to keep red fixation, for now
        trialInfo.fixSeq = ones(size(trialInfo.seq));
        
        %     % Other color of fixation for fixation task
        %     nn = floor(4/(stimLength+ISItime)); % on average every 4 seconds [max response time = 3 seconds]
        %     trialInfo.fixSeq = ones(nn,1)*round(rand(1,ceil(length(trialInfo.seq)/nn)));
        %     trialInfo.fixSeq = trialInfo.fixSeq(:)+1;
        %     trialInfo.fixSeq = trialInfo.fixSeq(1:length(trialInfo.seq));
        %     % force binary
        %     trialInfo.fixSeq(trialInfo.fixSeq>2)=2;
        %     trialInfo.fixSeq(trialInfo.fixSeq<1)=1;
        
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
        
        % Get TMS pulse delay (SOA)
        tokens = parseString(trialInfo.conditionName,'_');
        delayToken = parseString(tokens{4},'-');
        TMSdelay = str2num(delayToken{2});
        
        % Pulse before trial onset?
        if isempty(TMSdelay)  % then it wasn't a number, so assume negative
            delayTokenNeg = parseString(delayToken{2},'n');
            negdelay = (str2num(delayTokenNeg{1}))/1000;
            WaitSecs('UntilTime',gotime-negdelay);
            err=DaqDConfigPort(deviceInd,0,0); %err=DaqDConfigPort(device,port,direction) % port = 0 direction = 0
            err=FastDaqDout(deviceInd,0,255-2);  % triggers pulse # 1
            negTMSpulseTime = GetSecs;
            WaitSecs('UntilTime',gotime-negdelay+doublePulseTime);
            err=DaqDConfigPort(deviceInd,0,0); %err=DaqDConfigPort(device,port,direction) % port = 0 direction = 0
            err=FastDaqDout(deviceInd,0,255-2);  % triggers pulse # 2
            TMSdelay = -negdelay;
       %     set(tmr,'TasksToExecute',0)  % don't execute TMS pulses in TMSshowTrial
        else
            TMSdelay = TMSdelay/1000;  % secs to ms
%            set(tmr,'StartDelay',TMSdelay)  % time to pulse after start(tmr) command (in TMSshowTrial)
        end
        
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
        if TMSdelay<0, TMSpulseTimes(trialNum,1)=negTMSpulseTime-GetSecs; TMSpulseTimes(trialNum,2)=0, end
        [quitProg,timeStartTrial,pulseTime] = TMSshowTrial(trialInfo, scanparams.display, quitProgKey, TMSdelay, doublePulseTime, quitProg);
        if ~isempty(pulseTime), TMSpulseTimes(trialNum,:)=pulseTime, end
        timeposttrial = GetSecs;
        trialtime = timeposttrial-timepretrial;  %remove semicolon to output
        
        %% Switch to fixation, then wait for RT, which is the extra time given for a subject response after stimulus is off.
        % It is also the minimum ITI.
        drawFixation(scanparams.display,1);
        Screen('Flip', scanparams.display.windowPtr);
        Screen('Close');
        
        
        %% Clear the current textures to free up memory
        trialInfo.textures = [];
        
        if quitProg, break, end
    end
    
    if ~quitProg  % don't want to wait if user just quit
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
%    delete(tmr);
    rethrow(lasterror)
end

try  % if running from a different user, saving may not work due to permissions
    % Save out the response data
    savedDataDir = [fileparts(savedTrialsDir) '/Data'];
    if ~exist(savedDataDir,'dir'), mkdir(savedDataDir), end;
    if ~isfield(params,'scanNumber'), params.scanNumber = 'NA'; end
    savedResponsesFile = fullfile(savedDataDir,[subjID '_' datestr(now,'dd.mm.yyyy-HH.MM') '_scan' num2str(params.scanNumber') '_savedResponses.mat']);
    save(savedResponsesFile,'ssResponses','ssRTs','doublePulseTime','TMSpulseTimes');  % this is the raw data, will make calculations below
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
