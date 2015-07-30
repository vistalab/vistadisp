function [params, stimulus] = retLoadEmoji(params, stimulus)

emojiPth = fullfile(vistadispRootPath,'Applications2', 'Retinotopy', 'standard', 'emoji');
d = dir(fullfile(emojiPth, '*.png'));

assert(numel(d)>0)

[x,y] = meshgrid(linspace(-1, 1, params.display.fixSizePixels));
maskblob = 255*(x.^2+y.^2<1);

for ii = 1:length(d)
    im = imread(fullfile(emojiPth, d(ii).name));
    im = im(7:121, 2:116,:);
    im = imresize(im, [1 1]* params.display.fixSizePixels);
    im(:,:,end+1) = maskblob;
    fixStimulus.images{ii} = im;
end

params.display.rect = [0 0 params.display.numPixels];
params.display.fixationStimulus = makeTextures(params.display, fixStimulus);


% make Rects
params.display.fixationStimulus.srcRect = [0,0,size(im, 2), ...
    size(im, 1)];
if ~isfield(params.display,'destRect'),
    params.display.fixationStimulus.destRect = ...
        CenterRect(params.display.fixationStimulus.srcRect, params.display.rect);
else
    params.display.fixationStimulus.destRect = CenterRect(params.display.destRect, params.display.rect);
end


%% correct fixation sequence so it is mostly ones, and occasionally twos, rather than long sequences of ones and twos
seq = [0; diff(stimulus.fixSeq)];
stimulus.fixSeq = ones(size(stimulus.fixSeq));
inds = find(seq);
for ii = 0:5
    stimulus.fixSeq(inds+ii) = 2;
end

return