function params = setscissionParams(expName, params)
% setRetinotopyParams - set parameters for different retinotopy scans 
%
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
% 99.08.12 RFD rewrote WAP's code with a cleaner wrapper.
% 05.07.04 SOD ported to OSX; several changes

% the following should match those listed in the switch statement below
% expNames = {'rotating wedge (90deg duty)','rotating wedge (90deg duty) Reverse',...
%             'rotating wedge (45deg duty)','rotating wedge (45deg duty) Reverse', ...
%             'rotating wedge with blanks (45deg duty)','rotating wedge with blanks (45deg duty) Reverse', ...
% 			'expanding ring (180deg duty)', 'contracting ring (180deg duty)', ...
% 			'expanding ring (45% duty)', 'contracting ring (45% duty)', ...
% 			'expanding ring with blanks (45% duty)', 'contracting ring with blanks (45% duty)', ...
% 			'full-field, on-off', 'full-field, drift-static', ...
% 			'center-surround','center-surround (0-1deg/14-20deg)','center (0-1deg)'};
%%
expNames = {'Annulus',...
            'FilterSizeChange',...
            'CentSurroundRotation',...
            'SurroundRotation'};

if ~exist('expName', 'var')
	params = expNames;
	return;
end

disp(['[' mfilename ']:Setting stimulus parameters for ' expName '.']);

% some more definitions
if isfinite(params.interleaves),
    params.framePeriod = params.tr*params.interleaves;
else,
    params.framePeriod = params.tr;
end;
params.startScan   = params.tr*2;
params.quitProgKey = KbName('q');


%disp('flipping images to simulate 3T projector view');
%params.flipUD = 1;
%params.flipLR = 1;
%%
if ~isempty(params.calibration),
    params.display = loadDisplayParams('displayName',params.calibration);
    disp(sprintf('[%s]:loading calibration from: %s.',mfilename,params.calibration));
else,
    params.display.screenNumber   = max(Screen('screens'));
    [width, height]=Screen('WindowSize',params.display.screenNumber);
    params.display.numPixels  = [width height];
    params.display.dimensions = [24.6 18.3];
    params.display.pixelSize  = min(params.display.dimensions./params.display.numPixels);
    params.display.distance   = 43.0474;%40;
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

%%
% IMPORTANT: Set stereoFlag to 1 if using stereo display.  This     %
% will affect both the stimulus presentation and the fixation point %
params.stereoFlag = 0;
params.display.stereoFlag = 0;


%% Flickering fixation point parameters
%
% this controls the duration of the fix flicks, in frames.
% Set it to 0 to turn get no flicks.
params.fixFlickFrames = 5;
% this controls the density of the flicks, per frame.
% Thus, .01 will, on average, flick once every 100 frames.
params.fixFlickFreq = .01;
params.dispString = [expName '.  Please watch the fixation square.'];

% Color parameters
params.backRGB.dir = [1 1 1]';	% These two values are your
params.backRGB.scale = 0.5;		% standard default gray.
params.stimLMS.dir = [1 1 1]';
params.stimLMS.scale = 1.0;

%%
switch expName
case 'Annulus',
	params.type = 'Annulus';		% Set to 'wedge' or 'ring'

case 'FilterSizeChange',
	params.type = 'FilterSizeChange';		% Set to 'wedge' or 'ring'

case 'CentSurroundRotation',
	params.type = 'CentSurroundRotation';
    
case 'SurroundRotation',
	params.type = 'SurroundRotation';
    
otherwise,
	error('Unknown expName!');
end
