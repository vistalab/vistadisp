function params = retSetExperimentParams(params, expName)
%
% expNames = retSetExperimentParams(params, expName)
%
%
% Use this function to set any parameters that are specific to a particular
% kind of retinotopy experiment.
%
% If called with no arguments, return a cell array listing
% all the experiment names that it is configured to do. This call is made
% from retMenu.m. It is a kind of hack, but it is useful to have the list
% of experiment names and the switch statement for experiment in the same
% function, so that if we add a new experiment, we need only modify this
% function:
%
% If a new experiment  is added, then the experiment name must be added
% both to the variable 'expNames' and to the switch / case statement below.
%
% April, 2010, JW: Split off from setRetinotopyParams.
%
%   See also setRetinotopyParams.m  retSetFixationParams.m



% ****************************
% Experiment Names
% ****************************
% The following should match those listed in the switch statement below
expNames = {...
    'experiment from file', ...
    'rotating wedge (45deg duty)', ...
    'rotating wedge (90deg duty)', ...
    'rotating wedge (45deg duty) Reverse', ...
    'rotating wedge with blanks (45deg duty)', ...
    'rotating wedge with blanks (45deg duty) Reverse', ...
    'expanding ring (45% duty)', ...
    'expanding ring (90% duty)', ...
    'contracting ring (45% duty)', ...
    'expanding ring with blanks (45% duty)', ...
    'contracting ring with blanks (45% duty)', ...
    '8 bars','8 bars (slow)','8 bars with blanks', ...
    '8 bars with blanks, fixed check size',...
    '8 bars with blanks thin', '8 bars with blanks thick',...
    '8 bars (sinewave)',...
    '8 bars (sinewave-soft)',...
    '8 bars (sinewave-soft) with blanks'...
    '8 bars (LMS)','8 bars (LMS) with blanks',...
    '8 bars (L-M)','8 bars (S)',...
    '8 bars (letters)', ...
    'full-field, on-off', 'full-field, short on', 'full-field, on only', 'full-field, on-off (impulse)','full-field, hrf'...
    'full-field, drift-static', 'full-field, red/green', ...
    'center-surround','center-surround (0-1deg/14-20deg)','center (0-1deg)',...
    '2 rings',...
    'stationary wedge, on-off, 180', ...
    'stationary wedge, on-complement, 180',...
    'stationary wedge, on-off, 90', ...
    'stationary wedge, on-complement, 90',...
    'stationary wedge, on-off, 45', ...
    'stationary wedge, on-complement, 45'};
...%'full-field, red/green - red only','full-field, red/green - green only',...
    ...%'full-field, red/green - red only with blanks','full-field, red/green - green only with blanks',...
    
if ~exist('expName', 'var'), params = expNames; return; end



% ****************************************************
% Big switch! Set the parameters for the desired expt
% ****************************************************

switch expName
    
    case 'experiment from file',
        params.type = 'experiment from file';		

    case 'rotating wedge (90deg duty)',
        params.type = 'wedge';		% Set to 'wedge' or 'ring'
        params.wedgeDeg = 90;
        params.seqDirection = 0;
        params.numSubRings = (params.radius)/(2*params.subRingDeg);
        
    case 'rotating wedge (90deg duty) Reverse',
        params.type = 'wedge';		% Set to 'wedge' or 'ring'
        params.wedgeDeg = 90;
        params.seqDirection = 1;
        params.numSubRings = (params.radius)/(2*params.subRingDeg);
        
    case 'rotating wedge (45deg duty)',
        params.type = 'wedge';
        params.wedgeDeg = 45;
        params.seqDirection = 0;
        params.innerRad = 0;
        params.numSubRings = (params.radius)/(2*params.subRingDeg);
        
    case 'rotating wedge (45deg duty) Reverse',
        params.type = 'wedge';
        params.wedgeDeg = 45;
        params.seqDirection = 1;
        params.innerRad = 0;
        params.numSubRings = (params.radius)/(2*params.subRingDeg);
        
    case 'rotating wedge with blanks (45deg duty)',
        params.type = 'wedge';
        params.wedgeDeg = 45;
        params.seqDirection = 0;
        params.innerRad = 0;
        params.insertBlanks.do = 1;
        params.numSubRings = (params.radius)/(2*params.subRingDeg);
        
    case 'rotating wedge with blanks (45deg duty) Reverse',
        params.type = 'wedge';
        params.wedgeDeg = 45;
        params.seqDirection = 1;
        params.innerRad = 0;
        params.insertBlanks.do = 1;
        params.numSubRings = (params.radius)/(2*params.subRingDeg);
        
    case 'expanding ring (90% duty)',
        params.type = 'ring';
        params.ringDeg = params.radius/4;
        params.seqDirection = 0;
        params.numSubRings = (params.radius)/(2*params.subRingDeg);
        
    case 'contracting ring (180deg duty)',
        params.type = 'ring';
        params.ringDeg = params.radius/2;
        params.seqDirection = 1;
        params.numSubRings = (params.radius)/(2*params.subRingDeg);
        
    case 'expanding ring (45% duty)',
        params.type = 'ring';
        params.ringDeg = params.radius/8;
        params.seqDirection = 0;
        params.numSubRings = (params.radius-params.innerRad)/(params.radius);
        
    case 'contracting ring (45% duty)',
        params.type = 'ring';
        params.ringDeg = params.radius/8;
        params.seqDirection = 1;
        params.numSubRings = (params.radius-params.innerRad)/(params.radius);
        
    case 'expanding ring with blanks (45% duty)',
        params.type = 'ring';
        params.ringDeg = params.radius/8;
        params.seqDirection = 0;
        params.insertBlanks.do = 1;
        params.numSubRings = (params.radius-params.innerRad)/(params.radius);
        
    case 'contracting ring with blanks (45% duty)',
        params.type = 'ring';
        params.ringDeg = params.radius/8;
        params.seqDirection = 1;
        params.insertBlanks.do = 1;
        params.numSubRings = (params.radius-params.innerRad)/(params.radius);
        
    case 'full-field, on-off',
        params.type = 'center-surround';
        params.centerInnerRad = 0;
        params.centerOuterRad = params.radius;
        params.surroundInnerRad = params.radius;
        params.surroundOuterRad = params.radius;
        params.numImages = 2;
        params.duration = params.period/params.numImages;
        params.numSubRings = (params.radius)/(2*params.subRingDeg);
        params.numSubRings = params.numSubRings * 2;
    case 'full-field, short on',
        params.type = 'center-surround';
        params.centerInnerRad   = 0;
        params.centerOuterRad   = params.radius;
        params.surroundInnerRad = params.radius;
        params.surroundOuterRad = params.radius;
        params.dutyCycle        = input('Please enter 1/duty-cycle (1/n): ');
        
        params.numImages   = params.dutyCycle;
        params.duration    = params.period/params.numImages;
        params.numSubRings = (params.radius)/(2*params.subRingDeg);
        
    case 'full-field, on only',
        params.type = 'center-surround';
        params.centerInnerRad   = 0;
        params.centerOuterRad   = params.radius;
        params.surroundInnerRad = params.radius;
        params.surroundOuterRad = params.radius;
        params.dutyCycle        = 1;
        
        params.numImages   = params.dutyCycle;
        params.duration    = params.period/params.numImages;
        params.numSubRings = (params.radius)/(2*params.subRingDeg);
        

    case 'full-field, hrf',
        params.type = 'center-surround';
        params.centerInnerRad = 0;
        params.centerOuterRad = params.radius;
        params.surroundInnerRad = params.radius;
        params.surroundOuterRad = params.radius;
        params.numImages = 2;
        params.duration = params.period/params.numImages;
        params.numSubRings = (params.radius)/(2*params.subRingDeg);
        
    case 'full-field, on-off (impulse)',
        params.type = 'center-surround';
        params.centerInnerRad = 0;
        params.centerOuterRad = params.radius;
        params.surroundInnerRad = params.radius;
        params.surroundOuterRad = params.radius;
        params.numImages = 2;
        params.duration  = params.period/params.numImages;
        params.numSubRings = (params.radius)/(2*params.subRingDeg);
        params.impulse   = input('Please enter impulse time (sec): ');
        params.insertBlanks.do = 1;
        params.insertBlanks.freq = params.numCycles;
        params.insertBlanks.phaseLock = 1;
        
    case 'full-field, drift-static',
        params.type = 'ring';
        params.dynamicStaticFlag = 1;	% if set, half the time will be a static stim
        params.innerRad = 0;		% Non-zero for annular wedge condition (deg)
        params.ringDeg = params.radius;			% Ring radius/width (deg)
        params.numImages = 2;
        params.duration = params.period/params.numImages;
        params.numSubRings = (params.radius)/(2*params.subRingDeg);
        
    case 'center-surround',
        params.type = 'center-surround';
        params.centerInnerRad = 0.2;
        params.centerOuterRad = 4;
        params.surroundInnerRad = 6%14;
        params.surroundOuterRad = 20;
        params.numImages = 2;
        params.duration = params.period/params.numImages;
        params.numSubRings = (params.radius)/(2*params.subRingDeg);
        
    case 'center-surround (0-1?/14-20?)',
        params.type = 'center-surround';
        params.centerInnerRad = 0;
        params.centerOuterRad = 1;
        params.surroundInnerRad = 14;
        params.surroundOuterRad = 20;
        params.numImages = 2;
        params.duration = params.period/params.numImages;
        params.numSubRings = (params.radius)/(2*params.subRingDeg);
        
    case 'center (0-1?)',
        params.type = 'center-surround';
        params.centerInnerRad = 0;
        params.centerOuterRad = 1;
        params.surroundInnerRad = 20;
        params.surroundOuterRad = 20;
        params.numImages = 2;
        params.duration = params.period/params.numImages;
        params.numSubRings = (params.radius)/(2*params.subRingDeg);
        
    case 'full-field, red/green',
        params.type = 'center-surround';
        params.centerInnerRad = 0;
        params.centerOuterRad = params.radius;
        params.surroundInnerRad = 0;
        params.surroundOuterRad = params.radius;
        params.numImages = 2;
        params.duration = params.period/params.numImages;
        params.numSubRings = (params.radius)/(2*params.subRingDeg);
        params.contrast    = 0.5;%[1 0.1]; % red blue
        params.startScan   = 0;
        
    case 'full-field, red/green - green only',
        params.type = 'center-surround';
        params.centerInnerRad = 0;
        params.centerOuterRad = params.radius;
        params.surroundInnerRad = 0;
        params.surroundOuterRad = 0;
        params.numImages = 2;
        params.duration = params.period/params.numImages;
        params.numSubRings = (params.radius)/(2*params.subRingDeg);
        params.contrast    = 0.5;%[1 0.1]; % red blue
        params.startScan   = 0;
        
    case 'full-field, red/green - red only',
        params.type = 'center-surround';
        params.centerInnerRad = 0;
        params.centerOuterRad = 0;
        params.surroundInnerRad = 0;
        params.surroundOuterRad = params.radius;
        params.numImages = 2;
        params.duration = params.period/params.numImages;
        params.numSubRings = (params.radius)/(2*params.subRingDeg);
        params.contrast    = 0.5;%[1 0.1]; % red blue
        params.startScan   = 0;
        
    case 'full-field, red/green - green only with blanks',
        params.type = 'center-surround';
        params.centerInnerRad = 0;
        params.centerOuterRad = params.radius;
        params.surroundInnerRad = 0;
        params.surroundOuterRad = 0;
        params.numImages = 2;
        params.duration = params.period/params.numImages;
        params.numSubRings = (params.radius)/(2*params.subRingDeg);
        params.contrast    = 0.5;%[1 0.1]; % red blue
        params.insertBlanks.do = 1;
        params.insertBlanks.freq = params.numCycles;
        params.startScan   = 0;
        
    case 'full-field, red/green - red only with blanks',
        params.type = 'center-surround';
        params.centerInnerRad = 0;
        params.centerOuterRad = 0;
        params.surroundInnerRad = 0;
        params.surroundOuterRad = params.radius;
        params.numImages = 2;
        params.duration = params.period/params.numImages;
        params.numSubRings = (params.radius)/(2*params.subRingDeg);
        params.contrast    = 0.5;%[1 0.1]; % red blue
        params.insertBlanks.do = 1;
        params.insertBlanks.freq = params.numCycles;
        params.startScan   = 0;
        
    case '2 rings',
        params.type = 'ring';
        params.ringDeg = params.radius/8;
        params.seqDirection = 0;
        params.numSubRings = (params.radius-params.innerRad)/(params.radius);
        params.numCycles = 5; % second is 5+2
        params.period    = 28*params.tr*params.numCycles;
        params.numImages = params.period/params.framePeriod;
        
    case '8 bars',
        params.type = 'bar';
        params.ringDeg = params.radius/4;
        params.seqDirection = 0;
        params.insertBlanks.do = 0;
        params.numSubRings = (params.radius-params.innerRad)/(params.radius);
        
    case '8 bars (slow)',
        params.type = 'bar';
        params.ringDeg = params.radius/3;
        params.seqDirection = 0;
        params.insertBlanks.do = 0;
        params.numSubRings = (params.radius-params.innerRad)/(params.radius);
        params.display.stimRgbRange   = [1 254];
        
    case '8 bars with blanks',
        params.type = 'bar';
        params.ringDeg = params.radius./4; % HW1 used radius/2 -- who is HW1?
        params.seqDirection = 0;
        params.insertBlanks.do = 1;
        params.numSubRings = (params.radius-params.innerRad)/(params.radius);
        
    case '8 bars with blanks, fixed check size',       
        params.type = 'bar';
        params.ringDeg = params.radius./4; 
        params.seqDirection = 0;
        params.insertBlanks.do = 1;
        params.numSubRings = (params.radius-params.innerRad)/(params.radius);
        
        maxRadius = pix2angle(params.display,floor(min(params.display.numPixels)/2));
        params.numSubRings = params.radius/maxRadius * 14/3 * 2/3;
        
    case '8 bars with blanks thin',
        params.type             = 'bar';
        params.ringDeg          = params.radius./4;
        params.seqDirection     = 0;
        params.insertBlanks.do  = 1;
        params.numSubRings      = (params.radius-params.innerRad)/(params.radius);
        params.ringDeg          = params.ringDeg / 2;
        params.numSubRings      = params.numSubRings / 2;

                
    case '8 bars with blanks thick',
        params.type             = 'bar';
        params.ringDeg          = params.radius./4;
        params.seqDirection     = 0;
        params.insertBlanks.do  = 1;
        params.numSubRings      = (params.radius-params.innerRad)/(params.radius);
        params.ringDeg          = params.ringDeg * 2;
        params.numSubRings      = params.numSubRings * 2;
        
    case '8 bars (sinewave)',
        params.type = 'bar';
        params.ringDeg = params.radius/3;
        params.seqDirection = 0;
        params.insertBlanks.do = 0;
        params.numSubRings = input('How many cycles/degree?: ');
        % reset motionSteps (flicker)
        % params.temporal.motionSteps = 2;
        % params.numSubRings = (params.radius-params.innerRad)/(params.radius);
        
    case '8 bars (sinewave-soft)',
        params.type = 'bar';
        params.ringDeg = params.radius/3;
        params.seqDirection = 0;
        params.insertBlanks.do = 0;
        params.numSubRings = input('How many cycles/degree?: ');
        
    case '8 bars (sinewave-soft) with blanks',
        params.type = 'bar';
        params.ringDeg = params.radius/3;
        params.seqDirection = 0;
        params.insertBlanks.do = 0;
        params.numSubRings = input('How many cycles/degree?: ');
        params.insertBlanks.do = 1;
        
    case '8 bars (LMS)',
        params.type = 'bar';
        params.ringDeg = params.radius/3;
        params.seqDirection = 0;
        params.insertBlanks.do = 0;
        params.numSubRings = 1;
        params.temporal.motionSteps = 8;
        
    case '8 bars (LMS) with blanks',
        params.type = 'bar';
        params.ringDeg = params.radius/3;
        params.seqDirection = 0;
        params.insertBlanks.do = 1;
        params.numSubRings = 1;
        params.temporal.frequency = 2; %Hz
        params.temporal.motionSteps = 8;
        params.display.gamma = create_LMScmap(params.display,[1 1 1]);%.*.5);
        if size(params.display.gamma,1)~=256,
            params.display.gamma = params.display.gamma(round(linspace(1,size(params.display.gamma,1),255)),:);
            params.display.gamma(256,:) = [1 1 1];
        end;
        params.display.gammaTable = round(params.display.gamma.*256)+1;
        
    case '8 bars (L-M)',
        params.type = 'bar';
        params.ringDeg = params.radius/3;
        params.seqDirection = 0;
        params.insertBlanks.do = 0;
        params.numSubRings = 1;
        params.temporal.motionSteps = 8;
        params.display.gamma = create_LMScmap(params.display,[-1 1 0].*.06);
        if size(params.display.gamma,1)~=256,
            params.display.gamma = params.display.gamma(round(linspace(1,size(params.display.gamma,1),255)),:);
            params.display.gamma(256,:) = [1 1 1];
        end;
        params.display.gammaTable = round(params.display.gamma.*256)+1;
        
    case '8 bars (S)',
        params.type = 'bar';
        params.ringDeg = params.radius/3;
        params.seqDirection = 0;
        params.insertBlanks.do = 0;
        params.numSubRings = 1;
        params.temporal.motionSteps = 8;
        params.display.gamma = create_LMScmap(params.display,[0 0 1].*.5);
        if size(params.display.gamma,1)~=256,
            params.display.gamma = params.display.gamma(round(linspace(1,size(params.display.gamma,1),255)),:);
            params.display.gamma(256,:) = [1 1 1];
        end;
        params.display.gammaTable = round(params.display.gamma.*256)+1;
        
    case '8 bars (letters)',
        params.temporal.numStimChanges = 2;
        params.temporal.numNoiseChanges = 4;
        params.stimulusType = 'letters';
        
    case 'stationary wedge, on-off, 180',
        params.type = 'stationary-wedge-on-off';
        params.wedgeDeg = 180;
        params.numImages = 2;
        params.duration = params.period/params.numImages;
        params.numSubRings = (params.radius)/(2*params.subRingDeg);
        
    case 'stationary wedge, on-complement, 180',
        params.type = 'stationary-wedge-on-complement';
        params.wedgeDeg = 180;
        params.numImages = 2;
        params.duration = params.period/params.numImages;
        params.numSubRings = (params.radius)/(2*params.subRingDeg);
        
    case 'stationary wedge, on-off, 90',
        params.type = 'stationary-wedge-on-off';
        params.wedgeDeg = 90;
        params.numImages = 2;
        params.duration = params.period/params.numImages;
        params.numSubRings = (params.radius)/(2*params.subRingDeg);
        
    case 'stationary wedge, on-complement, 90',
        params.type = 'stationary-wedge-on-complement';
        params.wedgeDeg = 90;
        params.numImages = 2;
        params.duration = params.period/params.numImages;
        params.numSubRings = (params.radius)/(2*params.subRingDeg);
        
    case 'stationary wedge, on-off, 45',
        params.type = 'stationary-wedge-on-off';
        params.wedgeDeg = 45;
        params.numImages = 2;
        params.duration = params.period/params.numImages;
        params.numSubRings = (params.radius)/(2*params.subRingDeg);
        
    case 'stationary wedge, on-complement, 45',
        params.type = 'stationary-wedge-on-complement';
        params.wedgeDeg = 45;
        params.numImages = 2;
        params.duration = params.period/params.numImages;
        params.numSubRings = (params.radius)/(2*params.subRingDeg);
        
    case 'new',
        % a convenient place for specifying some params to test
        params.type = 'ring';
        params.backRGB.dir = [1 1 1]';
        params.backRGB.scale = 0.5;
        params.stimLMS.dir = [1 1 1]';
        params.stimLMS.scale = 1;
        params.temporal.frequency = 4;
        params.radius = 16;			% Stimulus radius (deg; max 16)
        params.innerRad = 0;		% Non-zero for annular wedge condition (deg)
        params.wedgeDeg = 90;		% Wedge polar angle (deg)
        params.subWedgeDeg = 15;	% Sub wedge polar angle (deg)
        params.ringDeg = params.radius/2;			% Ring radius/width (deg)
        params.subRingDeg = 0.5;			% 1/2 radial spatial freq (deg)
        params.numSubRings = (params.radius)/(2*params.subRingDeg);
        
        
    otherwise,
        error('Unknown expName!');
end


return
