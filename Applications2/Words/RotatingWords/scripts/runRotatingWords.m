function theData = runRotatingWords(thePath,subID)
% Rotating Words experiment for ECoG
% Initiate from RotatingWords
% amr 10/20/08


%% Expt parameters (in secs)
stimDur = 0.160;
ISI = 1.840;

%% Get keyboard number
[k pauseKey quitKey resumeKey] = getKeyboardOr10key;
quitProg = 0;  %flag to see if user quit

%% Screen stuff

% check for OpenGL
AssertOpenGL;
% Initialize screen
[Window,Rect] = initializeScreen;

%% Print a loading screen
DrawFormattedText(Window, 'Loading images -- the experiment will begin shortly','center','center',255);
Screen('Flip',Window);

%% Load the images according to the stims in stimDir
cd(thePath.stim);
stimList = dir('*.bmp');
nStim = length(stimList);

stimOrder = [1:nStim];
for n = 1:nStim
    try
        pic = imread(stimList(n).name);
    catch
        fprintf(['\n' stimList(n).name ' unreadable\n']);
        stimOrder = setdiff(stimOrder,n); % remove this image from list
    end
end
stimOrder = Shuffle(stimOrder);

% How many trials?
nTrials = length(stimOrder);

%% Turn into textures
for n = 1:nTrials
    picNum = stimOrder(n);
    picName = stimList(picNum).name; % This is the filename of the image
    pic = imread(picName,'bmp');
    picPtrs(n) = Screen('MakeTexture',Window,pic);
    DrawFormattedText(Window,['Loading ' num2str(n)],'center','center',255);
    Screen('Flip',Window);
end

%% Initialize theData struct
for trial = 1:nTrials
    theData(trial).keys = [];
    theData(trial).RT = [];
    theData(trial).kinfo = [];
    theData(trial).ISI_keys = [];
    theData(trial).ISI_RT = [];
    theData(trial).stimName = stimList(stimOrder(trial)).name;
end

%% Set fixation
cd(thePath.util);
pic = imread('fix.jpg','jpg');
fixPtr = Screen('MakeTexture',Window,pic);


%% Set trigger square rect and dur
trigRect = [Rect(3)*0.97 Rect(4)*0.95 Rect(3) Rect(4)]; 
trigDur = 0.010;

boundBox = [Rect(3)*0.15 Rect(4)*0.15 Rect(3)*0.85 Rect(4)*0.85];


cd(thePath.data);

%% Print a ready screen and wait for a keypress to start photodiode
DrawFormattedText(Window, 'Ready! Press R to begin','center','center',255);
Screen('Flip',Window);
getKey(resumeKey,k);

% Set Priority
Priority(MaxPriority(Window));

%% Flashing start sequence
flinit = flinitseq(Window,trigRect);

% Wait for key press to start
Screen('FillRect',Window,0);
DrawFormattedText(Window, 'Get Ready!  Press any key to start.','center','center',255); 
Screen('Flip',Window);
pause; % wait for a keypress to close the screen

Screen(Window,'FillRect', 255, boundBox); %  white bounding box around stimulus
Screen('DrawTexture',Window,fixPtr); % Black fixation
flip.endStimVBLstamp = Screen('Flip',Window);
WaitSecs(2);

%% Do the trials
for trial = 1:nTrials
    % BREAK TIME
    %     if mod(trial,13)==0 % this would be a break every 2.5 minutes
    %         kmPause(k,resumeKey,Window);
    %     end
%     if picPtrs(trial) == 0
%         continue
%     end

    %tic
    Screen(Window,'FillRect', 255, trigRect); %  ***** TRIGGER *******
    Screen(Window,'FillRect', 255, boundBox); %  white bounding box around stimulus
    Screen('DrawTexture',Window,picPtrs(trial));
    [flip.VBLTimestamp flip.StimulusOnsetTime flip.FlipTimestamp flip.Missed flip.Beampos] = Screen('Flip',Window);
    [keys RT kinfo] = qkeys(flip.VBLTimestamp,stimDur,k);
    if strcmp(keys(1),pauseKey) % PAUSE EXPT
        quitProg = kmPause(k,resumeKey,quitKey,Window);
    end
    if quitProg, break, end
    theData(trial).keys = keys;
    theData(trial).RT = RT;
    theData(trial).kinfo = kinfo;

    Screen(Window,'FillRect', 255, boundBox); %  white bounding box around stimulus
    Screen('DrawTexture',Window,fixPtr); % Black fixation
    flip.endStimVBLstamp = Screen('Flip',Window);
    [keys RT kinfo] = qKeys(flip.endStimVBLstamp,ISI,k);
    if strcmp(keys(1),pauseKey) % PAUSE EXPT
        quitProg = kmPause(k,resumeKey,quitKey,Window);
    end
    if quitProg, break, end
    
    % VERY IMPORTANT NOTE: ISI_RT is the RT from onset of ISI time (flip.endStimVBLstamp)
    % ** final RT = [(flip.endStimVBLstamp - flip.VBLTimestamp) + ISI_RT ]
    theData(trial).ISI_keys = keys;
    theData(trial).ISI_RT = RT;
    theData(trial).kinfo = kinfo;
    theData(trial).flip = flip;
        
    flip = [];
    
    % save a new file every minute
    cmd = ['save rotWordsData.' subID '.' DATESTR(now,'dd.mm.yyyy.HH.MM') '.mat;'];
    eval(cmd);
    %toc
end

if quitProg
    fprintf('User quit.\n')
end
% Draw a blank screen
Screen('FillRect',Window,0); % 0=black
Screen('Flip',Window);

% Save the data
cd(thePath.data);
cmd = ['save rotWordsData.' subID '.' DATESTR(now,'dd-mm-yyyy-HH-MM') '.mat;'];
eval(cmd);
fprintf('\n\nData saved to %s\n\n',thePath.data)

% Print a goodbye screen
if ~quitProg
    Screen('FillRect',Window,0);
    DrawFormattedText(Window, 'Thanks! Press any key to exit','center','center',255);
    Screen('Flip',Window);
    pause; % wait for a keypress to close the screen
else
    Screen('FillRect',Window,0);
    DrawFormattedText(Window, 'User quit','center','center',255);
    Screen('Flip',Window);
    WaitSecs(1);
end

Priority(0);
clear screen
Screen('CloseAll');
ShowCursor;

