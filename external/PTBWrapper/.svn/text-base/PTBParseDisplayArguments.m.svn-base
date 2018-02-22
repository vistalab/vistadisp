%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBParseDisplayArguments.m
%
% NOTE: Internal function. DO NOT CALL.
%
% TODO: Move to separate folder.
%
% Parses the arguments for the Display calls
% Args:
%	- args: The arguments to parse
%
% Usage: PTBParseDisplayArguments(varargin)
%
% Author: Doug Bemis
% Date: 3/2/10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [triggers triggers_delay key_condition wPtr] = PTBParseDisplayArguments(duration, args)

% Default if none
triggers = [];
triggers_delay = [];
key_condition = '';

% Parse any we have
for i = 1:length(args)
	if ~isempty(args{i})

		% Take all numbers to be triggers
		if isnumeric(args{i})
            
            % See if it's only a single number or number delay pair
            if length(args{i}) == 1
                triggers(end+1) = args{i}; %#ok<AGROW>

                % Second argument could be a delay
                triggers_delay(end+1) = 0; %#ok<AGROW>
                if length(args) > i
                    if isnumeric(args{i+1})
                        triggers_delay(end) = args{i+1}; %#ok<AGROW>
                        args{i+1} = '';
                    end				
                end
            else
                
                % Need these to be pairs
                if mod(length(args{i}),2) == 1
                    error('Need trigger, delay pairs. Exiting.');
                end
                
                % Put them all in
                for t = 1:2:length(args{i})
                    triggers(end+1) = args{i}(t); %#ok<AGROW>
                    triggers_delay(end+1) = args{i}(t+1); %#ok<AGROW>
                end
            end
                
		% Take all strings to be key conditions
		elseif ischar(args{i})
			key_condition = args{i};
		end
	end
end

% Get or make the appropriate window pointer
global PTBTheWindowPtr;
global PTBKeyQueue;
global PTBTheScreenNumber;
global PTBLastWindowPtr;

if ~isempty(PTBLastWindowPtr)
	wPtr = PTBLastWindowPtr;
elseif isempty(key_condition)
	wPtr = PTBTheWindowPtr;
else
	wPtr = PTBCreateScreen(PTBTheScreenNumber,0);
	PTBKeyQueue{end+1} = {key_condition, wPtr};
end

% Might want to keep using the pointer next time
if isnumeric(duration{1}) && (duration{1} == -1)
	PTBLastWindowPtr = wPtr;
else
	PTBLastWindowPtr = [];
end

