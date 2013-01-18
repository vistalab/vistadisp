% generate examples of nick's shape stimuli

level    = 100;
stimsize = 100;
inds     = linspace(-stimsize/2,stimsize/2, 200);
[x, y]   =  meshgrid(inds, inds);
targetX  = 0;
targetY  = 0;

f = figure;
for level = 700:100:1200
    figure(f); clf; colormap gray;
    for pair = 1:16
        [~, in] = makeShape(level, pair, stimsize, x, y, targetX, targetY);
        subplot(4,4, pair);
        imagesc(in)
        axis image off
        title(sprintf('Class %d', pair))
    end
    fname = sprintf('Shape-Stimuli-Level-%d', level);
    suptitle(fname)
    saveas(f, fname, 'tif')
end