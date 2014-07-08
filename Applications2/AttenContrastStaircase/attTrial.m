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


% specify the sequence of images as a vector of image indices
sequence            = attMakeStimSeq(stimParams);

% specify the photodiode sequence
diodeSeq = zeros(length(sequence),1);
diodeSeq(1:2:end) = 1;

% specify the trigger sequence, depending on probe side, we send different
% triggers.
trigSeq = zeros(length(sequence),1);
trigSeq(2:2:end) = 2;
if probe_side == 0;
    trigSeq(1:2:end) = 1;
elseif probe_side == 1;
    trigSeq(1:2:end) = 3;
elseif probe_side == 1;
    trigSeq(1:2:end) = 4;
end

% Send specific trigger if probe is on the screen
for ii = 1:length(sequence)
    if sequence(ii) == 3;
        trigSeq(ii) = 8;
    end
end
    


% Make a fixation sequence
frame_duration = 1/stimParams.frequency;
%   minimum time between fixation change
min_fix_frames = round(0/frame_duration);
%   maximum time between fixation change
max_fix_frames = round(5/frame_duration);
%   initialize the fixation vector with ones. some of these will change
%   to twos.
fix_vector = ones(imagesPerTrial,1);
counter = 1;


which_fixation = randintrange(1, 2, 1);
while counter < imagesPerTrial
    % pick a random interval for this fixation where fix == 2
    this_dur = randi([min_fix_frames max_fix_frames]);
    fix_vector((1:this_dur)+counter-1) = which_fixation;
    
    % if it's a 2,make it a 1. if it's a 1, make it a 2.
    which_fixation = 3 - which_fixation; 
    
    counter = counter + this_dur;
end

% clip fixation vector in case it is longer than the image sequence
if length(fix_vector) > imagesPerTrial
    fix_vector = fix_vector(1:imagesPerTrial);
end

fixSeq     = fix_vector;

%% make attention stim
attIm               = attMakeStimulus(stimParams, display);
attStimStruct       = createStimulusStruct(attIm,cmap,sequence,[],timing, fixSeq, diodeSeq, trigSeq);
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
post_stim_probe = 1; % all white

preStim   = createStimulusStruct(blankIm,cmap,1,[], [], pre_stim_probe);
preStim   = createTextures(display, preStim);

% for post stim we add a uniform fixation (no cue to which side)
postStim   = createStimulusStruct(blankIm,cmap,1,[], [], post_stim_probe);
postStim   = createTextures(display, postStim);

%% Build the trial events 

trial = addTrialEvent(display,[],'ISIEvent', 'stimulus', preStim, 'duration', 1);
trial = addTrialEvent(display,trial,'stimulusEvent', 'stimulus', attStim);
trial = addTrialEvent(display,trial,'ISIEvent', 'stimulus', postStim, 'duration');

data = 'done';
return