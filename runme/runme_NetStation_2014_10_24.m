%% SSEEG

ip_address = '192.168.39.45'; %ip_address may not be correct as defined by NetStation ECI window... check system preferences.
port_number = 55513;
SynchLimit = 1.5;

%Connect to NetStation (Data Acquisition Computer)
NetStation ('Connect',ip_address,[port_number]);

%Synchronize to the connected host. SynchLimit specifies the minimum
%allowed time differential between host and STIM computer
NetStation('Synchronize', [SynchLimit]);

%Instruct NetStation to begin recording EEG data
%NetStation ('StartRecording') 

runme_EEG_OnOffLeftRight(1, 'onOffLeftRight_params');

%NetStation ('StopRecording')

