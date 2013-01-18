function [sequence] = cocImageSequence(params)

numCycles             = params.numCycles; if mod(numCycles, 2) == 1; error('need even number of cycles'); end
numImagesPerCycle     = round(1/params.stimulus.frequency / params.stimulus.stimframe);
numImages             = numImagesPerCycle * numCycles /2;
blankScreen           = numImages + 1;
durationStimframe     = params.stimulus.stimframe;
nStimFramesPerScan    = params.ncycles*params.period.*2./durationStimframe;
nStimframesPrescan    = round(params.prescanDuration./durationStimframe);
nStimframesPerCycle   = round(params.period./durationStimframe);

%initialize the scan sequence as a series of blank screens
sequence   = zeros(nStimFramesPerScan+nStimframesPrescan,1)+blankScreen;

%define the image sequence for one luminance cycle (probably about 1s) 
oneLuminanceCycle = 1:numImagesPerCycle;

%calculate number of luminance cycles in each on-cycle (probably about 12)
n = ceil(nStimframesPerCycle/length(oneLuminanceCycle));

%define the image sequence for each on-cycle
oneOnCycle = repmat(oneLuminanceCycle, 1, n);

%clean up in case num luminance cycles per on-cycle is not an integer
oneOnCycle = oneOnCycle(1:round(nStimframesPerCycle));

%define the image sequence for the whole scan
ii = nStimframesPrescan;

% set levels for each cycle
inds = round(1:numCycles/2);
level(inds) = inds-1;
level(inds+max(inds)) = fliplr(inds-1);

for n=1:numCycles,
    %sequence(ii+1:ii+nStimframesPerCycle) = oneOnCycle;    
    sequence(ii+1:ii+nStimframesPerCycle) = oneOnCycle + numImagesPerCycle * level(n);
    ii = ii+nStimframesPerCycle.*2;
end; 

return