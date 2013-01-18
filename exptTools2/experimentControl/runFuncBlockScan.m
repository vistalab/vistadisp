function runFuncBlockScan(ScanName,params,conds,blockOrder,dummyBlockType,baseDir,autoChooseBlocks,stimChooseAlgorithm,preloadBlockFlag)

% General script to run a block design fMRI experiment.
% Allows you to adjust the block length and stimulus length by
% adjusting the first few parameters.  The stimuli should be saved in a
% separate directory for each condition.
%
% There should be different ways of choosing your stimuli.
% Right now we assume a fixation change detection task (no ability to have
% 1-back task like in original KGS localizers). stimChooseAlgorithm can be
% either "random", in which case it will randomly choose stimuli for each
% block from the directory with the name of that block's condition, or it
% can be "list_whatever", in which case it will look for a txt file in the
% stim directory called whateverSESSIONNUM.txt.  In this case, it is essential that
% stimChooseAlgorithm starts with "list_" and ends with whatever the text
% file is called (without the .txt extension and without the run number)!
%
% Eventually it would be nice to have a GUI that shows your experiment
% parameters and conditions (maybe with example stimuli?).  You will be
% able to load experiments, save experiments, change parameters, save out
% .par files, etc.  And I want a big button that says "Scan" (and maybe one
% that says "Test Run" (for testing outside the scanner).
%
% To see one way of running this code, see verbGeneration.m
%
%       runFuncBlockScan(ScanName,params,conds,blockOrder,[dummyBlockType],[baseDir],[autoChooseBlocks=0],[stimChooseAlgorithm='random'],[preloadBlockFlag=0])
%
% written: amr 2008-09-23
%
% July 29, 2009:  amr:  allow field of params to be initFix and postFix--
% can be different than regular fixation length.  Note that initFix only
% is used if you have a dummy block (i.e. initFix is the fixation that
% corresponds to, or comes directly before, the dummy block).
% Aug 4, 2009:  amr:  dummyBlockType can now be 'Fix', which means that
% initFix will be used as a dummy fixation (without corresponding stimulus
% block)
% Aug 6, 2009:  amr:  fixed bug that caused parfiles not to be written
% properly when fixLength=0
% Spet 14, 2009:  amr:  allow different stimOrder txt file names by having
% stimChooseAlgorithm contain the txt file name (e.g. stimChooseAlgorithm =
% 'list_yourFileName' will use yourFileName.txt located in stim directory).
%  Old stimOrder.txt files, with stimChooseAlgorithm being 'list', should
%  still work.
%

%% PARAMETERS
if isfield(params,'fixationPixelSize')
    fixationPixelSize = params.fixationPixelSize;
else
    fixationPixelSize = 1;
end

if notDefined('autoChooseBlocks'), autoChooseBlocks = 0; end
if notDefined('stimChooseAlgorithm'), stimChooseAlgorithm = 'random'; end

if notDefined('baseDir')
    baseDir = ['/Users/Shared/AndreasWordsMatlab/' ScanName]; % directory that contains stim folder with stimuli
    % Note that the stim folder must have "noScramble" and "scramble"
    % folders within them that contain the stimulus pictures.
    % Checkerboard stimulus is in the stim directory also.
end

if notDefined('preloadBlockFlag')
    preloadBlockFlag = 0;
end

% Block Parameters (in seconds)
blockLength = params.blockLength;
fixLength = params.fixLength;  % between stimulus blocks  % usually 12
stimLength = params.stimLength;
ISItime = params.ISItime;
blankColor = params.blankColor;  % ISI uniform color e.g. 128 for gray

% Set the condition names here (this with the blockOrder information is basically the parfile)
% amr note: would be best to choose these in a GUI
if isfield(conds,'A'), condA = conds.A; end
if isfield(conds,'B'), condB = conds.B; end
if isfield(conds,'C'), condC = conds.C; end
if isfield(conds,'D'), condD = conds.D; end
if isfield(conds,'E'), condE = conds.E; end
if isfield(conds,'F'), condF = conds.F; end
if isfield(conds,'G'), condG = conds.G; end
if isfield(conds,'H'), condH = conds.H; end

%% CHECK VALIDITY OF PARAMETERS

stimsPerBlock = blockLength/(stimLength+ISItime);
if round(stimsPerBlock) ~= stimsPerBlock %  (abs(round(stimsPerBlock)-stimsPerBlock)>0.0000001) %% sometimes rounding seems to create a problem, but it is indicative of timing problems later
    sprintf('%s', 'Your stimuli do not divide evenly into your block length.  Please change the parameters.')
    return
end

%% GET SUBJECT AND DATE INFORMATION AND AUTO-ORDER BLOCKS
% auto-ordering blocks is just taking pre-defined condition orders, and
% these are chosen based on the session number that user enters.

fprintf('\n\n');
subjInitials = input('Subject Initials:  ','s');
sessionNum = input('Session number:  ','s');
%dateToday = input('Date (yymmdd):  ','s');
logFile = fullfile(baseDir,'data',[subjInitials '_' 'session' sessionNum '_' datestr(now,'dd.mm.yyyy.HH.MM') '_' 'savedVariables.mat']); % this is the file you will save all variables to

if autoChooseBlocks
    switch ScanName  % different preset orders of stimuli for different scans
        
        case 'VerbGeneration'
            if sessionNum == '1'
                blockOrder = 'ABABAB' %run 1 of verbGeneration
                dummyBlockType = 'Fix'; %'C';  % fixation dummy block for verbGeneration
            elseif sessionNum == '2'
                blockOrder = 'BABABA' %run 2 of verbGeneration
                dummyBlockType = 'Fix'; %'A';
            elseif sessionNum == '3'
                error('Can only auto-generate 2 blockOrder sessions for verbGeneration')
            end
            
        case 'WordLocalizer'  % not currently used because doWordLocalizer doesn't use this script!
            if sessionNum == '1'
                blockOrder = 'ACBCAB' %run1 of doWordLocalizer
                dummyBlockType = 'C';  % fixation dummy block for verbGeneration
            elseif sessionNum == '2'
                blockOrder = 'BACABC' %run2 of doWordLocalizer
                dummyBlockType = 'A';
            elseif sessionNum == '3'
                blockOrder = 'CBABCA' %run3
                dummyBlockType = 'B';
            end
            
        case 'wordEccentricity'
            if sessionNum == '1'
                blockOrder = 'ABCDEABCDE' %run1 of wordEccentricity
                dummyBlockType = 'E';  % fixation dummy block for wordEccentricity
            elseif sessionNum == '2'
                blockOrder = 'EDCBAEDCBA' %run2 of wordEccentricity
                dummyBlockType = 'A';
            elseif sessionNum == '3'
                blockOrder = 'CEADBCEADB' %run3
                dummyBlockType = 'B';
            end
            
        otherwise
            if sessionNum == '1'
                blockOrder = 'ABABAB' %run 1 of verbGeneration
                % blockOrder = 'ACBCAB'; %run1 of doWordLocalizer
                dummyBlockType = 'Fix'; %'C';  % fixation dummy block for verbGeneration
            elseif sessionNum == '2'
                blockOrder = 'BABABA' %run 2 of verbGeneration
                %blockOrder = 'BACABC'; %run2 of doWordLocalizer
                dummyBlockType = 'Fix'; %'A';
            elseif sessionNum == '3'
                blockOrder = 'CBABCA' %run3
                dummyBlockType = 'B';
            end
    end
end

numBlocks = length(blockOrder);
parFileName = [ScanName '_' subjInitials '_' datestr(now,'ddmmyyyy_HH-MM') '_Sess' num2str(sessionNum) '.par'];
parFilePath = fullfile(baseDir,'parfiles',parFileName);


%% MAKE PARFILE VARIABLE
% should make it possible to read in a parfile as well

if fixLength>0
    for parIndex = 1:2:(2*length(blockOrder))         % go by 2s because block is always paired with fixation
        % Fixation block
        par.onset(parIndex) = (floor(parIndex/2)) * (fixLength + blockLength);
        par.cond(parIndex) = 0;
        par.label{parIndex} = 'Fix';
        
        % Stimulus block
        par.onset(parIndex+1) = (floor(parIndex/2)) * (fixLength + blockLength) + fixLength;
        switch blockOrder(ceil(parIndex/2))
            case 'A'
                par.cond(parIndex+1) = 1;
                par.label{parIndex+1} = condA;
            case 'B'
                par.cond(parIndex+1) = 2;
                par.label{parIndex+1} = condB;
            case 'C'
                par.cond(parIndex+1) = 3;
                par.label{parIndex+1} = condC;
            case 'D'
                par.cond(parIndex+1) = 4;
                par.label{parIndex+1} = condD;
            case 'E'
                par.cond(parIndex+1) = 5;
                par.label{parIndex+1} = condE;
            case 'F'
                par.cond(parIndex+1) = 6;
                par.label{parIndex+1} = condF;
            case 'G'
                par.cond(parIndex+1) = 7;
                par.label{parIndex+1} = condG;
            case 'H'
                par.cond(parIndex+1) = 8;
                par.label{parIndex+1} = condH;
        end
    end
    % one more fixation at the end (see later code)
    par.onset(parIndex+2) = (floor(parIndex/2)) * (fixLength + blockLength) + fixLength + blockLength; % add 1 more block length
    par.cond(parIndex+2) = 0;  % +2 because it is 2 past last parIndex
    par.label{parIndex+2} = 'Fix';
    
else  % Parfile variable in the special case of having no fixation blocks
    for parIndex = 1:length(blockOrder)
        % Stimulus block
        par.onset(parIndex) = (parIndex-1) * blockLength;
        switch blockOrder(parIndex)
            case 'A'
                par.cond(parIndex) = 1;
                par.label{parIndex} = condA;
            case 'B'
                par.cond(parIndex) = 2;
                par.label{parIndex} = condB;
            case 'C'
                par.cond(parIndex) = 3;
                par.label{parIndex} = condC;
            case 'D'
                par.cond(parIndex) = 4;
                par.label{parIndex} = condD;
            case 'E'
                par.cond(parIndex) = 5;
                par.label{parIndex} = condE;
            case 'F'
                par.cond(parIndex) = 6;
                par.label{parIndex} = condF;
            case 'G'
                par.cond(parIndex) = 7;
                par.label{parIndex} = condG;
            case 'H'
                par.cond(parIndex) = 8;
                par.label{parIndex} = condH;
        end
    end
    % you can have a postFix even if fixLength=0
    if isfield(params,'postFix')
        if params.postFix>0
            par.onset(parIndex+1) = (parIndex) * blockLength + blockLength; % add 1 more block length
            par.cond(parIndex+1) = 0;
            par.label{parIndex+1} = 'Fix';
        end
    end
end


%% ASSIGN STIMULI (STIMULUS FILE NAMES) TO BLOCKS

if ~notDefined('condA'), condAStimDir = fullfile(baseDir,'stim',condA); end
if ~notDefined('condB'), condBStimDir = fullfile(baseDir,'stim',condB); end
if ~notDefined('condC'), condCStimDir = fullfile(baseDir,'stim',condC); end
if ~notDefined('condD'), condDStimDir = fullfile(baseDir,'stim',condD); end
if ~notDefined('condE'), condEStimDir = fullfile(baseDir,'stim',condE); end
if ~notDefined('condF'), condFStimDir = fullfile(baseDir,'stim',condF); end
if ~notDefined('condG'), condGStimDir = fullfile(baseDir,'stim',condG); end
if ~notDefined('condH'), condHStimDir = fullfile(baseDir,'stim',condH); end

switch stimChooseAlgorithm(1:4)  % how to assign stimuli to blocks
    
    case 'rand'  % uses randomizeStims2Block
        % dummy block
        if ~isempty(dummyBlockType)
            dummyInfo.condition = dummyBlockType;
            switch dummyBlockType
                case 'A',   dummyInfo.conditionName = condA;
                    dummyInfo.stimulusList = randomizeStims2Block(condAStimDir,stimsPerBlock);
                case 'B',   dummyInfo.conditionName = condB;
                    dummyInfo.stimulusList = randomizeStims2Block(condBStimDir,stimsPerBlock);
                case 'C',   dummyInfo.conditionName = condC;
                    dummyInfo.stimulusList = randomizeStims2Block(condCStimDir,stimsPerBlock);
                case 'D',   dummyInfo.conditionName = condD;
                    dummyInfo.stimulusList = randomizeStims2Block(condDStimDir,stimsPerBlock);
                case 'E',   dummyInfo.conditionName = condE;
                    dummyInfo.stimulusList = randomizeStims2Block(condEStimDir,stimsPerBlock);
                case 'F',   dummyInfo.conditionName = condF;
                    dummyInfo.stimulusList = randomizeStims2Block(condFStimDir,stimsPerBlock);
                case 'G',   dummyInfo.conditionName = condG;
                    dummyInfo.stimulusList = randomizeStims2Block(condGStimDir,stimsPerBlock);
                case 'H',   dummyInfo.conditionName = condH;
                    dummyInfo.stimulusList = randomizeStims2Block(condHStimDir,stimsPerBlock);
                case 'Fix', dummyInfo.conditionName = 'Fix';
                    dummyInfo.stimulusList = [];
                otherwise,  sprintf('%s','Dummy condition (dummyBlockType) not recognized, please correct.'), return;
            end
        end
        
        % experimental blocks
        for blockIndex = 1:length(blockOrder)  % for each block
            blockInfo{blockIndex}.condition = blockOrder(blockIndex);  % get the condition type
            switch blockInfo{blockIndex}.condition  % depending on condition type, get condition name and assign stimuli
                case 'A',   blockInfo{blockIndex}.conditionName = condA;
                    blockInfo{blockIndex}.stimulusList = randomizeStims2Block(condAStimDir,stimsPerBlock);
                case 'B',   blockInfo{blockIndex}.conditionName = condB;
                    blockInfo{blockIndex}.stimulusList = randomizeStims2Block(condBStimDir,stimsPerBlock);
                case 'C',   blockInfo{blockIndex}.conditionName = condC;
                    blockInfo{blockIndex}.stimulusList = randomizeStims2Block(condCStimDir,stimsPerBlock);
                case 'D',   blockInfo{blockIndex}.conditionName = condD;
                    blockInfo{blockIndex}.stimulusList = randomizeStims2Block(condDStimDir,stimsPerBlock);
                case 'E',   blockInfo{blockIndex}.conditionName = condE;
                    blockInfo{blockIndex}.stimulusList = randomizeStims2Block(condEStimDir,stimsPerBlock);
                case 'F',   blockInfo{blockIndex}.conditionName = condF;
                    blockInfo{blockIndex}.stimulusList = randomizeStims2Block(condFStimDir,stimsPerBlock);
                case 'G',   blockInfo{blockIndex}.conditionName = condG;
                    blockInfo{blockIndex}.stimulusList = randomizeStims2Block(condGStimDir,stimsPerBlock);
                case 'H',   blockInfo{blockIndex}.conditionName = condH;
                    blockInfo{blockIndex}.stimulusList = randomizeStims2Block(condHStimDir,stimsPerBlock);
                otherwise,  sprintf('%s%s','Condition ',(blockInfo{blockIndex}.condition),'not recognized, please correct.'), return;
            end
        end
        
    case 'list'  % read from a textfile, located in the stim directory
        stimOrderFile = fullfile(baseDir,'stim',[stimChooseAlgorithm(6:end) num2str(sessionNum) '.txt']); % txt file should be called fileName.txt, and stimChooseAlgorithm should be list_fileName
        if ~exist(stimOrderFile,'file')
            stimOrderFile = fullfile(baseDir,'stim','stimOrder.txt');  % if you just need one txt file, it can be called stimOrder.txt and stimChooseAlgorithm is "list"
        end
        fid = fopen(stimOrderFile);
        col = textscan(fid,'%s');
        fclose(fid);
        stims = col{1};
        
        if ~isempty(dummyBlockType)
            dummyInfo.stimulusList = [];
            dummyInfo.condition = dummyBlockType;
            
            % assign stimuli (except to a fixation dummy)
            if ~strcmp(dummyBlockType,'Fix')
                for curstimNum = 1:stimsPerBlock
                    numInList = curstimNum;
                    curstim = stims{numInList};
                    % get the full directory for the file
                    condDirName = eval(['cond' num2str(dummyBlockType)]);
                    curstim = fullfile(baseDir,'stim',condDirName,curstim);
                    curstim = [curstim '.bmp'];
                    dummyInfo.stimulusList{curstimNum} = curstim;
                end
                dummyBlockFlag = 1;  % this will be used to calculate which stimuli to use from stimOrder list
            else
                dummyBlockFlag = 0;
            end
            
            % assign condition names
            switch dummyBlockType
                case 'A',   dummyInfo.conditionName = condA;
                case 'B',   dummyInfo.conditionName = condB;
                case 'C',   dummyInfo.conditionName = condC;
                case 'D',   dummyInfo.conditionName = condD;
                case 'E',   dummyInfo.conditionName = condE;
                case 'F',   dummyInfo.conditionName = condF;
                case 'G',   dummyInfo.conditionName = condG;
                case 'H',   dummyInfo.conditionName = condH;
                case 'Fix', dummyInfo.conditionName = 'Fix';
                otherwise,  sprintf('%s','Dummy condition (dummyBlockType) not recognized, please correct.'), return;
            end

        else  % no dummy block (because dummyBlockType is empty)
            dummyBlockFlag = 0;
        end
        
        % sanity check for having enough stimuli in stimOrder txt file
        if length(stims) < (stimsPerBlock*(numBlocks+dummyBlockFlag))
            error('Not enough stims specified in stimOrder file for number of stimuli required in experiment.')
        end
        
        for blockIndex = 1:length(blockOrder)
            for curstimNum = 1:stimsPerBlock
                numInList = curstimNum+((blockIndex-1)*stimsPerBlock)+ dummyBlockFlag*stimsPerBlock;
                curstim = stims{numInList};
                % get the full directory for the file
                condDirName = eval(['cond' num2str(blockOrder(blockIndex))]);
                curstim = fullfile(baseDir,'stim',condDirName,curstim);
                curstim = [curstim '.bmp'];
                blockInfo{blockIndex}.stimulusList{curstimNum} = curstim;
            end
            % get condition and condition name for this block
            blockInfo{blockIndex}.condition = blockOrder(blockIndex);
            switch blockInfo{blockIndex}.condition  % depending on condition type, get condition name and assign stimuli
                case 'A',   blockInfo{blockIndex}.conditionName = condA;
                case 'B',   blockInfo{blockIndex}.conditionName = condB;
                case 'C',   blockInfo{blockIndex}.conditionName = condC;
                case 'D',   blockInfo{blockIndex}.conditionName = condD;
                case 'E',   blockInfo{blockIndex}.conditionName = condE;
                case 'F',   blockInfo{blockIndex}.conditionName = condF;
                case 'G',   blockInfo{blockIndex}.conditionName = condG;
                case 'H',   blockInfo{blockIndex}.conditionName = condH;
                otherwise,  sprintf('%s%s','Condition ',(blockInfo{blockIndex}.condition),'not recognized, please correct.'), return;
            end
        end
end

%% SCREEN AND KEYBOARD STUFF

% %To run on an external monitor for testing, although the projector params seem to work fine too.
if isfield(params,'displayName')
    scanparams.display = loadDisplayParams('displayName',params.displayName);%('builtin');%'tenbit');
else
    scanparams.display = loadDisplayParams('displayName','3T2_projector_2010_09_01');%('builtin');%'tenbit');
end
%scanparams.display = loadDisplayParams('displayName', '3T_projector_800x600');
scanparams.display.fixColorRgb = [255 0 0 255; 0 0 255 255; 255 255 255 0];
scanparams.display.fixType = 'small dot';
scanparams.display.fixSizePixels = fixationPixelSize;


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

%% IF USER WANTS TO PRELOAD BLOCKS, DO IT HERE
if preloadBlockFlag
    % LOAD DUMMY BLOCK
    if ~isempty(dummyBlockType) && (~strcmp(dummyBlockType,'Fix'))
        
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
        nn = floor(3/(stimLength+ISItime)); % on average every 3 seconds [max response time = 3 seconds]
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
        
        % Convert images into PTB textures
        dummyInfo = makeTextures(scanparams.display,dummyInfo);
    else
        dummyInfo = [];
    end
    
    % LOAD EXPERIMENT BLOCKS -- same as for the dummy block, except in a for loop for each block
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
        nn = floor(3/(stimLength+ISItime)); % on average every 4 seconds [max response time = 3 seconds]
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
        
        % Convert images into PTB textures
        blockInfo{blockNum} = makeTextures(scanparams.display,blockInfo{blockNum});
    end
end


%% INITIALIZATION
KbCheck;GetSecs;WaitSecs(0.001);

% set priority
Priority(scanparams.runPriority);

% wait for go signal
pressKey2Begin(scanparams.display);

% countdown + get start time (time0)
[startExptTime] = countDown(scanparams.display,scanparams.startScan+2,scanparams.startScan);
startBlockTime = startExptTime;  % Let's keep startExptTime to refer to it later, and have a separate variable keep timing for each block.


%% LOAD AND SHOW DUMMY BLOCK
% The first block shown can often have high activation, both due to the
% scanner, as well as possible attentional effects in the subject. To let
% the subject "settle in" first, use a dummy block.
if ~isempty(dummyBlockType) && (~strcmp(dummyBlockType,'Fix'))
    %Show fixation
    drawFixation(scanparams.display,1);
    Screen('Flip', scanparams.display.windowPtr);
    
    if ~preloadBlockFlag  % if you haven't already loaded the block above
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
        
        % Convert images into PTB textures
        dummyInfo = makeTextures(scanparams.display,dummyInfo);
    end
    
    % Wait until end of fixation (we've used up some of the time (about
    % 0.05 secs since start of expt) doing the above commands)
    if isfield(params,'initFix'), initFix = params.initFix;
    else initFix = fixLength; end
    WaitSecs('UntilTime',(startBlockTime+initFix));
    
    %Show dummy block
    tic
    [dummyresponse, timing, quitProg] = showScanBlock_noTrialStruct(scanparams.display,dummyInfo);
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
elseif strcmp(dummyBlockType,'Fix')
    dummyInfo.type = 'Fixation';
    drawFixation(scanparams.display,1);
    Screen('Flip', scanparams.display.windowPtr);
    try
        dummyInfo.fixLength = params.initFix;
        WaitSecs('UntilTime',startExptTime+params.initFix);
        sprintf('%s','Just showed a dummy fixation (',num2str(params.initFix),' sec). Starting experiment now.')
    catch
        error('If your dummy block is just a fixation, you must have a params.initFix parameter')
    end
else
    dummyInfo = [];
    fprintf('\n\nNO DUMMY BLOCK MAY MEAN THAT PARFILE OUTPUT IS INCORRECT!  \nPLEASE CHECK YOUR PARFILE.\n\n')
end

%% LOAD AND SHOW EXPERIMENT BLOCKS -- same as for the dummy block, except in a for loop for each block
for blockNum = 1:numBlocks
    
    % Get timing
    %toc
    %tic
    startBlockTime = GetSecs;
    
    %Show fixation
    drawFixation(scanparams.display,1);
    Screen('Flip', scanparams.display.windowPtr);
    
    if ~preloadBlockFlag
        %Load the next block
        if blockNum~=1
            blockInfo{blockNum-1}.images = [];%this will make us clear the memory from the last block
        end
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
        
        % Convert images into PTB textures
        blockInfo{blockNum} = makeTextures(scanparams.display,blockInfo{blockNum});
    end
    
    % Wait until end of fixation (we've used up some of the time (about
    % 0.05 secs since start of expt) doing the above commands)
    WaitSecs('UntilTime',(startBlockTime+fixLength));
    
    %Show the block's stimuli
    tic
    [responses{blockNum}, timing, quitProg] = showScanBlock_noTrialStruct(scanparams.display,blockInfo{blockNum});
    toc
    
    %Clear textures
    blockInfo{blockNum}.textures = [];
    
    %Check if user quit
    if quitProg
        Screen('CloseAll');
        Priority(0);
        ShowCursor;
        return
    end
end

% Show one more fixation at the end
if isfield(params,'postFix'), postFix = params.postFix;
else postFix = fixLength;
end
startLastFixTime = GetSecs;
drawFixation(scanparams.display,1);
Screen('Flip', scanparams.display.windowPtr);
WaitSecs('UntilTime',(startLastFixTime+postFix));

% Get experiment length
endExptTime = GetSecs;
exptLength = endExptTime - startExptTime;
fprintf('\n%s%0.2f%s\n','Total experiment length:  ', exptLength, ' seconds');


%% GET FIXATION PERFORMANCE FOR ALL BLOCKS
fixParams.task = 'Detect fixation change';  % something that getFixationPerformance needs
for blockNum = 1:numBlocks
    stimulus.fixSeq = blockInfo{blockNum}.fixSeq;
    stimulus.seqtiming = zeros(size(blockInfo{blockNum}.seqtiming));
    stimulus.seqtiming(2:end) = blockInfo{blockNum}.seqtiming(1:end-1); % correct for different use of seqtiming in Serge's code
    [blockInfo{blockNum}.fixTaskPercentCorrect,blockInfo{blockNum}.fixTaskRT] = getFixationPerformance(fixParams,stimulus,responses{blockNum});
end

%% SAVE VARIABLES TO A FILE FOR EXPERIMENTAL INFO AND WRITE OUT PARFILE
scanparams = params;  % just to save under a different name-- "params" is overused
clear params;
save(logFile,'dummyInfo','blockInfo','blockLength','fixLength','stimLength','ISItime','stimsPerBlock', 'responses', 'scanparams');
writeParfile(par,parFilePath);
fprintf('\n%s\n%s\n','Saved variables (information about block structure/stimuli to:  ', logFile);
fprintf('\n%s\n%s\n','Saved parfile to:  ', parFilePath);


%% RESET PRIORITY AND SCREEN
Screen('CloseAll');
Priority(0);
ShowCursor;
return