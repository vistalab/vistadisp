%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBHandleError.m
%
% Put this in the catch block of a try/catch loop.
% Will exit and perform cleanup, and, hopefully,
% print out the error that caused the exception.
%
% Args:
%
% Usage: PTBHandleError
%
% Author: Doug Bemis
% Date: 7/4/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBHandleError

% Grab the error, so we don't lose it.
e = psychlasterror;

% Reset settings
PTBCleanupExperiment;

% Print the error
% NOTE: May be a different type of error, in older matlabs
% TODO: Don't know why rethrow, etc. won't work correctly...
disp('  ');
disp(['ERROR: ' e.message]);
for i = 1:length(e.stack)
	disp(['FILE: ' e.stack(i).name]);
	disp(['LINE: ' num2str(e.stack(i).line)]);
	disp('  ');
end
error('There was an error.');
	

