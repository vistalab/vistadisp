function [blockInfo,wordIndex] = buildWordBlock(condition,wordImages,params,framesPerStim,wordList,trialsPerBlock,numISIframes,startWordNum)
% This function should build a movie (giving all the frames in blockFrames)
% for an individual block.
%
% [blockInfo,wordIndex] =
%       buildWordBlock(condition,wordImages,params,framesPerStim,wordList,stimsPerBlock,[numISIframes],[startWordNum])
%
% You end up here from buildWordScanBlocks.  If you are here, you already
% have decided whether you will show a word or a nonword.  (The noise
% conditions show a word in really noisy conditions, but we won't count it
% as having shown a word.)  Now we just need to decide whether that word or
% nonword will be defined by motion cues, luminance cues, or both
% ("lumtion").  That will determine how we run makeMoveDotForm or
% makeLuminanceDotForm.
% We may want to think about combining makeMoveDotForm and
% makeLuminanceDotForm so that we can vary the coherence of these
% conditions at the same time.
%
% blockInfo will be an array of structs, where each item in the array
% contains the information for a particular trial within that block e.g.
% blockInfo(1) will contain all information for trial number 1 within that
% block.
%
% written by amr 08/04/08
%


if exist('startWordNum','var')
    wordIndex = startWordNum;
    noCountFlag = 0;
else  % just use wordIndex = 1 throughout if there is no startWordNum, e.g. for noise block
    wordIndex = 1;
    noCountFlag = 1;
end

for trialNumInBlock=1:trialsPerBlock  % for each stimulus in the block
    blockInfo(trialNumInBlock).conditionName = condition;
    curWordImage = wordImages{wordIndex};
    blockInfo(trialNumInBlock).stim = wordList{wordIndex};  % just a list of stimuli used in the block

    if strcmp(condition,'motion')  % if it's a motion block
        mov = makeMoveDotForm(curWordImage, params, framesPerStim);
    elseif strcmp(condition,'lumtion') % both motion and luminance cues
        % change outFormRGB (color of outForm dots) to provide luminance
        % information.  Set them to backRGB if you want a blank background
        % (i.e. no outForm dots).
        params.outFormRGB = params.backRGB; %[0 0 0];
        mov = makeMoveDotForm(curWordImage, params, framesPerStim);  % note that params.coherence here will change the coherence of movement, not of luminance!
    elseif strcmp(condition,'luminance')  % only 1 frame "movie" if it's a luminance condition
        params.outFormRGB = params.backRGB; %[0 0 0]; % change outFormRGB to provide luminance information
        mov = makeLuminanceDotForm(curWordImage, params, 1);
    else
        sprintf('Bad sequence file. Condition in sequenceFile not recognized: %s', condition)
        return;
    end
    nFrames = size(mov,4);  % differs according to motion or luminance case
    for frameIndex=1:nFrames, blockInfo(trialNumInBlock).images{frameIndex} = mov(:,:,:,frameIndex); end

    % start over in our list of words if we've used them all
    if ~noCountFlag;
        wordIndex = wordIndex+1;
        if wordIndex > length(wordImages)
            wordIndex = 1;
        end
    end

%% ISI FRAMES
    blankFrame = zeros(size(blockInfo(trialNumInBlock).images{end}),'uint8');
    blankFrame(:) = params.backRGB(1);
    blockInfo(trialNumInBlock).images{end+1} = blankFrame;  % add a blanke frame to the end

%% SEQUENCE OF FRAMES FOR THAT STIMULUS
    blockInfo(trialNumInBlock).seq = [1:nFrames-1 nFrames+1];  % play each frame in order, replacing the last frame with the blank
    
%% SEQTIMING
    ISItime = numISIframes * params.frameDuration;
    blockInfo(trialNumInBlock).seqtiming = zeros(1,length(blockInfo(trialNumInBlock).seq));  % one entry of seqtiming per entry of seq
    % for motion, seqtiming will be the frameDuration for each frame, then blank for length ISItime
    if strcmp(condition,'motion') || strcmp(condition,'lumtion')
        blockInfo(trialNumInBlock).seqtiming = (1:nFrames).*params.frameDuration;
        goodIndices = find( (blockInfo(trialNumInBlock).seqtiming) <= (params.duration-ISItime));  % get all the frames up to stimulus duration
        % take only the frames before the ISI and then fill the rest of the time (up to stimulus duration with blank)
        blockInfo(trialNumInBlock).seqtiming = ...
            [blockInfo(trialNumInBlock).seqtiming(goodIndices)   params.duration]; % take only those frames
        newNumFrames = length(blockInfo(trialNumInBlock).seqtiming);
        blockInfo(trialNumInBlock).seq = [1:newNumFrames-1  nFrames+1]; %nFrames+1 refers to the blank at this point

        if blockInfo(trialNumInBlock).seqtiming(end-1) ~= params.duration-ISItime
            fprintf('\n%s\n%s\n%s\n','WARNING: your stimulus length may not be what you think it is, and your ISI may be long.'...
                ,'This is most likely because your number of frames do not divide evenly into (params.duration+ISItime)'...
                ,'or something of the sort. Try changing your ISI.')
        end
    % for luminance, the sequence is just the frame and then a blank frame,
    % and seqtiming will be stim duration minus ISItime, then stim duration
    elseif strcmp(condition,'luminance')
        blockInfo(trialNumInBlock).seq = [1 2]; % just play your frame and then the blank frame
        blockInfo(trialNumInBlock).seqtiming = [params.duration-ISItime params.duration];

    end
    
%% FIXSEQ - for now, the fixation is just kept a constant red by being 1
    blockInfo(trialNumInBlock).fixSeq = ones(size(blockInfo(trialNumInBlock).seq));
    
%% Some other things that a stimulus needs -- should figure this out at some point
    % See createStimulusStruct for required fields for stim
    blockInfo(trialNumInBlock).imSize = size(blockInfo(trialNumInBlock).images{1});
    blockInfo(trialNumInBlock).imSize = blockInfo(trialNumInBlock).imSize([2 1 3]);
    blockInfo(trialNumInBlock).cmap = [];

    % Not sure what this is about.
    blockInfo(trialNumInBlock).srcRect = [];

    % Center the output display rectangle
    c = params.display.numPixels/2;
    tl = round([c(1)-blockInfo(trialNumInBlock).imSize(1)/2 c(2)-blockInfo(trialNumInBlock).imSize(2)/2]);
    blockInfo(trialNumInBlock).destRect = [tl tl+blockInfo(trialNumInBlock).imSize(1:2)];
end

return