%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBCleanupExperiment.m
%
% Does the cleanup for a PTBExperiment. Call this
% if the screen is still up and you don't want it to be.
%
% Args:
%
% Usage: PTBCleanupExperiment
%
% Author: Doug Bemis
% Date: 7/3/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBCleanupExperiment

global PTBKeyFileName;
global PTBNextPresentationTime;
global PTBVisualStimulus;
global PTBAudioStimulus;
global PTBEventQueue;
global PTBKeyQueue;
global PTBWaitingForKey;
global PTBInputCollection;
global PTBOldVisualDebugLevel;
global PTBOldSupressAllWarnings;

% This errors sometimes. Want to make sure we get the error anyway.
try

    % Write the keystrokes, if necessary
    if ischar(PTBKeyFileName)
        PTBLogKeyStrokes;
    end

    % Shutdown the sound
    PTBShutDownSound;

    % Save any sound
    PTBSaveSoundKeyData;

    % Stop the eyetracker
    PTBStopEyeTrackerRecording;

    % Shutdown the StimTracker
    PTBShutdownStimTracker;
    
    % Shut down port listening
    PTBSetPortInput(0);

    % Clear the screen.
    if ~isempty(Screen('Windows'))

        % And clear
        PTBEventQueue = {};
        PTBKeyQueue = {};
        if strcmp(PTBInputCollection, 'Queue')
            KbQueueRelease;
        end
        if PTBNextPresentationTime - GetSecs > 1000
            PTBNextPresentationTime = 0;
        end
        PTBVisualStimulus = 1;
        PTBAudioStimulus = 0;
        PTBSetLogAppend(0,'clear',{});
        PTBWaitingForKey = 0;
        PTBPresentStimulus({0},'Cleanup', '',[],[],'');
    end

    % Restore preferences
    if ~isempty(PTBOldVisualDebugLevel)
        Screen('Preference', 'VisualDebugLevel', PTBOldVisualDebugLevel);
        Screen('Preference', 'SuppressAllWarnings', PTBOldSupressAllWarnings);
    end

    % TODO: Look into garbage collection here.
    global PTBCurrComputerSpecs;
    if ~isempty(PTBCurrComputerSpecs)
        if PTBCurrComputerSpecs.osx
            KbQueueRelease;
        end
    end
    Priority(0);
    ListenChar(0);
    ShowCursor
    Screen('CloseAll');
    fclose('all');

catch
    % Warn if errored and clean up anyway.
    disp(' ');
    disp(' ');
    disp('WARNING: Error in PTBCleanupExperiment. Try running again, to make sure everything closed.');
    disp(' ');
    disp(' ');
    Priority(0);
    ListenChar(0);
    ShowCursor
    Screen('CloseAll');
    fclose('all');
end
