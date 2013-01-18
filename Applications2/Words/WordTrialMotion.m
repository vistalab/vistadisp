function [trial, wordData] = WordTrialMotion(display, stimParams, wordData)
% Create trial structure used in psychophysical staircase
%
%     trial = WordTrial(display, stimParams, wordData)
%
% display:  Physical display
% params:   initWordParams
% wordData:     


%% If wordData is empty, we need to generate text renderings.
if isempty(wordData), wordData = wordCreateSaveMovingText(); return; end


%% If we have our text renderings, check which type of trial (word/nonword) and store current stimulus (curStrImg)
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
end


%% Create the movie out of curStrImg and send back as trial

% First check which condition we're in, and make the appropriate movie.
if strcmp(stimParams.conditionType, 'motion')  %case of motion dot defined forms
    mov = makeMoveDotForm(curStrImg, stimParams, numFrames);
elseif strcmp(stimParams.conditionType, 'luminance')  %case of luminance dot defined forms
    mov = makeLuminanceDotForm(curStrImg, stimParams, numFrames);
else
    disp('No valid condition type is set.  Go set stimParams.conditionType in initWordParams.');
end


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
stim = makeTextures(display, stim);

c = display.numPixels/2;
tl = round([c(1)-stim.imSize(1)/2 c(2)-stim.imSize(2)/2]);
stim.destRect = [tl tl+stim.imSize(1:2)];

trial = addTrialEvent(display,[],'stimulusEvent', 'stimulus', stim);


return;


%% Other things currently unused

numStimColors = display.stimRgbRange(2)-display.stimRgbRange(1)+1;
% We want to guarantee that the stimulus is modulated about the background
midStimColor = display.backColorIndex;
% display.gamma contains the gamma values needed to achieve each of
% numGammaEntries luminances, in a linear map. Thus, numGammaEntries/2 will
% yield the mean luminance, 1 will yield the minimum luminance, and
% numGammaEntries will yield the max luminance.
numGammaEntries = size(display.gamma,1);
midGammaIndex = round(numGammaEntries/2);
halfStimRange = stimParams.contrast*(numGammaEntries-1)*0.5;
gammaIndices = linspace(-halfStimRange, halfStimRange, numStimColors)+midGammaIndex;

cmap = zeros(display.maxRgbValue+1,3,1);

cmap(display.stimRgbRange(1)+1:display.stimRgbRange(2)+1,:) = display.gamma(round(gammaIndices),:);
% poke in reserved colors
cmap(1,:) = [0 0 0];
cmap(end,:) = [1 1 1];
% poke in the exact background color so that we can be sure it is in the
% center of the cmap (it might not be due to rounding).
cmap(display.backColorIndex, :) = display.gamma(midGammaIndex, :);

% Create the sequence
numFrames = round(display.frameRate * stimParams.duration);
seq = [-1 (1:numFrames+1)];

% Compute the images (if needed)
% only compute images if they don't exist yet (we aren't manipulating anything that
% requires recomputing the images, only the colormaps need to be recomputed).
if(~exist('data','var') | isempty(data))
    % Generate images for both positions
    radiusPix = 2*floor(angle2pix(display, stimParams.size/2)/2)+1;
    spreadPix =  2*floor(angle2pix(display, stimParams.spread)/2)+1;

    [x,y] = meshgrid(-radiusPix:radiusPix,-radiusPix:radiusPix);
    sz = size(x);

    if strcmp(stimParams.temporalEnvelopeShape,'gaussian')
        t = stimParams.temporalSpread/stimParams.duration;
        temporalWindow = exp(-.5*(([.5:numFrames]-numFrames/2)./(t*numFrames)).^2);
    else
        temporalWindow = ones(1,numFrames);
        len = ceil((stimParams.duration-stimParams.temporalSpread)/2*display.frameRate);
        endWin = (cos([0:len]/len*pi)+1)/2;
        temporalWindow(end-len+1:end) = endWin;
        temporalWindow(1:len) = fliplr(endWin);
    end

    sf = stimParams.cyclesPerDegree*display.pixelSize*2*pi;
    phaseInc = stimParams.cyclesPerSecond/display.frameRate*2*pi;
    angle = stimParams.orientDegrees*pi/180;
    a = cos(angle)*sf;
    b = sin(angle)*sf;
    img = cell(numFrames+1,1);
    phase = stimParams.phaseDegrees*pi/180;
    spatialWindow = exp(-((x/spreadPix).^2)-((y/spreadPix).^2));
    for ii=1:numFrames
        phase = phase+phaseInc;
        img{ii} = temporalWindow(ii)*spatialWindow.*sin(a*x+b*y+phase);
    end
    img{numFrames+1} = zeros(sz);
    % compute grating
    %img(:,:) = exp(-((x/spreadPix).^2) - ((y/spreadPix).^2)) ...
    %			.* sin(x*.5*stimParams.cycles/radiusPix*2*pi);
    % scale to the appropriate cmap range
    for(ii=1:length(img))
        img{ii} = uint8(round(img{ii}.*(numStimColors/2-1)+midStimColor));
    end

    data = createStimulusStruct(img, cmap, seq, []);
    wordData.imSize = sz;
    clear('img');
    data = makeTextures(display, data);
else
    % the stimulus exists in data, so we just need to update the cmaps and seq
    wordData.cmap = cmap;
    wordData.seq = seq;
end
clear('cmap');
clear('seq');

sz = wordData.imSize;
c = display.numPixels/2;
eccenPix = round(angle2pix(display, stimParams.eccentricity));
if stimParams.testPosition == 'L'
    % left, top, right, bottom
    wordData.destRect = round([c(1)-sz(1)/2-eccenPix c(2)-sz(2)/2]);
else
    wordData.destRect = round([c(1)-sz(1)/2+eccenPix c(2)-sz(2)/2]);
end
wordData.destRect = [wordData.destRect wordData.destRect+sz];

% build the trial
trial = addTrialEvent(display,[],'stimulusEvent', 'stimulus', data);


return;