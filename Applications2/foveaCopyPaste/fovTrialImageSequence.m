function [sequence] = fovTrialImageSequence(display, stimulus)

nImagesPerCycle  = round(1/ (stimulus.frequency * stimulus.stimframe));
blankStimulus    = nImagesPerCycle + 1;
numCycles        = stimulus.frequency * stimulus.duration;
nImagesPerTrial  = round(stimulus.duration / stimulus.stimframe);

%define the image sequence for one cycle (probably about 1s) 
oneCycle = 1:nImagesPerCycle;

%define the image sequence for the whole trial
oneTrial = repmat(oneCycle, 1, ceil(numCycles));

%clean up in case num luminance cycles is not an integer
sequence = [oneTrial(1:nImagesPerTrial) blankStimulus];

return