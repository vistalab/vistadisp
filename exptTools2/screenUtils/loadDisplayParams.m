function displayID = loadDisplayParams(varargin)
% load saved parameters for using a display with the VISTADISP tools.
%
% displayID = loadDisplayParams([property, value, ...]);
%
% This is a routine for loading display params on a given computer.  Uses a
% default directory in a default path to load files containing the
% parameters (the exact format of which is described below).
%
% As of 2008, there are several formats for the display parameters. The
% default is an M-file, 'displayParams.m', which defines some of the key
% parameters described below. Alternately, gamma files produced by the
% PsychToolbox calibration utlities may be read directly (modification by
% winawer early 2008). Also, the code may also load extra information
% contained in three files: "params", "gamma", and "spectra".
%
% Any of the properties specified in the 'displayParams' file can also be
% specified as a property/value pair when calling this function. There is
% an additional 'stereoFlag' parameter that can be set (defaults to 0). 
%
% A key parameter to set is 'DisplayName', [name of display]. This should
% specify a directory containing the calibration files described above. If
% this property/value pair is not given in the arguments, it will default
% to [default], a default set of calibration parameters which contain
% placeholder values (and which is therefore not likely to reflect an
% accurate calibration). If only one argument is passed in, it is assumed
% to be the display name.
%
% The "displayParams" file should contain the following variables (examples in parens):
%
%  	required:
%
%		frameRate	 - Refresh rate in Hz (200/3)          
%		numPixels	 - Number of pixels in display ([640 480])
%		dimensions	 - Dimensions of screen in cm ([39 29])
%		distance	 - From subject in cm (45)
%		cmapDepth	 - Number of DAC bits (10)
%		screenNumber - Separate screen output? (0 or 1)
%
%	descriptive (recommended):
%
%		computerName	- Name of computer ('Burgundy')
%		monitor			- Name of monitor ('ViewSonic')
%		card			- Name of card ('Radius10-bit')
%		position		- Name of location ('Room 485')
%
% The "gamma" file must contain the variable gammaTable, which should be
% 3 columns (one for each gun) by 256 or 1024 rows (for 8 bit and 10 bit cards,
% respectively).
%
% The "spectra" file must contain the varaible monitorSpectra, which should be
% 4 columns (one for each gun and one for white) by 361 rows.  The rows range from
% 370 nanometers to 730 nanomenters.
%
% Created by WAP on 11/3/99
%
% History:
% 11/03/99 wap created it.
% 04/13/06 shc made the function look for the "spectra" file only in the
% "displayName"  
% 05/06/08 Modified by JW to call a new function, loadDisplayParamsPTB, if
%           the calibration is a PsychophysicsToolbox file instead of a
%           Wandell-lab calibration directory. 
% 05/26/08 made case-insensitive, started documenting this better (the
% 'displayName' argument description wasn't even correct, and wouldn't
% work). What a mess!

if nargin==1 && ischar(varargin{1})
    displayName = varargin{1};
elseif mod(nargin,2)
    error('Number of arguments must be even (propertyName, propertyValue, ...).');
end

homedir = pwd;

% Check to see if monitor path or directory is specified
for argNum = 1:(nargin/2)
    if strcmpi( varargin{2*argNum-1}, 'path' )
        displayDir = varargin{2*argNum};
    elseif strcmpi( varargin{2*argNum-1}, 'displayname' )
        displayName = varargin{2*argNum};
    elseif strcmpi( varargin{2*argNum-1}, 'displaydir' )
        displayName = varargin{2*argNum};
    end
end

% check the preferred location
% (ras 07/08: the VISTADISP location is now preferred)
if ~exist('displayDir','var')
    displayDir = getDisplayPath;
end

% Display dir not found? Check the alternative (older) location
if ~exist(displayDir,'dir')
    displayDir = fullfile(matlabroot, 'Displays');
end

if ~exist(displayDir,'dir')
    error(['Display path ' displayDir ' does not exist and must be created.']);
end

%% Check to see if displayName is really a mat file made by PTB
if exist('displayName', 'var')
    if ~isempty(strfind(displayName, '.mat')) || ...
            check4File(fullfile(displayDir, displayName), '.mat') || ...
            check4File(fullfile(CalDataFolder, displayName), '.mat')
        displayID = loadDisplayParamsPTB(varargin{:});
        return;
    end

else
    if exist(fullfile(displayDir, 'default'),'dir')
        displayName = 'default';
    else
        displayName = 'demo';
        warning( ['Using the demo display definition. ' ...
				  'You should create your own to ensure accurate stimuli. ' ...
				  'See ' fullfile(displayDir, displayName) ' for an example.'] );
    end
end


displayPath = fullfile(displayDir, displayName);

if ~exist(displayPath,'dir')
    error(['"' displayName '" does not exist and must be created.']);
end

chdir(displayPath);
try
    disp(['Loading display params from ' displayDir '...']);
    displayID = feval('displayParams');
    displayID.screenNumber = max( Screen('Screens') );
    if(~isfield(displayID,'computerName'))
        displayID.computerName = 'unspecified';
    end
    if(~isfield(displayID,'monitor'))
        displayID.monitor = 'unspecified';
    end
    if(~isfield(displayID,'card'))
        displayID.card = 'unspecified';
    end
    if(~isfield(displayID,'position'))
        displayID.position = 'unspecified';
    end
    if(~isfield(displayID,'bitsPerPixel'))
        displayID.bitsPerPixel = 32;
    end
    disp(['Initializing ' displayID.computerName ' computer with ' displayID.monitor ' display.']);
    displayID.stereoFlag = 0;

    % Adjust any parameters as per special requests
    for argNum = 1:(nargin/2)
        propertyName = varargin{2*argNum-1};
        propertyVal = varargin{2*argNum};
        switch lower(propertyName)
            case 'framerate', 		displayID.frameRate = propertyVal;
            case 'numpixels', 		displayID.numPixels = propertyVal;
            case 'dimensions', 		displayID.dimensions = propertyVal;
            case 'distance', 		displayID.distance = propertyVal;
            case 'cmapdepth',		displayID.cmapDepth = propertyVal;
            case 'screennumber', 	displayID.screenNumber = propertyVal;
            case 'stereoflag', 		displayID.stereoFlag = propertyVal;
            case 'bitperpixel',     displayID.bitsPerPixel = propertyVal;
            otherwise,
                if ~(strcmp(propertyName,'path') || strcmp(propertyName,'displayName'))
                    error(['Unknown propertyName: ' propertyName]);
                end
        end
    end

    displayID.pixelSize = mean(displayID.dimensions./displayID.numPixels);
    displayID.maxGammaValue = (2^displayID.cmapDepth-1);
    if displayID.bitsPerPixel==8 || displayID.bitsPerPixel==24 || displayID.bitsPerPixel==32
        displayID.maxRgbValue = 255;
        % We reserve the first and last gamma table entry for stuff like
        % the fixation point.
        displayID.stimRgbRange = [1,254];
        displayID.backColorIndex = 128;
    else
        error('Unknown bitPerPixel value!');
    end

    % Set a default background- users will probably want to over ride this.
    displayID.backColorRgb = [repmat(round(displayID.maxRgbValue/2),1,3) displayID.maxRgbValue];
    displayID.textColorRgb = repmat(displayID.maxRgbValue,1,4);
    displayID.fixType = 'disk';
    displayID.fixSizePixels = 3;
    displayID.fixColorRgb = [displayID.maxRgbValue 0 0 displayID.maxRgbValue];
    displayID.fixX = round(displayID.numPixels(1)/2);
    displayID.fixY = round(displayID.numPixels(2)/2);

    % Load gamma table
    if exist(fullfile(displayPath,'gamma.mat'),'file')
        load gamma
        if ~exist('gammaTable','var')
            if exist('gamma10','var')
                gammaTable = gamma10 * 1023;
            else
                error('gammaTable not found in gamma.mat');
            end
        end
        displayID.gammaTable = gammaTable;
        disp('Loaded gamma table.');
    else
        gammaCol = (0:displayID.maxGammaValue)';
        displayID.gammaTable = [gammaCol gammaCol gammaCol];
        disp('Gamma table not found.  Using linear gamma table instead.');
    end

    % create a normalized gamma table
    displayID.gamma = displayID.gammaTable./displayID.maxGammaValue;

    % Load spectra
    if(exist(fullfile(displayPath,'spectra.mat'),'file'))
        load spectra
        if ~exist('monitorSpectra','var')
            disp('Spectra not in spectra file (only important for LMS-specified stimuli)');
        else
            displayID.spectra = monitorSpectra(:,1:3);
            disp('Loaded spectra.');
        end
    else
        disp('Spectra table not found (only important for LMS-specified stimuli)');
    end
    chdir(homedir);

    % Check the frame rate
    hz = Screen('FrameRate', displayID.screenNumber);

    %if MacOSX does not know the frame rate the 'FrameRate' will return 0.
    if(hz~=0 && abs(displayID.frameRate-hz)/displayID.frameRate > 0.01)
        warning('Current frame rate (%0.1f Hz) != displayID.frameRate (%0.1f Hz)- correcting displayID.frameRate.',hz, displayID.frameRate);
        displayID.frameRate = hz;
    end

catch
    chdir(homedir);
    rethrow(lasterror);
end




return
