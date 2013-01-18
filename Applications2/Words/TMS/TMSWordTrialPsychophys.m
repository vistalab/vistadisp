function [trial, data] = TMSWordTrialPsychophys(display, stimParams, data)
% General function called by a staircase to generate text renderings (or
% load them) on the first trial, and generate a movie (trial) from these
% renderings on every subsequent trial to send back.  This one is specific
% for TMS trials.
%
% trial = TMSWordTrialPsychophys(display, stimParams, data)
%
% Inputs:
%       display: display information for your calibrated(?) display
%       stimParams: a struct containing many fields.  See initWordParams
%           for required fields. Note that stimParams is made up for fontParams
%           and movieParams when you look at initWordParams.m
%       data:  stores all the data for each trial
%
%
%
%
% Example:
%   data =[]; stimParams = [];
%
%  Author: RFD, AMR
%

%% If data is empty, then we need to pre-generate the text renderings (and then save to a mat file) %%
% 579 Words/NonWords
load('/Users/Shared/PsychophysData/TMSStaircase/stimLists.mat');

% Set word storage file name
loadFile = sprintf('/Users/Shared/PsychophysData/TMSStaircase/%s_WordList.mat',stimParams.subjName);

% Check for word storage file
if(exist(loadFile,'file'));
    tempData = load(loadFile);
end

if(~isfield(data,'wStrImg'))
    % Check the cache file first
    if(exist(stimParams.stimFileCache,'file'))
        disp('Loading stim cache...');
        tmp = load(stimParams.stimFileCache);
        data = tmp.data;
        data.wStrInds = Shuffle([1:numel(data.wStrInds)]);
        data.nStrInds = Shuffle([1:numel(data.nStrInds)]);
        clear tmp;
    end
    
    % If data is still empty, that means either, the cache file didn't
    % exist, or it existed but was invalid. Either way, we have to generate
    % the stimulus images.
    if(~isfield(data,'wStrImg'))  %then renderText to make the word stimuli
        lettersFname = fullfile(fileparts(loadFile),'letters.mat');
        if ~exist(lettersFname,'file')
            letters = wordGenLetterVar(lettersFname,stimParams);  % use font params from initWordParams to create rendered letters if they don't already exist
        else
            lettersInfo = load(lettersFname);
            letters = lettersInfo.letters;
        end
        for(ii=1:length(wStr))
            fprintf('Rendering text:  %s\n',wStr{ii});
            
            tmp = wordGenerateImage(display,letters,wStr{ii},'adjustImSize',stimParams.stimSizePix);
            %tmp = renderText(wStr{ii}, stimParams.fontName, stimParams.fontSize, stimParams.sampsPerPt, stimParams.antiAlias, stimParams.fractionalMetrics, stimParams.boldFlag);
            sz = size(tmp);
            if(any(sz>stimParams.stimSizePix)) %true if some stimulus is larger than allowed
                r = stimParams.stimSizePix(1);
                c = stimParams.stimSizePix(2);
                error('Largest stimulus exceeds specificed stimulus size (%d %d).',r,c);
            end
            
            data.wStrImg{ii} = zeros(stimParams.stimSizePix, 'uint8');
            
            % rect is [left,top,right,bottom]. Matlab array is usually y,x
            r = CenterRect([1 1 sz(1) sz(2)], [1 1 stimParams.stimSizePix]);
            data.wStrImg{ii}(r(1):r(3),r(2):r(4)) = uint8(tmp);
            data.wStrInds = Shuffle([1:numel(wStr)]);  %shuffle order of stimulus presentation
        end
        
        for(ii=1:length(nStr)) % and make the nonword stimuli
            fprintf('Rendering text:  %s\n',nStr{ii});
            tmp = wordGenerateImage(display,letters,nStr{ii},'adjustImSize',stimParams.stimSizePix);
            %tmp = renderText(nStr{ii}, stimParams.fontName, stimParams.fontSize, stimParams.sampsPerPt, stimParams.antiAlias, stimParams.fractionalMetrics, stimParams.boldFlag);
            sz = size(tmp);
            if(any(sz>stimParams.stimSizePix))
                r = stimParams.stimSizePix(1);
                c = stimParams.stimSizePix(2);
                error('Largest stimulus exceeds specificed stimulus size (%d %d).',r,c);
            end
            data.nStrImg{ii} = zeros(stimParams.stimSizePix, 'uint8');
            % rect is [left,top,right,bottom]. Matlab array is usually y,x
            r = CenterRect([1 1 sz(1) sz(2)], [1 1 stimParams.stimSizePix]);
            data.nStrImg{ii}(r(1):r(3),r(2):r(4)) = uint8(tmp);
            data.nStrInds = Shuffle([1:numel(nStr)]);
        end
        % save to cache
        fName = mrvSelectFile('w','mat','Select file to save rendered stimuli');
        if isempty(fName)
            disp('User canceled saving rendered text.');
        else
            fontParams.stimFileCache = fName;
            save(fName,'data','wStr','nStr','stimParams');
            fprintf('Saved rendered stimuli to file: %s\n\n',fName);
        end
    end
    trial=[];   %Set this to nothing just so you can return
    data.curWStr=0;  %initialize curWStr
    data.curNStr=0;  %initialize curNStr
    
    if exist('tempData','var')
        data.wStrInds = tempData.wStrInds;
        data.nStrInds = tempData.nStrInds;
        data.curWStr = tempData.curWStr;
        data.curNStr = tempData.curNStr;
    end
    
    return;          %If it was in this if statement, it was before the first trial, so return.
end


%% Check which type of trial (word/nonword) and store current stimulus (curStrImg) %%
if(stimParams.wordType=='W')
    data.curWStr = data.curWStr+1;
    
    % If we've exhausted the list of words, repeat word list
    if(data.curWStr>numel(data.wStrInds))
        data.curWStr = 1;
        data.wStrInds = Shuffle(data.wStrInds);
        disp('NOTE: Repeating the word list.');
    end
    
    % Set current stimulus to the next word in the list
    curStrImg = data.wStrImg{data.wStrInds(data.curWStr)};
    % Store words that have been used
    data.word = wStr{data.wStrInds(data.curWStr)};
    data.wordType = 1;
    
elseif(stimParams.wordType=='N')
    data.curNStr = data.curNStr+1;
    
    % If we've exhausted the list of nonwords, repeat nonword list
    if(data.curNStr>numel(data.nStrInds))
        data.curNStr = 1;
        data.nStrInds = Shuffle(data.nStrInds);
        disp('NOTE: Repeating the nonword list.');
    end
    
    % Set current stimulus to the next nonword in the list
    curStrImg = data.nStrImg{data.nStrInds(data.curNStr)};
    % Store words that have been used
    data.word = nStr{data.nStrInds(data.curNStr)};
    data.wordType = 2;
    
end

% Update file of words that have been used already
save(loadFile, '-struct', 'data', 'wStrInds', 'nStrInds', 'curWStr' ,'curNStr');

%% Each frame will persist for an integer number of screen refreshes %%

numRefreshesPerFrame = round(stimParams.frameDuration * display.frameRate);
numFrames = round((display.frameRate * stimParams.duration)/numRefreshesPerFrame);

%% Create the movie out of curStrImg and send back as trial %%

% First check which condition we're in, and make the appropriate movie.
if strcmp(stimParams.conditionType, 'polar')
    mov = makeMoveDotForm(curStrImg, stimParams, numFrames);
    % Put the movie into stim.images
    for(ii=1:size(mov,4))
        stim.images{ii} = mov(:,:,:,ii);
    end
    
    % Create gray frame at end of movie to blank out stimulus
    finalFrame = zeros(size(stim.images{1}),'uint8');
    finalFrame(:) = stimParams.backRGB(1);
    stim.images{end+1} = finalFrame;
    
    clear mov;
    
    % See createStimulusStruct for required fields for stim
    stim.imSize = size(stim.images{1});
    stim.imSize = stim.imSize([2 1 3]);
    stim.cmap = [];
    
    % Replicate frames to produce desired persistence
    stim.seq = repmat([1:numFrames+1],[numRefreshesPerFrame 1]);
    stim.seq = stim.seq(:);
    stim.srcRect = [];
    % release the textures from the previous trial
    if(~isempty(data) && isfield(data,'stim') && isfield(data.stim,'textures'))
        Screen('Close', data.stim.textures);
    end
    stim = makeTextures(display, stim);
    data.stim = stim;
    
    c = display.numPixels/2;
    tl = round([c(1)-stim.imSize(1)/2 c(2)-stim.imSize(2)/2]);
    stim.destRect = [tl tl+stim.imSize(1:2)];
    
    trial = addTrialEvent(display,[],'stimulusEvent', 'stimulus', stim);
    
elseif strcmp(stimParams.conditionType,'contour')
    
    load(fullfile(fileparts(loadFile),'letters.mat'))
    img = wordGenerateImage(display,letters,data.word,'adjustImSize',stimParams.stimSizePix);
    invImg = (1-img).*255;  % get into the proper format for scrambleImage, and invert so text will be black
    
    % Convert into 255s using appropriate grayscales instead of mask
    img(img==0) = stimParams.backRGB(1);  % background-- should it be backRGB or outFormRGB?
    img(img==1) = stimParams.inFormRGB(1);  % change inForm shade of gray
    
    scrWordImg = scrambleImage(img,1-stimParams.scrambleLevel);
    %scrWordImg = scrambleWord(data.word,1-stimParams.scrambleLevel);  %we use 1-scramble level for Weibull
    
    blankImg = ones(size(scrWordImg))*128;  % gray (blank) image
    
    %% Create stim struct
    
    duration.stimframe  = stimParams.duration;
    sequence            = [1];
    timing              = [duration.stimframe];
    cmap                = display.gammaTable;
    fixSeq              = ones(size(sequence));
    
    stim        = createStimulusStruct(scrWordImg,cmap,sequence,[],timing,fixSeq);
    stim        = createTextures(display, stim);
    blankstim        = createStimulusStruct(blankImg,cmap,sequence,[],0.05,fixSeq);
    blankstim        = createTextures(display, blankstim);
    
    trial = addTrialEvent(display,[],'stimulusEvent', 'stimulus', stim);
    trial = addTrialEvent(display,trial,'ISIEvent', 'stimulus', blankstim, 'duration', stimParams.ISI);
else
    disp('No valid condition type is set.  Go set stimParams.conditionType in initWordParams.');
end



return