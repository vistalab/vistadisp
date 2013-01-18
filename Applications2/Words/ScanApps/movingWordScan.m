% Check input variables
if(~exist('coherence','var') || isempty(coherence)), coherence = 1; end;
if(~exist('form','var') || isempty(form))
    % Default form is a square
    form  = zeros(100,100);
    [x,y] = meshgrid([25:75],[25:75]);
    form(sub2ind(size(form),x,y)) = 1;
end;
if(~exist('dotDensity','var') || isempty(dotDensity)), dotDensity = 0.1; end;
if(~exist('numFrames','var')  || isempty(numFrames)),  numFrames = 32; end;
if(~exist('formDir','var')    || isempty(formDir)),    formDir = 90; end;
if(~exist('backDir','var')    || isempty(backDir)),
    if formDir>=180, backDir = formDir-180;
    else             backDir = formDir+180;
    end
end
if ~exist('stillBackground','var') || isempty('stillBackground'), stillBackground = 0; end

inFormRGB = [255 255 255];  %[255 255 255]
backRGB = [128 128 128];  %[128 128 128] for gray background
outFormRGB = [255 255 255];

display = loadDisplayParams('displayName', 'NEC485words.mat');
display.windowPtr=1;
stairParams

wStr = {'arch',  'boss'};
            
fontName = 'SansSerif';
fontSize = 8;  %regular value 8
sampsPerPt = 6; %regular value 6
antiAlias = 0;
fractionalMetrics = 0;
boldFlag = true;

% Make movies
%for ii=1:2
for(ii=1:length(wStr))
    form= renderText(wStr{ii}, fontName, fontSize, sampsPerPt, antiAlias, fractionalMetrics, boldFlag);
end
mov = makeMoveDotForm(form,coherence,dotDensity,numFrames,formDir,backDir,inFormRGB,outFormRGB,backRGB, stillBackground);
%end

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


% the following code is from doTrial.m
material = trial{eventNum,2};


[response, stimTime] = showStimulus(display, material.stimulus);
response = getKeyLabel(response);

% Display movies