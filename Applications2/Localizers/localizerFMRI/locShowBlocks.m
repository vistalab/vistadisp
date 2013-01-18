function P = locShowBlocks(P)
% Loop across blocks for fMRI localizer experiment, loading and showing the
% images.
%
% P = locShowBlocks(P)
%

%% INITIALIZATION
KbCheck;GetSecs;WaitSecs(0.001);

% set priority
Priority(P.scan.runPriority);

% This is redundant. We show instructions inside of pressKey2Begin.
% % instruction screen
% if P.scan.showInstructions, locShowInstructions(P.scan.display.windowPtr); end

% wait for go signal
onlyWaitKb = false; 
pressKey2Begin(P.scan.display, onlyWaitKb, [], P.scan.instructions);

% If we are doing eCOG, then signal to photodiode that expt is
% starting by giving a patterned flash
if isfield(P, 'modality') && strcmpi(P.modality, 'ecog')
    P.display = P.scan.display;
    retECOGdiode(P);
end

% countdown + get start time (time0)
[startExptTime] = countDown(P.scan.display,P.scan.startScan+P.scan.countdownsecs,P.scan.startScan, P.scan.triggerType);

P.responses = cell(1, P.stim.numBlocks);
for blockNum = 1:P.stim.numBlocks
    
    % Get timing
    startBlockTime = GetSecs;
    
    % If we are doing eCOG, then signal to photodiode to be black
    if isfield(P, 'modality') && strcmpi(P.modality, 'ecog')
        P.display = P.scan.display;
        votECOGdiode(P);
    end
    
    %Show fixation
    drawFixation(P.scan.display,1);        
    
    Screen('Flip', P.scan.display.windowPtr);
    
    %Load the next block
    P = locLoadBlockImages(P, blockNum);
 
    % Set the timing of each image
    P = locSetImagetiming(P, blockNum);
    
    % Fixation sequence; ones just to keep red fixation
    P = locSetFixationSequence(P, blockNum);
    
             
    % Some other parameters we need to specify the size of the image
    P.blockInfo{blockNum}.imSize = size(P.blockInfo{blockNum}.images{1});
    P.blockInfo{blockNum}.imSize = P.blockInfo{blockNum}.imSize([2 1]);
    
    % Not sure what this is about.
    P.blockInfo{blockNum}.srcRect = [];
    P.blockInfo{blockNum}.cmap = [];
    
    % Center the output display rectangle
    c = P.scan.display.numPixels/2;
    tl = round([c(1)-P.blockInfo{blockNum}.imSize(1)/2 c(2)-P.blockInfo{blockNum}.imSize(2)/2]);
    P.blockInfo{blockNum}.destRect = [tl tl+P.blockInfo{blockNum}.imSize(1:2)];
        
    % Convert images into PTB textures
    P.blockInfo{blockNum} = makeTextures(P.scan.display,P.blockInfo{blockNum});
    
    % add photodiode trigger to stimulus
    P.blockInfo{blockNum} = votECOGtrigger(P, P.blockInfo{blockNum});
    
    % Wait until end of fixation (we've used up some of the time (about
    % 0.05 secs since start of expt) doing the above commands)
    WaitSecs('UntilTime',(startBlockTime+P.stim.fixLength(blockNum)));
    
    % Show the block's stimuli
    tic % do we need tic toc? we record the time
    [P.responses{blockNum}, timing, quitProg] = showScanBlock_noTrialStruct(P.scan.display,P.blockInfo{blockNum}); %#ok<ASGLU>    
    toc
    
    % If we are doing eCOG, then signal to photodiode to be black
    if isfield(P, 'modality') && strcmpi(P.modality, 'ecog')
        P.display = P.scan.display;
        votECOGdiode(P);
    end
    
    %Clear textures (make sure we don't need to save anything here)
    P.blockInfo{blockNum}.textures = [];
    
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
    drawFixation(P.scan.display,1);
    Screen('Flip', P.scan.display.windowPtr);
    timeNow = GetSecs;
    gotime = timeNow + P.stim.fixLength(end); %show it for blankLength secs
    Screen('Close'); %close the off-screen window
    WaitSecs('UntilTime',gotime);
end

endExptTime = GetSecs;

P.exptLength = endExptTime - startExptTime;

fprintf('\n%s%0.2f%s\n','Total experiment length:  ', P.exptLength, ' seconds');

return
