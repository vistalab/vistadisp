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

% fixation should alternate between 1 (white) and 2 (black)
fixSeq              = ones(size(timing));

% specify the sequence of images as a vector of image indices
sequence            = attMakeStimSeq(stimParams);

%% make attention stim
attIm               = attMakeStimulus(stimParams, display);
attStimStruct       = createStimulusStruct(attIm,cmap,sequence,[],timing, fixSeq);
attStim             = createTextures(display, attStimStruct);



%% make pre and post stim (blank + fixation)

% blank image is a gray screen of background luminance
blankIm     = ones(size(attIm(:,:,1))) * display.backColorIndex; 

% for pre-stim we add a fixation indicating which side to attend
switch probe_side
    case 0 % attend to fixation, not probes
        pre_stim_probe = 1; % all white
    case 1 % attend left
        pre_stim_probe = 3; % red on left
    case 2 % attend right
        pre_stim_probe = 4; % red on right
end

preStim   = createStimulusStruct(blankIm,cmap,1,[], [], pre_stim_probe);
preStim   = createTextures(display, preStim);

% for post stim we add a uniform fixation (no cue to which side)
postStim   = createStimulusStruct(blankIm,cmap,1,[], [], 4);
postStim   = createTextures(display, postStim);

%% Build the trial events 

trial = addTrialEvent(display,[],'ISIEvent', 'stimulus', preStim, 'duration', 1);
trial = addTrialEvent(display,trial,'stimulusEvent', 'stimulus', attStim);
trial = addTrialEvent(display,trial,'ISIEvent', 'stimulus', postStim, 'duration');

data = 'done';
return