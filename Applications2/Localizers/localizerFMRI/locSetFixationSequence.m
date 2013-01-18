function P = locSetFixationSequence(P, blockNum)
% Set the sequence of fixation colors for fMRI localizer experiment.
%
% P = locSetFixationSequence(P, blockNum)

P.blockInfo{blockNum}.fixSeq = ones(size(P.blockInfo{blockNum}.seq));

stimLength  = P.stim.stimLength;

ISItime     = P.stim.ISItime;

% Other color of fixation for fixation task

% color reversal on average every 4 seconds [max response time = 3 seconds]
nn = floor(4/(stimLength+ISItime)); 

P.blockInfo{blockNum}.fixSeq = ones(nn,1)*round(rand(1,ceil(length(P.blockInfo{blockNum}.seq)/nn)));

P.blockInfo{blockNum}.fixSeq = P.blockInfo{blockNum}.fixSeq(:)+1;

P.blockInfo{blockNum}.fixSeq = P.blockInfo{blockNum}.fixSeq(1:length(P.blockInfo{blockNum}.seq));

% force binary
P.blockInfo{blockNum}.fixSeq(P.blockInfo{blockNum}.fixSeq>2)=2;

P.blockInfo{blockNum}.fixSeq(P.blockInfo{blockNum}.fixSeq<1)=1;

return
