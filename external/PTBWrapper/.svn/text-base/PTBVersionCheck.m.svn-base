%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBVersionCheck.m
%
% Checks the current version and errrors if we're not
% up to date
%
% Args:
%	- major: The major version number.
%	- minor: The minor version number.
%	- point: The point version number.
%	- mode: How we should relate
%		- at least: Current version must be at least that given.
%		- no more than: Current version must be no more than that given.
%		- less than: Current version must be more than given.
%		- more than: Current version must be less than that given.
%		- exactly: Current version must be exactly that given.
%
% Usage: PTBVersionCheck(1,0,0,'at least')
%
% Author: Doug Bemis
% Date: 3/1/10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBVersionCheck(major, minor, point, mode, info, recursive)

% Grab the info
if nargin < 5
    info = [];
end
if isempty(info)
    info = PTBWrapperVersion;
end

% Should we recurse or not
if nargin < 6
	recursive = 1;
end


% Check and error
for i = 1:3
	if checkValue(i, mode, info, [major, minor, point], recursive)
		return;
	end	
end

% Helper...
function value = checkValue(curr, mode, info, version, recursive)

% Set what we're checking
version_parts = {'major','minor','point'};
check = version(curr);
actual = info.(version_parts{curr});


% And check
value = -1;
if strcmpi(mode, 'at least')
	if actual > check
		value = 1;
	elseif actual == check
		value = 0;
	end
elseif strcmpi(mode, 'more than')
	if actual > check
		value = 1;
	elseif actual == check && curr < 3
		value = 0;
	end
elseif strcmpi(mode, 'no more than')
	if actual < check
		value = 1;
	elseif actual == check
		value = 0;
	end
elseif strcmpi(mode, 'less than')
	if actual < check
		value = 1;
	elseif actual == check && curr < 3
		value = 0;
	end
elseif strcmpi(mode, 'exactly')
	if actual == check
		value = 0;
	end
else
	error(['Unknown mode: ' mode '.']);
end

% Might have errored
if value < 0	
	
	% Might just be recursing
	if ~recursive
		error('Bad version');
	end
	
	% Show that we errored
	disp(' ');
	disp(['Version is no good. Need ' mode ' ' num2str(version(1)) '.' ...
		num2str(version(2)) '.' num2str(version(3)) '. Found ' num2str(info.major) '.' ...
		num2str(info.minor) '.' num2str(info.point) '.']);
	disp(' ');
	
	% Give a (hopefully) useful message
	for i = 1:length(info.past_versions)
		
		 % Make the new version info to check against
		new_v = info.past_versions{i}{1};
		[new_info.major new_v] = strtok(new_v,'.');
		[new_info.minor new_v] = strtok(new_v,'.');
		[new_info.point new_v] = strtok(new_v,'.');
		
		% Need to be numbers
		new_info.major = str2num(new_info.major);
		new_info.minor = str2num(new_info.minor);
		new_info.point = str2num(new_info.point);
		
		% Check if it's good
		is_good = 1;
		try
			PTBVersionCheck(version(1), version(2), version(3), mode, new_info, 0);
		catch
			is_good = 0;
		end	

		% If so, print out a message
		if is_good
			disp(['Try running the command: UpdatePTBWrapper([], ''' info.past_versions{i}{2} ''').']);
			disp(' ');
			error('Bad version');
		end
	end

	% Otherwise, somethings wrong
	error('Bad version, and there appear to be no good alternatives. Sorry...');
end

