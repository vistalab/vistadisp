%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBSetLogFiles.m
%
% Sets the log files. The second argument will cause all
% responses to be written to a second file. The third
% argument will record all keystrokes during the experiment.
% NOTE: An empty string will write to the command window.
%
%
% Args:
%	- logfile: The name of the log file.
%	- datafile: The name of the data file (optional).
%		* Will default to the logfile.
%
% Usage: PTBSetLogFiles('subj_log.txt','subj_data.txt')
%
% Author: Doug Bemis
% Date: 7/6/09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: Possibly allow changing during the experiment.
function PTBSetLogFiles(varargin)

if nargin < 1 || nargin > 4
	error('Wrong number of arguments.');
end

% Set
global PTBLogFileName;
PTBLogFileName = varargin{1};

% See if using different files for responses
global PTBDataFileName;
if nargin > 1
	PTBDataFileName = varargin{2};
else
	PTBDataFileName = PTBLogFileName;
end

% Might want a sound file for voice triggers
global PTBSoundFileName;
if nargin > 2
	PTBSoundFileName = varargin{3};
else
	PTBSoundFileName = 'Sound_Data';
end

% See if logging all keystrokes
global PTBKeyFileName;
if nargin > 3
	PTBKeyFileName = varargin{4};
else
	PTBKeyFileName = -1;
end
