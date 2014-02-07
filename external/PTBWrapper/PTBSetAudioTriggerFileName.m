%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBSetAudioTriggerFileName.m
%
% Sets the name of the next audio trigger file.
%
% Args:
%	- name: The name to use.
%   - name_first: If 1, sets the name first in the recorded file (optional)
%       * Defaults to 0.
%
% Usage: PTBSetAudioTriggerFileName({'stim_name'})
%
% Author: Doug Bemis
% Date: 3/8/12
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBSetAudioTriggerFileName(name, name_first)

% Set
global PTBAudioTriggerFileName;
PTBAudioTriggerFileName = name;

global PTBSoundNameFirst;
if exist('name_first','var') && name_first == 1
    PTBSoundNameFirst = 1;
end
