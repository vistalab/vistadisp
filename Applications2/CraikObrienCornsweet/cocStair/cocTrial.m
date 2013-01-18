function [trial, data] = cocTrial(display, stimParams, data)
% [trial, data] = cocTrial(display, stimParams, data)
%
%   function to generate a c-o-c stimulus and a match stimulus for 
%       coc staircase

% set parameters that apply to both stimuli
% 
% Written by JW, 5/2008

showProgessDots     = false; 
duration.stimframe  = stimParams.stimframe;
sequence            = cocTrialImageSequence(display, stimParams);
timing              = (1:length(sequence))'.*duration.stimframe;
cmap                = display.gammaTable;
fixSeq              = ones(size(sequence));

%correct fixation sequence to put fix on left or right if need be
%   fix side = 0 (center),-1(L), or 1 (R), 
%   which maps to stimulus.fixStim(1,2, or 3)
%
%if stimParams.fixationSide == -1, fixSeq = fixSeq + 1; end
%if stimParams.fixationSide ==  1, fixSeq = fixSeq + 2; end

%% make coc stim
testParams               = stimParams;
testParams.type          = stimParams.testType;
testParams.edgeAmplitdue = stimParams.testContrast;
cocIm                    = cocSingleFrame(testParams, display);
cocImages                = cocMultipleFrames(cocIm, testParams, display, showProgessDots);
cocStim                  = createStimulusStruct(cocImages,cmap,sequence,[],timing, fixSeq);
cocStim                  = createTextures(display, cocStim);

%% make matching stim (e.g., square wave or uniform)
matchParams      = stimParams;
matchParams.type = stimParams.matchType;
matchIm          = cocSingleFrame(matchParams, display);
matchImages      = cocMultipleFrames(matchIm, matchParams, display, showProgessDots);
matchStim        = createStimulusStruct(matchImages,cmap,sequence,[],timing,fixSeq);
matchStim        = createTextures(display, matchStim);

%% make blank stim
blankIm     = cocImages(:,:,end);
col = fixSeq(1) +1; %fixSeq(1) keeps the pos the same as for the edge stimuli and +3 changes the color
blankStim   = createStimulusStruct(blankIm,cmap,1,[], [], col);
blankStim   = createTextures(display, blankStim);
isi.sound = soundFreqSweep(500, 1000, .01);

%% Build the trial events 

switch (stimParams.MatchFirstOrSecond)
    case '1'
            firstStim = matchStim;
            secondStim = cocStim;
    case '2'
            firstStim = cocStim;
            secondStim = matchStim;
    otherwise
        error('MatchFirstOrSecond set to %c; should be 1 or 2', stimParams.MatchFirstOrSecond);
end

trial = addTrialEvent(display,[],'ISIEvent', 'stimulus', blankStim, 'duration', stimParams.isi);
trial = addTrialEvent(display,trial,'soundEvent',isi );
trial = addTrialEvent(display,trial,'stimulusEvent', 'stimulus', firstStim);
trial = addTrialEvent(display,trial,'ISIEvent', 'stimulus', blankStim, 'duration', stimParams.isi);
trial = addTrialEvent(display,trial,'soundEvent',isi );
trial = addTrialEvent(display,trial,'stimulusEvent', 'stimulus', secondStim);

data = 'done';
return