function P = locFixationPerformance(P)
% Wrapper function to fixation performance from fMRI localizer task. this
% function wraps getFixationPerformance.m, which is general utility in
% vistadisp for various types of scans.
%
% P = locFixationPerformance(P)

% something that getFixationPerformance needs
fixParams.task = 'Detect fixation change';  

% look for responses between .05 and 2 seconds after stimulus change
fixParams.responseTime = [0.05 2]; % 

for blockNum = 1:P.stim.numBlocks

    stimulus.fixSeq = P.blockInfo{blockNum}.fixSeq;
    
    stimulus.seqtiming = zeros(size(P.blockInfo{blockNum}.seqtiming));
    
    % correct for different use of seqtiming in Serge's code
    stimulus.seqtiming(2:end) = P.blockInfo{blockNum}.seqtiming(1:end-1); 
    
    [P.blockInfo{blockNum}.fixTaskPercentCorrect,P.blockInfo{blockNum}.fixTaskRT] = ...
        getFixationPerformance(fixParams,stimulus,P.responses{blockNum});
end

return
