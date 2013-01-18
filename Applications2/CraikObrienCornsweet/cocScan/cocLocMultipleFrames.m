function images = cocLocMultipleFrames(params, stimulus, params.display);
%not finished!!

%image properties
stimsize    = stimulus.radius;
m           = angle2pix(display,stimsize)*2; %(width in pixels)
n           = angle2pix(display,stimsize)*2; %(height in pixels)
[x,y]       = meshgrid(linspace(-stimsize,stimsize,n),linspace(stimsize,-stimsize,m));
curvature   = stimulus.curvatureAmp;
edgeShift   = curvature - ones(n,1) * abs(sin((1:n) *pi/n))*curvature;
edgeShift   = edgeShift * stimulus.fixationSide;
edgeAmp     = stimulus.edgeAmplitdue;
imagesc     = zeros(m,n,numImages+1,'uint8');
numImages   = 10;

images =    zeros(m,n,numImages,'uint8');

%% timing
%duration.scan.stimframes    = params.ncycles*params.period.*2./params.stimulus.stimframe;

%% make mask
mask = ((x + edgeShift') < 0) * 2 - 1;

%% make a checkerboard
im = 