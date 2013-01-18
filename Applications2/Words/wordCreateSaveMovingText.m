function [wordData, stimParams] = wordCreateSaveMovingText(stimParams,wStr,nwStr)
%Creates data structure with information needed for the text movie
%
%   [wordData, stimParams] = wordCreateSaveMovingText(stimParams,wStr,nwStr)
%
%
% wStr = {'arch',  'boss'};
% nwStr = {'twon', 'ceap'};
% stimParams = initWordParams('mr');
% wordData = wordCreateSaveMovingText(stimParams,wStr,nwStr);

%%
% Initialize parameters for legibility
fontName   = stimParams.fontName;
fontSize   = stimParams.fontSize;
sampsPerPt = stimParams.sampsPerPt;
antiAlias  = stimParams.antiAlias;
fractionalMetrics = stimParams.fractionalMetrics;
boldFlag = stimParams.boldFlag;

%%
% If wordData is still empty, that means either, the cache file didn't
% exist, or it existed but was invalid. Either way, we have to generate
% the stimulus images.

% Create renderings for the word strings
for ii=1:length(wStr)
    tmp = renderText(wStr{ii}, fontName, fontSize, sampsPerPt, antiAlias, fractionalMetrics, boldFlag);
    
    % Check if the stimulus is too large a stimulus
    sz = size(tmp);
    if(any(sz>stimParams.stimSizePix))
        r = stimParams.stimSizePix(1);
        c = stimParams.stimSizePix(2);
        error('Largest stimulus exceeds specificed stimulus size (%d %d).',r,c);
    end
    % imtool(tmp)
    wordData.wStrImg{ii} = zeros(stimParams.stimSizePix, 'uint8');
    
    % rect is [left,top,right,bottom]. Matlab array is usually y,x
    r = CenterRect([1 1 sz(1) sz(2)], [1 1 stimParams.stimSizePix]);
    wordData.wStrImg{ii}(r(1):r(3),r(2):r(4)) = uint8(tmp);
    
    % Give a random presentation order for the list of word stimuli
    wordData.wStrInds = Shuffle((1:numel(wStr)));  % maybe should be done outside the loop?

    
% amr started to try to make series of movies -- right now, we only have
% the rendered text as an output to this function, but we want movies
%     % Make movies out of all the word rendered texts
%     mov = makeMoveDotForm(wordData.wStrImg{ii}, stimParams, numFrames);
%     
%     % Put the movie into stim.images
%     for(jj=1:size(mov,4))
%         stim.images{jj} = mov(:,:,:,jj);
%     end
% 
%     % Create gray frame at end of movie to blank out stimulus
%     finalFrame = zeros(size(stim.images{1}),'uint8');
%     finalFrame(:) = stimParams.backRGB(1);
%     stim.images{end+1} = finalFrame;
% 
%     clear mov;
% 
%     % See createStimulusStruct for required fields for stim
%     stim.imSize = size(stim.images{1});
%     stim.imSize = stim.imSize([2 1 3]);
%     stim.cmap = [];
% 
%     % Replicate frames to produce desired persistence
%     stim.seq = repmat([1:numFrames+1],[numRefreshesPerFrame 1]);
%     stim.seq = stim.seq(:);
%     stim.srcRect = [];
%     stim = makeTextures(display, stim);
% 
%     c = display.numPixels/2;
%     tl = round([c(1)-stim.imSize(1)/2 c(2)-stim.imSize(2)/2]);
%     stim.destRect = [tl tl+stim.imSize(1:2)];
% 
%     wordData.movies{ii} = addTrialEvent(display,[],'stimulusEvent', 'stimulus', stim);
end

% Create renderings for the non-word strings
for ii=1:length(nwStr)
    tmp = renderText(nwStr{ii}, fontName, fontSize, sampsPerPt, antiAlias, fractionalMetrics, boldFlag);
    sz = size(tmp);
    if(any(sz>stimParams.stimSizePix))
        r = stimParams.stimSizePix(1);
        c = stimParams.stimSizePix(2);
        error('Largest stimulus exceeds specificed stimulus size (%d %d).',r,c);
    end
    wordData.nwStrImg{ii} = zeros(stimParams.stimSizePix, 'uint8');
    % rect is [left,top,right,bottom]. Matlab array is usually y,x
    r = CenterRect([1 1 sz(1) sz(2)], [1 1 stimParams.stimSizePix]);
    wordData.nwStrImg{ii}(r(1):r(3),r(2):r(4)) = uint8(tmp);
    wordData.nwStrInds = Shuffle((1:numel(nwStr)));
    
%     % Make movies out of all the nonword rendered texts
%     wordData.nwMovies{ii} = makeMoveDotForm(wordData.nwStrImg{ii}, stimParams, numFrames);
%     
end


wordData.curWStr=0;  %initialize curWStr
wordData.curNStr=0;  %initialize curNStr

% save to cache
data = wordData;
fName = stimParams.stimFileCache;
if isempty(fName) || ~exist(fName,'file')
    fName = mrvSelectFile('w','mat',[],'Select file to save rendered stimuli');
    stimParams.stimFileCache = fName;
end

save(fName,'data','wStr','nwStr');
disp('Saved rendered stimuli to: '); disp(fName);

return;
