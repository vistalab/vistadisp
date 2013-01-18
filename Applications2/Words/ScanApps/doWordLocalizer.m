function doWordLocalizer
%
% Runs a word form ("VWFA") localizer.  This localizer uses a block design
% and allows you to adjust the block length and stimulus length by
% adjusting the first few parameters.  The stimuli are saved images of
% words with or without phase scrambling, as well as checkerboards.
%
%       doWordLocalizer
%
% written: amr 2008-09-19
%
% With 2 sec TR, nframes = 90 as currently set (Jan 4, 2010)
%
% USER SPECIFIC variables (these may need to be edited): 
%   baseDir
%   scanparams.display 

%% PARAMETERS
% baseDir = '/Users/Shared/ScanData/WordLocalizer'; % directory that contains stim folder with stimuli
        % Note that the stim folder must have "noScramble" and "scramble"
        % folders within them that contain the stimulus pictures.
        % Checkerboard stimulus is in the stim directory also.
baseDir = fullfile(vistastimRootPath, 'localizers', 'wordLocalizerStim');

% Block Parameters (in seconds)
blockLength = 12;                           % usually 12
fixLength = 12;  % between stimulus blocks  % usually 12
stimLength = 0.4;
ISItime = 0.1;
blankColor = 128;  % ISI uniform color e.g. 128 for gray

fliphorizontal = 0;

% Set your condition names here
condA = 'Word';             % no phase scramble
condB = 'WordScramble';     % very high phase-scrambled word (not recognizable)
condC = 'Checkerboard';     % alternating contrast

%% BLOCK ORDERING

autoChooseBlocks = 1;  % flag to choose block order based on session number (that user enters)

% If you don't have autoChooseBlocks on, then you can set your block order here

blockOrder = 'ABABAB';   %run1 for reflex epilepsy
% blockOrder = 'BABABA'; %run2
% blockOrder = 'CBABCA'; %run3

% Dummy block is an additional block BEFORE the beginning of your normal blocks.
dummyBlockType = 'B';  % A,B,C, or []  ([] if you don't want a dummy block)
%dummyBlockType = 'A'; %run 2
%dummyBlockType = 'B'; %run 3

%% CHECK VALIDITY OF PARAMETERS

stimsPerBlock = blockLength/(stimLength+ISItime);
if round(stimsPerBlock) ~= stimsPerBlock
    sprintf('%s', 'Your stimuli do not divide evenly into your block length.  Please change the parameters.')
    return
end

%% GET SUBJECT AND DATE INFORMATION AND AUTO-ORDER BLOCKS

fprintf('\n\n');
subjInitials = input('Subject Initials:  ','s');
sessionNum = input('Session number:  ','s');
%dateToday = input('Date (yymmdd):  ','s');
logFile = fullfile(baseDir,'data',[subjInitials '_' 'session' sessionNum '_' datestr(now,'dd.mm.yyyy.HH.MM') '_' 'savedVariables.mat']); % this is the file you will save all variables to

if autoChooseBlocks
    if sessionNum == '1'
        blockOrder = 'CBACBA'; % run1 with checkerboards
        %blockOrder = 'ABABAB';  % run1 w/o checkerboards
        dummyBlockType = 'A';  % with checkerboards
        %dummyBlockType = 'B';   % no checkerboards
        scrambleBlockNum = 0;  % starting stim directory is n+1;
        noScrambleBlockNum = 0;
    elseif sessionNum == '2'
        blockOrder = 'ABCABC'; % run2 with checkerboards
        %blockOrder = 'BABABA';  % run2 no checkerboards
        dummyBlockType = 'B';
        scrambleBlockNum = 2;  % starting stim directory is n+1;  change to 3 if not using checkerboards
        noScrambleBlockNum = 2;
    elseif sessionNum == '3'
        blockOrder = 'BCAACB'; % run3 with checkerboards
        %blockOrder = 'AABBAB';  % run3 no checkerboards
        dummyBlockType = 'C';
        scrambleBlockNum = 4;  % starting stim directory is n+1;  change to 5 if not using checkerboards
        noScrambleBlockNum = 4;
    elseif sessionNum == '4'
        blockOrder = 'CABBAC'; % run3 with checkerboards
        %blockOrder = 'AABBAB';  % run3 no checkerboards
        dummyBlockType = 'A';
        scrambleBlockNum = 6;  % starting stim directory is n+1;  change to 5 if not using checkerboards
        noScrambleBlockNum = 6;
    end
end

numBlocks = length(blockOrder);
parFileName = ['VWFALocalizer' num2str(sessionNum) '_' subjInitials '_' datestr(now,'ddmmyyyy_HH-MM') '.par'];
parFilePath = fullfile(baseDir,'parfiles',parFileName);

%% MAKE PARFILE VARIABLE
% should make it possible to read in a parfile as well

for parIndex = 1:2:(2*length(blockOrder))         % go by 2s because block is always paired with fixation
    % Fixation block
    par.onset(parIndex) = (floor(parIndex/2)) * (fixLength + blockLength);
    par.cond(parIndex) = 0;
    par.label{parIndex} = 'Fix';

    % Stimulus block
    par.onset(parIndex+1) = (floor(parIndex/2)) * (fixLength + blockLength) + fixLength;
    switch blockOrder(ceil(parIndex/2))
        case 'A'
            par.cond(parIndex+1) = 3;
            par.label{parIndex+1} = condA;
        case 'B'
            par.cond(parIndex+1) = 2;
            par.label{parIndex+1} = condB;
        case 'C'
            par.cond(parIndex+1) = 1;
            par.label{parIndex+1} = condC;
    end
end   
% add fixation to end
par.onset(end+1)=par.onset(end)+blockLength;
par.cond(end+1)=0;
par.label{end+1}='Fix';

%% ASSIGN STIMULI (STIMULUS FILE NAMES) TO BLOCKS

noScrambleStimDirBase = fullfile(baseDir,'stim','noScramble');

scrambleStimDirBase = fullfile(baseDir,'stim','scramble');

checkerStimFile = fullfile(baseDir,'stim','check.bmp');

revcheckerStimFile = fullfile(baseDir,'stim','revcheck.bmp');

% dummy block
if ~isempty(dummyBlockType)
    dummyInfo.condition = dummyBlockType;
    switch dummyBlockType
        case 'A',   dummyInfo.conditionName = 'word';
            noScrambleBlockNumD = 8;  % always use set 8 for dummy
            noScrambleStimDir = fullfile(noScrambleStimDirBase,['set' num2str(noScrambleBlockNumD)]);
            dummyInfo.stimulusList = randomizeStims2Block(noScrambleStimDir,stimsPerBlock);
        case 'B',   dummyInfo.conditionName = 'wordScramble';
            scrambleBlockNumD = 8;  % always use set 8 for dummy
            scrambleStimDir = fullfile(scrambleStimDirBase,['set' num2str(scrambleBlockNumD)]);
            dummyInfo.stimulusList = randomizeStims2Block(scrambleStimDir,stimsPerBlock);
        case 'C',   dummyInfo.conditionName = 'checkerboard';
            % alternate checkerboard and "reverse" checkerboard
            for ii = 1:2:stimsPerBlock
                dummyInfo.stimulusList{ii} = checkerStimFile;
            end
            for ii = 2:2:stimsPerBlock
                dummyInfo.stimulusList{ii} = revcheckerStimFile;
            end
        otherwise,  sprintf('%s','Dummy condition (dummyBlockType) not recognized, please correct.'), return;
    end
else
    dummyInfo = [];  % No dummy block information because there is no dummy block
end

% experimental blocks
for blockIndex = 1:length(blockOrder)  % for each block
    blockInfo{blockIndex}.condition = blockOrder(blockIndex);  % get the condition type
    switch blockInfo{blockIndex}.condition  % depending on condition type, get condition name and assign stimuli
        case 'A',   blockInfo{blockIndex}.conditionName = 'word';
            noScrambleBlockNum = noScrambleBlockNum+1;
            noScrambleStimDir = fullfile(noScrambleStimDirBase,['set' num2str(noScrambleBlockNum)]);
            blockInfo{blockIndex}.stimulusList = randomizeStims2Block(noScrambleStimDir,stimsPerBlock);
        case 'B',   blockInfo{blockIndex}.conditionName = 'wordScramble';
            scrambleBlockNum = scrambleBlockNum+1;
            scrambleStimDir = fullfile(scrambleStimDirBase,['set' num2str(scrambleBlockNum)]);
            blockInfo{blockIndex}.stimulusList = randomizeStims2Block(scrambleStimDir,stimsPerBlock);
        case 'C',   blockInfo{blockIndex}.conditionName = 'checkerboard';
            for ii = 1:2:stimsPerBlock
                blockInfo{blockIndex}.stimulusList{ii} = checkerStimFile;
            end
            for ii = 2:2:stimsPerBlock
                blockInfo{blockIndex}.stimulusList{ii} = revcheckerStimFile;
            end
        otherwise,  sprintf('%s%s','Condition ',(blockInfo{blockIndex}.condition),'not recognized, please correct.'), return;
    end
end

%% SCREEN AND KEYBOARD STUFF

% %To run on an external monitor for testing, although the projector params seem to work fine too.
%scanparams.display = loadDisplayParams('displayName', 'NEC485words.mat');%('builtin');%'tenbit');
% %To run at the scanner
scanparams.display = loadDisplayParams('displayName', 'cni_lcd');
%scanparams.display = loadDisplayParams('displayName', 'NEC485words.mat');%('builtin');%'tenbit');
scanparams.display.fixColorRgb = [255 0 0 255; 0 0 255 255; 255 255 255 0];

screens=Screen('Screens'); % find the number of screens 
scanparams.display.screenNumber = max(screens); % put this on the highest number screen
                                                % (0 is the 1st screen)                     
scanparams.runPriority = 9;
scanparams.startScan = 0;
scanparams.display.devices = getDevices;  % in display so we can pass it along with that strucs

% check for OpenGL
AssertOpenGL;

% Open the screen
scanparams.display                = openScreen(scanparams.display);

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

% instruction screen
showWordLocalizerInstructions(scanparams.display.windowPtr);  % function is at the end of this function

% wait for go signal
pressKey2Begin(scanparams.display);

% countdown + get start time (time0)
[startExptTime] = countDown(scanparams.display,scanparams.startScan+2,scanparams.startScan, 'computer triggers scanner');
startBlockTime = startExptTime;  % Let's keep startExptTime to refer to it later, and have a separate variable keep timing for each block.


%% LOAD AND SHOW DUMMY BLOCK
% The first block shown can often have high activation, both due to the
% scanner, as well as possible attentional effects in the subject. To let
% the subject "settle in" first, use a dummy block.
if ~isempty(dummyBlockType)
    %Show fixation
    drawFixation(scanparams.display,1);
    Screen('Flip', scanparams.display.windowPtr);
    
    %Load dummy block images
    for stimNum = 1:stimsPerBlock
        dummyInfo.images{stimNum} = imread(dummyInfo.stimulusList{stimNum});
    end
    blankFrame = uint8(ones(size(dummyInfo.images{1})).*blankColor); % gray blank frame
    dummyInfo.images{end+1} = blankFrame;
    
    % Interleave your sequence of stimuli with blank frames (last image)
    dummyInfo.seq = ones(2,(length(dummyInfo.images)-1)).*length(dummyInfo.images);
    dummyInfo.seq(1,:) = 1:(length(dummyInfo.images)-1); % play all frames except blank ISI in order
    dummyInfo.seq = dummyInfo.seq(:);  % interleave
    dummyInfo.seq = dummyInfo.seq';    % proper formatting
    
    % Do something very similar for seqtiming, which specifies the end time
    % of each image
    dummyInfo.seqtiming = ones(2,(length(dummyInfo.images)-1)) .* (stimLength+ISItime);
    dummyInfo.seqtiming(2,:) = (1:(length(dummyInfo.images)-1)) .* (stimLength+ISItime);  %ISI timing
    dummyInfo.seqtiming(1,:) = (1:(length(dummyInfo.images)-1)) .* (stimLength+ISItime);  %stim timing
    dummyInfo.seqtiming(1,:) = dummyInfo.seqtiming(1,:) - ISItime;                        %more stim timing
    dummyInfo.seqtiming = dummyInfo.seqtiming(:);  % interleave
    dummyInfo.seqtiming = dummyInfo.seqtiming';  % proper formatting
    
    % Fixation sequence; ones just to keep red fixation
    dummyInfo.fixSeq = ones(size(dummyInfo.seq));
    % Other fixation colors
    nn = floor(4/(stimLength+ISItime)); % on average every 4 seconds [max response time = 3 seconds]
    dummyInfo.fixSeq = ones(nn,1)*round(rand(1,ceil(length(dummyInfo.seq)/nn)));
    dummyInfo.fixSeq = dummyInfo.fixSeq(:)+1;
    dummyInfo.fixSeq = dummyInfo.fixSeq(1:length(dummyInfo.seq));
    % force binary
    dummyInfo.fixSeq(dummyInfo.fixSeq>2)=2;
    dummyInfo.fixSeq(dummyInfo.fixSeq<1)=1;
    
    % Some other parameters we need to specify the size of the image
    dummyInfo.imSize = size(dummyInfo.images{1});
    dummyInfo.imSize = dummyInfo.imSize([2 1]);
    
    % Not sure what this is about.
    dummyInfo.srcRect = [];
    dummyInfo.cmap = [];
    
    % Center the output display rectangle
    c = scanparams.display.numPixels/2;
    tl = round([c(1)-dummyInfo.imSize(1)/2 c(2)-dummyInfo.imSize(2)/2]);
    dummyInfo.destRect = [tl tl+dummyInfo.imSize(1:2)];
    
    % Flip left-right if requested
    if fliphorizontal
        for imagenum = 1:length(dummyInfo.images)
           dummyInfo.images{imagenum} = fliplr(dummyInfo.images{imagenum}); 
        end
    end
    
    % Convert images into PTB textures
    dummyInfo = makeTextures(scanparams.display,dummyInfo);
    
    % Wait until end of fixation (we've used up some of the time (about
    % 0.05 secs since start of expt) doing the above commands)
    WaitSecs('UntilTime',(startBlockTime+fixLength));

    %Show dummy block
    tic
    [dummyresponse, timing, quitProg] = showScanBlock_noTrialStruct(scanparams.display,dummyInfo);
    %quitProg = showScanBlock(scanparams.display,dummyInfo,quitProgKey);
    toc
    if ~quitProg
        sprintf('%s','Just showed a dummy block. Starting experiment now.')
    end

    %Clear dummy textures to clear up memory
    dummyInfo.textures = [];

    % check if user quit yet
    if quitProg
        Screen('CloseAll');
        Priority(0);
        ShowCursor;
        return
    end
else
    dummyInfo = [];
end

%% LOAD AND SHOW EXPERIMENT BLOCKS -- same as for the dummy block, except in a for loop for each block

for blockNum = 1:numBlocks
    
    % Get timing
    startBlockTime = GetSecs;
    
    %Show fixation
    drawFixation(scanparams.display,1);
    Screen('Flip', scanparams.display.windowPtr);
    
    %Load the next block
    for stimNum = 1:stimsPerBlock
        blockInfo{blockNum}.images{stimNum} = imread(blockInfo{blockNum}.stimulusList{stimNum});
    end
    if blockNum == 1  % only need to load the blankFrame once
        blankFrame = uint8(ones(size(blockInfo{1}.images{1})).*blankColor); % gray blank frame
    end
    blockInfo{blockNum}.images{end+1} = blankFrame;

    % Interleave your sequence of stimuli with blank frames (last image)
    blockInfo{blockNum}.seq = ones(2,(length(blockInfo{blockNum}.images)-1)).*length(blockInfo{blockNum}.images);
    blockInfo{blockNum}.seq(1,:) = 1:(length(blockInfo{blockNum}.images)-1); % play all frames except blank ISI in order
    blockInfo{blockNum}.seq = blockInfo{blockNum}.seq(:);  % interleave
    blockInfo{blockNum}.seq = blockInfo{blockNum}.seq';    % proper formatting
    
    % Do something very similar for seqtiming, which specifies the end time
    % of each image
    blockInfo{blockNum}.seqtiming = ones(2,(length(blockInfo{blockNum}.images)-1)) .* (stimLength+ISItime);
    blockInfo{blockNum}.seqtiming(2,:) = (1:(length(blockInfo{blockNum}.images)-1)) .* (stimLength+ISItime);  %ISI timing
    blockInfo{blockNum}.seqtiming(1,:) = (1:(length(blockInfo{blockNum}.images)-1)) .* (stimLength+ISItime);  %stim timing
    blockInfo{blockNum}.seqtiming(1,:) = blockInfo{blockNum}.seqtiming(1,:) - ISItime;                        %more stim timing
    blockInfo{blockNum}.seqtiming = blockInfo{blockNum}.seqtiming(:);  % interleave
    blockInfo{blockNum}.seqtiming = blockInfo{blockNum}.seqtiming';  % proper formatting
    
    % Fixation sequence; ones just to keep red fixation
    blockInfo{blockNum}.fixSeq = ones(size(blockInfo{blockNum}.seq));
    
    % Other color of fixation for fixation task
    nn = floor(4/(stimLength+ISItime)); % on average every 4 seconds [max response time = 3 seconds]
    blockInfo{blockNum}.fixSeq = ones(nn,1)*round(rand(1,ceil(length(blockInfo{blockNum}.seq)/nn)));
    blockInfo{blockNum}.fixSeq = blockInfo{blockNum}.fixSeq(:)+1;
    blockInfo{blockNum}.fixSeq = blockInfo{blockNum}.fixSeq(1:length(blockInfo{blockNum}.seq));
    % force binary
    blockInfo{blockNum}.fixSeq(blockInfo{blockNum}.fixSeq>2)=2;
    blockInfo{blockNum}.fixSeq(blockInfo{blockNum}.fixSeq<1)=1;

    % Some other parameters we need to specify the size of the image
    blockInfo{blockNum}.imSize = size(blockInfo{blockNum}.images{1});
    blockInfo{blockNum}.imSize = blockInfo{blockNum}.imSize([2 1]);

    % Not sure what this is about.
    blockInfo{blockNum}.srcRect = [];
    blockInfo{blockNum}.cmap = [];
    
    % Center the output display rectangle
    c = scanparams.display.numPixels/2;
    tl = round([c(1)-blockInfo{blockNum}.imSize(1)/2 c(2)-blockInfo{blockNum}.imSize(2)/2]);
    blockInfo{blockNum}.destRect = [tl tl+blockInfo{blockNum}.imSize(1:2)];
    
    % Flip left-right if requested
    if fliphorizontal
        for imagenum = 1:length(blockInfo{blockNum}.images)
            blockInfo{blockNum}.images{imagenum} = fliplr(blockInfo{blockNum}.images{imagenum});
        end
    end
    
    % Convert images into PTB textures
    blockInfo{blockNum} = makeTextures(scanparams.display,blockInfo{blockNum});
    
    % Wait until end of fixation (we've used up some of the time (about
    % 0.05 secs since start of expt) doing the above commands)
    WaitSecs('UntilTime',(startBlockTime+fixLength));
    
    %Show the block's stimuli
    tic
    [responses{blockNum}, timing, quitProg] = showScanBlock_noTrialStruct(scanparams.display,blockInfo{blockNum});
    %[quitProg,responses{blockNum},responseRTs{blockNum}] = showScanBlock(scanparams.display,blockInfo{blockNum},quitProgKey);
    toc
    
    %Clear textures (make sure we don't need to save anything here)
    blockInfo{blockNum}.textures = [];
    
    %Check if user quit
    if quitProg,
        Screen('CloseAll');
        Priority(0);
        ShowCursor;
        return, 
    end
end

%% Show another fixation at the end (unless user quit)
if ~quitProg
    drawFixation(scanparams.display,1);
    Screen('Flip', scanparams.display.windowPtr);
    timeNow = GetSecs;
    gotime = timeNow + fixLength; %show it for blankLength secs
    Screen('Close'); %close the off-screen window
    WaitSecs('UntilTime',gotime);
end

endExptTime = GetSecs;
exptLength = endExptTime - startExptTime;
fprintf('\n%s%0.2f%s\n','Total experiment length:  ', exptLength, ' seconds');

%% GET FIXATION PERFORMANCE FOR ALL BLOCKS
fixParams.task = 'Detect fixation change';  % something that getFixationPerformance needs
fixParams.responseTime = [0.05 2]; % % look for responses between .05 and 2 seconds after stimulus change
for blockNum = 1:numBlocks
    stimulus.fixSeq = blockInfo{blockNum}.fixSeq;
    stimulus.seqtiming = zeros(size(blockInfo{blockNum}.seqtiming));
    stimulus.seqtiming(2:end) = blockInfo{blockNum}.seqtiming(1:end-1); % correct for different use of seqtiming in Serge's code
    [blockInfo{blockNum}.fixTaskPercentCorrect,blockInfo{blockNum}.fixTaskRT] = getFixationPerformance(fixParams,stimulus,responses{blockNum});
end

%% SAVE VARIABLES TO A FILE FOR EXPERIMENTAL INFO AND WRITE OUT PARFILE
save(logFile,'dummyInfo','blockInfo','blockLength','fixLength','stimLength','ISItime','stimsPerBlock', 'responses');
writeParfile(par,parFilePath);
fprintf('\n%s\n%s\n','Saved variables (information about block structure/stimuli to:  ', logFile);
fprintf('\n%s\n%s\n','Saved parfile to:  ', parFilePath);

%% RESET PRIORITY AND SCREEN
Screen('Close');
Screen('CloseAll');
Priority(0);
ShowCursor;
return


function showWordLocalizerInstructions(Window)
% Shows instructions to subject before start of scan

% Set fonts
Screen('TextFont',Window,'Times');
Screen('TextSize',Window,25);
Screen('FillRect', Window, 0);  % 0 = black background

DrawFormattedText(Window, 'Press button when fixation dot changes color.','center','center',255);
Screen('Flip',Window);
pause;
