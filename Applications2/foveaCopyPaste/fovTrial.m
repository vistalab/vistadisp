function [trial, data] = fovTrial(display, stimParams, data)
% [trial, data] = fovTrial(display, stimParams, data)
%
%   function to generate a 'foveal copy-paste' stimulus for fov staircase
%
% 
% Written by JW, 6/2010

Screen('Close')


sequence.t  = 1:stimParams.targetFrames;
timing.t    = sequence.t * stimParams.stimframe;
fixSeq.t    = ones(size(sequence.t));

sequence.i  = 1:stimParams.isiFrames;
timing.i    = sequence.i * stimParams.stimframe;
fixSeq.i    = ones(size(sequence.i));

cmap       = display.gammaTable;

%% make different 
im         = fovMakeStims(display, stimParams, 'different');
different  = createStimulusStruct(im,cmap,sequence.t,[],timing.t, fixSeq.t+1);
different  = createTextures(display, different);

%% make same
im         = fovMakeStims(display, stimParams, 'same');
same       = createStimulusStruct(im,cmap,sequence.t,[],timing.t, fixSeq.t+1);
same       = createTextures(display, same);

%% make isi stims
isi = cell(1,2);
for ii = 1:2
    im         = fovMakeStims(display, stimParams, 'isi');
    isi{ii}    = createStimulusStruct(im,cmap,sequence.i,[],timing.i, fixSeq.i);
    isi{ii}    = createTextures(display, isi{ii});
end
cue.sound  = soundFreqSweep(500, 1000, .01);
%% make blank stim
im         = im(:,:,1) * 0 + display.backColorIndex;
blank      = createStimulusStruct(im,cmap,1,[],0, fixSeq.i(1));
blank      = createTextures(display, blank);

%% Build the trial events
switch (stimParams.firstOrSecond)
    case '1'
            firstStim  = different; % this is what we are trying to detect
            secondStim = same;
    case '2'
            firstStim  = same;
            secondStim = different; % this is what we are trying to detect
    otherwise
        error('MatchFirstOrSecond set to %c; should be 1 or 2', stimParams.MatchFirstOrSecond);
end

% beep to start
trial = addTrialEvent(display,[],   'soundEvent' , cue );
trial = addTrialEvent(display,trial,'ISIEvent',         'stimulus', isi{1});
trial = addTrialEvent(display,trial,'ISIEvent',         'stimulus', firstStim);
trial = addTrialEvent(display,trial,'ISIEvent',         'stimulus', isi{2});
trial = addTrialEvent(display,trial,'ISIEvent',         'stimulus', secondStim);
trial = addTrialEvent(display,trial,'stimulusEvent',    'stimulus', blank);

data = 'done';


return
