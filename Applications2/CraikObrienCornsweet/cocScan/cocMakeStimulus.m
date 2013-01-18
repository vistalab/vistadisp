function [stimulus] = cocMakeStimulus(params)
% cocMakeStimulus : Craik-O'Brien-Cornsweet edge

duration.stimframe = params.stimulus.stimframe;

if isfield(params, 'showProgess'),
    showProgress = params.showProgess;
else,
    showProgress = false;
end

%make images and image sequence
switch lower(params.type)
    case'localizer'
        [images sequence, timing] = cocMakeCheckerboard(params);
    case 'text'
        [images sequence, timing] = cocDisplayText(params);
    case {'coc','squarewave','edgeonly','uniform',}
        im          = cocSingleFrame(params.stimulus, params.display);
        images      = cocMultipleFrames(im, params.stimulus, params.display, params, showProgress);
        sequence    = cocImageSequence(params);
        timing      = (0:length(sequence)-1)'.*duration.stimframe;
        createFigure(images, params.type)
    otherwise
        error('unknown stimulus type')
end

fixSeq  = cocFixationSequence(params, sequence);

% make stimulus structure for output
cmap     = params.display.gammaTable;
stimulus = createStimulusStruct(images,cmap,sequence,[],timing,fixSeq);

% save matrix if requested
if ~isempty(params.saveMatrix),
    save(params.saveMatrix,'images');
end

% ----------------------------------------
% ////////////////////////////////////////
% ----------------------------------------


% DEBUG
function createFigure(images, imType)


sz = size(images);

im = zeros(sz(3), sz(2));

for ii = 1:sz(3)
   
    im(ii,:) = images(round(sz(1)/2), : ,ii);
    
end

f = figure;

subplot(2,1,1)
imagesc(im); colormap gray
hold on;
plot([sz(2)/2 sz(2)/2], [0 sz(3)], 'k-')
zlim([0 255])

subplot(2,1,2);
hold on
c = jet(sz(3));

for ii = 1:sz(3)
    plot(im(ii,:), 'Color', c(ii,:))
end

plot([sz(2)/2 sz(2)/2], [0 255], 'k-')
ylim([0 255])

suptitle(imType);

return