function [images] = cocMultipleFrames(im, stimulus, display, params, showProgressFlag)

stimsize            = stimulus.radius;
numCycles           = params.numCycles; if mod(numCycles, 2) == 1; error('need even number of cycles'); end
numImagesPerCycle   = round(1/(stimulus.frequency * stimulus.stimframe));
numImages           = numImagesPerCycle * numCycles /2;
m                   = round(angle2pix(display,stimsize)*2); %(width in pixels)
n                   = round(angle2pix(display,stimsize)*2); %(height in pixels)
mask                = makecircle(m);
minCmapVal          = min([display.stimRgbRange]);
maxCmapVal          = max([display.stimRgbRange]);

if nargin == 4, showProgess = showProgressFlag; else showProgess = false; end

if showProgess,
    fprintf('[%s]:Creating %d images:',mfilename,numImages); 
end

if display.cmapDepth == 8,
    images=zeros(m,n,numImages+1,'uint8');
else
    images=zeros(m,n,numImages+1,'single'); % in case we have 10 bits?
end

startphase = 0;

level = linspace(0,1,numCycles/2+1).^2;
level = level(2:end);

for cycle = 1:numCycles/2;
    for imgNum=1:numImagesPerCycle,
        t = 2*pi*imgNum/numImagesPerCycle;
        y = im * sin(t+startphase) * level(cycle);
        tmp = y;% .* mask;
        ind = imgNum + (cycle-1) * numImagesPerCycle;
        if display.cmapDepth == 8,
            images(:,:,ind) = minCmapVal+ceil((maxCmapVal-minCmapVal) .* (tmp+1)./2);
        else
            % in case we have 10 bits, don't limit to integers
            images(:,:,ind) = minCmapVal+ (maxCmapVal-minCmapVal) .* (tmp+1)./2;
        end
        if showProgess,  fprintf('.');drawnow; end
    end;
end

% mean luminance
images(:,:,end) = images(:,:,end).*0+minCmapVal+ceil((maxCmapVal-minCmapVal)./2);

if showProgess, fprintf('Done.\n');drawnow; end

return


