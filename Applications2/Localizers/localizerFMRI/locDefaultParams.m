function params = locDefaultParams
% Set some default parameters for localizer fMRI. See help and comments in
% locGetParams.m for parameter descriptions.
% 
% params = locDefaultParams
%
% JW, 1/2012

% scan parameters
params.scan.instructions        = 'Please press button when fixation dot changes color.';
params.scan.dispName            = 'cni_lcd'; % name of calibration file (without extension)
params.scan.countdownsecs       = 0;        % seconds
params.scan.triggerType         = 'computer triggers scanner';

% stimulus parameters
params.stim.blockLength      = 12;    % seconds
params.stim.fixLength        = 12;    % seconds (scalar or vector)
params.stim.numBlocks        = 10;     % number of stimulus blocks
params.stim.stimLength       = 0.4;   % seconds
params.stim.ISItime          = 0.1;   % seconds
params.stim.blankColor       = 128;   % seconds
params.stim.circularAperture = false; % mask stimulus within a circular aperture

% Directory that contains stim folder with stimuli
params.stim.baseDir = fullfile(vistastimRootPath);

% Condition direcotries
params.stim.blockDirs        = [];

% Condition names
params.stim.condNames        = [];

% Condition order
params.stim.blockOrder       = [];

return
