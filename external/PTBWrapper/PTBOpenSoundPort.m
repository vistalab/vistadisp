%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBOpenSoundPort.m
%
% NOTE: Internal function. DO NOT CALL.
%
% Retrieves an open sound port, since psychtoolbox
%   will apparently return ports that are already open...
%
% Args: 
%   - freq: The frequency of the port to open
%   - channels: The number of channels in the port to open
%   - for_recording: Set to 1 for a recording channel
%       * Optional: Defaults to 0.
%
% Usage: PTBOpenSoundPort(44100, 2)
%
% Author: Doug Bemis
% Date: 3/6/12
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function port_handle = PTBOpenSoundPort(freq, channels, for_recording)

% Default to not recording
if ~exist('for_recording','var')
    for_recording = 0;
end

% Need to keep a list here of at least two open for
%   any frequency and channel combination. We'll be
%   ok as long as they're not over 512 of them...
global PTBSoundPortParameters;
global PTBSoundPorts;
global PTBOpenSoundPorts;
global PTBSoundInputDevice;

% See if we already have them open
port_ind = -1;
for p = 1:size(PTBSoundPortParameters,1)
    if PTBSoundPortParameters(p,1) == freq && ...
        PTBSoundPortParameters(p,2) == channels && ...
        PTBSoundPortParameters(p,3) == for_recording
        port_ind = p;
        break;
    end
end

% If we didn't get it, need to open them
if port_ind < 0
    port_ind = size(PTBSoundPortParameters,1)+1;
    PTBSoundPortParameters(port_ind,:) = [freq channels for_recording];
    if for_recording
		PTBSoundPorts(port_ind,1) = PsychPortAudio('Open', PTBSoundInputDevice, 2, 1, freq, channels);
		PTBSoundPorts(port_ind,2) = PsychPortAudio('Open', PTBSoundInputDevice, 2, 1, freq, channels);

		% Preallocate an internal audio recording  buffer with a capacity of 20 seconds:
		PsychPortAudio('GetAudioData', PTBSoundPorts(port_ind,1), 20);
		PsychPortAudio('GetAudioData', PTBSoundPorts(port_ind,2), 20);
    else
        PTBSoundPorts(port_ind,1) = PsychPortAudio('Open', [], [], 1, freq, channels);
        PTBSoundPorts(port_ind,2) = PsychPortAudio('Open', [], [], 1, freq, channels);
    end
end

% See if the first is in use
if ~any(PTBOpenSoundPorts == PTBSoundPorts(port_ind,1))
    port_handle = PTBSoundPorts(port_ind,1);
else
    if any(PTBOpenSoundPorts == PTBSoundPorts(port_ind,2))
        error('Too many sound ports open. Exiting...');
    end
    port_handle = PTBSoundPorts(port_ind,2);
end

% Make sure recording buffers are clear
if for_recording
    PsychPortAudio('GetAudioData', port_handle);
end

% And record that we're open
PTBOpenSoundPorts(end+1) = port_handle;


