function stim = cornsweetPlotImages(params, stim, ii)

rows = params.nRows;
cols = params.nCols;

t  = 2*pi*ii/params.framesPerCycle;

% luminance modulation
if params.modLuminance, lum = sin(t); else lum = 1; end
realEdge = stim.realEdge * lum + .5;
cocEdge  = stim.cocEdge  * lum + .5;
mixture  = stim.mixture  * lum + .5;

% rotation modulation
if params.modRotation, 
    rot = rad2deg(t); 
    realEdge = imrotate(realEdge, rot, 'crop'); 
    cocEdge  = imrotate(cocEdge,  rot, 'crop');
    mixture  = imrotate(mixture,  rot, 'crop');
end

% add noise
if params.addNoise, 
    noise = rand(size(realEdge)); 
    noise = noise - mean(noise(:)); 
    noise = noise * params.amplitude;

    realEdge = realEdge + noise; 
    cocEdge = cocEdge + noise; 
    mixture = mixture + noise; 
end

% mask
realEdge = stim.mask  .* realEdge;
cocEdge  = stim.mask  .* cocEdge;
mixture  = stim.mask  .* mixture;

% plot
ii = 1;
colormap gray;


if rows*cols > 1, useSubs = true; else useSubs = false; end

if params.showSquareWave,
    subplot(rows, cols, ii);
    if ~useSubs, imagesc(realEdge, [0 1]), else imshow(realEdge); end
    title('square wave'); axis image off;
    ii = ii +1;
end

if params.showCOC,
    subplot(rows, cols, ii);
    if ~useSubs, imagesc(cocEdge, [0 1]), else imshow(cocEdge); end
    title('c-o-c'); axis image off;
    ii = ii +1;
end

if params.showMixture,
    subplot(rows, cols, ii);
    if ~useSubs, imagesc(mixture, [0 1]), else imshow(mixture); end
    title('null'); axis image off;
end

stim.thisrealEdge = realEdge;
stim.thiscocEdge  = cocEdge;
stim.thismixture  = mixture;

end