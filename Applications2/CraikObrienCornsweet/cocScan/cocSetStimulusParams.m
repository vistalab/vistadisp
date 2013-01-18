function [params] = cocSetStimulusParams(params)

%Stimulus

% type of edge
params.stimulus.type = params.type;

% temporal frequency of stimuli
if ~isfield(params, 'stimulus') || ~isfield(params.stimulus, 'frequency')
    params.stimulus.frequency  = 1; %Hz
end

%contrast across edge
if ~isfield(params, 'stimulus') || ~isfield(params.stimulus, 'edgeAmplitdue')
    params.stimulus.edgeAmplitdue = 0.2;
    params.stimulus.edgeAmplitdue = 1;
end

%stimulus size
if ~isfield(params, 'stimulus') || ~isfield(params.stimulus, 'radius')
    params.stimulus.radius = params.display.radius;
end

%position of fixation relative to edge
if ~isfield(params, 'stimulus') || ~isfield(params.stimulus, 'fixationEcc')
    params.stimulus.fixationEcc = 3; %(deg)
    params.stimulus.fixationEcc = 2; %(deg)
end

% curvature of edge
if ~isfield(params, 'stimulus') || ~isfield(params.stimulus, 'curvatureAmp')
    params.stimulus.curvatureAmp = 10; %(deg)
end

% number of refreshes to show each identical image
if ~isfield(params, 'stimulus') || ~isfield(params.stimulus, 'framesPerImage')
    params.stimulus.framesPerImage = 2;
end

% duration of a stimulus frame in seconds
params.stimulus.stimframe = params.stimulus.framesPerImage / params.display.frameRate;

%fixation side
switch lower(params.fixSide)
    case {'left'}
        params.stimulus.fixationSide = -1;
    case {'right'}
        params.stimulus.fixationSide = 1;
    case {'center'}
        params.stimulus.fixationSide = 0;
end

return