function stim = ewGenerateStim(display,stimParams,curStrImg)

%{
stairParams.adjustableVarValues     = (10.^(0:-.4:-2)); %(10.^(0:-.04:-.8));
stairParams.curStairVars            = {'fixCondition', [11  12  13  21  22  23  ...
                                                        11  12  13  21  22  23  ...
                                                        11  12  13  21  22  23];...
                                       'distance',     [repmat(0,   1,6)        ...
                                                        repmat(2.5, 1,6)        ...
                                                        repmat(5,   1,6)]};

nVars                               = length(stairParams.adjustableVarValues);
maxVar                              = log10(stairParams.adjustableVarValues(nVars));
nStairs                             = length(stairParams.curStairVars{3});
nFixed                              = length(unique(stairParams.curStairVars{3}))/2;
levelVec                            = (maxVar/(nFixed-1))*((nFixed-1):-1:0);
stimParams.fixLevels                = 10.^levelVec(1:nFixed);

fix                     = floor(stimParams.fixCondition/10);
vary                    = rem(fix,2)+1;
level                   = mod(stimParams.fixCondition,10);

var1.min                = eval(sprintf('stimParams.min%s;',stimParams.vars{1}));
var1.max                = eval(sprintf('stimParams.max%s;',stimParams.vars{1}));
var2.min                = eval(sprintf('stimParams.min%s;',stimParams.vars{2}));
var2.max                = eval(sprintf('stimParams.max%s;',stimParams.vars{2}));

logValue(fix)           = stimParams.fixLevels(level); 
logValue(vary)          = stimParams.varyLevel;

var1.value              = var1.min + logValue(1)*(var1.max-var1.min);
var2.value              = var2.min + logValue(2)*(var2.max-var2.min);

% make sure to make a max wordRGB value in stimParams based off display

eval(sprintf('stimParams.%s = %d;',stimParams.vars{1},var1.value));
eval(sprintf('stimParams.%s = %d;',stimParams.vars{2},var2.value));
%}

% post processing of values before they are used to render stimuli (ex used
% is taking the RGB value and putting it into a 1x3 vector)

for i=1:3, stim.images{1}(:,:,i) = curStrImg; end

curStrImg(curStrImg==0) = display.backColorRgb(1);
curStrImg(curStrImg==1) = round(stimParams.wordRGB*display.maxRgbValue);
stim.images{1}          = curStrImg;

stim.imSize             = size(stim.images{1});
stim.imSize             = stim.imSize([2 1]);

numRefreshesPerFrame    = round(stimParams.frameDuration * display.frameRate);
numFrames               = round((display.frameRate * stimParams.duration)/numRefreshesPerFrame);
stim.seq                = ones(1,numFrames);

stim.cmap               = [];
stim.srcRect            = [];

%stimParams.width        = angle2pix(display,stimParams.width); %(stimParams.width/display.degWidth)*display.pixWidth;
%stim.newImSize          = [stimParams.width (stimParams.width/stim.imSize(1))*stim.imSize(2)];

center                  = computePosition(display,stimParams.centerLoc,stimParams.angle,(stimParams.distance));
topLeft                 = [center(3)-stim.imSize(1)/2 center(4)-stim.imSize(2)/2];
stim.destRect           = round([topLeft topLeft+stim.imSize(1:2)]);

stim = makeTextures(display,stim);






