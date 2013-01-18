function doWordScan(exptCode, scanparams)
%
% Runs a moving dot word scan.
% ** Requires making the stimuli with makeWordScanStimuli before running
% this script.  Loads in mat files (created by said script)
% with each file corresponding to movies in an individual block.
%
%    doWordScan([exptCode],[scanparams])
%
% The question is whether OTS responds during simple reading tasks when the
% words are defined by moving dots (or other contrasts) and not only by
% sharp edges.
%

%
% As an example, you may need to add these to your path!
% cd('c:\u\brian\Matlab\Psychtoolbox'); addpath(genpath(pwd))
% cd('c:\u\brian\Matlab\Vistadisp\Applications2');addpath(genpath(pwd))
% cd('c:\u\brian\Matlab\Vistadisp\exptTools2'); addpath(genpath(pwd))
% Wandell uses a script: ptbPath

% addpath(genpath(pwd))

%  1.  Load the display properties
%  2.  Create the fixed word outline
%  3.  Make the moving text for the word outline
%  4.  Select the sequence of moving words to present
%  5.  Schedule the words for the test block - and blanks
%        block design (Test vs. Fixation)
%      (At some point we might do words versus motion)
%      (We could do moving words versus fixed/luminance words)
%  6.

%% Any parameters to set before running

% initial "dummy" fixation
dummyFixLength = 0; % in secs, %12
    
%% Find out from user where the movie blocks are

pathName = '/Users/Shared/AndreasWordsMatlab/WordFiles';
if exist('exptCode','var')
    while 1
        moviesDir = fullfile(pathName,['MovieBlocks_exptCode_' num2str(exptCode)]);
        if exist(moviesDir,'dir')
            break;
        else
            fprintf('Movie directory %s\n',moviesDir)
            fprintf('does not exist! Please pick new experiment code or cntrl-C to stop. \n\n')
            exptCode = input('Experiment code:  ');
        end
    end
else
    if exist('/Users/Shared/AndreasWordsMatlab/WordFiles','dir')
        %moviesDir = uigetdir('/Users/Shared/AndreasWordsMatlab/WordFiles','Please choose directory with your blocks.');
        moviesFile = mrvSelectFile('r','mat','Please point to a single block file in movies directory','/Users/Shared/AndreasWordsMatlab/WordFiles');
    else
        %moviesDir = uigetdir(pwd,'Please choose directory with your blocks.');
        moviesFile = mrvSelectFile('r','mat','Please point to a single block file in movies directory',pwd);
    end
    moviesDir = fileparts(moviesFile);
end
notesFile = fullfile(moviesDir,'moreInfo.mat');
load(notesFile);


%% Input parameters

if notDefined('scanparams'), scanparams = initWordParams('mr'); end

% Set some more parameters.  Serge had a GUI to do most of these.
scanparams.runPriority = 9;
scanparams.repetitions = 1;
scanparams.startScan = 0;
scanparams.temporal.frequency = 1;

%% User sets here which calibration file to use

% scanparams.display = loadDisplayParams('displayName','NEC485words.mat');%('builtin');%'tenbit');
scanparams.display = loadDisplayParams('displayName', '3T_projector_800x600');

% The following will make it run externally unless mirror mode is selected
screens=Screen('Screens'); % find the number of screens 
scanparams.display.screenNumber = max(screens); % put this on the highest number screen
                                                % (0 is the 1st screen)  
                                                
if scanparams.display.screenNumber ~= 0  % then not running under mirror mode
    sprintf('\n%s\n', 'YOU SHOULD BE RUNNING THE REAL EXPERIMENT UNDER MIRROR MODE TO IMPROVE TIMING')
    WaitSecs(2);
end

% prefsDisplayName  % print out the display name that has been saved previously or set a new one if none exists
% *** To change the display after it is already set, run
% prefsDisplayName(1) and choose the display.

% If you already have a display name from prefsDisplayName, you can just
% call loadDisplayParams without arguments.
% scanparams.display = loadDisplayParams;

%% Set a few more things
scanparams.devices = getDevices;

% Establish the code for the quit key
if checkfields(scanparams,'display','quitProgKey')
    quitProgKey = scanparams.display.quitProgKey;
else quitProgKey = KbName('q');
end


%% Within a loop: load a block, show it, end with fixation frame and repeat

KbCheck;GetSecs;WaitSecs(0.001);

try
    % check for OpenGL
    AssertOpenGL;

    % Open the screen
    scanparams.display                = openScreen(scanparams.display);
    scanparams.display.devices        = scanparams.devices;

    % set priority
    Priority(scanparams.runPriority);

    % wait for go signal
    pressKey2Begin(scanparams.display);

    % countdown + get start time (time0)
    [time0] = countDown(scanparams.display,scanparams.startScan+2,scanparams.startScan);
    %     tic
    startExptTime = GetSecs;
    
    % initial "dummy" fixation
    drawFixation(scanparams.display,1);
    Screen('Flip', scanparams.display.windowPtr);
    Screen('Close');
    WaitSecs(dummyFixLength);
    
    for blockNum = 1:totNumBlocks
        % show a fixation frame
        drawFixation(scanparams.display,1);
        Screen('Flip', scanparams.display.windowPtr);
        Screen('Close');

        % gotime will determine when to move on to the next block.  In the
        % meantime, we load up that next block.
        gotime = dummyFixLength + startExptTime + (blankLength*blockNum + blockLength*(blockNum-1));
        moviesFile = fullfile(moviesDir,['block_' num2str(blockNum) '.mat']);
        tmp = load(moviesFile);
        movieBlock = tmp.blockInfo;
        clear tmp;

        % Store the images in textures
        movieBlock = makeTextures(scanparams.display,movieBlock); %could also use createTextures?

        % Leave fixation on until time to show next block
        WaitSecs('UntilTime',gotime);
        tic
        quitProg = showScanBlock(scanparams.display, movieBlock, quitProgKey);%,time0);
        toc

        if quitProg, % don't keep going if quit signal is given
            break;
        end

    end

    % show another fixation at the end (unless user quit)
    if ~quitProg
        drawFixation(scanparams.display,1);
        Screen('Flip', scanparams.display.windowPtr);
        timeNow = GetSecs;
        gotime = timeNow + blankLength; %show it for blankLength secs
        Screen('Close'); %close the off-screen window
        WaitSecs('UntilTime',gotime);
    end
    
    endExptTime = GetSecs;
    totExptTime = endExptTime - startExptTime;
    fprintf('Total run length: %0.3f%s\n',totExptTime,' seconds.');

    %     toc
    Priority(0);


    % process response data to compute performance
    %         [pc,rc,nn] = getFixationPerformance(scanparams.fix,stim,response);
    %         disp(sprintf('[%s]:Fixation dot task(%d): percent correct: %.1f %%, reaction time: %.1f secs',mfilename,nn,pc,rc));
    %
    % get 1-back performance
    %         if exist('onebackSequence') && ~isempty(onebackSequence),
    %             [pc,rc,nn] = getDetectionPerformance(scanparams.fix,stim,response,onebackSequence);
    %              disp(sprintf('[%s]:One-back task(%d): percent correct: %.1f %%, reaction time: %.1f secs',mfilename,nn,pc,rc));
    %         end;

    % save
    %         if scanparams.savestimparams,
    %             filename = ['~/Desktop/' datestr(now,30) '.mat'];
    %             save(filename);                % save parameters
    %             disp(sprintf('[%s]:Saving in %s.',mfilename,filename));
    %         end;

    % Close the one on-screen and many off-screen windows
    closeScreen(scanparams.display);
    Screen('Close');
catch
    % clean up if error occurred
    Screen('CloseAll');
    % setGamma(0);  turned my screen blue --amr
    Priority(0);
    ShowCursor;
    rethrow(lasterror);
end

Screen('CloseAll');
Priority(0);
ShowCursor;
return