function P = locSetImagetiming(P, blockNum)
% Set the timing of each image for fMRI localizer experiment
%
% P = locSetImagetiming(P, blockNum)
%
% See locLoadBlockImages.m


% Do something very similar for seqtiming, which specifies the end time
% of each image. [presumably, similar to what is done in
% locLoadBlockImages?]

stimLength  = P.stim.stimLength;

ISItime     = P.stim.ISItime;

P.blockInfo{blockNum}.seqtiming      = ones(2,(length(P.blockInfo{blockNum}.images)-1)) .* (stimLength+ISItime);

%ISI timing
P.blockInfo{blockNum}.seqtiming(2,:) = (1:(length(P.blockInfo{blockNum}.images)-1)) .* (stimLength+ISItime);  

%stim timing
P.blockInfo{blockNum}.seqtiming(1,:) = (1:(length(P.blockInfo{blockNum}.images)-1)) .* (stimLength+ISItime);  

%more stim timing
P.blockInfo{blockNum}.seqtiming(1,:) = P.blockInfo{blockNum}.seqtiming(1,:) - ISItime;                        

% interleave
P.blockInfo{blockNum}.seqtiming      = P.blockInfo{blockNum}.seqtiming(:);  

% proper formatting
P.blockInfo{blockNum}.seqtiming      = P.blockInfo{blockNum}.seqtiming';  
 
return
