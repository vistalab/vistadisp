function params = setRetinotopyParams(expName, params)
% params = setRetinotopyParams([expName], [params])
%
% Sets parameter values for the specified expName.  
%
% params is a struct with at least the following fields:
%  period, numCycles, tr, interleaves, framePeriod, startScan, prescanDuration
%
% Returns the parameter values in the struct params.
% If called with no arguments, params will be a cell array listing
% all the experiment names that it is configured to do.
%
% 1999.08.12 RFD rewrote WAP's code with a cleaner wrapper.
% 2005.07.04 SOD ported to OSX; several changes
% 2006.04.05 SOD ported from ret to loc

% the following should match those listed in the switch statement below
expNames = {'faces vs scrambled','faces vs objects (no faces)','faces vs fixation','faces vs fixation with 1-back','scrambled faces vs fixation',...
            'objects vs scrambled', 'objects vs fixation','moving bars vs fixation','objects vs fixation with 1-back','objects (no faces) vs scrambled',...
            'faces vs objects (no faces) vs scrambled vs fixation'};%,'words vs lines vs fixation'};

if ~exist('expName', 'var')
	params = expNames;
	return;
end
disp(['[' mfilename ']:Setting stimulus parameters for ' expName '.']);

% some more definitions
params.framePeriod = params.tr*params.interleaves;
params.startScan   = 0;
params.quitProgKey = KbName('q');
params.ncycles     = params.numCycles;

%disp('flipping images to simulate 3T projector view');
%params.flipUD = 1;
%params.flipLR = 1;

if ~isempty(params.calibration),
    params.display = loadDisplayParams('displayName',params.calibration);
    disp(sprintf('[%s]:loading calibration from: %s.',mfilename,params.calibration));
else,
    params.display.screenNumber   = max(Screen('screens'));
    [width, height]=Screen('WindowSize',params.display.screenNumber);
    params.display.numPixels  = [width height];
    params.display.dimensions = [24.6 18.3];
    params.display.pixelSize  = min(params.display.dimensions./params.display.numPixels);
    params.display.distance   = 40;
    params.display.frameRate  = 60;
    params.display.cmapDepth  =  8;
    params.display.gammaTable = [0:255]'./255*[1 1 1];
    params.display.gamma      = params.display.gammaTable;
    params.display.backColorRgb   = [128 128 128 255];
    params.display.textColorRgb   = [255 255 255 255];
    params.display.backColorRgb   = 128;
    params.display.backColorIndex = 128;
    params.display.maxRgbValue    = 255;
    params.display.stimRgbRange   = [0 255];
    params.display.bitsPerPixel   = 32;
    disp(sprintf('[%s]:no calibration.',mfilename));    
end;
params.display.quitProgKey = params.quitProgKey;

if max(Screen('screens')) < params.display.screenNumber,
    disp(sprintf('[%s]:resetting screenNumber %d -> %d.',mfilename,...
        params.display.screenNumber,max(Screen('screens'))));
    params.display.screenNumber   = max(Screen('screens'));
end;

% set destRect, which determines the stimulus size in degrees
if ischar(params.stimSize),
    params.radius = pix2angle(params.display,floor(min(params.display.numPixels)/2));
else,
    params.radius = params.stimSize;			
end;
params.display.destRect = [0 0 1 1].*angle2pix(params.display,2*params.radius);


% IMPORTANT: Set stereoFlag to 1 if using stereo display.  This     %
% will affect both the stimulus presentation and the fixation point %
params.stereoFlag = 0;
params.display.stereoFlag = 0;


params.dispString = [expName '.  Please watch the fixation square.'];

%
% Color parameters
%
params.backRGB.dir = [1 1 1]';	% These two values are your
params.backRGB.scale = 0.5;		% standard default gray.
params.stimLMS.dir = [1 1 1]';
params.stimLMS.scale = 1.0;
%bk = findName(params.display.reservedColor,'background');
%params.display.reservedColor(bk).gunVal = (params.display.numColors-1) * ...
%								params.backRGB.scale*params.backRGB.dir';

%
% Set some common defaults
%
if ischar(params.stimSize),
    params.radius = pix2angle(params.display,floor(min(params.display.numPixels)/2));
else,
    params.radius = params.stimSize;			
end;
disp(sprintf('[%s]: Stimulus size: %.1f degrees / %d pixels.',...
    mfilename,params.radius,angle2pix(params.display,2*params.radius)));
% front projector=16; back projection=3;
params.seqDirection = 0;	% 0 or 1- just plays the movie backwards if set to 1

% off for about 12 seconds
params.duration.onBlock  = params.period;

params.temporal.frequency  = 2; %Hz
params.duration.stimframe  = 0.75;%1./params.temporal.frequency;

% find directory where images are (should always be ../JPG relative to where loc lives)
topdir = fullfile(fileparts(fileparts(which('loc'))),'JPG');

switch expName
    case 'faces vs scrambled',
        params.type = 'image';		% Set to 'wedge' or 'ring'
        params.duration.offBlock = 0;
        params.duration.scan     = params.ncycles*params.duration.onBlock.*2;
        params.categoryImages    = {'face','scrambleprevious'};
        
    case 'faces vs objects (no faces)',
        params.type = 'image';		% Set to 'wedge' or 'ring'
        params.duration.offBlock = 0;
        params.duration.scan     = params.ncycles*params.duration.onBlock.*2;
        params.categoryImages    = {'face','object (no faces)'};

    case 'faces vs fixation',
        params.type = 'image';	
        params.duration.offBlock = params.duration.onBlock;
        params.duration.scan     = params.ncycles*params.duration.onBlock.*2;
        params.categoryImages    = {'face'};

    case 'faces vs fixation with 1-back',
        params.type = 'image';	
        params.duration.offBlock = params.duration.onBlock;
        params.duration.scan     = params.ncycles*params.duration.onBlock.*2;
        params.categoryImages    = {'face'};

    case 'scrambled faces vs fixation',
        params.type = 'image';	
        params.duration.offBlock = params.duration.onBlock;
        params.duration.scan     = params.ncycles*params.duration.onBlock.*2;
        params.categoryImages    = {'scrambled faces'};

    case 'objects vs scrambled',
        params.type = 'image';
        params.duration.offBlock = 0;
        params.duration.scan     = params.ncycles*params.duration.onBlock.*2;
        params.categoryImages    = {'object','scrambleprevious'};

    case 'objects vs fixation',
        params.type = 'image';
        params.duration.offBlock = params.duration.onBlock;
        params.duration.scan     = params.ncycles*params.duration.onBlock.*2;
        params.categoryImages    = {'object'};

    case 'objects vs fixation with 1-back',
        params.type = 'image';
        params.duration.offBlock = params.duration.onBlock;
        params.duration.scan     = params.ncycles*params.duration.onBlock.*2;
        params.categoryImages    = {'object'};

    case 'objects (no faces) vs scrambled',
        params.type = 'image';
        params.duration.offBlock = 0;
        params.duration.scan     = params.ncycles*params.period.*2;
        params.categoryImages    = {'object (no faces)','scrambleprevious'};

    case 'faces vs objects (no faces) vs scrambled vs fixation',
        params.type = 'image';
        params.duration.offBlock = round(12./params.tr).*params.tr;
        params.duration.scan     = params.ncycles*params.duration.onBlock.*3 + ...
            params.ncycles*params.duration.offBlock.*3 + params.duration.offBlock;
        params.categoryImages    = {'faces','object (no faces)','scrambleprevious'};

    case 'words vs lines vs fixation',
        params.type = '2 images';
        params.duration.offBlock = round(12./params.tr).*params.tr;
        params.duration.scan     = params.ncycles*params.duration.onBlock.*2 + ...
            params.ncycles*params.duration.offBlock.*2 + params.duration.offBlock;
        params.categoryImages    = {'words','lines'};
        
        params.temporal.frequency  = 1/4; %Hz
        params.duration.stimframe  = 1./params.temporal.frequency;

    case 'moving bars vs fixation',
        params.type = 'image';
        params.duration.offBlock = params.duration.onBlock;
        params.duration.scan     = params.ncycles*params.duration.onBlock.*2;
        params.temporal.motionFrequency = 4; %Hz
        params.temporal.motionSteps = 8;

        
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%																	%
% Fixation parameters												%
%																	%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

params.display.fixType        = params.fixation; % disk or largeCross
params.display.fixSizePixels  = 6;
switch(lower(params.display.fixType))
    case {'disk','double disk'}
        params.display.fixColorRgb    = [255   0   0 255;...
                                           0 255   0 255];
%        params.display.fixColorRgb    = [255 255 255 255;...
%                                         255 255 255 255];
        dim.x = params.display.numPixels(1);
        dim.y = params.display.numPixels(2);
        params.display.fixX = round(dim.x./2);
        params.display.fixY = round(dim.y./2);
        
    case {'large cross' , 'largecross'},
        params.display.fixColorRgb    = [255   0 0 255;...
                                           0 255 0 255];
        params.display.fixSizePixels  = 12;
        dim.x = params.display.numPixels(1);
        dim.y = params.display.numPixels(2);
        dim.ycoord = [1:dim.y dim.y:-1:1] ; % assume ydim is smallest
        dim.xcoord = [1:dim.y 1:dim.y] + round(-dim.y/2+dim.x/2);
        params.display.fixCoords{1} = [dim.xcoord;dim.ycoord];
        
    case {'large cross x+' , 'largecrossx+'},
        params.display.fixColorRgb    = [255 255 0 255;...
                                         255 255 0 255];
        params.display.fixSizePixels  = round([1 sqrt(2)].*12);
        dim.x = params.display.numPixels(1);
        dim.y = params.display.numPixels(2);
        dim.ycoord = [1:dim.y dim.y:-1:1] ; % assume ydim is smallest
        dim.xcoord = [1:dim.y 1:dim.y] + round(-dim.y/2+dim.x/2);
        params.display.fixCoords{1} = [dim.xcoord;dim.ycoord];
        dim.x = params.display.numPixels(1);
        dim.y = params.display.numPixels(2);
        dim.ycoord = [1:dim.y [1:dim.y].*0+round(dim.y./2)] ; % assume ydim is smallest
        dim.xcoord = [[1:dim.y].*0+round(dim.y./2) 1:dim.y] + round(-dim.y/2+dim.x/2);
        params.display.fixCoords{2} = [dim.xcoord;dim.ycoord];
        
    case 'left disk',
        params.display.fixColorRgb    = [255 0 0 255;...
                                         128 0 0 255];
        dim.x = params.display.numPixels(1);
        dim.y = params.display.numPixels(2);
        params.display.fixX = round(dim.x./2) - floor(min(max(dim.x),max(dim.y))./2);
        params.display.fixY = round(dim.y./2);
    case 'right disk',
        params.display.fixColorRgb    = [255 0 0 255;...
                                         128 0 0 255];
        dim.x = params.display.numPixels(1);
        dim.y = params.display.numPixels(2);
        params.display.fixX = round(dim.x./2) + floor(min(max(dim.x),max(dim.y))./2);
        params.display.fixY = round(dim.y./2);
    otherwise,
        error('Unknown fixationType!');
end

params.fix.task               = 'Detect fixation change';
params.fix.colorRgb           = params.display.fixColorRgb;
params.fix.responseTime       = [.01 3]; % seconds

% Duration of params
params.framePeriod = params.tr;

% some checks, must be done before we reset certain params
locParamsCheck(params);


