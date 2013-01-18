function [fixSeq] = cocFixationSequence(params, sequence)

duration.stimframe = params.stimulus.stimframe;

% fixation dot sequence
nn = 1./duration.stimframe*4; % on average every 4 seconds [max response time = 3 seconds]
fixSeq = ones(nn,1)*round(rand(1,ceil(length(sequence)/nn)));
fixSeq = fixSeq(:)+1;
fixSeq = fixSeq(1:length(sequence));
% force binary   q
fixSeq(fixSeq>2)=2; 
fixSeq(fixSeq<1)=1;

return