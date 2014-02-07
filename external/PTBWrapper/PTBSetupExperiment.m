%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBSetupExperiment.m
%
% Does the setup for a PTBExperiment. Should be called
% soonish in the experiment.
%
% Args:
%	- title: The name of the experiment.
%
% Usage: PTBSetupExperiment('VMod')
%
% This sets and provides various useful global
% values. NOTE: These can often be set at any time
% with the appropriate function.
%
%	- PTBCurrComputerSpecs: Some useful info about the 
%		current computer
%	- PTBTheWindowPtr: The pointer to the onscreen window.
%	- PTBScreenRes: Has 'width' and 'height' fields in pixels
%	- PTBStartTime: The time the experiment started (i.e.
%		when the start screen disappeared.
%	- PTBNextPresentationTime: When the next stimulus should be 
%		shown (usually set in PTBSetDuration).
%	- PTBLastPresentationTime: When the current stimulus was
%		shown.
%	- PTBWaitingForKey: True if we're waiting for a keypress
%		to show the next screen.
%	- PTBIsDebugging: True if we're debugging. This will
%		show only a portion of the screen. Timing will be
%		off because of the smaller screen.
%	- PTBExitKey: Will exit the program if given as a response.
%	- PTBLastKeyPressTime: The last time a key was recorded
%		as being pressed.
%	- PTBDataFileID: The file id to write responses to.
%	- PTBLogFileID: The file id to write stimulus presentations to.
%	- PTBLogAppend: This will be appended to any log line.
%	- PTBLastKeyPress: The last key given as a response.
%	- PTBBackgroundColor: The screen color.
%	- PTBInputDevice: The input device used for responses.
%	- PTBTextFont: The font for the text.
%	- PTBTextSize: The size for the text.
%   - PTBSoundInitialized: 1 if initialized.
%	- PTBNextSoundPort: The sound port that holds data for the next display
%	- PTBPrevSoundPort: The sound port that holds data from the last display
%	- PTBTrigSoundPort: The sound port to be used for the duration.
%   - PTBSoundPortParameters: A list of parameters of the opened sound ports
%   - PTBSoundPorts: The list of sound ports we have opened.
%   - PTBRecordingFrequency: The frequency to record at (defaulted to 44100)
%   - PTBRecordingChannels: The channels to record at (defaulted to 2)
%   - PTBUsedSoundPorts: The list of sound ports currently in use. 
%	- PTBVisualStimulus: 1 if there is a visual stimulus to display.
%	- PTBAudioStimulus: 1 if there is a visual stimulus to display.
%   - PTBTriggerLength: The length of triggers sent to the MEG DAQs.
%	- PTBUSBBoxInitialized: 1 if USBBox has been initialized.
%	- PTBTriggerPortInitialized: 1 if Parallel port trigger has been initialized.
%   - PTBEyeTrackerHandle: The handle to the eyetracker info.
%	- PTBEyeTrackerInitialized: 1 if eyetracker has been initialized.
%	- PTBEyeTrackerCalibrated: 1 if eyetracker has been calibrated.
%	- PTBEyeTrackerFileName: The file name we're saving the eye tracking data to.
%   - PTBPrintRTData: Can be set to 0 to not print out the next RT data.
%       * Will automatically be set back to 1 after that response.
%	- PTBEyeTrackerRecording: 1 if recording eye tracking data.
%	- PTBDisableTimeOut: 1 if want to collect a key press over multiple displays
%		* REMEMBER to set this back to 0 afterwards.
%	- PTBAddedResponseTime: Used internally when time out is disabled.
%   - PTBLogHeaders: Additional headers to use in the list.
%	- PTBKeyQueue: A list of screens to show depending on a key press outcome.
%	- PTBTheScreenNumber: The screen number we're displaying to.
%	- PTBInputCollection: How the input is collected. See PTBSetInputCollection
%	- PTBPortInput: Read from the NeuroSpin MEG port inputs as well as the
%       keyboard
%
% Author: Doug Bemis
% Date: 7/3/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: Eventually take variable args and parse.
% I.e.: Resolution, etc.
function PTBSetupExperiment(title)

% Versioning!
global PTBWrapper
PTBWrapperVersion;

% Setup the debugging flag. Default to not debugging.
global PTBIsDebugging
if isempty(PTBIsDebugging)
	PTBIsDebugging = 0;
end

% Setup the background color. Default to black.
global PTBBackgroundColor
if isempty(PTBBackgroundColor)
	PTBBackgroundColor = 0;
end

% Setup the exit key. Default to empty, which 
% means there will be no exit key.
global PTBExitKey
if isempty(PTBExitKey)
	PTBExitKey = '';
end

% Setup the input device. Default to -1, which 
% should be the keyboard.
global PTBInputDevice
if isempty(PTBInputDevice)
	PTBInputDevice = -1;
end

% Storage for the keys we're wating for now
global PTBKeysOfInterest
if isempty(PTBKeysOfInterest)
    PTBKeysOfInterest = zeros(1,256);
end

% Default the recording frequency
global PTBRecordingFrequency;
if isempty(PTBRecordingFrequency)
    PTBRecordingFrequency = 44100;
end
global PTBRecordingChannels;
if isempty(PTBRecordingChannels)
    PTBRecordingChannels = 2;
end

% And the ports
global PTBPrevSoundPort;
global PTBNextSoundPort;
global PTBTrigSoundPort;
PTBPrevSoundPort = -1;
PTBNextSoundPort = -1;
PTBTrigSoundPort = -1;

% To help psychtoolbox not clobber open sound ports
global PTBSoundPortParameters;
global PTBSoundPorts;
global PTBOpenSoundPorts;
global PTBSoundInitialized;
PTBSoundPortParameters = [];
PTBSoundPorts = [];
PTBOpenSoundPorts = [];
PTBSoundInitialized = 0;

% Set the stimulus values
global PTBVisual;
PTBVisual = 1;
global PTBAudio;
PTBAudio = 2;

% Initialize the stimuli
global PTBVisualStimulus;
PTBVisualStimulus = 0;
global PTBAudioStimulus;
PTBAudioStimulus = 0;

% Initialize the trigger length
global PTBTriggerLength;
if isempty(PTBTriggerLength)
    PTBTriggerLength = 0.01;
end

% Set to default for timeout
global PTBDisableTimeOut;
if isempty(PTBDisableTimeOut)
	PTBDisableTimeOut = 0;
end
global PTBAddedResponseTime;
if isempty(PTBAddedResponseTime)
	PTBAddedResponseTime = 0;
end

% Make sure we don't error
global PTBUSBBoxInitialized;
if isempty(PTBUSBBoxInitialized)
    PTBUSBBoxInitialized = 0;
end
global PTBTriggerPortInitialized;
if isempty(PTBTriggerPortInitialized)
    PTBTriggerPortInitialized = 0;
end
global PTBStimTrackerInitialized;
if isempty(PTBStimTrackerInitialized)
    PTBStimTrackerInitialized = 0;
end

% Make sure we don't error
global PTBEyeTrackerInitialized;
if isempty(PTBEyeTrackerInitialized)
    PTBEyeTrackerInitialized = 0;
end
global PTBEyeTrackerCalibrated;
if isempty(PTBEyeTrackerCalibrated)
    PTBEyeTrackerCalibrated = 0;
end
global PTBEyeTrackerRecording;
if isempty(PTBEyeTrackerRecording)
    PTBEyeTrackerRecording = 0;
end
global PTBEyeTrackerFileName;
if isempty(PTBEyeTrackerFileName)
    PTBEyeTrackerFileName = '';
end
global PTBEyeTrackerHandle;
if isempty(PTBEyeTrackerHandle)
    PTBEyeTrackerHandle = 0; 
end


% For triggers at the end of a stimulus
global PTBEndTriggers;
if isempty(PTBEndTriggers)
	PTBEndTriggers = {};
end

% This is how long the start screen is on for.
startScreenTime = 1;

% We'll be using OpenGL functions, so make sure
% that's possible.
AssertOpenGL;

% Get some computer info
global PTBCurrComputerSpecs;
PTBCurrComputerSpecs = Screen('Computer');

% Set the input collection. Default as high as possible.
global PTBInputCollection;
if isempty(PTBInputCollection) 
	if PTBCurrComputerSpecs.osx
		PTBInputCollection = 'Queue';
	else
		PTBInputCollection = 'Check';
	end
end

% This is off by default
global PTBPortInput;
if isempty(PTBPortInput)
    PTBPortInput = 0;
end
global PTBPortValues;
if isempty(PTBPortValues)
    PTBPortValues = [];
end


% Don't want the keypresses, but only for actual running, because
% need to reenable afterwards.
% TODO: Do we need flexibility here?
FlushEvents('keyDown');
if ~PTBIsDebugging

	% Careful with this call. Will supress output in matlab, which
	% is good, but, if not reset (i.e. because of an error) will
	% prevent any input from reaching matlab afterwards too.
	ListenChar(2);
	HideCursor;
else
	
	% TODO: Do we ever want this off?
	ListenChar(1);
end

% For now, always supress these for speed.
% NOTE: Should probably run or force run at least once per machine.
% TODO: Allow configurability.
global PTBOldVisualDebugLevel;
global PTBOldSupressAllWarnings;
PTBOldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
PTBOldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);


% Enable unified mode of KbName, so KbName accepts identical key names on
% all operating systems:
KbName('UnifyKeyNames');

% Need the window
global PTBTheWindowPtr;
global PTBTheScreenNumber;

% NOTE: Use max screens to set the display to be any
% secondary screen, if it exists. Doesn't always work though. 
% If not, use PTBSetScreenNumber.
screens = Screen('Screens');
if isempty(PTBTheScreenNumber)
    PTBTheScreenNumber = max(screens);
else
    
    % Make sure we can actually use it
    if isempty(find(screens == PTBTheScreenNumber))
        disp(['WARNING: Requested screen number ' num2str(PTBTheScreenNumber) ...
            ' not available. Defaulting to ' num2str(max(screens)) '.']);
        PTBTheScreenNumber = max(screens);
    end
end

% These will store the usable drawing area of the screen
% we're about to use.
% TODO: Allow configurability.
global PTBScreenRes;
PTBScreenRes=Screen('Resolution', PTBTheScreenNumber);

% Clear the key queue
global PTBKeyQueue;
PTBKeyQueue = {};

% This is for internal use to store events that need to be displayed
global PTBEventQueue;
PTBEventQueue = {};

% TODO: Do we want the ability to change this here?
% If so, Screen('Resolutions', screenNumber) will list the
% possible resolutions to go with.

% TODO: Might want to use these to define colors
% in the future.
% WhiteIndex(theWindowPtr)
% BlackIndex(theWindowPtr)

% Grab the screen
PTBTheWindowPtr = PTBCreateScreen(PTBTheScreenNumber,1);

% Need to set the style to normal
Screen('TextStyle',PTBTheWindowPtr,0);

% This prevents the OS from getting in the way.
% TODO: Allow configurability.
Priority(MaxPriority(PTBTheWindowPtr));

% Setup the text
global PTBTextFont;
if isempty(PTBTextFont)
	PTBTextFont = 'Courier';
end
global PTBTextSize;
if isempty(PTBTextSize)
	PTBTextSize = 30;
end
global PTBTextColor;
if isempty(PTBTextColor)
	PTBTextColor = [255 255 255];
end

% Show a start message
% TODO: Think about whether this is needed, or
% could be made better.
Screen('TextFont', PTBTheWindowPtr, PTBTextFont);
Screen('TextSize', PTBTheWindowPtr, PTBTextSize);

% Setup the startscreen
global PTBUseStartScreen;
if isempty(PTBUseStartScreen)
	PTBUseStartScreen = 1;
end
if PTBUseStartScreen
	Screen('DrawText', PTBTheWindowPtr, title, 50, 100, PTBTextColor);
	Screen('DrawText', PTBTheWindowPtr, ['Powered by PTB wrapper version: ' num2str(PTBWrapper.major)...
		'.' num2str(PTBWrapper.minor) '.' num2str(PTBWrapper.point)], 50, 180, PTBTextColor);
	if (PTBIsDebugging)
		Screen('TextSize', PTBTheWindowPtr, 25);
		 Screen('DrawText', PTBTheWindowPtr, 'Currently Debugging', 50, 260, PTBTextColor);
	end
end

% Record the first display
global PTBLastPresentationTime;
PTBLastPresentationTime = Screen('Flip', PTBTheWindowPtr);

% Show briefly
WaitSecs(startScreenTime);

% Make sure these are initialized
global PTBWaitingForKey;
PTBWaitingForKey = 0;
global PTBLastKeyPressTime;
PTBLastKeyPressTime = -1;
global PTBLastKeyPress;
PTBLastKeyPress = '';

% For a sound key
global PTBWaitingForSoundKey;
PTBWaitingForSoundKey = 0;
global PTBSoundKeyLevel;
PTBSoundKeyLevel = 0.01;
global PTBSoundKeyData;
PTBSoundKeyData = [];
global PTBRecordAudio;
PTBRecordAudio = [];
global PTBRecordAudioFileNames;
PTBRecordAudioFileNames = {};
global PTBSoundInputDevice;
PTBSoundInputDevice = [];
global PTBAudioTriggerFileName;
PTBAudioTriggerFileName = 'Sound_Data';
global PTBSoundNameFirst;
PTBSoundNameFirst = 0;
global PTBAudioTriggerFolderName;
PTBAudioTriggerFolderName = '.';

global PTBPrintRTData;
PTBPrintRTData = 1;

% Default the append to nothing
global PTBLogAppend;
if isempty(PTBLogAppend)
	PTBLogAppend = {};
end

% Setup the logfiles. Default to logfile.txt
global PTBLogFileName;
global PTBDataFileName;
global PTBSoundFileName;
if isempty(PTBLogFileName)
	PTBSetLogFiles('logfile.txt');
end
if isempty(PTBSoundFileName)
	PTBSoundFileName = 'Sound_Data';
end

% Now, initialize them.
PTBInitLogFiles;

% Set the random number generator
try
    RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock)));
catch %#ok<CTCH>
    % Not all matlabs have this installed
    disp('RandStream failed. Just a heads up. You should be fine.');
end

% Set the next to go as soon as possible
global PTBNextPresentationTime;
PTBNextPresentationTime = GetSecs;

% Also, useful for timestamping
global PTBStartTime;
PTBStartTime = PTBNextPresentationTime;


% And print out the start
global PTBLogHeaders;
global PTBLogFileID;
global PTBDataFileID;
PTBWriteLog(PTBLogFileID, 'START', num2str(PTBStartTime), '', PTBStartTime);
fprintf(PTBLogFileID, 'Display\tStimulus\tTag\tTime');
for h = 1:length(PTBLogHeaders)
    fprintf(PTBLogFileID,['\t' PTBLogHeaders{h}]); 
end
fprintf(PTBLogFileID,'\n');
if ~strcmp(PTBLogFileName, PTBDataFileName)
	PTBWriteLog(PTBDataFileID, 'START', num2str(PTBStartTime), '', PTBStartTime);
	fprintf(PTBDataFileID, 'Response\tKey\tRT\tAbs_RT\tStimulus\tTag');
    for h = 1:length(PTBLogHeaders)
        fprintf(PTBDataFileID,['\t' PTBLogHeaders{h}]); 
    end
    fprintf(PTBDataFileID,'\n');
end
