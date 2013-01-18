function [stimulus] = scissionMakeStimulus(params)
%
% scissionMakeStimulus : making image matrices for scission stimulus (Anderson-Winwer illusion)
% [stimulus] = scissionMakeStimulus(params)
% 12/2008 HH mimic cocMakeStimulus made by JW
%

duration.stimframe = params.stimulus.stimframe;

if isfield(params, 'showProgess'),
    showProgress = params.showProgess;
else
    showProgress = false;
end

%make images and image sequence
switch lower(params.type)
    
    case {'surroundrotation','centsurroundrotation', 'filtersizechange', 'annulus'}
        
        % load matrix or make it
        
        if ~isempty(params.loadMatrix),
            % we should really put some checks that the matrix loaded is
            % appropriate etc.
            load(params.loadMatrix);
            disp(sprintf('[%s]:loading images from %s.',mfilename,params.loadMatrix));
            
        else          
            images      = scissionMultipleFrames(params, params.stimulus, params.display, showProgress);
        end
        sequence    = scissionImageSequence(params);
        timing      = [0:length(sequence)-1]'.*duration.stimframe;
                  
    otherwise
        error('unknown stimulus type')
end

fixSeq  = scissionFixationSequence(params, sequence);

% make stimulus structure for output
cmap     = params.display.gammaTable;
stimulus = createStimulusStruct(images,cmap,sequence,[],timing,fixSeq);

% save matrix if requested
if ~isempty(params.saveMatrix),
    try
        save(params.saveMatrix,'images');
    catch
        tmp = fileparts(fileparts(params.saveMatrix));
        mkdir(tmp, 'storedImagesMatrices');
        save(params.saveMatrix,'images');
    end
end