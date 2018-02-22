%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBWriteLog.m
%
% NOTE: Internal function. DO NOT CALL.
%
% Write out a line to a log file. This is mainly used
% automatically and internally.
%
% Usage: PTBWriteLog(fid, event, type, tag, time, {'extra1','extra2'})
%
% Author: Doug Bemis
% Date: 7/6/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBWriteLog(fid, event, type, tag, time, varargin)

% Check for uninitialized
if isempty(fid)
    disp('WARNING: Nothing writting to log.');
    return;
end

% Append anything we need
global PTBLogAppend;

% Make all times relative to the start, as default
global PTBStartTime;

% Write out the line
% TODO: Think about buffering and not
% touching the file every time.
line = [event '\t' type '\t' tag '\t' num2str(time - PTBStartTime)];
for i = 1:length(varargin)
	line = [line '\t' varargin{i}]; %#ok<AGROW>
end
for i = 1:length(PTBLogAppend)
	line = [line '\t' PTBLogAppend{i}]; %#ok<AGROW>
end

% And print
fprintf(fid,[line '\n']);