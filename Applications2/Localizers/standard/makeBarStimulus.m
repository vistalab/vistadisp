function [stimulus, onebackSeq] = makeBarStimulus(params);
% makeBarStimulus

% various time measurements:
% confusingly cycle == blocklength here, so really cycle =
% 2*(the numbe rreported here)
duration.stimframe          = 1./params.temporal.frequency./params.temporal.motionSteps;
duration.scan.seconds       = params.ncycles*params.period.*2;
duration.scan.stimframes    = params.ncycles*params.period.*2./duration.stimframe;
duration.cycle.seconds      = params.period;
duration.cycle.stimframes   = params.period./duration.stimframe;
duration.prescan.seconds    = params.prescanDuration;
duration.prescan.stimframes = params.prescanDuration./duration.stimframe;

stimsize = params.radius;
barwidth = 3; % degrees (about)

numImages = 4;
numMotSteps = params.temporal.motionSteps;

bk = params.display.backColorIndex;

minCmapVal = min([params.display.stimRgbRange]);
maxCmapVal = max([params.display.stimRgbRange]);


%%% Initialize image template %%%
m=angle2pix(params.display,2*stimsize);
n=angle2pix(params.display,2*stimsize);

% here we crop the image if it is larger than the screen
% seems that you have to have a square matrix, bug either in my or
% psychtoolbox' code - so we make it square
[x,y]=meshgrid(linspace(-stimsize,stimsize,n),linspace(stimsize,-stimsize,m));
if m>params.display.numPixels(2),
    start  = round((m-params.display.numPixels(2))/2);
    len    = params.display.numPixels(2);
    y = y(start+1:start+len, start+1:start+len);
    x = x(start+1:start+len, start+1:start+len);
    m = len;
    n = len;
end;
disp(sprintf('[%s]:size stimulus: %dx%d pixels.',mfilename,n,m));

% make a circular mask
mask = makecircle(m);

% take into account barwidth
barwidthpixels = angle2pix(params.display,barwidth);
x = x./(barwidth.*2);
y = y./(barwidth.*2);
mymax = max(x(:));
x = x./mymax.*round(mymax);
mymax = max(y(:));
y = y./mymax.*round(mymax);

% orientation
orientations = (2*pi)/8*[0:3]; % degrees -> rad
original_x   = x;
original_y   = y;

% Loop that creates the final images
fprintf('[%s]:Creating %d images:',mfilename,numImages);
images=zeros(m,n,numImages.*params.temporal.motionSteps+1,'uint8');
startphase = (2*pi)/numMotSteps*[0:numMotSteps-1];
for imgNum=1:numImages,
    y = original_x .* sin(orientations(imgNum)) + original_y .* cos(orientations(imgNum));
    for ii=1:numel(startphase),
        %tmp = sign(2*round((cos(y*(2*pi)+startphase(ii))+1)/2)-1).*mask;
        tmp = cos(y*(2*pi)+startphase(ii)).*mask;
        iii = (imgNum-1)*numel(startphase)+ii;
        images(:,:,iii)=minCmapVal+ceil((maxCmapVal-minCmapVal) .* (tmp+1)./2);  
    end;
    fprintf('.');drawnow;
end;
% mean luminance
images(:,:,end) = images(:,:,end).*0+minCmapVal+ceil((maxCmapVal-minCmapVal)./2);
fprintf('Done.\n');drawnow;

    

% sequence
onebackSeq = zeros(duration.scan.stimframes+duration.prescan.stimframes,1);
sequence   = zeros(duration.scan.stimframes+duration.prescan.stimframes,1)+size(images,3);
mymotseq   = [reshape(1:32,8,4) flipud(reshape(1:32,8,4))];
%mymotseq   = [mymotseq;mymotseq.*0+33];
mymotseq   = [mymotseq;mymotseq(1:4,:); mymotseq(5:end,:).*0+33];
my1b       = zeros(duration.cycle.stimframes./duration.cycle.seconds,duration.cycle.seconds);
% one repeat
seq = round(rand(duration.cycle.seconds,100)*7)+1;
d   = sum(diff(seq)==0);
seq = seq(:,find(d==1));
while size(seq,2)<6,
    seq2 = round(rand(duration.cycle.seconds,100)*7)+1;
    d    = sum(diff(seq)==0);
    seq  = [seq seq2(:,find(d==1))];
end;

ii = duration.prescan.stimframes;
for n=1:params.numCycles,
    my1b(1,:) = [diff(seq(:,n)')==0 0];
    onebackSeq(ii+1:ii+duration.cycle.stimframes) = my1b(:);
    
    m = mymotseq(:,seq(:,n));
    sequence(ii+1:ii+duration.cycle.stimframes) = m(:);
    ii = ii+duration.cycle.stimframes.*2;
end; 

% fixation dot sequence
nn = 1./duration.stimframe*4; % on average every 4 seconds [max response time = 3 seconds]
fixSeq = ones(nn,1)*round(rand(1,ceil(length(sequence)/nn)));
fixSeq = fixSeq(:)+1;
fixSeq = fixSeq(1:length(sequence));
% force binary   q
fixSeq(fixSeq>2)=2; 
fixSeq(fixSeq<1)=1;


% make stimulus structure for output
timing   = [0:length(sequence)-1]'.*duration.stimframe;
cmap     = params.display.gammaTable;
stimulus = createStimulusStruct(images,cmap,sequence,[],timing,fixSeq);

% save matrix if requested
if ~isempty(params.saveMatrix),
    save(params.saveMatrix,'images');
end;



