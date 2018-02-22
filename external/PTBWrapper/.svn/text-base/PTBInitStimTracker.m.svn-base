%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBInitStimTracker.m
%
% Initializes the Cedrus StimTracker
%
% Usage: PTBInitStimTracker
%
% Author: Doug Bemis
% Date: 6/22/12
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBInitStimTracker

global PTBStimTrackerInitialized;
global PTBUSBBoxInitialized;
global PTBStimTrackerHandle;
global PTBTriggerPortInitialized;

% Make sure we're not trying to use too many trigger devices
if PTBUSBBoxInitialized == 1 || PTBTriggerPortInitialized == 1
    error('Only one trigger device can be used at one time.');
end

% Close the port first, to be sure
PTBShutdownStimTracker;

% Attempt to find the StimTracker
% Don't try this in windows
global PTBCurrComputerSpecs;
if PTBCurrComputerSpecs.osx
    
    % Not sure how foolproof this is. We're looking for the
    %   port number for the StimTracker. There will be some other ones.
    %   Not sure of the best way yet to determine which is the right one.
    
    % For now, search all the IO devices.
    % One correct port is cu.usbserial-A900a2R9, not sure how much of that
    %   is necessary. At least the 'usbserial'.
    error_msg = '';
    results = [];
    ThePortDevices = dir('/dev/cu*'); 
    for d = 1:length(ThePortDevices)
        if ~isempty(strfind(lower(ThePortDevices(d).name), 'usbserial'))
            results(end+1) = d; %#ok<AGROW>
        end
    end
    
    % Only expecting one for now...
    if isempty(results)
        error_msg = 'StimTracker not found.';
    elseif length(results) > 1
        error_msg = 'Too many (possible) StimTrackers found.';        

    % Try to open it
    else
        try 
            % NOTE: An error here seems to close the screen automatically,
            % so no obvious way to gracefully exit here...
            [PTBStimTrackerHandle errr] = IOPort('OpenSerialPort',['/dev/' ThePortDevices(results(1)).name],...
                sprintf('BaudRate=%i Parity=None DataBits=8 StopBits=1 FlowControl=Hardware ReceiveTimeout=1 ', 115200)); %#ok<NASGU>
            
            % Make sure it's the right device
            % NOTE: Can get the full product name with '_d1'            
            err = checkData('_d2','S');
            
            % This sometimes fails the first time...
            if err == 1
                
                % Close and then open again
                IOPort('Close',PTBStimTrackerHandle);
                [PTBStimTrackerHandle errr] = IOPort('OpenSerialPort',['/dev/' ThePortDevices(results(1)).name],...
                    sprintf('BaudRate=%i Parity=None DataBits=8 StopBits=1 FlowControl=Hardware ReceiveTimeout=1 ', 115200)); %#ok<NASGU>
                
                % And check again
                err = checkData('_d2','S');
                if err ~= 0
                    error('Bad connection. Exiting...');
                end
            elseif err > 0
                error('Bad connection. Exiting...');
            end
            
            % This one shouldn't fail
            err = checkData('_d3','C');
            if err ~= 0
                error('Bad connection. Exiting...');
            end
                                    
            
        catch %#ok<CTCH>
            error_msg = 'StimTracker initialization failed.'; 
        end
    end
else
    error_msg = 'StimTracker only implemented for mac.';
end

% Send a warning if we failed
if ~isempty(error_msg)
	PTBStimTrackerHandle = -1;
	PTBStimTrackerInitialized = 0;
	
	% Show to the console
    disp('WARNING! WARNING! WARNING! WARNING! WARNING! WARNING!');
	disp([error_msg ' No triggers will be sent.']);
    disp('WARNING! WARNING! WARNING! WARNING! WARNING! WARNING!');

	% And to the screen
	PTBDisplayParagraph({'WARNING! WARNING! WARNING! WARNING! WARNING! WARNING!',...
		[error_msg ' No triggers will be sent.'],'WARNING! WARNING! WARNING! WARNING! WARNING! WARNING!'},{'center',30},{'any'})	
	PTBDisplayBlank({.1},'Trigger warning');
	return;
end

% Set all the triggers to 0
% NOTE: Sending the 'mh' command as bytes for ease...
% NOTE: Also seems to be reversed for now, but not sure yet...
IOPort('Write',PTBStimTrackerHandle, uint8([109 104 bitcmp(uint8(0)) 0]));
disp('StimTracker found and ready to go.');
PTBStimTrackerInitialized = 1;


% Helper to check data
function err = checkData(cmd, chk)

% Give it some time to time out
time_out = .1;

% Be optimistic
err = 0;

% Write the data
% NOTE: Flushing may be unecessary, but can't hurt
global PTBStimTrackerHandle;
IOPort('Flush',PTBStimTrackerHandle);
IOPort('Write',PTBStimTrackerHandle,cmd);

% Need to wait for the bytes
start_time = GetSecs;
b_avail = 0;
while ~b_avail
    b_avail = IOPort('BytesAvailable',PTBStimTrackerHandle);
    if GetSecs - start_time > time_out
        break;
    end
end

% If we got some, check them
if b_avail > 0
    data = IOPort('Read',PTBStimTrackerHandle);
    if ~strcmp(char(data),chk)
        disp(['Wrong data found. Expected: ' chk '. Got: ' char(data) '. Failing...']);
        err = 2;
    end
    
% Otherwise, signal no bytes    
else
    err = 1;
end


            