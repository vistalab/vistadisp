function sequence = attMakeStimSeq(stimParams)
% Define a cec
% sequence = attMakeStimSeq(stimParams)

sequence = zeros(stimParams.numFrames,1);

sequence(1:2:end) = 1;
sequence(2:2:end) = 2;

% Define contrast decrement images for the test probe
probe.init = stimParams.start_frame;
probe.end  = stimParams.start_frame+stimParams.nTimePoints-1;

imageNum.init = 3;
imageNum.end  = stimParams.nTimePoints+2;
sequence(probe.init:probe.end) = imageNum.init:imageNum.end;



return