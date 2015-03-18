function initresponse = retInitDiode(params)
%
% flashTimes = retInitDiode(params)
%
% If we are doing an ECoG/EEG/MEG experiment, then flash a rectangle a few
% times so photodiode will pick up 'start' signal.
%
% April, 2010, JW: Split off from doRetinotopyScan.m

drawFixation(params.display);

if isfield(params, 'modality')
    switch lower(params.modality)
        case {'eeg' 'meg' 'ecog'}
            % get the current time
            t0 = GetSecs;
            
            seq = params.display.initstim.seq;            
            nframes = length(seq);
            
            initresponse = [];
            % Flashing start sequence
            for frame = 1:nframes               
                drawTrig(params.display, seq(frame));   
                [~, nextFlipTime] = getWaitTime(params.display.initstim, initresponse, frame, t0, false);                
                initresponse.flip(frame) = Screen(params.display.windowPtr,'Flip', nextFlipTime, 1);
            end
            
            
            %%
        otherwise
            % do nothing
            initresponse = [];
    end
end
