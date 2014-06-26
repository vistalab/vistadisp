function [trial, data] = attTrial(display, stimParams, data)
% [trial, data] = attTrial(display, stimParams, data)
%

% showProgessDots     = false;
% duration.stimframe  = stimParams.stimframe;
% sequence            = attTrialImageSequence(display, stimParams);

imagesPerTrial      = stimParams.duration * stimParams.frequency;
timing              = (1:imagesPerTrial)' /  stimParams.frequency;
cmap                = display.gammaTable;
probe_side          = stimParams.probe_side;

fixSeq              = ones(size(timing))*probe_side;

% specify the sequence of images as a vector of image indices
sequence            = attMakeStimSeq(stimParams);

%% make attention stim
attIm               = attMakeStimulus(stimParams, display);
attStimStruct       = createStimulusStruct(attIm,cmap,sequence,[],timing, fixSeq);
attStim             = createTextures(display, attStimStruct);



%% make blank stim
blankIm     = ones(size(attIm(:,:,1))) * display.backColorIndex; 
col         = probe_side; %fixSeq(1) * ; 
blankStim   = createStimulusStruct(blankIm,cmap,1,[], [], col);
blankStim   = createTextures(display, blankStim);

%% Build the trial events 

% trial = addTrialEvent(display,[],'stimulusEvent', 'stimulus', blankStim, stimParams.isi);
trial = addTrialEvent(display,[],'stimulusEvent', 'stimulus', attStim);
trial = addTrialEvent(display,trial,'ISIEvent', 'stimulus', blankStim, 'duration');

data = 'done';
return