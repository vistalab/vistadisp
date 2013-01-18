function stim = flickerScreen(subject, stopForIntKeyOnly)
%
% Flicker stimulus to try to induce seizure in a reflex epilepsy patient.
%
%       stim = flickerScreen(subject, stopForIntKeyOnly)
%
% To stop showing the grid, press any key. If the stopForKbOnly flag is set
% to 1 [default value], the display will only stop when the "q" key is pressed on
% the main keyboard (but not button boxes, for instance). If 0, the "q" key on
% the internal keyboard or any key on the external keyboard will stop it. 
%
% The subject argument is an optional text label. It is only used in
% determining the name of the save file. 
%	If no subject name is passed, stimulus information is saved as:
%		data/ShowGrid-[date]-#.mat
%	otherwise, the save file is:
%		data/ShowGrid-[subject]-[date]-#.mat
%	where # is the number of the save file (counts existing save files, and
%	increments by 1 each time).
%
% written by: amr 10/29/08
%
% To do: add capability for subject keypress to end stimulus (with
% stopForKbOnly, see ShowGrid.m)
%

%% PARAMETERS
if notDefined('subject'),		subject = '';                       end
if notDefined('stopForIntKeyOnly'),	stopForIntKeyOnly = 1;			end

stim.frequency = 16; % frequency of flicker in Hertz

%% mark the time this function was invoked
stim.startTime = clock;
stim.startTimeSecs = GetSecs;

%% INITIALIZE SCREEN

scanparams.display = loadDisplayParams('displayName', '3T_projector_800x600');

scanparams.display.screenNumber = 1; % 0 = main display
                           
%[Window, Rect] = Screen('OpenWindow',scanparams.display.screenNumber); % open the window

% % Set fonts
% Screen('TextFont',Window,'Times');
% Screen('TextSize',Window,24);

scanparams.runPriority = 9;
scanparams.startScan = 0;
scanparams.display.devices = getDevices;

% check for OpenGL
AssertOpenGL;

% Open the screen
scanparams.display                = openScreen(scanparams.display);
HideCursor;

% Establish the quit key
quitProgKey = 'q';

%% INITIALIZATION
KbCheck;GetSecs;WaitSecs(0.001);

% set priority
Priority(scanparams.runPriority);

% wait for go signal
pressKey2Begin(scanparams.display);

% countdown + get start time (time0)
startExptTime = countDown(scanparams.display,scanparams.startScan+2,scanparams.startScan);
    
%% FLICKERING STIMULUS UNTIL USER PRESSES Q
timeBtwFlashes = 1/stim.frequency;
numFlash = 1;
while 1
    Screen('FillRect', scanparams.display.windowPtr, 0);    % black screen
    VBLstampBlack = Screen('Flip',scanparams.display.windowPtr);
    keyDown_int = KbCheck(scanparams.display.devices.keyInputInternal);
    keyDown_ext = KbCheck(scanparams.display.devices.keyInputExternal);
    WaitSecs('UntilTime',VBLstampBlack+(1/stim.frequency)/2);
    %keys1 = qkeys(GetSecs,timeBtwFlashes/4-0.01,scanparams.devices.keyInputInternal);   % -0.01 just because of delays
    %keys1_ext = qkeys(GetSecs,timeBtwFlashes/4-0.01,scanparams.devices.keyInputExternal);
    Screen('FillRect', scanparams.display.windowPtr, 255);  % white screen
    VBLstamps(numFlash) = Screen('Flip',scanparams.display.windowPtr);
    keyDown_int2 = KbCheck(scanparams.display.devices.keyInputInternal);
    keyDown_ext2 = KbCheck(scanparams.display.devices.keyInputExternal);
    WaitSecs('UntilTime',(VBLstamps(numFlash)+(1/stim.frequency)/2)-0.01);
    % check if user quits
    %keys2 = qkeys(GetSecs,timeBtwFlashes/4-0.01,scanparams.devices.keyInputInternal);
    %keys2_ext = qkeys(GetSecs,timeBtwFlashes/4-0.01,scanparams.devices.keyInputExternal);
    if stopForIntKeyOnly
        if keyDown_int || keyDown_int2
            break
        end
    else
        if keyDown_int || keyDown_int2 || keyDown_ext || keyDown_ext2
        %if strcmp(keys1(1),quitProgKey) || strcmp(keys2(1),quitProgKey) || ~strcmp(keys1_ext,'noanswer') || ~strcmp(keys2_ext,'noanswer')
            break
        end
    end
    numFlash = numFlash+1;
end

%% close up, save results
scanparams.display = closeScreen(scanparams.display);

mfileDir = fileparts( which(mfilename) );
dataDir = fullfile(mfileDir, 'data');
ensureDirExists(dataDir);

if isempty(subject)
	prefix = sprintf('%s-%s', mfilename, datestr(now, 1));
else
	prefix = sprintf('%s-%s-%s', mfilename, subject, datestr(now, 1));
end

% find any existing files with this prefix
w = dir( fullfile(dataDir, [prefix '*.mat']) );

% assign the file # as the next file in this series
fileNum = length(w) + 1;

stim.endTime = clock;
stim.endTimeSecs = getSecs;
stim.elapsedTime = stim.endTimeSecs - stim.startTimeSecs;
stim.measuredFreq = 1/median(diff(VBLstamps));

% report the times
fprintf('ShowGrid started at %s.\n ', datestr(stim.startTime));
fprintf('Finished at %s\n', datestr(stim.endTime));
fprintf('Elapsed time %2.0f min, %2.2f sec.\n', floor(stim.elapsedTime/60), mod(stim.elapsedTime, 60));
fprintf('Measured flicker frequency is %2.2f Hz\n', stim.measuredFreq);

% save the file
saveName = sprintf('%s-%i.mat', prefix, fileNum);
saveFile = fullfile(dataDir, saveName);
save(saveFile, '-struct', 'stim');
fprintf('Saved stim info in %s.\n', saveFile);


%% RESET PRIORITY AND SCREEN
Screen('Close');
Screen('CloseAll');
Priority(0);
ShowCursor;

return;


function keys = qkeys(startTime,dur,deviceNumber)
% If dur==-1, terminates after first keypress

KbQueueCreate(deviceNumber);
KbQueueStart();

WaitSecs('UntilTime',startTime+dur);

KbQueueStop();

[k.pressed, k.firstPress] = KbQueueCheck();

if k.pressed == 0
    keys = 'noanswer';
else
    keys = KbName(k.firstPress);
end