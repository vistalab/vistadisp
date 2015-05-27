function stimulus = makeRetinotopyStimulusFromFile(params)
% Load a stimulus description from a file
%
% stimulus = makeRetinotopyStimulusFromFile(params)

% Check whether loadMatrix exists
if ~isfield(params, 'loadMatrix'), error('No loadMatrix to load'); end
if ~exist(params.loadMatrix, 'file'), error('Cannot locate stim file %s.', params.loadMatrix); end

% Load the stimulus from a stored file
tmp = load(params.loadMatrix, 'stimulus');

if isfield(tmp, 'stimulus'),  stimulus = tmp.stimulus;    
else                          stimulus = tmp;  end

% clear textures field if it extists. textures will be remade lated
if isfield(stimulus, 'textures'), stimulus = rmfield(stimulus, 'textures'); end

%% fixation dot sequence
% change on the fastest every 6 seconds
if isfield(stimulus, 'fixSeq') && ~isempty(stimulus.fixSeq)
    % if the field exists, don't overwrite
else
    % if the fixSeq doesn't exist, create it
    duration.stimframe  = median(diff(stimulus.seqtiming));
    minsec = round(6./duration.stimframe);
    
    fixSeq = ones(minsec,1)*round(rand(1,ceil(length(stimulus.seq)/minsec)));
    fixSeq = fixSeq(:)+1;
    
    % force binary
    fixSeq(fixSeq>2)=2;
    fixSeq(fixSeq<1)=1;
    
    stimulus.fixSeq = fixSeq;
end
