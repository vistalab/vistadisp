ip_address = '192.168.39.45'; %ip_address may not be correct as defined by NetStation ECI window... check system preferences.
port_number = 55513;
SynchLimit = 1.5;

%Connect to NetStation (Data Acquisition Computer)
NetStation ('Connect',ip_address,[port_number]);

%Synchronize to the connected host. SynchLimit specifies the minimum
%allowed time differential between host and STIM computer
NetStation('Synchronize', [SynchLimit]);

%Instruct NetStation to begin recording EEG data
NetStation ('StartRecording') 

%Begin Trial
PsychDefaultSetup(2);
screens = Screen('Screens');
screenNumber = max(screens);
white = WhiteIndex(screenNumber);
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, white);

ifi = Screen('GetFlipInterval', window); 
topPriorityLevel = MaxPriority(window);
numSecs = 5;
numFrames = round(numSecs / ifi);
waitframes = 1;

Priority(topPriorityLevel);
vbl = Screen('Flip', window);
for frame = 1:numFrames;
    
    Screen('FillRect', window, [0.5 0 0]);
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    NetStation('Event','Flip',[vbl],[numSecs]);
end

NetStation ('StopRecording')

Priority(0);
close all;
clear all;
sca;