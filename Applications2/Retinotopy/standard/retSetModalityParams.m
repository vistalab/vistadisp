function params = retSetModalityParams(params)
% retSetModalityParams - set parameters for retinotopy modality (fMRI, EEG,
% ECoG, MEG)
%
% params = retSetModalityParams(params)
%
%
% params is a struct. for fields, check retCreateDefaultGUIParams
%
% Returns the parameter values in the struct params.

% For experiments that use photodiode triggers, define:
%    the rect which flashes to signal to the photodiode
%    the initialization sequence
% initDiode

if ~isfield(params, 'modality'), params.modality = 'fMRI'; end

modality = params.modality;

switch lower(modality)
    case 'fmri'
        % Time to show each image is relative to experiment start, rather
        % than relate to last screen flip because we do not want to accrue
        % timing error over the course of the experiment
        params.display.timeFromT0 = false;
        
    case {'eeg' 'ecog' 'meg'}
        % We need to add modality to the display field as well as the
        % params field because there are some functions like
        % showScanStimulus that take display but not params as input, but
        % still need to know the modality
        params.display.modality = params.modality;
        
        % Time to show each image is relative to last screen flip rather
        % than to experiment start,  because we want precise control over
        % the interstimulus interval, which is more important than the time
        % since the experiment began
        params.display.timeFromT0 = false;
        
        % specifiy temporal sequence of photodiode signals to indicate
        % experiment start (1 is white, 0 is black)
        params.display.initstim.seq       = [0 1 0 1 0 1 0 1 0 1 0]; 
        params.display.initstim.seqtiming = [2 5 7 12 16 20 28 35 40 45 51] ...
            ./ params.display.frameRate; % time in seconds 
        
        % Specify the position of the rectangle that signals to the
        % photodiode for ECoG/EEG/MEG experiments
        x = params.display.numPixels(1);
        y = params.display.numPixels(2);
        % upper left
        params.display.trigRect = round([0*x 0*y .07*x .09*y]); 

    otherwise
        error('Unknown experiment modality %s', modality);
end
