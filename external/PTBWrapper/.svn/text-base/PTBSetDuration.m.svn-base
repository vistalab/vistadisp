%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBSetDuration.m
%
% NOTE: Internal function. DO NOT CALL.
%
% This is setup to do all the preparation to
% display while the previous screen is being viewed.
% Therefore, we simply use the duration to set
% the time for the next display, and move on to 
% preparing it.
%
% Args:
%	- duration: The duration to use
%
% Usage: PTBSetDuration({.3,'any'})
%
% Author: Doug Bemis
% Created: 7/4/09
% Modified: 7/2/12
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBSetDuration(duration, tag, type)

global PTBLastPresentationTime;
global PTBNextPresentationTime;
global PTBTheWindowPtr;
global PTBWaitingForKey;
global PTBWaitingForSoundKey;
global PTBExitKey;
global PTBInputDevice;
global PTBKeyTag;
global PTBKeyType;
global PTBInputCollection;
global PTBPortInput;
global PTBEndTriggers;
global PTBPrintRTData;
global PTBTrigSoundPort;
global PTBRecordingFrequency;
global PTBRecordingChannels;

% Make sure we can parse
if ~iscell(duration)
	error('Bad duration.');
end

% TODO: Probably only need to do this once at the start.
% TODO: This is unnecessary and wrong for audio stimuli. But, have
% to figure out what's next. Maybe subtract at presentation of next audio?
slack = Screen('GetFlipInterval', PTBTheWindowPtr);

% The keys that we'll be waiting for
global PTBKeysOfInterest;
if ~PTBWaitingForKey
    PTBKeysOfInterest=zeros(1,256);
end

% Set for no time out, if no duration set
% An hour should do it.
PTBNextPresentationTime = PTBLastPresentationTime + 3600;

% Setup all the conditions
got_sound = 0;
for i = 1:length(duration)
	
	% If a cell, assuming that the next argument
	% is an associated trigger, followed possibly by a 
	% trigger delay.
	if iscell(duration{i})
		
		% Add the trigger values
		if length(duration{i}) == 2
			PTBEndTriggers{end+1} = {duration{i}{1} duration{i}{2} 0}; %#ok<AGROW>
		elseif length(duration{i}) == 3
			PTBEndTriggers{end+1} = duration{i}; %#ok<AGROW>
		else
			error('Bad duration. Exiting...');
		end
		
		% Add the first argument as a standalone duration
		duration{i} = duration{i}{1};
	end
	
	% If numeric, just set and go
	if isnumeric(duration{i})

		% Need to adjust for refresh rate
		% TODO: Why does the pdf slides use Screen('GetFlipInterval', theWindowPtr) / 2?
		% TODO: Still needs some work (off by about 1ms, but consistently fast.
		% Much more testing needed...

		% If duration is over 200, assume we're setting an absolute
		% duration instead of relative. 
        % TODO: Make this better
		if (duration{i} > 200)
			PTBNextPresentationTime = duration{i} - slack;
		else
			PTBNextPresentationTime = PTBLastPresentationTime + duration{i} - slack;
		end

	% Might be a sound trigger
	elseif strcmpi(duration{i}, 'sound') 
        
        % Don't want to do this twice in one go
        if got_sound
            continue;
        end
        got_sound = 1;
		        
		% For now, we'll treat this as a special key
		PTBWaitingForSoundKey = 1;
		PTBWaitingForKey = 1;

		% Perform basic initialization of the sound driver, to be sure
		PTBInitSound(1);

		% Open the default audio device [],  
        %   and 2 sound channels for stereo capture.
		PTBTrigSoundPort = PTBOpenSoundPort(PTBRecordingFrequency,PTBRecordingChannels,1);

		% Start audio capture immediately and wait for the capture to start.
		% We set the number of 'repetitions' to zero,
		% i.e. record until recording is manually stopped.
		PsychPortAudio('Start', PTBTrigSoundPort, 0, 0, 1);
	
		% And record what we're waiting at
		PTBKeyTag = tag;
		PTBKeyType = type;
		
	% Special 'anykey'
	elseif strcmpi(duration{i}, 'any')
		PTBKeysOfInterest = ones(1,256);
		
	% Special 'exit' key, and won't print out
	elseif strcmpi(duration{i}, 'exit')
		PTBKeysOfInterest(KbName(PTBExitKey))=1;
        
        % Don't preint this out if we're just giving an exit
        PTBPrintRTData = 0;

	% Set a response key
    else
        
        % NOTE: For 'Port' input, we'll just be mapping on the 
        % '0' to '9' keys. The conversion is then done in WaitForKey.
        PTBKeysOfInterest(KbName(duration{i}))=1;
	end
end

% Set up the queue, if waiting for a key
global PTBDisableTimeOut;
if sum(PTBKeysOfInterest) > 0
	
	% Add the exit key, if needed
	PTBKeysOfInterest(KbName(PTBExitKey)) = 1;
	
	% TODO: Should probably build for the
	% delay associated with checking the key
	% before timing out. Or move to PTBWaitForKey.
	% i.e. nextDisplayTime = nextDisplayTime - 0.015.
	
    % Queue functions only work for mac and then, 
	% only sometimes
    if strcmp(PTBInputCollection, 'Queue')

        % TODO: Figure out deviceNumbers.
        % NOTE: Do NOT call KbQueueRelease, unless 
        % you really feel it's necessary. This should 
        % act to change the parameters of the queue
        % and KbQueueRelease causes crashes.
        KbQueueCreate(PTBInputDevice, PTBKeysOfInterest);

        % Clear it here.
        % TODO: Figure out how much funcationality
        % we want here.
        KbQueueFlush;

        % Start up the queue and keep going.
        KbQueueStart;	
		
	% Otherwise, wait for the input to clear
    elseif strcmp(PTBInputCollection, 'Check')

		% Wait for all keys to be released, if we're not
		% holding over
        if ~PTBDisableTimeOut
			KbWait(PTBInputDevice,1);
        end
		
	% Or, simply clear
    else
        if ~PTBDisableTimeOut
			FlushEvents('KeyDown');
        end
    end
    
    if PTBPortInput == 1        
        % NOTE: Have to wait for a clear port at some point, but choosing
        % to do so before waiting for the key. If here, then will have to
        % delay setup for held keys...
    end        
	
	% Mark that we're waiting
	PTBWaitingForKey = 1;
	
	% And record what we're waiting at
	PTBKeyTag = tag;
	PTBKeyType = type;
	
end

