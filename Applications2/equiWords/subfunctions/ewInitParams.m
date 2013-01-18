function [stimParams, stairParams] = ewInitParams

% Font Properties
stimParams.fontName                 = 'Monospaced'; 
stimParams.fontSize                 = 20;%regular value 10
stimParams.sampsPerPt               = 8; %regular value 8
stimParams.antiAlias                = 0;
stimParams.fractionalMetrics        = 0;
stimParams.boldFlag                 = true;
stimParams.stimSizePix              = [180 600]; % in pixels, [y,x]  [180 600]
stimParams.centerLoc                = [.5 .5]; % x,y percent
stimParams.duration                 = .2; % seconds

assumedRefresh                      = 75;
stimParams.frameDuration            = 1/assumedRefresh;
stimParams.quitKey                  = '7';
eccDist                             = [ 0.0       5.0     5.0];
eccAngle                            = [ 90        90      270];
minWidth                            = [ .5        2       2];
maxWidth                            = [ 2.5       10      10];
wordRGB                             = [0.55 0.70 0.90]; % vector of all RGB values of words
adjustableVarValues                 = [1 .9 .8 .7 .6 .5 .4 .3 .2 .1 0];%(10.^(0:-.21:-2));

stairParams.measuredEcc             = length(eccDist);
stairParams.nStairs                 = length(wordRGB)*length(eccDist);

ind = 0;
for i=1:length(wordRGB)
    for ii=1:length(eccDist)
        ind                         = ind+1;
        stimParams.wordRGB(ind)     = wordRGB(i);
        stimParams.eccDists(ind)    = eccDist(ii);
        stimParams.eccAngles(ind)   = eccAngle(ii);
        stairParams.adjustableVarValues(ind,:) = ... 
            minWidth(ii) + adjustableVarValues*(maxWidth(ii)-minWidth(ii));
    end
end

stairParams.useGlobalData           = true;
stairParams.alternativeVarName      = 'wordType';
stairParams.alternativeVarValues    = ['W' 'N'];
stairParams.adjustableVarName       = 'width';
stairParams.curStairVars            = {'wordRGB',  stimParams.wordRGB;
                                       'distance', stimParams.eccDists;
                                       'angle',    stimParams.eccAngles};                                 
stairParams.numCorrectForStep       = 2;
stairParams.numIncorrectForStep     = 1;
stairParams.maxNumTrials            = 150;
stairParams.maxNumReversals         = 8;
stairParams.correctStepSize         = [2 2 1];    
stairParams.incorrectStepSize       = [2 2 1]*-1;
stairParams.feedback                = 'auditory';
stairParams.responseSet             = {'1' '3'};
stairParams.conditionName           = {'lexical decision'};
stairParams.adjustableVarStart      = repmat([2 2 2], 1, 3);
stairParams.iti                     = .3;
stairParams.saveDataVars            = {'stimType', 'd'; 'stimWord', 's'; 'stimIndex', 'd'; 'distance', 'd'; 'width', 'd'; 'angle', 'd'; 'wordRGB', 'd'};
stairParams.prFlag                  = 1;
stairParams.trialGenFuncName        = 'ewRunTrial';
stairParams.laps                    = 3;
stairParams.customInstructions      = 'ewDisplayInstructions(display,[stairParams.ind stairParams.laps]);';
stairParams.stimList                = 'list712.mat';

% can be dumped?
%stimParams.angle                    = 0; % degrees
%stimParams.distance                 = 0; % degrees of visual angle
%stimParams.wordType                 = 'W';
%stimParams.width                    = 1;