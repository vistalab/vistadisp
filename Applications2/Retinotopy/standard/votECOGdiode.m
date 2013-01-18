function votECOGdiode(params)
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
    
drawFixation(params.display,1);

if isfield(params, 'modality') && strcmpi(params.modality, 'ecog')
    Rect        = params.display.rect;
    trigRect    = [Rect(3)*0.93 Rect(4)*0.91 Rect(3) Rect(4)];
    fl_black(params.display.windowPtr,trigRect);
end
