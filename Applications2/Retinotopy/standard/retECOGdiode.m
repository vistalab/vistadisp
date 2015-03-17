function retECOGdiode(params)
%
% retECOGdiode(params)
% 
% If we are doing eCOG experiment, then flash eCOG rect a few times so
% eCOG photodiode will pick up 'start' signal.
%
% April, 2010, JW: Split off from doRetinotopyScan.m
%
% note: this function doesn't have to be specific to retinotopy. could now
% be renamed and moved to, say, vistadisp/exptTools2/screenUtils
% 
ifi           = Screen(params.display.windowPtr,'GetFlipInterval');
% seq_pattern = round(rand(1,5) * 200);
seq_pattern   = [4 9 16 25 36 49 64 81]
interval      = ifi * seq_pattern;
drawFixation(params.display);

if isfield(params, 'modality')
    switch lower(params.modality)
        case {'eeg' 'meg' 'ecog'}
            Rect        = params.display.rect;
            %trigRect    = [Rect(3)*0.93 Rect(4)*0.91 Rect(3) Rect(4)];
            trigRect    = [1 1 .07*Rect(3) .09*Rect(4)];
            flinitseq(params.display.windowPtr, trigRect, 0.024, interval);
        otherwise
            % do nothing
    end
end
