%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBInitLogFiles.m
%
% NOTE: Internal function. DO NOT CALL.
%
% Initialize the log files.
%
% Args:
%
% Usage: PTBInitLogFiles
%
% Author: Doug Bemis
% Date: 7/5/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBInitLogFiles

global PTBLogFileName;
global PTBDataFileName;
global PTBLogFileID;
global PTBDataFileID;

% Open them up
if ischar(PTBLogFileName)
	PTBLogFileID = fopen(PTBLogFileName, 'a','ieee-le.l64','UTF-8');
else
	PTBLogFileID = 1;
end
if ischar(PTBDataFileName)
	PTBDataFileID = fopen(PTBDataFileName, 'a','ieee-le.l64','UTF-8');
else
	PTBDataFileID = 1;
end

% Use the helper to start up
initFile(PTBLogFileID);
if ~strcmp(PTBDataFileName, PTBLogFileName)
	initFile(PTBDataFileID);
end

% Helper function
function initFile(fileID)

global isDebugging;

fprintf(fileID, '\n----------------------------------------------------------------------------\n');
fprintf(fileID, ['Started at: ' datestr(now) '\n']);
if isDebugging
	fprintf(fileID, 'Is Debugging.\n');
end
fprintf(fileID, '\n');
