function doWordHierarchy(params,conds)
%
% This function will sweep out word-like stimuli along some parameter, such
% as wordiness as defined by letter frequency, bigram freq, trigram freq,
% quad freq, and real words (c.f. Vinckier et al 2008 Neuron).
%
% The idea is to have a continuous parameter which can be mapped onto
% anatomical space, just like phase or eccentricity is mapped onto visual
% cortex.  In the pRF model, sigma represents the width of the population
% receptive field.  We would like something analagous in the space of words
% that represents the specificity of the response within the space.
%

%% PARAMETERS

ScanName = 'WordHierarchy';  % Enter the name of your functional block scan here (used in saving data)

baseDir = ['/Users/Shared/AndreasWordsMatlab/' ScanName]; % directory that contains stim folder with stimuli
% Note that the stim folder must have folder names within it
% corresponding to the condition names. These should contain the stimulus pictures.
% Checkerboard stimulus is in the stim directory also.

% Block Parameters (in seconds)
if notDefined('params')
    params.blockLength = 6;                           % usually 12
    params.fixLength = 0;  % between stimulus blocks  % usually 12
    params.stimLength = 0.4;  % doesn't include ISItime
    params.ISItime = 0.1;
    params.blankColor = 128;  % ISI uniform color e.g. 128 for gray
    params.nRepeats = 6;  % number of times to repeat sequence of blocks
    params.initFix = 6;  % first fixation length
    params.postFix = 0;
end


% Set the condition names here
if notDefined('conds')
    conds.A = 'consonants';
    conds.B = 'unigrams';
    conds.C = 'bigrams';
    conds.D = 'trigrams';
    conds.E = 'words';
end


%% BLOCK ORDERING

autoChooseBlocks = 0;  % flag to choose block order based on session number (that user enters)

% If you don't have autoChooseBlocks on, then you can set your block order here
if isfield(params,'blockOrder')
    blockOrder = params.blockOrder;
else
    blockOrder = 'ABCDE';  % basic block order, will be repeated n times; predictable
    %blockOrder = 'AEDBCEDACB';  % unpredictable
    blockOrder = repmat(blockOrder,1,params.nRepeats);
end
numBlocks = length(blockOrder);

scanLength = params.blockLength*(numBlocks+1)+params.initFix+params.postFix;

% Dummy block is an additional block BEFORE the beginning of your normal blocks.
dummyBlockType = 'A';  % A,B,C, or []  ([] if you don't want dummy block)

stimChooseAlgorithm = 'random';  % if 'list', will read from a text file in main stim directory, called 'stimOrder.txt'

preloadBlockFlag = 1;  % makes sure to load in all the blocks beforehand, since there is no fixation


%% RUN SCAN
runFuncBlockScan(ScanName,params,conds,blockOrder,dummyBlockType,baseDir,autoChooseBlocks,stimChooseAlgorithm,preloadBlockFlag);

return


%% FIRST TRY (OLD STUFF)

% %% READ IN STIMULI-- they must already be in randomized lists, one for each condition
% condstimFilePaths.A = fullfile(baseDir,'wordlists',[conds.A '.txt']);
% condstimFilePaths.B = fullfile(baseDir,'wordlists',[conds.B,'.txt']);
% condstimFilePaths.C = fullfile(baseDir,'wordlists',[conds.C '.txt']);
% condstimFilePaths.D = fullfile(baseDir,'wordlists',[conds.D '.txt']);
% condstimFilePaths.E = fullfile(baseDir,'wordlists',[conds.E '.txt']);
% 
% fid = fopen(condstimFilePaths.A);
% cols = textscan(fid,'%s');
% fclose(fid)
% stimlists.A = cols{1};
% 
% fid = fopen(condstimFilePaths.B);
% cols = textscan(fid,'%s');
% fclose(fid)
% stimlists.B = cols{1};
% 
% fid = fopen(condstimFilePaths.C);
% cols = textscan(fid,'%s');
% fclose(fid)
% stimlists.C = cols{1};
% 
% fid = fopen(condstimFilePaths.D);
% cols = textscan(fid,'%s');
% fclose(fid)
% stimlists.D = cols{1};
% 
% fid = fopen(condstimFilePaths.E);
% cols = textscan(fid,'%s');
% fclose(fid)
% stimlists.E = cols{1};
% 
% %% MAKE THE STIMULI
% for repeatNum = 1:params.nRepeats
%     for blockNum = 1:numBlocks
%         for stimNum = 1:numStims
%             curList = eval(['stimlists.' condition]);
%             curWord = curList{[stimCounter '.' condition]};
%             stimCounter = stimCounter+1;
%             %             %[stimCounter '.' condition] = eval([stimCounter '.' condition]) + 1;
%             blockInfo(blockNum).words{stimNum} = curWord;
%         end
%     end
% end
% 
% %% SCREEN AND KEYBOARD STUFF
% 
% % %To run on an external monitor for testing, although the projector params seem to work fine too.
% scanparams.display = loadDisplayParams('displayName', 'NEC485words.mat');%('builtin');%'tenbit');
% % %To run at the scanner
% %scanparams.display = loadDisplayParams('displayName', '3T_projector_800x600');
% scanparams.display.fixColorRgb = [255 0 0 255; 0 0 255 255; 255 255 255 0];
% 
% 
% screens=Screen('Screens'); % find the number of screens
% scanparams.display.screenNumber = max(screens); % put this on the highest number screen
%                                                 % (0 is the 1st screen)
% scanparams.runPriority = 9;
% scanparams.startScan = 0;
% scanparams.display.devices = getDevices;  % in display so we can pass it along with that strucs
% 
% % check for OpenGL
% AssertOpenGL;
% 
% % Open the screen
% scanparams.display                = openScreen(scanparams.display);
% 
% % Establish the code for the quit key
% % Note that checkfields is in mrLoadRet-3.0
% if checkfields(scanparams,'display','quitProgKey')
%     quitProgKey = scanparams.display.quitProgKey;
% else quitProgKey = KbName('q');
% end
% 
% % % Set fonts
% % Screen('TextFont',scanparams.display.windowPtr,'Monospaced');
% % Screen('TextSize',scanparams.display.windowPtr,25);
% % Screen('FillRect', scanparams.display.windowPtr, params.blankColor);  % 0 = black background
% 
% 
% %% INITIALIZATION
% KbCheck;GetSecs;WaitSecs(0.001);
% 
% % set priority
% Priority(scanparams.runPriority);
% 
% % wait for go signal
% pressKey2Begin(scanparams.display);
% 
% % countdown + get start time (time0)
% [startExptTime] = countDown(scanparams.display,scanparams.startScan+2,scanparams.startScan);
% startBlockTime = startExptTime;  % Let's keep startExptTime to refer to it later, and have a separate variable keep timing for each block.
% 
% 
% %% RUN SCAN
% 
% % Maybe want some sort of dummy block first?
% numBlocks = length(blockOrder);
% 
% for repeatNum = 1:params.nRepeats
%     for blockNum = 1:numBlocks
%           startBlockTime = getSecs;
%          [quitProg,ssResponses,ssRTs] = showScanBlock(display, blockInfo(blockNum), quitProgKey, startBlockTime);
%     end
% end
% 
% % stimCounter = 1;
% % for repeatNum = 1:params.nRepeats
% %     for blockNum = 1:numBlocks
% %         condition = blockOrder(blockNum);
% %         curList = eval(['stimlists.' condition]);
% %         for stimNum = 1:numStims
% %             curWord = curList{[stimCounter '.' condition]};
% %             DrawFormattedText(scanparams.display.windowPtr, curWord,'center','center',255);
% %             Screen('Flip',scanparams.display.windowPtr);
% %             timeToFlip = startExptTime + blockNum*params.blockLength + stimNum*params.stimLength;
% %             WaitSecs('UntilTime',timeToFlip)
% %             drawFixation(scanparams.display,1);
% %             Screen('Flip', scanparams.display.windowPtr);
% %             stimCounter = stimCounter+1;
% %             %[stimCounter '.' condition] = eval([stimCounter '.' condition]) + 1;
% %         end
% %     end
% % end
% 
% 
% % Show one more fixation at the end
% startLastFixTime = GetSecs;
% drawFixation(scanparams.display,1);
% Screen('Flip', scanparams.display.windowPtr);
% WaitSecs('UntilTime',(startLastFixTime+fixLength));
% 
% % Get experiment length
% endExptTime = GetSecs;
% exptLength = endExptTime - startExptTime;
% fprintf('\n%s%0.2f%s\n','Total experiment length:  ', exptLength, ' seconds');
% 
% 
% %% GET FIXATION PERFORMANCE FOR ALL BLOCKS
% fixParams.task = 'Detect fixation change';  % something that getFixationPerformance needs
% for blockNum = 1:numBlocks
%     stimulus.fixSeq = blockInfo{blockNum}.fixSeq;
%     stimulus.seqtiming = zeros(size(blockInfo{blockNum}.seqtiming));
%     stimulus.seqtiming(2:end) = blockInfo{blockNum}.seqtiming(1:end-1); % correct for different use of seqtiming in Serge's code
%     [blockInfo{blockNum}.fixTaskPercentCorrect,blockInfo{blockNum}.fixTaskRT] = getFixationPerformance(fixParams,stimulus,responses{blockNum});
% end
% 
% %% SAVE VARIABLES TO A FILE FOR EXPERIMENTAL INFO AND WRITE OUT PARFILE
% save(logFile,'dummyInfo','blockInfo','blockLength','fixLength','stimLength','ISItime','stimsPerBlock', 'responses');
% writeParfile(par,parFilePath);
% fprintf('\n%s\n%s\n','Saved variables (information about block structure/stimuli to:  ', logFile);
% fprintf('\n%s\n%s\n','Saved parfile to:  ', parFilePath);
% 
% 
% %% RESET PRIORITY AND SCREEN
% Screen('CloseAll');
% Priority(0);
% ShowCursor;
% return

