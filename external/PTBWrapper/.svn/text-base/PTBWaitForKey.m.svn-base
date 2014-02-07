%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBWaitForKey.m
%
% NOTE: Internal function. DO NOT CALL.
%
% This waits for a key to be pressed and records it.
%
% Usage: PTBWaitForKey
%
% Author: Doug Bemis
% Date: 7/4/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: Take variable args and parse.
% TODO: Error checking.
function PTBWaitForKey

global PTBWaitingForKey;
global PTBWaitingForSoundKey;
global PTBLastPresentationTime;
global PTBNextPresentationTime;
global PTBExitKey;
global PTBLastKeyPressTime;
global PTBLastKeyPress;
global PTBDisableTimeOut;
global PTBAddedResponseTime;
global PTBKeysOfInterest;
global PTBKeyTag;
global PTBKeyType;
global PTBInputCollection;
global PTBPortInput;
global PTBInputDevice;
global PTBTrigSoundPort;
global PTBSoundKeyLevel;
global PTBSoundKeyData;
global PTBPrintRTData;
global PTBStartTime;

% Have to wait here for clear ports, so will hang here for responses
%   fast enough to beat the setup time of the following display/
if PTBPortInput == 1
    while ~isempty(PTBCheckResponsePorts())
    end
end

% For now, just waiting for any key.
% TODO: Error check and extend.
pressed = 0;
while pressed == 0
    
    % Even if we got one last time, maybe it was wrong, and we
    %   don't have one now
    gotSoundKey = 0;
    got_port_key = 0;

	% Might be looking for a sound
	if PTBWaitingForSoundKey
		
        % Fetch current audiodata:
        [audiodata offset overflow tCaptureStart] = PsychPortAudio('GetAudioData', PTBTrigSoundPort); %#ok<ASGLU>

		% For now, record everything...
		PTBSoundKeyData = [PTBSoundKeyData audiodata]; %#ok<AGROW>

        % Compute maximum signal amplitude in this chunk of data:
        if ~isempty(audiodata)
            level = max(abs(audiodata(1,:)));
        else
            level = 0;
        end
        
        % Below trigger-threshold?
        if level > PTBSoundKeyLevel %#ok<ALIGN>
			pressed = 1;
			gotSoundKey = 1;
		end
	end
	
    % Use the good stuff for mac...
    if strcmp(PTBInputCollection, 'Queue')

        % Grab the key, and record
        [pressed, firstPress] = KbQueueCheck;
        
     % ...otherwise, the bad stuff
	elseif strcmp(PTBInputCollection, 'Check')
        
        % Check the current input device
    	[keyIsDown, timeSecs, keyCode] = KbCheck(PTBInputDevice);
        
        % See if we got one we wanted
        if keyIsDown && (sum(PTBKeysOfInterest & keyCode) > 0) %#ok<ALIGN>
            pressed = 1;
		end
		
	% ...or the really bad stuff
	elseif strcmp(PTBInputCollection, 'Char')

		% Check for a character
		while CharAvail
			
			% See if we wanted it
			[ch when] = GetChar; %#ok<NASGU>
			
			% TODO: Fix errors from control keys
			try
				if PTBKeysOfInterest(KbName(ch)) > 0
					pressed = 1;

					% NOTE: The 'when' is really bad, so, just
					% do was well as we can.
					char_press_time = GetSecs;
					break;
				end
			catch %#ok<CTCH>
				% Just keep going for now...
			end
		end
    end
    
    % And check the ports if we need to 
    if PTBPortInput == 1
        [key_codes key_time] = PTBCheckResponsePorts();

        % See if we got one, and it's the one we wanted
        if ~isempty(key_codes)
            
            for k = 1:length(key_codes)
                if PTBKeysOfInterest(key_codes(k)) == 1
                    key_code = key_codes(k);
                    pressed = 1;
                end
            end
            got_port_key = 1;
        end
    end
    
    % See if we've timed out
    timeOutCheck = GetSecs;
    if timeOutCheck > PTBNextPresentationTime

        % TODO: Slight chance that a button 
        % was pressed during the last loop. 
        % Should probably check...
        pressed = -1;
        break;
    end

end

% Either got a press...
global PTBDataFileID;
global PTBEndTriggers;
global PTBRecordAudio;
global PTBRecordAudioFileNames;
global PTBAudioTriggerFileName;
if pressed > 0

    % Handle queue responses
	% Need to set PTBLastKeyPressTime and PTBLastKeyPress
	if gotSoundKey

		% Record the info
		freq = 44100;
	    idx = min(find(abs(audiodata(1,:)) >= PTBSoundKeyLevel)); %#ok<MXFND>
		PTBLastKeyPressTime = tCaptureStart + ((offset + idx - 1) / freq);
		PTBLastKeyPress = 'sound';

		% Record through the next display
        PTBRecordAudio(end+1,:) = [PTBTrigSoundPort,2];
        PTBRecordAudioFileNames{end+1} = PTBAudioTriggerFileName;
        PTBTrigSoundPort = -1;
        
    elseif got_port_key

        firstKey = key_code;
        PTBLastKeyPress = KbName(key_code);
        PTBLastKeyPressTime = key_time;
        
	elseif strcmp(PTBInputCollection, 'Queue')

        % Find the first key press
        % TODO: There's probably a better way to do this.
        % If only one key press, can do away with most of this.
        firstKey = find(firstPress == min(firstPress(find(firstPress > 0)))); %#ok<FNDSB>

        % Record the time and press
        PTBLastKeyPressTime = firstPress(firstKey);
        PTBLastKeyPress = KbName(firstKey);

        % Just stop listening for now
        KbQueueStop;
        KbQueueRelease;
       
    % Or Windows responses
	elseif strcmp(PTBInputCollection, 'Check')
        
        % Get the pressed key
        % TODO: This will wrongly record if two
        % of the response keys are pressed at the same
        % time...
        firstKey = min(find(PTBKeysOfInterest & keyCode > 0)); %#ok<MXFND>
        
        % Record the time and press
        PTBLastKeyPressTime = timeSecs;
        PTBLastKeyPress = KbName(firstKey);
		
	elseif strcmp(PTBInputCollection, 'Char')

		% Record the time and press
		firstKey = KbName(ch);
        PTBLastKeyPressTime = char_press_time;
        PTBLastKeyPress = ch;
	end
	
	% Send a trigger, if necessary
	if ~isempty(PTBEndTriggers)
		
		% Check for matching
		for i = 1:length(PTBEndTriggers)
			if strcmp(PTBEndTriggers{i}{1},'any') || strcmp(PTBEndTriggers{i}{1}, PTBLastKeyPress)
				PTBSendTrigger(PTBEndTriggers{i}{2}, PTBEndTriggers{i}{3});
			end
		end
	end

	% Get response time
	RT = PTBAddedResponseTime + PTBLastKeyPressTime - PTBLastPresentationTime;
    log_type = 'KEY';
    
	% For now, always clear when get a key
	PTBNextPresentationTime = 0;
	
	% Check the exit key
	if ~gotSoundKey && ~isempty(PTBExitKey) && KbName(PTBExitKey) == firstKey
		error('Exit key pressed.');
	end

	% Reset the flag.
	PTBWaitingForKey = 0;
	PTBWaitingForSoundKey = 0;
	
	% No more added time
	PTBAddedResponseTime = 0;

% ...or timed out.
else
	
	%  Only record if we're not disabled
	if ~PTBDisableTimeOut
		PTBLastKeyPress = 'TIMEOUT';
		PTBLastKeyPressTime = PTBStartTime-1;
        RT = -1;
        log_type = 'TIMEOUT';

		% Might need to reset the sound
		if PTBWaitingForSoundKey
			
			% Stop capture
            PTBCloseSoundPort(PTBTrigSoundPort);
		end
		
		% Just stop listening for now
        if strcmp(PTBInputCollection, 'Queue') %#ok<ALIGN>
        	KbQueueStop;
            KbQueueRelease;
		end
        		
		% And clear
		FlushEvents();

		% Reset the flag.
		PTBWaitingForKey = 0;
		PTBWaitingForSoundKey = 0;
		
		% No more added time
		PTBAddedResponseTime = 0;

	% Need to keep this running
	else
		PTBLastKeyPress = 'TIMEOUT';
		PTBAddedResponseTime = PTBAddedResponseTime + PTBNextPresentationTime - PTBLastPresentationTime;
	end
end

% And write the results, if we want to
if PTBPrintRTData
    PTBWriteLog(PTBDataFileID, log_type, PTBLastKeyPress, num2str(RT), PTBLastKeyPressTime, PTBKeyType, PTBKeyTag);
else
    % Want to automatically reset to do next time
    PTBPrintRTData = 1;
end

% Done with this now.
% NOTE: Do NOT call this here. Causes matlab to
% crash randomly. Can just kep calling KbQueueCreate
% to change options.
% KbQueueRelease;
