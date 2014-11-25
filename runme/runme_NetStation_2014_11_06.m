%% SSEEG

%ip_address may not be correct as defined by NetStation ECI window... check system preferences.
ip_address = '169.254.187.13'; 
%ip_address = '10.0.0.42'; 
port_number = 55513;
SynchLimit = 1.5;

%Connect to NetStation (Data Acquisition Computer)
NetStation ('Connect',ip_address,[port_number]);

%Synchronize to the connected host. SynchLimit specifies the minimum
%allowed time differential between host and STIM computer
NetStation('Synchronize', [SynchLimit]);

%Instruct NetStation to begin recording EEG data
NetStation ('StartRecording') 

%Run experiment
runme_EEG_OnOffLeftRight(1, 'egi_calibration_params');

%Instruct NetStation to stop recording EEG data
NetStation ('StopRecording')

