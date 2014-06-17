function [trial, data] = attTrial(display, stimParams, data)
% [trial, data] = attTrial(display, stimParams, data)
%

% showProgessDots     = false;
% duration.stimframe  = stimParams.stimframe;
% sequence            = attTrialImageSequence(display, stimParams);

imagesPerTrial      = stimParams.duration * stimParams.frequency;
timing              = (1:imagesPerTrial)' /  stimParams.frequency;
cmap                = display.gammaTable;
fixSeq              = ones(size(timing));

% specify the sequence of images as a vector of image indices
sequence            = attMakeStimSeq(stimParams);

%% make attention stim
attIm               = attMakeStimulus(stimParams, display);
attStimStruct       = createStimulusStruct(attIm,cmap,sequence,[],timing, fixSeq);
attStim             = createTextures(display, attStimStruct);
% attStim            = createStimulusStruct(attIm,cmap,sequence,[],timing, fixSeq);



%% make blank stim
blankIm     = ones(size(attIm(:,:,1))) * display.backColorIndex; 
col         = fixSeq(1) +1; %fixSeq(1) keeps the pos the same as for the edge stimuli and +3 changes the color
blankStim   = createStimulusStruct(blankIm,cmap,1,[], [], col);
blankStim   = createTextures(display, blankStim);
isi.sound   = soundFreqSweep(500, 1000, .01);

%% Build the trial events 

% trial = addTrialEvent(display,[],'stimulusEvent', 'stimulus', blankStim, stimParams.isi);
trial = addTrialEvent(display,[],'stimulusEvent', 'stimulus', attStim, stimParams.isi);
trial = addTrialEvent(display,trial,'ISIEvent', 'stimulus', blankStim, 'duration', stimParams.isi);

data = 'done';
return