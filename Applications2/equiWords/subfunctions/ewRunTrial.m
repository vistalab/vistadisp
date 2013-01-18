function [trial, data] = ewRunTrial(display, stimParams, data)

% Check for an image field in data.  If it doesn't exist, data has yet to
% be initialized.
if(~isfield(data,'letters'))
    % Check for word list
    [data,stimParams.listFile] = ewCheckFile(stimParams.listFile, 'Word Lists');
    
    % Check for the cache file, load if it exists
    [cache,stimParams.letterImages] = ewCheckFile(stimParams.letterImages, 'Letter Images', 1);
    % If cache is empty, we still need to get some images to work with
    if isempty(cache)
        % Generate the images
        data.letters = genLetterVar(stimParams);
        
        % If a file name is indicated but cache was empty (as seen
        % earlier), then the intent of the user was to save a new cache
        % file, so we perform this action
        if ~isempty(stimParams.letterImages)
            paramsAtGeneration = stimParams;
            save(stimParams.letterImages,'data','paramsAtGeneration');
            fprintf('Saved letter images to file:\n%s\n',stimParams.letterImages);
        end
    % If cache had something in it, then stuff was loaded.  Get it ready
    else
        data.letters = cache.data.letters;
        clear cache;
        fprintf('Loaded letter images from file:\n%s\n',stimParams.letterImages);
    end
    
    % Check for the history file, and load if it exists
    if exist(stimParams.indHistory,'file')
        tmp = load(stimParams.indHistory);
        data.wStrInds   = tmp.wStrInds;
        data.nStrInds   = tmp.nStrInds;
        data.curWStr    = tmp.curWStr;
        data.curNStr    = tmp.curNStr;
    % Otherwise, start from the beginning
    else
        data.wStrInds   = Shuffle(1:numel(data.wList));
        data.nStrInds   = Shuffle(1:numel(data.nList));
        data.curWStr    = 1;
        data.curNStr    = 1;
    end
    
    trial = [];
    return;          %If it was in this if statement, it was before the first trial, so return.
end

if strcmp(stimParams.wordType,'W')
    data.stimType   = 1;
    data.stimIndex  = data.wStrInds(data.curWStr);
    data.stimWord   = data.wList{data.stimIndex};
elseif strcmp(stimParams.wordType,'N')
    data.stimType   = 2;
    data.stimIndex  = data.nStrInds(data.curNStr);
    data.stimWord   = data.nList{data.stimIndex};
end

[data,curStrImg]    = ewProcessTrial(display,data,stimParams);

save(stimParams.indHistory, '-struct', 'data', 'wStrInds', 'nStrInds', 'curWStr' ,'curNStr');

% Clear up the memory
if(isfield(data,'stim'))% && isfield(data,'precue'))
    Screen('Close', data.stim.textures);
    %Screen('Close', data.precue.textures);
end

data.stim           = ewGenerateStim(display,stimParams,curStrImg);
%data.precue         = ewGeneratePrecue(display,stimParams);
data.distance       = stimParams.distance;
data.angle          = stimParams.angle;
data.wordRGB        = stimParams.wordRGB;

%trial               = addTrialEvent(display,[],'stimulusEvent', 'stimulus', data.precue);
trial               = addTrialEvent(display,[],'stimulusEvent', 'stimulus', data.stim);

