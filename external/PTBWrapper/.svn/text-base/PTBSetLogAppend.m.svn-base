%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBSetLogAppend.m
%
% Sets data to append at the end of each log line.
%
% Args:
%	- position: The position to insert the first string
%       - e.g. 1 will insert at the beginning.
%		- Subsequent strings will be put in subsequent positions
%		* NOTE: 'end' is a valid position.
%	- mode: The mode to insert strings with
%		- 'clear': Clear the current append.
%		- 'insert': Insert new items into the current log
%		- 'overwrite': Overwrites any current items in the positions
%			needed for the new item.
%	- Comma delimited strings to add.
%
% Usage: PTBSetLogAppend(1,'clear',{'Condition','Item'})
%
% Author: Doug Bemis
% Date: 7/6/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBSetLogAppend(position, mode, items)

% Clear and set
global PTBLogAppend;

% Convert ends
if strcmpi(position,'end')
	position = length(PTBLogAppend)+1;
end

% Might be resetting
if strcmpi(mode,'clear')
	PTBLogAppend = {};
end

% Move for inserting
if strcmpi(mode,'insert')
	for i = length(PTBLogAppend):-1:position
		PTBLogAppend{i+length(items)} = PTBLogAppend{i};
	end
end

% Set the items into the append
for i = 1:length(items)
	PTBLogAppend{i-1+position} = items{i};
end
