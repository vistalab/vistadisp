function params = retSetCommonDefaults(params, expName)
%
% params = retSetCommonDefaults(params, expName)
%
% April, 2010, JW: split off from setRetinopyParams
%
% Still a little hard to read. Main parameter categories set here are:
%
%   - Timing
%   - Screen / Calibration
%   - Stimulus dimensions
%   - Blanks
%   - Quit key
%
% Some of these may be overwritten by experiment-specific settings or
% fixation-specific settings. 
%
% See also 
%       setRetinotopyParams.m  
%       retSetFixationParams.m
%       retSetExperimentParams.m
%       retSetCommonDefaults.m


% ************************
% Timing
% ************************
    if isfinite(params.interleaves),
        params.framePeriod  = params.tr*params.interleaves;
    else
        params.framePeriod  = params.tr;
    end;
    
    if ~isfield(params, 'startScan') || isempty(params.startScan)
        params.startScan        = params.tr*2;
    end
    
    % Set the temporal frequency of the carrier grating
    % 2 Hz and 8 motion steps is most common. 7.5 Hz and 2 steps is useful for
    % frequency tagging of eCOG subjetcs. 
    if isfield(params, 'motionSteps'), 
        params.temporal.motionSteps = params.motionSteps;
    else
        params.temporal.motionSteps = 8;
    end

    if isfield(params, 'tempFreq'), 
        params.temporal.frequency   = params.tempFreq;
    else
        params.temporal.tempFreq    = 2;
    end

    % Number of samples of the image (i.e. per cycle)
    params.numImages                = round(params.period/params.framePeriod);  
    params.duration                 = round(params.period/params.numImages);
    % if set, half the time will be a static stim
    params.dynamicStaticFlag        = 0;	


% ************************
% Screen / Calibration
% ************************
    if ~isempty(params.calibration),
        params.display = loadDisplayParams('displayName',params.calibration);
        fprintf('[%s]:loading calibration from: %s.\n',mfilename,params.calibration);
    else
        params.display = setDefaultDisplay;
        fprintf('[%s]:no calibration.\n',mfilename);
    end;
    %disp('flipping images to simulate 3T projector view');
    %params.flipUD = 1;
    %params.flipLR = 1;

    if max(Screen('screens')) < params.display.screenNumber,
        fprintf('[%s]:resetting screenNumber %d -> %d.\n',mfilename,...
            params.display.screenNumber,max(Screen('screens')));
        params.display.screenNumber   = max(Screen('screens'));
    end;

    % IMPORTANT: Set stereoFlag to 1 if using stereo display.  This     %
    % will affect both the stimulus presentation and the fixation point %
    params.stereoFlag           = 0;
    params.display.stereoFlag   = 0;

    params.dispString           = [expName '.  Please watch the fixation square.'];

    % Color parameters

    params.backRGB.dir          = [1 1 1]';	% These two values are your
    params.backRGB.scale        = 0.5;		% standard default gray.
    params.stimLMS.dir          = [1 1 1]';
    params.stimLMS.scale        = 1.0;
    %bk = findName(params.display.reservedColor,'background');
    %params.display.reservedColor(bk).gunVal = (params.display.numColors-1) * ...
    %								params.backRGB.scale*params.backRGB.dir';

% ************************
% Stimulus dimensions
% ************************
    if ischar(params.stimSize),
        params.radius = pix2angle(params.display,floor(min(params.display.numPixels)/2));
    else
        params.radius = params.stimSize;			
    end;
    fprintf('[%s]: Stimulus size: %.1f degrees / %d pixels.\n',...
        mfilename,params.radius,angle2pix(params.display,2*params.radius));
    % front projector=16; back projection=3;
    params.seqDirection     = 0;	% 0 or 1- just plays the movie backwards if set to 1

    % Wedge parameters
    params.innerRad         = 0;		% Non-zero for annular wedge condition (deg)
    params.wedgeDeg         = 90;		% Wedge polar angle (deg)
    params.subWedgeDeg      = 15;	% Sub wedge polar angle (deg) 

    % Ring parameter - 8 for a radius=16 stim gives a 180 degree duty cycle
    params.ringDeg          = params.radius/2;			% Ring radius/width (deg)

    % Wedge and ring parameters
    params.subRingDeg       = 1;			% 1/2 radial spatial freq (deg)


% ************************
% Fixation 
% ************************
params.display.fixType       = params.fixation; % disk or largeCross
params.display.fixSizePixels = 6;%3;%6;12 (radius of fixation)


% **********************
% Blanks
% **********************
    params.insertBlanks.do          = 0;
    params.insertBlanks.freq        = 4;
    params.insertBlanks.phaseLock   = 0;
    % stimulus on/off presentation
    if params.insertBlanks.do,
    %    bn = questdlg('Phase lock stimulus on/off cycle?','Blanking','Yes','No','No');
    %	if strmatch(bn,'Yes'),
    %		params.insertBlanks.phaseLock = 1;
    %    else,
            params.insertBlanks.phaseLock = 0;
    %    end;
    end;


% ************************
% Quit key
% ************************

    params.quitProgKey          = KbName('q');
    params.display.quitProgKey  = params.quitProgKey;


