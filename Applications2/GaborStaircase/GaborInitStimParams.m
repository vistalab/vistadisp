function stimParams = GaborInitStimParams(display, stimParams)

% initialize stimulus poarameters

% amplitude
stimParams.contrast              = 1.0;
stimParams.colorDir              = [1 1 1];
stimParams.present               = 1; % relevant for pres / abs experiments

% temporal
stimParams.cyclesPerSecond       = 0;   % drift rate (0 = stationary)
stimParams.duration              = 0.5;	% in seconds
stimParams.temporalEnvelopeShape = 'flicker';   % 'gaussian';%ß % or 'raisedcos' or 'gaussian' (try spread=duration/6)
stimParams.temporalSpread        = 0.8;         % used only for gaussian temporal envelope

% spatial
stimParams.testPosition          = 'L'; % irrelevant if ecc == 0 deg
stimParams.cyclesPerDegree       = 1;	% spatial frequency
stimParams.orientDegrees         = 90;
stimParams.phaseDegrees          = 0;
stimParams.size                  = 10; % hard edge of stimulus in deg
stimParams.spread                = fwhm2sd(4); % gaussian sigma in deg

if ~isfield(stimParams, 'eccentricity')
    stimParams.eccentricity          = -3; % stimulus location in deg (negative = down)
end

% position of fixation cross
stimParams.fixationEcc           = 0; 

return

function sigma = fwhm2sd(fwhm)
% convert a gaussian fullwidth-halfmax to sd

sigma = fwhm / 2.35;

return


