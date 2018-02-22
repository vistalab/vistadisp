%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBSendTrigger.m
%
% NOTE: Internal function. DO NOT CALL.
%
% Sends a trigger to the USBBox.
%
% Args:
%	- value: 0-255 trigger values to send
%   - trigger_delay: The delays to use for each trigger.
%
% Usage: PTBSendTrigger(30)
%
% Author: Doug Bemis
% Date: 2/3/10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBSendTrigger(triggers, triggers_delay)

% Check that we have something to use
global PTBUSBBoxInitialized;
global PTBStimTrackerInitialized;
global PTBTriggerPortInitialized;
global PTBEyeTrackerRecording;
if ~PTBUSBBoxInitialized && ~PTBStimTrackerInitialized &&...
        ~PTBTriggerPortInitialized && ~PTBEyeTrackerRecording

	disp('WARNING: No trigger sent.');
	return;
    
% This should never happen... 
% Check the Init functions
elseif (PTBStimTrackerInitialized + PTBUSBBoxInitialized + PTBTriggerPortInitialized) > 1
    error('Too many trigger devices in use.');
end

% Send the triggers
global PTBUSBBoxDeviceID;
global PTBStimTrackerHandle;
global PTBTriggerLength;

% Schedule the triggers
curr_time = GetSecs;
for i = length(triggers_delay):-1:1
    triggers_delay(i) = triggers_delay(i) + sum(triggers_delay(1:i-1)) + curr_time;
end

% Account for the trigger length for any triggers after the first
% triggers_delay = triggers_delay - PTBTriggerLength;
% triggers_delay(1) = triggers_delay(1) + PTBTriggerLength;
for i = 1:length(triggers)

    % Sometimes need to delay, because it gets there before the screen
    while GetSecs < triggers_delay(i)
    end

    % Send the trigger
    trig_time = GetSecs;
    
    if PTBUSBBoxInitialized
        PsychHID('SetReport', PTBUSBBoxDeviceID, 2, hex2dec('32'), uint8(zeros(1,2)+triggers(i)));
    elseif PTBStimTrackerInitialized
        
        % NOTE: Sending the 'mh' command as bytes for ease...
        % NOTE: Also seems to be reversed for now, but not sure yet...
        IOPort('Write',PTBStimTrackerHandle, uint8([109 104 bitcmp(uint8(triggers(i))) 0]));
    elseif PTBTriggerPortInitialized

        % Write to the port
        lptwrite(888,triggers(i))
        
    elseif ~PTBEyeTrackerRecording
        error('Should never get here.');
    end
            
    % If we're recording eye-tracking data, assume we want to send here as well.
	% TODO: What values can we send, and how?
	if PTBEyeTrackerRecording
        
        % Check recording status, stop display if error
        status = Eyelink('CheckRecording');
        if status ~= 0
            error('Eyetracker stopped recording.');
        end
        
        % If good, then send
		status = Eyelink('Message','MEG Trigger: %i', triggers(i));
        if status ~= 0
            error('Could not send message.');
        end
	end
	
    pause(PTBTriggerLength);
    if PTBUSBBoxInitialized
        PsychHID('SetReport', PTBUSBBoxDeviceID, 2, hex2dec('32'), uint8(zeros(1,2)));
    elseif PTBStimTrackerInitialized
        IOPort('Write',PTBStimTrackerHandle, uint8([109 104 bitcmp(uint8(0)) 0]));
    elseif PTBTriggerPortInitialized
        lptwrite(888,0);
    elseif ~PTBEyeTrackerRecording
        error('Should never get here.');
    end
end

% Want to record
global PTBLogFileID;
if PTBUSBBoxInitialized
    PTBWriteLog(PTBLogFileID, 'TRIGGER', 'USBBox', num2str(triggers), trig_time);	
elseif PTBStimTrackerInitialized
    PTBWriteLog(PTBLogFileID, 'TRIGGER', 'StimTracker', num2str(triggers), trig_time);	
elseif PTBTriggerPortInitialized
    PTBWriteLog(PTBLogFileID, 'TRIGGER', 'ParallelPort', num2str(triggers), trig_time);	
elseif ~PTBEyeTrackerRecording
    error('Should never get here.');
end
if PTBEyeTrackerRecording
	PTBWriteLog(PTBLogFileID, 'TRIGGER', 'EyeLink', num2str(triggers), trig_time);	
end
    