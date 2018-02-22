%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBWrapperRoot.m
%
% NOTE: Internal function. DO NOT CALL.
%
% Returns the path to the Psychtoolbox folder, even if it's been renamed.
% Also see matlaboot, DiskRoot, [and maybe DesktopFolder].
%
% Author: Doug Bemis (really the psychtoolbox team)
% Date: 2/5/10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function path = PTBWrapperRoot

path=which('PTBWrapperRoot');
i=find(filesep==path);

% NOTE: Add -1 after end for each 
% folder we're in under PTBWrapper.
path=path(1:i(end));
