function runFuncBlockScan2(params,varargin)

    % General script to run a block design fMRI experiment.
    % Allows you to adjust the block length and stimulus length by
    % adjusting the first few parameters.  The stimuli should be saved in a
    % separate directory for each condition.
    %
    % I am working on implementing different ways of choosing your stimuli.
    % Right now they are just chosen randomly from your directories, but you
    % may want them in a specific order or be able to have a 1-back task like
    % in the original KGS localizers. Right now we assume a fixation change
    % detection task.
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
    %

    %%
    params = runFuncDefaults(params); % Set defaults

    %% Parse options
    for ii = 1:2:length(varargin)
        switch lower(varargin{ii})
            case 'scanname',            params.scanName = varargin{ii+1};
            case 'blockorder',          params.blockOrder = varargin{ii+1};
            case 'dummyblocktype',      params.dummyBlockType = varargin{ii+1};
            case 'basedir',             params.baseDir = varargin{ii+1};
            case 'autochooseblocks',    params.autoChooseBlocks = varargin{ii+1};
            case 'stimchoosealgorithm', params.stimChooseAlgorithm = varargin{ii+1};
            case 'preloadblockflag',    params.preloadBlockFlag = varargin{ii+1};
        end
    end

    %%
    params = runFuncGetSubjSess(params); % Subject and session info
    params = runFuncSetDirectories(params); % Setting up directories where stuff is stored
    params = runFuncInitDisplay(params); % Screen and keyboard stuff

    %%
    params.stimsPerBlock = params.blockLength/(params.stimLength+params.ISItime);
    if (abs(round(params.stimsPerBlock)-params.stimsPerBlock)>0.0000001) %round(stimsPerBlock) ~= stimsPerBlock  % sometimes rounding seems to create a problem, but it is indicative of timing problems later
        sprintf('%s', 'Your stimuli do not divide evenly into your block length.  Please change the parameters.')
        return;
    end

    %%
    params = runFuncChooseBlocks(params); % Auto choose blocks if necessary


    %% ASSIGN STIMULI (STIMULUS FILE NAMES) TO BLOCKS
    if ~isempty(params.dummyBlockType)
        [dummyInfo params] = runFuncDummyInfo(params); % Dummy Block
    end

    [blockInfo params] = runFuncBlockInfo(params); % Experimental Blocks

    %% IF USER WANTS TO PRELOAD BLOCKS, DO IT HERE
    if params.preloadBlockFlag
        % LOAD DUMMY BLOCK
        if ~isempty(params.dummyBlockType)
            dummyInfo = runFuncLoadBlock(dummyInfo,params,'dummy');
        else
            dummyInfo = [];
        end 

        % LOAD EXPERIMENT BLOCKS -- same as for the dummy block, except in a for loop for each block
        for blockNum = 1:length(params.blockOrder)
            blockInfo{blockNum} = runFuncLoadBlock(blockInfo{blockNum},params,'normal');
        end
    end


    %% INITIALIZATION
    KbCheck;GetSecs;WaitSecs(0.001);

    % set priority
    Priority(params.runPriority);

    % wait for go signal
    pressKey2Begin(params.display);

    % countdown + get start time (time0)
    [startExptTime] = countDown(params.display,params.startScan+2,params.startScan);
    startBlockTime = startExptTime;  % Let's keep startExptTime to refer to it later, and have a separate variable keep timing for each block.


    %% LOAD AND SHOW DUMMY BLOCK
    % The first block shown can often have high activation, both due to the
    % scanner, as well as possible attentional effects in the subject. To let
    % the subject "settle in" first, use a dummy block.
    if ~isempty(params.dummyBlockType) && (~strcmp(params.dummyBlockType,'Fix'))
        %Show fixation
        drawFixation(params.display,1);
        Screen('Flip', params.display.windowPtr);

        if ~params.preloadBlockFlag  % if you haven't already loaded the block above
           dummyInfo = runFuncLoadBlock(dummyInfo,params,'dummy');
        end

        % Wait until end of fixation (we've used up some of the time (about
        % 0.05 secs since start of expt) doing the above commands)
        if isfield(params,'initFix'), initFix = params.initFix;
        else initFix = fixLength; end
        WaitSecs('UntilTime',(startBlockTime+initFix));

        %Show dummy block
        tic
        [dummyresponse, timing, quitProg] = showScanBlock_noTrialStruct(params.display,dummyInfo);
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
    elseif strcmp(params.dummyBlockType,'Fix')
        dummyInfo.type = 'Fixation';
        drawFixation(params.display,1);
        Screen('Flip', params.display.windowPtr);
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
    for blockNum = 1:length(params.blockOrder)

        % Get timing
        startBlockTime = GetSecs;

        %Show fixation
        params.display.fixX = blockInfo{blockNum}.fixX;
        params.display.fixY = blockInfo{blockNum}.fixY;
        drawFixation(params.display,1);
        Screen('Flip', params.display.windowPtr);

        if ~params.preloadBlockFlag
            blockInfo{blockNum} = runFuncLoadBlock(blockInfo{blockNum},params,'normal');
        end

        % Wait until end of fixation (we've used up some of the time (about
        % 0.05 secs since start of expt) doing the above commands)
        WaitSecs('UntilTime',(startBlockTime+params.fixLength));

        %Show the block's stimuli
        tic
        [responses{blockNum}, timing, quitProg] = showScanBlock_noTrialStruct(params.display,blockInfo{blockNum});
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
    else postFix = params.fixLength;
    end
    startLastFixTime = GetSecs;
    drawFixation(params.display,1);
    Screen('Flip', params.display.windowPtr);
    WaitSecs('UntilTime',(startLastFixTime+postFix));

    % Get experiment length
    endExptTime = GetSecs;
    exptLength = endExptTime - startExptTime;
    fprintf('\n%s%0.2f%s\n','Total experiment length:  ', exptLength, ' seconds');


    %% GET FIXATION PERFORMANCE FOR ALL BLOCKS
    fixParams.task = 'Detect fixation change';  % something that getFixationPerformance needs
    for blockNum = 1:length(params.blockOrder)
        stimulus.fixSeq = blockInfo{blockNum}.fixSeq;
        stimulus.seqtiming = zeros(size(blockInfo{blockNum}.seqtiming));
        stimulus.seqtiming(2:end) = blockInfo{blockNum}.seqtiming(1:end-1); % correct for different use of seqtiming in Serge's code
        [blockInfo{blockNum}.fixTaskPercentCorrect,blockInfo{blockNum}.fixTaskRT] = getFixationPerformance(fixParams,stimulus,responses{blockNum});
    end

    %% SAVE VARIABLES TO A FILE FOR EXPERIMENTAL INFO AND WRITE OUT PARFILE

    save(params.logFile,'dummyInfo','blockInfo','responses','params');
    runFuncMakeParfile(params);
    fprintf('\n%s\n%s\n','Saved variables (information about block structure/stimuli to:  ', params.logFile);
    fprintf('\n%s\n%s\n','Saved parfile to:  ', params.parFile);


    %% RESET PRIORITY AND SCREEN
    Screen('CloseAll');
    Priority(0);
    ShowCursor;
    return

end

function [blockInfo params] = runFuncBlockInfo(params)

    blockInfo = cell(length(params.blockOrder)); % Pre allocate for speed

    switch lower(params.stimChooseAlgorithm)
        case 'random'
            for blockIndex = 1:length(params.blockOrder)  % for each block
                condsIndex = strcmpi(params.blockOrder(blockIndex),params.conditionLetters);
                if ~sum(condsIndex)==0
                    blockInfo{blockIndex}.condition = params.blockOrder(blockIndex); % Set condition to block number
                    blockInfo{blockIndex}.conditionName = params.conds{condsIndex};
                    blockStimDir = fullfile(params.stimDir,blockInfo{blockIndex}.conditionName);
                    blockInfo{blockIndex}.stimulusList = randomizeStims2Block(blockStimDir,params.stimsPerBlock);
                else
                    fprintf('Block condition (%s) not recognized, please correct.',blockInfo{blockIndex}.condition);
                    params.abort = 1;
                    return;
                end
            end

        case 'list'
            stimOrderFile = fullfile(params.stimDir,'stimOrder.txt');
            runContingentStimFile = sprintf('stimOrderRUN%02.0f.txt',str2double(params.sessionNum));
            if exist(fullfile(params.stimDir,runContingentStimFile),'file')
                stimOrderFile = fullfile(params.stimDir,runContingentStimFile);
            end
            fid = fopen(stimOrderFile);
            col = textscan(fid,'%s %s %.0f');
            fclose(fid);
            readStims = col{1};

            for blockIndex = 1:length(params.blockOrder)
                condsIndex = strcmpi(params.blockOrder(blockIndex),params.conditionLetters);
                if ~sum(condsIndex)==0
                    % Store some basic info
                    blockInfo{blockIndex}.condition     = params.blockOrder(blockIndex);
                    blockInfo{blockIndex}.conditionName = params.conds{condsIndex};

                    for curStimNum = 1:params.stimsPerBlock
                        numInList       = curStimNum+((blockIndex-1)*params.stimsPerBlock);
                        curStim         = readStims{numInList};
                        blockStimDir    = fullfile(params.stimDir,blockInfo{blockIndex}.conditionName);
                        curStim         = fullfile(blockStimDir,[curStim '.bmp']);
                        blockInfo{blockIndex}.stimulusList{curStimNum} = curStim;
                        blockInfo{blockIndex}.fixX = params.display.numPixels(1)*params.fixLoc(1,condsIndex);
                        blockInfo{blockIndex}.fixY = params.display.numPixels(2)*params.fixLoc(2,condsIndex);
                    end
                else
                    fprintf('Block condition (%s) not recognized, please correct.',blockInfo{blockIndex}.condition);
                    params.abort = 1;
                    return;
                end
            end
    end
    
end

function params = runFuncChooseBlocks(params)

    if params.autoChooseBlocks
        switch lower(params.scanName)  % different preset orders of stimuli for different scans
            case 'verbgeneration'
                if params.sessionNum == '1'
                    params.blockOrder = 'ABABAB' %run 1 of verbGeneration
                    params.dummyBlockType = 'Fix'; %'C';  % fixation dummy block for verbGeneration
                elseif params.sessionNum == '2'
                    params.blockOrder = 'BABABA' %run 2 of verbGeneration
                    params.dummyBlockType = 'Fix'; %'A';
                elseif params.sessionNum == '3'
                    error('Can only auto-generate 2 blockOrder sessions for verbGeneration')
                end

            case 'wordlocalizer'  % not currently used because doWordLocalizer doesn't use this script!
                if params.sessionNum == '1'
                    params.blockOrder = 'ACBCAB' %run1 of doWordLocalizer
                    params.dummyBlockType = 'C';  % fixation dummy block for verbGeneration
                elseif params.sessionNum == '2'
                    params.blockOrder = 'BACABC' %run2 of doWordLocalizer
                    params.dummyBlockType = 'A';
                elseif sessionNum == '3'
                    params.blockOrder = 'CBABCA' %run3
                    params.dummyBlockType = 'B';
                end

            case {'wordeccentricity', 'checkerboards'}
                if params.sessionNum == '1'
                    params.blockOrder = 'ABCDEFABCDEF' %run1 of wordEccentricity
                    params.dummyBlockType = 'Fix'%'E';  % fixation dummy block for wordEccentricity
                elseif params.sessionNum == '2'
                    params.blockOrder = 'FEDCBAFEDCBA' %run2 of wordEccentricity
                    params.dummyBlockType = 'Fix'%'A';
                elseif params.sessionNum == '3'
                    params.blockOrder = 'BACEDFBACEDF'
                    params.dummyBlockType = 'Fix';
                elseif params.sessionNum == '4'
                    params.blockOrder = 'FDECABFDECAB'
                    params.dummyBlockType = 'Fix';
                elseif params.sessionNum == '5'
                    params.blockOrder = 'CFBEADCFBEAD'
                    params.dummyBlockType = 'Fix';
                end

            otherwise
                if params.sessionNum == '1'
                    params.blockOrder = 'ABABAB' %run 1 of verbGeneration
                    %params.blockOrder = 'ACBCAB'; %run1 of doWordLocalizer
                    params.dummyBlockType = 'Fix'; %'C';  % fixation dummy block for verbGeneration
                elseif params.sessionNum == '2'
                    params.blockOrder = 'BABABA' %run 2 of verbGeneration
                    %params.blockOrder = 'BACABC'; %run2 of doWordLocalizer
                    params.dummyBlockType = 'Fix'; %'A';
                elseif params.sessionNum == '3'
                    params.blockOrder = 'CBABCA' %run3
                    params.dummyBlockType = 'B';
                end
        end
    end

    params.condsLetters = sort(unique(params.blockOrder));

end

function params = runFuncDefaults(params)

    conditionCount = length(params.conds); % count # of conditions being run
    params.abort = 0;
    params.preloadBlockFlag = 0;
    params.autoChooseBlocks = 0;
    params.stimChooseAlgorithm = 'random';
    params.baseDir = '/Users/Shared/AndreasWordsMatlab/';
    params.quitProgKey = KbName('q');
    params.conditionLetters = {'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K'};

    if ~isfield(params,'fixLoc')
        params.fixLoc = .5*ones(2,conditionCount); % defaults to center [x;y] coords for each cond/column
    end
    
    if ~isfield(params,'distance')
        params.distance = zeros(1,conditionCount); % defaults to no distance from fixation for each cond/column
    end
    
    if ~isfield(params,'angle')
        params.angle = zeros(1,conditionCount); % defaults to no angle for each cond/column
    end
    
end

function [dummyInfo params] = runFuncDummyInfo(params)

    switch lower(params.stimChooseAlgorithm)
        case 'random'
            dummyInfo.condition = params.dummyBlockType;
            if strcmpi(params.dummyBlockType,'fix')
                dummyInfo.conditionName = 'Fix';
                dummyInfo.stimulusList  = [];
            else
                condsIndex = strcmpi(params.dummyBlockType,params.conditionLetters);
                if ~sum(condsIndex)==0
                    dummyInfo.conditionName = params.conds{condsIndex};
                    dummyStimDir = fullfile(params.stimDir,dummyInfo.conditionName);
                    dummyInfo.stimulusList = randomizeStims2Block(dummyStimDir,params.stimsPerBlock);
                else
                    fprintf('Dummy condition (%s) not recognized, please correct.',params.dummyBlockType);
                    params.abort = 1;
                    return;
                end
            end
        case 'list' % Doesn't currently work - need to fix!
            dummyInfo.stimulusList = [];
            dummyInfo.condition = params.dummyBlockType;
            if strcmpi(params.dummyBlockType,'fix')
                dummyInfo.conditionName = 'Fix';
                dummyInfo.stimulusList  = [];
            else
                condsIndex = strcmpi(params.dummyBlockType,params.conditionLetters);
                if ~sum(condsIndex)==0
                    dummyInfo.conditionName = params.conds{condsIndex};
                else
                    fprintf('Dummy condition (%s) not recognized, please correct.',params.dummyBlockType);
                    params.abort = 1;
                    return;
                end
            end
    end
end

function params = runFuncGetSubjSess(params)

    % GET SUBJECT AND DATE INFORMATION

    fprintf('\n\n');
    params.subjInitials     = input('Subject Initials:  ','s');
    params.sessionNum       = input('Session number:  ','s');

end

function params = runFuncInitDisplay(params)

    params.display = loadDisplayParams('displayName', params.displayName);
    params.display.fixColorRgb = [255 0 0 255; 0 0 255 255; 255 255 255 0];
    screens=Screen('Screens'); % find the number of screens
    params.display.screenNumber = max(screens); % put this on the highest number screen
    % (0 is the 1st screen)
    params.runPriority = 9;
    params.startScan = 0;
    params.display.devices = getDevices;  % in display so we can pass it along with that strucs

    % check for OpenGL
    AssertOpenGL;

    % Open the screen
    params.display                = openScreen(params.display);
    
    % Hard coding in small dot size
    params.display.fixType = 'small dot';
    params.display.fixSizePixels = 2;
    
end

function info = runFuncLoadBlock(info,params,type)

    for stimNum = 1:params.stimsPerBlock
        info.images{stimNum} = imread(info.stimulusList{stimNum});
    end
    blankFrame = uint8(ones(size(info.images{1})).*params.blankColor); % gray blank frame
    info.images{end+1} = blankFrame;

    % Interleave your sequence of stimuli with blank frames (last image)
    info.seq = ones(2,(length(info.images)-1)).*length(info.images);
    info.seq(1,:) = 1:(length(info.images)-1); % play all frames except blank ISI in order
    info.seq = info.seq(:);  % interleave
    info.seq = info.seq';    % proper formatting

    % Do something very similar for seqtiming, which specifies the end time
    % of each image
    info.seqtiming = ones(2,(length(info.images)-1)) .* (params.stimLength+params.ISItime);
    info.seqtiming(2,:) = (1:(length(info.images)-1)) .* (params.stimLength+params.ISItime);  %ISI timing
    info.seqtiming(1,:) = (1:(length(info.images)-1)) .* (params.stimLength+params.ISItime);  %stim timing
    info.seqtiming(1,:) = info.seqtiming(1,:) - params.ISItime;                        %more stim timing
    info.seqtiming = info.seqtiming(:);  % interleave
    info.seqtiming = info.seqtiming';  % proper formatting

    % Fixation sequence; ones just to keep red fixation
    info.fixSeq = ones(size(info.seq));
    % Other fixation colors
    nn = floor(4/(params.stimLength+params.ISItime)); % on average every 4 seconds [max response time = 3 seconds]
    info.fixSeq = ones(nn,1)*round(rand(1,ceil(length(info.seq)/nn)));
    info.fixSeq = info.fixSeq(:)+1;
    info.fixSeq = info.fixSeq(1:length(info.seq));
    % force binary
    info.fixSeq(info.fixSeq>2)=2;
    info.fixSeq(info.fixSeq<1)=1;

    % Some other parameters we need to specify the size of the image
    info.imSize = size(info.images{1});
    info.imSize = info.imSize([2 1]);

    % Not sure what this is about.
    info.srcRect = [];
    info.cmap = [];

    % Center the output display rectangle
    c = params.display.numPixels/2;
    tl = round([c(1)-info.imSize(1)/2 c(2)-info.imSize(2)/2]);

    switch lower(type)
        case 'dummy'
            if ~strcmp(params.dummyBlockType,'Fix') 
                condition = findstr(params.condsLetters,params.dummyBlockType);
                c   = computePosition(params.display,params.fixLoc(:,condition),params.angle(condition),params.distance(condition));
                tl  = round([c(3)-info.imSize(1)/2 c(4)-info.imSize(2)/2]);
            end
        case 'normal'
                condition = findstr(params.condsLetters,info.condition);
                c   = computePosition(params.display,params.fixLoc(:,condition),params.angle(condition),params.distance(condition));
                tl  = round([c(3)-info.imSize(1)/2 c(4)-info.imSize(2)/2]);
    end


    info.destRect = [tl tl+info.imSize(1:2)];

    % Convert images into PTB textures
    info = makeTextures(params.display,info);

end

function runFuncMakeParfile(params)

    if params.fixLength>0
        for parIndex = 1:2:(2*length(params.blockOrder))         % go by 2s because block is always paired with fixation
            % Fixation block
            par.onset(parIndex) = (floor(parIndex/2)) * (params.fixLength + params.blockLength);
            par.cond(parIndex) = 0;
            par.label{parIndex} = 'Fix';

            % Stimulus block
            par.onset(parIndex+1) = (floor(parIndex/2)) * (params.fixLength + params.blockLength) + params.fixLength;

            par.cond(parIndex+1)    = findstr(params.condsLetters,params.blockOrder(ceil(parIndex/2)));
            par.label{parIndex+1}   = params.conds{par.cond(parIndex+1)};
        end
        % one more fixation at the end (see later code)
        par.onset(parIndex+2) = (floor(parIndex/2)) * (params.fixLength + params.blockLength) + params.fixLength + params.blockLength; % add 1 more block length
        par.cond(parIndex+2) = 0;  % +2 because it is 2 past last parIndex
        par.label{parIndex+2} = 'Fix';

    else  % Parfile variable in the special case of having no fixation blocks
        for parIndex = 1:length(blockOrder)
            % Stimulus block
            par.onset(parIndex) = (parIndex-1) * params.blockLength;

            par.cond(parIndex+1)    = findstr(params.condsLetters,params.blockOrder(parIndex));
            par.label{parIndex+1}   = params.conds{par.cond(parIndex+1)};
        end
        % you can have a postFix even if fixLength=0
        if isfield(params,'postFix')
            if params.postFix>0
                par.onset(parIndex+1) = (parIndex) * params.blockLength + params.blockLength; % add 1 more block length
                par.cond(parIndex+1) = 0;
                par.label{parIndex+1} = 'Fix';
            end
        end
    end

    writeParfile(par,params.parFile);
    
end

function params = runFuncSetDirectories(params)

    params.dataDir = fullfile(params.baseDir,'data');
    params.stimDir = fullfile(params.baseDir,'stim');
    params.parDir = fullfile(params.baseDir,'parfiles');

    if ~exist(params.dataDir,'dir')
        mkdir(params.dataDir);
    end
    if ~exist(params.parDir,'dir')
        mkdir(params.parDir);
    end

    parFileName = [params.scanName '_' params.subjInitials '_' datestr(now,'ddmmyyyy_HH-MM') '_Sess' num2Str(params.sessionNum) '.par'];
    logFileName = [params.subjInitials '_' 'session' params.sessionNum '_' datestr(now,'dd.mm.yyyy.HH.MM') '_' 'savedVariables.mat'];

    params.parFile = fullfile(params.parDir, parFileName);
    params.logFile = fullfile(params.dataDir, logFileName);

end