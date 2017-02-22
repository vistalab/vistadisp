function  stimulus = retCreateDiodeSequence(params, stimulus)
% stimulus = retCreateDiodeSequence(params, stimulus)
%
% Add a blinking square to every other frame in order to sync stimulus and
% photodiode when doing an ECoG/MEG/EEG experiment
%
% April, 2010, JW: Split off from doRetinotopyScan.m
%
% note: this function doesn't have to be specific to retinotopy. could now
% be renamed and moved to, say, vistadisp/exptTools2/experimentControl

switch lower(params.modality)
    case {'ecog', 'eeg', 'meg'}
        diodeSeq          = zeros(size(stimulus.seq));
        diodeSeq(1:2:end) = 1;
        stimulus.diodeSeq = diodeSeq;        
        stimulus.trigSeq  = stimulus.seq;
    case 'fmri'
        % do nothing
    otherwise
        error('Unrecognized modality %s', params.modality)
end

return