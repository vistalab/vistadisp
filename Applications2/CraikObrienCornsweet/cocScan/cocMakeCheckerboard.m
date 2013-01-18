function [images sequence, timing] = cocMakeCheckerboard(params)


stimulus = params.stimulus;
display = params.display;

%timing
numCycles           = params.numCycles;
temporalFrequency   = 4;
durationStimframe   = 1 / temporalFrequency;
nStimFramesPerScan  = numCycles*params.period.*2./durationStimframe;
nStimframesPrescan  = round(params.prescanDuration./durationStimframe);
nStimframesPerCycle = round(params.period./durationStimframe);
nStimframesTotal    = nStimFramesPerScan + nStimframesPrescan;

%image
stimsize            = stimulus.radius;
m                   = angle2pix(display,stimsize)*2; %(width in pixels)
n                   = angle2pix(display,stimsize)*2; %(height in pixels)
[x,y]               = meshgrid(linspace(-stimsize,stimsize,n),linspace(stimsize,-stimsize,m));
curvature           = stimulus.curvatureAmp;




edgeShift           = curvature -  abs(sin((1:m)' * ones(1, n) *pi/m))*curvature + stimulus.fixationEcc;
edgeShift           = edgeShift * stimulus.fixationSide;
checkSize           = 18;
numImages           = 5;


minCmapVal          = min([display.stimRgbRange]);
maxCmapVal          = max([display.stimRgbRange]);

images =    zeros(m,n,numImages,'uint8');
tmp    =    zeros(m,n,numImages);


% make mask
mask = ((x + edgeShift) < 0);

% make a checkerboard
im = zeros(size(x))-1;


for ii = 1:checkSize*2:size(x,1)
    for j = 1:2*checkSize:size(x,2)   
        im((1:checkSize)+ii, (1:checkSize)+j) = 1;%odd rows
        im((1:checkSize)+ii+checkSize, (1:checkSize)+j+checkSize) = 1;%even rows
    end
end

%limit the size
im = im(1:size(x,1), 1:size(x,2));

%make 4 checkers (2 contrast polarities and 2 masked sides)
tmp(:,:,1)   =  (im.* mask);
tmp(:,:,2)   = (-im).* mask;
tmp(:,:,3)   = im.* (1-mask);
tmp(:,:,4)   = (-im).* (1-mask);
tmp(:,:,end) = im * 0;

for ii = 1:5
    images(:,:,ii)   = minCmapVal+ceil((maxCmapVal-minCmapVal) .* (tmp(:,:,ii)+1)./2);
end



%define the image sequence for each on-cycle

for ii = 1:2:nStimframesTotal
    sequence(ii) = 1;
    sequence(ii+1) = 2;
end


ii = nStimframesPrescan;
for n=1:numCycles,
    sequence(ii+1:ii+nStimframesPerCycle) = sequence(ii+1:ii+nStimframesPerCycle) +2;
    ii = ii+nStimframesPerCycle.*2;
end; 

timing   = [0:length(sequence)-1]'.*durationStimframe;