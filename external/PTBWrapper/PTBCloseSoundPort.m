%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBCloseSoundPort.m
%
% NOTE: Internal function. DO NOT CALL.
%
% Stops and closes a sound port, if open.
% NOTE: This is only called when another one is needed.
% TODO: Figure out if this is bad...
%
% Args:
%   - port: The port to close
%
% Usage: PTBCloseSound
%
% Author: Doug Bemis
% Date: 1/21/10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBCloseSoundPort(port)

global PTBOpenSoundPorts;

% Don't actually close, because ptb doesn't keep track
%    of that. Just remove from the open list so we know what's going on.
for i = 1:length(PTBOpenSoundPorts)
    if PTBOpenSoundPorts(i) == port 
        PTBOpenSoundPorts = PTBOpenSoundPorts([1:i-1 i+1:end]);
        break;
    end
end
PsychPortAudio('Stop', port);
