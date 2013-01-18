function [params] = scissionSetStimulusParams(params)

%Stimulus

% type of stimulus
params.stimulus      = params;
params.stimulus.type = params.type;

% Noise type
if ~isfield(params, 'stimulus') || ~isfield(params.stimulus, 'NoiseType')
    params.stimulus.NoiseType = 'Uniform'; % 'Uniform' or 'Normalize'
end

% stimulus size
if ~isfield(params, 'stimulus') || ~isfield(params.stimulus, 'radius')
    params.stimulus.radius = params.display.radius;
end

% stimulus ratio for whole image
if ~isfield(params, 'stimulus') || ~isfield(params.stimulus, 'SizeRatio')
    params.stimulus.SizeRatio = params.SizeRatio; % 1 indicates that Circle and Display are same size  
end

% temporal frequency of stimuli
if ~isfield(params, 'stimulus') || ~isfield(params.stimulus, 'frequency')
    params.stimulus.frequency  = 1; %Hz
end

% Number of Division in OneCycle 
if ~isfield(params, 'stimulus') || ~isfield(params.stimulus, 'NumOfDevision')
    params.stimulus.NumOfDevision  = 4; % 6 means 30 degrees, 4 means 45 degrees
end

% Number of Reptition to make OneCycle  
if ~isfield(params, 'stimulus') || ~isfield(params.stimulus, 'NumOfReptOneCycle')
    params.stimulus.NumOfReptOneCycle  = 3 ; %3
end

% Without contrast violation 
if ~isfield(params, 'stimulus') || ~isfield(params.stimulus, 'WithoutContrastViolation')
    params.stimulus.WithoutContrastViolation  = true;
end

% params.period (usually 24sec) * params.stimulus.frequency / params.stimulus.NumOfDevision
% should be integer.....

% for Size changing stimuli
% These two parameter don't work precicely..... must be fixed....
% Which is short-cycle, center or surround? 1 means surrund, 0 means center.
% 1 0 center modulation 1/4 scission 1/2
% 0 0 center modulation 1/2 scission 1/4

if ~isfield(params, 'stimulus') || ~isfield(params.stimulus, 'HowLongScissionCycle')
    params.stimulus.HowLongScissionCycle  = 0; 
end

% How long is scission-cycle? 0 means short-scission cycle (1/4), 1 means long scission cycle (1/2).
if ~isfield(params, 'stimulus') || ~isfield(params.stimulus, 'whichDurationLongerSvsN')
    params.stimulus.whichDurationLongerSvsN  = 0; 
end

if ~isfield(params, 'stimulus') || ~isfield(params.stimulus, 'HowManyTimesFiltSize')
    params.stimulus.HowManyTimesFiltSize  = 10; % 10 
end

%% Gray Annulus as destructor of brightness induction
if ~isfield(params, 'stimulus') || ~isfield(params.stimulus, 'Annulus')
    params.stimulus.Annulus = false;
end

if ~isfield(params, 'stimulus') || ~isfield(params.stimulus, 'DesWidth')
    params.stimulus.DesWidth = 0; 
end

if ~isfield(params, 'stimulus') || ~isfield(params.stimulus, 'DesGray')
    params.stimulus.DesGray = 128;
end

%% Filter
if ~isfield(params, 'stimulus') || ~isfield(params.stimulus, 'Eliplisity')
    params.stimulus.Eliplisity = 1;% in case of rotation 50 ,in case of sizechangestimlus = 1
end

if ~isfield(params, 'stimulus') || ~isfield(params.stimulus, 'Filtersize')
    params.stimulus.Filtersize = 1;% in case of rotation .1 ,in case of sizechangestimlus = 1

end
if ~isfield(params, 'stimulus') || ~isfield(params.stimulus, 'Filtering')
    params.stimulus.Filtering =  true; 
end
%% Central Condition

% central dots contrast
if ~isfield(params, 'stimulus') || ~isfield(params.stimulus, 'CentralDotsContrast')
    params.stimulus.CentralDotsContrast = 1; % 1 is maximam
end

% central filter eliplisity
if ~isfield(params, 'stimulus') || ~isfield(params.stimulus, 'CentralFilterEliplisity')
    params.stimulus.CentralFilterEliplisity = params.stimulus.Eliplisity;
end

% central filter size 
if ~isfield(params, 'stimulus') || ~isfield(params.stimulus, 'CentralFilterSize')
    params.stimulus.CentralFilterSize = params.stimulus.Filtersize;
end

% central filter type
if ~isfield(params, 'stimulus') || ~isfield(params.stimulus, 'CentralFilterType')
    params.stimulus.CentralFilterType = 'gaussian';
end


%% Surround condition

% surround dots contrast
if ~isfield(params, 'stimulus') || ~isfield(params.stimulus, 'SurroundDotsContrast')
    params.stimulus.SurroundDotsContrast = .5; % 1 is maximam
end

% surround filter eliplisity
if ~isfield(params, 'stimulus') || ~isfield(params.stimulus, 'SurroundFilterEliplisity')
    params.stimulus.SurroundFilterEliplisity = params.stimulus.Eliplisity;
end

% surround filter size 
if ~isfield(params, 'stimulus') || ~isfield(params.stimulus, 'SurroundFilterSize')
    params.stimulus.SurroundFilterSize = params.stimulus.Filtersize;
end

% surround filter type
if ~isfield(params, 'stimulus') || ~isfield(params.stimulus, 'SurroundFilterType')
    params.stimulus.SurroundFilterType = 'gaussian';
end
%% Fixation
%position of fixation relative to edge
if ~isfield(params, 'stimulus') || ~isfield(params.stimulus, 'fixationEcc')
    params.stimulus.fixationEcc = 5; %(deg)
end

%% Refresh rate 
% number of refreshes to show each identical image
if ~isfield(params, 'stimulus') || ~isfield(params.stimulus, 'framesPerImage')
    params.stimulus.framesPerImage = 4 ;
    % In case of display refresh rate of 60Hz, 6 means 10Hz (each image show every 0.1 sec.) sec
end

% How many ratio to change randam noize
if ~isfield(params, 'stimulus') || ~isfield(params.stimulus, 'frameUpdateFrequency')
    params.stimulus.frameUpdateFrequency = 1 ;%this number have to be able to devide refresh rate.
    if params.stimulus.frameUpdateFrequency ~= 1; params.stimulus.NumOfReptOneCycle  = 1 ;end
end

% duration of a stimulus frame in seconds
params.stimulus.stimframe = params.stimulus.framesPerImage / params.display.frameRate;

return