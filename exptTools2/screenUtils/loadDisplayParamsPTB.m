function displayID = loadDisplayParamsPTB(varargin)
% displayID = loadDisplayParamsPTB([property, value, ...]);
%
% 05/07/08 Modified from loadDisplayParams by JW in order to handle PTB
%           calibration files.
%
%
% Routine for loading display params on a given computer.  Requires a PTB
%   calibration (.mat) file. 
%
% Can also use 3 optional files from old Wandell lab calibration
%   directories: a "displayParams" file, a "gamma" file, and a "spectra"
%   file. 
%   
%   These files must exist in a directory called [calFile 'displayParams'],
%   where calFile is the name of the calibration file without the
%   extenstion (e.g., 'screen1displayParams'). This directory should be in
%   the path in which PTB looks for calibration files, and can be
%   determined by calling the function 'CalDataFolder'.
%
%   If any of these files exist, they will get priority over variables set
%   in the PTB cal file.
%
% Most of the variables that are required by VISTADISP functions are part
% of the PTB cal files, but a few are not, esp those pertaining to viewing
% conditions during the experiment. Any of the required variables can be
% set in the function call or in a "displayParams" file, or they
% can be added and stored as new fields to the PTB cal file.
%
% Properties that can be changed include any of the required properties
% contained in the old "displayParams" file, as well as the flag
% "stereoFlag", which defaults to zero.
%
% The "displayParams" can contain any of the following variables
% (equivalent PTB cal field in parentheses)
%
%        required:
%
%           frameRate	 (cal.describe.hz)
%           cmapDepth	 (cal.describe.dacsize)
%           screenNumber (cal.describe.whichScreen)
%           numPixels	 (cal.display.numPixels)*
%           dimensions	 (cal.display.dimensions)*
%           distance	 (cal.display.distance)*
%               * not made by PTB, but can be added offline by user
%
%       descriptive (recommended):
%
%           computerName	(cal.describe.computer)
%           monitor			(cal.describe.monitor)
%           card			(cal.describe.driver)
%           position		(cal.describe.comment)
%
%
%  
%   From "gamma" file in Wandell-lab calibrations.
%
%     Supposed to contain the variable gammaTable, which should be 3
%     columns (one for each gun) by 256 or 1024 rows (for 8 bit and 10 bit
%     cards, respectively)). To get this from PTB cal file:
%
%       cal = SetGammaMethod(cal,0);
%       linearValues = ones(3,1)*linspace(0,1,2^cal.describe.dacsize);
%       gamma = PrimaryToSettings(cal,linearValues);
%
%   From "spectra" file in Wandell-lab calibrations.
%
%    Should contain the varaible monitorSpectra, which should be 4 columns
%    (one for each gun and one for white) by 361 rows.  The rows range from
%    370 nanometers to 730 nanomenters. To get this from PTB cal file:
%       
%       Get the wavelengths from PTB calibration struct:
%
%           wavelengths = SToWls(cal.S_device);
%
%       Note that the range is 380:4:780 nm, not 370:730 nm. This may
%       require updating stimulus presentation code.
%
%       Get the spectra:
%           spectra = [cal.P_device(:,1:3) sum(cal.P_device(:,1:3)')'];
%
%       Note that the PTB struct does not include a column for white.
%       Summing columns 1-3 gives white, though obviously this is not an
%       independent measure. If running color sensitive expt then check
%       this.
%
%% Set up path and directory
nargin = length(varargin);
displayID = [];

% The input to loadDisplayParamsPTB can be a single variable, in which case
% it is expected to be the name of a calibration file, 
if length(varargin)==1 && ischar(varargin{1})
    displayName = varargin{1};
elseif mod(nargin,2)
    error('Number of arguments must be even (propertyName, propertyValue, ...).');
end

homedir = pwd;

% Check to see if monitor path or directory is specified
for argNum = 1:(nargin/2)
    if strcmp(varargin{2*argNum-1},'path')
        displayDir = varargin{2*argNum};
    elseif strcmp(varargin{2*argNum-1},'displayName')
        displayName = varargin{2*argNum};
    end
end

if ~exist('displayDir','var')
    displayDir = CalDataFolder;
end

if ~exist(displayDir,'dir')
    error(['Display path ' displayDir ' does not exist and must be created.']);
end

displayPath = fullfile(displayDir, displayName);

if check4File(displayPath, '.mat')
    [ignore calFile] = fileparts(displayName); %#ok<ASGLU>
    displayDir = CalDataFolder ;
    displayName = [calFile 'displayParams'];
    cal = LoadCalFile(calFile);
else
    error('Cal file must be a .mat file');
end

displayPath = fullfile(displayDir, displayName);

%% Try getting var settings from displayParams file
if exist(displayPath,'dir')
    chdir(displayPath);
    disp(['Loading display params from ' displayDir '...']);
    displayID = feval('displayParams');
end

%% Update any vars from cal file if they  are not yet set
if(~isfield(displayID,'computerName'))
    displayID.computerName = cal.describe.computer;
end
if(~isfield(displayID,'frameRate'))
    displayID.frameRate = cal.describe.hz;
end
if(~isfield(displayID,'cmapDepth'))
    displayID.cmapDepth = cal.describe.dacsize;
end
if(~isfield(displayID,'screenNumber'))
    displayID.screenNumber = cal.describe.whichScreen;
end
if(~isfield(displayID,'monitor'))
    displayID.monitor = cal.describe.monitor;
end
if(~isfield(displayID,'position'))
    displayID.position = cal.describe.comment;
end

if isfield(cal, 'display'),
    if(~isfield(displayID,'numPixels')) && isfield(cal.display, 'numPixels'),
        displayID.numPixels = cal.display.numPixels;
    end

    if(~isfield(displayID,'dimensions')) && isfield(cal.display, 'dimensions')
        displayID.dimensions = cal.display.dimensions;
    end
    if(~isfield(displayID,'distance')) &&  isfield(cal.display, 'distance')
        displayID.distance = cal.display.distance;
    end
    if(~isfield(displayID,'stereoFlag')) &&  isfield(cal.display, 'stereoFlag')
        displayID.stereoFlag = cal.display.stereoFlag;
    end
    if(~isfield(displayID,'bitsPerPixel')) &&  isfield(cal.display, 'bitsPerPixel')
        displayID.bitsPerPixel = cal.display.bitsPerPixel;
    end
end
%% Override var settings if they are inputs to function call
for argNum = 1:(nargin/2)
    propertyName = varargin{2*argNum-1};
    propertyVal = varargin{2*argNum};
    switch propertyName
        case 'frameRate', 		displayID.frameRate = propertyVal;
        case 'numPixels', 		displayID.numPixels = propertyVal;
        case 'dimensions', 		displayID.dimensions = propertyVal;
        case 'distance', 		displayID.distance = propertyVal;
        case 'cmapDepth',		displayID.cmapDepth = propertyVal;
        case 'screenNumber', 	displayID.screenNumber = propertyVal;
        case 'stereoFlag', 		displayID.stereoFlag = propertyVal;
        case 'bitPerPixel',     displayID.bitsPerPixel = propertyVal;
        otherwise,
            if ~(strcmp(propertyName,'path') || strcmp(propertyName,'displayName'))
                error(['Unknown propertyName: ' propertyName]);
            end
    end
end

%% If optional vars  don't exist write in default values
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
 
if(~isfield(displayID,'stereoFlag'))
    displayID.stereoFlag = 0;
end

%% Check that necessary variables all exist
if ~isfield(displayID, 'frameRate')
    error('frameRate not set!')
end
if ~isfield(displayID, 'cmapDepth')
    error('cmapDepth not set!')
end
if ~isfield(displayID, 'screenNumber')
    error('screenNumber not set!')
end
if ~isfield(displayID, 'numPixels')
	res = Screen('Resolution', displayID.screenNumber);
    warning('numPixels not set -- applying current settings...') %#ok<WNTAG>
	displayID.numPixels = [res.width res.height];
end
if ~isfield(displayID, 'dimensions')
    error('dimensions not set!')
end
if ~isfield(displayID, 'distance')
    error('distance not set!')
end

chdir(homedir);

%% Derive some more settings
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

%Set a default background- users will probably want to over ride this.
displayID.backColorRgb = [repmat(round(displayID.maxRgbValue/2),1,3) displayID.maxRgbValue];
displayID.textColorRgb = repmat(displayID.maxRgbValue,1,4);
displayID.fixType = 'disk';
displayID.fixSizePixels = 3;
displayID.fixColorRgb = [displayID.maxRgbValue 0 0 displayID.maxRgbValue];
displayID.fixX = round(displayID.numPixels(1)/2);
displayID.fixY = round(displayID.numPixels(2)/2);

%% Load gamma table
%     should be 3 columns (one for each gun) by 256 or 1024 rows (for 8 bit
%     and 10 bit cards, respectively)).

% First see if old style calibration file exists 
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
    displayID.gamma = displayID.gammaTable./displayID.maxGammaValue;
    disp('Loaded gamma table.');
else
    % If not, load cal data from PTB cal file
    cal = SetGammaMethod(cal,0);
    linearValues = ones(3,1)*linspace(0,1,2^cal.describe.dacsize);
    try
        displayID.gamma = PrimaryToSettings(cal,linearValues)';
    catch
        cal = calFixGammaTable(cal);
        displayID.gamma = PrimaryToSettings(cal,linearValues)';
    end
        gammaCol = (0:displayID.maxGammaValue)';
        displayID.gammaTable = [gammaCol gammaCol gammaCol];
end

%% Load spectra
% First see if old style spectra file exists 
if(exist(fullfile(displayPath,'spectra.mat'),'file'))
    load spectra
    if ~exist('monitorSpectra','var')
        disp('Spectra not in spectra file (only important for LMS-specified stimuli)');
    else
        displayID.spectra = monitorSpectra(:,1:3);
        disp('Loaded spectra from old spectra.mat file.');
    end
else
    % If not, load cal data from PTB cal file
        wav = SToWls(cal.S_device);
        spec =   cal.P_device(:,1:3);
        disp('Loaded spectra from PTB cal file.');
        [r, w] = interpPR650([wav spec(:,1)]);
        [g] = interpPR650([wav spec(:,2)]);
        [b] = interpPR650([wav spec(:,3)]);
        displayID.spectra = [r g b];
        displayID.wavelengths = w;
end


%% Check the frame rate

% If the user is testing on one display, but will use another display in
% the scanner, the screenNumber can be wrong - this line produces an
% error.
try
    hz = Screen('FrameRate', displayID.screenNumber);
catch
    fprintf('No screenNumber %d.\nAssuming frameRate slot is correct.\n',displayID.screenNumber);
    hz = 0; % displayID.frameRate;
end

%if MacOSX does not know the frame rate the 'FrameRate' will return 0.
if(hz~=0 && abs(displayID.frameRate-hz)/displayID.frameRate > 0.01)
    warning('Current frame rate (%0.1f Hz) != displayID.frameRate (%0.1f Hz)- correcting displayID.frameRate.',hz, displayID.frameRate);
    displayID.frameRate = hz;
end

%% Shouldn't we also check the pixel dimensions?

return
