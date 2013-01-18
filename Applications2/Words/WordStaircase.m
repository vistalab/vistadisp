function stimFile = WordStaircase
% Runs a staircase on words defined by dots.  The dots inside the form can
% be differentiated from those outside the form either by luminance or by
% motion.  Choose parameters for the staircase in initWordParams.
%
%
% Authors: Dougherty, Rauschecker, Reno

%% Initialize Data Directory
dataDir = '/Users/Shared/PsychophysData/WordStaircase/';
if(~exist(dataDir,'dir')), mkdir(dataDir); end
stimFile = fullfile(dataDir, 'stimCache.mat');

%% Initialize Experimental Parameters
[stimParams,stairParams] = initWordParams('psychophysics',stimFile); % Initialize experimental parameters
priorityLevel = 0; % Set priority level to low (why? I'm not sure why)

%% Initialize Subject Information
subjectName = 'demo';
comment = 'none';
dlgPrompt = {'Enter the subject name: ','Enter a comment: '};
dlgTitle = 'Subject Name';
resp = inputdlg(dlgPrompt,dlgTitle,1,{subjectName,comment}); % Input dialog for subject info
if isempty(resp), return; end % No subject info?  Quit out
stimParams.subjName = resp{1}; % Store the subject's name in stimParams

%% Initialize Displays
AssertOpenGL;
screens=Screen('Screens'); % find the number of screens
hideCursor = false; % Don't hide the cursor (why? I'm not sure why)
display = loadDisplayParams('displayName', 'NEC485words.mat'); % Load display parameters up
display.screenNumber = max(screens); % put this on the highest number screen
display.devices = getDevices;
stairParams.device = getBestDevice(display);
display = openScreen(display,hideCursor); % Open the screen

%% Initialize Log File and Other Malarkey
subjectName = resp{1};
dataSumName = fullfile(dataDir,[subjectName 'sum']);
logFID(1) = fopen(fullfile(dataDir,[subjectName '.log']), 'at');
fprintf(logFID(1), '%s\n', datestr(now));
if(~isempty(stairParams.curStairVars))
    fprintf(logFID(1), '%s = [ %s ]', stairParams.curStairVars{1}, num2str(stairParams.curStairVars{2}));
end
fprintf(logFID(1), '\n');
logFID(2) = 1;
dotSpeed = pix2angle(display,1) / stimParams.frameDuration; % Calculate the dot speed
fprintf('dotSpeed = %f degrees/sec',dotSpeed); % Print the dot speed (why? I'm not sure why)

%% Initialize Staircase Procedure
HideCursor; % Hide the cursor
%for ii=1:4
    try
        % doWordStaircase is doStaircase modded to allow saving of word types/indices
        newDataSum = doStaircase(display, stairParams, stimParams, stairParams.trialGenFuncName, ...  %% This is the key line
            priorityLevel, logFID, 'precomputeFirstTrial');

        newDataSum(1).stimParams = stimParams;
        newDataSum(1).stairParams = stairParams;

        % Try to merge new data with existing dataSum
        sumExists = 1;
        eval('load(dataSumName)', 'sumExists = 0;');
        if sumExists
            dataSum = [dataSum newDataSum];
            save(dataSumName, 'dataSum');
            disp(['DataSum file ' dataSumName ' updated.']);
        else
            disp(['DataSum file ' dataSumName ' not found.']);
            dataSum = newDataSum;
            save(dataSumName, 'dataSum');
            disp(['New dataSum file ' dataSumName ' saved.']);
        end
        %if newDataSum(1).abort, break; end
    catch
        sca;
        rethrow(lasterror);
    end
%end

closeScreen(display); % Close the screen
ShowCursor; % Show the cursor

