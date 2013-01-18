function P = locLoadBlockImages(P, blockNum)
% Load the image sequence for a block in an fMRI localizer experiment.
%
% P = locLoadBlockImages(P, blockNum)


for stimNum = 1:P.stim.stimsPerBlock
    P.blockInfo{blockNum}.images{stimNum} = ...
        imread(P.blockInfo{blockNum}.stimulusList{stimNum});
end

% Blank screen: calculate once and store
if blockNum == 1
    P.stim.blankFrame = uint8(ones(size(P.blockInfo{1}.images{1})).*P.stim.blankColor);
end
P.blockInfo{blockNum}.images{end+1} = P.stim.blankFrame;

% debug:
% beep; Screen('CloseAll');
if P.stim.circularAperture,
    P.blockInfo{blockNum} = locMakeAperture(P.blockInfo{blockNum}, ...
        P.stim.blankColor);
end

% Interleave your sequence of stimuli with blank frames (last image)
P.blockInfo{blockNum}.seq = ...
    ones(2,(length(P.blockInfo{blockNum}.images)-1)).*...
    length(P.blockInfo{blockNum}.images);

% play all frames except blank ISI in order
P.blockInfo{blockNum}.seq(1,:)  = ...
    1:(length(P.blockInfo{blockNum}.images)-1);

% interleave
P.blockInfo{blockNum}.seq       = P.blockInfo{blockNum}.seq(:);

% proper formatting
P.blockInfo{blockNum}.seq       = P.blockInfo{blockNum}.seq';

return
