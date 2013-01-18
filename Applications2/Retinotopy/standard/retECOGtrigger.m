function  stimulus = retECOGtrigger(params, stimulus)
% stimulus = retECOGtrigger(params, stimulus)
%
% Add a blinking square to every other frame in order to sync stimulus and
% photodiode when doing eCOG experiments 
%
% April, 2010, JW: Split off from doRetinotopyScan.m
%
% note: this function doesn't have to be specific to retinotopy. could now
% be renamed and moved to, say, vistadisp/exptTools2/experimentControl

if isfield(params, 'modality') && strcmpi(params.modality, 'ecog')
    trigSeq = stimulus.seq * 0; % +1;
    trigSeq(2:2:end) = 2;
    stimulus.trigSeq = trigSeq;
end

return