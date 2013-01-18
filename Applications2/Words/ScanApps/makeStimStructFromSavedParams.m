% stimulus will contain all the params for the whole scan (need to sort it out of
% the individual blocks).  The purpose of writing this code was for having
% an input stimulus for the pRF prediction code in mrVista.
% This code is HORRIBLY written.  I'm sorry.  I was in a rush and didn't
% have the patience.  I should probably just rewrite this.
%
%
% written by amr Sept 9, 2009

%ScanName = 'RotatingWordLocalizer';  % Enter the name of your functional block scan here (used in saving data)
%baseDir = ['/Users/Shared/AndreasWordsMatlab/' ScanName]; % directory that contains stim folder with stimuli

% First, you must load in your saved params (in the data folder)

% Then, run this:

stimsize = [800 600]; %[600 600] % in pixels
blankFrame = uint8(ones(stimsize).*128); % gray blank frame
numBlocks = length(blockInfo);
numStimsPerCond = 32; % hard-coded for now

if notDefined('scanparams.initFix')
    scanparams.initFix = 6;  % initial (dummy) fixation in seconds
end

% get all the conditions
for blockNum = 1:numBlocks;
   conds{blockNum}=blockInfo{blockNum}.conditionName; % in order of how they appeared
end
uniqueconds = unique(conds);

% initialize images, which contains all UNIQUE images
numConds = length(uniqueconds);
numImages = numConds*numStimsPerCond;
images = uint8(ones([size(blankFrame),numImages+1])*128);  % initialize matrix that will contain all images, +1 for blank frame
images(:,:,end)=blankFrame;  % last image is a blank frame, which stimulus.seq will refer to

% first make all the images for each condition (sorted by condition, then by
% alphabetic order of stimulus)-- number the images 1 through n, which will
% be used in stimulus.seq (3rd dimension of matrix)
ScanName = 'RotatingWordLocalizer';
baseDir = ['/Users/Shared/AndreasWordsMatlab/' ScanName]; % directory that contains stim folder with stimuli
imageNum =1; % initialize
for curCond = 1:length(uniqueconds)
    % get all the bmp files in the cond dir
    curPath = fullfile(baseDir,'stim',uniqueconds{curCond});
    curFiles = fullfile(curPath,'/*.bmp');
    d = dir(curFiles);  % d is a struct with d.name for every file
    for stimNum = 1:length(d)
        curFile = fullfile(curPath,d(stimNum).name);
        curImg = imread(curFile);
        
        % center the current image on background
        [sz(1) sz(2)]=size(curImg);
        r = CenterRect([1 1 sz(1) sz(2)], [1 1 stimsize]);
        images(r(1):r(3),r(2):r(4),imageNum) = uint8(curImg);
        
        % also keep track of which imageNum is which stimulus in a separate vector
        stimOrderList{imageNum}=curFile;
        
        imageNum = imageNum+1; % update
    end
end

% then figure out stimulus.seq by going through all the stimuli in each
% block and matching it to the correct image
stimNum = 1;

% dummy block stimuli
dummyStims = dummyInfo.stimulusList;
for xx=1:length(dummyStims)
    imageIndex = strmatch(dummyStims{xx},stimOrderList);
    stimseq(stimNum)=imageIndex;
    stimNum = stimNum+1;
end
%stimseq(stimNum)=stimseq(stimNum-1);  % temp fix for messed up timing!  ****************
%stimNum = stimNum +1;
% dummy block stimuli are the first index into thisBlock
thisBlock(1).fixSeq = dummyInfo.fixSeq;
thisBlock(1).seqtiming = zeros(size(dummyInfo.seqtiming));
thisBlock(1).seqtiming(2:end) = dummyInfo.seqtiming(1:end-1); % correct for different use of seqtiming in Serge's code
thisBlock(1).blockLength = max(dummyInfo.seqtiming);

% other block stimuli
for blockNum = 1:numBlocks
    
    % stimulus sequence
    blockStims = blockInfo{blockNum}.stimulusList;
    for xx = 1:length(blockStims)
        imageIndex = strmatch(blockStims{xx},stimOrderList);
        stimseq(stimNum)=imageIndex;
        stimNum = stimNum+1;
    end
    %stimseq(stimNum)=stimseq(stimNum-1);  % temp fix for messed up timing!  (adds stimuli) ****************
    %stimNum = stimNum +1;
    
    % stimulus timing
    thisBlock(blockNum+1).fixSeq = blockInfo{blockNum}.fixSeq;
    thisBlock(blockNum+1).seqtiming = zeros(size(blockInfo{blockNum}.seqtiming));
    thisBlock(blockNum+1).seqtiming(2:end) = blockInfo{blockNum}.seqtiming(1:end-1); % correct for different use of seqtiming in Serge's code
    thisBlock(blockNum+1).blockLength = max(blockInfo{blockNum}.seqtiming);
    
end

% add in the ISI blanks to stimulus.seq
blankseq = repmat(numImages+1,1,length(stimseq));
stimulus.seq = cat(1,stimseq,blankseq);
stimulus.seq = stimulus.seq(:)';

% get stimulus.seqtiming
offsetSum=0;
stimulus.seqtiming = zeros(1,length(stimulus.seq));  % initialize
numStimsPerBlock = length(thisBlock(2).seqtiming);  % assume same number of stimuli for every block

stimulus.seqtiming(1:numStimsPerBlock)=thisBlock(1).seqtiming;  % first block (usually dummy)
% now blocks 2 to end
for blockNum = 2:(numBlocks+1)  %+1 to account for dummy block
    offsetSum = thisBlock(blockNum-1).blockLength + offsetSum;
    curStartInd = numStimsPerBlock*(blockNum-1)+1;
    stimulus.seqtiming(curStartInd:(curStartInd+numStimsPerBlock-1)) = (thisBlock(blockNum).seqtiming)+offsetSum;
end

% add some params needed by makeStimFromScan (for retinotopy predictions)
params.framePeriod = 2;  %2 sec TR
params.prescanDuration = thisBlock(1).blockLength+scanparams.initFix;  % in seconds (this is the length of the dummy block)
params.numImages = (round(max(stimulus.seqtiming))-params.prescanDuration) / params.framePeriod;   % num TRs per scan


% add in the initial fixation (blank screen) at the beginning of stimulus.seq and
% stimulus.seqtiming
stimulus.seq(2:end+1) = stimulus.seq(1:end);  % shift everything over by one slot
stimulus.seq(1) = max(stimulus.seq);  % max corresponds to blank image, which is the last frame of images
stimulus.seqtiming(2:end+1) = stimulus.seqtiming(1:end);
stimulus.seqtiming(1) = -scanparams.initFix;  % make sure starting value will be at 0 (time 0)
stimulus.seqtiming = stimulus.seqtiming + scanparams.initFix;    % shift all times by initial fixation

% if you want to save, run this:
save('~/Desktop/params_file','stimulus','params')
save('~/Desktop/image_matrix','images')

return


%% Patch for runs where timing got screwed up so that blocks were only 5.7s
%% long instead of 6s...  just pretend they were 6s long for prediction

dummyInfo.seqtiming = [dummyInfo.seqtiming 5.8700 6.000];
dummyInfo.seq = [dummyInfo.seq 1 20];
for blockNum = 1:length(blockInfo)
    blockInfo{blockNum}.seqtiming = [blockInfo{blockNum}.seqtiming 5.8700 6.000];
    blockInfo{blockNum}.seq = [blockInfo{blockNum}.seq 1 20];
end
