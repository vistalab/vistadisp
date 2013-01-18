function [stimParams, stairParams] = ewInitParams_bkup

stimParams.fontName                 = 'Courier New';

% Font Properties
stimParams.fontName = 'Monospaced'; %'SansSerif';
stimParams.fontSize = 20;  %regular value 10
stimParams.sampsPerPt = 8; %regular value 8
stimParams.antiAlias = 0;
stimParams.fractionalMetrics = 0;
stimParams.boldFlag = true;
stimParams.stimSizePix = [180 600]; % in pixels, [y,x]  [180 600]
%stimParams.spread = stimParams.stimSizePix/5; %4.5

stimParams.minwordRGB               = .51;
stimParams.maxwordRGB               = 1;
stimParams.angle                    = 0; % degrees
stimParams.distance                 = 0; % degrees of visual angle
stimParams.centerLoc                = [.5 .5]; % x,y percent
stimParams.duration                 = .2; % seconds
stimParams.wordType                 = 'W';
stimParams.wordRGB                  = [.5]; %round(ones(1,3)*.8*display.maxRgbValue);
stimParams.varyLevel                = 1;
stimParams.width                    = 1;
assumedRefresh                      = 75;
stimParams.frameDuration            = 1/assumedRefresh;
stimParams.quitKey                  = '7';
stimParams.inputDevice              = 4;
eccDist                             = [ 0.0     2.5     2.5     5.0     5.0];
eccAngle                            = [  90      90     270      90     270];
stimSize                            = [ 0.7    1.96    1.96     5.49   5.49];
min2maxLog                          = .22; % log spacing from min to max of size values
stairParams.measuredSizes           = 4; % number of points (sizes) measured
stairParams.measuredEcc             = length(eccDist);
stairParams.nStairs                 = stairParams.measuredSizes*length(stimSize);
intervalLog                         = min2maxLog/(stairParams.measuredSizes-1);
adjustableVarValues                 = (10.^(0:-.4:-2));

ind = 0;
for i=1:length(stimSize)
    for ii=1:stairParams.measuredSizes
        ind = ind+1;
        stimParams.stimSizes(ind) = 10^(log10(stimSize(i))+intervalLog*(ii-1));
        stimParams.eccDists(ind)  = eccDist(i);
        stimParams.eccAngles(ind) = eccAngle(i);
    end
end

stairParams.useGlobalData           = true;
stairParams.alternativeVarName      = 'wordType';
stairParams.alternativeVarValues    = ['W' 'N'];
stairParams.adjustableVarName       = 'wordRGB';
stairParams.adjustableVarValues     = stimParams.minwordRGB + adjustableVarValues*(stimParams.maxwordRGB-stimParams.minwordRGB); %(10.^(0:-.04:-.8));
% Making a special version of this variable so we can draw from it to run
% separate sets of interleaved staircases (subsets of these values)
stairParams.curStairVarsALL         = {'width',         stimParams.stimSizes;
                                       'distance',      stimParams.eccDists;
                                       'angle',         stimParams.eccAngles};
stairParams.numCorrectForStep       = 2;
stairParams.numIncorrectForStep     = 1;
stairParams.maxNumTrials            = 150;
stairParams.maxNumReversals         = 8;
stairParams.correctStepSize         = [2 2 1];    
stairParams.incorrectStepSize       = [2 2 1]*-1;
stairParams.feedback                = 'auditory';
stairParams.responseSet             = {'1' '3'};
stairParams.conditionName           = {'lexical decision'};
stairParams.adjustableVarStart      = repmat(1, 1, stairParams.nStairs);
stairParams.iti                     = .3;
stairParams.saveDataVars            = {'stimType', 'd'; 'stimWord', 's'; 'stimIndex', 'd'; 'distance', 'd'; 'width', 'd'; 'angle', 'd'};
stairParams.prFlag                  = 1;
stairParams.trialGenFuncName        = 'ewRunTrial';
stairParams.laps                    = 3;
stairParams.customInstructions      = 'ewDisplayInstructions(display,[stairParams.ind (stairParams.measuredSizes*stairParams.laps)],stimParams.inputDevice);';
stairParams.stimList                = 'list712.mat';