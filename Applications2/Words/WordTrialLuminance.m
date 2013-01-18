function [trial, data] = WordTrial(display, stimParams, data)
% trial = WordTrial(display, stimParams)


fontName = 'SansSerif';
fontSize = 8;  %regular value 18
sampsPerPt = 6; %regular value 12
antiAlias = 0;
fractionalMetrics = 0;
boldFlag = true;

if(isempty(data))
    % If data is empty, then we need to pre-generate the text renderings
    % (and then save to a mat file)

    wStr = {'This is a sentence.','I am not tired.','Oranges taste nice.','The apple is green.'};
    nStr = {'Gnow rodo is meab.','Noen eara teaf.'};
    %     wStr = {'arch',  'boss',  'coat',  'fact','rail'};
    %     nStr = {'twon', 'ceap', 'eara', 'gnow','cega'};
    %% All words and pseudowords
    %wStr = {'arch',  'boss',  'coat',  'fact',  'gulf',  'lamp',  'neon',  'rail',  'soul',  'wall',  'area',  'bowl',  'coin',  'fame',  'hair',  'lane',  'noon',  'ramp',  'soup',  'week',  'army',  'buck',  'cold',  'fate',  'half',  'lawn',  'nose',  'rice',  'star',  'west',  'aunt',  'bulb',  'cone',  'fist',  'hall',  'leaf',  'oven',  'road',  'tail',  'wife',  'baby',  'cafe',  'cork',  'flag',  'hawk',  'lens',  'pair',  'robe',  'tale',  'wine',  'ball',  'cage',  'corn',  'foam',  'herb',  'lion',  'palm',  'roof',  'task',  'wing',  'barn',  'cake',  'crew',  'foil',  'hero',  'loop',  'past',  'room',  'taxi',  'wood',  'bass',  'calf',  'crib',  'folk',  'hill',  'luck',  'pear',  'root',  'team',  'wool',  'bath',  'cape',  'deer',  'food',  'hole',  'maid',  'pile',  'sale',  'tent',  'yard',  'beam',  'card',  'desk',  'foot',  'home',  'male',  'pine',  'salt',  'text',  'yarn',  'bean',  'cart',  'diet',  'fork',  'hour',  'meal',  'pink',  'seal',  'tile',  'year', 'beef',  'cave',  'dirt',  'fort',  'idea',  'meat',  'pipe',  'seat',  'tire',  'zero',  'beer',  'cell',  'dish',  'gang',  'inch',  'menu',  'poem',  'shoe',  'tone',  'bell',  'cent',  'disk',  'gate',  'item',  'mess',  'poet',  'silk',  'tool',  'belt',  'chin',  'door',  'gene',  'king',  'mile',  'pole',  'site',  'tour',  'bird',  'chip',  'drum',  'gift',  'knee',  'mood',  'pond', 'snow',  'town',  'blue',  'city',  'duck',  'girl',  'knot',  'moon',  'pony',  'soap',  'tray', 'boat',  'clay',  'duty',  'goal',  'lace',  'myth',  'pool',  'sofa',  'tree',  'body',  'club',  'east',  'gold',  'lady',  'nail', ' port',  'soil',  'tube',  'bone',  'coal',  'echo',  'gown',  'lake',  'neck',  'rack',  'song',  'vein'};
    %nStr = {'abby', 'ceap', 'eara', 'gnow', 'kroc', 'meab', 'noen', 'rodo', 'teaf', 'twon', 'alem', 'cega', 'eida', 'gril', 'kucb', 'meaf', 'nomo', 'romo', 'teid', 'tyci', 'aloc', 'ceno', 'emss', 'harc', 'lawl', 'mepo', 'nono', 'ropt', 'teim', 'wein', 'alse', 'cino', 'enum', 'heco', 'lema', 'miad', 'nove', 'ruto', 'teno', 'weke', 'alte', 'ckud', 'etma', 'heso', 'lemi', 'mlap', 'nyra', 'sabs', 'tepo', 'wodo', 'arck', 'claf', 'fale', 'hids', 'leoh', 'moaf', 'parm', 'sbos', 'tere', 'wrec', 'atem', 'cluk', 'faos', 'hlal', 'lepi', 'moeh', 'pepi', 'slea', 'tesa', 'xait', 'avec', 'cnih', 'feiw', 'horu', 'lepo', 'murd', 'pich', 'slen', 'tesi', 'xett', 'befe', 'crad', 'fgit', 'hroe', 'lian', 'nale', 'plam', 'slik', 'thab', 'yonp', 'bero', 'cron', 'flah', 'hwak', 'llab', 'narb', 'puso', 'sopa', 'tial', 'yrat', 'birc', 'dary', 'flug', 'hymt', 'llec', 'nawl', 'ract', 'srat', 'tiel', 'zore', 'blel', 'dere', 'foro', 'kast', 'llih', 'neab', 'raih', 'sulo', 'tisf', 'blet', 'dirb', 'frok', 'keal', 'loga', 'nect', 'raip', 'swet', 'tlas', 'bluc', 'dloc', 'geen', 'keca', 'loif', 'neek', 'rali', 'swon', 'tnet', 'breh', 'doby', 'glaf', 'kesd', 'lois', 'neiv', 'ramy', 'tabo', 'toca', 'buel', 'domo', 'glod', 'kisd', 'loow', 'nepi', 'raye', 'tacf', 'toof', 'buet', 'donp', 'gnag', 'klof', 'lopo', 'neso', 'reci', 'tage', 'toor', 'cale', 'doof', 'gnik', 'knec', 'loto', 'nich', 'reeb', 'tase', 'torf', 'caly', 'dora', 'gniw', 'knip', 'lowb', 'nilo', 'repa', 'tasp', 'trid', 'ceaf', 'dyla', 'gnos', 'kont', 'lubb', 'nobe', 'reti', 'taun', 'tudy'};
    % Check the cache file first
    if(exist(stimParams.stimFileCache,'file'))
        disp('Loading stim cache...');
        tmp = load(stimParams.stimFileCache);
        % make sure cache is valid
        if(numel(wStr)==numel(tmp.wStr) && numel(nStr)==numel(tmp.nStr))
            data = tmp.data;
            data.wStrInds = Shuffle([1:numel(wStr)]);
            data.nStrInds = Shuffle([1:numel(nStr)]);
        else
            disp('Invalid stim cache- regenerating...');
        end
        clear tmp;
    end
    % If data is still empty, that means either, the cache file didn't
    % exist, or it existed but was invalid. Either way, we have to generate
    % the stimulus images.
    if(isempty(data))  %then renderText to make the word stimuli
        for(ii=1:length(wStr))
            tmp = renderText(wStr{ii}, fontName, fontSize, sampsPerPt, antiAlias, fractionalMetrics, boldFlag);
            sz = size(tmp);
            if(any(sz>stimParams.stimSizePix))
                r = stimParams.stimSizePix(1);
                c = stimParams.stimSizePix(2);
                error('Largest stimulus exceeds specificed stimulus size (%d %d).',r,c);
            end
            data.wStrImg{ii} = zeros(stimParams.stimSizePix, 'uint8');
            % rect is [left,top,right,bottom]. Matlab array is usually y,x
            r = CenterRect([1 1 sz(1) sz(2)], [1 1 stimParams.stimSizePix]);
            data.wStrImg{ii}(r(1):r(3),r(2):r(4)) = uint8(tmp);
            data.wStrInds = Shuffle([1:numel(wStr)]);
        end

        for(ii=1:length(nStr)) % and make the nonword stimuli
            tmp = renderText(nStr{ii}, fontName, fontSize, sampsPerPt, antiAlias, fractionalMetrics, boldFlag);
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
        save(stimParams.stimFileCache,'data','wStr','nStr');
    end
    trial=[];   %Set this to nothing just so you can return
    data.curWStr=0;  %initialize curWStr
    data.curNStr=0;  %initialize curNStr
    return;          %If it was in this if statement, it was before the first trial, so return.
end
if(stimParams.wordType=='W')
    data.curWStr = data.curWStr+1;
    if(data.curWStr>numel(data.wStrInds))
        data.curWStr = 1;
        data.wStrInds = Shuffle(data.wStrInds);
        disp('NOTE: Repeating the word list.');
    end
    curStrImg = data.wStrImg{data.wStrInds(data.curWStr)};
elseif(stimParams.wordType=='N')
    data.curNStr = data.curNStr+1;
    if(data.curNStr>numel(data.nStrInds))
        data.curNStr = 1;
        data.nStrInds = Shuffle(data.nStrInds);
        disp('NOTE: Repeating the nonword list.');
    end
    curStrImg = data.nStrImg{data.nStrInds(data.curNStr)};
end


% Each frame will persist for an integer number of screen refreshes
numRefreshesPerFrame = round(stimParams.frameDuration * display.frameRate);
numFrames = round((display.frameRate * stimParams.duration)/numRefreshesPerFrame);

%% Create the movie
% In this luminance case, this is a still movie but structure the same way
% as for a moving dot font.

mov = makeLuminanceDotForm(curStrImg, stimParams.coherence, stimParams.dotDensity, numFrames, stimParams.formDir, stimParams.backDir, stimParams.inFormRGB, stimParams.outFormRGB, stimParams.backRGB);

for(ii=1:size(mov,4))
    stim.images{ii} = mov(:,:,:,ii);
end
%create gray frame at end of movie to blank out stimulus
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
    data.imSize = sz;
    clear('img');
    data = makeTextures(display, data);
else
    % the stimulus exists in data, so we just need to update the cmaps and seq
    data.cmap = cmap;
    data.seq = seq;
end
clear('cmap');
clear('seq');

sz = data.imSize;
c = display.numPixels/2;
eccenPix = round(angle2pix(display, stimParams.eccentricity));
if stimParams.testPosition == 'L'
    % left, top, right, bottom
    data.destRect = round([c(1)-sz(1)/2-eccenPix c(2)-sz(2)/2]);
else
    data.destRect = round([c(1)-sz(1)/2+eccenPix c(2)-sz(2)/2]);
end
data.destRect = [data.destRect data.destRect+sz];

% build the trial
trial = addTrialEvent(display,[],'stimulusEvent', 'stimulus', data);


return;